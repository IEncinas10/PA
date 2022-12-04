// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "../decoder.sv"
`timescale 1 ns / 1 ns

module decoder_testbench();

    `SVUT_SETUP

    parameter INSTR_SIZE = `WORD_SIZE;

    logic [INSTR_SIZE-1:0] instr;
    logic [`ARCH_REG_INDEX_SIZE-1:0]  rs1;
    logic [`ARCH_REG_INDEX_SIZE-1:0]  rs2;
    logic [`ARCH_REG_INDEX_SIZE-1:0]   rd;
    logic [`WORD_SIZE-1:0]   imm;

    decoder 
    #(
    .INSTR_SIZE (INSTR_SIZE)
    )
    dut 
    (
    .instr (instr),
    .rs1   (rs1),
    .rs2   (rs2),
    .rd    (rd),
    .imm   (imm)
    );


    //00000000 <a>:
    //.text
    //a:
    //add x1, x2, x3
       //0:	003100b3          	add	ra,sp,gp
    //addi x1, x1, 1
       //4:	00108093          	addi	ra,ra,1
    //sub x2, x3, x4
       //8:	40418133          	sub	sp,gp,tp
    //mul x2, x3, x4
       //c:	02418133          	mul	sp,gp,tp
    //lb x1, 1(x3)
      //10:	00118083          	lb	ra,1(gp)
    //lw x1, 1(x3)
      //14:	0011a083          	lw	ra,1(gp)
    //sb x1, 1(x3)
      //18:	001180a3          	sb	ra,1(gp)
    //sw x1, 1(x3)
      //1c:	0011a0a3          	sw	ra,1(gp)
    //jal x1, 0
      //20:	000000ef          	jal	ra,20 <a+0x20>
    //j x1
      //24:	fddff06f          	j	0 <a>
    //j a
      //28:	fd9ff06f          	j	0 <a>
    //beq x1, x1, a
      //2c:	fc108ae3          	beq	ra,ra,0 <a>
    //j b
      //28:	ff5ff06f          	j	1c <b>
    //jal x1, b
      //2c:	ff1ff0ef          	jal	ra,1c <b>
    //beq x1, x1, b
      //34:	fe1084e3          	beq	ra,ra,1c <b>


    // To create a clock:
     //initial aclk = 0;
     //always #2 aclk = ~aclk;

    // To dump data for visualization:
     initial begin
	 $dumpfile("decoder_testbench.vcd");
	 $dumpvars(0, decoder_testbench);
     end

    // Setup time format when printing with $realtime()
    initial $timeformat(-9, 1, "ns", 8);

    task setup(msg="");
    begin
        // setup() runs when a test begins
    end
    endtask

    task teardown(msg="");
    begin
        // teardown() runs when a test ends
    end
    endtask

    `TEST_SUITE("DECODER")

    //  Available macros:"
    //
    //    - `MSG("message"):       Print a raw white message
    //    - `INFO("message"):      Print a blue message with INFO: prefix
    //    - `SUCCESS("message"):   Print a green message if SUCCESS: prefix
    //    - `WARNING("message"):   Print an orange message with WARNING: prefix and increment warning counter
    //    - `CRITICAL("message"):  Print a purple message with CRITICAL: prefix and increment critical counter
    //    - `ERROR("message"):     Print a red message with ERROR: prefix and increment error counter
    //
    //    - `FAIL_IF(aSignal):                 Increment error counter if evaluaton is true
    //    - `FAIL_IF_NOT(aSignal):             Increment error coutner if evaluation is false
    //    - `FAIL_IF_EQUAL(aSignal, 23):       Increment error counter if evaluation is equal
    //    - `FAIL_IF_NOT_EQUAL(aSignal, 45):   Increment error counter if evaluation is not equal
    //    - `ASSERT(aSignal):                  Increment error counter if evaluation is not true
    //    - `ASSERT((aSignal == 0)):           Increment error counter if evaluation is not true
    //
    //  Available flag:
    //
    //    - `LAST_STATUS: tied to 1 is last macro did experience a failure, else tied to 0

    `UNIT_TEST("ADD")
	
	//add x1, x2, x3
	   //0:	003100b3          
	instr = 'h003100b3;

	#1;
	`FAIL_IF(rs1 != 2);
	`FAIL_IF(rs2 != 3);
	`FAIL_IF(rd  != 1);
	`FAIL_IF(dut.funct7 != `ADD_OR_AND_FUNCT7);
	`FAIL_IF(dut.funct3 != `ADD_FUNCT3);
	`FAIL_IF_NOT(dut.instr_R_type);
    `UNIT_TEST_END

    `UNIT_TEST("ADDI")
	
	//addi x1, x1, 1
	   //4:	00108093          	
	instr = 'h00108093;

	#2;
	`FAIL_IF(rd  != 1);
	`FAIL_IF(rs1 != 1);
	`FAIL_IF(imm != 1);
	`FAIL_IF(dut.funct7 != `ADD_OR_AND_FUNCT7);
	`FAIL_IF(dut.funct3 != `ADDI_FUNCT3);
	`FAIL_IF_NOT(dut.instr_I_type);
    `UNIT_TEST_END

    `UNIT_TEST("SUB")
	
	//sub x2, x3, x4
	   //8:	40418133          	
	instr = 'h40418133;

	#2;
	`FAIL_IF(rd  != 2);
	`FAIL_IF(rs1 != 3);
	`FAIL_IF(rs2 != 4);
	`FAIL_IF(dut.funct7 != `SUB_FUNCT7);
	`FAIL_IF_NOT(dut.instr_R_type);
    `UNIT_TEST_END

    `UNIT_TEST("MUL")
	
	//mul x2, x3, x4
	   //c:	02418133
	instr = 'h02418133;

	#2;
	`FAIL_IF(rd  != 2);
	`FAIL_IF(rs1 != 3);
	`FAIL_IF(rs2 != 4);
	`FAIL_IF(dut.funct7 != `MUL_FUNCT7);
	`FAIL_IF(dut.opcode != `OPCODE_ALU);
	`FAIL_IF_NOT(dut.instr_R_type);
    `UNIT_TEST_END


    `UNIT_TEST("LB")
	//lb x1, 1(x3)
	  //10:	00118083          	
	instr = 'h00118083;

	#2;
	`FAIL_IF(rd  != 1);
	`FAIL_IF(rs1 != 3);
	`FAIL_IF(imm != 1);
	`FAIL_IF(dut.funct3 != 0);
	`FAIL_IF(dut.opcode != `OPCODE_LOAD);
	`FAIL_IF_NOT(dut.instr_I_type);
	`FAIL_IF(dut.imm != 1);
    `UNIT_TEST_END

    `UNIT_TEST("LW")
	
	//lw x1, 1(x3)
	  //14:	0011a083  
	instr = 'h0011a083;

	#2;
	`FAIL_IF(rd  != 1);
	`FAIL_IF(rs1 != 3);
	`FAIL_IF(dut.funct3 != 2);
	`FAIL_IF(dut.opcode != `OPCODE_LOAD);
	`FAIL_IF_NOT(dut.instr_I_type);
	`FAIL_IF(dut.imm != 1);
    `UNIT_TEST_END

    `UNIT_TEST("SB")
	//sb x1, 1(x3)
	  //18:	001180a3 
	instr = 'h001180a3;

	#2;
	`FAIL_IF(rs2 != 1);
	`FAIL_IF(rs1 != 3);
	`FAIL_IF(dut.funct3 != 0);
	`FAIL_IF(imm != 1);
	`FAIL_IF(dut.opcode != `OPCODE_STORE);
	`FAIL_IF_NOT(dut.instr_S_type);
	`FAIL_IF(dut.imm != 1);
    `UNIT_TEST_END

    `UNIT_TEST("SW")
	
	//sw x1, 1(x3)
	  //1c:	0011a0a3 
	instr = 'h0011a0a3;

	#2;
	`FAIL_IF(rs2 != 1);
	`FAIL_IF(rs1 != 3);
	`FAIL_IF(dut.funct3 != 2);
	`FAIL_IF(dut.opcode != `OPCODE_STORE);
	`FAIL_IF_NOT(dut.instr_S_type);
	`FAIL_IF(dut.imm != 1);
    `UNIT_TEST_END

    // JAL, J, jumps are relative to the PC!!!
    
    // J se codifica como un JAL con rd 0
    `UNIT_TEST("J")
	
	//j b
	  //28:	ff5ff06f          	j	1c <b>
	instr = 'hff5ff06f;

	#2;
	`FAIL_IF(dut.opcode != `OPCODE_JUMP);
	`FAIL_IF(rd != 0);
	`FAIL_IF_NOT(dut.instr_J_type);
	`FAIL_IF(dut.imm + 'h28 != 'h1c);
    `UNIT_TEST_END

    `UNIT_TEST("JAL")
	
	//jal x1, b
	  //2c:	ff1ff0ef          	jal	ra,1c <b>
	instr = 'hff1ff0ef;

	#2;
	`FAIL_IF(dut.opcode != `OPCODE_JUMP);
	`FAIL_IF(rd != 1);
	`FAIL_IF_NOT(dut.instr_J_type);
	`FAIL_IF(dut.imm + 'h2c != 'h1c);
    `UNIT_TEST_END
    `UNIT_TEST("BEQ")
	
	//beq x1, x1, b
	  //34:	fe1084e3          	beq	ra,ra,1c <b>
	instr = 'hfe1084e3;

	#2;
	`FAIL_IF(dut.opcode != `OPCODE_BRANCH);
	`FAIL_IF(rs1 != 1);
	`FAIL_IF(rs2 != 1);
	`FAIL_IF_NOT(dut.instr_B_type);
	`FAIL_IF(dut.imm + 'h34 != 'h1c);
    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
