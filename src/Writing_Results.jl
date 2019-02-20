@inbounds function Writing_The_Output_File(Opt_Solution::OOESolution, Total_Time::Float64, threads::Int64, stats, GLB::Float64)
	iteration = stats[:iteration]
	Number_MIPs = stats[:Number_MIPs]
	Time_Finder_Point = stats[:Time_Finder_Point]/threads
	IP_Finder_Point = stats[:IP_Finder_Point]
	N_Finder_Point = stats[:N_Finder_Point]
	Time_Weighted_Sum = stats[:Time_Weighted_Sum]/threads
	IP_Weighted_Sum = stats[:IP_Weighted_Sum]
	N_Weighted_Sum = stats[:N_Weighted_Sum]
	Time_Line_Detector = stats[:Time_Line_Detector]/threads
	IP_Line_Detector = stats[:IP_Line_Detector]
	N_Line_Detector = stats[:N_Line_Detector]
	Time_Finder_Line = stats[:Time_Finder_Line]/threads
	IP_Finder_Line = stats[:IP_Finder_Line]
	N_Finder_Line = stats[:N_Finder_Line]
	Time_Finder_Triangle = stats[:Time_Finder_Triangle]/threads
	IP_Finder_Triangle = stats[:IP_Finder_Triangle]
	N_Finder_Triangle = stats[:N_Finder_Triangle]
	Time_UB_Finder_Triangle = stats[:Time_UB_Finder_Triangle]/threads
	IP_UB_Finder_Triangle = stats[:IP_UB_Finder_Triangle]
	N_UB_Finder_Triangle = stats[:N_UB_Finder_Triangle]
	
	Output_File = open("Output.txt","w")
	write(Output_File, "Running_Time: $Total_Time  #IPs: $Number_MIPs  #Iterations: $iteration \n")
	write(Output_File, "Time_Finder_Point: $Time_Finder_Point   #IPs_Finder_Point: $IP_Finder_Point  Number_Finder_Point: $N_Finder_Point \n")
	write(Output_File, "Time_Weighted_Sum: $Time_Weighted_Sum   #IPs_Weighted_Sum: $IP_Weighted_Sum   Number_Weighted_Sum: $N_Weighted_Sum \n")
	write(Output_File, "Time_Line_Detector: $Time_Line_Detector   #IPs_Line_Detector: $IP_Line_Detector  Number_Line_Detector: $N_Line_Detector \n")
	write(Output_File, "Time_Finder_Line: $Time_Finder_Line   #IPs_Finder_Line: $IP_Finder_Line  Number_Finder_Line: $N_Finder_Line \n")
	write(Output_File, "Time_Finder_Triangle: $Time_Finder_Triangle   #IPs_Finder_Triangle: $IP_Finder_Triangle  Number_Finder_Triangle: $N_Finder_Triangle \n")
	write(Output_File, "Time_UB_Finder_Triangle: $Time_UB_Finder_Triangle   #IPs_UB_Finder_Triangle: $IP_UB_Finder_Triangle  Number_UB_Finder_Triangle: $N_UB_Finder_Triangle \n")
	fx = Opt_Solution.obj_vals[1]
	Z1 = Opt_Solution.obj_vals[2]
	Z2 = Opt_Solution.obj_vals[3]
	write(Output_File, "GLB=  $GLB   GUB= $fx  f(x)= $fx \n")
	write(Output_File, "Z1=   $Z1    Z2=   $Z2  \n")
	close(Output_File)

	Output_File = open("Solution.txt","w")
	j = 0

	for i in 1:length(Opt_Solution.vars)
		x = Opt_Solution.vars[i]
		write(Output_File, "x($i)= $x	")
		j+=1
		if j == 5
			j = 0
			write(Output_File, "\n")
		end
	end
	close(Output_File)

end
