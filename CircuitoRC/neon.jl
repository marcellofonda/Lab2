using Gnuplot
using DelimitedFiles

dati=open("dati_neon.csv", "r")
#[voltaggi periodi]
a=readdlm(dati, ',', Float64)
#Voltaggio-frequenza
@gp a[:,1] a[:,2].\1 #"w l"
