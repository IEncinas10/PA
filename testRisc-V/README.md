[https://ecomaikgolf.com/programming/xwgqclvo.html](https://ecomaikgolf.com/programming/xwgqclvo.html)

```
riscv64-unknown-elf-gcc -O0 vectorCopy.S -static -nostdlib -ffreestanding -fno-stack-protector -fno-stack-check -nolibc -Ttext=0x0 -no-pie
```

```
riscv64-unknown-elf-objcopy -S -O verilog vectorCopy.o assembly.hex
```

Borrar las lineas con los "@..."

Con NVIM (Cntrl - V mode) borrar los espacios y juntar en grupos de 4 bytes (32 bits)