`timescale 1 ns / 1 ns

module register #(
    parameter WIDTH = 32,  //-- Width of the register (nº bits)
    parameter INIT = 0     //-- Initial value after reset
) (
    input wire rst, 
    input wire clk, 
    input wire wenable,
    input wire [WIDTH-1:0] din, 
    output reg [WIDTH-1:0] dout
);
always @(posedge(clk)) begin
    if (rst == 1) begin
	dout <= INIT;
    end
    else if(wenable) begin
	dout <= din;
    end
end
endmodule
