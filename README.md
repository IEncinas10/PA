# MIRI - Processor Architecture

## Correction guide

### Architectural state

- [ ] Special register rm0 for holding the PC the OS should return to on exceptions: ROB ex_pc signal. We could just hook up the rob_ex_pc wire from core.sv to anything and call it rm0, or just say that rm0 is inside ROB.
- [ ] Faulting addr is held in mem_ex_v_addr inside ROB.
- [ ] We differenciate from iTLB exceptions and dTLB exceptions, but that's it

### Interface to OS
We **don't have OS code**. We do boot at PC = 0x1000, and when we get an exception we jump to 0x2000 and **stay there forever**

https://github.com/IEncinas10/PA/blob/master/src/fetch_stage.sv

### Instruction set

Memory: lw, lb, sw, sb

Branches: jump (not jal although jump is jal rd=0), beq, bne, bge, blt

ALU: auipc (needed to support la - load address for symbols), add addi, or, and...

M extension: good old multiplication

Summary: required + some others, but not too many.

### Caches

Directly mapped.

We take 5 cycles to go to memory but we can make 1 request per cycle:

|  | Cycles |  |  |  |  |  |  |
|---|---|---|---|---|---|---|---|
| Request | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
| R1 | Create req | Wait | Wait | Wait | Wait | Wait | Recv response |
| R2 | - | Create req | Wait | Wait | Wait | Wait | Wait |
| R3 | - | - | Create req | Wait | Wait | Wait | Wait |
| R4 | - | - | - | - | Create req | Wait | Wait |

- Wrong: delay from Memory to Cache is 1 cycle instead of 5 
- No unaligned support

### Pipeline(s)
F D E Wb
F D E Mem Wb
F D M1 M2  M3  M4 M5 Wb

- Complete set of bypasses: one from the execution stages themselves, other from the writeback registers (write port to ROB) and another one from the ROB.
- Reorder buffer
- Store buffer

### Virtual memory
Again, no OS code. Hardware *Page walker*. We take a configurable amount of cycles to get the translation from our TLBs, and then output the translation to be used by the caches (or signal exception). **Agreed in class**

Only accessing page 0 raises an exception.

Always enabled, again, no OS.

### Performance tests

## Test

- Store Buffer bypass present in sumSquares.c
- veccopy_optimized.s is a vector copy that operates in bundles of 4 elements (much faster because we don't fight over cache lines)
- loadadd.s shows how we can do independent adds while a load is waiting for memory data

### Links¿?
https://github.com/UCSBarchlab/PyRTL

## Documentation
[Google docs](https://docs.google.com/document/d/18r8yGa84ThLDYwM06uA_4UGuCUN9DsUpggfJ-Dybp5g/edit?usp=sharing)

## Verilog
- [Wire vs regs](https://inst.eecs.berkeley.edu//~cs150/Documents/Nets.pdf)
- [https://stackoverflow.com/questions/33459048/what-is-the-difference-between-reg-and-wire-in-a-verilog-module#:~:text=wire%20elements%20must%20be%20continuously,it%20can%20store%20some%20value.](https://stackoverflow.com/questions/33459048/what-is-the-difference-between-reg-and-wire-in-a-verilog-module#:~:text=wire%20elements%20must%20be%20continuously,it%20can%20store%20some%20value.)



## Exceptions

If iTLB raises exception, that exception is written into the ROB at decode stage.
If dTLB raises exception, that exception is written into the ROB at MEM_WB stage.

When the offending exception becomes the head of the ROB, we jump to 0x2000 and stay there forever, we reset everything. Because we're lazy we also reset the register file although we shouldn't. Fixing it would be easy but there isn't too much point to it.

## Resources

[BrunoLevy tutorial](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV/PIPELINE.md#step-9-return-address-stack)


[RISCV assembler](https://github.com/carlosedp/riscvassembler), alternative to compiling with gcc for rv32i. Might be interesting...

### Compile

https://github.com/IEncinas10/PA/tree/master/testRisc-V


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

- [X] ADD (R), SUB (R), MUL (R), LDB (I), LDW (I), STB (I), STW (I) , BEQ (B), JUMP(J)  (whatever ISA you decide to use)

## Posibles ampliaciones
- [Caché muy lista¿?](https://personals.ac.upc.edu/jmanel/papers/ics97.pdf) Revisar si nos vale
  
  


