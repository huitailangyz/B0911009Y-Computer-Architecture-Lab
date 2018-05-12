#include <asm.h>
#include <regdef.h>
#include <ucas_cde.h>

##s0, number
##s1, number adress 
##s2, exception use
##s3, score

	.set	noreorder
	.globl	_start
	.globl	start
	.globl	__main
_start:
start:

	j	locate
	nop

##avoid "j locate" not taken
    lui   t0, 0x8000
    addiu t1, t1, 1
    or    t2, t0, zero
    addu  t3, t5, t6
    lw    t4, 0(t0)
    nop

##avoid cpu run error
.org 0x0ec
    lui   t0, 0x8000
    addiu t1, t1, 1
    or    t2, t0, zero
    addu  t3, t5, t6
    lw    t4, 0(t0)
.org 0x100
test_finish:
    addiu t0, t0, 1
    b test_finish
    nop
##avoid cpu run error
    lui   t0, 0x8000
    addiu t1, t1, 1
    or    t2, t0, zero
    addu  t3, t5, t6
    lw    t4, 0(t0)
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

    LI (a0, LED_RG1_ADDR)
    LI (a1, LED_RG0_ADDR)
    LI (a2, LED_ADDR)
    LI (s1, NUM_ADDR)

    LI (t1, 0x0002)
    LI (t2, 0x0001)
    LI (t3, 0x0000ffff)
    lui s3, 0

    sw t1, 0(a0)
    sw t2, 0(a1)
    sw t3, 0(a2)
    sw s3, 0(s1)
inst_test:
   

    jal n15_and_test    #bne
    nop
    jal wait_1s
    nop
    jal n16_andi_test     #lw
    nop
    jal wait_1s
    nop
    jal n17_lui_test     #or
    nop
    jal wait_1s
    nop
    jal n18_nor_test    #slt
    nop
    jal wait_1s
    nop
    jal n19_or_test   #slti
    nop
    jal wait_1s
    nop
    jal n20_ori_test #sltiu
    nop
    jal wait_1s
    nop
	jal n21_xor_test    #lui
    nop
    jal wait_1s
    nop
    jal n22_xori_test   #addu
    nop
    jal wait_1s
    nop
    jal n23_sll_test  #addiu
    nop
    jal wait_1s
    nop
    jal n24_sllv_test    #beq
    nop
    jal wait_1s
    nop
    jal n25_sra_test    #bne
    nop
    jal wait_1s
    nop
    jal n26_srav_test     #lw
    nop
    jal wait_1s
    nop
    jal n27_srl_test     #or
    nop
    jal wait_1s
    nop
    jal n28_srlv_test    #slt
    nop
    jal wait_1s
    nop
    jal n29_beq_test   #slti
    nop
    jal wait_1s
    nop
    jal n30_bne_test #sltiu
    nop
    jal wait_1s
    nop
	jal n31_bgez_test    #lui
    nop
    jal wait_1s
    nop
    jal n32_bgtz_test   #addu
    nop
    jal wait_1s
    nop
    jal n33_blez_test  #addiu
    nop
    jal wait_1s
    nop
    jal n34_bltz_test    #beq
    nop
    jal wait_1s
    nop
    jal n35_bltzal_test    #bne
    nop
    jal wait_1s
    nop
    jal n36_bgezal_test     #lw
    nop
    jal wait_1s
    nop
    jal n37_j_test     #or
    nop
    jal wait_1s
    nop
    jal n38_jal_test    #slt
    nop
    jal wait_1s
    nop
    jal n39_jr_test   #slti
    nop
    jal wait_1s
    nop
    jal n40_jalr_test #sltiu
    nop
    jal wait_1s
    nop

    jal n47_lb_test     #or
    nop
    jal wait_1s
    nop
    jal n48_lbu_test    #slt
    nop
    jal wait_1s
    nop
    jal n49_lh_test   #slti
    nop
    jal wait_1s
    nop
    jal n50_lhu_test #sltiu
    nop
    jal wait_1s
    nop
	jal n51_lw_test    #lui
    nop
    jal wait_1s
    nop
    jal n52_sb_test   #addu
    nop
    jal wait_1s
    nop
    jal n53_sh_test  #addiu
    nop
    jal wait_1s
    nop
    jal n54_sw_test    #beq
    nop
    jal wait_1s
    nop
    




test_end:
    LI  (s0, 0x14)
	NOP
    NOP
    NOP
    beq s0, s3, 1f
    nop

    LI (a0, LED_ADDR)
	LI (a1, LED_RG1_ADDR)
    LI (a2, LED_RG0_ADDR)
	
    LI (t1, 0x0002)
	NOP
	NOP
    
	sw zero, 0(a0)
    sw t1, 0(a1)
    sw t1, 0(a2)
    b  2f
    nop
1:
    LI (t1, 0x0001)
    LI (a0, LED_RG1_ADDR)
	LI (a1, LED_RG0_ADDR)
	NOP
	NOP
    sw t1, 0(a0)
    sw t1, 0(a1)

2:
	LI (t1, 0xff)
	LI (t0, UART_ADDR)
	NOP
	NOP
	NOP
	sw t1, 0(t0)

	j test_finish
    nop

wait_1s:
    LI (t1,SIMU_FLAG_ADDR)
    lui   t0, zero
    NOP
    NOP
    lw t2, 0x(t1)
    NOP
    NOP
    NOP
    bne  t2, zero, 1f
    nop
    lui   t0, 0x20
1:
    addiu t0, 1
    NOP
    NOP
    NOP
2:
    addiu t0, -1
    NOP
    NOP
    NOP
    bne t0,zero, 2b
    nop
    jr ra
    nop
