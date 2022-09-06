    .text
    .global _start
    .org 0x0000

_start:
    movia   sp, 0x007FFFFC

    ldw     r2, N(r0)
    movia   r3, LIST1
    movia   r4, LIST2
    call    CopyListPos
    stw     r2, NUM_GT_ZERO(r0)

_end:
    break
    br _end

# -------------------------------------------------------------------

CopyListPos:
    subi    sp, sp, 20
    stw     ra, 16(sp)
    stw     r3, 12(sp)
    stw     r4, 8(sp)
    stw     r5, 4(sp)
    stw     r6, 0(sp)

    mov     r5, r0

clp_loop:
    ldw     r6, 0(r3)
    ble     r6, r0, clp_end_if 
clp_if:
    addi    r5, r5, 1
    stw     r6, 0(r4)
clp_end_if:
    subi    r2, r2, 1
    addi    r3, r3, 4
    addi    r4, r4, 4
    bgt     r2, r0, clp_loop

    mov     r2, r5

    ldw     ra, 16(sp)
    ldw     r3, 12(sp)
    ldw     r4, 8(sp)
    ldw     r5, 4(sp)
    ldw     r6, 0(sp)
    addi    sp, sp, 20

    ret

# -------------------------------------------------------------------

    .org	0x1000
N:  .word 6
LIST1:  .word -1, 2, -4, 0, -16, 32
LIST2:  .skip 24
NUM_GT_ZERO: .skip 4
    .end