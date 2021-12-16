using Gnuplot
BIG_N = 1000

"""
    conteggio(a, intervalli, iniz, fin)
Count how many elements in array `a` are present in each of the `intervalli` subintervals of `iniz:fin`. Return the midpoints of the subintervals, the countings and the width of the subintervals.
"""
function conteggio(a, intervalli, iniz, fin)
	h=(fin-iniz)/intervalli
	a = a .- iniz
	a = a ./ h
	a = trunc.(Int, a) .+ 1

	b=zeros(intervalli)
	c=[iniz + i*h + h/2 for i in 0:intervalli-1]
	for x in a
		(x <= intervalli) && (b[x]=b[x]+1)
	end

	return c, b, h
end

gauss(x,μ, σ) = 1/(σ*sqrt(2*π)) * exp(-(x - μ)^2/(2*σ^2))

#1. Uniforme


#2. Bernoulli
bernoulli(n,p,k) = n>=p && 0<= p && p<= 1 ? binomial(n,k) * p^k * (1-p)^(n-k) : error("Errore, non posso calcolare con k>n")
poisson(ν,k)=big(ν)^k*exp(-ν)/factorial(big(k))

N=4
p=0.8


"""
    genera(distrib::String, p::Float64, N::Integer; histo::Bool=false, path::String="default", name::String="histo_\$distrib-\$N-\$p")
Generate `BIG_N` numbers with binomial or poisson distribution and save a histogram, if required.
# Arguments
- `distrib::String`: the distribution function. It has to be either `"binom"` or `"poisson"`.
- `p::Float64`: the probability in the binomial distribution, or the expected value of poisson distribution.
- `N::Integer`: the number of events in binomial distribution, or the number of histogram bars if distribution is Poisson. If distribution is Poisson and histo=false, this parameter is useless.
- `histo::Bool=false`: whether to save or not a histogram with the generated numbers.
- `path::String="../Grafici/default"`: the local path to the folder where to save the histogram.
- `name::String="histo_\$distrib-\$N-\$p"`: the name of the file. Extension is automatically added.
"""
function genera(distrib::String, p::Float64, N::Integer; histo::Bool=false, path::String="../Grafici/default", name::String="histo_$distrib-$N-$p")
	distrib ∈ ["binom", "poisson"] || error("""Distribuzione "$distrib" non supportata!""")
	intervalli=N
	if (distrib == "poisson")
		N = trunc(Int, p * 100)
		p = 0.01
	end
	prob(k)= distrib == "poisson" ? poisson(N*p,k) : bernoulli(N,p,k)

	a=[sum([x<p ? 1 : 0 for x in rand(Float64,(N))]) for i in 1:BIG_N]

	if (histo)
		x, y = conteggio(a, intervalli+1, -.5, intervalli + .5)

		erra(k) = sqrt(BIG_N * prob(k) * (1 - prob(k)))
		x=trunc.(Int, x)
		@gp x y erra.(x) "w boxerrorbars fs solid .5" #[err for i in 1:intervalli+1]

		@gp :- x BIG_N .* prob.(x)
		w = 0:.1:(distrib=="poisson" ? intervalli + 1 : N+1)
		@gp :- w BIG_N .* gauss.(w,N*p,sqrt(N*p*(1-p))) .* ((distrib=="poisson") ? 1 : (N/intervalli)) "w l"
		#Salva l'istogramma se richiesto
		save("$path/$name.gp")
	end
	return a
end

"Generates `N` numbers with distribution N(μ, σ)"
normale(N, μ, σ)=randn(Float64, (N)) .* σ .+ μ
normale(μ, σ)=randn(Float64) .* σ .+ μ
"Package `conteggio` loaded correctly"


	#plot(a)
	#histogram(a)
	#plot!( -4.:.1:4., BIG_N .* gauss(-4.:.1:4.,0,1) .* .5 )
