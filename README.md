# MIRI - Processor Architecture

## Documentation
[Google docs](https://docs.google.com/document/d/18r8yGa84ThLDYwM06uA_4UGuCUN9DsUpggfJ-Dybp5g/edit?usp=sharing)

## Verilog
- [Wire vs regs](https://inst.eecs.berkeley.edu//~cs150/Documents/Nets.pdf)
- [https://stackoverflow.com/questions/33459048/what-is-the-difference-between-reg-and-wire-in-a-verilog-module#:~:text=wire%20elements%20must%20be%20continuously,it%20can%20store%20some%20value.](https://stackoverflow.com/questions/33459048/what-is-the-difference-between-reg-and-wire-in-a-verilog-module#:~:text=wire%20elements%20must%20be%20continuously,it%20can%20store%20some%20value.)

## Exceptions
Protect the wenable for DCache and TLB when exceptions are raised

Also, perhaps stop issuing misses to the cache if an exception was produced, no point in fetching data?

Interrupts wired into WB stage. **DIFERENCE** if interrupt, instr at WB finishes but if we have an exception we don't finish, so return PC is PC or PC+4, also we have or dont have to write into RF

## Resources

[BrunoLevy tutorial](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV/PIPELINE.md#step-9-return-address-stack)


[RISCV assembler](https://github.com/carlosedp/riscvassembler), alternative to compiling with gcc for rv32i. Might be interesting...

### Compile
```
riscv64-unknown-elf-gcc assembly.s -O0 -c -march=rv32im -mabi=ilp32 && riscv64-unknown-elf-objcopy --only-section=.text --output-target binary assembly.o assembly.bin

xxd -b assembly.bin

riscv64-unknown-elf-objdump -S assembly.o

riscv64-unknown-elf-gcc assembly.s -O0 -c -g -march=rv32im -mabi=ilp32 && riscv64-unknown-elf-objcopy --only-section=.text --output-target binary assembly.o assembly.bin && riscv64-unknown-elf-objdump -d --disassembler-color=color assembly.o
```
La salida de objdump está mal (las instrucciones de la derecha). Si compilamos con -g y hacemos objdump obtendremos las instrucciones correctas


```
riscv64-unknown-elf-g++ test.cpp  -O0 -c -march=rv32im -mabi=ilp32
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

- [X] ADD (R), SUB (R), MUL (R), LDB (I), LDW (I), STB (I), STW (I) , BEQ (B), JUMP(J)  (whatever ISA you decide to use)

## Posibles ampliaciones
- [Caché muy lista¿?](https://personals.ac.upc.edu/jmanel/papers/ics97.pdf) Revisar si nos vale
  
  


