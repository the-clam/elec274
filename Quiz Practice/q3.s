    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC
    ldw     r2, N(r0)
    movia   r3, LIST
    call    MulTenOrSetZero
    stw     r2, Z_COUNT(r0)

_end:
    break
    br _end

# ---------------------------------------

MulTenOrSetZero:
    subi    sp, sp, 12
    stw     r3, 8(sp)
    stw     r4, 4(sp)
    stw     r5, 0(sp)

    mov     r5, r0
    
loop:
if:
    ldw     r4, 0(r3)
    bge     r4, r0, else_if
then:
    stw     r0, 0(r3)
    addi    r5, r5, 1
    br      end_if
else_if:
    muli    r4, r4, 10
    stw     r4, 0(r3)
end_if:
    addi    r3, r3, 4
    subi    r2, r2, 1
    bgt     r2, r0, loop

    mov     r2, r5

    ldw     r3, 8(sp)
    ldw     r4, 4(sp)
    ldw     r5, 0(sp)
    addi    sp, sp, 12

    ret

# ---------------------------------------

    .org    0x1000
N:  .word   8
LIST:   .word   -42, 16, 30, -202, 0xDB, 0xFF, 100, 0
Z_COUNT:    .skip   4
    .end