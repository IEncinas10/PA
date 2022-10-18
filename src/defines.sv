`ifndef DEFINES
`define DEFINES

`timescale 1 ns / 1 ns

`define	WORD_SIZE 32

/*
 * Number of total architectural registers.
 * Size of minimum index needed to address them.
 */

`define NUM_ARCH_REGS 32
`define ARCH_REG_INDEX_SIZE $clog2(`NUM_ARCH_REGS)

`define OPCODE_ALU      7'b0110011
`define OPCODE_ALU_IMM  7'b0010011
`define OPCODE_BRANCH   7'b1100011
`define OPCODE_STORE    7'b0100011
`define OPCODE_LOAD     7'b0000011
//`define OPCODE_MUL      7'b0110011 //mismo opcode que alu, mirar funct 7
`define OPCODE_JUMP     7'b1101111


//TODO meter todos funt3 y funct7 de funciones alu y aluimm
`define OR_FUNCT3       3'b110 
`define AND_FUNCT3      3'b111 
`define ADD_FUNCT3      3'b000
`define ADDI_FUNCT3     3'b000 //solo se necesita f3 para addi
 

//TODO revisar todos los f7 y f3 necesarios para las operaciones
`define SUB_FUNCT7      7'b0100000
`define MUL_FUNCT7      7'b0000001
`define ADD_OR_AND_FUNCT7   7'b0000000




`endif
