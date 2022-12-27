// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "cache.sv"
`timescale 1 ns / 1 ns

module cache_testbench();

    `SVUT_SETUP

    parameter N                = `CACHE_N_LINES;
    parameter LINE_SIZE        = `CACHE_LINE_SIZE;
    parameter WORD_SIZE        = `WORD_SIZE;
    parameter ASSOCIATIVITY    = `CACHE_ASSOCIATIVITY;
    parameter TAG_SIZE         = `TAG_SIZE;
    parameter SB_ENTRIES       = `STORE_BUFFER_ENTRIES;
    parameter SIZE_WRITE_WIDTH = `SIZE_WRITE_WIDTH;
    parameter OFFSET_SIZE      = `OFFSET_SIZE;
    parameter SET_SIZE         = $clog2(`CACHE_N_LINES - `CACHE_ASSOCIATIVITY);
    parameter INIT             = 0;

    logic clk;
    logic rst;
    logic                        valid;
    logic [WORD_SIZE-1:0]        addr;
    logic [SIZE_WRITE_WIDTH-1:0] load_size;
    logic                        store;
    logic                       hit;
    logic[WORD_SIZE-1:0] read_data;
    logic                mem_req;
    logic[WORD_SIZE-1:0] mem_req_addr;
    logic                 mem_res;
    logic [WORD_SIZE-1:0] mem_res_addr;
    logic [LINE_SIZE-1:0] mem_res_data;
    logic	       mem_write;
    logic[WORD_SIZE-1:0] mem_write_addr;
    logic[LINE_SIZE-1:0] mem_write_data;
    logic [WORD_SIZE-1:0]        sb_value;
    logic [WORD_SIZE-1:0]        sb_addr;
    logic [SIZE_WRITE_WIDTH-1:0] sb_size;
    logic                        wenable;
    logic		      store_success;

    cache 
    #(
    .N                (N),
    .LINE_SIZE        (LINE_SIZE),
    .WORD_SIZE        (WORD_SIZE),
    .ASSOCIATIVITY    (ASSOCIATIVITY),
    .TAG_SIZE         (TAG_SIZE),
    .SB_ENTRIES       (SB_ENTRIES),
    .SIZE_WRITE_WIDTH (SIZE_WRITE_WIDTH),
    .OFFSET_SIZE      (OFFSET_SIZE),
    .SET_SIZE         (SET_SIZE),
    .INIT             (INIT)
    )
    dut 
    (
    .clk            (clk),
    .rst            (rst),
    .valid          (valid),
    .addr           (addr),
    .load_size      (load_size),
    .store          (store),
    .hit            (hit),
    .read_data      (read_data),
    .mem_req        (mem_req),
    .mem_req_addr   (mem_req_addr),
    .mem_res        (mem_res),
    .mem_res_addr   (mem_res_addr),
    .mem_res_data   (mem_res_data),
    .mem_write      (mem_write),
    .mem_write_addr (mem_write_addr),
    .mem_write_data (mem_write_data),
    .sb_value       (sb_value),
    .sb_addr        (sb_addr),
    .sb_size        (sb_size),
    .wenable        (wenable),
    .store_success  (store_success)
    );


    // To create a clock:
     initial clk = 0;
     always #1 clk = ~clk;

    // To dump data for visualization:
     initial begin
	 $dumpfile("cache_testbench.vcd");
	 $dumpvars(0, cache_testbench);
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

    `UNIT_TEST("Miss - Store - Load + LB sign extends")
	valid = 1;
	store = 1;
	addr  = 128;
	wenable = 0;
	mem_res = 0;
	#2;
	#0.1;
	`ASSERT((dut.pin_counters[0] === 0));
	`ASSERT((dut.mem_req_pin_counters[0] === 1));

	mem_res = 1;
	mem_res_addr = 128;
	mem_res_data =  340282366920938463463374607431768211327;
	#0.9;
	
	#0.1;
	`ASSERT((dut.pin_counters[0] === 2));

	#2;
	store = 0;
	load_size = `FULL_WORD_SIZE;
	#0.1;
	`ASSERT((read_data === 32'hFFFFFF7F));
	#2;
	load_size = `BYTE_SIZE;
	#0.1;
	`ASSERT((read_data === 32'h0000007F));
	#2;
	addr  = 132;
	#0.1;
	`ASSERT((read_data === 32'hFFFFFFFF));

	

        // Describe here the testcase scenario
        //
        // Because SVUT uses long nested macros, it's possible
        // some local variable declaration leads to compilation issue.
        // You should declare your variables after the IOs declaration to avoid that.

    `UNIT_TEST_END

    `UNIT_TEST("Increase pin counter")
	`ASSERT((dut.pin_counters[0] === 2));
	valid = 1;
	store = 1;
	addr  = 128 + 2;
	wenable = 0;
	mem_res = 0;
	#2;
	#0.1;
	`ASSERT((dut.pin_counters[0] === 3));

	store = 0;

	

        // Describe here the testcase scenario
        //
        // Because SVUT uses long nested macros, it's possible
        // some local variable declaration leads to compilation issue.
        // You should declare your variables after the IOs declaration to avoid that.

    `UNIT_TEST_END

    `UNIT_TEST("Stores from SB")
	sb_addr = 128;
	sb_value = 32'h12345678;
	sb_size = `FULL_WORD_SIZE;
	wenable = 1;
	#2;
	#0.1;
	`ASSERT((dut.pin_counters[0] === 2));
	#2;
	#0.1;
	`ASSERT((dut.pin_counters[0] === 1));
	#2;
	#0.1;
	`ASSERT((dut.pin_counters[0] === 0));
	`ASSERT((read_data == 32'h00000034));
	


        // Describe here the testcase scenario
        //
        // Because SVUT uses long nested macros, it's possible
        // some local variable declaration leads to compilation issue.
        // You should declare your variables after the IOs declaration to avoid that.

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
