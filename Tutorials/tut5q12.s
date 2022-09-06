    .equ		JTAG_UART_BASE,		0x10001000
    .equ		DATA_OFFSET,		0
    .equ		STATUS_OFFSET,		4
    .equ		WSPACE_MASK,		0xFFFF

    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC

    movi    r2, 0xD1                    # test value
    call    PrintHexByte

    movi    r2, ' '                     # add space
    call    PrintChar

    movi    r2, 0x05                    # test value
    call    PrintHexByte

    movi    r2, '\n'                    # make new line
    call    PrintChar

    
_end:
    break
    br _end

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
    
    ldw     ra, 8(sp)                   # restore reg values
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

PrintSignedHexByte:
    subi    sp, sp, 12
    stw     ra, 8(sp)
    stw     r2, 4(sp)
    stw     r3, 0(sp)

pshb_if:
    bge     r2, r0, pshb_end_if
pshb_then:
    mov     r3, r2
    movi    r2, '-'
    call    PrintChar
    sub     r2, r0, r3
pshb_end_if:
    call    PrintHexByte
    
    ldw     ra, 8(sp)
    ldw     r2, 4(sp)
    ldw     r3, 0(sp)    
    addi    sp, sp, 12
    ret

# ------------------------------------------------------------
