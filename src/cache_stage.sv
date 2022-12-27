`include "../defines.sv"
`include "../cache.sv"
`include "../TLB.sv"
`include "../store_buffer.sv"

module cache_stage #(
    parameter WORD_SIZE = `WORD_SIZE,
    parameter INSTR_TYPE_SZ = `INSTR_TYPE_SZ,
    parameter LINE_SIZE        = `CACHE_LINE_SIZE,
    parameter ROB_ENTRY_WIDTH = `ROB_ENTRY_WIDTH
) (
    input wire clk,
    input wire rst,
    input wire [INSTR_TYPE_SZ-1:0] instruction_type_out,
    input wire [WORD_SIZE-1:0] pc,
    input wire [2:0] funct3,
    input wire [WORD_SIZE-1:0] v_mem_addr,  // alu out
    input wire [WORD_SIZE-1:0] s2,        // store value
    input wire [ROB_ENTRY_WIDTH-1:0] rob_id,
    input wire valid,
    input wire stall_in, 
    output wire [WORD_SIZE-1:0] read_data,                       // result of the load
    output wire mem_req,                         // memory read port
    output wire [WORD_SIZE-1:0] mem_req_addr,
    output reg		       mem_write,       // Memory write port
    output reg [WORD_SIZE-1:0] mem_write_addr,  // 
    output reg [LINE_SIZE-1:0] mem_write_data,
    input wire mem_res,                        // Memory response
    input wire [WORD_SIZE-1:0] mem_res_addr, 
    input wire [LINE_SIZE-1:0] mem_res_data,
    input wire                       rob_store_permission,
    input wire [ROB_ENTRY_WIDTH-1:0] rob_sb_permission_rob_id,
    output reg stall_out, /* STALL output */
    output reg valid_out
);

    wire is_store = instruction_type_out == `INSTR_TYPE_STORE;

    wire cache_hit;
    wire cache_store_stall;
    wire cache_store_success; // for SB
    wire tlb_exception;
    wire tlb_hit;

    wire sb_store = is_store && !cache_store_stall;
    
    wire [WORD_SIZE-1:0] phy_mem_addr;

    assign phy_mem_addr[WORD_SIZE-1-`PAGE_WIDTH:0] = v_mem_addr[WORD_SIZE-1-`PAGE_WIDTH:0];


    wire [WORD_SIZE-1:0]         sb_store_value; // sb -> cache
    wire [WORD_SIZE-1:0]         sb_store_phy_addr;
    wire                         sb_cache_wenable;
    wire [`SIZE_WRITE_WIDTH-1:0] sb_cache_store_size;
    wire                         sb_full;
    wire [WORD_SIZE-1:0]         sb_bypass_value;
    wire                         sb_bypass_needed;
    wire                         sb_bypass_possible;

    TLB dtlb(
	.clk(clk),
	.virtual_page(v_mem_addr[WORD_SIZE-1-:`PAGE_WIDTH]),
	.physical_page_out(phy_mem_addr[WORD_SIZE-1-:`PAGE_WIDTH]),
	.exception(tlb_exception),
	.hit(tlb_hit)
    );

    cache dcache(
	.clk(clk),
	.rst(rst),
	.valid(valid),
	.addr(phy_mem_addr),
	.load_size(funct3),
	.store(is_store),
	.hit(cache_hit),
	.store_stall(cache_store_stall),
	.read_data(read_data),
	.mem_req(mem_req),
	.mem_req_addr(mem_req_addr),
	.mem_res(mem_res),
	.mem_res_addr(mem_res_addr),
	.mem_res_data(mem_res_data),
	.mem_write(mem_write),
	.mem_write_addr(mem_write_addr),
	.mem_write_data(mem_write_data),
	.sb_value(sb_store_value),
	.sb_addr(sb_store_phy_addr),
	.sb_size(sb_cache_store_size),
	.wenable(sb_cache_wenable),
	.store_success(cache_store_success)
    );

    store_buffer sb(
	.clk(clk),
	.rst(rst),
	.store_value(s2),
	.physical_address(phy_mem_addr),
	.input_rob_id(rob_id),
	.op_size(funct3),
	.store(sb_store), // check SB comments
	.store_success(cache_store_success),
	.TLBexception(tlb_exception),
	.store_permission(rob_store_permission), // ROB
	.store_permission_rob_id(rob_sb_permission_rob_id),
	.cache_store_value(sb_store_value),
	.cache_physical_address(sb_store_phy_addr),
	.cache_wenable(sb_cache_wenable),
	.cache_store_size(sb_cache_store_size),
	.full(sb_full),
	.bypass_value(sb_bypass_value),
	.bypass_needed(sb_bypass_needed),
	.bypass_possible(sb_bypass_possible)
    );
endmodule
