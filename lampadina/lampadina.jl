import Gnuplot
using Gnuplot
using DelimitedFiles


#USARE IL FILE DEI DATI
io= open("./lampadina/dati.csv", "r")

a=readdlm(io, ',', Float64)


 x=a[1:17,1]
 y=a[1:17,2]
 σ_y=a[1:17,3] ./ sqrt(3)

n=size(x,1)

n=size(x,1)
colonne=size(a,2)
σ_x=0
if (colonne==3)
    σ_y=a[:,3]
elseif (colonne==4)
    σ_x=a[:,3]
    σ_y=a[:,4]
else
    σ_y=[Δy for i in 1:n]
end

#Definisci la funzione S come sommatoria...
S(l,k)=sum([x[i]^l * y[i]^k / σ_y[i]^2 for i in 1:n])



#Calcola D
D=S(0,0)*S(2,0)-S(1,0)^2

#Calcola coefficiente angolare e quota del fit
m = 1/D * (S(0,0)*S(1,1)-S(1,0)*S(0,1))
q = 1/D * (S(0,1)*S(2,0)-S(1,1)*S(1,0))



if (colonne==4)
    println()
    sigma=σ_y
    for i in 1:2

        global sigma, σ_y, σ_x, m, q, D

        println(m,q)
        println(i)
        println(σ_y)

        σ_primo= σ_x.^2 .* m^2

        σ_y=sqrt.(sigma.^2 .+ σ_primo)

        #Calcola D
        D=S(0,0)*S(2,0)-S(1,0)^2

        #Calcola coefficiente angolare e quota del fit
        m = 1/D * (S(0,0)*S(1,1)-S(1,0)*S(0,1))
        q = 1/D * (S(0,1)*S(2,0)-S(1,1)*S(1,0))
    end
end

σ_m=sqrt(S(0,0)/D)
σ_q=sqrt(S(2,0)/D)

f(u)=m*u + q


@gp a[:,1] a[:,2] a[:,3].*3 "w errorbars"
@gp :- a[1:75,1] f.(a[1:75,1]) "w l"
save("../Grafici/Lampadina/lampadinaa.gp")


 @gp a[:,1] a[:,2].^2 a[:,3].*a[:,2].*6 "w errorbars"
 save("../Grafici/Lampadina/quadratico1.gp")
