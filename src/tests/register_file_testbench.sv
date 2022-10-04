// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "../register_file.sv"
`timescale 1 ns / 1 ns

module register_file_testbench();

    `SVUT_SETUP

    parameter N = 5;
    parameter WIDTH = 32;
    parameter INI = 0;

    logic rst;
    logic clk;
    logic wenable;
    logic [N-1:0] reg_in;
    logic [WIDTH-1:0] din;
    logic [N-1:0] a;
    logic [N-1:0] b;
    logic[WIDTH-1:0] data_a;
    logic[WIDTH-1:0] data_b;
    logic[WIDTH-1:0] dout;

    register_file 
    #(
    .N     (N),
    .WIDTH (WIDTH)
    )
    dut 
    (
    .rst     (rst),
    .clk     (clk),
    .wenable (wenable),
    .reg_in  (reg_in),
    .din     (din),
    .a       (a),
    .b       (b),
    .data_a  (data_a),
    .data_b  (data_b)
    );


    // To create a clock:
     initial clk = 0;
     always #1 clk = ~clk;

    // To dump data for visualization:
     initial begin
	 $dumpfile("register_file_testbench.vcd");
	 $dumpvars(0, register_file_testbench);
     end

    // Setup time format when printing with $realtime()
    initial $timeformat(-9, 1, "ns", 8);

    task setup(msg="");
    begin
        // setup() runs when a test begins
	rst = 1;
	#2; rst = 0;
    end
    endtask

    task teardown(msg="");
    begin
        // teardown() runs when a test ends
    end
    endtask

    `TEST_SUITE("Register file")

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

    `UNIT_TEST("Set")
	wenable = 1;
	reg_in = 15;
	a = 15;
	b = 15;
	din = 2047;
	#2 
	wenable=0;
	`FAIL_IF(din != data_a);
	`FAIL_IF(din != data_b);
	#2;

        // Describe here the testcase scenario
        //
        // Because SVUT uses long nested macros, it's possible
        // some local variable declaration leads to compilation issue.
        // You should declare your variables after the IOs declaration to avoid that.

    `UNIT_TEST_END

    `UNIT_TEST("wenable")
	wenable = 0;
	reg_in = 15;
	a = 15;
	b = 15;
	din = 2047;
	#2 
	`FAIL_IF(din == data_a);
	`FAIL_IF(din == data_b);
	`FAIL_IF(data_a != 0);
	`FAIL_IF(data_b != 0);
	#2;

        // Describe here the testcase scenario
        //
        // Because SVUT uses long nested macros, it's possible
        // some local variable declaration leads to compilation issue.
        // You should declare your variables after the IOs declaration to avoid that.

    `UNIT_TEST_END

    `UNIT_TEST("Write r0")
	wenable = 1;
	reg_in = 0;
	a = 0;
	b = 0;
	din = 2047;
	#2 
	#1;
	`FAIL_IF(din == data_a);
	`FAIL_IF(din == data_b);
	`FAIL_IF(data_a != 0);
	`FAIL_IF(data_b != 0);
	#2;

        // Describe here the testcase scenario
        //
        // Because SVUT uses long nested macros, it's possible
        // some local variable declaration leads to compilation issue.
        // You should declare your variables after the IOs declaration to avoid that.

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
