[https://ecomaikgolf.com/programming/xwgqclvo.html](https://ecomaikgolf.com/programming/xwgqclvo.html)

https://github.com/sifive/elf2hex

```
riscv64-unknown-elf-elf2hex --bit-width 32 --input a.out --output output.hex
```

```
riscv64-unknown-elf-gcc -O0 vectorCopy.S -march=rv32im --no-pie -mabi=ilp32 -static -nostdlib -ffreestanding -fno-stack-protector -fno-stack-check -nolibc -T linker.ld
```

```
riscv64-unknown-elf-objcopy -S -O verilog vectorCopy.o assembly.hex --reverse-bytes=4 --remove-section=.riscv.attributes --verilog-data-width=4
```

Borrar las lineas con los "@..."

Con NVIM (Cntrl - V mode) borrar los espacios y juntar en grupos de 4 bytes (32 bits)
