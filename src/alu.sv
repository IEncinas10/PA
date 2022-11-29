`include "../defines.sv"


  //Revisar esto, en el tuto pone que se puede hacer dentro del decoder pero
  //no se si esto nos sirve a nosotros o no
module alu #(
  parameter WORD_SIZE = `WORD_SIZE 
) (
    input wire [WORD_SIZE-1:0] pc,
    input wire [6:0] opcode,
    input wire [6:0] funct7,
    input wire [2:0] funct3,
    input wire [WORD_SIZE-1:0] aluIn1, // rs1
    input wire [WORD_SIZE-1:0] aluIn2, // rs2 : Iimm
    input wire [WORD_SIZE-1:0] immediate,
    output reg [WORD_SIZE-1:0] aluOut,
    output reg [WORD_SIZE-1:0] newpc,
    output reg branchTaken
);

  

  wire [WORD_SIZE-1:0] aluAdd = aluIn1 + aluIn2;
  wire [WORD_SIZE-1:0] aluSub = aluIn1 - aluIn2; 
  wire [WORD_SIZE-1:0] aluMul = aluIn1 * aluIn2; 

  assign newpc = pc + immediate; //only make sense if branch or jump

  always@(*) begin
    assign branchTaken = 0; //ver si va asi, sino meter en cada uno
    case (opcode) 

     `OPCODE_ALU: begin
        case(funct7)
        `SUB_FUNCT7: begin
          assign aluOut = aluSub;
        end
        `MUL_FUNCT7: begin
          assign aluOut = aluMul;
        end
        `ADD_OR_AND_FUNCT7: begin
          case(funct3)
            `ADD_FUNCT3: begin
              assign aluOut = aluAdd;
            end
            `OR_FUNCT3: begin
              assign aluOut = aluIn1 | aluIn2;
            end
            `AND_FUNCT3: begin
              assign aluOut = aluIn1 & aluIn2;
            end
          endcase
          end
        endcase
      end

      `OPCODE_BRANCH: begin
        assign aluOut = aluSub;
        assign branchTaken = aluOut == 0;
      end
      `OPCODE_JUMP: begin
        assign aluOut = aluIn1 + immediate;
        assign branchTaken = 1;
      end
      `OPCODE_LOAD: begin
        assign aluOut = aluIn1 + immediate;
      end
      `OPCODE_STORE: begin
        assign aluOut = aluIn1 + immediate;
      end
      `OPCODE_ALU_IMM: begin
        case (funct3)
          `ADDI_FUNCT3: begin
            assign aluOut = aluIn1 + immediate;
          end
        endcase
      end
      default:begin
        assign aluOut = 0;
      end
    endcase
  
  end
  endmodule
