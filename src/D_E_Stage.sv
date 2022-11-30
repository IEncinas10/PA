`include "../defines.sv"

module D_E_Stage #(
  parameter WORD_SIZE = `WORD_SIZE 
) (
    input wire clk,
    input wire [1:0] instruction_type,
    input wire [WORD_SIZE-1:0] pc,
    input wire [6:0] opcode,
    input wire [6:0] funct7,
    input wire [2:0] funct3,
    input wire [WORD_SIZE-1:0] s1, // rs1
    input wire [WORD_SIZE-1:0] s2, // rs2 : Iimm
    input wire [WORD_SIZE-1:0] immediate,
    input wire stall,
    input wire valid,
    output reg [1:0] instruction_type_out,
    output reg [WORD_SIZE-1:0] pc_out,
    output reg [6:0] opcode_out,
    output reg [6:0] funct7_out,
    output reg [2:0] funct3_out,
    output reg [WORD_SIZE-1:0] s1_out, // rs1
    output reg [WORD_SIZE-1:0] s2_out, // rs2 : Iimm
    output reg [WORD_SIZE-1:0] immediate_out
);

    wire wenable = stall == 0 && valid == 1;

    always @(posedge(clk)) begin
        if (wenable) begin
            instruction_type_out = instruction_type;
            pc_out = pc;
            opcode_out = opcode;
            funct7_out = funct7;
            funct3_out = funct3;
            s1_out = s1;
            s2_out = s2;
            immediate_out = immediate;
        end
    end
endmodule