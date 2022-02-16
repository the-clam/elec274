    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC
    movia   r2, N(r0)
    movia   r3, LIST(r0)
    call    DivideByTwoOrAddOne
    

_end:
    break
    br _end

# ---------------------------------------

DivideByTwoOrAddOne:
    subi    sp, sp, 20
    stw     ra, 16(r0)
    stw     r2, 12(r0)
    stw     r3, 8(r0)
    stw     r4, 4(r0)
    stw     r5, 0(r0)

div_loop:
    ldw     r4, 0(r3)
    movi    r5, 2
    div     r5, r4, r5
    muli    r5, r5, 2
    sub     r5, r4, r5
    beq     r5, r0, div_then
div_if:
    addi    r4, r4, 1   #odd
    stw     r4, 0(r3)
    br      div_endif
div_then:               #even
    movi    r5, 2
    div     r4, r4, r5
    stw     r4, 0(r3)
div_endif:
    subi    r2, r2, 1
    addi    r3, r3, 4
    bgt     r2, r0, div_loop

    ldw     ra, 16(r0)
    ldw     r2, 12(r0)
    ldw     r3, 8(r0)
    ldw     r4, 4(r0)
    ldw     r5, 0(r0)
    addi    sp, sp, 20

    ret

# ---------------------------------------

    .org    0x1000
N:  .word   8
LIST:   .word   -42, 16, 30, -202, 0xDB, 0xFF, 100, 0
    .end