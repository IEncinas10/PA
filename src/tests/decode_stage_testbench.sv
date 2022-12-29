// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "decode_stage.sv"
`timescale 1 ns / 100 ps

module decode_stage_testbench();

    `SVUT_SETUP

    parameter WORD_SIZE = `WORD_SIZE;

    logic clk;
    logic rst;
    logic [`WORD_SIZE-1:0] instruction;
    logic valid;
    logic [WORD_SIZE-1:0] rob_s1_data;
    logic [WORD_SIZE-1:0] rob_s2_data;
    logic rob_s1_valid;
    logic rob_s2_valid;
    logic [WORD_SIZE-1:0]       alu_data;
    logic [`ROB_ENTRY_WIDTH-1:0] alu_rob_id;
    logic alu_bypass_enable;
    logic [WORD_SIZE-1:0]       alu_wb_data;
    logic [`ROB_ENTRY_WIDTH-1:0] alu_wb_rob_id;
    logic alu_wb_bypass_enable;
    logic [WORD_SIZE-1:0]       mem_data;
    logic [`ROB_ENTRY_WIDTH-1:0] mem_rob_id;
    logic mem_bypass_enable;
    logic [WORD_SIZE-1:0]       mem_wb_data;
    logic [`ROB_ENTRY_WIDTH-1:0] mem_wb_rob_id;
    logic mem_wb_bypass_enable;
    logic [WORD_SIZE-1:0]       mul_data;
    logic [`ROB_ENTRY_WIDTH-1:0] mul_rob_id;
    logic mul_bypass_enable;
    logic [WORD_SIZE-1:0]       mul_wb_data;
    logic [`ROB_ENTRY_WIDTH-1:0] mul_wb_rob_id;
    logic mul_wb_bypass_enable;
    logic [WORD_SIZE-1:0] s1_data_out;
    logic [WORD_SIZE-1:0] s2_data_out;
    logic [2:0] funct3_out;
    logic [6:0] funct7_out;
    logic [6:0] opcode_out;
    logic [WORD_SIZE-1:0] imm_out;
    logic [`INSTR_TYPE_SZ-1:0] instr_type_out;
    logic commit;
    logic [`ARCH_REG_INDEX_SIZE-1:0] commit_rd;
    logic [`ROB_ENTRY_WIDTH-1:0] commit_rob_id;
    logic [WORD_SIZE-1:0] din;
    logic [`ROB_ENTRY_WIDTH-1:0] assigned_rob_id;
    logic full;
    logic require_rob_entry;
    logic is_store;
    logic [`ARCH_REG_INDEX_SIZE-1:0] rd;
    logic jump_taken;
    logic stall_in;
    logic stall_out;

    decode_stage 
    #(
    .WORD_SIZE (WORD_SIZE)
    )
    dut 
    (
    .clk                  (clk),
    .rst                  (rst),
    .instruction          (instruction),
    .valid                (valid),
    .rob_s1_data          (rob_s1_data),
    .rob_s2_data          (rob_s2_data),
    .rob_s1_valid         (rob_s1_valid),
    .rob_s2_valid         (rob_s2_valid),
    .alu_data             (alu_data),
    .alu_rob_id           (alu_rob_id),
    .alu_bypass_enable    (alu_bypass_enable),
    .alu_wb_data          (alu_wb_data),
    .alu_wb_rob_id        (alu_wb_rob_id),
    .alu_wb_bypass_enable (alu_wb_bypass_enable),
    .mem_data             (mem_data),
    .mem_rob_id           (mem_rob_id),
    .mem_bypass_enable    (mem_bypass_enable),
    .mem_wb_data          (mem_wb_data),
    .mem_wb_rob_id        (mem_wb_rob_id),
    .mem_wb_bypass_enable (mem_wb_bypass_enable),
    .mul_data             (mul_data),
    .mul_rob_id           (mul_rob_id),
    .mul_bypass_enable    (mul_bypass_enable),
    .mul_wb_data          (mul_wb_data),
    .mul_wb_rob_id        (mul_wb_rob_id),
    .mul_wb_bypass_enable (mul_wb_bypass_enable),
    .s1_data_out          (s1_data_out),
    .s2_data_out          (s2_data_out),
    .funct3_out           (funct3_out),
    .funct7_out           (funct7_out),
    .opcode_out           (opcode_out),
    .imm_out              (imm_out),
    .instr_type_out       (instr_type_out),
    .commit               (commit),
    .commit_rd            (commit_rd),
    .commit_rob_id        (commit_rob_id),
    .din                  (din),
    .assigned_rob_id	  (assigned_rob_id),
    .full                 (full),
    .require_rob_entry    (require_rob_entry),
    .is_store             (is_store),
    .rd                   (rd),
    .jump_taken           (jump_taken),
    .stall_in             (stall_in),
    .stall_out            (stall_out)
    );


    // To create a clock:
    // initial aclk = 0;
    // always #2 aclk = ~aclk;

    // To dump data for visualization:
    // initial begin
    //     $dumpfile("decode_stage_testbench.vcd");
    //     $dumpvars(0, decode_stage_testbench);
    // end

    // Setup time format when printing with $realtime()
    initial $timeformat(-9, 1, "ns", 8);

    task setup(msg="");
    begin
        // setup() runs when a test begins
    end
    endtask

    task teardown(msg="");
    begin
        // teardown() runs when a test ends
    end
    endtask

    `TEST_SUITE("TESTSUITE_NAME")

    //  Available macros:"
    //
    //    - `MSG("message"):       Print a raw white message
    //    - `INFO("message"):      Print a blue message with INFO: prefix
    //    - `SUCCESS("message"):   Print a green message if SUCCESS: prefix
    //    - `WARNING("message"):   Print an orange message with WARNING: prefix and increment warning counter
    //    - `CRITICAL("message"):  Print a purple message with CRITICAL: prefix and increment critical counter
    //    - `ERROR("message"):     Print a red message with ERROR: prefix and increment error counter
    //
    //    - `FAIL_IF(aSignal):                 Increment error counter if evaluaton is true
    //    - `FAIL_IF_NOT(aSignal):             Increment error coutner if evaluation is false
    //    - `FAIL_IF_EQUAL(aSignal, 23):       Increment error counter if evaluation is equal
    //    - `FAIL_IF_NOT_EQUAL(aSignal, 45):   Increment error counter if evaluation is not equal
    //    - `ASSERT(aSignal):                  Increment error counter if evaluation is not true
    //    - `ASSERT((aSignal == 0)):           Increment error counter if evaluation is not true
    //
    //  Available flag:
    //
    //    - `LAST_STATUS: tied to 1 is last macro did experience a failure, else tied to 0

    `UNIT_TEST("TESTCASE_NAME")

        // Describe here the testcase scenario
        //
        // Because SVUT uses long nested macros, it's possible
        // some local variable declaration leads to compilation issue.
        // You should declare your variables after the IOs declaration to avoid that.

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
