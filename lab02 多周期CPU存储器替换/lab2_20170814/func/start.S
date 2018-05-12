#define WAIT_COUNT 00000001

#include <asm.h>
#include <regdef.h>

#define UART_ADDR               0xfffffff0
#define LED_ADDR                0xfffff000
#define LED_RG0_ADDR            0xfffff004
#define LED_RG1_ADDR            0xfffff008
#define NUM_ADDR                0xfffff010

#define LI(reg, imm) \
    lui reg , ((imm>>16) + (imm&0x00008000)>>15)&0x0000ffff; \
    addiu reg, zero, (imm & 0x0000ffff)

	.set	noreorder
	.globl	_start
	.globl	start
	.globl	__main
_start:
start:

	j	locate
	nop

.org 0x100
test_finish:
    addiu t0, t0, 1
    b test_finish
    nop
/*
 *  exception handle
 */
.org 0x380
1:  
    addiu t0, t0, 1
    b 1b
    nop


locate:
	.set noreorder

    LI (t1, 0x0002)
    LI (t0, LED_RG1_ADDR)
    sw t1, 0(t0)

    LI (t1, 0x0001)
    LI (t0, LED_RG0_ADDR)
    sw t1, 0(t0)

    LI (t1, 0x0000ffff)
    LI (t0, LED_ADDR)
    sw t1, 0(t0)

    LI (s1, NUM_ADDR)
    lui s3, 0
    sw s3, 0(s1)
inst_test:
    jal n1_lui_test    #lui
    nop
    jal wait_1s
    nop
    jal n2_addu_test   #addu
    nop
    jal wait_1s
    nop
    jal n3_addiu_test  #addiu
    nop
    jal wait_1s
    nop
    jal n4_beq_test    #beq
    nop
    jal wait_1s
    nop
    jal n5_bne_test    #bne
    nop
    jal wait_1s
    nop
    jal n6_lw_test     #lw
    nop
    jal wait_1s
    nop
    jal n7_or_test     #or
    nop
    jal wait_1s
    nop
    jal n8_slt_test    #slt
    nop
    jal wait_1s
    nop
    jal n9_slti_test   #slti
    nop
    jal wait_1s
    nop
    jal n10_sltiu_test #sltiu
    nop
    jal wait_1s
    nop
    jal n11_sll_test   #sll
    nop
    jal wait_1s
    nop
    jal n12_sw_test    #sw
    nop
    jal wait_1s
    nop
    jal n13_j_test       #j
    nop
    jal wait_1s
    nop
    jal n14_jal_test     #jal
    nop
    jal wait_1s
    nop
    jal n15_jr_test      #jr
    nop
    jal wait_1s
    nop

test_end:
    LI  (a0, 0xf)
    beq a0, s3, 1f
    nop

    LI (t0, LED_ADDR)
    sw zero, 0(t0)

    LI (t1, 0x0002)
    LI (t0, LED_RG1_ADDR)
    sw t1, 0(t0)

    LI (t1, 0x0002) 
    LI (t0, LED_RG0_ADDR)
    sw t1, 0(t0)
    b  2f
    nop
1:
    LI (t1, 0x0001)
    LI (t0, LED_RG1_ADDR)
    sw t1, 0(t0)

    LI (t1, 0x0001) 
    LI (t0, LED_RG0_ADDR)
    sw t1, 0(t0)

2:
	LI (t1, 0xff)
	LI (t0, UART_ADDR)
	sw t1, 0(t0)

	j test_finish
    nop

wait_1s:
#ifdef SIM
    addiu t0, zero, 1
#else
    lui   t0, 150
#endif
1:
    addiu t0, -1
    bne t0,zero, 1b
    nop
    jr ra
    nop
