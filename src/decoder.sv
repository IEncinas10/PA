`include "defines.sv"

module decoder #(
    parameter INSTR_SIZE = `WORD_SIZE
) (
    input  wire [INSTR_SIZE-1:0]           instr,
    output wire [`ARCH_REG_INDEX_SIZE-1:0] rs1,
    output wire [`ARCH_REG_INDEX_SIZE-1:0] rs2,
    output wire [`ARCH_REG_INDEX_SIZE-1:0] rd,
    output wire [`WORD_SIZE-1:0]           imm,
    output wire [`INSTR_TYPE_SZ-1:0]       instr_type,
    output wire [6:0]                      opcode,
    output wire [6:0]                      funct7,
    output wire [2:0]                      funct3
);



    //
    //ADD (R), SUB (R), MUL (R), LDB (I), LDW (I), STB (I), STW (I) , BEQ (B), JUMP(J)
    //
    assign opcode = instr[6:0];
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];
    assign rd     = instr[11:7];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];

    //https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf
    //Página 104, listing de todas las instrucciones de RV32I, 
    //podemos ver que rd <- rs1 OP rs2 tienen todos el mismo opcode

    // Ver como sacar esto hacia la siguiente stage o algo
    wire instr_ALU     = (opcode == `OPCODE_ALU);
    wire instr_ALU_IMM = (opcode == `OPCODE_ALU_IMM);
    wire instr_BRANCH  = (opcode == `OPCODE_BRANCH);
    wire instr_STORE   = (opcode == `OPCODE_STORE);
    wire instr_LOAD    = (opcode == `OPCODE_LOAD);
    wire instr_JUMP    = (opcode == `OPCODE_JUMP);
    wire instr_AUIPC   = (opcode == `OPCODE_AUIPC);

    wire instr_R_type  = instr_ALU;
    wire instr_I_type  = instr_LOAD || instr_ALU_IMM;
    wire instr_S_type  = instr_STORE;
    wire instr_B_type  = instr_BRANCH;
    wire instr_J_type  = instr_JUMP;
    wire instr_U_type  = instr_AUIPC;

    assign instr_type = (instr_R_type && funct7 == `MUL_FUNCT7) ? `INSTR_TYPE_MUL :
			((instr_R_type && funct7 != `MUL_FUNCT7) || instr_AUIPC) ? `INSTR_TYPE_ALU :
			(instr_STORE || instr_LOAD)             ? `INSTR_TYPE_MEM : `INSTR_TYPE_NO_WB;


    // https://github.com/BrunoLevy/learn-fpga/blob/dd7b10b4163a149c2a6aac33f923a4f4fe806d4c/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV/pipeline1.v#L79
    // Page 12 https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf
    wire[`WORD_SIZE-1:0] I_imm = {{21{instr[31]}}, instr[30:20]};
    wire[`WORD_SIZE-1:0] S_imm = {{21{instr[31]}}, instr[30:25], instr[11:7]};
    wire[`WORD_SIZE-1:0] B_imm = {{20{instr[31]}}, instr[7],     instr[30:25], instr[11:8],  1'b0};
    wire[`WORD_SIZE-1:0] U_imm = {instr[31],       instr[30:12], {12{1'b0}}};
    wire[`WORD_SIZE-1:0] J_imm = {{12{instr[31]}}, instr[19:12], instr[20],    instr[30:21], 1'b0};

    assign imm = (instr_I_type) ? I_imm :
		 (instr_S_type) ? S_imm :
		 (instr_B_type) ? B_imm :
		 (instr_U_type) ? U_imm : J_imm;
		 //(instr_J_type) ? J_imm ;




    //always@(*) begin
    //end

endmodule
