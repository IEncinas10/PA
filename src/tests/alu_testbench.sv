// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "../alu.sv"
`timescale 1 ns / 1 ns

module alu_testbench();

    `SVUT_SETUP

    parameter WORD_SIZE = `WORD_SIZE ;

    logic [31:0] pc;
    logic [6:0] opcode;
    logic [6:0] funct7;
    logic [2:0] funct3;
    logic [31:0] aluIn1;
    logic [31:0] aluIn2;
    logic [31:0] immediate;
    logic[31:0] aluOut;
    logic[31:0] newpc;
    logic branchTaken;
    

    alu 
    

    dut 
    (
   .pc               (pc),
   .opcode           (opcode),
   .funct7           (funct7),
   .funct3           (funct3),
   .aluIn1           (aluIn1),
   .aluIn2           (aluIn2),
   .immediate        (immediate),
   .aluOut           (aluOut),
   .newpc            (newpc),
   .branchTaken      (branchTaken)
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
        #2;
        
    `UNIT_TEST_END

 
    `UNIT_TEST("SUB_TEST")
        opcode = `OPCODE_ALU;
        funct7 = `SUB_FUNCT7;
        aluIn1 = 4;
        aluIn2 = 2;
        #2;
        `FAIL_IF(aluOut != 2);
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
       #2;
    `UNIT_TEST_END

    `UNIT_TEST("OPCODE_BRANCH")
       opcode = `OPCODE_BRANCH;
       aluIn1 = 4;
       aluIn2 = 3;
	   funct3 = `BEQ_FUNCT3;
       #2;
       `ASSERT((aluOut != 0));
       `ASSERT((branchTaken == 0));
       #2;
    `UNIT_TEST_END

    `UNIT_TEST("OPCODE_BRANCH2")
       pc = 400;
       opcode = `OPCODE_BRANCH;
       aluIn1 = 4;
       aluIn2 = 4;
	   funct3 = `BEQ_FUNCT3;
       immediate = 60;
       #2;
       `ASSERT((aluOut == 0));
       `ASSERT((branchTaken == 1));
       `ASSERT((newpc == 460));
       #2;
    `UNIT_TEST_END

    `UNIT_TEST("OPCODE_BNE")
       pc = 400;
       opcode = `OPCODE_BRANCH;
       aluIn1 = 4;
       aluIn2 = 4;
	   funct3 = `BNE_FUNCT3;
       immediate = 60;
       #2;
       `ASSERT((aluOut == 0));
       `ASSERT((branchTaken == 0));
       #2;
    `UNIT_TEST_END
    
	`UNIT_TEST("OPCODE_BGE")
       pc = 400;
       opcode = `OPCODE_BRANCH;
       aluIn1 = 5;
       aluIn2 = 4;
	   funct3 = `BGE_FUNCT3;
       immediate = 60;
       #2;
       `ASSERT((branchTaken == 1));
       #2;
    `UNIT_TEST_END

	`UNIT_TEST("OPCODE_BLT")
       pc = 400;
       opcode = `OPCODE_BRANCH;
       aluIn1 = 3;
       aluIn2 = 4;
	   funct3 = `BLT_FUNCT3;
       immediate = 60;
       #2;
       `ASSERT((branchTaken == 1));
       #2;
    `UNIT_TEST_END

    `UNIT_TEST("OPCODE_JUMP")
       pc = 400;
       opcode = `OPCODE_JUMP;
       aluIn1 = 6'b010010;
       aluIn2 = 6'b000000;
       immediate = 60;
       #2;
       `ASSERT((branchTaken == 1));
       `ASSERT((newpc == 460));
       #2;
    `UNIT_TEST_END

    
    `UNIT_TEST("MULTIPLICATION")
       opcode = `OPCODE_ALU;
       funct7 = `MUL_FUNCT7;

       aluIn1 = 42;
       aluIn2 = 3;
       #2;
       `ASSERT((aluOut == 126));
       #2;
    `UNIT_TEST_END

    `UNIT_TEST("MULTIPLICATION2")
       opcode = `OPCODE_ALU;
       funct7 = `MUL_FUNCT7;

       aluIn1 = 42;
       aluIn2 = -3;
       #2;
       `ASSERT((aluOut == -126));
       #2;
    `UNIT_TEST_END

   `UNIT_TEST("ADDI")
       opcode = `OPCODE_ALU_IMM;
       funct3 = `ADDI_FUNCT3;
       aluIn1 = 7;
       immediate = 3;
       #2;
       `ASSERT((aluOut == 10));

       #2;
    `UNIT_TEST_END 

    `UNIT_TEST("AUIPC")
       opcode = `OPCODE_AUIPC;
       pc = 42;

       immediate = 8;
       #2;
       `ASSERT((aluOut == 50));
       #2;
    `UNIT_TEST_END 

    `UNIT_TEST("SLLI")
       opcode = `OPCODE_ALU;
       funct3 = `SLLI_FUNCT3;
	   funct7 = `ADD_OR_AND_FUNCT7;
	   aluIn1 = 1;
	   aluIn2 = 2;

       #2;
       `ASSERT((aluOut == (1 << 2)));
       #2;
    `UNIT_TEST_END 

    `UNIT_TEST("SRLI")
       opcode = `OPCODE_ALU;
       funct3 = `SRLI_FUNCT3;
	   funct7 = `ADD_OR_AND_FUNCT7;
	   aluIn1 = 8;
	   aluIn2 = 2;

       #2;
       `ASSERT((aluOut == (8 >> 2)));
       #2;
    `UNIT_TEST_END 
    `TEST_SUITE_END

endmodule
