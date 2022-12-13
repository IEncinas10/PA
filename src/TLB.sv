`include "../defines.sv"

module TLB #(
  parameter N = `TLB_ENTRIES,  //Number of entries of TLB
  parameter WIDTH = `PAGE_WIDTH,
  parameter TLB_DELAY = `TLB_DELAY,
  parameter TLB_DELAY_WIDTH = `TLB_DELAY_WIDTH
) (
    input wire clk,
    input wire [WIDTH-1:0] virtual_page,
    output reg [WIDTH-1:0] physical_page_out,
    output reg exception,
    output reg hit
);

    reg [N] [WIDTH-1:0] virtual_addresses;
    reg [N] [WIDTH-1:0] physical_addresses;
    reg [N] valid;
    reg inserted;

    // Artificial delay for doing translations
    reg [TLB_DELAY_WIDTH-1:0] delay;
    
    integer i;

    initial begin
        for(i = 0; i < N; i = i + 1) begin
            valid[i] = 0;
            virtual_addresses[i] = 0;
            physical_addresses[i] = 0;
            hit = 0;
            inserted = 0;
        end
    end

    

    

    always @(*) begin
        hit = 0;
        for(i = 0; i < N; i = i + 1) begin
            if ((virtual_addresses[i] == virtual_page) && valid[i]) begin
                hit = 1;
                physical_page_out = physical_addresses[i];
            end
        end

	delay = TLB_DELAY;
	exception = virtual_page == 0 && hit;
    end


    always @(posedge(clk)) begin
        inserted = 0; 
        if(hit == 0) begin 
            for (i = 0; i < N; i = i + 1) begin
                if(valid[i] == 0 && inserted == 0 && delay == 0) begin
                    virtual_addresses[i] = virtual_page;
                    physical_addresses[i] = virtual_page + 1;
                    valid[i] = 1;
                    inserted = 1;
                end
            end
	    delay = delay - 1;
        end
    end

   
endmodule
