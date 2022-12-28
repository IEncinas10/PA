`include "defines.sv"
`include "TLB.sv"
`include "cache.sv"


module fetch_stage #(
    parameter WORD_SIZE = `WORD_SIZE,
    parameter LINE_SIZE = `CACHE_LINE_SIZE
) (
    input wire clk,
    input wire rst,
    input wire jump_taken,
    input wire [WORD_SIZE-1:0] nextpc,
    input wire stall_in,
    input wire exception_in,
    output wire                 mem_req,        // memory read port
    output wire [WORD_SIZE-1:0] mem_req_addr,
    input wire		       mem_res,         // Memory response
    input wire [WORD_SIZE-1:0] mem_res_addr, 
    input wire [LINE_SIZE-1:0] mem_res_data,
    output wire [WORD_SIZE-1:0] pc_out,
    output wire [WORD_SIZE-1:0] instruction_out,
    output wire exception_out,
    output wire valid_out
);

    reg [WORD_SIZE-1:0] pc;
    reg exception = 0;

    assign valid_out = hit_tlb && !stall_in && !exception;

    assign pc_out = pc;

    /* Wires for iTLB */
    wire hit_tlb;

    wire valid = 1;

    wire [WORD_SIZE-1:0] phy_mem_addr;

    assign phy_mem_addr[WORD_SIZE-1-`PAGE_WIDTH:0] = pc[WORD_SIZE-1-`PAGE_WIDTH:0];

    /* Wires for iCache */
    wire cache_hit;
    wire cache_store = 0;  // We only load from iCache
    wire wenable                          = 0;
    wire [WORD_SIZE-1:0] sb_value         = 0;
    wire [WORD_SIZE-1:0] sb_addr          = 0;
    wire [`SIZE_WRITE_WIDTH-1:0] sb_size  = 0;

    wire store_success;
    wire store_stall;
    wire [`SIZE_WRITE_WIDTH-1:0] load_size = `FULL_WORD_SIZE; //Hardcode, we always want the full instruction (word size)

    initial begin
	pc = `PC_INITIAL;
    end

    /* PC selection */
    always @(posedge(clk)) begin
	if(exception_in || exception) begin
	    pc = `PC_EXCEPTION;
	    exception = 1;
	end else if(jump_taken) begin
	    pc = nextpc;
	end else if (rst) begin 
	    pc = `PC_INITIAL; // definir un pc initial
	end else if (!valid_out) begin
	    pc = pc; //in case of stall, we stay in the same pc
	end else begin
	    pc = pc + 4;
	end
    end

    /* iTLB */

    TLB itlb(
	.clk(clk),
	.virtual_page(pc[WORD_SIZE-1-:`PAGE_WIDTH]),
	.valid(valid),
	.physical_page_out(phy_mem_addr[WORD_SIZE-1-:`PAGE_WIDTH]),
	.exception(exception_out),
	.hit(hit_tlb)
    );

    /* iCache: wenable always 0 (hardcode wire)*/

    cache icache(
	.clk(clk),
	.rst(rst),
	.valid(valid && hit_tlb),
	.addr(phy_mem_addr),
	.load_size(load_size),
	.store(cache_store),
	.hit(cache_hit),
	.store_stall(store_stall),
	.read_data(instruction_out),
	.mem_req(mem_req),
	.mem_req_addr(mem_req_addr),
	.mem_res(mem_res),
	.mem_res_addr(mem_res_addr),
	.mem_res_data(mem_res_data),
	.mem_write(),
	.mem_write_addr(),
	.mem_write_data(),
	.sb_value(sb_value),
	.sb_addr(sb_addr),
	.sb_size(sb_size),
	.wenable(wenable),
	.store_success(store_success)
    );

endmodule
