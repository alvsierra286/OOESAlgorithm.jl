###########################
# LEXICOGRAPHIC OPERATION #
###########################
@inbounds function lex_min(instance::MOOInstance, c2::Vector{T}, c3::Vector{T}, c1::Vector{T}, stats) where {T<:Number}
	model = MathProgBase.LinearQuadraticModel(stats[:solver])
	MathProgBase.loadproblem!(model, instance.A, instance.v_lb, instance.v_ub, c2, instance.cons_lb, instance.cons_ub, :Min)
	MathProgBase.setvartype!(model, instance.var_types)
	MathProgBase.optimize!(model)
	try
		inds = findall(x -> x!="0.0", c2)
        	MathProgBase.addconstr!(model, inds, c2[inds], -Inf, MathProgBase.getobjval(model))
	catch
		return OOESolution()
	end
	MathProgBase.setobj!(model, c3)
	MathProgBase.optimize!(model)
	tmp = OOESolution(vars=MathProgBase.getsolution(model))
	tmp
end

@inbounds function lex_min(instance::MOOInstance, stats)
	non_dom_sols::Vector{OOESolution} = OOESolution[]
	tmp = OOESolution()
	for i in 1:2
		if i == 1
			tmp = lex_min(instance::MOOInstance, instance.c[2,:], instance.c[3,:], instance.c[1,:], stats)
		else
			tmp = lex_min(instance::MOOInstance, instance.c[3,:], instance.c[2,:], instance.c[1,:],  stats)
		end
		if length(tmp.vars) == 0
			continue
		else
			compute_objective_function_value!(tmp, instance)
			model = MathProgBase.LinearQuadraticModel(stats[:solver])
			MathProgBase.loadproblem!(model, instance.A, instance.v_lb, instance.v_ub, instance.c[1, :], instance.cons_lb, instance.cons_ub, :Min)
			MathProgBase.setvartype!(model, instance.var_types)
			c2 = instance.c[2,:]
			c3 = instance.c[3,:]
			inds = findall(x -> x!="0.0", c2)
        		MathProgBase.addconstr!(model, inds, c2[inds], -Inf, tmp.obj_vals[2] + Compute_Epsilon(tmp.obj_vals[2]))
			inds = findall(x -> x!="0.0", c3)
        		MathProgBase.addconstr!(model, inds, c3[inds], -Inf, tmp.obj_vals[3] + Compute_Epsilon(tmp.obj_vals[3]))
			MathProgBase.optimize!(model)
			try
				tmp.vars = MathProgBase.getsolution(model)
			catch
				tmp.vars = tmp.vars
			end
			compute_objective_function_value!(tmp, instance)
			tmp.fxopt = true	
			push!(non_dom_sols, tmp)
		end
	end
	#println(non_dom_sols)
	non_dom_sols
end

