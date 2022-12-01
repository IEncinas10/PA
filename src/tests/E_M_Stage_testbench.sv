// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "../E_M_Stage.sv"
`timescale 1 ns / 1 ns

module E_M_Stage_testbench();

    `SVUT_SETUP

    parameter WORD_SIZE = `WORD_SIZE;

    logic clk;
    logic [1:0] instruction_type;
    logic [WORD_SIZE-1:0] pc;
    logic [2:0] funct3;
    logic [WORD_SIZE-1:0] aluResult;
    logic [WORD_SIZE-1:0] s2;
    logic stall;
    logic valid;
    logic [6:0] rob_id;
    logic reset;
    logic[1:0] instruction_type_out;
    logic[WORD_SIZE-1:0] pc_out;
    logic[2:0] funct3_out;
    logic[WORD_SIZE-1:0] aluResult_out;
    logic[WORD_SIZE-1:0] s2_out;
    logic[6:0] rob_id_out;
    logic wenable;
    logic valid_out;

    E_M_Stage 
    #(
    .WORD_SIZE (WORD_SIZE)
    )
    dut 
    (
    .clk                  (clk),
    .instruction_type     (instruction_type),
    .pc                   (pc),
    .funct3               (funct3),
    .aluResult            (aluResult),
    .s2                   (s2),
    .stall                (stall),
    .valid                (valid),
    .rob_id               (rob_id),
    .reset                (reset),
    .instruction_type_out (instruction_type_out),
    .pc_out               (pc_out),
    .funct3_out           (funct3_out),
    .aluResult_out        (aluResult_out),
    .s2_out               (s2_out),
    .rob_id_out           (rob_id_out),
    .valid_out            (valid_out)
    );


    // To create a clock:
    initial clk = 0;
    always #1 clk = ~clk;

    // To dump data for visualization:
    initial begin
         $dumpfile("E_M_Stage_testbench.vcd");
         $dumpvars(0, E_M_Stage_testbench);
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

    `UNIT_TEST("TESTCASE_WENABLE_1")

        instruction_type = 1;
        pc = 1222;
        funct3 = 3;
        aluResult = 7;
        s2 = 3;
        rob_id = 2;
        stall = 0;
        valid = 1;
        reset = 0;
        #2;
        `ASSERT(dut.wenable);
        `ASSERT((instruction_type_out == instruction_type));
        `ASSERT((pc_out == pc));
        `ASSERT((funct3_out == funct3));
        `ASSERT((aluResult_out == aluResult));
        `ASSERT((s2_out == s2));
        `ASSERT(valid_out);
    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_WENABLE_2")

        instruction_type = 0;
        pc = 1282;
        funct3 = 73;
        aluResult = 77;
        s2 = 37;
        rob_id = 27;
        stall = 0;
        valid = 0;
        reset = 0;
        #2;
        `ASSERT(dut.wenable);
        `ASSERT((instruction_type_out == instruction_type));
        `ASSERT((pc_out == pc));
        `ASSERT((funct3_out == funct3));
        `ASSERT((aluResult_out == aluResult));
        `ASSERT((s2_out == s2));
        `ASSERT((valid_out == 0));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_WENABLE_3")

        instruction_type = 1;
        pc = 122;
        funct3 = 35;
        aluResult = 57;
        s2 = 53;
        rob_id = 52;
        stall = 1;
        valid = 0;
        reset = 0;
        #2;
        `ASSERT(dut.wenable);
        `ASSERT((instruction_type_out == instruction_type));
        `ASSERT((pc_out == pc));
        `ASSERT((funct3_out == funct3));
        `ASSERT((aluResult_out == aluResult));
        `ASSERT((s2_out == s2));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_WENABLE_4")

        instruction_type = 0;
        pc = 1224;
        funct3 = 34;
        aluResult = 74;
        s2 = 34;
        rob_id = 24;
        stall = 1;
        valid = 1;
        reset = 0;
        #2;
        `ASSERT((dut.wenable == 0));
        `ASSERT((instruction_type_out != instruction_type));
        `ASSERT((pc_out != pc));
        `ASSERT((funct3_out != funct3));
        `ASSERT((aluResult_out != aluResult));
        `ASSERT((s2_out != s2));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_RESET")

        instruction_type = 1;
        pc = 1222;
        funct3 = 3;
        aluResult = 7;
        s2 = 3;
        rob_id = 2;
        stall = 0;
        valid = 1;
        reset = 1;
        #2;
        `ASSERT(dut.wenable);
        `ASSERT((instruction_type_out == instruction_type));
        `ASSERT((pc_out == pc));
        `ASSERT((funct3_out == funct3));
        `ASSERT((aluResult_out == aluResult));
        `ASSERT((s2_out == s2));
        `ASSERT((valid_out == 0));
    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
