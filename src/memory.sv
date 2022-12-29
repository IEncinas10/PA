`include "../defines.sv"

`ifndef MEMORY
`define MEMORY

module memory #(
  parameter MEM_DELAY_CYCLES = `MEM_DELAY_CYCLES,
  parameter NUM_BLOCKS       = `MEM_SIZE / LINE_SIZE,
  parameter NUM_WORDS        = `MEM_SIZE / `WORD_SIZE,
  parameter LINE_SIZE        = `CACHE_LINE_SIZE,
  parameter WORD_SIZE        = `WORD_SIZE
) (
    input wire clk,
    input wire                 i_read,    // I cache read request and addr
    input wire [WORD_SIZE-1:0] i_addr,
    output reg                 i_res,     // I cache response, addr and data
    output reg [LINE_SIZE-1:0] i_res_data,
    output reg [WORD_SIZE-1:0] i_res_addr,
    input wire                 d_read,    // D cache read request and addr
    input wire [WORD_SIZE-1:0] d_addr,
    output reg                 d_res,     // D cache response, addr and data
    output reg [LINE_SIZE-1:0] d_res_data,
    output reg [WORD_SIZE-1:0] d_res_addr,
    input wire                 d_wenable,   // D cache write port
    input wire [LINE_SIZE-1:0] d_w_data,    
    input wire [WORD_SIZE-1:0] d_w_addr
);


    reg [WORD_SIZE-1:0] data [0:NUM_WORDS];
    reg [LINE_SIZE-1:0] aux;

    reg [MEM_DELAY_CYCLES] [WORD_SIZE-1:0] d_addrs;
    reg [MEM_DELAY_CYCLES]                 d_reads;

    reg [MEM_DELAY_CYCLES] [WORD_SIZE-1:0] i_addrs;
    reg [MEM_DELAY_CYCLES]                 i_reads;

    reg [MEM_DELAY_CYCLES]                 d_wenables;
    reg [MEM_DELAY_CYCLES] [WORD_SIZE-1:0] d_w_addrs;
    reg [MEM_DELAY_CYCLES] [LINE_SIZE-1:0] d_w_datas;

    
    integer i;

    initial begin
        for(i = 0; i < NUM_BLOCKS; i = i + 1) begin
	    data[i] = 0;
        end

	for(i = 0; i < MEM_DELAY_CYCLES; i = i + 1) begin
	    d_addrs[i] = 0;
	    d_reads[i] = 0;

	    i_addrs[i] = 0;
	    i_reads[i] = 0;

	    d_wenables[i] = 0;
	    d_w_addrs[i] = 0;
	    d_w_datas[i] = 0;
	end
    end

    

    reg [WORD_SIZE-1:0] clean_d_addr; 
    reg [WORD_SIZE-1:0] clean_i_addr; 
    reg [WORD_SIZE-1:0] clean_w_addr;

    always @(*) begin
	//clean_d_addr = d_addrs[0] >> `OFFSET_SIZE;
	//clean_i_addr = i_addrs[0] >> `OFFSET_SIZE;
	//
	clean_d_addr = d_addrs[0] >> 2;
	clean_i_addr = i_addrs[0] >> 2;

	d_res      = d_reads[0];
	//d_res_data = data[clean_d_addr];
	d_res_data = {data[clean_d_addr + 3], data[clean_d_addr + 2], data[clean_d_addr + 1], data[clean_d_addr + 0]};
	d_res_addr = d_addrs[0];

	i_res      = i_reads[0];
	//i_res_data = data[clean_i_addr];
	i_res_data = {data[clean_i_addr + 3], data[clean_i_addr + 2], data[clean_i_addr + 1], data[clean_i_addr + 0]};
	i_res_addr = i_addrs[0];

    end


    always @(posedge(clk)) begin
	if(d_wenables[0]) begin
	    //clean_w_addr = d_w_addrs[0] >> `OFFSET_SIZE;
	    //data[clean_w_addr] = d_w_datas[0];
	    
	    clean_w_addr = d_w_addrs[0] >> 2;
	    aux = d_w_datas[0];

	    data[clean_w_addr + 0] = aux[31:0];
	    data[clean_w_addr + 1] = aux[63:32];
	    data[clean_w_addr + 2] = aux[95:64];
	    data[clean_w_addr + 3] = aux[127:96];
	end
	for(i = 0; i < MEM_DELAY_CYCLES - 1 ; i = i + 1) begin
	    d_addrs[i] = d_addrs[i + 1];
	    d_reads[i] = d_reads[i + 1];

	    i_addrs[i] = i_addrs[i + 1];
	    i_reads[i] = i_reads[i + 1];

	    d_wenables[i] = d_wenables[i + 1];
	    d_w_addrs[i]  = d_w_addrs[i + 1];
	    d_w_datas[i]  = d_w_datas[i + 1];
	end
	d_addrs[MEM_DELAY_CYCLES - 1] = d_addr;
	d_reads[MEM_DELAY_CYCLES - 1] = d_read;

	i_addrs[MEM_DELAY_CYCLES - 1] = i_addr;
	i_reads[MEM_DELAY_CYCLES - 1] = i_read;

	d_wenables[MEM_DELAY_CYCLES - 1] = d_wenable;
	d_w_addrs[MEM_DELAY_CYCLES - 1]  = d_w_addr;
	d_w_datas[MEM_DELAY_CYCLES - 1]  = d_w_data;

    end

   
endmodule

`endif
