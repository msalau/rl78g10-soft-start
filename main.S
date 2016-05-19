    .text

    .equ P0,     0FFF00H
    .equ PM0,    0FFF20H
    .equ PMC0,   0F0060H
    .equ STEP,   10

    ;; One tick is 800ns

_delay:
    ;;  Delay will be ~AX*(2+4) cycles (plus few cycles to enter and return from the routine)
    cmpw    ax, #0
    sknz
    ret
_delay_loop:
    subw    ax, #1              ; Use subw, because decw doesn't set flags (according to R01US0015EJ0220)
    bnz     $_delay_loop
    ret

    .global _main
_main:
    ;; Start time is expected to be 528ms

    ; Set P04 to output push-pull mode
    clr1    !PMC0.4
    clr1    PM0.4
_main_restart:
    movw    bc, #100            ; Initial On-time
    movw    de, #1000           ; Initial Off-time
_main_loop:
    ;; Turn output off
    clr1    P0.4
    ;; Off-time delay
    movw    ax, de
    call    !_delay
    ;; Increase On-time
    movw    ax, bc
    addw    ax, #STEP
    movw    bc, ax

    ;; Turn output on
    set1    P0.4
    ;; On-time delay
    movw    ax, bc
    call    !_delay
    ;; Decrease Off-time
    movw    ax, de
    subw    ax, #STEP
    bc      $_done              ; If no Off-time left, exit
    movw    de, ax

    br      $_main_loop

_done:
    ;; Turn output off
    clr1    P0.4
    ;; Small delay between loops
    ;; 480ms delay is made of 100 4.8ms delays
    movw    ax, #100
_pause:
    ;; 4.8ms delay
    push    ax
    movw    ax, #1000
    call    !_delay
    pop     ax

    subw    ax, #1
    bnz     $_pause

    br      $_main_restart

    ;; Sleep forever
    di
    halt
    br      $.
