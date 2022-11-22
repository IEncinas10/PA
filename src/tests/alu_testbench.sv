// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "../alu.sv"
`timescale 1 ns / 1 ns

module alu_testbench();

    `SVUT_SETUP


    logic [6:0] opcode;
    logic [6:0] funct7;
    logic [2:0] funct3;
    logic [31:0] aluIn1;
    logic [31:0] aluIn2;
    logic[31:0] aluOut;
    logic zero;
    logic[31:0] exceptionCode;

    alu 
    dut 
    (
    .opcode         (opcode),
    .funct7         (funct7),
    .funct3         (funct3),
    .aluIn1         (aluIn1),
    .aluIn2         (aluIn2),
    .aluOut         (aluOut),
    .zero           (zero),
    .exceptionCode  (exceptionCode)
    );


    // To create a clock:
    //initial aclk = 0;
    //always #1 aclk = ~aclk;

    // To dump data for visualization:
    initial begin
        $dumpfile("alu_testbench.vcd");
        $dumpvars(0, alu_testbench);
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

    `TEST_SUITE("TESTSUITE_ALU")

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

    `UNIT_TEST("ADD_TEST")
        opcode = `OPCODE_ALU;
        funct7 = `ADD_OR_AND_FUNCT7;
        funct3 = `ADD_FUNCT3;
        aluIn1 = 23;
        aluIn2 = 7;
        #2;
        `FAIL_IF(aluOut != 30);
       `ASSERT(zero == 0);
        #2;
        
    `UNIT_TEST_END

 
    `UNIT_TEST("SUB_TEST")
        opcode = `OPCODE_ALU;
        funct7 = `SUB_FUNCT7;
        aluIn1 = 4;
        aluIn2 = 2;
        #2;
        `FAIL_IF(aluOut != 2);
       `ASSERT((zero == 0));
        #2;
        
    `UNIT_TEST_END

    `UNIT_TEST("OPCODE_OUT_OF_ORDER_TEST")
       opcode = 7'b1100001;
       aluIn1 = 10;
       aluIn2 = 9;
       #2;
       `ASSERT((exceptionCode == 32'b1));
       `ASSERT((zero == 0));
       #2;
    `UNIT_TEST_END

    `UNIT_TEST("OPCODE_OR1")
       opcode = `OPCODE_ALU;
       funct7 = `ADD_OR_AND_FUNCT7;
       funct3 = `OR_FUNCT3;
       aluIn1 = 6'b001011;
       aluIn2 = 6'b010010;
       #2;
       `ASSERT((aluOut == 6'b011011));
       `ASSERT((zero == 0));
       `ASSERT((exceptionCode == 0));
       #2;
    `UNIT_TEST_END

    `UNIT_TEST("OPCODE_OR2")
       opcode = `OPCODE_ALU;
       funct7 = `ADD_OR_AND_FUNCT7;
       funct3 = `OR_FUNCT3;
       aluIn1 = 1'b1;
       aluIn2 = 1'b0;
       #2;
       `ASSERT((aluOut == 1));
       `ASSERT((exceptionCode == 0));
       `ASSERT((zero == 0));
       `FAIL_IF(exceptionCode == 1);
       #2;
    `UNIT_TEST_END

    `UNIT_TEST("OPCODE_AND")
       opcode = `OPCODE_ALU;
       funct7 = `ADD_OR_AND_FUNCT7;
       funct3 = `AND_FUNCT3;
       aluIn1 = 6'b010010;
       aluIn2 = 6'b001110;
       #2;
       `ASSERT((aluOut == 6'b000010));
       `ASSERT((exceptionCode == 0));
       `ASSERT((zero == 0));
       `FAIL_IF(exceptionCode == 1);
       #2;
    `UNIT_TEST_END

    `UNIT_TEST("OPCODE_BRANCH")
       opcode = `OPCODE_BRANCH;
       aluIn1 = 6'b000010;
       aluIn2 = 6'b001010;
       #2;
       `ASSERT((aluOut == 6'b001100));
       `ASSERT((exceptionCode == 0));
       `ASSERT((zero == 0));
       `FAIL_IF(exceptionCode == 1);
       #2;
    `UNIT_TEST_END

    `UNIT_TEST("OPCODE_BRANCH2")
       opcode = `OPCODE_BRANCH;
       aluIn1 = 6'b010010;
       aluIn2 = 6'b010010;
       #2;
       `FAIL_IF(aluOut != 6'b100100);
       `FAIL_IF(zero != 1);
       `FAIL_IF(exceptionCode == 1);
       #2;
    `UNIT_TEST_END

    `UNIT_TEST("OPCODE_JUMP")
       opcode = `OPCODE_JUMP;
       aluIn1 = 6'b010010;
       aluIn2 = 6'b000000;
       #2;
       `ASSERT((aluOut == 6'b010010));
       `ASSERT((zero == 0));
       `ASSERT((exceptionCode == 0));
       `FAIL_IF(exceptionCode == 1);
       #2;
    `UNIT_TEST_END

    
    `UNIT_TEST("MULTIPLICATION")
       opcode = `OPCODE_ALU;
       funct7 = `MUL_FUNCT7;

       aluIn1 = 42;
       aluIn2 = 3;
       #2;
       `ASSERT((aluOut == 126));
       `ASSERT((zero == 0));
       `ASSERT((exceptionCode == 0));
       #2;
    `UNIT_TEST_END

    `UNIT_TEST("MULTIPLICATION2")
       opcode = `OPCODE_ALU;
       funct7 = `MUL_FUNCT7;

       aluIn1 = 42;
       aluIn2 = -3;
       #2;
       `ASSERT((aluOut == -126));
       `ASSERT((zero == 0));
       `ASSERT((exceptionCode == 0));
       #2;
    `UNIT_TEST_END

   `UNIT_TEST("ADDI")
       opcode = `OPCODE_ALU_IMM;
       funct3 = `ADDI_FUNCT3;
       aluIn1 = 7;
       aluIn2 = 3;
       #2;
       `ASSERT((aluOut == 10));
       `ASSERT((zero == 0));
       `ASSERT((exceptionCode == 0));
       `FAIL_IF(exceptionCode == 1);
       #2;
    `UNIT_TEST_END 


    `TEST_SUITE_END

endmodule
