; R5F10Y16ASP 2k 256 10pin

    .section ".vec", "a"
    .short  _start

    .macro _iv x
    .weak   \x
    \x = _default_handler
    .short  \x
    .endm

    .section ".ivec", "a"
    _iv _INTWDTI
    _iv _INTP0
    _iv _INTP1
    _iv _INTST0
    _iv _INTSR0
    _iv _INTSRE0
    _iv _INTTM01H
    _iv _INTTM00
    _iv _INTTM01
    _iv _INTAD
    _iv _INTKR

    .section ".opt", "a"
    .global _opt_bytes
_opt_bytes:
    .byte 0E0h     ; WDT disabled
    .byte 0F3h     ; RESET is RESET; POR 4.28V/4.20V
    .byte 0FDh     ; fHOCO = 1.25Mhz (V = 2.7V to 5.5V)
    .byte 05h      ; OCD disabled

    .text

    .extern _main
    .extern __stack

    .global _default_handler
    .type   _default_handler, @function
_default_handler:
    reti

    .global _start
    .type   _start, @function
_start:
    mov     es, #0
    movw    sp, #__stack

    call    !_main

_loop:
    halt
    br     $_loop
