`include "defines.sv"

`ifndef FORWARD_UNIT
`define FORWARD_UNIT

module forward_unit #(
    parameter WORD_SIZE = `WORD_SIZE,
    parameter ROB_ENTRY_WIDTH = `ROB_ENTRY_WIDTH
) (
    /* Register file values */
    input wire [WORD_SIZE-1:0] rf_s1_data,
    input wire [WORD_SIZE-1:0] rf_s2_data,
    /* ROB values and whether they're valid or not (ready / instr. in flight)*/
    input wire [WORD_SIZE-1:0] rob_s1_data,
    input wire [WORD_SIZE-1:0] rob_s2_data,
    input wire rob_s1_valid,
    input wire rob_s2_valid,
    /* RF-ROB: where are rs1 and rs2 in the ROB? (if they are/will be in ROB) */
    input wire [ROB_ENTRY_WIDTH-1:0] rs1_rob_entry,
    input wire [ROB_ENTRY_WIDTH-1:0] rs2_rob_entry,
    input wire rs1_rob_entry_valid,
    input wire rs2_rob_entry_valid,
    /* Bypasses: ALU Stage, ALU ROB Writeback */ 
    input wire [WORD_SIZE-1:0]       alu_data,
    input wire [ROB_ENTRY_WIDTH-1:0] alu_rob_id,
    input wire alu_bypass_enable,
    /* ALU ROB Writeback */ 
    input wire [WORD_SIZE-1:0]       alu_wb_data,
    input wire [ROB_ENTRY_WIDTH-1:0] alu_wb_rob_id,
    input wire alu_wb_bypass_enable,
    /* Bypasses: MEM Stage, Mem ROB Writeback */ 
    input wire [WORD_SIZE-1:0]       mem_data,
    input wire [ROB_ENTRY_WIDTH-1:0] mem_rob_id,
    input wire mem_bypass_enable,
    /* Mem ROB writeback */
    input wire [WORD_SIZE-1:0]       mem_wb_data,
    input wire [ROB_ENTRY_WIDTH-1:0] mem_wb_rob_id,
    input wire mem_wb_bypass_enable,
    /* Bypasses: MUL Stage, MUL ROB  Writeback */ 
    input wire [WORD_SIZE-1:0]       mul_data,
    input wire [ROB_ENTRY_WIDTH-1:0] mul_rob_id,
    input wire mul_bypass_enable,
    /* MUL ROB  Writeback */ 
    input wire [WORD_SIZE-1:0]       mul_wb_data,
    input wire [ROB_ENTRY_WIDTH-1:0] mul_wb_rob_id,
    input wire mul_wb_bypass_enable,
    /* Correct s1 and s2 values IF AVAILABLE */
    output reg [WORD_SIZE-1:0] s1_data,
    output reg [WORD_SIZE-1:0] s2_data,
    /* Do we have to stall because data is not ready? */
    output reg stall
);

reg s1_available;
reg s2_available;

always @(*) begin
    
    /* 
     * If rs1 or rs2 have to be be yet to be architecturally updated we have
     * to consume them. From the ROB or from the pipeline bypasses.
     * 
     * For the moment we mark them as unavailable, and if we secure a bypass
     * we'll set them to available.
     */
    s1_available = !rs1_rob_entry_valid;
    s2_available = !rs2_rob_entry_valid;
    
    /* Initialize s1_data and s2_data to RF values */
    s1_data = rf_s1_data;
    s2_data = rf_s2_data;

    if(rs1_rob_entry_valid) begin
	/* Stage bypasses */
	if(rs1_rob_entry == alu_rob_id && alu_bypass_enable) begin
	    s1_data = alu_data;
	    s1_available = 1;
	end else if(rs1_rob_entry == mem_rob_id && mem_bypass_enable) begin
	    s1_data = mem_data;
	    s1_available = 1;
	end else if(rs1_rob_entry == mul_rob_id && mul_bypass_enable) begin
	    s1_data = mul_data;
	    s1_available = 1;
	end
	/* WB bypasses */
	else if(rs1_rob_entry == alu_wb_rob_id && alu_wb_bypass_enable) begin
	    s1_data = alu_wb_data;
	    s1_available = 1;
	end else if(rs1_rob_entry == mem_wb_rob_id && mem_wb_bypass_enable) begin
	    s1_data = mem_wb_data;
	    s1_available = 1;
	end else if(rs1_rob_entry == mul_wb_rob_id && mul_wb_bypass_enable) begin
	    s1_data = mul_wb_data;
	    s1_available = 1;
	end else if(rob_s1_valid) begin
	    s1_data = rob_s1_data;
	    s1_available = 1;
	end 
    end

    if(rs2_rob_entry_valid) begin
	if(rs2_rob_entry == alu_rob_id && alu_bypass_enable) begin
	    s2_data = alu_data;
	    s2_available = 1;
	end else if(rs2_rob_entry == mem_rob_id && mem_bypass_enable) begin
	    s2_data = mem_data;
	    s2_available = 1;
	end else if(rs2_rob_entry == mul_rob_id && mul_bypass_enable) begin
	    s2_data = mul_data;
	    s2_available = 1;
	end
	/* WB bypasses */
	else if(rs2_rob_entry == alu_wb_rob_id && alu_wb_bypass_enable) begin
	    s2_data = alu_wb_data;
	    s2_available = 1;
	end else if(rs2_rob_entry == mem_wb_rob_id && mem_wb_bypass_enable) begin
	    s2_data = mem_wb_data;
	    s2_available = 1;
	end else if(rs2_rob_entry == mul_wb_rob_id && mul_wb_bypass_enable) begin
	    s2_data = mul_wb_data;
	    s2_available = 1;
	end 
	/* Rob entry */
	else if(rob_s2_valid) begin 
	    s2_data = rob_s2_data;
	    s2_available = 1;
	end
    end
    
    stall = !s1_available || !s2_available;
end

endmodule

`endif
