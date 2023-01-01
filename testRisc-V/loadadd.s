.data
variable:
    .word 8
.text
.global loadadd
loadadd:
	
	la a0, variable 
	lw t0, 0(a0)
	addi t1, zero, 1
	addi t1, t1, 1
	addi t1, t1, 1
	mul  t2, t1, t1
	addi t1, t1, 1
	addi t1, t1, 1
	addi t1, t1, 1
	addi t1, t1, 1
	addi t1, t1, 1
loop:
	j loop
