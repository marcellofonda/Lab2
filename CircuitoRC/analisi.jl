using Gnuplot
using DelimitedFiles
include("../reglin.jl")

function plotta(path)
    dati = open(path, "r")
    a=readdlm(dati, ',', Float64)

    ΔV=0.05
    σ_V=ΔV/sqrt(3)
    V0=a[end,2]
    a=a[1:end-1,:]

    a[:,2] .*= -1
    a[:,2] .+= V0
    a[:,2] = log.(a[:,2])
    fit = reglin(a,σ_V)

    println(fit)
    m=fit[1]
    ohm = 1000.
    C=1/(abs(m)*ohm)
    close(dati)
    println(C)
    @gp :- a[:,1] a[:,2] "w l"
end
@gp
plotta("dati.csv")
plotta("dati_scarica.csv")
save("circuitoRC.gp")
