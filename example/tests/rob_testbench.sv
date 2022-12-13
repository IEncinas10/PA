// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "rob.sv"
`timescale 1 ns / 1 ns

module rob_testbench();

    `SVUT_SETUP

    parameter WORD_SIZE = `WORD_SIZE;
    parameter ROB_ENTRIES = 10;
    parameter INIT = 0;

    logic rst;
    logic clk;
    logic wenable;
    logic full;

    rob 
    #(
    .WORD_SIZE   (WORD_SIZE),
    .ROB_ENTRIES (ROB_ENTRIES),
    .INIT        (INIT)
    )
    dut 
    (
    .rst     (rst),
    .clk     (clk),
    .wenable (wenable),
    .full    (full)
    );


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

    `UNIT_TEST("TESTCASE_NAME")
	rst = 1;	
	#2;
	rst = 0;
	wenable = 1;
	#28;
	dut.entry_ready[1] = 1;

	#4;
	dut.entry_ready[0] = 1;
	dut.entry_ready[2] = 1;
	dut.entry_ready[3] = 1;
	dut.entry_ready[4] = 1;
	dut.entry_ready[5] = 1;
	dut.entry_ready[6] = 1;
	dut.entry_ready[7] = 1;
	dut.entry_ready[8] = 1;
	dut.entry_ready[9] = 1;

	#20;

        // Describe here the testcase scenario
        //
        // Because SVUT uses long nested macros, it's possible
        // some local variable declaration leads to compilation issue.
        // You should declare your variables after the IOs declaration to avoid that.

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
