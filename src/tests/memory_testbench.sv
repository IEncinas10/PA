// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "memory.sv"
`timescale 1 ns / 1 ns

module memory_testbench();

    `SVUT_SETUP

    parameter MEM_DELAY_CYCLES= `MEM_DELAY_CYCLES;
    parameter NUM_BLOCKS      = `MEM_SIZE / LINE_SIZE;
    parameter LINE_SIZE       = `CACHE_LINE_SIZE;
    parameter WORD_SIZE       = `WORD_SIZE;

    logic clk;
    logic                 i_read;
    logic [WORD_SIZE-1:0] i_addr;
    logic                i_res;
    logic[LINE_SIZE-1:0] i_res_data;
    logic[WORD_SIZE-1:0] i_res_addr;
    logic                 d_read;
    logic [WORD_SIZE-1:0] d_addr;
    logic                d_res;
    logic[LINE_SIZE-1:0] d_res_data;
    logic[WORD_SIZE-1:0] d_res_addr;
    logic                 d_wenable;
    logic [LINE_SIZE-1:0] d_w_data;
    logic [WORD_SIZE-1:0] d_w_addr;

    memory 
    #(
    .MEM_DELAY_CYCLES       (MEM_DELAY_CYCLES),
    .NUM_BLOCKS      (NUM_BLOCKS),
    .LINE_SIZE       (LINE_SIZE),
    .WORD_SIZE       (WORD_SIZE)
    )
    dut 
    (
    .clk        (clk),
    .i_read     (i_read),
    .i_addr     (i_addr),
    .i_res      (i_res),
    .i_res_data (i_res_data),
    .i_res_addr (i_res_addr),
    .d_read     (d_read),
    .d_addr     (d_addr),
    .d_res      (d_res),
    .d_res_data (d_res_data),
    .d_res_addr (d_res_addr),
    .d_wenable  (d_wenable),
    .d_w_data   (d_w_data),
    .d_w_addr   (d_w_addr)
    );


    // To create a clock:
     initial clk = 0;
     always #1 clk = ~clk;

    // To dump data for visualization:
     initial begin
	 $dumpfile("memory_testbench.vcd");
	 $dumpvars(0, memory_testbench);
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

	dut.data[0] = 32'h12345678;
	dut.data[1] = 32'h12345678;
	dut.data[2] = 32'h12345678;
	dut.data[3] = 32'h12345678;
	i_read = 1;	
	i_addr = (1 << 4);

	#(2 * `MEM_DELAY_CYCLES);


	#2;



    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
