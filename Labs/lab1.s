        .text
        .global _start
        .org    0x20

_start:
        ldw     r2, A(r0)       # == FIRST PSEUDOCODE LINE ==
        ldw     r3, C(r0)
        add     r2, r2, r3
        ldw     r3, K(r0)
        mul     r2, r2, r3
        stw     r2, B(r0)
        ldw     r3, J(r0)       # == SECOND PSEUDOCODE LINE ==
        sub     r2, r2, r3
        stw     r2, X(r0)
        ldw     r3, F(r0)       # == THIRD PSEUDOCODE LINE ==
        addi    r2, r2, 4
        div     r2, r2, r3
        stw     r2, W(r0)
_end:
        break
        br      _end

# ------------------------------------------------------------------------

        .org    0x3000
A:      .word   1               # store number 1 in variable A
B:      .skip   4               # reserve 4 btes for variable B
C:      .word   2               # store number 2 in variable C
F:      .word   3               # store number 3 in variable F
J:      .word   4               # store number 4 in variable J
K:      .word   5               # store number 5 in variable K
W:      .skip   4               # reserve 4 btes for variable W
X:      .skip   4               # reserve 4 btes for variable X

        .end