# MIRI - Processor Architecture

## Testing framework
Testing will be done with [svut](https://github.com/dpretet/svut) framework.
- Create tests: *svutCreate* filename
- Run tests: *svutRun* [filename]

You can dump create the .vcd file for visualization if you want. It's commented out by default. It also creates
a clock and so on.

Open them with gtkwave filewave.vcd

### Problems
  - If you have more than 1 module per Verilog/SystemVerilog file the output is very weird. You can manually fix it
  but its best to avoid this if possible.
  - Follow the [svut Tutorial](https://github.com/dpretet/svut#tutorial) if you have problems with includes and so on (files.f is your friend) 
  - You have to follow the expected code style: every parameter is one new line and so on. **Check** your generated tests, if a parameter 
    is missing you know you have not followed the expected input style.
    
## ISA
[RISC-V](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf) Chapter 2 - RV32I Base Integer Instruction Set

- [ ] Can we get a RISC-V compiler to test our processor?

- [ ] ADD, SUB, MUL, LDB, LDW, STB, STW, BEQ, JUMP  (whatever ISA you decide to use)
### Instructions
- [ ] ADD: 
  add rd, rs1, rs2
  
  rd     = instr[11:7] 
  rs1    = instr[19:15]
  rs2    = instr[24:20]
  opcode = 7'b0
  funct3 = instr[14:12]


