`include "defines.sv"
`include "decoder.sv"
`include "RF_ROB.sv"
`include "forward_unit.sv"
`include "register_file.sv"

`ifndef DECODE_STAGE
`define DECODE_STAGE

module decode_stage #(
  parameter WORD_SIZE = `WORD_SIZE
) (
    input wire clk,
    input wire rst,

    /* Input connection from F_D_Registers */
    input wire [`WORD_SIZE-1:0] instruction,
    input wire valid,

    /* Connections for Forward Unit */
    input wire [WORD_SIZE-1:0] rob_s1_data,
    input wire [WORD_SIZE-1:0] rob_s2_data,
    input wire                 rob_s1_valid, //This are the rob sources valid bit
    input wire                 rob_s2_valid,
    input wire [WORD_SIZE-1:0]        alu_data,          /* ALU stage bypass */
    input wire [`ROB_ENTRY_WIDTH-1:0] alu_rob_id,
    input wire                        alu_bypass_enable, 
    input wire [WORD_SIZE-1:0]        alu_wb_data,       /* ALU writeback bypass */
    input wire [`ROB_ENTRY_WIDTH-1:0] alu_wb_rob_id,
    input wire                        alu_wb_bypass_enable,
    input wire [WORD_SIZE-1:0]        mem_data,          /* MEM stage bypass */
    input wire [`ROB_ENTRY_WIDTH-1:0] mem_rob_id,
    input wire                        mem_bypass_enable,
    input wire [WORD_SIZE-1:0]        mem_wb_data,      /* MEM writeback bypass */
    input wire [`ROB_ENTRY_WIDTH-1:0] mem_wb_rob_id,
    input wire                        mem_wb_bypass_enable,
    input wire [WORD_SIZE-1:0]        mul_data,         /* MUL stage bypass */
    input wire [`ROB_ENTRY_WIDTH-1:0] mul_rob_id,
    input wire                        mul_bypass_enable,
    input wire [WORD_SIZE-1:0]        mul_wb_data,      /* MUL writeback bypass */
    input wire [`ROB_ENTRY_WIDTH-1:0] mul_wb_rob_id,
    input wire                        mul_wb_bypass_enable,	

    /* Connection to D_E_Registers */
    output wire [WORD_SIZE-1:0]      s1_data_out,
    output wire [WORD_SIZE-1:0]      s2_data_out,
    output wire [2:0]                funct3_out,
    output wire [6:0]                funct7_out,
    output wire [6:0]                opcode_out,
    output wire [WORD_SIZE-1:0]      imm_out,
    output wire [`INSTR_TYPE_SZ-1:0] instr_type_out,
	
    /* Connections RF_ROB with ROB */
    input wire                            commit,
    input wire [`ARCH_REG_INDEX_SIZE-1:0] commit_rd,
    input wire [`ROB_ENTRY_WIDTH-1:0]     commit_rob_id,

    /* Connections RF with ROB*/
    input wire [WORD_SIZE-1:0]            din,
	
    /* Connections to ROB */
    input wire [`ROB_ENTRY_WIDTH-1:0]      assigned_rob_id,
    input wire                             full,
    output wire                            require_rob_entry,
    output wire                            is_store,
    output wire [`ARCH_REG_INDEX_SIZE-1:0] rd,
	output wire [`ROB_ENTRY_WIDTH-1:0] rs1_rob_entry_out, //Rob entries from RF_ROB
	output wire [`ROB_ENTRY_WIDTH-1:0] rs2_rob_entry_out,

    
    /* Connections from other stages */
    input wire jump_taken,
    input wire stall_in,//This stall is used for RF_ROB renaming, 

    /* STALL output */
    output wire stall_out
);
    /* Wires for decoder connections*/
    wire [`ARCH_REG_INDEX_SIZE-1:0] rs1_wire;
    wire [`ARCH_REG_INDEX_SIZE-1:0] rs2_wire;
    
    /* Wires for RF connection with Forward Unit */
    wire [WORD_SIZE-1:0] rf_s1_data_wire;
    wire [WORD_SIZE-1:0] rf_s2_data_wire;
    
    /* Wires for RF-ROB connection with Forward Unit */
    wire rs1_rob_entry_valid_wire;
    wire rs2_rob_entry_valid_wire;
    
    /* output wires to F_D_registers */
    wire [WORD_SIZE-1:0] s1_data_wire;
    wire [WORD_SIZE-1:0] s2_data_wire;
    
    wire stall_wire;

    /* Require rob entry logic and output assignation */
    assign require_rob_entry = instr_type_out != `INSTR_TYPE_NO_WB && !jump_taken && valid;//TODO revisar error de compilacion en esta linea(?)
    
    /* Renaming wire logic */
    wire renaming_reg_wire = !full && require_rob_entry && !jump_taken && !stall_in && instr_type_out != `INSTR_TYPE_STORE && valid;

    decoder decoder(
	.instr(instruction),
	.rs1(rs1_wire),
	.rs2(rs2_wire),
	.rd(rd),
	.imm(imm_out),
	.instr_type(instr_type_out),
	.opcode(opcode_out),
	.funct7(funct7_out),
	.funct3(funct3_out)
    );

    register_file register_file(
	.rst(rst),
	.clk(clk),
	.wenable(commit),
	.reg_in(commit_rd),
	.din(din),
	.a(rs1_wire),
	.b(rs1_wire),
	.data_a(rf_s1_data_wire),
	.data_b(rf_s2_data_wire)
    );

    RF_ROB RF_ROB(
	.clk(clk),
	.reset(rst),
	.rs1(rs1_wire),
	.rs2(rs2_wire),
	.rs1_rob_entry(rs1_rob_entry_out),
	.rs1_rob_entry_valid(rs1_rob_entry_valid_wire),
	.rs2_rob_entry(rs2_rob_entry_out),
	.rs2_rob_entry_valid(rs2_rob_entry_valid_wire),
	.renaming_reg(renaming_reg_wire),
	.rd(rd),
	.rob_id(assigned_rob_id),
	.commit(commit),
	.commit_rd(commit_rd),
	.commit_rob_id(commit_rob_id)
    );

    forward_unit forward_unit(
	.rf_s1_data(rf_s1_data_wire),
	.rf_s2_data(rf_s2_data_wire),
	.rob_s1_data(rob_s1_data),
	.rob_s2_data(rob_s2_data),
	.rob_s1_valid(rob_s1_valid),
	.rob_s2_valid(rob_s2_valid),
	.rs1_rob_entry(rs1_rob_entry_out),
	.rs2_rob_entry(rs2_rob_entry_out),
	.rs1_rob_entry_valid(rs1_rob_entry_valid_wire),
	.rs2_rob_entry_valid(rs2_rob_entry_valid_wire),
	.alu_data(alu_data),
	.alu_rob_id(alu_rob_id),
	.alu_bypass_enable(alu_bypass_enable),
	.alu_wb_data(alu_wb_data),
	.alu_wb_rob_id(alu_wb_rob_id),
	.alu_wb_bypass_enable(alu_wb_bypass_enable),
	.mem_data(mem_data),
	.mem_rob_id(mem_rob_id),
	.mem_bypass_enable(mem_bypass_enable),
	.mem_wb_data(mem_wb_data),
	.mem_wb_rob_id(mem_wb_rob_id),
	.mem_wb_bypass_enable(mem_wb_bypass_enable),
	.mul_data(mul_data),
	.mul_rob_id(mul_rob_id),
	.mul_bypass_enable(mul_bypass_enable),
	.mul_wb_data(mul_wb_data),
	.mul_wb_rob_id(mul_wb_rob_id),
	.mul_wb_bypass_enable(mul_wb_bypass_enable),
	.s1_data(s1_data_out),
	.s2_data(s2_data_out),
	.stall(stall_wire)
    );

    assign is_store = (instr_type_out == `INSTR_TYPE_STORE) ? 1 : 0;
    
    //output assignation from Forward Unit wires to stage output wires
    assign stall_out = stall_wire || stall_in; // stall if forward_unit says stall or if we receive stall

endmodule

`endif
