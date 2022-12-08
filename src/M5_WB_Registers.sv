`include "../defines.sv"

module M5_WB_Registers #(
  parameter WORD_SIZE = `WORD_SIZE,
  parameter INSTR_TYPE_SZ = `INSTR_TYPE_SZ
) (
    input wire clk,
    input wire [INSTR_TYPE_SZ-1:0] instruction_type,
    input wire [WORD_SIZE-1:0] pc,
    input wire [WORD_SIZE-1:0] result,
    input wire [6:0] rob_id,
    input wire valid,
    input wire reset,
    output reg [INSTR_TYPE_SZ-1:0] instruction_type_out,
    output reg [WORD_SIZE-1:0] pc_out,
    output reg [WORD_SIZE-1:0] result_out, 
    output reg [6:0] rob_id_out,
    output reg valid_out
);

    initial begin
        instruction_type_out = 0;
        pc_out = 0;
        result_out = 0;
        rob_id_out = 0;
        valid_out = 0;
    end

    always @(posedge(clk)) begin

        if (reset == 1) begin
            valid_out = 0;
        end
        else begin
            valid_out = valid;
        end

        instruction_type_out = instruction_type;
        pc_out = pc;
        result_out = result;
        rob_id_out = rob_id;
        
    end
endmodule