# MIRI - Processor Architecture

## Resources

[BrunoLevy tutorial](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV/PIPELINE.md#step-9-return-address-stack)


[RISCV assembler](https://github.com/carlosedp/riscvassembler), alternative to compiling with gcc for rv32i. Might be interesting...

### Compile
```
riscv64-unknown-elf-gcc assembly.s -O0 -c -march=rv32i -mabi=ilp32 && riscv64-unknown-elf-objcopy --only-section=.text --output-target binary assembly.o assembly.bin
```

```
riscv64-unknown-elf-g++ test.cpp  -O0 -S -march=rv32i -mabi=ilp32
riscv64-unknown-elf-objdump -D -b binary -m riscv test.o
```


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
[RISC-V](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf) Chapter 2 - RV32I Base Integer Instruction Set. **Multiplication is in M extension**

- [ ] Can we get a RISC-V compiler to test our processor?

Instruction (Instr. format)

![image](https://user-images.githubusercontent.com/42119338/193021954-1bd02364-72a5-4f31-b157-6cc7f04adbf6.png)


![image](https://user-images.githubusercontent.com/42119338/193022040-62eebefe-c568-4da3-9974-b6f305db8b63.png)


- [ ] ADD (R), SUB (R), MUL (R), LDB (I), LDW (I), STB (I), STW (I) , BEQ (B), JUMP(J)  (whatever ISA you decide to use)
### Instructions
[Opcodes](https://github.com/ucb-bar/riscv-sodor/blob/master/src/main/scala/common/instructions.scala) Useful for decoding

- [ ] ADD **(R)**: 
  add rd, rs1, rs2
  
  rd     = instr[11:7] 

  rs1    = instr[19:15]
  
  rs2    = instr[24:20]
  
  funct7 = 7'b0
  
  funct3 = instr[14:12]
  
  opcode = instr[6:0]
  
  
  


