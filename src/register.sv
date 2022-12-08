`include "defines.sv"

module register #(
    parameter WIDTH = `WORD_SIZE,  //-- Width of the register (nº bits)
    parameter INIT = 0     //-- Initial value after reset
) (
    input wire rst, 
    input wire clk, 
    input wire wenable,
    input wire [WIDTH-1:0] din, 
    output reg [WIDTH-1:0] dout
);

initial begin
    dout <= INIT;
end


always @(posedge(clk)) begin
    if (rst == 1) begin
	dout <= INIT;
    end
    else if(wenable) begin
	dout <= din;
    end
end
endmodule
