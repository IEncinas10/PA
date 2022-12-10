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
`define OPCODE_JUMP     7'b1101111
`define OPCODE_AUIPC    7'b0010111


//TODO meter todos funt3 y funct7 de funciones alu y aluimm
`define OR_FUNCT3       3'b110 
`define AND_FUNCT3      3'b111 
`define ADD_FUNCT3      3'b000
`define ADDI_FUNCT3     3'b000 //solo se necesita f3 para addi
 

//TODO revisar todos los f7 y f3 necesarios para las operaciones
`define SUB_FUNCT7      7'b0100000
`define MUL_FUNCT7      7'b0000001
`define ADD_OR_AND_FUNCT7   7'b0000000



`define CACHE_LINE_SIZE 128
`define CACHE_N_LINES   4

`define I_CACHE_LINE_SIZE `CACHE_LINE_SIZE
`define I_CACHE_N_LINES   `CACHE_N_LINES

`define D_CACHE_LINE_SIZE `CACHE_LINE_SIZE
`define D_CACHE_N_LINES   `CACHE_N_LINES

`define CACHE_DELAY_CYCLES 5

`define REPLACEMENT_POLICY_LRU 3'000

/*
 * MEMORY DEFINES
 *
 * [0x0000, 0xFFFF]
 *
 */
`define MEM_DELAY_CYCLES 5
`define MEM_SIZE (1 << 18)


/*
 * Internal defines
 *
 * They're used to know when to write into the ROB. 
 *   - ALU writes after Ex stage            (F D E WB) 
 *   - MEM writes after MEM stage           (F D E M WB)
 *   - MUL write at the end of the pipeline (F D E M2 M3 M4 M5 WB)
 *   - The rest don't write into ROB (invalid or jumps)
 */
`define INSTR_TYPE_SZ 3

`define INSTR_TYPE_ALU     3'b000
`define INSTR_TYPE_MUL     3'b001
`define INSTR_TYPE_NO_WB   3'b010
`define INSTR_TYPE_STORE   3'b011
`define INSTR_TYPE_LOAD    3'b100


`define PAGE_WIDTH 20
`define TLB_ENTRIES 512

// Think about maximum latency: 
// load (cache miss)
// addi x(N)
// how many entries do we need to not stall?
`define ROB_NUM_ENTRIES 14
`define ROB_ENTRY_WIDTH $clog2(`ROB_NUM_ENTRIES)

// Invalid rob id (for bubbles or jumps) we have to
// assign them some value that nobody is going to 
// consume so that our bypass logic works
`define ROB_INVALID_ENTRY 15



`endif
