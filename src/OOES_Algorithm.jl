###############################################################################
#                                                                             #
#  This file is part of the julia module for Multi Objective Optimization     #
#  (c) Copyright 2017 by Alvaro Sierra-Altamiranda, Hadi Charkhgard           #
#                                                                             #
# This license is designed to guarantee freedom to share and change software  #
# for academic use, but restricting commercial firms from exploiting our      #
# knowhow for their benefit. The precise terms and conditions for using,      #
# copying, distribution, and modification follow. Permission is granted for   #
# academic research use. The license expires as soon as you are no longer a   # 
# member of an academic institution. For other uses, contact the authors for  #
# licensing options. Every publication and presentation for which work based  #
# on the Program or its output has been used must contain an appropriate      # 
# citation and acknowledgment of the authors of the Program.                  #
#                                                                             #
# The above copyright notice and this permission notice shall be included in  #
# all copies or substantial portions of the Software.                         #
#                                                                             #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     #
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         #
# DEALINGS IN THE SOFTWARE.                                                   #
#                                                                             #
###############################################################################

using JuMP, MathProgBase, GLPKMathProgInterface, Pkg, SparseArrays

include("Storage.jl")
include("Read_Instances.jl")
include("Point_Differences_Epsilons.jl")
include("Priority_Queue_Update.jl")
include("Lex_Min_Operation.jl")
include("Weighted_Sum_Method.jl")
include("Line_Detector.jl")
include("LB_Finder_Operations.jl")
include("Splitting_Triangle.jl")
include("Triangle_Operations.jl")
include("Parallelization.jl")
include("Exploring_Queue.jl")
include("Writing_Results.jl")

#################
# THE ALGORITHM #
#################
@inbounds function OOES(instance::MOOInstance, instance2::MOOInstance, Partial_Solutions::Vector{OOESolution}, Priority_Queue::Vector{EOPriorQueue}, number_of_cont_variables::Int64, number_of_int_or_bin_variables::Int64, Feasible_Solution::OOESolution, Opt_Solution::OOESolution, GUB::Float64, initial_time::Float64, timelimit::Float64, threads::Int64, parallelization::Int64, stats)
	Search_Done::Bool = false
	Epsilon::Float64 = 1e-5
	Epsilon6::Float64 = 1e-5
	while (length(Priority_Queue) > 0) && (Search_Done == false) && (time() - initial_time <= timelimit)
		GLB = Priority_Queue[1].LBound
		Relative_Gap = abs(GUB - GLB) / (abs(GUB) + Epsilon)
		stats[:iteration] += 1
		if (Relative_Gap < Epsilon6) || (GUB <= GLB + Epsilon6)
			Search_Done = true;
		elseif threads > 1 && parallelization == 4
			threads_to_use::Int64 = min(length(Priority_Queue), threads)
			num_threads::Vector{Int64} = setdiff(procs(), myid())[1:threads_to_use]
			Priority_Queue_Vector::Vector{Vector{EOPriorQueue}} = fill(EOPriorQueue[], threads_to_use)
			tmp_stats = initialize_statistics(stats[:solver])	
			for i in 1:threads_to_use
				Priority_Queue_Vector[i] = [Priority_Queue[1]]
				popfirst!(Priority_Queue)
			end
			vector_of_solutions::Vector{Parallel_Solutions} = fill(Parallel_Solutions(), threads_to_use)
			@sync begin
				for i in 1:threads_to_use
					@async begin
						vector_of_solutions[i] = remotecall_fetch(parallel_exploring_1st_element_of_queue, num_threads[i], copy(instance), copy(instance2), Partial_Solutions, Priority_Queue_Vector[i], number_of_cont_variables, number_of_int_or_bin_variables, Feasible_Solution, Opt_Solution, GUB, timelimit, tmp_stats)
					end
				end
			end
			Opt_Solution, GUB = vector_of_solutions[1].Opt_Solution, vector_of_solutions[1].GUB
			if threads_to_use > 1
				for i in 2:threads_to_use
					if vector_of_solutions[i].Opt_Solution.obj_vals[1] < Opt_Solution.obj_vals[1]
						Opt_Solution = vector_of_solutions[i].Opt_Solution
					end
					if vector_of_solutions[i].GUB < GUB
						GUB = vector_of_solutions[i].GUB
					end
				end
			end
			for i in 1:threads_to_use
				stats = parallel_statistics(stats, vector_of_solutions[i].stats)
				for j in 1:length(vector_of_solutions[i].Priority_Queue)
					insert_element_in_queue!(Priority_Queue, vector_of_solutions[i].Priority_Queue[j].Sol_Top, vector_of_solutions[i].Priority_Queue[j].Sol_Bottom, vector_of_solutions[i].Priority_Queue[j].Shape, vector_of_solutions[i].Priority_Queue[j].Direction, vector_of_solutions[i].Priority_Queue[j].LBound)
				end
			end
		else
			Priority_Queue, Partial_Solutions, Opt_Solution, GUB, stats = exploring_1st_element_of_queue(instance, instance2, Partial_Solutions, Priority_Queue, number_of_cont_variables, number_of_int_or_bin_variables, Feasible_Solution, Opt_Solution, GUB, timelimit, stats)
		end
	end
	GLB::Float64 = Opt_Solution.obj_vals[1]
	if (length(Priority_Queue) > 0) && (time() - initial_time > timelimit)
		GLB = Priority_Queue[1].LBound
	end
	Opt_Solution, stats, GLB
end

@inbounds function OOES(instance::MOOInstance, instance2::MOOInstance, Partial_Solutions::Vector{OOESolution}, Priority_Queue::Vector{EOPriorQueue}, number_of_cont_variables::Int64, number_of_int_or_bin_variables::Int64, Feasible_Solution::OOESolution, Opt_Solution::OOESolution, timelimit::Float64, threads::Int64, parallelization::Int64, stats)
	initial_time::Float64 = time()
	GLB::Float64 = -1e10
	GUB::Float64 = 1e10
	Relative_Gap::Float64 = 2.0
	if length(Partial_Solutions) > 0
		for i in 1:length(Partial_Solutions)
			Opt_Solution, GUB = Update_Global_Upper_Bound(Opt_Solution, Partial_Solutions[i], GUB)
		end
		insert_element_in_queue!(Priority_Queue, Partial_Solutions[1], Partial_Solutions[2], false, false, -1e10)
		popfirst!(Partial_Solutions)
		popfirst!(Partial_Solutions)
		Opt_Solution, stats, GLB = OOES(instance, instance2, Partial_Solutions, Priority_Queue, number_of_cont_variables, number_of_int_or_bin_variables, Feasible_Solution, Opt_Solution, GUB, initial_time, timelimit, threads, parallelization, stats)
	else
		println("Infeasible")
	end
	if threads == 1 || (threads > 1 && parallelization == 4)
		return Opt_Solution, stats, GLB
	else
		final_results = Opt_Solutions()
		final_results.tmp_solution = Opt_Solution
		final_results.stats = stats
		final_results.GLB = GLB
		return final_results
	end
end

############################
# PARALLELIZATION APPROACH #
############################
@inbounds function OOES_parallel(instance::MOOInstance, instance2::MOOInstance, Partial_Solutions::Vector{OOESolution}, Priority_Queue::Vector{EOPriorQueue}, number_of_cont_variables::Int64, number_of_int_or_bin_variables::Int64, Feasible_Solution::OOESolution, Opt_Solution::OOESolution, threads::Int64, parallelization::Int64, timelimit::Float64, stats)
	num_threads::Vector{Int64} = setdiff(procs(), myid())[1:threads]
	initial_solutions::Vector{Vector{OOESolution}} = fill(OOESolution[], length(num_threads))
	vector_of_solutions::Vector{Opt_Solutions} = fill(Opt_Solutions(), length(num_threads))
	initial_solutions, stats = parallel_division_of_objective_space(initial_solutions, instance, Partial_Solutions, threads, parallelization, stats)
	@sync begin
		for i in 1:length(num_threads)
			@async begin
				vector_of_solutions[i] = remotecall_fetch(OOES, num_threads[i], copy(instance), copy(instance2), initial_solutions[i], Priority_Queue, number_of_cont_variables, number_of_int_or_bin_variables, Feasible_Solution, Opt_Solution, timelimit, threads, parallelization, stats)
			end
		end
	end
	Opt_Solution, stats, GLB = vector_of_solutions[1].tmp_solution, vector_of_solutions[1].stats, vector_of_solutions[1].GLB
	for i in 2:length(num_threads)
		if vector_of_solutions[i].tmp_solution.obj_vals[1] < Opt_Solution.obj_vals[1]
			Opt_Solution = vector_of_solutions[i].tmp_solution
		end
		if vector_of_solutions[i].GLB < GLB
			GLB = vector_of_solutions[i].GLB
		end
		stats = parallel_statistics(stats, vector_of_solutions[i].stats)
	end
	Opt_Solution, stats, GLB
end

########################
# MODEL INITIALIZATION #
########################
@inbounds function OOES_warm_up(instance::MOOInstance, mip_solver::MathProgBase.SolverInterface.AbstractMathProgSolver)
	Partial_Solutions::Vector{OOESolution} = OOESolution[]
	Priority_Queue::Vector{EOPriorQueue} = EOPriorQueue[]
	Opt_Solution = OOESolution()
	Feasible_Solution = OOESolution()
	number_of_cont_variables, number_of_int_or_bin_variables = counting(instance)
	if number_of_cont_variables > 0 && number_of_int_or_bin_variables > 0 
		instance2 = deepcopy(instance)
		Duplicate_Instance!(instance2, instance, number_of_cont_variables)
	else
		instance2 = deepcopy(instance)
	end
	stats = initialize_statistics(mip_solver)	
	Partial_Solutions = lex_min(instance, stats)
	stats[:Number_MIPs] += 6
	instance2, Partial_Solutions, Priority_Queue, number_of_cont_variables, number_of_int_or_bin_variables, Feasible_Solution, Opt_Solution, stats
end

###################################
# READING INSTANCE FROM JuMP FILE #
###################################
@inbounds function OOES(model::JuMP.Model; mipsolver::Int64=1, mip_solver::MathProgBase.SolverInterface.AbstractMathProgSolver=GLPKSolverMIP(), threads::Int64=1, parallelization::Int64=1, timelimit::Float64=86400.0, relative_gap::Float64=1.0e-6, sense::Array{Symbol,1} = [:Min, :Min, :Min])
	GLB::Float64 = -1e10
	Opt_Solution = OOESolution()
	if mipsolver == 2
		mip_solver=GurobiSolver(OutputFlag=0, Threads=1, MIPGap=relative_gap)
	elseif mipsolver == 3
		mip_solver=CplexSolver(CPX_PARAM_SCRIND=0, CPX_PARAM_THREADS=1, CPX_PARAM_EPGAP=relative_gap)
	elseif mipsolver == 4
		mip_solver=SCIPSolver("display/verblevel", 0, "limits/gap", relative_gap)
	elseif mipsolver == 5
		mip_solver=Xpress.XpressSolver(XPRS_THREADS=1, XPRS_STOP_MIPGAP=relative_gap, XPRS_OUTPUTLOG=0)
	end
	if threads > 1 && threads > length(procs())-1
		println("")
		println("Please, make sure to setup the number of threads correctly")
	else
		instance, sense = read_an_instance_from_a_jump_model(model, sense)
		Start_Time = time()
		instance2, Partial_Solutions, Priority_Queue, number_of_cont_variables, number_of_int_or_bin_variables, Feasible_Solution, Opt_Solution, stats = OOES_warm_up(instance, mip_solver)
		if threads == 1 || (threads > 1 && parallelization == 4)
			Opt_Solution, stats, GLB = OOES(instance, instance2, Partial_Solutions, Priority_Queue, number_of_cont_variables, number_of_int_or_bin_variables, Feasible_Solution, Opt_Solution, timelimit, threads, parallelization, stats)
		else
			Opt_Solution, stats, GLB = OOES_parallel(instance, instance2, Partial_Solutions, Priority_Queue, number_of_cont_variables, number_of_int_or_bin_variables, Feasible_Solution, Opt_Solution, threads, parallelization, timelimit, stats)
		end
		Total_Time = time() - Start_Time
		Writing_The_Output_File(Opt_Solution, Total_Time, threads, stats, GLB)
	end
	Opt_Solution
end

########################################
# READING INSTANCE FROM LP OR MPS FILE #
########################################
@inbounds function OOES(filename::String; mipsolver::Int64=1, mip_solver::MathProgBase.SolverInterface.AbstractMathProgSolver=GLPKSolverMIP(), threads::Int64=1, parallelization::Int64=1, timelimit::Float64=86400.0, relative_gap::Float64=1.0e-6, sense::Array{Symbol,1} = [:Min, :Min, :Min])
	sense = [:Min, :Min, :Min]
	GLB::Float64 = -1e10
	Opt_Solution = OOESolution()
	if mipsolver == 2
		mip_solver=GurobiSolver(OutputFlag=0, Threads=1, MIPGap=relative_gap)
	elseif mipsolver == 3
		mip_solver=CplexSolver(CPX_PARAM_SCRIND=0, CPX_PARAM_THREADS=1, CPX_PARAM_EPGAP=relative_gap)
	elseif mipsolver == 4
		mip_solver=SCIPSolver("display/verblevel", 0, "limits/gap", relative_gap)
	elseif mipsolver == 5
		mip_solver=Xpress.XpressSolver(XPRS_THREADS=1, XPRS_STOP_MIPGAP=relative_gap, XPRS_OUTPUTLOG=0)
	end
	if threads > 1 && threads > length(procs())-1
		println("")
		println("Please, make sure to setup the number of threads correctly")
	else
		instance, sense = read_an_instance_from_a_lp_or_a_mps_file(filename, sense)
		Start_Time = time()
		instance2, Partial_Solutions, Priority_Queue, number_of_cont_variables, number_of_int_or_bin_variables, Feasible_Solution, Opt_Solution, stats = OOES_warm_up(instance, mip_solver)
		if threads == 1 || (threads > 1 && parallelization == 4)
			Opt_Solution, stats, GLB = OOES(instance, instance2, Partial_Solutions, Priority_Queue, number_of_cont_variables, number_of_int_or_bin_variables, Feasible_Solution, Opt_Solution, timelimit, threads, parallelization, stats)
		else
			Opt_Solution, stats, GLB = OOES_parallel(instance, instance2, Partial_Solutions, Priority_Queue, number_of_cont_variables, number_of_int_or_bin_variables, Feasible_Solution, Opt_Solution, threads, parallelization, timelimit, stats)
		end
		Total_Time = time() - Start_Time
		Writing_The_Output_File(Opt_Solution, Total_Time, threads, stats, GLB)
	end
	Opt_Solution
end
