include("../Esercizio 2/conteggio.jl")

a=rand(Float64,(BIG_N))

x, y = conteggio(a, 12, -.1, 1.1 )
@gp x y [sqrt(90) for i in 1:12] "w boxerrorbars fs solid .5"
save("isto1unif.gp")

genera("binom",.8, 12, histo=true)
genera("binom",.8, 12)

genera("poisson",3.2,15, histo=true)

x="a"
x∈["b","a"]
1∈[1,2]

a=[sum(rand(Float64, (12)) .- 0.5) for i in 1:1000]
	x, y, h = conteggio(a, 21, -4., 4.)
	errore(x)=sqrt(BIG_N * gauss(x,0,1) * h * (1. - h * gauss(x,0,1)))
	@gp x y errore.(x) "w boxerrorbars fs solid .5"
	x=-4.5:.1:4.5
	@gp :- x BIG_N .* gauss.(x,0,1) .* h "w l"
