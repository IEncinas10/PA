`include "../defines.sv"

`ifndef F_D
`define F_D

module F_D_Registers #(
  parameter WORD_SIZE = `WORD_SIZE
) (
    input wire clk,
    input wire [WORD_SIZE-1:0] pc,
    input wire [WORD_SIZE-1:0] instruction,
    input wire valid,
    input wire stall,
    input wire reset,
    input wire exception,
    output reg [WORD_SIZE-1:0] pc_out, // Connect to ROB and D_E
    output reg [WORD_SIZE-1:0] instruction_out,
    output reg exception_out, // Connect to ROB
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

        wenable = stall == 0 || valid_out == 0;

        if (reset == 1) begin
	    valid_out = 0;
        end else if (wenable) begin
            valid_out	    <= valid;
            pc_out          <= pc;
            instruction_out <= instruction;
	    exception_out   <= exception;
        end
        
    end
endmodule

`endif
