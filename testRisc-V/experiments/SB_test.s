.data
position:
	.word -1
.text
.global main

main:
#Line 0
	la a0, position
	addi a5, a5, 0xff
	nop
#Line 1
	#sw-lw
	sw a5, 0(a0)
	lw a4, 0(a0)
	nop
	nop
#Line 2
	#sw-lb
	addi a5, a5, 2
	sw a5, 128(a0)
	lb a4, 128(a0)
	lb a3, 129(a0)
#Line 3
	addi a4, a4, 1
	#sb-lb
	sb a4, 256(a0)
	lb a4, 256(a0)
	#sb-lw
	addi a4, a4, 1
#Line 4
	nop
	sb a4, 512(a0)
	lw a5, 512(a0)
end: 
	j end
