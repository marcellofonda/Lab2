import Gnuplot
using Gnuplot
using DelimitedFiles

#USARE IL FILE DEI DATI
io= open("aga.csv", "r")

a=readdlm(io, ',', Float64)

x=a[:,1]
y=a[:,2]
σ_y=a[:,3]

n=size(x,1)

#x=[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
#y=[3.0, 4.0, 5.0, 6., 7, 7.9, 9., 10.0,11.0,12.0]
#σ_y=[.3 for i in 1:10]
#σ_x=[1.0]

#Definisci la funzione S come sommatoria...
S(l,k)=sum([x[i]^l * y[i]^k / σ_y[i] for i in 1:n])

#Calcola D
D=S(0,0)*S(2,0)-S(1,0)^2

#Calcola coefficiente angolare e quota del fit
m = 1/D * (S(0,0)*S(1,1)-S(1,0)*S(0,1))
q = 1/D * (S(0,1)*S(2,0)-S(1,1)*S(1,0))

σ_m=sqrt(S(0,0)/D)
σ_q=sqrt(S(2,0)/D)

f(u,m)=m*u + q

@gp x y σ_y "w errorbars"
@gp :- x f.(x,m+σ_m).-σ_q f.(x,m+σ_m).+σ_q "w filledcu lc 'red' fs transparent solid 0.5"
@gp :- x f.(x,m-σ_m) .- σ_q f.(x,m-σ_m) .+ σ_q "w filledcu lc 'red' fs transparent solid 0.5"
@gp :- x f.(x,m) "w l"
