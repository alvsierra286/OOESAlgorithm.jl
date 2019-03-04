__precompile__()
module OOESAlgorithm

using Distributed, MathOptInterface, JuMP, MathProgBase, GLPK, GLPKMathProgInterface, Pkg, SparseArrays

println("******************************************************************")
println("******************************************************************")
println("*****                                                        *****")
println("*****               Welcome to OOESAlgorithm                 *****")
println("*****           A comprehensive Julia package for            *****")
println("***** Bi-Objective Mixed Integer Linear Programming Problems *****")
println("*****                                                        *****")
println("***** To support us please cite:                             *****")
println("*****                                                        *****")
println("***** Sierra-Altamiranda, A., Charkhgard, H., 2018.          *****")
println("***** A new exact algorithm to optimize a linear function    *****")
println("***** over the set of efficient solutions for bi-objective   *****")
println("***** mixed integer linear programming. INFORMS Journal on   *****")
println("***** Computing To appear.                                   *****")
println("*****                                                        *****")
println("***** Sierra-Altamiranda, A., Charkhgard, H., 2018.          *****")
println("***** OOESAlgorithm.jl: A julia package for optimizing a     *****")
println("***** linear function over the set of efficient solutions    *****")
println("***** for bi-objective mixed integer linear programming      *****")
println("*****                                                        *****")
println("******************************************************************")
println("******************************************************************")

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
