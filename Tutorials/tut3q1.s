        .text
        .global _start
        .org 0x0000

_start:
        ldw     r2, X(r0)
        ldw     r3, Y(r0)
        sub     r3, r2, r3
        ldw     r4, Z(r0)
        sub     r2, r2, r4
        add     r2, r3, r2
        subi    r2, r2, 3
        stw     r2, W(r0)
_end:
        break
        br      _end

# --------------------------

        .org 0x1000
W:      .word 8
X:      .word 6
Y:      .word 4
Z:      .word 1

        .end