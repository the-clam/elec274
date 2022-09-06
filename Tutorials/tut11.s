    .equ		JTAG_UART_BASE,		0x10001000
    .equ		DATA_OFFSET,		0
    .equ		STATUS_OFFSET,		4
    .equ		WSPACE_MASK,		0xFFFF

    .text
    .global _start
    .org 0x0000

_start:
    movia   sp, 0x007FFFFC

    movia   r2, TEST_STRING
    call    PrintString

    movia   r2, TEST_STRING
    call    MakeUpperCase_Attempt

    call    PrintDec99  # print returned number from MakeUpperCase

    movi    r2, '\n'
    call    PrintChar

    movia   r2, TEST_STRING
    call    PrintString

    movi    r2, '\n'
    call    PrintChar

_end:
    break
    br _end

# ------------------------------------------------------------

MakeUpperCase:
    subi    sp, sp, 20
    stw     ra, 16(sp)           
    stw     r3, 12(sp)  # str pointer from r2
    stw     r4, 8(sp)   # ch
    stw     r5, 4(sp)
    stw     r6, 0(sp)

    mov     r3, r2      # move pointer
    movi    r5, 'a'
    movi    r6, 'z'
    movi    r2, 0       # initialize counter to 0

mu_loop:
    ldb     r4, 0(r3)
mu_if:
    beq     r4, r0, mu_loop_end
mu_else:
    blt     r4, r5, mu_loop_end
    bgt     r4, r6, mu_end_if
mu_then:
    addi    r4, r4, 'A'
    subi    r4, r4, 'a'
    stb     r4, 0(r3)
    addi    r2, r2, 1
mu_end_if:
    addi    r3, r3, 1
    beq     r0, r0, mu_loop

mu_loop_end:

    ldw     ra, 16(sp)           
    ldw     r3, 12(sp)
    ldw     r4, 8(sp)
    ldw     r5, 4(sp) 
    ldw     r6, 0(sp)
    addi    sp, sp, 20
    
    ret

# ------------------------------------------------------------

MakeUpperCase_Attempt:
    subi    sp, sp, 20              # save reg values for use
    stw     ra, 16(sp)              
    stw     r3, 12(sp)              # hold string pointer
    stw     r4, 8(sp)               # used to count number of numbers turned to uppercase
    stw     r5, 4(sp)               # 'a'
    stw     r6, 0(sp)               # 'z'

    mov     r3, r2
    mov     r4, r0
    movi    r5, 'a'                  # 'a'
    movi    r6, 'z'                 # 'z'

muc_loop_a:
    ldb     r2, 0(r3)               # load byte in
    beq     r2, r0, muc_endloop_a   # if this is the zero char (end of string, go to end)
muc_if_a:                             # check if char is within range of lowercase chars
    blt     r2, r5, muc_endif_a     # if loaded char is less than 'a', skip then
    bgt     r2, r6, muc_endif_a     # if loaded char is greater than 'z', skip then
muc_then_a:
    addi    r4, r4, 1               # increment amount of number lowercase by 1
    subi    r2, r2, 32              # subtract to make it uppercase
    stb     r2, 0(r3)               # store uppercase char back into string
muc_endif_a:
    addi    r3, r3, 1               # increment string pointer
    beq     r0, r0, muc_loop_a        # unconditional loop

muc_endloop_a:
    mov     r2, r4                  # return value of number of lowercase letters

    ldw     ra, 16(sp)
    ldw     r3, 12(sp)
    ldw     r4, 8(sp)
    ldw     r5, 4(sp)
    ldw     r6, 0(sp)
    addi    sp, sp, 20

    ret

# ------------------------------------------------------------

PrintDec99:
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
REPL_STRING:  .asciz "Num of replaced lowercase letters: "
TEST_STRING:  .asciz "This Phrase Has 24 Lowercase Letters\n" # this one has 26 lowercase
    .end