`include "../defines.sv"


`ifndef ALU
`define ALU

module alu #(
  parameter WORD_SIZE = `WORD_SIZE 
) (
    input wire [WORD_SIZE-1:0] pc,
    input wire [6:0] opcode,
    input wire [6:0] funct7,
    input wire [2:0] funct3,
    input wire [WORD_SIZE-1:0] aluIn1,
    input wire [WORD_SIZE-1:0] aluIn2, 
    input wire [WORD_SIZE-1:0] immediate,
    output reg [WORD_SIZE-1:0] aluOut,
    output reg [WORD_SIZE-1:0] newpc,
    output reg branchTaken // If instr. is not valid, ignore this and set to 0 from outside
);

  

  wire [WORD_SIZE-1:0] aluAdd = aluIn1 + aluIn2;
  wire [WORD_SIZE-1:0] aluSub = aluIn1 - aluIn2; 
  wire [WORD_SIZE-1:0] aluMul = aluIn1 * aluIn2; 


  always@(*) begin
    branchTaken = 0; 
    newpc = pc + immediate; //only make sense if branch or jump. Also used for AUIPC

    case (opcode) 

     `OPCODE_ALU: begin
        case(funct7)
        `SUB_FUNCT7: begin
          aluOut = aluSub;
        end
        `MUL_FUNCT7: begin
          aluOut = aluMul;
        end
        `ADD_OR_AND_FUNCT7: begin
          case(funct3)
            `ADD_FUNCT3: begin
              aluOut = aluAdd;
            end
            `OR_FUNCT3: begin
              aluOut = aluIn1 | aluIn2;
            end
            `AND_FUNCT3: begin
              aluOut = aluIn1 & aluIn2;
			end
			`SLLI_FUNCT3: begin
				aluOut = aluIn1 << aluIn2;
			end
			`SRLI_FUNCT3: begin
				aluOut = aluIn1 >> aluIn2;
			end
          endcase
          end
        endcase
      end
      `OPCODE_AUIPC: begin
        aluOut = newpc;
      end
      `OPCODE_BRANCH: begin
		case(funct3)
			`BEQ_FUNCT3: begin
				aluOut = aluSub;
				branchTaken = aluOut == 0;
			end
			`BNE_FUNCT3: begin
				aluOut = aluSub;
				branchTaken = aluOut != 0;
			end
			`BGE_FUNCT3: begin
				aluOut = aluSub;
				branchTaken = (aluIn1 > aluIn2) || aluOut == 0;
			end
			`BLT_FUNCT3: begin
				aluOut = aluSub;
				branchTaken = aluIn1 < aluIn2;
			end
		endcase
      end
      `OPCODE_JUMP: begin
        branchTaken = 1;
      end
      `OPCODE_LOAD: begin
        aluOut = aluIn1 + immediate;
      end
      `OPCODE_STORE: begin
        aluOut = aluIn1 + immediate;
      end
      `OPCODE_ALU_IMM: begin
        case (funct3)
          `ADDI_FUNCT3: begin
            aluOut = aluIn1 + immediate;
          end
        endcase
      end
      default:begin
        aluOut = 0;
      end
    endcase
  
  end
  endmodule

`endif
