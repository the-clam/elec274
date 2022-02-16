    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC
    ldw     r3, N(r0)
    movia   r4, LIST
main_loop:
    ldw     r2, 0(r4)
    call    theFunction
    stw     r2, 0(r4)
    addi    r4, r4, 4
    subi    r3, r3, 1
    bgt     r3, r0, main_loop

_end:
    break
    br _end

# ---------------------------------------

theFunction:
    subi    sp, sp, 16
    stw     ra, 12(r0)
    stw     r3, 8(r0)
    stw     r4, 4(r0)
    stw     r5, 0(r0)

    movi    r5, 2
    div     r5, r2, r5
    muli    r5, r5, 2
    sub     r5, r2, r5
    beq     r5, r0, then
if:
    subi    r2, r2, 3
    muli    r2, r2, 2
    br      end_if
then:
    subi    r2, r5, 5
    muli    r2, r2, 16
end_if:

    ldw     ra, 12(r0)
    ldw     r3, 8(r0)
    ldw     r4, 4(r0)
    ldw     r5, 0(r0)
    addi    sp, sp, 16

    ret

# ---------------------------------------

    .org    0x1000
N:  .word   8
LIST:   .word -42, 16, 30, -202, 219, 255, 100, 0
    .end