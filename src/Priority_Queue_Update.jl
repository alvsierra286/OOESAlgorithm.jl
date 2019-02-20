#######################################
# UPDATING ELEMENTS IN PRIORITY QUEUE #
#######################################
@inbounds function insert_element_in_queue!(Priority_Queue::Vector{EOPriorQueue}, Sol_Top::OOESolution, Sol_Bottom::OOESolution, Shape::Bool, Direction::Bool, LBound::Float64)
	tmp = EOPriorQueue()
	tmp.Sol_Top = Sol_Top
	tmp.Sol_Bottom = Sol_Bottom
	tmp.Shape = Shape
    	tmp.Direction = Direction
    	tmp.LBound = LBound
	if length(Priority_Queue) > 0
		x = 1
		sw = false
		while LBound > Priority_Queue[x].LBound
			if x == length(Priority_Queue)
				push!(Priority_Queue, tmp)
				sw = true
				break
			end
			x += 1
		end
		if sw == false
			insert!(Priority_Queue, x, tmp)
		end
	else
		push!(Priority_Queue, tmp)
	end
end

@inbounds function Update_Queue_Top!(Priority_Queue::Vector{EOPriorQueue}, Condition1::Bool, Condition2::Bool, Feasible_Solution::OOESolution)
	x = 1
	sw = false
	if Condition1 == true && Condition2 == true
		while x <= length(Priority_Queue) && sw == false
			if Point_Difference4(Feasible_Solution, Priority_Queue[x].Sol_Top, Epsilon = 1e-5)
				x += 1
			else
				Priority_Queue[x].Sol_Top = Feasible_Solution
				sw = true
			end
		end
	end
end


@inbounds function Update_Queue_Bottom!(Priority_Queue::Vector{EOPriorQueue}, Condition1::Bool, Condition2::Bool, Feasible_Solution::OOESolution)
	x = 1
	sw = false
	if Condition1 == true && Condition2 == true
		while x <= length(Priority_Queue) && sw == false
			if Point_Difference4(Feasible_Solution, Priority_Queue[x].Sol_Bottom, Epsilon = 1e-5)
				x += 1
			else
				Priority_Queue[x].Sol_Bottom = Feasible_Solution
				sw = true
			end
		end
	end
end

@inbounds function Update_Global_Upper_Bound(Opt_Solution::OOESolution, Feasible_Solution::OOESolution, GUB::Float64)
	if (Feasible_Solution.obj_vals[1] < GUB)
		Opt_Solution = Feasible_Solution
		GUB = Opt_Solution.obj_vals[1]
	end
	Opt_Solution, GUB
end

@inbounds function first_element_of_the_queue(Priority_Queue::Vector{EOPriorQueue})
	element = Priority_Queue[1]
	element1 = element.Sol_Top
	element2 = element.Sol_Bottom
	popfirst!(Priority_Queue)
	element, element1, element2, Priority_Queue
end
