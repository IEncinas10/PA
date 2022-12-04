.global matrix_mul
.data
matrixA:
	.word 1, 2, 3, 4, 5, 6, 7, 8, 9

matrixB:
	.word 1, 0, 0, 0, 1, 0, 0, 0, 1 

matrixSol: 
	.word 0:9
	
rows:
	.word 3

columns:
	.word 3
.text

matrix_mul:

    	la a0, matrixA
    	la a1, matrixB
    	la a2, matrixSol
    	
        addi t0, zero, 3 # size
        add s11, zero, a1 # B

        add t1, zero, zero # i = 0 
loop1:  # loop1 #
        add t2, zero, zero # j = 0
        # loop2 #
loop2:   
        add t3, zero, zero # k = 0
        add t4, zero, zero # sum = 0
        # loop3 #
loop3:
        lw t5, 0(a0) # A[i][k]
        lw t6, 0(s11) # B[k][j]
        mul t5, t5, t6 # A*B
        add t4, t4, t5 # C += A*B
        ##andi t4, t4, 1023 # mod 1024
        addi a0, a0, 4 # A[i][k+1]
        addi s11, s11, 12 # B[k+1][j]
        addi t3, t3, 1 # k++ 
        blt t3, t0, loop3 # k<size , continue
        # loop3 end #
        sw t4, 0(a2) # store back to C[i][j]
        addi a2, a2, 4 # C[i][j+1]
        addi a0, a0, -12 # A go back
        addi a1, a1, 4 # B[k][j+1]
        add  s11, zero, a1 # B
        addi t2, t2, 1 # j++
        blt t2, t0, loop2 # j<size , continue
        # loop2 end #
        addi a0, a0, 12 # A[i+1][k]
        addi a1, a1, -12 # B go back (because line 40 add 2*128=256) AQUI SON 12 PORQUE 3 ELEMENTOS * 4 BYTES
        add s11, zero, a1 # B
        addi t1, t1, 1 # i++
        blt t1, t0, loop1 # i<size , continue
        # loop1 end #

end: 
	j end
