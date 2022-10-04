`ifndef DEFINES
`define DEFINES

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
`define OPCODE_MUL      7'b0110011
`define OPCODE_JUMP     7'b1101111



`define SUB_FUNCT7      7'b0100000
`define ADD_FUNCT7      7'b0000000

`define ADDI_FUNCT3      3'b000



`endif
