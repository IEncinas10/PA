// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "soc.sv"
//`timescale 1 ns / 1 ns

module Bypass_testbench();

    `SVUT_SETUP

    logic clk;
    logic rst = 0;

    soc 
    dut 
    (
    .clk (clk),
    .rst (rst)
    );


    // To create a clock:
     initial clk = 0;
     always #1 clk = ~clk;

    // To dump data for visualization:
    reg[32:0] i;
    reg[32:0] j;
    reg[127:0] xd;
    initial begin
        $dumpfile("Bypass_testbench.vcd");
        $dumpvars(0, Bypass_testbench);

        $readmemh("../../../testRisc-V/experiments/Bypass_test.hex", dut.mem.data,2048);

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

    `TEST_SUITE("TESTSUITE_EXECUTION_CODE_EXTRA_SQUARES")

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
		for(i = 0; i < 10000; i = i + 1) begin
			#1;
			if(dut.cpu.fetch.instruction_out == 32'h0000006F && dut.cpu.decode.instruction == 32'h00000000) begin
				$display("Cycles = %d", i/2);
				i = 100000;
			end
		end
		
		#500

    `UNIT_TEST_END

    `TEST_SUITE_END

	endmodule


