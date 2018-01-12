.global matMult
.equ ws, 4

.text

matMult:
	prologue:
		push %ebp
		movl %esp, %ebp
		subl $5*ws, %esp #make space for locals
		#save register
		push %ebx
		push %esi


		#stack after prologue:
		#	num_cols_b
		#	num_rows_b
		#	B
		#	num_cols_a
		#	num_rows_a
		#	A
		#	ret address
		#ebp:	old ebp
		#	C
		#	sum
		#	i
		#	j
		#esp:	k


		.equ A, (2 * ws)
		.equ rowA, (3 * ws)
		.equ colA, (4 * ws)
		.equ B, (5 * ws)
		.equ rowB, (6 * ws)
		.equ colB, (7 * ws)
		.equ C, (-1 * ws)
		.equ sum, (-2 * ws)
		.equ i, (-3 * ws)
		.equ j, (-4 * ws)
		.equ k, (-5 * ws)

		movl $0, sum(%ebp)

		movl rowA(%ebp), %eax #eax = num_rows_a
		shll $2, %eax #eax = num_rows_a * sizeof(int*)
		push %eax
		call malloc
		addl $1 * ws, %esp
		movl %eax, C(%ebp)

		#eax will be i 
		#ecx wil be j and temp sometimes
		#eax will be i
		#ecx will be j
		#esi will be k

		movl $0, sum(%ebp)
		movl $0, %eax
		start_loop:
			movl %eax , i(%ebp)
			cmpl rowA(%ebp), %eax
			jge end_outer_loop
			movl colB(%ebp), %edx
			shll $2, %edx
			push %edx
			movl %eax, i(%ebp)
			call malloc
			addl $1 * ws, %esp
			movl %eax, %edx
			movl i(%ebp), %eax
			movl C(%ebp), %ecx
			movl %edx, (%ecx, %eax, ws) #C[i] = edx
		
			movl $0, %ecx
			
			inner_loop:
				movl %ecx, j(%ebp)
				cmpl colB(%ebp), %ecx
				jge end_inner_loop
				movl $0, %esi

				mult_loop:
					movl %esi, k(%ebp)
					cmpl colA(%ebp), %esi
					jge end_mult_loop					
					
					movl A(%ebp), %ebx
					movl (%ebx, %eax, ws), %ebx
					movl (%ebx, %esi, ws), %ebx
					movl %ebx, %eax # move to eax to use for mull
			
					movl B(%ebp), %ebx
					movl (%ebx, %esi, ws), %ebx
					movl (%ebx, %ecx, ws), %ebx
					imull %eax, %ebx # eax = eax * esi
					addl %ebx, sum(%ebp) # sum += a[i][j] * b[k][j]

					movl i(%ebp), %eax #restore eax
					movl k(%ebp), %esi
					incl %esi
					jmp mult_loop
				end_mult_loop:		
	
				movl j(%ebp), %ecx
				movl sum(%ebp), %eax				

				movl %eax, (%edx, %ecx, ws) #c[i][j] = sum
				
				movl i(%ebp), %eax
				movl $0, sum(%ebp) # sum = 0

				incl %ecx
				jmp inner_loop
			end_inner_loop:
			
			movl i(%ebp), %eax
			incl %eax
			jmp start_loop
		end_outer_loop:	
		
		
		movl C(%ebp), %eax

		epilogue:
			pop %esi
			pop %ebx
			movl %ebp, %esp
			pop %ebp
			ret
		

			
