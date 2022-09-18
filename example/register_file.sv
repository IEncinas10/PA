`include "register.sv"
`timescale 1 ns / 1 ns

module register_file #(
    parameter N = 5,        //-- Número de registros
    parameter WIDTH = 32     //-- Número de bits del registro
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

    wire [(2**N)-1:0] [WIDTH-1:0] registers_out;
    reg [(2**N)-1:0] wenables;
    register #(.WIDTH(WIDTH)) registers [(2**N)-1:0] (
	.rst(rst),
	.clk(clk),
	.wenable(wenables),
	.din(din),
	.dout(registers_out) // magia
    );
    
    //always @(posedge clk) begin
	//if(rst) begin
	    //// do nothing, auto reset?
	//end 
    //end

    // output
    integer i;
    always @(*) begin
	for (i=0; i < 32; i = i+1) begin
	    wenables[i] = i == reg_in;
	end

	data_a <= registers_out[a];
	data_b <= registers_out[b];
    end

endmodule


// Eliminar el módulo registro, ¿no? se puede propagar el write enable hacia
// abajo
//module register #( parameter WIDTH = 32,     //-- Nmero de bits del registro
    //parameter INI = 0   //-- Valor inicial
//) (
    //input wire rst, 
    //input wire clk, 
    //input wire wenable,
    //input wire [WIDTH-1:0] din, 
    //output reg [WIDTH-1:0] dout
//);
//always @(posedge(clk)) begin
    //if (rst == 1) begin
	//dout <= INI; //-- Inicializacion
    //end
    //else if(wenable) begin
	//dout <= din; //-- Funcionamiento normal
    //end
	////dout <= din; //-- Funcionamiento normal
//end
//endmodule



