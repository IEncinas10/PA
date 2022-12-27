`include "../defines.sv"

module decode_stage #(
  parameter WORD_SIZE = `WORD_SIZE 
) (
    input wire clk,
    input wire rst,

    /* Input connection from F_D_Registers */
    input wire [`INSTR_SIZE-1:0] instruction,

    /* Connections for Forward Unit */
    input wire [WORD_SIZE-1:0] rob_s1_data,
    input wire [WORD_SIZE-1:0] rob_s2_data,
    input wire rob_s1_valid,
    input wire rob_s2_valid,
    input wire [WORD_SIZE-1:0]       alu_data,
    input wire [`ROB_ENTRY_WIDTH-1:0] alu_rob_id,
    input wire alu_bypass_enable,
    input wire [WORD_SIZE-1:0]       alu_wb_data,
    input wire [`ROB_ENTRY_WIDTH-1:0] alu_wb_rob_id,
    input wire alu_wb_bypass_enable,
    input wire [WORD_SIZE-1:0]       mem_data,
    input wire [`ROB_ENTRY_WIDTH-1:0] mem_rob_id,
    input wire mem_bypass_enable,
    input wire [WORD_SIZE-1:0]       mem_wb_data,
    input wire [`ROB_ENTRY_WIDTH-1:0] mem_wb_rob_id,
    input wire mem_wb_bypass_enable,
    input wire [WORD_SIZE-1:0]       mul_data,
    input wire [`ROB_ENTRY_WIDTH-1:0] mul_rob_id,
    input wire mul_bypass_enable,
    input wire [WORD_SIZE-1:0]       mul_wb_data,
    input wire [ROB_ENTRY_WIDTH-1:0] mul_wb_rob_id,
    input wire mul_wb_bypass_enable,	

    /* Connection to D_E_Registers */
    output reg [WORD_SIZE-1:0] s1_data_out,
    output reg [WORD_SIZE-1:0] s2_data_out,
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,
    output reg [6:0] opcode_out,
    output reg [WORD_SIZE-1:0] imm_out,
    output reg [`INSTR_TYPE_SZ-1:0] instr_type_out,
    
    /* Connections RF_ROB with ROB */
    input wire commit,
    input wire commit_rd,
    input wire commit_rob_id,

    /* Connections RF with ROB*/
    input wire wenable_rf,
    input wire [N-1:0] reg_in,
    input wire [WORD_SIZE-1:0] din,

    /* Connections to ROB */
    input wire [ROB_ENTRY_WIDTH-1:0] assigned_rob_id,
    input wire full,
    output reg require_rob_entry,
    output reg is_store,
    output reg [`REG_INDEX_SIZE-1:0] rd,
    
    /* Connections from other stages */
    input wire jump_taken,
    input wire stall_in,//This stall is used for RF_ROB renaming, 

    /* STALL output */
    output reg stall_out
);
    /* Wires for decoder connections*/
    wire [2:0] funct3_wire;
    wire [6:0] funct7_wire;
    wire [6:0] opcode_wire;
    wire [WORD_SIZE-1:0] imm_wire;
    wire [`INSTR_TYPE_SZ] instr_type_wire;
    wire [`ARCH_REG_INDEX_SIZE-1:0] rs1_wire;
    wire [`ARCH_REG_INDEX_SIZE-1:0] rs2_wire;
    wire [`ARCH_REG_INDEX_SIZE-1:0] rd_wire;
    
    /* Wire for renaming wire logic */
    wire renaming_reg_wire;

    /* Wires for RF connection with Forward Unit */
    wire [WORD_SIZE-1:0] rf_s1_data_wire;
    wire [WORD_SIZE-1:0] rf_s2_data_wire;
    
    /* Wires for RF-ROB connection with Forward Unit */
    wire [`ROB_ENTRY_WIDTH-1:0] rs1_rob_entry_wire;
    wire [`ROB_ENTRY_WIDTH-1:0] rs2_rob_entry_wire;
    wire [`ROB_ENTRY_WIDTH-1:0] rs1_rob_entry_valid_wire;
    wire [`ROB_ENTRY_WIDTH-1:0] rs2_rob_entry_valid_wire;
    
    /* output wires to F_D_registers */
    wire [WORD_SIZE-1:0] s1_data_wire;
    wire [WORD_SIZE-1:0] s2_data_wire;
    
    wire stall_wire;

    /* Require rob entry logic and output assignation */
    require_rob_entry = instr_type != `INSTR_TYPE_NO_WB && !jump_taken;
    
    /* Renaming wire logic */
    assign renaming_reg_wire = !full && require_rob_entry && !jump_taken && !stall_in && instr_type != `INSTR_TYPE_STORE;
    //he puesto instr_type != INSTR_TYPE_STORE, ya que si lo pusiese a igual
    //no encaja con el comentario que haces en el commit...

    // decoder

    decoder decoder(
	    .instr(instruction),
	    .rs1(rs1_wire),
	    .rs2(rs2_wire),
	    .rd(rd_wire),
	    .imm(imm_wire),
	    .instr_type(instr_type_wire),
	    .opcode(opcode_wire),
	    .funct7(funct7_wire),
	    .funct3(funct3_wire),
    );

    /* Decode outputs to D_E_Registers */
    funct3_out <= funct3_wire;
    funct7_out <= funct7_wire;
    opcode_out <= opcode_wire;
    imm_out <= imm_wire;
    instr_type_out = instr_type_wire


    register_file register_file(
	.rst(rst),
	.clk(clk),
	.wenable(wenable_rf),
	.reg_in(reg_in),//TODO ver en los test si funciona teniendo los mismos nombres
	.din(din),
	.a(rs1_wire),
	.b(rs1_wire),
	data_a(rf_s1_data_wire),
	data_b(rf_s2_data_wire)
    );

    RF_ROB RF_ROB(
	.clk(clk),
	.reset(rst),
	.rs1(rs1_wire),
	.rs2(rs2_wire),
	.rs1_rob_entry(rs1_rob_entry_wire),
	.rs1_rob_entry_valid(rs1_rob_entry_valid_wire),
	.rs2_rob_entry(rs2_rob_entry_wire),
	.rs2_rob_entry_valid(rs2_rob_entry_valid_wire),
	.renaming_reg(renaming_reg_wire),
	.rd(rd_wire),
	.rob_id(assigned_rob_id),
	.commit(commit_rd),
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
	.rs1_rob_entry(rs1_rob_entry_wire),
	.rs2_rob_entry(rs2_rob_entry_wire),
	.rs1_rob_entry_valid(rs1_rob_entry_valid_wire),
	.rs2_rob_entry_valid(rs2_rob_entry_valid_wire),
	.alu_data(alu_data),
	.alu_rob_id(alu_rob_id),
	.alu_wb_bypass_enable(alu_wb_bypass_enable),
	.alu_wb_data(alu_wb_data),
	.alu_wb_rob_id(alu_wb_rob_id),
	.alu_wb_bypass_enable(alu_wb_bypass_enable),
	.mem_data(mem_data),
	.mem_rob_id(mem_rob_id),
	.mem_bypass_enable(mem_bypass_enable),
	.mem_wb_data(mem_wb_data),
	.mem_wb_rob_id(mem_wb_rob_id),
	-mem_wb_bypass_enable(mem_wb_bypass_enable),
	.mul_data(mul_data),
	.mul_rob_id(mul_rob_id),
	.mul_bypass_enable(mul_bypass_enable),
	.mul_wb_data(mul_wb_data),
	.mul_wb_rob_id(mul_wb_rob_id),
	.mul_wb_bypass_enable(mul_wb_bypass_enable),
	.s1_data(s1_data_wire),
	.s2_data(s1_data_wire),
	.stall(stall_wire)
    );
    
    /* Output for require_rob_entry ROB: TODO missing... en diagrama pone que es salida 
    * del decoder sale de decoder, comprobar de donde viene realmente. */

    is_store = instr_type_wire == `INSTR_TYPE_STORE ? 1 : 0;
    rd <= rd_wire;
    
    //output assignation from Forward Unit wires to stage output wires
    s1_data_out <= s1_data_wire;
    s2_data_out <= s2_data_wire;
    stall_out <= stall_wire || stall_in; // stall if forward_unit says stall or if we receive stall
endmodule
