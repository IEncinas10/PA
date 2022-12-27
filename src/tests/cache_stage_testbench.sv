// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "cache_stage.sv"
`timescale 1 ns / 100 ps

module cache_stage_testbench();

    `SVUT_SETUP

    parameter WORD_SIZE = `WORD_SIZE;
    parameter INSTR_TYPE_SZ = `INSTR_TYPE_SZ;
    parameter LINE_SIZE        = `CACHE_LINE_SIZE;
    parameter ROB_ENTRY_WIDTH = `ROB_ENTRY_WIDTH;

    logic clk;
    logic rst;
    logic [INSTR_TYPE_SZ-1:0] instruction_type_out;
    logic [WORD_SIZE-1:0] pc;
    logic [2:0] funct3;
    logic [WORD_SIZE-1:0] v_mem_addr;
    logic [WORD_SIZE-1:0] s2;
    logic [ROB_ENTRY_WIDTH-1:0] rob_id;
    logic valid;
    logic stall_in;
    logic [WORD_SIZE-1:0] read_data;
    logic mem_req;
    logic [WORD_SIZE-1:0] mem_req_addr;
    logic	       mem_write;
    logic[WORD_SIZE-1:0] mem_write_addr;
    logic[LINE_SIZE-1:0] mem_write_data;
    logic mem_res;
    logic [WORD_SIZE-1:0] mem_res_addr;
    logic [LINE_SIZE-1:0] mem_res_data;
    logic                       rob_store_permission;
    logic [ROB_ENTRY_WIDTH-1:0] rob_sb_permission_rob_id;
    logic stall_out /* STALL  */;
    logic valid_out;

    cache_stage 
    #(
    .WORD_SIZE       (WORD_SIZE),
    .INSTR_TYPE_SZ   (INSTR_TYPE_SZ),
    .LINE_SIZE       (LINE_SIZE),
    .ROB_ENTRY_WIDTH (ROB_ENTRY_WIDTH)
    )
    dut 
    (
    .clk                      (clk),
    .rst                      (rst),
    .instruction_type_out     (instruction_type_out),
    .pc                       (pc),
    .funct3                   (funct3),
    .v_mem_addr               (v_mem_addr),
    .s2                       (s2),
    .rob_id                   (rob_id),
    .valid                    (valid),
    .stall_in                 (stall_in),
    .read_data                (read_data),
    .mem_req                  (mem_req),
    .mem_req_addr             (mem_req_addr),
    .mem_write                (mem_write),
    .mem_write_addr           (mem_write_addr),
    .mem_write_data           (mem_write_data),
    .mem_res                  (mem_res),
    .mem_res_addr             (mem_res_addr),
    .mem_res_data             (mem_res_data),
    .rob_store_permission     (rob_store_permission),
    .rob_sb_permission_rob_id (rob_sb_permission_rob_id),
    .stall_out           (stall_out),
    .valid_out           (valid_out)
    );


    // To create a clock:
    // initial aclk = 0;
    // always #2 aclk = ~aclk;

    // To dump data for visualization:
    // initial begin
    //     $dumpfile("cache_stage_testbench.vcd");
    //     $dumpvars(0, cache_stage_testbench);
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
