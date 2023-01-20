.data
vectorA: 
    .word 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
vectorB: 
    .word 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
length: 
    .word 128
.text
.global vectorcopy
vectorcopy:
	
	la a0, vectorA # a0 = destination
	la a1, vectorB # a1 = source
	addi a2, zero, 128
	addi t0, zero, 0
	addi t1, zero, 0
	addi t3, zero, 4
	
for: 	# For loop
     	bge   t1, a2, endfor   # if i >= size, break
    	mul  t2, t1, t3    # Multiply i by 4 (1 << 2 = 4)
    	add t4, a1, t2     # Update memory addres to copy
    	add   t2, a0, t2   # Update memory address to read
    	lw    t0, 0(t2)    # Dereference address to get integer
    	lw    t5, 4(t2)    # Dereference address to get integer
    	lw    t6, 8(t2)    # Dereference address to get integer
    	lw    s1, 12(t2)    # Dereference address to get integer
	sw t0, 0(t4)	   # Copy value in mem
	sw t5, 4(t4)	   # Copy value in mem
	sw t6, 8(t4)	   # Copy value in mem
	sw s1, 12(t4)	   # Copy value in mem
    	addi  t1, t1, 4    # Increment the iterator
    	jal   zero, for     # Jump back to start of loop (1 backwards)
	nop
endfor:
	j endfor
