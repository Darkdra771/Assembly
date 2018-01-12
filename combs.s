.global get_combs
.equ ws, 4

.text
	combinations:
		prologue_combination:
			push %ebp
			movl %esp, %ebp
			#make space for local
			subl $1*ws, %esp
			#save reg
			push %ebx

/*
		stack after prologue:
			itemLen
			index
			oriK
			K
			comb
			numCombs
			len
			items
			C
			ret address
		ebp:    old ebp
		esp:	j
*/

		.equ Cr, (2 * ws)
		.equ itemsr, (3 * ws)
		.equ lenr, (4 * ws)
		.equ numCombsr, (5 * ws)
		.equ combr, (6 * ws)
		.equ kr, (7 * ws)
		.equ oriK, (8 * ws)
		.equ indexr, (9 * ws)
		.equ itemLen, (10 * ws)
		.equ j, (-1 * ws)

		#EAX is j

		start_if:
			movl indexr(%ebp), %eax			 #for checking index
			movl (%eax), %eax
			
			cmpl $0, kr(%ebp)
			jnz end_if
			movl $0, %eax

			
			start_for:
				movl %eax, j(%ebp)
				cmpl oriK(%ebp), %eax
				jge end_for

				movl combr(%ebp), %ecx           #ecx is combr
				movl (%ecx, %eax, ws), %ecx      #ecx is comb[j]

				movl Cr(%ebp), %ebx              #ebx is c 
				movl indexr(%ebp), %edx          #edx is index
				movl (%edx), %edx                #edx is *index
				movl (%ebx, %edx, ws), %ebx      #ebx is c[*index]
				movl %ecx, (%ebx, %eax, ws)      #c[*index][j] = comb[j]

				movl j(%ebp), %eax
				incl %eax
				jmp start_for
			end_for:				

			movl indexr(%ebp), %eax                   #eax is index
			addl $1, (%eax)                           #(*index)++
			jmp epilogue_combination
		end_if:


		start_while:
			movl indexr(%ebp), %eax                   #eax is index
			movl (%eax), %eax
			cmpl numCombsr(%ebp), %eax
			jge end_while

			movl itemLen(%ebp), %eax                  #eax is itemLen
			cmpl lenr(%ebp), %eax                     
			jge end_while

			movl itemsr(%ebp), %eax                   #eax is items
			movl itemLen(%ebp), %ebx                  #ebx is itemLen
			movl (%eax, %ebx, ws), %eax               #eax is items[itemLen]

			movl combr(%ebp), %ebx                    #ebx is comb
			movl oriK(%ebp), %ecx                     #ecx is oriK
			subl kr(%ebp), %ecx                       #ecx is oriK - k
			movl %eax, (%ebx, %ecx, ws)               #comb[oriK - k] = items[itemLen]
			
			movl itemLen(%ebp), %eax                  #eax is itemLen
			incl %eax
			movl %eax, itemLen(%ebp)                  #itemLen++
			
			push itemLen(%ebp)                        #itemLen
			push indexr(%ebp)                         #index
			push oriK(%ebp)                           #oriK
			movl kr(%ebp), %eax
			decl %eax
			push %eax                                 #k - 1
			push combr(%ebp)                          #comb
			push numCombsr(%ebp)                      #numComb
			push lenr(%ebp)                           #len
			push itemsr(%ebp)                         #items
			push Cr(%ebp)                             #c

			call combinations 

			addl $9*ws, %esp                          #erase arguments	
			jmp start_while
		end_while:


		epilogue_combination:
			pop %ebx
			movl %ebp, %esp
			pop %ebp
			ret
	

	get_combs:
		prologue:
			push %ebp
			movl %esp, %ebp
			subl $5*ws, %esp
			#save registers

/*
		stack after prologue:
			len
			k
			items
			ret address
		ebp:	old ebp
			numCombs
			index
			i
			C
		esp:	comb
			
*/

		.equ items, (2 * ws)
		.equ k, (3 * ws)
		.equ len, (4 * ws)
		.equ numCombs, (-1 * ws)
		.equ index, (-2 * ws)
		.equ i, (-3 * ws)
		.equ C, (-4 * ws)
		.equ comb, (-5 * ws)

		#numCombs = num_combs(len, k)
		movl k(%ebp), %eax
		movl len(%ebp), %ecx
		push %eax
		push %ecx
		call num_combs
		movl %eax, numCombs(%ebp)
		addl $2 * ws, %esp 

		#*index = 0
		movl $1, %eax
		shll $2, %eax
		push %eax
		call malloc
		addl $1*ws, %esp
		movl %eax, index(%ebp)
		movl index(%ebp), %eax
		movl $0, (%eax)
		movl index(%ebp), %eax
		movl (%eax), %eax

		#comb = (int*)malloc(k * sizeof(int))
		movl k(%ebp), %eax
		shll $2, %eax
		push %eax
		call malloc
		addl $1 * ws, %esp
		movl %eax, comb(%ebp)

		#c = (int**)malloc(numCombs * sizeof(int*))
		movl numCombs(%ebp), %eax
		shll $2, %eax
		push %eax
		call malloc
		addl $1 * ws, %esp
		movl %eax, C(%ebp)
		
		movl $0, %eax
		start_loop:
			cmpl numCombs(%ebp), %eax
			jge end_loop
			movl k(%ebp), %edx
			shll $2, %edx
			push %edx
			movl %eax, i(%ebp)
			call malloc
			addl $1*ws, %esp
			movl %eax, %edx
			movl i(%ebp), %eax
			movl C(%ebp), %ecx
			movl %edx, (%ecx, %eax, ws)
			incl %eax
			jmp start_loop
		end_loop:


		push $0                 #0
		movl index(%ebp), %eax
		push %eax             #index
		movl k(%ebp), %eax
		push %eax               #k
		push %eax               #k
		movl comb(%ebp), %eax
		push %eax               #comb
		push numCombs(%ebp)     #numCombs
		push len(%ebp)          #len		
		movl items(%ebp), %eax
		push %eax               #items
		movl C(%ebp), %eax
		push %eax               #C

		call combinations

		addl $9*ws, %esp
		
		movl C(%ebp), %eax

		epilogue:
			movl %ebp, %esp
			pop %ebp
			ret


		
