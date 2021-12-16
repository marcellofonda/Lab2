include("../reglin.jl")
include("../Esercizio 2/conteggio.jl")

V=Array(.4:.2:1.6)
m0=5.1
σ=[.05,.05,.05,.1,.1,.1,.1]
m0.*V
#valori = [V m0 .* V .+ normale.(0, σ) σ]

a = Array{NTuple{5,Float64}}(undef,5000)
for i in 1:5000
    global a
    a[i]=reglin([V m0 .* V .+ normale.(0, σ) σ])
end
reinterpret(Float64,a)
a=transpose(reshape(reinterpret(Float64,a),5, 5000))

σ_medio(n, m)=sum(a[:,n].*a[:,m])/5000 - (sum(a[:,n])/5000)*(sum(a[:,m])/5000)
dhdhdhd=a[1,3]
fhfhfhf=a[1,4]
rho=a[1,5]
σ_medio_m = sqrt(σ_medio(1,1))
σ_medio_q = sqrt(σ_medio(2,2))
σ_medio_mq= σ_medio(1,2)
rhoaa=σ_medio_mq/(σ_medio_m*σ_medio_q)

println("Punto 2: Le stime delle varianze su m e q e del loro coefficiente di correlazione sono costanti e valgono")
println("$dhdhdhd, $fhfhfhf e $rho.")
println("I valori ottenuti con i valori medi sono")
println("$σ_medio_m, $σ_medio_q, $rhoaa")
soQquadro(m,q,σ_m,σ_q,ρ) = 1/(1-ρ^2) * (((m-m0)/σ_m)^2 + (q/σ_q)^2 - 2ρ*(m-m0)q/(σ_q*σ_m))

Qquadri=[soQquadro(a[i,:]...) for i in 1:5000]
conteggia_ellisse = sum([i <= 4 ? 1 : 0 for i in Qquadri])

conteggia_m = sum([i > m0 - 2dhdhdhd && i < m0+2dhdhdhd ? 1 : 0 for i in a[:,1]])
conteggia_q = sum([i > -2fhfhfhf && i<2fhfhfhf ? 1 : 0 for i in a[:,2]])
