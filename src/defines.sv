`timescale 1 ns / 1 ns

`ifndef DEFINES
`define DEFINES


`define	WORD_SIZE 32

`define PC_EXCEPTION 32'h00002000
`define PC_INITIAL   32'h00001000

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
 

/* Funct3 of branches */
`define BEQ_FUNCT3      3'b000
`define BNE_FUNCT3		3'b010
`define BLT_FUNCT3      3'b100
`define BGE_FUNCT3      3'b101

//TODO revisar todos los f7 y f3 necesarios para las operaciones
`define SUB_FUNCT7      7'b0100000
`define MUL_FUNCT7      7'b0000001
`define ADD_OR_AND_FUNCT7   7'b0000000




`define CACHE_LINE_SIZE 128
`define CACHE_N_LINES   4
`define CACHE_ASSOCIATIVITY (0)
`define CACHE_DELAY_CYCLES 5
`define OFFSET_SIZE $clog2(`CACHE_LINE_SIZE / 8)

/* WORD_SIZE - line index bits - byte offset bits. Associativity increases tag size */
`define TAG_SIZE (`WORD_SIZE - $clog2(`CACHE_N_LINES) - `OFFSET_SIZE + `CACHE_ASSOCIATIVITY)

`define REPLACEMENT_POLICY_LRU 3'000

`define I_CACHE_LINE_SIZE `CACHE_LINE_SIZE
`define I_CACHE_N_LINES   `CACHE_N_LINES
`define I_CACHE_ASSOCIATIVITY `CACHE_ASSOCIATIVITY

`define D_CACHE_LINE_SIZE `CACHE_LINE_SIZE
`define D_CACHE_N_LINES   `CACHE_N_LINES
`define D_CACHE_ASSOCIATIVITY `CACHE_ASSOCIATIVITY

/*
 * MEMORY DEFINES
 *
 * [0x0000, 0xFFFF]
 *
 */
// do a dummy diagram to see when the data is available
// lw: F D E Miss1 Miss2 Miss3 ... Fill, Hit¿?¿?
`define MEM_DELAY_CYCLES 5
`define MEM_SIZE (1 << 20)


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
`define TLB_DELAY 5 
`define TLB_DELAY_WIDTH $clog2(`TLB_DELAY)

// Think about maximum latency: 
// load (cache miss)
// addi x(N)
// how many entries do we need to not stall?
`define ROB_NUM_ENTRIES 14

// Invalid rob id (for bubbles or jumps) we have to
// assign them some value that nobody is going to 
// consume so that our bypass logic works
`define ROB_INVALID_ENTRY (`ROB_NUM_ENTRIES + 1) 

`define ROB_ENTRY_WIDTH $clog2(`ROB_INVALID_ENTRY)


`define STORE_BUFFER_ENTRIES	4

`define SIZE_WRITE_WIDTH 3

// unsigned..
`define BYTE_SIZE	3'b000
`define HALF_SIZE	3'b001
`define FULL_WORD_SIZE	3'b010

`define ADDRESS_WIDTH 32



`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

`endif


