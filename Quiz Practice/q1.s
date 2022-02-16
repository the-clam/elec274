    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC
    ldw     r2, N(r0)
    movia   r3, LIST1(r0)
    movia   r4, LIST2(r0)
    call    CopyModify
    stw     r2, REPL_COUNT(r0)

_end:
    break
    br _end

# ---------------------------------------

CopyModify:
    subi    sp, sp, 24
    stw     ra, 20(r0)
    stw     r3, 16(r0)
    stw     r4, 12(r0)
    stw     r5, 8(r0)
    stw     r6, 4(r0)
    stw     r7, 0(r0)

    mov     r5, r0

cm_loop:
    ldw     r6, 0(r3)
    movi    r7, 100
    bgt     r6, r7, cm_if1
    movi    r7, -100
    blt     r6, r7, cm_if2
    br      cm_endif
cm_if1:
    movi    r6, 100
    addi    r5, r5, 1
    br      cm_endif
cm_if2:
    movi    r6, -100
    addi    r5, r5, 1
    br      cm_endif    
cm_endif:
    stw     r6, 0(r4)
    subi    r2, r2, 1
    addi    r3, r3, 4
    addi    r4, r4, 4
    bgt     r2, r0, cm_loop

    mov     r2, r5

    ldw     ra, 20(r0)
    ldw     r3, 16(r0)
    ldw     r4, 12(r0)
    ldw     r5, 8(r0)
    ldw     r6, 4(r0)
    ldw     r7, 0(r0)
    addi    sp, sp, 24

    ret

# ---------------------------------------

    .org    0x1000
N:  .word   6
LIST1:  .word   123, 0, -179, 0x800, 0x2A, 100
LIST2:  .skip   24
REPL_COUNT: .skip   4
    .end