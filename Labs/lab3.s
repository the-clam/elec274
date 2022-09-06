    .equ		JTAG_UART_BASE,		0x10001000
    .equ		DATA_OFFSET,		0
    .equ		STATUS_OFFSET,		4
    .equ		WSPACE_MASK,		0xFFFF

    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC
    movia   r2, NAME_STRING
    call    PrintString

    movia   r2, LIST1
    movia   r3, LIST2
    movia   r4, N
    call    CopyListWithZeroCheck

_end:
    break
    br _end

# ------------------------------------------------------------

CopyListWithZeroCheck:
    subi    sp, sp, 28
    stw     ra, 24(sp)
    stw     r2, 20(sp)   # list 1 pointer (initially), temp for parameter passing (in subroutine)
    stw     r3, 16(sp)   # list 2 pointer
    stw     r4, 12(sp)   # num pointer
    stw     r5, 8(sp)   # list 1 pointer temp
    stw     r6, 4(sp)   # count
    stw     r7, 0(sp)   # pointer increments

    mov     r5, r2
    mov     r6, r0
    movia   r2, COPY_STRING
    call    PrintString

    ldw     r4, 0(r4)       # load counter value into r4

LOOP:   
    movia   r2, PERIOD_STRING
    call    PrintString

    ldw     r2, 0(r5)
    call    PrintHexDigit

    ldw     r2, 0(r5)
    bne		r2, r0, clwzc_not
    addi    r6, r6, 1
clwzc_not:
    stw     r2, 0(r3)    

    addi    r3, r3, 4
    addi    r5, r5, 4
    subi    r4, r4, 1
    bgt     r4, r0, LOOP
    
    stw     r6, N(r0)

    movi    r2, '\n'
    call    PrintChar
    ldw     r2, N(r0)
    call    PrintHexDigit
    movia   r2, END_STRING
    call    PrintString   
    
    ldw     ra, 24(sp)
    ldw     r2, 20(sp)   # list 1 pointer (initially), temp for parameter passing (in subroutine)
    ldw     r3, 16(sp)   # list 2 pointer
    ldw     r4, 12(sp)   # num pointer
    ldw     r5, 8(sp)   # list 1 pointer temp
    ldw     r6, 4(sp)   # count
    ldw     r7, 0(sp)   # pointer increments
    addi    sp, sp, 28

    ret
    
# ------------------------------------------------------------

PrintHexDigit:
    subi    sp, sp, 12                  # save reg values for use
    stw     ra, 8(sp)                   
    stw     r2, 4(sp)                   
    stw     r3, 0(sp)                   # hold constant for comparison

phd_if:
    movi    r3, 10
    bge     r2, r3, phd_else
phd_then:
    addi    r2, r2, '0'                 # store appropriate ASCII representation for PrintChar (<10)
    br      phd_end_if
phd_else:
    subi    r2, r2, 10
    addi    r2, r2, 'A'                 # store appropriate ASCII representation for PrintChar (>10)
phd_end_if:
    call    PrintChar                   # argument ready in r2
    
    ldw     ra, 8(sp)                      # restore reg values
    ldw     r2, 4(sp)
    ldw     r3, 0(sp)                   # hold constant for comparison
    addi    sp, sp, 12
    ret

# ------------------------------------------------------------

PrintString:
    subi    sp, sp, 12                  # save reg values for use
    stw     ra, 8(sp)
    stw     r3, 4(sp)
    stw     r4, 0(sp)

    mov     r4, r2                      # move string pointer to r4

ps_loop:
    ldb		r2, 0(r4)                   # read byte into r2 from the pointer r4
    beq     r2, r0, ps_end_loop         # if ch is 0, loop past end
    call    PrintChar                   # otherwise, call printChar subroutine with r2 as input
    addi    r4, r4, 1                   # increment string pointer (1 byte at a time!)
    beq     r0, r0, ps_loop             # unconditional loop (while loop)

ps_end_loop:
    ldw     ra, 8(sp)                   # restore reg values
    ldw     r3, 4(sp)
    ldw     r4, 0(sp)
    addi    sp, sp, 12

    ret

# ------------------------------------------------------------

PrintChar:
    subi    sp, sp, 12                   # save reg values for use
    stw     ra, 8(sp)
    stw     r3, 4(sp)
    stw     r4, 0(sp)

    movia   r3, JTAG_UART_BASE          # move pointer to the JTAG UART location in memory using movia (large address)

# start polling loop
pc_loop:
    ldwio   r4, STATUS_OFFSET(r3)       # load word from control reg of JTAG UART (+4 from base addr)
    andhi   r4, r4, WSPACE_MASK         # and top 16 bits of the control reg w/ FFFF 
    beq     r4, r0, pc_loop             # if top 16 bits is 0, no space for char to be read, repeat polling loop
    
    stwio   r2, DATA_OFFSET(r3)         # store the character in the "data" area of the JTAG UART to be read (+0 from base addr)

    ldw     ra, 8(sp)                   # restore reg values
    ldw     r3, 4(sp)                   
    ldw     r4, 0(sp)
    addi    sp, sp, 12

    ret
    
# ------------------------------------------------------------

        .org    0x1000
N:      .word   5
LIST1:  .word   5,0,15,0,4
LIST2:  .skip   20
NAME_STRING:    .asciz  "L3 by Campbell, Zubia, Carl\n"
COPY_STRING:    .asciz  "copying list items:"
PERIOD_STRING:  .asciz  ".."
END_STRING:     .asciz  " of the items were 0\n"
        .end