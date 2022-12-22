`include "../defines.sv"

module rob #(
    parameter N                = `ROB_NUM_ENTRIES,
    parameter WORD_SIZE        = `WORD_SIZE,
    parameter ROB_ENTRY_WIDTH  = `ROB_ENTRY_WIDTH,
    parameter REG_INDEX_SIZE   = `ARCH_REG_INDEXSIZE,
    parameter INIT             = 0
) (
    input wire                        clk,
    input wire                        rst,
    /* Connections from decode */
    input wire 			     require_rob_entry,
    input wire			     is_store,
    input wire [REG_INDEX_SIZE-1:0]  rd,
    output reg [ROB_ENTRY_WIDTH-1:0] assigned_rob_id,
    output reg                       full,

    /* Exceptions from decode: ITLB */
    input wire d_exception,
    input wire d_pc,
    // d_exception's rob entry comes from TAIL if we're not full (of course?)

    /* ALU write port */
    input wire [WORD_SIZE-1:0] alu_result,
    input wire 		       alu_rob_wenable,
    input wire 		       alu_rob_id,
    /* MEM write port */
    input wire [WORD_SIZE-1:0] mem_result,
    input wire 		       mem_rob_wenable,
    input wire 		       mem_rob_id,

    /* EXCEPTION INFO. MEM ONLY */
    input wire		       mem_exception,
    input wire [WORD_SIZE-1:0] mem_v_addr,
    input wire [WORD_SIZE-1:0] mem_pc,

    /* MUL write port */
    input wire [WORD_SIZE-1:0] mul_result,
    input wire 		       mul_rob_wenable,
    input wire 		       mul_rob_id,

    /* Bypasses */
    input reg [ROB_ENTRY_WIDTH-1:0] rs1_rob_entry,
    input reg [ROB_ENTRY_WIDTH-1:0] rs2_rob_entry,
    output reg [WORD_SIZE-1:0]      bypass_s1,
    output reg [WORD_SIZE-1:0]      bypass_s2,
    output reg                      bypass_s1_valid,
    output reg                      bypass_s2_valid,

    /* RF and RF-ROB. Don't write into RF if exception present */
    output reg                       commit,
    output reg [REG_INDEX_SIZE-1:0]  commit_rd,
    output reg [WORD_SIZE-1:0]       commit_value,
    output reg [ROB_ENTRY_WIDTH-1:0] commit_rob_entry,

    /* Store Buffer */
    output reg			     sb_store_permission,
    output reg [ROB_ENTRY_WIDTH-1:0] sb_rob_id,

    /* Exception output */
    output reg exception,
    output reg ex_pc,
);

    reg [N] [REG_INDEX_SIZE-1:0] rds;
    reg [N] [WORD_SIZE-1:0]      values;
    reg [N]			 readys;
    reg [N]		 	 are_store;

    reg [$clog2(N)-1:0] head;
    reg [$clog2(N)-1:0] tail;
    reg [$clog2(N):0]   entries;


    /* 
     * We only care about the oldest exception. 
     * We assume only MEM instr can cause exceptions
     *
     * We have to keep track of both exceptions separately because this
     * could happen:
     * 
     * load word
     * Page boundary
     * Instr2
     *
     * load word causes mem instr
     * Instr2 causes ITLB exception
     *
     * Instr2 writes in decode stage to ROB saying it has caused an exception
     * load word goes to write his exception to ROB but finds Instr2's excep
     * and doesn't write.
     *
     * Then, we're incorrectly processing Instr2's exception.
     *
     * Keeping track of both types of exceptions separately lets us
     * avoid reordering.
     */
    reg			mem_ex_present;
    reg [WORD_SIZE-1:0] mem_ex_v_addr;
    reg [WORD_SIZE-1:0] mem_ex_pc;
    reg			mem_ex_rob_id;

    /*
     * ITLB exceptions => we write them into ROB
     * from decode and we KILL that instruction.
     * 
     * The exception will be processed when the faulting
     * instructions becomes head of the ROB
     *
     * Of course, we have to ensure that if an ITLB exception
     * is present, the instruction asks for a ROB entry
     */

    reg			itlb_ex_present;
    reg [WORD_SIZE-1:0] itlb_ex_pc;
    reg			itlb_ex_rob_id;

    // reg ¿?¿? exception_code

    initial begin
	reset();
    end

    always @(*) begin
	full = (entries == N);

	/* Decode */
	assigned_rob_id = tail;

	if(itlb_ex_present && head == itlb_ex_rob_id && readys[head]) begin
	    exception = 1;
	    ex_pc     = itlb_ex_pc;
	end else if (mem_ex_present && head == mem_ex_rob_id && readys[head]) begin
	    exception = 1;
	    ex_pc     = mem_ex_rob_id;
	end

	/* Store buffer */
	sb_store_permission = !exception && readys[head] && are_store[head];
	sb_rob_id = head;

	/* RF - ROB */
	commit		 = !exception && readys[head];
	commit_rd	 = rds[head];
	commit_value	 = values[head];
	commit_rob_entry = head;

	/* Bypass */
	bypass_s1_valid = readys[rs1_rob_entry];
	bypass_s2_valid = readys[rs2_rob_entry];
	bypass_s1	= values[rs1_rob_entry];
	bypass_s2 	= values[rs2_rob_entry];
    end

    always @(posedge(clk)) begin
	if(rst) begin
	    reset();
	end else begin

	    // Free head
	    if(readys[head] && entries > 0) begin 
		// Freed entry's state. 
		readys[head] = 0;

		// ROB state
		head = (head + 1) % N;
		entries = entries - 1;
	    end

	    // Give tail
	    if(require_rob_entry && !full) begin 
		// New entry's state
		rds[tail]       = rd;
		values[tail]    = 0;
		readys[tail]    = 0;
		are_store[tail] = is_store;

		/* Exceptions from decode: ITLB */
		if(d_exception) begin
		    itlb_ex_present = 1;
		    itlb_ex_v_addr  = d_pc;
		    itlb_ex_rob_id  = tail;
		end

		// ROB state
		tail    = (tail + 1) % N;
		entries = entries + 1;
	    end

	    // Write port ALU
	    if(alu_rob_wenable) begin
		readys[alu_rob_id] = 1;
		values[alu_rob_id] = alu_result;
	    end
	    // Write port MEM
	    if(mem_rob_wenable) begin
		readys[mem_rob_id] = 1;
		values[mem_rob_id] = mem_result;

		// MEM exceptions
		mem_ex_v_pc     = mem_pc;
		mem_ex_v_addr   = mem_v_addr;
		mem_ex_present  = mem_exception;
		mem_ex_v_rob_id = mem_rob_id;
	    end
	    
	    // Write port MUL
	    if(mul_rob_wenable) begin
		readys[mul_rob_id] = 1;
		values[mul_rob_id] = mul_result;
	    end
	end
    end

    task reset;
	head = 0;
	tail = 0;
	entries = 0;

	mem_ex_present  = 0;
	itlb_ex_present = 0;

	for(i = 0; i < N; i = i + 1) begin
	    rds[i]      <= 0;
	    values[i]   <= 0;
	    readys[i] 	<= 0;
	    are_store[i] <= 0;
	end
    endtask

endmodule
