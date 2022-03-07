    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC


_end:
    break
    br _end

# ---------------------------------------

NAMEOFSUBROUTINE:
    subi    sp, sp, ?
    stw     ra, ?(r0)
    stw     r3, ?(r0)
    stw     r4, ?(r0)
    stw     r5, ?(r0)
    stw     r6, ?(r0)
    stw     r7, ?(r0)

    

    ldw     ra, ?(r0)
    ldw     r3, ?(r0)
    ldw     r4, ?(r0)
    ldw     r5, ?(r0)
    ldw     r6, ?(r0)
    ldw     r7, ?(r0)
    addi    sp, sp, ?

    ret

# ---------------------------------------

    .org    0x1000

    .end