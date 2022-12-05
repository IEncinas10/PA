SECTIONS
{
    . = 0x2000;
    .text : { *(.text) }
    . = 0xA000;
    .data : { *(.data) }
    .bss : { *(.bss) }
}
