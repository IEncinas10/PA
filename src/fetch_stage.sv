`include "defines"
`include "memory.sv"
`include "tlb.sv"
`include "cache.sv"


module fetch_stage #(
	parameter WORD_SIZE = `WORD_SIZE
) (
	input wire clk,
	input wire rst,
	input wire valid,//maybe this is always valid (?), check
	
	/* Connections with other stages */
	input wire jump_taken,
	input wire [WORD_SIZE-1:0] nextpc,
	input wire stall_in,

	/* Connections with Memory */
	output wire mem_write;
	output wire [WORD_SIZE-1:0] mem_write_addr;
	output wire [`LINE_SIZE-1:0] mem_write_data;
    output wire                 mem_req,        // memory read port
    output wire [WORD_SIZE-1:0] mem_req_addr,
    output wire		        mem_write,       // Memory write port
    output wire [WORD_SIZE-1:0] mem_write_addr, 
    output wire [LINE_SIZE-1:0] mem_write_data,
    input wire		       mem_res,         // Memory response
    input wire [WORD_SIZE-1:0] mem_res_addr, 
    input wire [LINE_SIZE-1:0] mem_res_data,
	
	/* Connections to F_D_Registers */
	output wire [WORD_SIZE-1:0] pc_out,
	output wire [WORD_SIZE-1:0] instruction_out,
	output wire exception_out,
	output wire valid_out,
	output wire stall_out
);

reg [WORD_SIZE-1:0] pc;

assign valid_out = valid && !stall_out;
assign stall_out = (valid && !hit_tlb) || stall_in; //solo si es valido y no damos en la tlb??

assign pc_out = pc;

/* Wires for iTLB */
wire hit_tlb;
wire [WORD_SIZE-1:0] virtual_page;
assign [WORD_SIZE-1-`PAGE_WIDTH:0] virtual_page = pc[WORD_SIZE-1-:`PAGE_WIDTH];
wire [WORD_SIZE-1-`PAGE_WIDTH:0] physical_page;

/* Wires for iCache */
wire cache_hit,
wire wenable = 0;
wire cache_store = 0; 
wire sb_value;
wire [WORD_SIZE-1:0] sb_addr;
wire [WORD_SIZE-1:0] sb_size;
wire store_success;
wire store_stall;
wire [`SIZE_WRITE_WIDTH-1:0] load_size = `FULL_WORD_SIZE; //Hardcode, we always want the full instruction (word size)

/* PC selection */
always @(posedge(clk)) begin
	if (!exception_out && !jump_taken) begin
		pc = pc + 4;
	end else if (jump_taken) begin
		pc = nextpc;
	end else if (exception_out && !jump_taken) begin
		pc = pc; // en caso de exception que pasa con el pc
	end else if (rst) begin 
		pc = `PC_INITIAL; // definir un pc initial
	end else if (stall_out) begin
		pc = pc; //in case of stall, we stay in the same pc
	end
end

/* iTLB */

TLB itlb(
	.clk(clk),
	.virtual_page(virtual_page),
	.valid(valid),
	.physical_page_out(physical_page),
	.exception(exception_out),
	.hit(hit_tlb)
);

/* iCache: wenable always 0 (hardcode wire)*/

cache icache(
	.clk(clk),
	.rst(rst),
	.valid(valid && hit_tlb),
	.addr(physical_page),
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
	.mem_write(mem_write),
	.mem_write_addr(mem_write_addr),
	.mem_write_data(mem_write_data),
	.sb_value(sb_value),
	.sb_addr(sb_addr),
	.sb_size(sb_size),
	.wenable(wenable),
	.store_success(store_success)
);

endmodule
