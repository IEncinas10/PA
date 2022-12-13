`include "../defines.sv"

module M_WB_Registers #(
  parameter WORD_SIZE = `WORD_SIZE,
  parameter INSTR_TYPE_SZ = `INSTR_TYPE_SZ,
  parameter ROB_ENTRY_WIDTH = `ROB_ENTRY_WIDTH
) (
    input wire clk,
    input wire [INSTR_TYPE_SZ-1:0] instruction_type,
    input wire [WORD_SIZE-1:0] pc,
    input wire exception,
    input wire [WORD_SIZE-1:0] virtual_addr_exception,
    input wire [WORD_SIZE-1:0] aluResult, 
    input wire valid,
    input wire reset,
    input wire [ROB_ENTRY_WIDTH-1:0] rob_id,
    output reg [INSTR_TYPE_SZ-1:0] instruction_type_out,
    output reg [WORD_SIZE-1:0] pc_out,
    output reg exception_out,
    output reg [WORD_SIZE-1:0] virtual_addr_exception_out,
    output reg [WORD_SIZE-1:0] aluResult_out, 
    output reg [ROB_ENTRY_WIDTH-1:0] rob_id_out,
    output reg valid_out
);

    initial begin
        instruction_type_out = 0;
        pc_out = 0;
        exception_out = 0;
        virtual_addr_exception_out = 0;
        aluResult_out = 0;
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
        exception_out = exception;
        aluResult_out = aluResult;
        virtual_addr_exception_out = virtual_addr_exception;
        rob_id_out = rob_id;

    end
endmodule
