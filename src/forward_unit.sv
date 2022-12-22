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
	input wire rs1_rob_entry_valid
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

initial begin
	s1_data = 0;
	s2_data = 0;
	stall = 0;
end

always @(*) begin
	stall = 0;

	if(rs1_rob_entry_valid) begin
		if(rs1_rob_entry == alu_rob_id) begin
			if(alu_bypass_enable) begin
				s1_data = alu_data;
			end else begin
				stall = 1;
			end
		end else if(rs1_rob_entry == mem_rob_id) begin
			if(mem_bypass_enable) begin
				s1_data = alu_data;
			end else begin
				stall = 1;
			end
		end else if(rs1_rob_entry == mul_rob_id) begin
			if(mul_bypass_enable) begin
				s1_data = alu_data;
			end else begin
				stall = 1;
			end
		end else if(rob_s1_valid)
			s1_data = rob_s1_data;
		end else 
			stall = 1;
		end
	end else 
		s1_data = rf_s1_data;
	end

	if(rs2_rob_entry_valid) begin
		if(rs2_rob_entry == alu_rob_id) begin
			if(alu_bypass_enable) begin
				s2_data = alu_data;
			end else begin
				stall = 1;
			end
		end else if(rs2_rob_entry == mem_rob_id) begin
			if(mem_bypass_enable) begin
				s2_data = alu_data;
			end else begin
				stall = 1;
			end
		end else if(rs2_rob_entry == mul_rob_id) begin
			if(mul_bypass_enable) begin
				s2_data = alu_data;
			end else begin
				stall = 1;
			end
		end else if(rob_s2_valid)
			s2_data = rob_s2_data;
		end else 
			stall = 1;
		end
	end else 
		s2_data = rf_s2_data;
	end

end

endmodule
