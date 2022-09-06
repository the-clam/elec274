    .equ		JTAG_UART_BASE,		0x10001000
    .equ		DATA_OFFSET,		0
    .equ		STATUS_OFFSET,		4
    .equ		WSPACE_MASK,		0xFFFF

    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC
    movia   r2, TEXT
    call    PrintString

_end:
    break
    br _end

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
TEXT:   .ascii    "This text will be "   
        .asciz    "printed.\n***\n"     # add zero byte to end of string in memory
    .end