#import Gnuplot
#using Gnuplot
#using DelimitedFiles

#USARE IL FILE DEI DATI
#io= open("dati1.csv", "r")

#a=readdlm(io, ',', Float64)

function rendilog(a)
    #a[:,end] = abs.(log.(a[:,1]) .- log.(a[:,1] .- a[:,end]))
    #a[:,1] = log.(a[:,1])
    converti(a, x -> log(x))
end

function inverti(a)
    a = converti(a, x -> 1/x)
end

function converti!(a, f) #a = [valori errori]
    b=f.(a[:,1])
    a[:,end] = max.( abs.( f.(a[:,1] .+ a[:,end]) .- b), abs.(b .- f.(a[:,1] .- a[:,end])) )
    a[:,1] = b
    return a
end

function reglin(a,Δy...)
    colonne=size(a,2)
    (colonne<2)&&error("Servono almeno due serie di dati per un fit!")
    (colonne==2)&&(size(Δy,1)==0)&&error("Serve almeno un'indicazione per l'incertezza su y!")

    x=a[:,1]
    y=a[:,2]

   n=size(x,1)

   σ_x=0
   σ_y=1

   if (colonne==3)
       σ_y=a[:,3]
   elseif (colonne==4)
       σ_x=a[:,3]
       σ_y=a[:,4]
   else
       σ_y=[Δy[1] for i in 1:n]
   end
   println(σ_y)
   #Definisci la funzione S come sommatoria...
   S(l,k)=sum([x[i]^l * y[i]^k / σ_y[i]^2 for i in 1:n])

   #Calcola D
   D=S(0,0)*S(2,0)-S(1,0)^2

   #Calcola coefficiente angolare e quota del fit
   m = 1/D * (S(0,0)*S(1,1)-S(1,0)*S(0,1))
   q = 1/D * (S(0,1)*S(2,0)-S(1,1)*S(1,0))



    if (colonne==4)
       global σ_y,σ_x,m
       println()
       sigma=σ_y
       for i in 1:2
           global σ_y, σ_x, m, q, D

           #println(m,q)
           #println(i)
           #println(σ_y)

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

    ρ_mq = -S(1,0)/sqrt(S(0,0)*S(2,0))
    return m, q, σ_m, σ_q, ρ_mq
end
#
# m = 0
# q= 0
# σ_m=0
# σ_q=0
# #m, q, σ_m, σ_q
# m, q, σ_m, σ_q= reglin(a)
#
# f(u)=m*u + q
#
# colonne=size(a,2)
#
# if (colonne==3)
#     @gp x y σ_y "w errorbars"
#     @gp :- x f.(x) "w l"
# elseif (colonne==4)
#     @gp x y σ_x σ_y "w xyerrorbars"
#     @gp :- x f.(x) "w l"
# end
# save("fit.gp")
#
# @gp x y.- f.(x) σ_y "w errorbars"
# save("differenze.gp")
