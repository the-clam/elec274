    .org 0
    .global _start

_start:
        ldw     r2, N(r0)       # Load number of elements in list.
        mov     r3, r0          # Initialize sum to 0.
        movi    r4, LIST        # Load starting address of list.
LOOP:   ldw     r5, 0(r4)       # Load the next number in list.
        add     r3, r3, r5      # Accumulate number in sum.
        addi    r4, r4, 4       # Increment the pointer to the list.
        subi    r2, r2, 1       # Decrement the counter of elements.
        bgt     r2, r0, LOOP    # Repeat if end of list not reached.
        stw     r3, SUM(r0)     # Store final sum.

_end:   br      _end            # End of program. Infinite loop.

# --------------------------------------------------------------------

        .org 0x1000

N:      .word 3                 # Number of elements in list.
SUM:    .skip 4                 # Space to store sum of list.
LIST:   .word 0x4               # Start of list.
        .word 0x7               
        .word 0xc               # End of list.