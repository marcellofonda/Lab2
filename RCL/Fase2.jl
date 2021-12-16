using DelimitedFiles
using Gnuplot

include("../reglin.jl")

file1=open("periodo-ampiezza-sfasamento(unità oscilloscopio).csv", "r")
#a sarà una matrice con le seguenti colonne:
# - lettura del periodo in unità di quadratini sull'oscilloscopio
# - Incertezza sulla lettura del periodo in unità di quadratini sull'oscilloscopio
# - Ampiezza massima dell'onda in V
# - Incertezza sull'ampiezza massima in V
# - Sfasamento delle due onde in unità di quadratini sull'oscilloscopio
# - Incertezza sullo sfasamento in unità di quadratini sull'oscilloscopio.
a=readdlm(file1, ',', Float64)

#Questo file contiene i dati presi erroneamente leggendo le frequenze sulla
#scala del generatore. Risultano tuttavia compatibili con quelli presi
#nel file1.
file2=open("frequenza-ampiezza-sfasamento.csv", "r")
#b sarà una matrice analoga ad a, con le seguenti colonne:
# - lettura della frequenza in Hz
# - Incertezza sulla lettura della frequenza in Hz
# - Ampiezza massima dell'onda in V
# - Incertezza sull'ampiezza massima in V
# - Sfasamento delle due onde in s
# - Incertezza sullo sfasamento in s
b=readdlm(file2, ',', Float64)

#Converti i periodi in pulsazioni (misurate in Hz*Rad) simmetrizzando gli errori
a[:,1:2]= converti!(a[:,1:2], x-> 2π/(x * 20e-6) )
#Converti gli sfasamenti in unità di secondi
a[:,5:6]= converti!(a[:,5:6], x-> 20e-6 * x )

#Converti le frequenze in pulsazioni (misurate in Hz*Rad)
b[:,1:2]= converti!(b[:,1:2], x-> 2π*x)


#Ampiezza massima. Per ora, il massimo tra le letture, poi faremo meglio
V_0=21.
#Resistenza del resistore
R=250.
#L'induttanza delle induttanze, in H
L=110e-3
#Capacità del condensatore, in f
C=3.2e-9

ω_0=1/sqrt(L*C)
Γ=R/L
Q=ω_0/Γ

funzione_attesa(ω) = V_0/sqrt(1+ Q^2*(ω/ω_0-ω_0/ω)^2)



#Valore ottenuto estrapolando a V_0/√2
Γ_1=5158.5
Γ_2=3379
Γ_3=6921

La(Γ_x)=R/Γ_x
#Grafico su Gnuplot delle ampiezze in funzione delle pulsazioni
@gp a[:,1] a[:,3] a[:,2] a[:,4] "with xyerrorbars"
@gp :- b[:,1] b[:,3] b[:,2] b[:,4] "with xyerrorbars"
# @gp :- a[:,1] funzione_attesa.(a[:,1]) "with lines"
# Q=ω_0/Γ_1
@gp :- a[:,1] funzione_attesa.(a[:,1]) "with lines"
L=La(Γ_3)
ω_0=1/sqrt(L*C)
Γ=R/L
Q=ω_0/Γ
@gp :- a[:,1] funzione_attesa.(a[:,1]) "with lines"
save("../Grafici/RLC/pulsazioni-ampiezze.gp")

#Grafico su Gnuplot degli sfasamenti in funzione delle pulsazioni
@gp a[:,1] a[:,5] a[:,2] a[:,6] "with xyerrorbars"
@gp :- b[:,1] b[:,5] b[:,2] b[:,6] "with xyerrorbars"
