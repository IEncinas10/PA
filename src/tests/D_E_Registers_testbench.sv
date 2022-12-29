// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "../D_E_Registers.sv"
`timescale 1 ns / 1 ns

module D_E_Registers_testbench();

    `SVUT_SETUP

    parameter WORD_SIZE = `WORD_SIZE;
    parameter INSTR_TYPE_SZ = `INSTR_TYPE_SZ;

    logic clk;
    logic [INSTR_TYPE_SZ-1:0] instruction_type;
    logic [WORD_SIZE-1:0] pc;
    logic [6:0] opcode;
    logic [6:0] funct7;
    logic [2:0] funct3;
    logic [WORD_SIZE-1:0] s1;
    logic [WORD_SIZE-1:0] s2;
    logic [WORD_SIZE-1:0] immediate;
    logic stall;
    logic valid;
    logic reset;
    logic [INSTR_TYPE_SZ-1:0] instruction_type_out;
    logic[WORD_SIZE-1:0] pc_out;
    logic[6:0] opcode_out;
    logic[6:0] funct7_out;
    logic[2:0] funct3_out;
    logic[WORD_SIZE-1:0] s1_out;
    logic[WORD_SIZE-1:0] s2_out;
    logic[WORD_SIZE-1:0] immediate_out;
    logic wenable;
    logic valid_out;
    logic[`ROB_ENTRY_WIDTH-1:0] rob_id;
    logic[`ROB_ENTRY_WIDTH-1:0] rob_id_out;

    D_E_Registers 
    #(
    .WORD_SIZE (WORD_SIZE)
    )
    dut 
    (
    .clk                  (clk),
    .instruction_type     (instruction_type),
    .pc                   (pc),
    .opcode               (opcode),
    .funct7               (funct7),
    .funct3               (funct3),
    .s1                   (s1),
    .s2                   (s2),
    .immediate            (immediate),
    .rob_id               (rob_id),
    .stall                (stall),
    .valid                (valid),
    .reset                (reset),
    .instruction_type_out (instruction_type_out),
    .pc_out               (pc_out),
    .opcode_out           (opcode_out),
    .funct7_out           (funct7_out),
    .funct3_out           (funct3_out),
    .s1_out               (s1_out),
    .s2_out               (s2_out),
    .immediate_out        (immediate_out),
    .rob_id_out           (rob_id_out),
    .valid_out            (valid_out)
    );


    // To create a clock:
     initial clk = 0;
     always #1 clk = ~clk;

    // To dump data for visualization:
     initial begin
         $dumpfile("D_E_Registers_testbench.vcd");
         $dumpvars(0, D_E_Registers_testbench);
     end

    // Setup time format when printing with $realtime()
    //initial $timeformat(-9, 1, "ns", 8);

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

    `TEST_SUITE("TESTSUITE_D_E")

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

    `UNIT_TEST("TESTCASE_WENABLE_TRUE")
        opcode = `OPCODE_ALU;
        funct7 = `ADD_OR_AND_FUNCT7;
        funct3 = `ADD_FUNCT3;
        s1 = 23;
        s2 = 7;
        instruction_type = 0;
        immediate = 89;
        stall = 0;
        valid = 1;
        reset = 0;
        #2;
        `ASSERT((opcode_out == opcode));
        `ASSERT((funct7_out == funct7));
        `ASSERT((funct3_out == funct3));
        `ASSERT((s1_out == s1));
        `ASSERT((s2_out == s2));
        `ASSERT((instruction_type_out == instruction_type));
        `ASSERT((immediate_out == immediate));
        `ASSERT(dut.wenable);
        `ASSERT(valid_out);
        #2;

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_WENABLE_FALSE")
        stall = 1;
        valid = 1;
        opcode = `OPCODE_ALU_IMM;
        funct7 = `MUL_FUNCT7;
        funct3 = `AND_FUNCT3;
        s1 = 212;
        s2 = 73;
        instruction_type = 1;
        immediate = 879;
        reset = 0;
        #2;
        `ASSERT((opcode_out != opcode));
        `ASSERT((funct7_out != funct7));
        `ASSERT((funct3_out != funct3));
        `ASSERT((s1_out != s1));
        `ASSERT((s2_out != s2));
        `ASSERT((instruction_type_out != instruction_type));
        `ASSERT((immediate_out != immediate));
        `ASSERT((dut.wenable == 0));
        #2;

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_WENABLE_2")
        stall = 0;
        valid = 0;
        opcode = `OPCODE_ALU_IMM;
        funct7 = `MUL_FUNCT7;
        funct3 = `AND_FUNCT3;
        s1 = 212;
        s2 = 73;
        instruction_type = 1;
        immediate = 879;
        reset = 0;
        #2;
        `ASSERT((opcode_out == opcode));
        `ASSERT((funct7_out == funct7));
        `ASSERT((funct3_out == funct3));
        `ASSERT((s1_out == s1));
        `ASSERT((s2_out == s2));
        `ASSERT((instruction_type_out == instruction_type));
        `ASSERT((immediate_out == immediate));
        `ASSERT(dut.wenable);
        #2;

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_WENABLE_3")
        stall = 1;
        valid = 0;
        opcode = `OPCODE_ALU_IMM;
        funct7 = `MUL_FUNCT7;
        funct3 = `AND_FUNCT3;
        s1 = 212;
        s2 = 73;
        instruction_type = 1;
        immediate = 879;
        reset = 0;
        #2;
        `ASSERT((opcode_out == opcode));
        `ASSERT((funct7_out == funct7));
        `ASSERT((funct3_out == funct3));
        `ASSERT((s1_out == s1));
        `ASSERT((s2_out == s2));
        `ASSERT((instruction_type_out == instruction_type));
        `ASSERT((immediate_out == immediate));
        `ASSERT(dut.wenable);
        #2;

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_RESET")
        opcode = `OPCODE_ALU;
        funct7 = `ADD_OR_AND_FUNCT7;
        funct3 = `ADD_FUNCT3;
        s1 = 23;
        s2 = 7;
        instruction_type = 0;
        immediate = 89;
        stall = 0;
        valid = 1;
        reset = 1;
        #2;
        `ASSERT((opcode_out == opcode));
        `ASSERT((funct7_out == funct7));
        `ASSERT((funct3_out == funct3));
        `ASSERT((s1_out == s1));
        `ASSERT((s2_out == s2));
        `ASSERT((instruction_type_out == instruction_type));
        `ASSERT((immediate_out == immediate));
        `ASSERT(dut.wenable);
        `ASSERT((valid_out == 0));
        #2;

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
