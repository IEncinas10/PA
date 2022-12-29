// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "M_WB_Registers.sv"
`timescale 1 ns / 1 ns

module M_WB_Registers_testbench();

    `SVUT_SETUP

    parameter WORD_SIZE = `WORD_SIZE;
    parameter INSTR_TYPE_SZ = `INSTR_TYPE_SZ;

    logic clk;
    logic [INSTR_TYPE_SZ-1:0] instruction_type;
    logic [WORD_SIZE-1:0] pc;
    logic exception;
    logic [WORD_SIZE-1:0] virtual_addr_exception;
    logic [WORD_SIZE-1:0] load_data;
    logic valid;
    logic reset;
    logic[`ROB_ENTRY_WIDTH-1:0] rob_id;
    logic [INSTR_TYPE_SZ-1:0] instruction_type_out;
    logic [WORD_SIZE-1:0] pc_out;
    logic exception_out;
    logic [WORD_SIZE-1:0] virtual_addr_exception_out;
    logic [WORD_SIZE-1:0] load_data_out;
    logic[`ROB_ENTRY_WIDTH-1:0] rob_id_out;
    logic valid_out;

    M_WB_Registers 
    #(
    .WORD_SIZE (WORD_SIZE)
    )
    dut 
    (
    .clk                        (clk),
    .instruction_type           (instruction_type),
    .pc                         (pc),
    .exception                  (exception),
    .virtual_addr_exception     (virtual_addr_exception),
    .load_data                  (load_data),
    .valid                      (valid),
    .reset                      (reset),
    .rob_id                     (rob_id),
    .instruction_type_out       (instruction_type_out),
    .pc_out                     (pc_out),
    .exception_out              (exception_out),
    .virtual_addr_exception_out (virtual_addr_exception_out),
    .load_data_out              (load_data_out),
    .rob_id_out                 (rob_id_out),
    .valid_out                  (valid_out)
    );


    // To create a clock:
     initial clk = 0;
     always #1 clk = ~clk;

    // To dump data for visualization:
    initial begin
        $dumpfile("M_WB_Registers_testbench.vcd");
        $dumpvars(0, M_WB_Registers_testbench);
    end

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

    `UNIT_TEST("TESTCASE_RESET0")

        instruction_type = 2;
        pc = 42;
        exception = 0;
        virtual_addr_exception = 2;
        rob_id = 0;
        valid = 1;
        reset = 0;
        #2
        `ASSERT((valid_out == 1));
        `ASSERT((pc == 42));
    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_RESET1")

        instruction_type = 1;
        pc = 4;
        exception = 10;
        virtual_addr_exception = 12;
        rob_id = 3;
        valid = 1;
        reset = 1;
        #2
        `ASSERT((valid_out == 0));
        `ASSERT((pc == 4));
    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
