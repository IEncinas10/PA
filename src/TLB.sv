`include "../defines.sv"

module TLB #(
  parameter N = `TLB_ENTRIES,  //Number of entries of TLB
  parameter WIDTH = `PAGE_WIDTH
) (
    input wire clk,
    input wire [WIDTH-1:0] virtual_page,
    output reg [WIDTH-1:0] physical_page_out,
    output reg hit
);

    reg [N] [WIDTH-1:0] virtual_addresses;
    reg [N] [WIDTH-1:0] physical_addresses;
    reg [N] valid;
    
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

    

    reg inserted;

    always @(*) begin
        hit = 0;
        for(i = 0; i < N; i = i + 1) begin
            if ((virtual_addresses[i] == virtual_page) && valid[i]) begin
                hit = 1;
                physical_page_out = physical_addresses[i];
            end
        end
    end

    always @(posedge(clk)) begin
        inserted = 0; 
        if(hit == 0) begin 
            for (i = 0; i < N; i = i + 1) begin
                if(valid[i] == 0 && inserted == 0) begin
                    virtual_addresses[i] = virtual_page;
                    physical_addresses[i] = virtual_page + 1;
                    valid[i] = 1;
                    inserted = 1;
                end
            end
        end
    end

   
endmodule