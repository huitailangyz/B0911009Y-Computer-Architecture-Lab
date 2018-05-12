#include <asm.h>
#include <regdef.h>
#include <inst_test.h>

LEAF(n69_syscall_test)
    .set noreorder
    addiu s0, s0, 1
    li  s2, 0x01
##clear cause.TI, status.EXL
    mtc0  zero, c0_compare
    lui a0,0x0040
	mtc0	a0, c0_status
###test inst
    .globl syscall_pc
syscall_pc:
    syscall
###detect exception
    li a0, 0x00010000
    bne s2, a0, inst_error
    nop
###score ++
    addiu s3, s3, 1
###output (s2<<24)|s3
inst_error:  
    sll t1, s0, 24
    or t0, t1, s3 
    sw t0, 0(s1)
    jr ra
    nop
END(n69_syscall_test)
