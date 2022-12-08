`include "../defines.sv"

module F_D_Registers #(
  parameter WORD_SIZE = `WORD_SIZE,
) (
    input wire clk,
    input wire [WORD_SIZE-1:0] pc,
    input wire [WORD_SIZE-1:0] instruction,
    input wire valid,
    input wire stall,
    input wire reset,
    output reg [WORD_SIZE-1:0] pc_out,
    output reg [WORD_SIZE-1:0] instruction_out,
    output reg valid_out
);
    reg wenable;

    initial begin
        pc_out = 0;
        instruction_out = 0;
        valid_out = 0;
        wenable = 0;
    end

    always @(posedge(clk)) begin

        if (reset == 1) begin
            valid_out = 0;
        end
        else begin
            valid_out = valid;
        end

        wenable = stall == 0 || valid_out == 0;

        if (wenable) begin
            pc_out = pc;
            instruction_out = instruction;
        end
        
    end
endmodule