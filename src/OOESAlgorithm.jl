__precompile__()
module OOESAlgorithm

using Distributed, MathOptInterface, JuMP, MathProgBase, GLPK, GLPKMathProgInterface, Pkg, SparseArrays

println("Using GLPKSolverMIP as default solver")
if ("Gurobi" in keys(Pkg.installed()))
	using Gurobi
	println("For using GurobiSolver, add mipsolver=2")
end
if ("CPLEX" in keys(Pkg.installed()))
	using CPLEX
	println("For using CplexSolver, add mipsolver=3")
end
if ("SCIP" in keys(Pkg.installed()))
	using SCIP
	println("For using SCIPSolver, add mipsolver=4")
end
if ("Xpress" in keys(Pkg.installed()))
	using Xpress
	println("For using XpressSolver, add mipsolver=5")
end
include("OOES_Algorithm.jl")

export OOES

end
