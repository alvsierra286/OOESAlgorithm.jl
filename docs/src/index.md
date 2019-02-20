# OOESAlg: A comprehensive julia package to optimize a linear function over the efficient set of Biobjective Mixed Integer Linear Programming problems. #

This package contains a criterion space search algorithm for optimizing a linear function over the set of efficient solutions of bi-objective mixed integer linear programs. This is a julia v1.0.2 project written in Linux (Ubuntu). Important characteristics of this package are:

1. **Can solve any (both structured and unstructured) biobjective mixed integer linear problem. The following problem classes are supported:**
    1. Objectives: 2 linear objectives and one extra objective to be optimized over the efficient set.
    2. Constraints: 0 or more linear (both inequality and equality) constraints
    3. Variables:
        1. Binary variables
        2. Integer variables
        3. Continuous variables
2. **A biobjective mixed integer linear instance can be provided as a input in 4 ways:**
    1. [JuMP Model](https://github.com/JuliaOpt/JuMP.jl)
    2. LP file format
    3. MPS file format
3. **Any linear programming solver supported by MathProgBase.jl can be used. No mixed integer programming solver is required**. [OOESAlg](https://github.com/alvsierra286/OOESAlg) automatically installs [GLPK](https://github.com/JuliaOpt/GLPKMathProgInterface.jl) by default. If the user desires to use any other MIP solver, it must be separately installed. [OOESAlg](https://github.com/alvsierra286/OOESAlg) has been successfully tested with:
    1. [GLPK - v4.61](https://github.com/JuliaOpt/GLPKMathProgInterface.jl)
    2. [SCIP - v5.0.1](https://github.com/SCIP-Interfaces/SCIP.jl)
    3. [Gurobi - v7.5](https://github.com/JuliaOpt/Gurobi.jl)
    4. [CPLEX - v12.7](https://github.com/JuliaOpt/CPLEX.jl).
4. **Supports parallelization.**

## Contents: ##

```@contents
Pages = ["installation.md", "getting_started.md", "advanced.md", "solving_instances_from_literature.md"]
```

## Supporting and Citing: ##

The software in this ecosystem was developed as part of academic research. If you would like to help support it, please star the repository as such metrics may help us secure funding in the future. If you use [OOESAlg](https://github.com/alvsierra286/OOESAlg) software as part of your research, teaching, or other activities, we would be grateful if you could cite:

1. [Sierra-Altamiranda, A. and Charkhgard, H., A New Exact Algorithm to Optimize a Linear Function Over the Set of Efficient Solutions for Bi-objective Mixed Integer Linear Programming.](http://www.optimization-online.org/DB_FILE/2017/10/6262.pdf).
2. [Sierra-Altamiranda, A. and Charkhgard, H. (2018). OOES.jl: A julia package for optimizing a linear function over the set of efficient solutions for bi-objective mixed integer linear programming.](http://www.optimization-online.org/DB_FILE/2018/04/6596.pdf).

## Contributions ##

This package is written and maintained by [Alvaro Sierra-Altamiranda](https://github.com/alvsierra286). Please fork and send a pull request or create a [GitHub issue](https://github.com/alvsierra286/OOESAlg/issues) for bug reports or feature requests.
