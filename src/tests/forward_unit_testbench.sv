// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "forward_unit.sv"
`timescale 1 ns / 1 ns

module forward_unit_testbench();

    `SVUT_SETUP

    parameter WORD_SIZE = `WORD_SIZE;
    parameter ROB_ENTRY_WIDTH = `ROB_ENTRY_WIDTH;

    logic [WORD_SIZE-1:0] rf_s1_data;
    logic [WORD_SIZE-1:0] rf_s2_data;
    logic [WORD_SIZE-1:0] rob_s1_data;
    logic [WORD_SIZE-1:0] rob_s2_data;
    logic rob_s1_valid;
    logic rob_s2_valid;
    logic [ROB_ENTRY_WIDTH-1:0] rs1_rob_entry;
    logic [ROB_ENTRY_WIDTH-1:0] rs2_rob_entry;
    logic rs1_rob_entry_valid;
    logic rs2_rob_entry_valid;
    logic [WORD_SIZE-1:0]       alu_data;
    logic [ROB_ENTRY_WIDTH-1:0] alu_rob_id;
    logic alu_bypass_enable;
    logic [WORD_SIZE-1:0]       alu_wb_data;
    logic [ROB_ENTRY_WIDTH-1:0] alu_wb_rob_id;
    logic alu_wb_bypass_enable;
    logic [WORD_SIZE-1:0]       mem_data;
    logic [ROB_ENTRY_WIDTH-1:0] mem_rob_id;
    logic mem_bypass_enable;
    logic [WORD_SIZE-1:0]       mem_wb_data;
    logic [ROB_ENTRY_WIDTH-1:0] mem_wb_rob_id;
    logic mem_wb_bypass_enable;
    logic [WORD_SIZE-1:0]       mul_data;
    logic [ROB_ENTRY_WIDTH-1:0] mul_rob_id;
    logic mul_bypass_enable;
    logic [WORD_SIZE-1:0]       mul_wb_data;
    logic [ROB_ENTRY_WIDTH-1:0] mul_wb_rob_id;
    logic mul_wb_bypass_enable;
    logic [WORD_SIZE-1:0] s1_data;
    logic [WORD_SIZE-1:0] s2_data;
    logic stall;

    forward_unit 
    #(
    .WORD_SIZE       (WORD_SIZE),
    .ROB_ENTRY_WIDTH (ROB_ENTRY_WIDTH)
    )
    dut 
    (
    .rf_s1_data           (rf_s1_data),
    .rf_s2_data           (rf_s2_data),
    .rob_s1_data          (rob_s1_data),
    .rob_s2_data          (rob_s2_data),
    .rob_s1_valid         (rob_s1_valid),
    .rob_s2_valid         (rob_s2_valid),
    .rs1_rob_entry        (rs1_rob_entry),
    .rs2_rob_entry        (rs2_rob_entry),
    .rs1_rob_entry_valid  (rs1_rob_entry_valid),
    .rs2_rob_entry_valid  (rs2_rob_entry_valid),
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
    .s1_data              (s1_data),
    .s2_data              (s2_data),
    .stall                (stall)
    );


    // To create a clock:
    //initial clk = 0;
    //always #2 clk = ~clk;

    // To dump data for visualization:
    initial begin
        $dumpfile("forward_unit_testbench.vcd");
        $dumpvars(0, forward_unit_testbench);
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

    `UNIT_TEST("TESTCASE_1")
		rf_s1_data = 1;
		rf_s2_data = 2;

		rob_s1_data = 3;
		rob_s1_valid = 1;
		
		rob_s2_data = 4;
		rob_s2_valid = 1;

		rs1_rob_entry = 1;
		rs2_rob_entry = 2;
		rs1_rob_entry_valid = 1;
		rs2_rob_entry_valid = 0;

		#2

		`ASSERT((!stall));
		`ASSERT((s1_data == rob_s1_data));
		`ASSERT((s2_data == rf_s2_data));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_2")
		rf_s1_data = 1;
		rf_s2_data = 2;

		rob_s1_data = 3;
		rob_s1_valid = 1;
		
		rob_s2_data = 4;
		rob_s2_valid = 1;

		alu_data = 5;
		alu_rob_id = 1;
		alu_bypass_enable = 1;

		rs1_rob_entry = 1;
		rs2_rob_entry = 2;
		rs1_rob_entry_valid = 1;
		rs2_rob_entry_valid = 1;

		#2

		`ASSERT((!stall));
		`ASSERT((s1_data == alu_data));
		`ASSERT((s2_data == rob_s2_data));

    `UNIT_TEST_END


    `UNIT_TEST("TESTCASE_3")
		rf_s1_data = 1;
		rf_s2_data = 2;

		rob_s1_data = 3;
		rob_s1_valid = 1;
		
		rob_s2_data = 4;
		rob_s2_valid = 1;

		alu_data = 5;
		alu_rob_id = 1;
		alu_bypass_enable = 1;

		mul_wb_data = 6;
		mul_wb_rob_id = 2;
		mul_wb_bypass_enable = 1;

		rs1_rob_entry = 1;
		rs2_rob_entry = 2;
		rs1_rob_entry_valid = 1;
		rs2_rob_entry_valid = 1;

		#2

		`ASSERT((!stall));
		`ASSERT((s1_data == alu_data));
		`ASSERT((s2_data == mul_wb_data));

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
