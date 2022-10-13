`include "defines.sv"


  //Revisar esto, en el tuto pone que se puede hacer dentro del decoder pero
  //no se si esto nos sirve a nosotros o no
module alu #(
  parameter INSTR_SIZE = `WORD_SIZE 
) (
    input wire [6:0] opcode,
    input wire [6:0] funct7,
    input wire [2:0] funt3,
    input wire [INSTR_SIZE-1:0] aluIn1, // rs1
    input wire [INSTR_SIZE-1:0] aluIn2, // rs2 : Iimm ESTO SE CONTROLA FUERA, DENTRO SE TRATA RS2 COMO IMM EN CASO DE SER NECESARIO IMM
    output reg [INSTR_SIZE-1:0] aluOut,
    output reg zero, 
    output reg [INSTR_SIZE-1:0] exceptionCode
);

  

  wire [INSTR_SIZE-1:0] aluAdd = aluIn1 + aluIn2;
  wire [INSTR_SIZE-1:0] aluSub = aluIn1 - aluIn2; 
  wire [INSTR_SIZE-1:0] aluMul = aluIn1 * aluIn2; //signed????
  wire [INSTR_SIZE-1:0] noException = 32'b0;

  assign zero = (aluIn1 == aluIn2) ? 1'b1 : 1'b0;

  always@(*) begin
    case (opcode) //anidar cases en alu
      `ADD_FUNCT7: begin
        assign aluOut = aluAdd;//control exception overflow
        assign exceptionCode = noException;
      end
      `SUB_FUNCT7: begin
        assign aluOut = aluSub;//control exception overflow
        assign exceptionCode = noException;
      end
      `AND_FUNCT3: begin
        assign aluOut = aluIn1 & aluIn2;
        assign exceptionCode = noException;
      end
      `OR_FUNCT3: begin
        assign aluOut = aluIn1 | aluIn2;
        assign exceptionCode = noException;
      end
      `OPCODE_BRANCH: begin
        assign aluOut = aluAdd;
        assign exceptionCode = noException;
      end
      `OPCODE_JUMP: begin
        assign aluOut = aluIn1;
        assign exceptionCode = noException;
      end
      `OPCODE_MUL: begin
        assign aluOut = aluMul;
        assign exceptionCode = noException;
      end
      `OPCODE_LOAD: begin
        assign aluOut = aluAdd;
        assign exceptionCode = noException;
      end
      `OPCODE_STORE: begin
        assign aluOut = aluAdd;
        assign exceptionCode = noException;
      end
      default:begin
        assign aluOut = 32'b0;
        assign exceptionCode = 32'b1;
      end
    endcase
  
  end
  endmodule
