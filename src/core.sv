`include "defines.sv"
`include "TLB.sv"
`include "cache.sv"
`include "cache_stage.sv"
`include "memory.sv"
`include "alu.sv"


module core #(
    parameter WORD_SIZE = `WORD_SIZE,
    parameter LINE_SIZE = `CACHE_LINE_SIZE
) (
    input wire clk,
    input wire rst,
    output wire                 i_read,    // I cache read request and addr
    output wire [WORD_SIZE-1:0] i_addr,
    input wire                 i_res,     // I cache response, addr and data
    input wire [LINE_SIZE-1:0] i_res_data,
    input wire [WORD_SIZE-1:0] i_res_addr,
    output wire                 d_read,    // D cache read request and addr
    output wire [WORD_SIZE-1:0] d_addr,
    input reg                 d_res,     // D cache response, addr and data
    input reg [LINE_SIZE-1:0] d_res_data,
    input reg [WORD_SIZE-1:0] d_res_addr,
    output wire                 d_wenable,   // D cache write port
    output wire [LINE_SIZE-1:0] d_w_data,    
    output wire [WORD_SIZE-1:0] d_w_addr
);

    wire [WORD_SIZE-1:0] fetch_pc_out;
    wire [WORD_SIZE-1:0] fetch_instr_out;
    wire                 fetch_valid_out;
    wire                 fetch_exception_out;

    wire [WORD_SIZE-1:0] f_d_pc_out;
    wire [WORD_SIZE-1:0] f_d_instr_out;
    wire                 f_d_exception_out;
    wire                 f_d_valid_out;

    wire                       decode_stall_out;
    wire [`INSTR_TYPE_OUT-1:0] decode_instr_type_out;
    wire [WORD_SIZE-1:0]       decode_s1_data_out;
    wire [WORD_SIZE-1:0]       decode_s2_data_out;
    wire [WORD_SIZE-1:0]       decode_imm_out;
    wire		       decode_require_rob_entry;
    wire 		       decode_is_store;
    wire 		       decode_rd;
    wire [2:0]		       decode_funct3_out;
    wire [6:0]		       decode_funct7_out;
    wire [6:0]		       decode_opcode_out;

    wire [`INSTR_TYPE_OUT-1:0]  d_e_instr_type_out;
    wire [WORD_SIZE-1:0]        d_e_pc_out;
    wire [WORD_SIZE-1:0]        d_e_imm_out;
    wire [2:0]		        d_e_funct3_out;
    wire [6:0]		        d_e_funct7_out;
    wire [6:0]		        d_e_opcode_out;
    wire [WORD_SIZE-1:0]        d_e_s1_out;
    wire [WORD_SIZE-1:0]        d_e_s2_out;
    wire [`ROB_ENTRY_WIDTH-1:0] d_e_rob_id_out;
    wire                        d_e_valid_out;


    wire	 	 alu_branch_taken;
    wire [WORD_SIZE-1:0] alu_newpc;
    wire [WORD_SIZE-1:0] alu_result;
    wire		 alu_instr_valid;
    assign alu_instr_valid = d_e_valid_out;

    wire [`INSTR_TYPE_OUT-1:0]  e_m_instr_type_out;
    wire [WORD_SIZE-1:0]        e_m_pc_out;
    wire [WORD_SIZE-1:0]        e_m_imm_out;
    wire [2:0]		        e_m_funct3_out;
    wire [WORD_SIZE-1:0]        e_m_alu_result_out;
    wire [WORD_SIZE-1:0]        e_m_s2_out;
    wire [`ROB_ENTRY_WIDTH-1:0] e_m_rob_id_out;
    wire                        e_m_valid_out;

    wire [WORD_SIZE-1:0]	cache_load_data;
    wire [WORD_SIZE-1:0] 	cache_v_addr_exception;
    wire                 	cache_exception;
    wire                 	cache_valid_out;
    wire                 	cache_stall_out;

    wire [`INSTR_TYPE_OUT-1:0]  m_wb_instr_type_out;
    wire [WORD_SIZE-1:0]        m_wb_pc_out;
    wire [WORD_SIZE-1:0]        m_wb_load_data_out;
    wire [`ROB_ENTRY_WIDTH-1:0] m_wb_rob_id_out;
    wire                        m_wb_valid_out;
    wire                        m_wb_exception_out;
    wire                        m_wb_v_addr_exception_out;

    wire [`INSTR_TYPE_OUT-1:0]  m2_m3_instr_type_out;
    wire [WORD_SIZE-1:0]        m2_m3_pc_out;
    wire [WORD_SIZE-1:0]        m2_m3_alu_result_out;
    wire [`ROB_ENTRY_WIDTH-1:0] m2_m3_rob_id_out;
    wire                        m2_m3_valid_out;

    wire [`INSTR_TYPE_OUT-1:0]  m3_m4_instr_type_out;
    wire [WORD_SIZE-1:0]        m3_m4_pc_out;
    wire [WORD_SIZE-1:0]        m3_m4_alu_result_out;
    wire [`ROB_ENTRY_WIDTH-1:0] m3_m4_rob_id_out;
    wire                        m3_m4_valid_out;

    wire [`INSTR_TYPE_OUT-1:0]  m4_m5_instr_type_out;
    wire [WORD_SIZE-1:0]        m4_m5_pc_out;
    wire [WORD_SIZE-1:0]        m4_m5_alu_result_out;
    wire [`ROB_ENTRY_WIDTH-1:0] m4_m5_rob_id_out;
    wire                        m4_m5_valid_out;

    wire [`INSTR_TYPE_OUT-1:0]  m5_wb_instr_type_out;
    wire [WORD_SIZE-1:0]        m5_wb_pc_out;
    wire [WORD_SIZE-1:0]        m5_wb_alu_result_out;
    wire [`ROB_ENTRY_WIDTH-1:0] m5_wb_rob_id_out;
    wire                        m5_wb_valid_out;

    wire		 rob_exception_out;
    wire [WORD_SIZE-1:0] rob_ex_pc;

    wire [`ROB_ENTRY_WIDTH-1:0] rob_assigned_rob_id;
    wire			rob_full;

    /* RF and RF-ROB. Don't write into RF if exception present */
    wire                        rob_commit;
    wire [`REG_INDEX_SIZE-1:0]  rob_commit_rd;
    wire [WORD_SIZE-1:0]        rob_commit_value;
    wire [`ROB_ENTRY_WIDTH-1:0] rob_commit_rob_entry;

    wire [WORD_SIZE-1:0] rob_bypass_s1;
    wire [WORD_SIZE-1:0] rob_bypass_s2;
    wire                 rob_bypass_s1_valid;
    wire                 rob_bypass_s2_valid;
    wire		       rob_sb_store_permission;
    wire [`ROB_ENTRY_WIDTH-1:0] rob_sb_rob_id;


    fetch_stage fetch(
	.clk(clk),
	.rst(rst),
	.jump_taken(alu_branch_taken && alu_instr_valid),
	.nextpc(alu_newpc),
	.stall_in(),
	.exception_in(rob_exception_out),
	.mem_req(i_read),
	.mem_req_addr(i_addr),
	.mem_res(i_res),
	.mem_res_addr(i_res_addr),
	.mem_res_data(i_res_data),
	.pc_out(fetch_pc_out),
	instruction_out(fetch_instr_out),
	.exception_out(fetch_exception_out),
	.valid_out(fetch_valid_out)
    );

    F_D_Registers f_d(
	.clk(clk),
	.pc(fetch_pc_out),
	.instruction(fetch_instr_out),
	.valid(fetch_valid_out),
	.stall(),
	.reset(rst || rob_exception_out || (alu_branch_taken && alu_instr_valid)),
	.exception(fetch_exception_out),
	.pc_out(f_d_pc_out), 
	.instruction_out(f_d_instr_out),
	.exception_out(f_d_exception_out), 
	.valid_out(f_d_valid_out)
    );

    decode_stage decode(
	.clk(clk),
	.rst(rst || rob_exception_out), //incorrectly resetting register file 
	.instruction(f_d_instr_out),
	.valid(f_d_valid_out),
	.rob_s1_data(rob_bypass_s1),
	.rob_s2_data(rob_bypass_s2),
	.rob_s1_valid(rob_bypass_s1_valid),
	.rob_s2_valid(rob_bypass_s2_valid),
	.alu_data(alu_result),          /* ALU stage bypass */
	.alu_rob_id(d_e_rob_id_out),
	.alu_bypass_enable(d_e_valid_out && d_e_instr_type_out == `INSTR_TYPE_ALU), 
	.alu_wb_data(e_m_alu_result_out),       /* ALU writeback bypass */
	.alu_wb_rob_id(e_m_rob_id_out),
	.alu_wb_bypass_enable(e_m_valid_out && e_m_instr_type_out == `INSTR_TYPE_ALU),
	.mem_data(cache_load_data),          /* MEM stage bypass */
	.mem_rob_id(e_m_rob_id_out),
	.mem_bypass_enable(cache_valid_out),
	.mem_wb_data(m_wb_load_data_out),      /* MEM writeback bypass */
	.mem_wb_rob_id(m_wb_rob_id_out),
	.mem_wb_bypass_enable(m_wb_valid_out),
	.mul_data(m4_m5_alu_result_out),         /* MUL stage bypass */
	.mul_rob_id(m4_m5_rob_id_out),
	.mul_bypass_enable(m4_m5_valid_out),
	.mul_wb_data(m5_wb_alu_result_out),      /* MUL writeback bypass */
	.mul_wb_rob_id(m5_wb_rob_id_out),
	.mul_wb_bypass_enable(m5_wb_valid_out),	
	.s1_data_out(decode_s1_data_out),
	.s2_data_out(decode_s2_data_out),
	.funct3_out(decode_funct3_out),
	.funct7_out(decode_funct7_out),
	.opcode_out(decode_opcode_out),
	.imm_out(decode_imm_out),
	.instr_type_out(decode_instr_type_out),
	.commit(rob_commit),
	.commit_rd(rob_commit_rd),
	.commit_rob_id(rob_commit_rob_entry),
	.din(rob_commit_value),
	.assigned_rob_id(rob_assigned_rob_id),
	.full(rob_full),
	// TODO: add connections with rob: rs1_rob_entry, rs2_rob_entry
	.require_rob_entry(decode_require_rob_entry),
	.is_store(decode_is_store),
	.rd(decode_rd),
	.jump_taken(alu_branch_taken && alu_instr_valid),
	.stall_in(),//This stall is used for RF_ROB renaming, 
	.stall_out(decode_stall_out)
    );

    D_E_Registers d_e(
	.clk(clk),
	.instruction_type(decode_instr_type_out),
	.pc(f_d_pc_out),
	.opcode(decode_opcode_out),
	.funct7(decode_funct7_out),
	.funct3(decode_funct3_out),
	.s1(decode_s1_data_out), // rs1
	.s2(decode_s2_data_out), // rs2 
	.immediate(decode_imm_out),
	.rob_id(), // salida del rob
	.stall(),
	.valid(f_d_valid_out && !decode_stall_out),
	.reset(rst || rob_exception_out || (alu_branch_taken && alu_instr_valid)),
	.instruction_type_out(d_e_instr_type_out),
	.pc_out(d_e_pc_out),
	.opcode_out(d_e_pc_out),
	.funct7_out(d_e_funct7_out),
	.funct3_out(d_e_funct3_out),
	.s1_out(d_e_s1_out), // rs1
	.s2_out(d_e_s2_out), // rs2 
	.immediate_out(d_e_imm_out),
	.rob_id_out(d_e_rob_id_out),
	.valid_out(d_e_valid_out)
    );

    // This stage has to forward its result
    alu alu(
	.pc(d_e_pc_out),
	.opcode(d_e_opcode_out),
	.funct7(d_e_funct7_out),
	.funct3(d_e_funct3_out),
	.aluIn1(d_e_s1_data_out),
	.aluIn2(d_e_s2_data_out), 
	.immediate(d_e_imm_out),
	.aluOut(alu_result),
	.newpc(alu_newpc),
	.branchTaken(branch_taken) // If instr. is not valid, ignore this and set to 0 from outside
    );

    // This stage has to forward its result
    E_M_Registers e_m(
	.clk(clk),
	.instruction_type(d_e_instr_type_out),
	.pc(d_e_pc_out),
	.funct3(d_e_funct3_out),
	.aluResult(alu_result), 
	.s2(d_e_s2_data_out),
	.stall(),
	.valid(d_e_valid_out),
	.reset(rst || rob_exception_out),
	.rob_id(d_e_rob_id_out),
	.instruction_type_out(e_m_instr_type_out),
	.pc_out(e_m_pc_out),
	.funct3_out(e_m_pc_out),
	.aluResult_out(e_m_alu_result_out), 
	.s2_out(e_m_s2_out),
	.rob_id_out(e_m_rob_id_out),
	.valid_out(e_m_valid_out)
    );

    cache_stage cache(
	.clk(clk),
	.rst(rst),
	.instruction_type(e_m_instr_type_out),
	.pc(e_m_pc_out),
	.funct3(e_m_funct3_out),
	.v_mem_addr(e_m_alu_result_out),  // alu out
	.s2(e_m_s2_out),        // store value
	.rob_id(e_m_rob_id_out),
	.valid(e_m_valid_out && (e_m_instr_type_out == `INSTR_TYPE_LOAD || e_m_instr_type_out == `INSTR_TYPE_STORE)),
	.valid_out(cache_valid_out),
	.stall_out(cache_stall_out), /* STALL output, propagate backwards */
	.read_data(cache_load_data),      // result of the load
	.mem_req(d_read),        // memory read port
	.mem_req_addr(d_addr),
	.mem_write(d_wenable),       // Memory write port
	.mem_write_addr(d_w_addr), 
	.mem_write_data(d_w_data),
	.mem_res(d_res),         // Memory response
	.mem_res_addr(d_res_addr), 
	.mem_res_data(d_res_data),
	.rob_store_permission(),
	.rob_sb_permission_rob_id()
	.exception(cache_exception),
	.v_addr_exception(cache_v_addr_exception)

    );

    M_WB_Registers m_wb(
	.clk(clk),
	.instruction_type(e_m_instr_type_out),
	.pc(e_m_pc_out),
	.exception(cache_exception),
	.virtual_addr_exception(cache_v_addr_exception),
	.load_data(cache_load_data), 
	.valid(cache_valid_out),
	.stall,
	.reset(rst || rob_exception_out),
	.rob_id(e_m_rob_id_out),
	.instruction_type_out(m_wb_instr_type_out),
	.pc_out(m_wb_pc_out),
	.exception_out(m_wb_exception_out),
	.virtual_addr_exception_out(m_wb_v_addr_exception_out),
	.load_data_out(m_wb_load_data_out), 
	.rob_id_out(m_wb_rob_id_out),
	.valid_out(m_wb_valid_out)
    );

    M2_M3_Registers m2_m3(
	.clk(clk),
	.instruction_type(e_m_instr_type_out),
	.pc(e_m_pc_out),
	.aluResult(e_m_alu_result_out),
	.valid(e_m_valid_out && (e_m_instr_type_out == `INSTR_TYPE_MUL)),
	.stall,
	.reset(rst || rob_exception_out),
	.rob_id(e_m_rob_id_out),
	.instruction_type_out(m2_m3_instr_type_out),
	.pc_out(m2_m3_pc_out),
	.aluResult_out(m2_m3_alu_result_out),
	.rob_id_out(m2_m3_rob_id_out),
	.valid_out(m2_m3_valid_out)
    );

    M3_M4_Registers m3_m4(
	.clk(clk),
	.instruction_type(m2_m3_instr_type_out),
	.pc(m2_m3_pc_out),
	.aluResult(m2_m3_alu_result_out),
	.valid(m2_m3_valid_out),
	.stall(),
	.reset(rst || rob_exception_out),
	.rob_id(m2_m3_rob_id_out),
	.instruction_type_out(m3_m4_instr_type_out),
	.pc_out(m3_m4_pc_out),
	.aluResult_out(m3_m4_alu_result_out),
	.rob_id_out(m3_m4_rob_id_out),
	.valid_out(m3_m4_valid_out)

    );

    // This stage has to forward its result
    M4_M5_Registers m4_m5(
	.clk(clk),
	.instruction_type(m3_m4_instr_type_out),
	.pc(m3_m4_pc_out),
	.aluResult(m3_m4_alu_result_out),
	.valid(m3_m4_valid_out),
	.stall(),
	.reset(rst || rob_exception_out),
	.rob_id(m3_m4_rob_id_out),
	.instruction_type_out(m4_m5_instr_type_out),
	.pc_out(m4_m5_pc_out),
	.aluResult_out(m4_m5_alu_result_out),
	.rob_id_out(m4_m5_rob_id_out),
	.valid_out(m4_m5_valid_out)
    );

    // This stage has to forward its result
    M5_WB_Registers m4_wb(
	.clk(clk),
	.instruction_type(m4_m5_instr_type_out),
	.pc(m4_m5_pc_out),
	.aluResult(m4_m5_alu_result_out),
	.valid(m4_m5_valid_out),
	.stall(),
	.reset(rst || rob_exception_out),
	.rob_id(m4_m5_rob_id_out),
	.instruction_type_out(m5_wb_instr_type_out),
	.pc_out(m5_wb_pc_out),
	.aluResult_out(m5_wb_alu_result_out),
	.rob_id_out(m5_wb_rob_id_out),
	.valid_out(m5_wb_valid_out)
    );


    rob reorder_buffer(
	clk(clk),
	rst(rst),
	/* Connections from decode */
	require_rob_entry(decode_require_rob_entry),
	is_store(decode_is_store),
	rd(decode_rd),
	assigned_rob_id(rob_assigned_rob_id),
	full(rob_full),

	/* Exceptions from decode: ITLB */
	d_exception(f_d_exception_out),
	d_pc(f_d_pc_out),
	// d_exception's rob entry comes from TAIL if we're not full (of course?)

	/* ALU write port */
	alu_result(e_m_alu_result_out),
	alu_rob_wenable(e_m_valid_out && (e_m_instr_type_out == `INSTR_TYPE_ALU)),
	alu_rob_id(e_m_rob_id_out),
	/* MEM write port */
	mem_result(m_wb_load_data_out),
	mem_rob_wenable(m_wb_valid_out),
	mem_rob_id(m_wb_rob_id_out),

	/* EXCEPTION INFO. MEM ONLY */
	mem_exception(m_wb_exception_out),
	mem_v_addr(m_wb_v_addr_exception_out),
	mem_pc(m_wb_pc_out),

	/* MUL write port */
	mul_result(m5_wb_alu_result_out),
	mul_rob_wenable(m5_wb_valid_out),
	mul_rob_id(m5_wb_rob_id_out),

	/* Bypasses */
	rs1_rob_entry(), // ADRI, cambiar decode_stage
	rs2_rob_entry(),
	bypass_s1(rob_bypass_s1),
	bypass_s2(rob_bypass_s2),
	bypass_s1_valid(rob_bypass_s1_valid),
	bypass_s2_valid(rob_bypass_s2_valid),

	/* RF and RF-ROB. Don't write into RF if exception present */
	commit(rob_commit),
	commit_rd(rob_commit_rd),
	commit_value(rob_commit_value),
	commit_rob_entry(rob_commit_rob_entry),

	/* Store Buffer */
	sb_store_permission(rob_sb_store_permission),
	sb_rob_id(rob_sb_rob_id),

	/* Exception output */
	exception(rob_exception_out),
	ex_pc(rob_ex_pc)
    );

endmodule
