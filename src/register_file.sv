`include "register.sv"

module register_file #(
    parameter N = 5,      //-- Bits needed for the register. 2^N registers
    parameter WIDTH = 32  //-- Number of bits held by the register
) (
    input wire rst,
    input wire clk,

    // Writing to the register file
    input wire wenable,
    input wire [N-1:0] reg_in,
    input wire [WIDTH-1:0] din,

    // Reading from the register file
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    output reg [WIDTH-1:0] data_a,
    output reg [WIDTH-1:0] data_b
);

    // Array of wires that will be connected to each register
    wire [(2**N)-1:0] [WIDTH-1:0] registers_out;
    // Array of wenables that will be conected to each register
    reg [(2**N)-1:0] wenables;

    // The registers are automatically connected to the respective elements
    // of array 'wenables' and 'registers_out'. [0, 0, 0], [1, 1, 1], ..., [N-1, N-1, N-1]
    register #(.WIDTH(WIDTH)) registers [(2**N)-1:0] (
	.rst(rst),
	.clk(clk),
	.wenable(wenables),  // magic
	.din(din),
	.dout(registers_out) // magic
    );

    // output
    integer i;
    always @(*) begin
	// Can't write to r0, its always 0
	for (i=1; i < 32; i = i+1) begin
	    wenables[i] = (i == reg_in) && wenable;
	end

	data_a <= registers_out[a];
	data_b <= registers_out[b];
    end

endmodule
