`include "../defines.sv"

module store_buffer #(
	parameter N 				  = `STORE_BUFFER_WIDTH,
    parameter WORD_SIZE 		  = `WORD_SIZE,
	parameter WIDTH 			  = `ADDRESS_WIDTH,
    parameter ROB_ENTRY_WIDTH     = `ROB_ENTRY_WIDTH,
	parameter SIZE_WRITE_WIDTH    = `SIZE_WRITE_WIDTH,
	parameter INIT			  = 0;
) (
    input wire clk,
    input wire reset,
    /* Sources for new entries */
    input wire [WORD_SIZE-1:0] 			store_value,
	input wire [WIDTH-1:0] 				physical_address_in,
	input wire [ROB_ENTRY_WIDTH-1:0] 	rob_id,
	input wire [SIZE_WRITE_WIDTH-1:0]	store_size, 
	input wire        					store, 
	/* Sources for update state of the entries */
	input wire 							store_success,
	input wire 							TLBexception,
	input wire 							store_permission,
	input wire [ROB_ENTRY_WIDTH-1:0] 	store_permission_rob_id,
	/* Outputs for cache communications */
	output reg [WORD_SIZE-1:0] 			cache_store_value,
	output reg [WIDTH-1:0] 				cache_physical_address,
	output reg 							cache_wenable,
	output reg [SIZE_WRITE_WIDTH-1:0]	cache_store_size,
	/* Outputs for Stage communications */
	output reg 							full,
	output reg [WORD_SIZE-1:0] 			bypass_value,
	output reg 							bypass_needed,
	output reg 							bypass_possible
);

reg [N] [WIDTH-1:0] 			physical_addresses;
reg [N] 						can_store;
reg [N] [WORD_SIZE-1:0] 		value;
reg [N] [ROB_ENTRY_WIDTH-1:0] 	rob_id;
reg [N] [SIZE_WRITE_WIDTH-1:0] 	size;

reg [$clog2(N)-1:0] 			head;
reg [$clog2(N)-1:0]				tail;

reg full_sb;
reg found;

integer i;

initial begin
	value <= INIT;
	physical_address 	<= INIT;
	full 				<= INIT;
	bypass_value 		<= INIT;
	bypass_needed 		<= INIT;
	bypass_possible 	<= INIT;
	head 				<= INIT;
	tail 				<= INIT;
	full_sb				<= INIT;

	for(i = 0; i < N; i = i + 1) begin
		physical_addresses[i] 	<= INIT;
		can_store[i] 		<= INIT;
		value[i] 			<= INIT;
		rob_id[i] 			<= INIT;
		size[i] 			<= INIT;
	end
end

always @(posedge(clk)) begin
	if(rst) begin
		for(i = 0; i < N; i = i + 1) begin //Reset all values after a rst signal
			physical_addresses[i] 	<= INIT;
			can_store[i] 		<= INIT;
			value[i] 			<= INIT;
			rob_id[i] 			<= INIT;
			size[i] 			<= INIT;
		end
	end else begin

		if(store_permission) begin // update can_store
			found = 0;
			for(i = 0; i < N; i = i + 1) begin
				if(!found && rob_id[i] == store_permission_rob_id) begin
					can_store[i] = 1;
					found = 1;
				end
			end
		end

		if(can_store[head]) begin //if head can write send to cache
			cache_store_size <= size[head];
			cache_physical_address <= physical_addresses[head];
			cache_store_value <= value[head];
			cache_wenable <= 1;
		end

		if(store_success) begin //TODO revisar si hace falta hacer reset de los valores tras introducirlos
			can_store[head] = 0;
			physical_addresses[head] = INIT;
			value[head] = INIT;
			rob_id[head] = INIT;
			size[head] = INIT;

			head = (head + 1) % N;
		end

		if(store && !full_sb) begin //si metemos al sb y no esta lleno
			tail <= (tail + 1) % N; //TODO falta introducir los datos y controlar tamaño de store
		end

		
		//TODO bypass usa physical_address & store_size
	end

	full_sb = head == tail % N;
	full = full_sb; //mmmmmmmmmmmmm
end



endmodule
