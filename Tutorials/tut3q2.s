        .text
        .global _start
        .org 0x0000

_start:
        ldw     r2, N(r0)
        movi    r4, LIST
        mov     r5, r0
LOOP:   
IF:
        ldw     r3, 0(r4)
        bne     r3, r0, END_IF
THEN:
        addi    r5, r5, 1
END_IF:
        addi    r4, r4, 4
        subi    r2, r2, 1
        bgt     r2, r0, LOOP

        stw     r5, ZCOUNT(r0)

_end:
        break
        br _end

# ------------------------------------------

        .org 0x1000
ZCOUNT:    .skip   4
N:      .word 5
LIST:   .word 34, 0, 57, 91, 0
