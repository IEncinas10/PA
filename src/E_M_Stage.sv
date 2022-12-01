`include "../defines.sv"

module E_M_Stage #(
  parameter WORD_SIZE = `WORD_SIZE
) (
    input wire clk,
    input wire [1:0] instruction_type,
    input wire [WORD_SIZE-1:0] pc,
    input wire [2:0] funct3,
    input wire [WORD_SIZE-1:0] aluResult, 
    input wire [WORD_SIZE-1:0] s2,
    input wire stall,
    input wire valid,
    input wire reset,
    input wire [6:0] rob_id,
    output reg [1:0] instruction_type_out,
    output reg [WORD_SIZE-1:0] pc_out,
    output reg [2:0] funct3_out,
    output reg [WORD_SIZE-1:0] aluResult_out, 
    output reg [WORD_SIZE-1:0] s2_out,
    output reg [6:0] rob_id_out,
    output reg valid_out
);

    reg wenable;

    always @(posedge(clk)) begin


        if (reset == 1) begin
            valid_out = 0;
        end
        else begin
            valid_out = valid;
        end

        wenable = stall == 0 || valid_out == 0;

        if (wenable) begin
            instruction_type_out = instruction_type;
            pc_out = pc;
            funct3_out = funct3;
            aluResult_out = aluResult;
            s2_out = s2;
            rob_id_out = rob_id;
        end
    end
endmodule