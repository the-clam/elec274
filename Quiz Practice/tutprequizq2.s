	.text
	.global _start
	.org 0x0000

_start:
	movia	sp, 0x007FFFFC
	ldw	r2, N(r0)
	movi 	r3, LIST1
	movi 	r4, LIST2	
	call	CopyList

_end:
	break
	br	_end

# ---------------------------------------------------------

CopyList:
	subi	sp, sp, 12
	stw	r3, 8(sp)
	stw	r4, 4(sp)
	stw	r5, 0(sp)

cl_loop:
	ldw	r5, 0(r3)
	stw	r5, 0(r4)
	subi	r2, r2, 1
	addi	r3, r3, 4
	addi	r4, r4, 4
	bgt	r2, r0, cl_loop

	ldw	r3, 8(sp)
	ldw	r4, 4(sp)
	ldw	r5, 0(sp)
	addi	sp, sp, 12

	ret

# ---------------------------------------------------------

	.org 0x1000
N:	.word 	6
LIST1: 	.word	-1, 2, -4, 0, 16, 32
LIST2: 	.skip	24
	.end