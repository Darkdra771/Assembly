.global knapsack
.equ ws, 4

.text

	max:
		#EAX will be a
		#EDX will be b
		#return value will be in EAX

		max_if:
			cmpl %eax, %edx
			jge max_else
			ret

		max_else:
			movl %edx, %eax
			ret



	knapsack:
		prologue:
			push %ebp
			movl %esp, %ebp
			subl $2*ws, %esp
			#save register
			push %ebx

/*
		stack after prologue:
			cur_value
			capacity
			num_items
			values
			weigths
			ret address
		ebp:	old ebp
			i
			best_value
*/

		.equ weights, (2 * ws)
		.equ values, (3 * ws)
		.equ num_items, (4 *ws)
		.equ capacity, (5 *ws)
		.equ cur_value, (6 * ws)
		.equ i, (-1 * ws)
		.equ best_value, (-2 * ws)

		#best_value = cur_value
		movl cur_value(%ebp), %eax
		movl %eax, best_value(%ebp)

		#intiliaze eax as is
		movl weights(%ebp), %ebx
		movl $0, %eax
		movl (%ebx, %eax, ws), %ebx    #print weights[0]
		
		start_for:
			movl %eax, i(%ebp) #store i into stack
			cmpl num_items(%ebp), %eax
			jge end_for
			
			start_if:
				movl i(%ebp), %ebx             #ebx is i

				movl weights(%ebp), %ecx       #ecx is weights
				movl (%ecx, %ebx, ws), %ecx    #exc is weights[i]
				cmpl %ecx, capacity(%ebp)      #capacity - weights[i]
				jl end_if
				
				movl values(%ebp), %eax        #eax is values
				movl (%eax, %ebx, ws), %eax    #eax is values[i]
				addl cur_value(%ebp), %eax     #eax is cur_value + values[i]	
				push %eax

				movl capacity(%ebp), %eax      #eax is capacity
				subl %ecx, %eax                #capacity - weights[i]
				push %eax
					
				movl num_items(%ebp), %eax     #eax is num_items
				subl i(%ebp), %eax             #num_items - i
				subl $1, %eax                  #num_items - i - 1
				push %eax

				movl values(%ebp), %eax        #eax is values address
				movl %ebx, %edx                
				imull $4, %edx				
				addl %edx, %eax
				addl $1*ws, %eax   	       #eax is values + i + 1
				movl (%eax), %edx
				push %eax

				movl weights(%ebp), %eax       #eax is weights
				movl %ebx, %edx
				imull $4, %edx				
				addl %edx, %eax
				addl $1*ws, %eax                 #eax is weights + i + 1			
				push %eax

				call knapsack

				addl $5*ws, %esp               #clear the 5 arguments
				
				movl best_value(%ebp), %edx    #edx is best_value
				
				call max
			
				movl %eax, best_value(%ebp)
			end_if:


			movl i(%ebp), %eax #restore eax
			incl %eax
			jmp start_for
		end_for:

			movl best_value(%ebp), %eax

		epilogue:
			pop %ebx
			movl %ebp, %esp	
			pop %ebp
			ret

		







