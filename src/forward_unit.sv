`include "defines.sv"

module forward_unit #(
	parameter WORD_SIZE = `WORD_SIZE,
	parameter ROB_ENTRY_WITDH = `ROB_ENTRY_WITDH
) (
	input wire [WORD_SIZE-1:0] rf_s1_data,
	input wire [WORD_SIZE-1:0] rf_s2_data,
	input wire [WORD_SIZE-1:0] rob_s1_data,
	input wire [WORD_SIZE-1:0] rob_s2_data,
	input wire rob_s1_valid,
	input wire rob_s2_valid,
	input wire [ROB_ENTRY_WIDTH-1:0] rs1_rob_entry,
	input wire [ROB_ENTRY_WIDTH-1:0] rs2_rob_entry,
	input wire [WORD_SIZE-1:0] alu_data,
	input wire [ROB_ENTRY_WIDTH-1:0] alu_rob_id,
	input wire alu_bypass_enable,
	input wire [WORD_SIZE-1:0] mem_data,
	input wire [ROB_ENTRY_WIDTH-1:0] mem_rob_id,
	input wire mem_bypass_enable,
	input wire [WORD_SIZE-1:0] mul_data,
	input wire [ROB_ENTRY_WIDTH-1:0] mul_rob_id,
	input wire mul_bypass_enable,
	output reg [WORD_SIZE-1:0] s1_data,
	output reg [WORD_SIZE-1:0] s2_data,
	output reg stall
);

always @(*) begin

end

endmodule