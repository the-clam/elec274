	.text
	.global _start
	.org    0x0000

_start:                         # == INITILIAZATION ==       
        ldw     r2, N(r0)       # r2 is the loop counter (decrementing)                           
        movi    r3, LIST        # r3 points to the first list element
        movi    r4, 0           # r4 accumulates the sum
LOOP:                           # == LOOP BODY START ==
        ldw     r5, 0(r3)       # get next element from list
        add     r4, r4, r5      # add element to accumulating sum in r4
        addi    r3, r3, 4       # advance the list pointer
        subi    r2, r2, 1       # (start of branching) decrement counter
        bgt     r2, r0, LOOP    # has count reached zero?
                                # == LOOP BODY END ==
        stw     r4, SUM(r0)     # write final accumulated value to memory
_end:
        br      _end

# ------------------------------------------------------------------------

        .org    0x1000
SUM:    .skip   4               # reserve 4 btes of space for final sum
N:      .word   5               # indicate that there are N=5 items in list
LIST:   .word   12, 0xFFFFFFFE, 7, -1, 2    # hex value is -2 in two's-comp.

        .end