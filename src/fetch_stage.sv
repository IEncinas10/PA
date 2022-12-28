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
	input wire nextpc,

	/* Connections to F_D_Registers */
	output wire [WORD_SIZE-1:0] pc_out,
	output wire [WORD_SIZE-1:0] instruction_out,
	output wire exception_out,
	output wire valid_out
);

wire [WORD_SIZE-1:0] pc;

assign valid_out = valid && !stall_out;

/* Wires for iTLB */
wire hit_tlb;
wire [WORD_SIZE-1-`PAGE_WIDTH:0] virtual_page;//TODO hay que inicializarlo a la page donde vaya a estar el codigo?? Ver despues
wire [WORD_SIZE-1-`PAGE_WIDTH:0] physical_page;

/* Wires for iCache */
wire wenable = 0;
wire mem_write;
wire [WORD_SIZE-1:0] mem_write_addr;
wire [`LINE_SIZE-1:0] mem_write_data; //revisar
wire sb_value;
wire [WORD_SIZE-1:0] sb_addr;
wire [WORD_SIZE-1:0] sb_size;
wire store_success;

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
	.valid(valid),
	.addr(physical_page),
	.load_size(),
	.store_stall(),
	.read_data(),
	.mem_req(),
	.mem_req_addr(),
	.mem_res(),
	.mem_res_addr(),
	.mem_res_data(),
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
