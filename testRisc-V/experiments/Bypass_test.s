.data
position:
	.word -1
.text
.global main

main:
#Line 0
	addi x1, x1, 1
	addi x2, x1, 1##alu
	addi x3, x1, 1##alu-wb
	addi x4, x1, 1##rob
#Line 1
	la x2, position #2inst
	nop
	nop
#Line 2
	lw x2, 0(x2)
	addi x3, x2, 1 #mem
	addi x4, x2, 1 #mem-wb
	nop
#Line 3
	mul x1, x1, x1
	addi x2, x1, 1 #mul
	addi x3, x1, 1 #mul-wb
#Line 4
end: 
	j end
