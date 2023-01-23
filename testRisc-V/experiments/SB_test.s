.data
position:
	.word -1
.text
.global main

main:
	la a0, position
	addi a5, a5, 0xff
	nop
	#sw-lw
	sw a5, 0(a0)
	lw a4, 0(a0)
	nop
	nop
	#sw-lb
	addi a5, a5, 2
	sw a5, 128(a0)
	lb a4, 128(a0)
	lb a3, 129(a0)
	addi a4, a4, 1
	#sb-lb
	sb a4, 256(a0)
	lb a4, 256(a0)
	#sb-lw
	addi a4, a4, 1
	nop
	sb a4, 512(a0)
	lw a5, 512(a0)
end: 
	j end
