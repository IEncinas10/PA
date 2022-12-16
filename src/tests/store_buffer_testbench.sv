// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "store_buffer.sv"
`timescale 1 ns / 1 ns

module store_buffer_testbench();

    `SVUT_SETUP

    parameter N                = `STORE_BUFFER_ENTRIES;
    parameter WORD_SIZE        = `WORD_SIZE;
    parameter WIDTH            = `ADDRESS_WIDTH;
    parameter ROB_ENTRY_WIDTH  = `ROB_ENTRY_WIDTH;
    parameter SIZE_WRITE_WIDTH = `SIZE_WRITE_WIDTH;
    parameter INIT             = 0;

    logic                        clk;
    logic                        rst;
    logic [WORD_SIZE-1:0] 	      store_value;
    logic [WIDTH-1:0] 	      physical_address;
    logic [ROB_ENTRY_WIDTH-1:0]  input_rob_id;
    logic [SIZE_WRITE_WIDTH-1:0] op_size;
    logic        		      store;
    logic 			      store_success;
    logic 			      TLBexception;
    logic 			      store_permission;
    logic [ROB_ENTRY_WIDTH-1:0]  store_permission_rob_id;
    logic[WORD_SIZE-1:0] 	      cache_store_value;
    logic[WIDTH-1:0] 	      cache_physical_address;
    logic			      cache_wenable;
    logic[SIZE_WRITE_WIDTH-1:0] cache_store_size;
    logic		      full;
    logic[WORD_SIZE-1:0]        bypass_value;
    logic		    	      bypass_needed;
    logic		      bypass_possible;

    store_buffer 
    #(
    .N                (N),
    .WORD_SIZE        (WORD_SIZE),
    .WIDTH            (WIDTH),
    .ROB_ENTRY_WIDTH  (ROB_ENTRY_WIDTH),
    .SIZE_WRITE_WIDTH (SIZE_WRITE_WIDTH),
    .INIT             (INIT)
    )
    dut 
    (
    .clk                     (clk),
    .rst                     (rst),
    .store_value             (store_value),
    .physical_address        (physical_address),
    .input_rob_id            (input_rob_id),
    .op_size                 (op_size),
    .store                   (store),
    .store_success           (store_success),
    .TLBexception            (TLBexception),
    .store_permission        (store_permission),
    .store_permission_rob_id (store_permission_rob_id),
    .cache_store_value       (cache_store_value),
    .cache_physical_address  (cache_physical_address),
    .cache_wenable           (cache_wenable),
    .cache_store_size        (cache_store_size),
    .full                    (full),
    .bypass_value            (bypass_value),
    .bypass_needed           (bypass_needed),
    .bypass_possible         (bypass_possible)
    );


    // To create a clock:
    initial clk = 0;
    always #1 clk = ~clk;

     //To dump data for visualization:
    initial begin
        $dumpfile("store_buffer_testbench.vcd");
        $dumpvars(0, store_buffer_testbench);
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

    `UNIT_TEST("TESTCASE_NEW_ENTRY")
    
    rst = 0;
    store_value = 26;
    physical_address = 4;
    input_rob_id = 0;
    op_size = `FULL_WORD_SIZE;
    store = 1;
    TLBexception = 0;

    #2
    `ASSERT((dut.tail != dut.head));
    `ASSERT((dut.value[0] == 26));
    `ASSERT((dut.physical_addresses[0] == 4));
    `ASSERT((dut.size[0] == `FULL_WORD_SIZE));
    `ASSERT((dut.can_store[0] == 0));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_NEW_ENTRY2")
    
    rst = 0;
    store_value = 2;
    physical_address = 8;
    input_rob_id = 2;
    op_size = `BYTE_SIZE;
    store = 1;
    TLBexception = 0;

    #2
    `ASSERT((dut.tail != dut.head));
    `ASSERT((dut.value[1] == 2));
    `ASSERT((dut.physical_addresses[1] == 8));
    `ASSERT((dut.size[1] == `BYTE_SIZE));
    `ASSERT((dut.can_store[1] == 0));
    
    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_NEW_ENTRY_3")
    
    rst = 0;
    store_value = 4294967295;
    physical_address = 12;
    input_rob_id = 0;
    op_size = `FULL_WORD_SIZE;
    store = 1;
    TLBexception = 0;

    #2
    `ASSERT((dut.tail != dut.head));
    `ASSERT((dut.value[2] == 4294967295));
    `ASSERT((dut.physical_addresses[2] == 12));
    `ASSERT((dut.size[2] == `FULL_WORD_SIZE));
    `ASSERT((dut.can_store[2] == 0));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_BYPASS_LW_SW")
    
    rst = 0;
    physical_address = 4;
    store = 0;
    op_size = `FULL_WORD_SIZE;
    store_success = 0;


    #2
    
    `ASSERT((bypass_value == 26));
    `ASSERT((bypass_needed == 1));
    `ASSERT((bypass_possible == 1));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_BYPASS_LW_SB")
    
    rst = 0;
    physical_address = 8;
    store = 0;
    op_size = `FULL_WORD_SIZE;
    store_success = 0;


    #2
    //bypass_value not checked, it wont have any usefull data for us...
    `ASSERT((bypass_needed == 1));
    `ASSERT((bypass_possible == 0));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_BYPASS_NO_HIT")
    
    rst = 0;
    physical_address = 48;
    store = 0;
    op_size = `FULL_WORD_SIZE;
    store_success = 0;

    #2
    `ASSERT((bypass_needed == 0));
    `ASSERT((bypass_possible == 0));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_BYPASS_LB_SB")
    
    rst = 0;
    physical_address = 8;
    store = 0;
    op_size = `BYTE_SIZE;
    store_success = 0;

    #2
    `ASSERT((bypass_value == 2));
    `ASSERT((bypass_needed == 1));
    `ASSERT((bypass_possible == 1));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_BYPASS_LB_SB_NO_HIT")
    
    rst = 0;
    physical_address = 9;
    store = 0;
    op_size = `BYTE_SIZE;
    store_success = 0;

    #2
    `ASSERT((bypass_needed == 0));
    `ASSERT((bypass_possible == 0));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_BYPASS_LB_SW_POS0")
    
    rst = 0;
    physical_address = 12;
    store = 0;
    op_size = `BYTE_SIZE;
    store_success = 0;

    #2
    `ASSERT((bypass_value == 255));
    `ASSERT((bypass_needed == 1));
    `ASSERT((bypass_possible == 1));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_BYPASS_LB_SW_POS1")
    
    rst = 0;
    physical_address = 13;
    store = 0;
    op_size = `BYTE_SIZE;
    store_success = 0;

    #2
    `ASSERT((bypass_value == 255));
    `ASSERT((bypass_needed == 1));
    `ASSERT((bypass_possible == 1));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_BYPASS_LB_SW_POS2")
    
    rst = 0;
    physical_address = 14;
    store = 0;
    op_size = `BYTE_SIZE;
    store_success = 0;

    #2
    `ASSERT((bypass_value == 255));
    `ASSERT((bypass_needed == 1));
    `ASSERT((bypass_possible == 1));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_BYPASS_LB_SW_POS3")
    
    rst = 0;
    physical_address = 15;
    store = 0;
    op_size = `BYTE_SIZE;
    store_success = 0;

    #2
    `ASSERT((bypass_value == 255));
    `ASSERT((bypass_needed == 1));
    `ASSERT((bypass_possible == 1));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_PERMISSION")
    
    rst = 0;
    store = 0;
    store_permission = 1;
    store_permission_rob_id = 0;
    TLBexception = 0;
    store_success = 0;


    #2
    `ASSERT((dut.tail != dut.head));
    `ASSERT((dut.value[0] == 26));
    `ASSERT((dut.physical_addresses[0] == 4));
    `ASSERT((dut.size[0] == `FULL_WORD_SIZE));
    `ASSERT((dut.can_store[0] == 1));

    `ASSERT((cache_store_value == 26));
    `ASSERT((cache_physical_address == 4));
    `ASSERT((cache_wenable == 1));
    `ASSERT((cache_store_size == `FULL_WORD_SIZE));

    `UNIT_TEST_END

    `UNIT_TEST("TESTCASE_STORE_SUCCESS")
    
    rst = 0;
    store_success = 1;


    #2
    `ASSERT((dut.tail != dut.head));
    `ASSERT((dut.value[0] != 26));
    `ASSERT((dut.physical_addresses[0] != 4));
    `ASSERT((dut.size[0] != `FULL_WORD_SIZE));
    `ASSERT((dut.can_store[0] != 1));

    `ASSERT((dut.head + 2 == dut.tail));

    `UNIT_TEST_END

    
    `UNIT_TEST("TESTCASE_RST")
    
    rst = 1;
    store_value = 2;
    physical_address = 8;
    input_rob_id = 2;
    op_size = `BYTE_SIZE;
    store = 1;
    TLBexception = 0;

    #2
    `ASSERT((dut.tail == dut.head));
    `ASSERT((dut.value[1] == 0));
    `ASSERT((dut.physical_addresses[1] == 0));
    `ASSERT((dut.size[1] == 0));
    `ASSERT((dut.can_store[1] == 0));
    `ASSERT((dut.value[0] == 0));
    `ASSERT((dut.physical_addresses[0] == 0));
    `ASSERT((dut.size[0] == 0));
    `ASSERT((dut.can_store[0] == 0));
    
    `UNIT_TEST_END

    

    `TEST_SUITE_END

endmodule
