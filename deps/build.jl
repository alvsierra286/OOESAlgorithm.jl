using Pkg
if !("MathProgBasse" in keys(Pkg.installed()))
	Pkg.add("MathProgBase")
end
if !("MathOptInterface" in keys(Pkg.installed()))
	Pkg.add("MathOptInterface")
end
if !("GLPKMathProgInterface" in keys(Pkg.installed()))
	Pkg.add("GLPKMathProgInterface")
end
if !("GLPK" in keys(Pkg.installed()))
	Pkg.add("GLPK")
end
if !("JuMP" in keys(Pkg.installed()))
	Pkg.add("JuMP")
end
