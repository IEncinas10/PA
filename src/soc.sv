`include "defines.sv"
`include "core.sv"

module soc#(
    parameter WORD_SIZE = `WORD_SIZE,
    parameter LINE_SIZE = `CACHE_LINE_SIZE,
    parameter MEM_SIZE = `MEM_SIZE
) (
    input wire clk,
    input wire rst
);

    wire                 i_read;    // I cache read request and addr
    wire [WORD_SIZE-1:0] i_addr;
    wire                 i_res;     // I cache response; addr and data
    wire [LINE_SIZE-1:0] i_res_data;
    wire [WORD_SIZE-1:0] i_res_addr;
    wire                 d_read;    // D cache read request and addr
    wire [WORD_SIZE-1:0] d_addr;
    wire                 d_res;     // D cache response; addr and data
    wire [LINE_SIZE-1:0] d_res_data;
    wire [WORD_SIZE-1:0] d_res_addr;
    wire                 d_wenable;   // D cache write port
    wire [LINE_SIZE-1:0] d_w_data;    
    wire [WORD_SIZE-1:0] d_w_addr;

    core cpu(
	.clk(clk),
	.rst(rst),
	.i_read(i_read),
	.i_addr(i_addr),
	.i_res(i_res),
	.i_res_data(i_res_data),
	.i_res_addr(i_res_addr),
	.d_read(d_read),
	.d_addr(d_addr),
	.d_res(d_res),
	.d_res_data(d_res_data),
	.d_res_addr(d_res_addr),
	.d_wenable(d_wenable),
	.d_w_data(d_w_data),
	.d_w_addr(d_w_addr)
    );

    memory #(
	.NUM_BLOCKS = MEM_SIZE / LINE_SIZE, 
	.NUM_WORDS = MEM_SIZE / WORD_SIZE) 
	mem (
	.clk(clk),
	.i_read(i_read),
	.i_addr(i_addr),
	.i_res(i_res),
	.i_res_data(i_res_data),
	.i_res_addr(i_res_addr),
	.d_read(d_read),
	.d_addr(d_addr),
	.d_res(d_res),
	.d_res_data(d_res_data),
	.d_res_addr(d_res_addr),
	.d_wenable(d_wenable),
	.d_w_data(d_w_data),
	.d_w_addr(d_w_addr)
    );
endmodule
