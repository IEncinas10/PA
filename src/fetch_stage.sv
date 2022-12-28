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
	output wire exception_out
);

wire [WORD_SIZE-1:0] pc

/* iTLB */

TLB itlb(
	.clk(clk),
	.virtual_page(),
	.valid(valid),
	.physical_page_out(),
	.exception(),
	.hit()
);

/* iCache: wenable always 0 (hardcode wire)*/

cache icache(
	.clk(clk),
	.rst(rst),
	.valid(),
	.addr(),
	.load_size(),
	.store_stall(),
	.read_data(),
	.mem_req(),
	.mem_req_addr(),
	.mem_res(),
	.mem_res_addr(),
	.mem_res_data(),
	.mem_write(),
	.mem_write_addr(),
	.mem_write_data(),
	.sb_value(),
	.sb_addr(),
	.sb_size(),
	.wenable(),
	.store_success()
);



endmodule
