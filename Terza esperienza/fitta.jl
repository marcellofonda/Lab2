using Gnuplot
using DelimitedFiles
include("../reglin.jl")
#files=[71, 49, 36, 18, 4, "77K"]
files=["../RCL/dati"]
pendenze=[]
intercette=[]
@gp [0] [0]
scrivi=open("bigbro2.txt","w")


for nome in files
    println("aaaaaaaaaaaaaaaaaaaaaaa")

    input=open("$nome.csv","r")
    a=readdlm(input, ',', Float64)



    a[:,3] = a[:,3] ./ sqrt(3)
    a[:,4] = abs.(log.(a[:,2]) .- log.(a[:,2] .- a[:,4]))
    a[:,2] = log.(a[:,2])
    println(a)

    m, q, sfsfe, eggreg = reglin(a)
    println("m=$m, q=$q")
    push!(pendenze, m)
    push!(intercette, q)
    x= 0:1e-6:27.5e-6
    @gp :- a[:,1] a[:,2] a[:,3] a[:,4] "w xyerrorbars"
    @gp :- x m .* x .+ q "w l"
end

println(pendenze)
println(intercette)
@gp :-
save("../Grafici/RLC/tempo-log(ampiezza).gp")
#save("../Grafici/TerzaEsperienza/guardacomedondolo.gp")

# Temperature=[files[i] + 273.15 for i in 1:5]
# push!(Temperature, 77)
#
# q=1.6e-19
# k=1.38e-23
# η=q ./ (k .* Temperature .* pendenze)
# risultato=sum(η)/6
#
# voltaggi=[(log(I) .- intercette) ./ pendenze for I in [10e-3, 8e-3, 6e-3]]
# using Plots
# gr()
# @gp [0] [0]
# for v in voltaggi
#     println(scrivi, [Temperature v])
#     write(scrivi, "\n\n\n")
#
# end
# close(scrivi)
# #save("caca.gp")
