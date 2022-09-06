# QUESTION:
# Prepare a modular subroutine ListGeneration(f,g,h,n,x,y) in Nios II assembly-lanauge that accepts
# pointers to the beginning of three lists f/g/h in memory, where each list has space for n word-sized
# items, and an additional parameter values x,y.
# 
# For each f list element i between 0 and n-1, the required computation for this subroutine is
# f[i] = g[i] + x if g[i] < h[i], otherwise f[i] = g[i]*x - y.
# 
# The subroutine should also maintain a count for the number of times that item that f list element is
# computed as a positive value, and the final count should be returned to the caller.
# 
# For full modularity, the subroutine should not refer to any global variables directly by name.
# 
# Include the necessary data directives in assembly language for the following global variable:
# •	N for the number of items in the lists
# •	VAL1 for the first subroutine parameter of value 3
# •	VAL2 for the second subroutine parameter of value 7
# •	DEST_LIST with sufficient space
# •	SRC_LIST1 consisting of the items { 5, 6, 1, 2 }
# •	SRC_LIST2 consisting of the items { 3, 4, 7, 8 }
# •	POS_COUNT for the number of positive-valued elements in the generated list
# 
# Develop a main routine that calls the modular subroutine above with appropriate arguments to place
# the computer results into DEST_LIST from SRC_LIST1 and SRC_LIST2. Place the returned result in POS_COUNT.
# 
# Include the necessary directives at the beginning for a properly implemented system.

###################################################################################

# PSEUDOCODE:
# 
# ListGeneration(f,g,h,n,x,y):
# 	if(g[i] < h[i])
# 		f[i] = g[i] + x
# 	else
# 		f[i] = g[i] * x - y
# 	end if
# 
# 	if(f[i] >= 0)
# 		pos_count++
# 	endif
# ret pos_count++

###################################################################################

    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC
    movia   r2, DEST_LIST
    movia   r3, SRC_LIST1
    movia   r4, SRC_LIST2
    ldw     r5, N(r0)
    ldw     r6, VAL1(r0)
    ldw     r7, VAL2(r0)
    call    ListGeneration
    stw     r2, POS_COUNT(r0)

_end:
    break
    br _end

# ---------------------------------------

ListGeneration:
    subi    sp, sp, 40
    stw     ra, 36(r0)
    stw     r3, 32(r0)  #list1 ptr
    stw     r4, 28(r0)  #list2 ptr
    stw     r5, 24(r0)  #N counter
    stw     r6, 20(r0)  #val1
    stw     r7, 16(r0)  #val2
    stw     r8, 12(r0)  #g[i]
    stw     r9, 8(r0)   #h[i]
    stw     r10, 4(r0)  #pos counter
    stw     r11, 0(r0)  #temp calculation holder

#main calculation
lg_loop:
    mov     r10, r0     #initialize positive counter at 0
    mov		r11, r0 
lg_if:
    ldw     r8, 0(r3)
    ldw     r9, 0(r4)
    bge     r8, r9, lg_else
lg_then:
    add     r11, r8, r6
    stw     r11, 0(r2)
    br      lg_endif
lg_else:
    mul     r11, r8, r6
    sub     r11, r11, r7
    stw     r11, 0(r2)
lg_endif:

#check if pos
    blt     r11, r0, not_pos
if_pos:
    addi    r10, r10, 1
not_pos:
    
#increment counter, and loop back
    addi    r2, r2, 4
    addi    r3, r3, 4
    addi    r4, r4, 4
    subi    r5, r5, 1
    bgt     r5, r0, lg_loop

# return value
    mov     r2, r10

    ldw     ra, 36(r0)
    ldw     r3, 32(r0)
    ldw     r4, 28(r0)
    ldw     r5, 24(r0)
    ldw     r6, 20(r0)
    ldw     r7, 16(r0)
    ldw     r8, 12(r0)
    ldw     r9, 8(r0)
    ldw     r10, 4(r0)
    ldw     r11, 0(r0)  
    addi    sp, sp, 40

    ret

# ---------------------------------------

    .org    0x1000
N:  .word   4
VAL1:   .word   3
VAL2:   .word   7
DEST_LIST:  .skip   16
SRC_LIST1:  .word   5, 6, 1, 2
SRC_LIST2:  .word   3, 4, 7, 8
POS_COUNT:  .skip   4
    .end