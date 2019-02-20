# OOES.jl
A flexible, open-source package to optimize a Linear Function Over the Set of Efficient Solutions for BOMILP

This is a criterion space search for optimizing a linear function over the set of efficient solutions of bi-objective mixed integer linear programs. This project is a julia v0.6.2 project which is written in Linux (Ubuntu).

### The following problem classes are supported:
i. Objectives:    2 linear objectives.
ii. Constraints:  0 or more linear (both inequality and equality) constraints.
iii. Variables:
    a. Binary
    b. Integer variables
    c. Continous variables
    d. Any combination between previous types of variables.

### A multiobjective mixed integer linear instance can be provided as a input in 3 ways:
    a. ModoModel - an extension of JuMP Model
    b. LP file format
    c. MPS file format

### Any mixe integer programming solver supported by MathProgBase.jl can be used.
OOES.jl automatically installs FPBH.jl which comes with GLPK by default. If the user desires to use any other MIP solver, it must be separately installed. 

    a. OOES.jl has been successfully tested with:
        i.      GLPK - v4.61
        ii.     SCIP - v5.0.1
        iii.    Gurobi - v7.5
        iv.     CPLEX - v12.7.
    b. All parameters are already tuned.
    c. Supports parallelization

### Supporting and Citing
The software in this ecosystem was developed as part of academic research. If you would like to help support it, please star the repository as such metrics may help us secure funding in the future. We would be grateful if you could cite:

[Sierra-Altamiranda, A. and Charkhgard, H. (2018). OOES.jl: A julia package for optimizing a linear function over the set of efficient solutions for bi-objective mixed integer linear programming.](http://www.optimization-online.org/DB_FILE/2018/04/6596.pdf)
