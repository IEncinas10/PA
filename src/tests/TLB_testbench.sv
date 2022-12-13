// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "../TLB.sv"
`timescale 1 ns / 1 ns

module TLB_testbench();

    `SVUT_SETUP

    parameter N = `TLB_ENTRIES;
    parameter WIDTH = `PAGE_WIDTH;

    logic clk;
    logic [WIDTH-1:0] virtual_page;
    logic[WIDTH-1:0] physical_page_out;
    logic hit;
    logic exception;

    TLB 
    #(
    .N     (N),
    .WIDTH (WIDTH)
    )
    dut 
    (
    .clk               (clk),
    .virtual_page      (virtual_page),
    .physical_page_out (physical_page_out),
    .hit           (hit),
    .exception (exception)
    );


    // To create a clock:
    initial clk = 0;
    always #1 clk = ~clk;

    // To dump data for visualization:
     initial begin
        $dumpfile("TLB_testbench.vcd");
        $dumpvars(0, TLB_testbench);
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

    `UNIT_TEST("TESTCASE_TLB_MISS")
        virtual_page = 2;
        `ASSERT((dut.hit==0));
        #2
    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_TLB_MISS_2")

        virtual_page = 6;
	#0.00000001
        `ASSERT((dut.hit == 0));
	#2;
    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_TLB_HIT")

	#1;
        virtual_page = 2;
        #(2 * `TLB_DELAY)
	#0.01;
        `ASSERT((dut.hit==1));
        `ASSERT((physical_page_out == virtual_page + 1));
        #2
    `UNIT_TEST_END

    `UNIT_TEST("Exception")

    // Page 0 raises an exception, like dereferencing NULL
	#2;
        virtual_page = 0;
        #(2 * `TLB_DELAY)
	#0.01;
        `ASSERT((exception == 1));
    `UNIT_TEST_END
    

    `TEST_SUITE_END

endmodule
