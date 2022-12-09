`include "../defines.sv"

module RF_ROB #(

parameter ARCH_REG_INDEX_SIZE = `ARCH_REG_INDEX_SIZE
parameter REGISTERS = `NUM_ARCH_REGS
parameter ROB_ENTRY_WIDTH = `ROB_ENTRY_WIDTH

) (
    input wire clk,
    input wire reset,
    input wire [ARCH_REG_INDEX_SIZE-1:0] rs1,
    input wire [ARCH_REG_INDEX_SIZE-1:0] rs2,
    input wire renaming_reg,
    input wire [ARCH_REG_INDEX_SIZE-1:0] rd,
    input wire [ROB_ENTRY_WIDTH-1:0] rob_id,
    input wire commit,
    input wire [ARCH_REG_INDEX_SIZE-1:0]commit_rd,
    input wire [ROB_ENTRY_WIDTH-1:0] commit_rob_id,
    output reg [ROB_ENTRY_WIDTH-1:0] rs1_rob_entry,
    output reg [ROB_ENTRY_WIDTH-1:0] rs2_rob_entry,
    output reg rs1_rob_entry_valid,
    output reg rs2_rob_entry_valid
);

reg [REGISTERS] [ROB_ENTRY_WIDTH-1:0] rob_entry;
reg [REGISTERS] valid;

integer i;

initial begin 
    for(i = 0; i < REGISTERS; i = i + 1) begin
        valid[i] <= 0;
        rob_entry[i] <= 0; //inicializado a 0 por tener un valor que no sea basura
    end
end


always @(*) begin
    rs1_rob_entry <= rob_entry[rs1];
    rs1_rob_entry_valid <= valid[rs1];

    rs2_rob_entry <= rob_entry[rs2];
    rs2_rob_entry_valid <= valid[rs2];
end

always @(posedge(clk)) begin
    if(reset) begin 
        for(i = 0; i < REGISTERS; i = i + 1) begin
            valid[i] <= 0;
        end
    end else begin 
        if(rob_entry[rd] == commit_rob_id && commit && (!renaming_reg || commit_rd != rd) ) begin
            valid[commit_rd] <= 0;
        end    

        if(rd != 0 && renaming_reg) begin
            rob_entry[rd] <= rob_id;
            valid[rd] <= 1;
        end
    end
end
   
endmodule