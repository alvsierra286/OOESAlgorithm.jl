##################
# DIAGONAL SPLIT #
##################
@inbounds function Split_Diagonal(obj::Vector{T}, cons::Vector{T}, diagonal_bound::T, lambda::T, instance::MOOInstance, initial_solution::Vector{T}, stats) where {T<:Number}
	tmp = OOESolution()
	model = MathProgBase.LinearQuadraticModel(stats[:solver])
	MathProgBase.loadproblem!(model, instance.A, instance.v_lb, instance.v_ub, obj, instance.cons_lb, instance.cons_ub, :Min)
	MathProgBase.setvartype!(model, instance.var_types)
	extra_constraint = obj - diagonal_bound * cons
	inds = findall(x -> x!="0.0", extra_constraint)
	MathProgBase.addconstr!(model, inds, extra_constraint[inds], lambda, Inf)
	MathProgBase.optimize!(model)
	try
		tmp.vars = MathProgBase.getsolution(model)
	catch
		tmp.vars = initial_solution
	end
	compute_objective_function_value!(tmp, instance)
	tmp
end

###############################
# DIVISION OF OBJECTIVE SPACE #
###############################
@inbounds function horizontal_division_of_objective_space(initial_solutions::Vector{Vector{OOESolution}}, instance::MOOInstance, Partial_Solutions::Vector{OOESolution}, threads::Int64, stats)
	element1 = Partial_Solutions[1]
	element2 = OOESolution()
	bound_variation = (element1.obj_vals[3] - Partial_Solutions[2].obj_vals[3])/ threads
	half_bound::Float64 = element1.obj_vals[3] - bound_variation
	for i in 1: threads - 1
		element2 = Split_Triangle(instance.c[2,:], instance.c[3,:], half_bound, instance, Partial_Solutions[2].vars, stats)
		stats[:Number_MIPs] += 1
		element2 = Weighted_Sum(instance, element2, stats)
		stats[:Number_MIPs] += 1
		element2, Opt_Solution, GUB, stats = LB_Finder_Point(instance, element2, deepcopy(element2), 0.0, false, stats)
		tmp = [element1, element2]
		initial_solutions[i] = tmp
		element1 = element2
		half_bound += -bound_variation
	end
	initial_solutions[threads] = [element1, Partial_Solutions[2]]
	initial_solutions, stats
end

@inbounds function vertical_division_of_objective_space(initial_solutions::Vector{Vector{OOESolution}}, instance::MOOInstance, Partial_Solutions::Vector{OOESolution}, threads::Int64, stats)
	element1 = Partial_Solutions[1]
	element2 = OOESolution()
	bound_variation = (Partial_Solutions[2].obj_vals[2] - element1.obj_vals[2])/ threads
	half_bound::Float64 = element1.obj_vals[2] + bound_variation
	for i in 1: threads - 1
		element2 = Split_Triangle(instance.c[3,:], instance.c[2,:], half_bound, instance, element1.vars, stats)
		stats[:Number_MIPs] += 1
		element2 = Weighted_Sum(instance, element2, stats)
		stats[:Number_MIPs] += 1
		element2, Opt_Solution, GUB, stats = LB_Finder_Point(instance, element2, deepcopy(element2), 0.0, false, stats)
		tmp = [element1, element2]
		initial_solutions[i] = tmp
		element1 = element2
		half_bound += bound_variation
	end
	initial_solutions[threads] = [element1, Partial_Solutions[2]]
	initial_solutions, stats
end

@inbounds function diagonal_division_of_objective_space(initial_solutions::Vector{Vector{OOESolution}}, instance::MOOInstance, Partial_Solutions::Vector{OOESolution}, threads::Int64, stats)
	element1 = Partial_Solutions[1]
	element2 = OOESolution()
	tmp_angle = (pi/2)/threads
	for i in 1: threads - 1
		tmp_angle *= i
		diagonal_bound = tan(tmp_angle)
		lambda = element1.obj_vals[3] - (Partial_Solutions[2].obj_vals[2] * diagonal_bound)
		element2 = Split_Diagonal(instance.c[3,:], instance.c[2,:], diagonal_bound, lambda, instance, element1.vars, stats)
		stats[:Number_MIPs] += 1
		element2 = Weighted_Sum(instance, element2, stats)
		stats[:Number_MIPs] += 1
		element2, Opt_Solution, GUB, stats = LB_Finder_Point(instance, element2, deepcopy(element2), 0.0, false, stats)
		tmp = [element1, element2]
		initial_solutions[i] = tmp
		element1 = element2
	end		
	initial_solutions[threads] = [element1, Partial_Solutions[2]]
	initial_solutions, stats
end

##############################
# PARALLELIZATION TECHNIQUES #
##############################
@inbounds function parallel_division_of_objective_space(initial_solutions::Vector{Vector{OOESolution}}, instance::MOOInstance, Partial_Solutions::Vector{OOESolution}, threads::Int64, parallelization::Int64, stats)
	if parallelization == 1
		initial_solutions, stats = horizontal_division_of_objective_space(initial_solutions, instance, Partial_Solutions, threads, stats)
	elseif parallelization == 2
		initial_solutions, stats = vertical_division_of_objective_space(initial_solutions, instance, Partial_Solutions, threads, stats)
	else
		initial_solutions, stats = diagonal_division_of_objective_space(initial_solutions, instance, Partial_Solutions, threads, stats)
	end
	initial_solutions, stats	
end
