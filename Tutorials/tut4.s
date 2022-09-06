    .text
    .global _start
    .org 0x0000

_start:
main:
    movi    sp, 0x7FFC      # last word that can be addressable, assign to stack pointer

    movi    r2, LIST        # assign r2 to address of list
    ldw     r3, N(r0)       # load the number of items from memory addr N in the list into r3
#   movia   r3, N           # load address of number of items into r3 (if > 16bits)
#   ldw     r3, 0(r3)       # load the number of items into r3 (from address pointed to from above)
    call 	ZeroCount       # call the ZeroCount subroutine
    stw     r2, ZCOUNT(r0)  # store the counter number of zeros into ZCOUNT

_end:
    break
    br _end

# -------------------------------------------------------------------------------------------------

ZeroCount:  # r2 is listptr, r3 is num of elements
    subi    sp, sp, 16      # decrement the stack pointer by sufficient amount to hold variables
    stw     ra, 12(sp)      # must save due to nested call
    stw     r3, 8(sp)       # preserve original value of N
    stw     r4, 4(sp)       # pointer in subroutine
    stw     r5, 0(sp)       # used to count zeros

    movi    r5, 0           # set r5 to 0 for use as zero counter
    mov     r4, r2          # local pointer within subroutine

zc_loop:
zc_if:
    ldw     r2, 0(r4)       # load element from list into r2 to be passed to CheckIfZero
    call    CheckIfZero     # check value in list
    beq     r2, r0, zc_end_if # if false, then skip the count
zc_then:
    addi    r5, r5, 1       # count = count + 1
zc_end_if:
    addi    r4, r4, 4       # increment pointer forward
    subi    r3, r3, 1       # decrement loop counter
    bgt     r3, r0, zc_loop # if still numbers go to go through, do loop again

    mov     r2, r5          # store result in r2 for return

    ldw     ra, 12(sp)      # must save due to nested call
    ldw     r3, 8(sp)       # preserve original value of N
    ldw     r4, 4(sp)       # pointer in subroutine
    ldw     r5, 0(sp)       # used to count zeros
    addi    sp, sp, 16      # increment the stack pointer back to original value
    ret

# -------------------------------------------------------------------------------------------------

CheckIfZero:
ciz_if:
    bne     r2, r0, ciz_else
ciz_then:
    movi    r2, 1
    br      ciz_end_if
ciz_else:
    mov     r2, r0
ciz_end_if:
    ret

# -------------------------------------------------------------------------------------------------

    .org 0x1000
ZCOUNT: .skip 4
N:      .word 5
LIST:   .word 34, 0, 57, 91, 0

    .end