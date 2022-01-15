#-1/2,  -2,  -9/2
using CUDA
using DelimitedFiles
using Gnuplot
#using Cthulhu
import Base.*
include("../conteggio.jl")
dati =open("dati.txt", "r")

a= readdlm(dati, ' ', Float64)

close(dati)

const θ_1=a[1,1]
const θ_2p=CuArray(a[:,2])
gϵ_p=CuArray(a[:,3])
const σ_p=CuArray(a[:,4])
const θ_2c=CuArray(a[:,5])
gϵ_c=CuArray(a[:,6])
const σ_c=CuArray(a[:,7])

const epsilon = .001

#Prodotto cartesiano
×(a,b) = [(x,y) for x in a for y in b]

μ_p_func(a_c::Float64,a_p::Float64,θ_1::Float64,θ_2::Float64) = a_c * a_p * θ_1 * θ_2
μ_c_func(a_c::Float64,a_p::Float64,θ_1::Float64,θ_2::Float64) = a_c^2 * θ_1 * θ_2

addendo(μ::Float64,ϵ::Float64,σ::Float64)= -.5 * log(2π * σ^2) - (ϵ - μ)^2/(2σ^2)

ln_likelihood_parziale(μ::CuArray{Float64},ϵ::CuArray{Float64},σ::CuArray{Float64}) = sum(addendo.(μ,ϵ,σ))

function ln_likelihood( a_c::Float64,
                        a_p::Float64,
                        ϵ_p::CuArray{Float64},
                        ϵ_c::CuArray{Float64})
    μ_p = μ_p_func.(a_c,a_p,θ_1,θ_2p)
    μ_c = μ_c_func.(a_c,a_p,θ_1,θ_2c)

    ln_likelihood_p = ln_likelihood_parziale(μ_p, ϵ_p, σ_p)
    ln_likelihood_c = ln_likelihood_parziale(μ_c, ϵ_c, σ_c)

    return ln_likelihood_c + ln_likelihood_p
end

*(x::Tuple{Float64,Float64}, y::Bool) = y ? x : (NaN,NaN)

function estrai_corrispondenti(punti::CuArray{Tuple{Float64,Float64}}, valori::CuArray{Float64}, condizione)
    punti .*= condizione.(valori)
    return CuArray{Tuple{Float64,Float64}}(filter(x -> (x[1] <= 1)!=(x[1] >= 1), punti))
end



ics(a::Tuple{Float64,Float64})=a[1]
ips(a::Tuple{Float64,Float64})=a[2]

tolleranzavariata(x::Float64, epsilon::Float64) = (abs(x) < epsilon)
tolleranza(x::Float64) = tolleranzavariata(x,epsilon)

function trova_max_likelihood(  range::CuArray{Tuple{Float64, Float64}},
                                likelihood::CuArray{Float64},
                                ϵ_p::CuArray{Float64},
                                ϵ_c::CuArray{Float64})

    # function funzione_likelirobin(a_c::Float64, a_p::Float64)
    #     ln_likelihood(a_c, a_p, θ_1, θ_2p, θ_2c, ϵ_p, σ_p, ϵ_c, σ_c)
    # end
    funzione_likelihood(x::Tuple{Float64, Float64}) = ln_likelihood(x[1], x[2], ϵ_p, ϵ_c)
    #funzione_likelihood.(range)
    likelihood .= funzione_likelihood.(range)

    massimo = maximum(likelihood)

    massimi = estrai_corrispondenti(range, likelihood, x::Float64 -> x == massimo)
    begin
        #unsigma = estrai_corrispondenti(range, likelihood .- (massimo - .5), tolleranza)
        #duesigma = estrai_corrispondenti(range, likelihood .- (massimo - 2.), tolleranza)
        #tresigma = estrai_corrispondenti(range, likelihood .- (massimo - 4.5), tolleranza)

        #println(size(unsigma)[1]+size(duesigma)[1]+size(tresigma)[1])

        #@gp Vector(ics.(massimi)) Vector(ips.(massimi))
        #@gp :- Vector(ics.(unsigma)) Vector(ips.(unsigma))
        #@gp :- Vector(ics.(duesigma)) Vector(ips.(duesigma))
        #@gp :- Vector(ics.(tresigma)) Vector(ips.(tresigma))

        #save("polpo.gp")
    end
    return massimi[end]
end


range_a_c = -.2:.005:.8
range_a_p = -1.5:.01:5
const reset_ranga = CuArray{Tuple{Float64, Float64}}(range_a_c × range_a_p)
ranga = [CuArray(reset_ranga) for i in 1:Threads.nthreads()]
liklihud = [CuArray{Float64}(undef, size(reset_ranga)[1]) for i in 1:Threads.nthreads()]


println("aaa")
@code_warntype trova_max_likelihood(ranga[1],liklihud[1], gϵ_p, gϵ_c)
@time max_stimato = trova_max_likelihood(ranga[1],liklihud[1], gϵ_p, gϵ_c)
println(max_stimato)


ϵ_c_stimato(θ_2) = max_stimato[1]^2 * θ_1 * θ_2
ϵ_p_stimato(θ_2) = max_stimato[2] * max_stimato[1] * θ_1 * θ_2

const ϵ_c_stimati = ϵ_c_stimato.(θ_2c)
const ϵ_p_stimati = ϵ_c_stimato.(θ_2p)
println("Checkpoint")
n_simulazioni=1000
VALORIII=Vector{Tuple{Float64, Float64}}(undef,n_simulazioni)
println("ssssss")

buffer=Array{Int}(undef,n_simulazioni)
Threads.@threads for i in 1:n_simulazioni
    buffer[i]=Threads.threadid()
end

@time Threads.@threads for i in 1:n_simulazioni
    ϵ_c_calc = normale.(ϵ_c_stimati, σ_c)
    ϵ_p_calc = normale.(ϵ_p_stimati, σ_p)
    ranga[buffer[i]] .= reset_ranga
    VALORIII[i]=trova_max_likelihood(ranga[buffer[i]], liklihud[buffer[i]], ϵ_p_calc, ϵ_c_calc)
end

println("AAAA")

#griglia = Array((-.2:.05:.8) × (-1.5:.05:5))

@gp ics.(VALORIII) ips.(VALORIII)

#condizione(punto) =

#output=open("repliche.txt", "w")
#println(output, VALORIII)
#close(output)
