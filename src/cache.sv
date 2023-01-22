`include "../defines.sv"

`ifndef CACHE
`define CACHE

module cache #(
    parameter N                = `CACHE_N_LINES,
    parameter LINE_SIZE        = `CACHE_LINE_SIZE,
    parameter WORD_SIZE        = `WORD_SIZE,
    parameter ASSOCIATIVITY    = `CACHE_ASSOCIATIVITY,
    parameter TAG_SIZE         = `TAG_SIZE,
    parameter SB_ENTRIES       = `STORE_BUFFER_ENTRIES,
    parameter SIZE_WRITE_WIDTH = `SIZE_WRITE_WIDTH,
    parameter OFFSET_SIZE      = `OFFSET_SIZE,
    parameter SET_SIZE         = $clog2(`CACHE_N_LINES - `CACHE_ASSOCIATIVITY),
    parameter INIT             = 0
) (
    input wire clk,
    input wire rst,
    input wire                        valid,    // Valid = 0 <=> Bubble or SB full && store
    input wire [WORD_SIZE-1:0]        addr,
    input wire [SIZE_WRITE_WIDTH-1:0] load_size, 
    input wire                        store,    // 1 store, 0 load
    output reg                        hit,      // 
    output reg                        store_stall,  // do we need to stall because we cant issue the mem request?
    output reg [WORD_SIZE-1:0] read_data,
    output reg                 mem_req,         // memory request
    output reg [WORD_SIZE-1:0] mem_req_addr,    
    input wire                 mem_res,         // memory response
    input wire [WORD_SIZE-1:0] mem_res_addr, 
    input wire [LINE_SIZE-1:0] mem_res_data,
    output reg		       mem_write,       // cache line eviction
    output reg [WORD_SIZE-1:0] mem_write_addr,  // set lower bits to 0¿?
    output reg [LINE_SIZE-1:0] mem_write_data,
    input wire [WORD_SIZE-1:0]        sb_value,
    input wire [WORD_SIZE-1:0]        sb_addr,
    input wire [SIZE_WRITE_WIDTH-1:0] sb_size,
    input wire                        wenable,
    output reg			      store_success
);

    // Pin counter. Incremented each time a store touches a line.
    // If line is not present, when it comes we'll initialize the
    // counter to the corresponding value. 
    //
    // 1) Missing request "queue" -> {tag, counter}_n
    // When a line comes in we match it with his MRQ and initialize the value
    reg [N] [$clog2(SB_ENTRIES):0] pin_counters;
    reg [N]                          dirtys;
    reg [N] [TAG_SIZE -1:0]          tags;
    reg [N] [LINE_SIZE-1:0]          data;

    // We don't care¿? 
    //reg [N]                          valids;

    //   Direct mapping example
    //   
    //   ┌─────────────────────────────┐
    //   │            addr             │
    //   └─────────────────────────────┘
    //   31                            0
    //
    //   ┌───────┐ ┌─────┐  ┌─────────┐
    //   │  tag  │ │ set │  │ offset  │
    //   └───────┘ └─────┘  └─────────┘
    //   31      6 5     4  3         0


    wire [OFFSET_SIZE-1:0] offset = addr[OFFSET_SIZE-1:0]; 
    wire [SET_SIZE-1:0]       set = addr[OFFSET_SIZE + SET_SIZE - 1:OFFSET_SIZE];
    wire [TAG_SIZE-1:0]       tag = addr[31:OFFSET_SIZE + SET_SIZE];

    // Missing request pin counter, tag and a bit indicating if it is present
    reg [N]                          mem_req_present;
    reg [N] [$clog2(SB_ENTRIES):0] mem_req_pin_counters;
    reg [N] [TAG_SIZE-1:0]	     mem_req_tags;

    // Store buffer
    wire [OFFSET_SIZE-1:0] sb_offset = sb_addr[OFFSET_SIZE-1:0]; 
    wire [SET_SIZE-1:0]       sb_set = sb_addr[OFFSET_SIZE + SET_SIZE - 1:OFFSET_SIZE];
    wire [TAG_SIZE-1:0]       sb_tag = sb_addr[31:OFFSET_SIZE + SET_SIZE];

    // Memory request 
    wire [SET_SIZE-1:0] mem_req_set = mem_req_addr[OFFSET_SIZE + SET_SIZE - 1:OFFSET_SIZE];
    wire [TAG_SIZE-1:0] mem_req_tag = mem_req_addr[31:OFFSET_SIZE + SET_SIZE];

    // Memory response 
    wire [SET_SIZE-1:0] mem_res_set = mem_res_addr[OFFSET_SIZE + SET_SIZE - 1:OFFSET_SIZE];
    wire [TAG_SIZE-1:0] mem_res_tag = mem_res_addr[31:OFFSET_SIZE + SET_SIZE];

    // Ty icarus verilog: Chapuzas...
    reg [LINE_SIZE-1:0] line_read;
    reg [WORD_SIZE-1:0] read_offset;
    reg [WORD_SIZE-1:0] write_offset;
    reg [LINE_SIZE-1:0] line_write;


    reg increase_pin_counter;
    reg decrease_pin_counter;
    reg increase_mem_req_pin_counter;


    integer i;

    initial begin
	reset();
    end

    always @(*) begin
	// Defaults
	hit	      = 0; // Cache stage
	read_data     = 0;
	store_stall   = 0;

	mem_req       = 0; // Memory
	mem_write     = 0; 
	store_success = 0; // Store buffer

	if(valid) begin
	    hit = tags[set] == tag;

	    // If we miss and we're not requesting anything for the set "set"
	    // raise mem_req signal and specify the desired memory block
	    if(!hit && pin_counters[set] == 0 && !mem_req_present[set]) begin
		mem_req = 1;
		//mem_req_addr = {tag, set, OFFSET_SIZE'b0000};
		mem_req_addr = {tag, set, 4'b0000};
	    end else begin
		mem_req = 0;
	    end

	    // If we're a store, we stall whenever we miss the cache AND
	    // we can't request the memory we want. If we're load, we stall
	    // whenever the data is not in the cache
	    if(store) begin
		store_stall = !(hit || mem_req_tags[set] == tag || !mem_req_present[set]);
	    end


	    line_read = data[set];
	    case(load_size) 
		`BYTE_SIZE: begin
		    //read_data = {24'b0, line_read[(offset + 1)*8:offset*8]};
		    read_offset = (offset + 1) * 8 - 1;
		    // LB sign extends!
		    read_data = {{24{line_read[read_offset]}}, line_read[read_offset-:8]};
		end
		`FULL_WORD_SIZE: begin
		    //read_data = line_read[(offset + 4)*8:offset*8];
		    read_offset = (offset + 4) * 8 - 1;
		    read_data = line_read[read_offset-:32];
		end
	    endcase
	end 

	// Stores from SB should always succeed
	store_success = wenable && sb_tag == tags[sb_set];
	
	// We can only create 1 request per set. If we're asking this cycle
	// for a new memory block, we don't need to increase it's pin counter
	increase_mem_req_pin_counter = !mem_req && valid && store && mem_req_present[set] && mem_req_tags[set] == tag;

	increase_pin_counter = valid && store && hit;
	decrease_pin_counter = store_success;


	// Evict line before it is replaced
	if(mem_res && dirtys[mem_res_set]) begin
	    `assert(pin_counters[mem_res_set], 0);
	    mem_write      = 1;
	    mem_write_data = data[mem_res_set];
	    //mem_write_addr = {tags[mem_res_set], mem_res_set, OFFSET_SIZE'b0000};
	    mem_write_addr = {tags[mem_res_set], mem_res_set, 4'b0000};
	end
    end

    always @(posedge(clk)) begin
	if(rst) begin
	    reset();
	end else begin
	    // If we're a store and we have HIT cache, we have to
	    // increase the pin counter. When we write from the SB we will
	    // decrement it back

	    handle_requests();



	    // Store Buffer. Write and decrement pin counter
	    if(wenable && sb_tag == tags[sb_set]) begin
		`assert(tags[sb_set], sb_tag);
		dirtys[sb_set] <= 1;

		line_write = data[sb_set];
		case(sb_size)
		    `BYTE_SIZE: begin
			write_offset = (sb_offset+1) * 8 - 1;
			line_write[write_offset-:8] = sb_value[7:0];
			data[sb_set] <= line_write;
		    end
		    `FULL_WORD_SIZE: begin
			write_offset = (sb_offset+4) * 8 - 1;
			line_write[write_offset-:32] = sb_value;
			data[sb_set] <= line_write;
			
		    end
		endcase
	    end

	    if(increase_pin_counter && !decrease_pin_counter) begin
		pin_counters[set] <= pin_counters[set] + 1;
	    end else if (decrease_pin_counter && !increase_pin_counter) begin
		pin_counters[sb_set] <= pin_counters[sb_set] - 1;
	    end

	end
    end

    task handle_requests;
	//
	// Request model:
	// 
	// Cycles | 1  2  3  4  5  6
	// -------------------------
	//  Req   | 1 ?  ?  ?  
	//  Res   |             1
	//
	// Res cycle 5 <-> Req cycle 1
	// We can ask for several lines before getting a reply,
	// 1 per cycle.


	//Internal bookkeeping. We need the tag for the pin_counter, and
	//the pin counter to pin lines for stores in the store buffer
	if(mem_req) begin
	    mem_req_tags[set]	 <= tag;
	    mem_req_present[set] <= 1;
	    // If a load brings the line we must not pin it
	    mem_req_pin_counters[set] <= store ? 1 : 0;
	end

	// If we're already requesting this memory block, just update its pin counter.
	// If this request already exists, a store will only stay 1 cycle in
	// this stage (and if the SB is full we will get a 'valid = 0')
	if(increase_mem_req_pin_counter) begin
	    mem_req_pin_counters[set] <= mem_req_pin_counters[set] + 1;
	end

	// response latency 1 doesnt work
	if(mem_res && mem_req_present[mem_res_set]) begin
	    // Update replaced line
	    tags[mem_res_set]   <= mem_res_tag;
	    data[mem_res_set]   <= mem_res_data;
	    dirtys[mem_res_set] <= 0;
	    // We have to inherit the pin counter from the memory request
	    pin_counters[mem_res_set] <= mem_req_pin_counters[mem_res_set];

	    // Clear memory request info 
	    mem_req_pin_counters[mem_res_set] <= 0;
	    mem_req_present[mem_res_set]      <= 0;
	    mem_req_tags[mem_res_set]         <= 0;
	end
    endtask

    task reset;
	for(i = 0; i < N; i = i + 1) begin
	    pin_counters[i] = 0;
	    dirtys[i]	    = 0;
	    tags[i]	    = 0;
	    data[i]	    = 0;
	    
	    mem_req_present[i] = 0;
	    mem_req_pin_counters[i] = 0;
	    mem_req_tags[i] = 0;
	end
    endtask

endmodule

`endif
