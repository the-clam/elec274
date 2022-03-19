    .text
    .global _start
    .org 0x000

_start:
main:
    movi    sp, 0x7FFC              # initialize stack pointer to 0x7FFC
    
    # PREP VARIABLES FOR SUBROUTINE GENERATEOUTPUTLIST
    movia   r2, ALIST               # load address of ALIST
    movia   r3, BLIST               # load address of BLIST
    movia   r4, N                   # load address of N
    ldw     r4, 0(r4)               # load value of N
    movia   r5, K                   # load address of K
    ldw     r5, 0(r5)               # load value of K
    call    GenerateOutputList      # call GenerateOutputList subroutine

    # PREP VARIABLES FOR SUBROUTINE COUNTERLARGER
    movia   r2, BLIST               # load address of BLIST
    movia   r3, N                   # load address of N
    ldw     r3, 0(r3)               # load value of N
    movi    r4, 4                   # load value of 4 into value
    call    CountLarger             # call CountLarger subroutine
    
	stw		r2, LARGER_COUNT(r0)    # store final count to memory
	
_end:
    break
    br _end

# -------------------------------------------------------------------------------------------------

GenerateOutputList:                 # r3 is LISTA ptr, r4 is LISTB ptr, r5 is N
    subi    sp, sp, 20              # decrement sp by sufficient amount hold variables for subroutine
    stw     ra, 16(sp)              # must save due to call
    stw     r3, 12(sp)              # outlst address
    stw     r4, 8(sp)               # loop counter
    stw     r5, 4(sp)               # preserve original value of K
    stw     r6, 0(sp)               # hold inlst address

    mov     r6, r2                  # move inlst pointer out of r2

gol_loop:

    # PREP VARIABLES FOR COMPUTEELEMENT SUBROUTINE
    ldw     r2, 0(r6)               # load element from ALIST to r2 to be passed to ComputeElement
                                    # r5 already loaded
    call ComputeElement             # call ComputeElement subroutine
    stw     r2, 0(r3)               # store computed number into LISTB

    addi    r6, r6, 4               # increase LISTA ptr
    addi    r3, r3, 4               # increase LISTB ptr
    subi    r4, r4, 1               # decrement N counter
    bgt     r4, r0, gol_loop        # if still numbers to iterate through, do loop again
    
    ldw     ra, 16(sp)              # restore values
    ldw     r3, 12(sp)
    ldw     r4, 8(sp)
    ldw     r5, 4(sp) 
    ldw     r6, 0(sp)
    addi    sp, sp, 20               
    ret                             # return to main

# -------------------------------------------------------------------------------------------------

ComputeElement:
    mul     r2, r2, r5              # do (c * v)
    subi    r2, r2, 1               # do -1
    ret                             # returns r2 as (c*v)-1

# -------------------------------------------------------------------------------------------------

CountLarger:
    subi    sp, sp, 12              # decrement sp by sufficient amount hold variables for subroutine
    stw     ra, 16(sp)              # must save due to call
    stw     r3, 12(sp)              # hold loop counter n
    stw     r4, 8(sp)               # hold value of 4
    stw     r5, 4(sp)               # hold value from list
    stw     r6, 0(sp)               # hold list pointer for list
    
    mov     r6, r2                  # move list pointer to r6
    mov     r2, r0                  # set r2 to 0 to be used as counter

cl_loop:
    ldw     r5, 0(r6)               # load element from list
    ble     r5, r4, cl_then         # if number is less than or equal to r4, do not add count 
cl_if:
    addi    r2, r2, 1               # increase count
cl_then:
    addi    r6, r6, 4               # increment list pointer forward
    subi    r3, r3, 1               # decrement loop counter
    bgt     r3, r0, cl_loop         # if still numbers to iterate through, do loop again

    ldw     ra, 16(sp)              # restore values
    ldw     r3, 12(sp)
    ldw     r4, 8(sp)
    ldw     r5, 4(sp)
    ldw     r6, 0(sp)
    addi    sp, sp, 12 
    ret                             # returns r2 with value
    
# -------------------------------------------------------------------------------------------------

    .org    0x1000
ALIST:  .word   -2, -1, 0, 1, 2
BLIST:  .skip   20
N:  .word   5
K:  .word   4
LARGER_COUNT:   .skip   4