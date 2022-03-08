    .equ		JTAG_UART_BASE,		0x10001000
    .equ		DATA_OFFSET,		0
    .equ		STATUS_OFFSET,		4
    .equ		WSPACE_MASK,		0xFFFF

    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC      # initialize stack pointer

    movia   r2, 0x12345678      # initialize test value to be passed into PrintHexWord
    call    PrintHexWord_Attempt

    movi    r2, '\n'            # make new line
    call    PrintChar

    movia   r2, 0x12345699      # initialize test value to be passed into PrintHexWord
    call    PrintHexWord_Solution

    movi    r2, '\n'            # make new line
    call    PrintChar

_end:
    break
    br _end

# ------------------------------------------------------------

PrintHexWord_Solution:
    subi    sp, sp, 12          # subtract from stack pointer
    stw     ra, 8(sp)           # store return address for nested functions
    stw     r2, 4(sp)           # input value
    stw     r3, 0(sp)           # temp value    

    mov     r3, r2              # hold value in r3 (so r2 can be used to pass in parameter to PrintHexByte)
    srli    r2, r2, 24          # logical shift right 24 to only get top 8 bits (srli inserts zeros)
    call    PrintHexByte        # print first 2 chars (X X _ _ _ _ _ _)
    mov     r2, r3              # reload value in r2
    srli    r2, r2, 16          # logical shift right 16 to only get top 16 bits
    andi    r2, r2, 0xFF        # and with 0xFF to only get the next 2 chars
    call    PrintHexByte        # print next 2 chars (_ _ X X _ _ _ _)
    mov     r2, r3              # reload value in r2
    srli    r2, r2, 8           # logical shift right 8 to only get top 24 bits
    andi    r2, r2, 0xFF        # and with 0xFF to only get the next 2 chars
    call    PrintHexByte        # print next 2 chars (_ _ _ _ X X _ _)
    mov     r2, r3              # reload value in r2 (all 32 bits will be present)
    andi    r2, r2, 0xFF        # and with 0xFF to only get the next 2 chars (bottom 8 bits)
    call    PrintHexByte        # print next 2 chars (_ _ _ _ _ _ X X)

    ldw     ra, 8(sp)           # store return address for nested functions
    ldw     r2, 4(sp)           # input value
    ldw     r3, 0(sp)           # temp value
    addi    sp, sp, 12          # add stack pointer

    ret

# ------------------------------------------------------------

PrintHexWord_Attempt:
    subi    sp, sp, 20          # subtract from stack pointer
    stw     ra, 16(sp)          # store return address for nested functions
    stw     r2, 12(sp)          # used to send value to PrintHexByte
    stw     r3, 8(sp)           # loop counter
    stw     r4, 4(sp)           # shift amount multi
    stw     r5, 0(sp)           # temporarily hold input value

    movi    r3, 4               # set loop amount (4 bytes per word, so 4 loops)
    movi    r4, 32              # hold amount to shift right
    mov     r5, r2              # move input value to r5

phwa_loop:   
    subi    r4, r4, 8           # decrement amount to shift left by each time by 16 bits (1 byte)
    srl     r2, r5, r4          # shift value left by shift amount
    andi    r2, r2, 0xFF        # and only 8 bits (0xFF) held in r2 to be printed using printhexbyte
    call    PrintHexByte        # print the byte being held in r2 (ie. printing XX, in order of XX000000, 00XX0000, 0000XX00, 000000XX)
    subi    r3, r3, 1           # decrement loop counter
    bgt     r3, r0, phwa_loop    # loop if needed

    ldw     ra, 16(sp)          # store return address for nested functions
    ldw     r2, 12(sp)          
    ldw     r3, 8(sp)           
    ldw     r4, 4(sp)           
    ldw     r5, 0(sp)            
    addi    sp, sp, 20          # add to stack pointer

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