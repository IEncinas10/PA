`include "../defines.sv"

`ifndef TLB
`define TLB

module TLB #(
  parameter N = `TLB_ENTRIES,  //Number of entries of TLB
  parameter WIDTH = `PAGE_WIDTH,
  parameter TLB_DELAY = `TLB_DELAY,
  parameter TLB_DELAY_WIDTH = `TLB_DELAY_WIDTH
) (
    input wire clk,
    input wire [WIDTH-1:0] virtual_page,
    input wire valid,
    output reg [WIDTH-1:0] physical_page_out,
    output reg exception,
    output reg hit
);

    reg [N] [WIDTH-1:0] virtual_addresses;
    reg [N] [WIDTH-1:0] physical_addresses;
    reg [N] valids;
    reg inserted;

    // Artificial delay for doing translations
    reg [TLB_DELAY]             input_valid;
    
    integer i;

    initial begin
        for(i = 0; i < N; i = i + 1) begin
            valids[i] = 0;
            virtual_addresses[i] = 0;
            physical_addresses[i] = 0;
            hit = 0;
            inserted = 0;
        end
    end

    

    

    always @(*) begin
        hit = 0;
        for(i = 0; i < N; i = i + 1) begin
            if ((virtual_addresses[i] == virtual_page) && valids[i]) begin
                hit = 1;
                physical_page_out = physical_addresses[i];
            end
        end

	exception = virtual_page == 0 && hit;
    end


    always @(posedge(clk)) begin
        inserted = 0; 
        if(hit == 0) begin 
            for (i = 0; i < N; i = i + 1) begin
                if(valids[i] == 0 && inserted == 0 && input_valid[0] && valid) begin
                    virtual_addresses[i] = virtual_page;
                    physical_addresses[i] = virtual_page + 1;
                    valids[i] = 1;
                    inserted = 1;
                end
            end

	    // Valid has to be 1 for every cycle of the delay. If at any
	    // moment it resets, we have to reset the valid bits
	    for(i = 0; i < TLB_DELAY - 1; i = i + 1) begin
		input_valid[i] = input_valid[i + 1] && valid;
	    end
	    input_valid[TLB_DELAY - 1]        = valid;
	end 

    end

   
endmodule
`endif
