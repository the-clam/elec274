    .text
    .global _start
    .org 0x000

_start:
main:
    movi    sp, 0x7FFC              # initialize stack pointer to 0x7FFC
    
    movia   r3, K                   # load address of K
    ldw     r3, 0(r3)               # load value of K
    movia   r4, ALIST               # load address of ALIST
    movia   r5, BLIST               # load address of BLIST
    movia   r6, N                   # load address of N
    ldw     r6, 0(r6)               # load value of N

    call    GenerateOutputList      # call GenerateOutputList subroutine

_end:
    break
    br _end

# -------------------------------------------------------------------------------------------------

GenerateOutputList:                 # r3 is LISTA ptr, r4 is LISTB ptr, r5 is N
    subi    sp, sp, 20              # decrement sp by sufficient amount hold variables for subroutine
    stw     ra, 16(sp)              # must save due to call
    stw     r3, 12(sp)              # preserve original value of K
    stw     r4, 8(sp)               # preserve address of ALIST
    stw     r5, 4(sp)               # preserve address of BLIST
    stw     r6, 0(sp)               # preserve original value of N
    
gol_loop:
    ldw     r2, 0(r4)               # load element from ALIST to r2 to be passed to ComputeElement
                                    # r3 already loaded
    call ComputeElement             # call ComputeElement subroutine
    stw     r2, 0(r5)               # store computer number into LISTB

    addi    r4, r4, 4               # increase LISTA ptr
    addi    r5, r5, 4               # increase LISTB ptr
    subi    r6, r6, 1               # decrement N counter
    bgt     r6, r0, gol_loop        # if still numbers to iterate through, do loop again
    
    ldw     ra, 16(sp)              # restore values
    ldw     r3, 12(sp)
    ldw     r4, 8(sp) 
    ldw     r5, 4(sp) 
    ldw     r6, 0(sp) 
    addi    sp, sp, 20          
    ret

# -------------------------------------------------------------------------------------------------

ComputeElement:
    mul     r2, r2, r3              # do (c * v)
    subi    r2, r2, 1               # do -1
    ret                             # returns r2 as (c*v)-1

# -------------------------------------------------------------------------------------------------

CountLarger:



# -------------------------------------------------------------------------------------------------

    .org    0x1000
N:  .word   5
K:  .word   4
ALIST:  .word   -2, -1, 0, 1, 2
BLIST:  .skip   20
LARGER_COUNT:   .skip   4