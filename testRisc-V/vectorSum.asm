# sum elements of a vector in a buffer_sum variable

.data
vector:
	.word 1:128
length: .word 128
.section arraysum
.text

arraysum:
	la a0, vector
	lw a1, length
	addi t0, zero, 0
	addi t1, zero, 0
	addi t3, zero, 4
for: 	# For loop
     	bge   t1, a1, endfor   # if i >= size, break
    	mul  t2, t1, t3    # Multiply i by 4 (1 << 2 = 4)
    	add   t2, a0, t2   # Update memory address
    	lw    t2, 0(t2)    # Dereference address to get integer
    	add   t0, t0, t2   # Add integer value to ret
    	addi  t1, t1, 1    # Increment the iterator
    	jal   zero, for     # Jump back to start of loop (1 backwards)
endfor:
    	addi  a0, t0, 0    # Move t0 (ret) into a0
    	la a1, length
	sw a0, 4(a1) ## store in memory the result next to length

end: 
	j end