    .equ		JTAG_UART_BASE,		0x10001000
    .equ		DATA_OFFSET,		0
    .equ		STATUS_OFFSET,		4
    .equ		WSPACE_MASK,		0xFFFF
    
    .text
    .global _start
    .org 0x0000

_start:
    movia   sp, 0x007FFFFC      # initialize stack pointer

    movia   r2, STRING1
    call    PrintString

    movia   r2, STRING2
    call    PrintString

    movia   r2, LIST
    ldw     r3, N(r0)
    call ShowMemContents

    

_end:
    break
    br _end

# ------------------------------------------------------------

ShowMemContents:
    subi    sp, sp, 32
    stw     ra, 28(sp)
    stw     r2, 24(sp)   # list pointer
    stw     r3, 20(sp)   # count n
    stw     r4, 16(sp)   # c_counter
    stw     r5, 12(sp)   # store current item from list
    stw     r6, 8(sp)   # hold 0x1000
    stw     r7, 4(sp)   # list pointer temp
    stw     r8, 0(sp)   # contents

    mov     r7, r2    
    mov     r4, r0
    movia   r6, 0x1000

smc_loop:
    ldw     r5, 0(r7)
smc_if:
    bge     r5, r6, smc_else
smc_then:
    movia   r2, CODE_STRING
    call    PrintString
    addi    r4, r4, 1
    br      smc_endif
smc_else:
    movia   r2, DATA_STRING
    call    PrintString
smc_endif:
    movia   r2, LOCATION_STRING
    call    PrintString

    mov     r2, r5
    call    PrintHexWord

    movia   r2, CONTAINS_STRING
    call    PrintString

    ldw     r2, 0(r5)
    call    PrintHexWord

    movi    r2, '\n'
    call    PrintChar

    addi    r7, r7, 4
    subi    r3, r3, 1
    bgt     r3, r0, smc_loop

    mov     r2, r4
    call    PrintHexWord

    movia   r2, END_STRING
    call    PrintString

    ldw     ra, 28(sp)
    ldw     r2, 24(sp)
    ldw     r3, 20(sp)
    ldw     r4, 16(sp)
    ldw     r5, 12(sp)
    ldw     r6, 8(sp) 
    ldw     r7, 4(sp) 
    ldw     r8, 0(sp) 
    addi    sp, sp, 32

    ret

# ------------------------------------------------------------

PrintString:
    subi    sp, sp, 12              # save reg values for use
    stw     ra, 8(sp)
    stw     r3, 4(sp)
    stw     r4, 0(sp)

    mov     r4, r2                  # move string pointer to r4

ps_loop:
    ldb		r2, 0(r4)               # read byte into r2 from the pointer r4
    beq     r2, r0, ps_end_loop     # if ch is 0, loop past end
    call    PrintChar               # otherwise, call printChar subroutine with r2 as input
    addi    r4, r4, 1               # increment string pointer (1 byte at a time!)
    beq     r0, r0, ps_loop         # unconditional loop (while loop)

ps_end_loop:
    ldw     ra, 8(sp)               # restore reg values
    ldw     r3, 4(sp)
    ldw     r4, 0(sp)
    addi    sp, sp, 12

    ret

# ------------------------------------------------------------

PrintHexWord:
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
    bgt     r3, r0, phwa_loop   # loop if needed

    ldw     ra, 16(sp)          # store return address for nested functions
    ldw     r2, 12(sp)          
    ldw     r3, 8(sp)           
    ldw     r4, 4(sp)           
    ldw     r5, 0(sp)            
    addi    sp, sp, 20          # add to stack pointer

    ret

# ------------------------------------------------------------

PrintHexByte:
    subi    sp, sp, 12      # save reg values for use
    stw     ra, 8(sp)
    stw     r2, 4(sp)       # restore original value of r2
    stw     r3, 0(sp)       # hold original input value n

    mov     r3, r2
    srli    r2, r2, 4       # shift n right 4 to get top 4 bytes
    call    PrintHexDigit   # print top 4 bytes
    andi    r2, r3, 0xF     # get bottom 4 bytes
    call    PrintHexDigit   # print bottom 4 bytes
    
    ldw     ra, 8(sp)       # restore reg values
    ldw     r2, 4(sp)
    ldw     r3, 0(sp)
    addi    sp, sp, 12
    
    ret

# ------------------------------------------------------------

PrintHexDigit:
    subi    sp, sp, 12          # save reg values for use
    stw     ra, 8(sp)                   
    stw     r2, 4(sp)                   
    stw     r3, 0(sp)           # hold constant for comparison

phd_if:
    movi    r3, 10
    bge     r2, r3, phd_else    
phd_then:
    addi    r2, r2, '0'         # store appropriate ASCII representation for PrintChar (<10)
    br      phd_end_if
phd_else:
    subi    r2, r2, 10
    addi    r2, r2, 'A'         # store appropriate ASCII representation for PrintChar (>10)
phd_end_if:
    call    PrintChar           # argument ready in r2
    
    ldw     ra, 8(sp)           # restore reg values
    ldw     r2, 4(sp)
    ldw     r3, 0(sp)           # hold constant for comparison
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

    .org 0x1000
N: .word 5
LIST: .word 0x0, 0x4, 0x8, 0x1000, 0x1004
CODE_STRING:    .asciz "[code] "
DATA_STRING:    .asciz "[data] "
LOCATION_STRING: .asciz "location "
CONTAINS_STRING: .asciz " contains "
END_STRING: .asciz " were code locations\n"
STRING1: .asciz "ELEC274 by\n"
STRING2: .asciz "Campbell, Zubia, Carl\n"
    .end