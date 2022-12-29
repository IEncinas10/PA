// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "rob.sv"
`timescale 1 ns / 1 ns

module rob_testbench();

    `SVUT_SETUP

    parameter N                = `ROB_NUM_ENTRIES;
    parameter WORD_SIZE        = `WORD_SIZE;
    parameter ROB_ENTRY_WIDTH  = `ROB_ENTRY_WIDTH;
    parameter REG_INDEX_SIZE   = `ARCH_REG_INDEX_SIZE;
    parameter INIT             = 0;

    logic                        clk;
    logic                        rst;
    logic 			     require_rob_entry;
    logic			     is_store;
    logic [REG_INDEX_SIZE-1:0]  rd;
    logic[ROB_ENTRY_WIDTH-1:0] assigned_rob_id;
    logic                      full;
    logic d_exception;
    logic d_pc;
    logic [WORD_SIZE-1:0] alu_result;
    logic 		       alu_rob_wenable;
    logic 		       alu_rob_id;
    logic [WORD_SIZE-1:0] mem_result;
    logic 		       mem_rob_wenable;
    logic 		       mem_rob_id;
    logic		       mem_exception;
    logic [WORD_SIZE-1:0] mem_v_addr;
    logic [WORD_SIZE-1:0] mem_pc;
    logic [WORD_SIZE-1:0] mul_result;
    logic 		       mul_rob_wenable;
    logic 		       mul_rob_id;
    logic [ROB_ENTRY_WIDTH-1:0] rs1_rob_entry;
    logic [ROB_ENTRY_WIDTH-1:0] rs2_rob_entry;
    logic[WORD_SIZE-1:0]      bypass_s1;
    logic[WORD_SIZE-1:0]      bypass_s2;
    logic                     bypass_s1_valid;
    logic                     bypass_s2_valid;
    logic                      commit;
    logic[REG_INDEX_SIZE-1:0]  commit_rd;
    logic[WORD_SIZE-1:0]       commit_value;
    logic[ROB_ENTRY_WIDTH-1:0] commit_rob_entry;
    logic		     sb_store_permission;
    logic[ROB_ENTRY_WIDTH-1:0] sb_rob_id;
    logic exception;
    logic [WORD_SIZE-1:0] ex_pc;

    rob 
    #(
    .N (N),
    .WORD_SIZE (WORD_SIZE),
    .ROB_ENTRY_WIDTH (ROB_ENTRY_WIDTH),
    .REG_INDEX_SIZE (REG_INDEX_SIZE),
    .INIT (INIT)
    )
    dut 
    (
    .clk                 (clk),
    .rst                 (rst),
    .require_rob_entry   (require_rob_entry),
    .is_store            (is_store),
    .rd                  (rd),
    .assigned_rob_id      (assigned_rob_id),
    .full                (full),
    .d_exception         (d_exception),
    .d_pc                (d_pc),
    .alu_result          (alu_result),
    .alu_rob_wenable     (alu_rob_wenable),
    .alu_rob_id          (alu_rob_id),
    .mem_result          (mem_result),
    .mem_rob_wenable     (mem_rob_wenable),
    .mem_rob_id          (mem_rob_id),
    .mem_exception       (mem_exception),
    .mem_v_addr          (mem_v_addr),
    .mem_pc              (mem_pc),
    .mul_result          (mul_result),
    .mul_rob_wenable     (mul_rob_wenable),
    .mul_rob_id          (mul_rob_id),
    .rs1_rob_entry       (rs1_rob_entry),
    .rs2_rob_entry       (rs2_rob_entry),
    .bypass_s1           (bypass_s1),
    .bypass_s2           (bypass_s2),
    .bypass_s1_valid     (bypass_s1_valid),
    .bypass_s2_valid     (bypass_s2_valid),
    .commit              (commit),
    .commit_rd           (commit_rd),
    .commit_value        (commit_value),
    .commit_rob_entry    (commit_rob_entry),
    .sb_store_permission (sb_store_permission),
    .sb_rob_id           (sb_rob_id),
    .exception      (exception),
    .ex_pc          (ex_pc)
    );


    integer i;

    // To create a clock:
    initial clk = 0;
    always #1 clk = ~clk;

    // To dump data for visualization:
    initial begin
        $dumpfile("rob_testbench.vcd");
        $dumpvars(0, rob_testbench);
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

    `UNIT_TEST("FULL / drain")

	rst = 1;
	#2;
	rst = 0;
	require_rob_entry = 1;
	is_store = 0;
	rd = 1;

	d_exception = 0;
	d_pc = 0;
	
	alu_rob_wenable = 0;
	mem_rob_wenable = 0;
	mul_rob_wenable = 0;
	mem_exception = 0;

	rs1_rob_entry = 0;
	rs2_rob_entry = 0;
	#(2*`ROB_NUM_ENTRIES);

	`FAIL_IF_NOT(dut.full);

	for(i = 0; i < `ROB_NUM_ENTRIES; i = i + 1) begin
	    dut.readys[i] = 1;
	end
	require_rob_entry = 0;

	#(2*`ROB_NUM_ENTRIES);
	`FAIL_IF(dut.entries != 0);
    `UNIT_TEST_END

    `UNIT_TEST("FULL / stall / drain")

	rst = 1;
	#2;
	rst = 0;
	require_rob_entry = 1;
	is_store = 0;
	rd = 1;

	d_exception = 0;
	d_pc = 0;
	
	alu_rob_wenable = 0;
	mem_rob_wenable = 0;
	mul_rob_wenable = 0;
	mem_exception = 0;

	rs1_rob_entry = 0;
	rs2_rob_entry = 0;
	#(2*`ROB_NUM_ENTRIES);

	`FAIL_IF_NOT(dut.full);

	for(i = 1; i < `ROB_NUM_ENTRIES; i = i + 1) begin
	    dut.readys[i] = 1;
	end
	require_rob_entry = 0;

	#2;
	`FAIL_IF_NOT(dut.full);

	dut.readys[0] = 1;
	#(2*`ROB_NUM_ENTRIES);

	`FAIL_IF(dut.entries != 0);
    `UNIT_TEST_END
    `UNIT_TEST("ALU writeback")

	rst = 1;
	#2;
	rst = 0;
	require_rob_entry = 1;
	is_store = 1;
	rd = 1;

	d_exception = 0;
	d_pc = 0;
	
	alu_rob_wenable = 0;
	mem_rob_wenable = 0;
	mul_rob_wenable = 0;
	mem_exception = 0;

	rs1_rob_entry = 0;
	rs2_rob_entry = 0;
	#2;
	`FAIL_IF_NOT((dut.entries == 1));
	`FAIL_IF_NOT((dut.bypass_s1_valid == 0));
	`FAIL_IF_NOT((dut.bypass_s2_valid == 0));
	require_rob_entry = 0;
	alu_rob_wenable = 1;
	alu_result = 15;
	alu_rob_id = 0;
	#2;
	`FAIL_IF_NOT(dut.bypass_s1_valid);
	`FAIL_IF_NOT(dut.bypass_s2_valid);
	`FAIL_IF((dut.bypass_s2 != 15));
	`FAIL_IF((dut.bypass_s1 != 15));

	`FAIL_IF_NOT((dut.commit_rd == 1));
	`FAIL_IF_NOT((dut.commit));
	`FAIL_IF_NOT((dut.commit_rob_entry == 0));
	`FAIL_IF_NOT((dut.commit_value == 15));

	`FAIL_IF_NOT((dut.sb_store_permission));
	`FAIL_IF_NOT((dut.sb_rob_id == 0));

	`FAIL_IF((dut.entries != 1));
	`FAIL_IF_NOT((dut.values[0] == 15));


	

	#2;
	`FAIL_IF_NOT(dut.entries == 0);

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
