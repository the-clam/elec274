    .text
    .global _start
    .org 0x0000

_start:
    ldw     r2, X(r0)
    ldw     r3, Y(r0)
    add     r2, r2, r3
    ldw     r3, Z(r0)
    add     r2, r2, r3
    stw     r2, W(r0)
    break
    
    .org    0x1000
W:  .word   9
X:  .word   3
Y:  .word   2
Z:  .word   1

    .end