`include "defines.sv"

module rob #(
    parameter WORD_SIZE = `WORD_SIZE,  //-- Width of the register (nº bits)
    parameter ROB_ENTRIES = 10,
    parameter INIT = 0
) (
    input wire rst, 
    input wire clk, 
    input wire wenable,
    output wire full
);

    reg [$clog2(ROB_ENTRIES)-1:0] head;
    reg [$clog2(ROB_ENTRIES)-1:0] tail;
    reg [$clog2(ROB_ENTRIES)-1:0] next_tail;
    reg [ROB_ENTRIES-1:0] entry_ready;

    reg [$clog2(ROB_ENTRIES)-1:0] first_ready;

    reg found;


integer i;
always @(posedge(clk)) begin
    if (rst == 1) begin
	head <= INIT;
	tail <= INIT;
	next_tail <= INIT + 1;
	for(i = 0; i < ROB_ENTRIES; i++) begin
	    entry_ready[i] <= INIT;
	end
    end
    else begin

	// Los bloques se ejecutan en orden. Lo que no se respeta es el orden 
	// dentro de un mismo bloque para los "<=" que son non-blocking
	// assignments
	if(entry_ready[head]) begin
	    entry_ready[head] = 0;
	    head = (head + 1) % ROB_ENTRIES;
	end

	if(wenable && !full) begin
	    tail <= (tail + 1) % ROB_ENTRIES;
	    next_tail <= (next_tail + 1) % ROB_ENTRIES;
	end
    end

    found = 0;
    for (i=head; i != tail; i = (i+1) % ROB_ENTRIES) begin
	if(!found && entry_ready[i] == 1) begin
	    first_ready = i;
	    found = 1;
	end
    end
end

    assign full = (head == next_tail);

endmodule
