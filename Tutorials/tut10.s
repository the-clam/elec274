    .equ		JTAG_UART_BASE,		0x10001000
    .equ		DATA_OFFSET,		0
    .equ		STATUS_OFFSET,		4
    .equ		WSPACE_MASK,		0xFFFF

    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC

    ldw     r2, N(r0)
    movia   r3, LIST
    call    ShowBytes_Attempt

    # broken
    # ldw     r2, N(r0)
    # movia   r3, LIST
    # call    ShowBytes_Soln

_end:
    break
    br _end

# ------------------------------------------------------------

ShowBytes_Soln:
    subi    sp, sp, 24          # save reg values for use
    stw     ra, 20(sp)
    stw     r2, 16(sp)          # ptr, use as input for subroutines
    stw     r3, 12(sp)          # hold n
    stw     r4, 8(sp)           # move pointer in here
    stw     r5, 4(sp)           # r
    stw     r6, 0(sp)           # 16
    
    mov     r4, r2
    mov     r5, r0
    movi    r6, 16

sb_s_loop:
sb_s_if1:
    ble     r5, r0, sb_s_end_if1
sb_s_then1:
    movi    r2, ' '
    call    PrintChar
sb_s_end_if1:
    ldbu    r2, 0(r4)
    call    PrintHexByte
    addi    r5, r5, 1

sb_s_if2:
    blt     r5, r6, sb_s_end_if2
sb_s_then2:
    movi    r2, '\n'
    call    PrintChar
    movi    r5, 0
sb_s_end_if2:
    addi    r4, r4, 1
    subi    r3, r3, 1
    bgt     r3, r0, sb_s_loop

sb_if3:
    beq     r5, r0, sb_end_if3
sb_then3:
    movi    r2, '\n'
    call    PrintChar
sb_end_if3:

    ldw     ra, 20(sp)
    ldw     r2, 16(sp)
    ldw     r3, 12(sp)
    ldw     r4, 8(sp) 
    ldw     r5, 4(sp) 
    ldw     r6, 0(sp) 
    addi    sp, sp, 24
    ret

# ------------------------------------------------------------

ShowBytes_Attempt:
    subi    sp, sp, 20          # save reg values for use
    stw     ra, 16(sp)          # save return address for nested functions
    stw     r2, 12(sp)          # pass in value of N (initially), nested input
    stw     r3, 8(sp)           # list pointer
    stw     r4, 4(sp)           # hold value of N
    stw     r5, 0(sp)           # countdown number of prints per row before newline

    mov     r4, r2              # store value of N into r4
    movi    r5, 4               # set count to 4

sb_loop:
    ldbu    r2, 0(r3)           # load byte from pointer
    call    PrintHexByte

    movi    r2, ' '             # print space between every byte
    call    PrintChar

sb_if:
	subi    r5, r5, 1           # remove 1 from number of printed values
    bgt     r5, r0, sb_endif    # if less than 4 bytes in row, skip newline printing
sb_then:
    movi    r2, '\n'            # print newline every 4 bytes
    call    PrintChar
    movi    r5, 4               # set count to 4
sb_endif:

    addi    r3, r3, 1
    subi    r4, r4, 1
    bgt     r4, r0, sb_loop

sb1_if:
    bne     r4, r0, sb1_endif    # if less than 4 bytes in row, print newline
sb1_then:
    movi    r2, '\n'            # print newline every 4 bytes
    call    PrintChar
sb1_endif:

    ldw     ra, 16(sp)          # save return address for nested functions
    ldw     r2, 12(sp)          # pass in value of N (initially), nested input
    ldw     r3, 8(sp)           # list pointer
    ldw     r4, 4(sp)           # hold value of N
    ldw     r5, 0(sp)           # countdown number of prints per row before newline
    addi    sp, sp, 20          # save reg values for use

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

    .org 0x1000
N:  .word   13
LIST: .byte -10, 20, -30, 40, -50, 60, -70, 80, 90, 100, 110, 120, -127            
            # -0A, 14, -1E, 28
            # -32, 3C, -46, 50
            # 5A, 64, 6E, 78
            # -7F (any higher than 127 and it will not work
    .end