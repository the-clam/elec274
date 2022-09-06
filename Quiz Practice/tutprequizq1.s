    .text
    .global _start
    .org 0x000

_start:
    movia       sp, 0x007FFFFC
    movi        r2, LIST
    movi        r3, N
    ldw         r3, 0(r3)
    call        CalcAvg
    movi        r3, AVG
    stw         r2, 0(r3)
    mov         r4, r2
    movi        r2, LIST
    movi        r3, N
    ldw         r3, 0(r3)
    call        CountGTorEQAvg
    movi        r5, N_GT_OR_EQ
    stw         r2, 0(r5)
    sub         r2, r2, r3
    movi        r5, N_LT
    stw         r2, 0(r5)

    movi        r2, LIST            # start of tutorial exercise
    ldw         r3, N
    ldw         r4, AVG
    call        DiffFromAvg

_end:
    break
    br  _end

# -------------------------------------------------------------------------------------------------

DiffFromAvg:
    subi    sp, sp, 12
    stw     r3, 8(sp)
    stw     r4, 4(sp)
    stw     r5, 0(sp)

dfa_loop:
    ldw     r5, 0(r2)
    sub     r5, r5, r4
    stw     r5, 0(r2)
    addi    r2, r2, 4
    subi    r3, r3, 1
    bgt     r3, r0, dfa_loop
    
    ldw     r3, 8(sp)
    ldw     r4, 4(sp)
    ldw     r5, 0(sp)
    addi    sp, sp, 12

    ret

# -------------------------------------------------------------------------------------------------

CalcAvg:
    subi        sp, sp, 12
    stw         r3, 8(sp)           # orig N
    stw         r4, 4(sp)           # list element
    stw         r5, 0(sp)           # sum

    movi        r5, 0               # sum = 0

calc_loop:
    ldw         r4, 0(r2)           # read list[i]
    add         r5, r5, r4          # sum = sum + list[i]
    addi        r2, r2, 4          # advance list pointer
    subi        r3, r3, 1           # decrement loop counter
    bgt         r3, r0, calc_loop   # determine if loop complete

    ldw         r3, 8(sp)           # get orig N
    divu        r2, r5, r3          # avg = sum/n (return value)

    ldw         r3, 8(sp)
    ldw         r4, 4(sp)
    ldw         r5, 0(sp)
    addi        sp, sp, 12
    ret

# -------------------------------------------------------------------------------------------------

CountGTorEQAvg:
    subi        sp,sp,16
    stw         r3, 12(sp)          # orig N
    stw         r4, 8(sp)           # orig avg
    stw         r5, 4(sp)           # list element
    stw         r6, 0(sp)           # count

    movi        r6, 0               # count = 0

count_loop:
if:
    ldw     r5, 0(r2)               # read list[i]
    blt     r5, r4, end_if          # skip if list[i] < avg
then:
    addi    r6, r6, 1               # count = count + 1
end_if:
    addi    r2, r2, 4               # advance list pointer
    subi    r3, r3, 1               # decrement loop counter
    bgt     r3, r0, count_loop      # determine if loop is finished

    mov r2, r6                     # return count

    stw         r3, 12(sp)
    stw         r4, 8(sp)
    stw         r5, 4(sp)
    stw         r6, 0(sp)
    addi        sp, sp, 16 
    ret

# -------------------------------------------------------------------------------------------------

    .org        0x1000
N:  .word       6                   # number of items in list
LIST:   .word       44,52,67,74,82,93      # definition of elemnts in list
AVG:    .skip   4                   # reserve one word for avg
N_GT_OR_EQ: .skip 4                 # reserve one word for n_gt_or_eq
N_LT:   .skip 4                     # reserve one word for n_lt
    .end