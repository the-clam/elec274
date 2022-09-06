    .equ		JTAG_UART_BASE,		0x10001000
    .equ		DATA_OFFSET,		0
    .equ		STATUS_OFFSET,		4
    .equ		WSPACE_MASK,		0xFFFF

    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC      # initialize stack pointer

    movia   r2, 69      # initialize test value to be passed into PrintHexWord
    call    PrintDec99_Attempt

    movi    r2, '\n'            # make new line
    call    PrintChar

    movia   r2, 72      # initialize test value to be passed into PrintHexWord
    call    PrintDec99_Solution

    movi    r2, '\n'            # make new line
    call    PrintChar

_end:
    break
    br _end

# ------------------------------------------------------------

PrintDec99_Solution:
    subi    sp, sp, 16              # save register values for use
    stw     ra, 12(sp)
    stw     r2, 8(sp)
    stw     r3, 4(sp)
    stw     r4, 0(sp)  
    
    movi    r3, 10                  # store 10 in r3 for use in div instruction
    div     r3, r2, r3              # divide the inputted value by 10 to get ten's place, store in r3
    muli    r4, r3, 10              # multiply number of tens by 10 (so they can be subtracted from the total value)
    sub     r4, r2, r4              # subtract all multiples of ten from the inputted value to get value of one's place, store in r4

    beq     r3, r0, PD9_else_soln   # if number is less than 10, skip to only printing one's place

PD9_if_soln:
    addi    r2, r3, '0'             # move the ten's place into r2 to be used as parameter for PrintChar, add '0' for appropriate ASCII
    call    PrintChar               # print ten's palce

PD9_else_soln:
    addi    r2, r4, '0'             # move the one's place into r2 to be used a parameter for PrintChar, add '0' for appropriate ASCII
    call    PrintChar               # print one's place

    ldw     ra, 12(sp)
    ldw     r2, 8(sp)
    ldw     r3, 4(sp)
    ldw     r4, 0(sp)
    addi    sp, sp, 16              # move stack pointer back up

    ret
        
# ------------------------------------------------------------

PrintDec99_Attempt:
    subi    sp, sp, 16              # save reg values for use
    stw     ra, 12(sp)
    stw     r2, 8(sp)
    stw     r3, 4(sp)
    stw     r4, 0(sp)

    mov     r3, r2                  # use r3 to be the temporary holder
    movi    r4, 10                  # use to hold value of 10

PD9_if:
    blt     r3, r4, PD9_endif       # if r3 < r3 (10), then skip printing the upper value
    div     r2, r2, r4              # divide value by 10 and store in r3
    addi    r2, r2, '0'             # add to char of 0 to find proper char to be added
    call    PrintChar
PD9_endif:
    mov     r2, r3                  # use r2 value to hold the number of tens to be subtracted
    div     r2, r2, r4              # divide by 10 to truncate value to tens value only
    mul     r2, r2, r4              # multiply value to get the amount to remove from val to print (for one's place)
    sub     r2, r3, r2              # subtract multiple of ten to be left with one's place only
    addi    r2, r2, '0'             # add to char of 0 to find proper char to be added
    call    PrintChar
    
    ldw     ra, 12(sp)
    ldw     r2, 8(sp)
    ldw     r3, 4(sp)
    ldw     r4, 0(sp)
    addi    sp, sp, 16              # move stack pointer back up
    
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