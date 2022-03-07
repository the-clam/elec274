    .equ		JTAG_UART_BASE,		0x10001000
    .equ		DATA_OFFSET,		0
    .equ		STATUS_OFFSET,		4
    .equ		WSPACE_MASK,		0xFFFF

    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC      # initialize stack pointer

    movia   r2, 0xABCDEF12      # initialize test value to be passed into PrintHexWord
    call    PrintHexWord

_end:
    break
    br _end

# ------------------------------------------------------------

PrintHexWord:
    subi    sp, sp, 28      # subtract from stack pointer
    stw     ra, 24(sp)      
    stw     r2, 16(sp)      # send value to PHB
    stw     r3, 12(sp)      # loop amount
    stw     r4, 8(sp)       # loop counter
    stw     r5, 4(sp)       # hold val
    stw     r6, 0(sp)       # shift amount multi

    movi    r3, 4           # set loop amount (4 bytes per word)
    movi    r4, 0           # loop counter

    mov     r5, r2          # move val into r5

phw_loop:
    movi    r2, 24          # default "shift" amount (ie. need 8 first 8 bits from first, so shift 32 bits 24 right = getting 8 bits)
    muli    r6, r4, 8       # in loop order(0, 8, 16, 24)
    sub    r2, r2, r6      # in loop order(24, 16, 8, 0)
    srl     r2, r5, r2      # shift left by (24, 16, 8, then 0)
    andi    r2, r2, 0xFF    # only and the last 8 bits
    call    PrintHexByte
    addi    r4, r4, 1
    blt     r4, r3, phw_loop

    ldw     ra, 24(sp)      
    ldw     r2, 16(sp)      # send value to PHB
    ldw     r3, 12(sp)      # loop amount
    ldw     r4, 8(sp)       # loop counter
    ldw     r5, 4(sp)       # hold val
    ldw     r6, 0(sp)       # shift amount multi
    addi    sp, sp, 28      # add to stack pointer

    ret



# ------------------------------------------------------------

PrintHexByte:
    subi    sp, sp, 12                  # save reg values for use
    stw     ra, 8(sp)
    stw     r2, 4(sp)                   # restore original value of r2
    stw     r3, 0(sp)                   # hold original input value n

    mov     r3, r2
    srli    r2, r2, 4                   # shift n right 4 to get top 4 bytes
    call    PrintHexDigit               # print top 4 bytes
    andi    r2, r3, 0xF                 # get bottom 4 bytes
    call    PrintHexDigit               # print bottom 4 bytes
    
    ldw     ra, 8(sp)                   # restore reg values
    ldw     r2, 4(sp)
    ldw     r3, 0(sp)
    addi    sp, sp, 12
    
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

PrintChar:
    subi    sp, sp, 12                  # save reg values for use
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