SECTIONS
{
    . = 0x1000;
    .text : { *(.text) }
    . = 0x4000;
    .data : { *(.data) }
    .bss : { *(.bss) }
}
