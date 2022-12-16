`include "../defines.sv"

module store_buffer #(
    parameter N                = `STORE_BUFFER_ENTRIES,
    parameter WORD_SIZE        = `WORD_SIZE,
    parameter WIDTH            = `ADDRESS_WIDTH,
    parameter ROB_ENTRY_WIDTH  = `ROB_ENTRY_WIDTH,
    parameter SIZE_WRITE_WIDTH = `SIZE_WRITE_WIDTH,
    parameter INIT             = 0
) (
    input wire                        clk,
    input wire                        rst,
    /* Sources for new entries */
    input wire [WORD_SIZE-1:0] 	      store_value,
    input wire [WIDTH-1:0] 	      physical_address,
    input wire [ROB_ENTRY_WIDTH-1:0]  input_rob_id, // this only matters for imports
    input wire [SIZE_WRITE_WIDTH-1:0] op_size, 
    input wire        		      store, 
    /* Sources for update state of the entries */
    input wire 			      store_success,
    input wire 			      TLBexception,
    input wire 			      store_permission,
    input wire [ROB_ENTRY_WIDTH-1:0]  store_permission_rob_id,
    /* Outputs for cache communications */
    output reg [WORD_SIZE-1:0] 	      cache_store_value,
    output reg [WIDTH-1:0] 	      cache_physical_address,
    output reg 			      cache_wenable,
    output reg [SIZE_WRITE_WIDTH-1:0] cache_store_size,
    /* Outputs for Stage communications */
    output reg			      full,
    output reg [WORD_SIZE-1:0]        bypass_value,
    output reg 		    	      bypass_needed,
    output reg			      bypass_possible
);

    reg [N] [WIDTH-1:0]            physical_addresses;
    reg [N] 	                   can_store;
    reg [N] [WORD_SIZE-1:0]        value;
    reg [N] [ROB_ENTRY_WIDTH-1:0]  rob_id;
    reg [N] [SIZE_WRITE_WIDTH-1:0] size;

    //TODO fix this
    reg [$clog2(N)-1:0] head;
    reg [$clog2(N)-1:0] tail;

    reg found;
    reg [SIZE_WRITE_WIDTH-1:0] load_size;

	reg [WORD_SIZE-1:0] aux_value;

    integer i;

    initial begin
	reset();
    end

    always @(*) begin
	//if head can write send to cache
	if(can_store[head]) begin 
	    cache_store_size <= size[head];
	    cache_physical_address <= physical_addresses[head];
	    cache_store_value <= value[head];
	    cache_wenable <= 1;
	end

	if(!store) begin 
	    load_size = op_size;
	    bypass_possible = 0;
	    bypass_needed = 0;
	    /* This for takes the last match */
	    for (i = head; i != tail; i = (i + 1) % N) begin
		aux_value = value[i];
		if(load_size == `FULL_WORD_SIZE) begin
		    if(physical_addresses[i] == physical_address && size[i] == `FULL_WORD_SIZE) begin
			bypass_value = value[i];
			bypass_possible = 1;
			bypass_needed = 1;
		    end else if(physical_addresses[i] == physical_address && size[i] == `BYTE_SIZE) begin
			bypass_needed = 1;
			bypass_possible = 0;
		    end
		end else if (load_size == `BYTE_SIZE) begin
		    if(physical_addresses[i] == physical_address) begin
			bypass_value = {{24{1'b0}}, aux_value[7:0]};
			bypass_possible = 1;
			bypass_needed = 1;
		    end else if((physical_address - 1) == physical_addresses[i] && size[i] == `FULL_WORD_SIZE) begin
			bypass_value = {{24{1'b0}}, aux_value[15:8]};
			bypass_possible = 1;
			bypass_needed = 1;
		    end else if((physical_address - 2) == physical_addresses[i] && size[i] == `FULL_WORD_SIZE) begin
			bypass_value = {{24{1'b0}}, aux_value[23:16]};
			bypass_possible = 1;
			bypass_needed = 1;
		    end else if((physical_address - 3) == physical_addresses[i] && size[i] == `FULL_WORD_SIZE) begin
			bypass_value = {{24{1'b0}}, aux_value[31:24]};
			bypass_possible = 1;
			bypass_needed = 1;
		    end
		end
	    end
	end

	full = head == (tail + 1) % N;
    end

    always @(posedge(clk)) begin
	if(rst) begin
	    reset();
	end else begin
	    // update can_store
	    if(store_permission) begin 
		found = 0;
		for(i = 0; i < N; i = i + 1) begin
		    if(!found && rob_id[i] == store_permission_rob_id) begin
			can_store[i] = 1;
			found = 1;
		    end
		end
	    end

	    //TODO revisar si hace falta hacer reset de los valores tras introducirlos
	    if(store_success) begin 
		can_store[head] = 0;
		physical_addresses[head] = INIT;
		value[head] = INIT;
		rob_id[head] = INIT;
		size[head] = INIT;
		head = (head + 1) % N; //update de head
	    end

	    //si metemos al sb y no esta lleno
	    if(store && !full && !TLBexception) begin 
		physical_addresses[tail] = physical_address;
		rob_id[tail] = input_rob_id;
		value[tail] = store_value;
		size[tail] = op_size;
		tail <= (tail + 1) % N; //update the tail
	    end
	end
    end

    task reset;
	cache_store_value <= INIT;
	cache_physical_address <= INIT;
	cache_wenable <= INIT;
	cache_store_size <= INIT;
	full 		 <= INIT;
	bypass_value   	 <= INIT;
	bypass_needed 	 <= INIT;
	bypass_possible  <= INIT;
	head 		 <= INIT;
	tail 		 <= INIT;
	load_size 	 <= INIT;

	for(i = 0; i < N; i = i + 1) begin
	    physical_addresses[i] <= INIT;
	    can_store[i]          <= INIT;
	    value[i] 	          <= INIT;
	    rob_id[i] 	          <= INIT;
	    size[i] 	          <= INIT;
	end
    endtask

endmodule
