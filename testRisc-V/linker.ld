SECTIONS
{
    . = 0x1000;
    .text : { *(.text) }
    . = 0x3000;
    .data : { *(.data) }
    .bss : { *(.bss) }
}
