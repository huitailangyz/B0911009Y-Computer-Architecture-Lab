#include <asm.h>
#include <regdef.h>
#include <ucas_cde.h>

#define TEST_NUM 69

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
    li  t0, 0x01 # syscall
    beq s2, t0, syscall_ex
    nop

syscall_ex:
    addu  s2, zero, zero
    mfc0 k0, c0_epc
    la   k1, syscall_pc
    bne  k0, k1, ex_finish
    nop
    mfc0 k0, c0_cause
    andi k0, k0, 0x7c # 6..2
    li   k1, 0x20 # 010_00
    bne  k0, k1, ex_finish
    nop
    mfc0 k0, c0_status
    andi k0, k0, 0x02
    li   k1, 0x02
    bne  k0, k1, ex_finish
    nop
    lui  s2, 0x1
    b ex_finish
    nop

ex_finish:
    mfc0 k0,c0_cause
    mfc0 v1,c0_epc
    lui k1,0x8000
    addiu v1,v1,0x4
    and k0,k0,k1
    beq k0,zero, 1f
    nop
    addiu v1,v1,0x4
1:  
    mtc0  v1,c0_epc
    nop
    bne s2, zero, ex_ret
    nop
    lui s2, 0xffff
ex_ret:
    .set mips32
    eret
    .set mips1
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
    lui s0, 0
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
    jal n16_beq_ds_test  #beq delay slot
    nop
    jal wait_1s
    nop
    jal n17_bne_ds_test  #bne delay slot
    nop
    jal wait_1s
    nop
    jal n18_j_ds_test    #j delay slot
    nop
    jal wait_1s
    nop
    jal n19_jal_ds_test  #jal delay slot
    nop
    jal wait_1s
    nop
    jal n20_jr_ds_test   #jr delay slot
    nop
    jal wait_1s
    nop
    jal n21_add_test   #add
    nop
    jal wait_1s
    nop
    jal n22_addi_test   #addi
    nop
    jal wait_1s
    nop
    jal n23_sub_test   #sub
    nop
    jal wait_1s
    nop
    jal n24_subu_test   #subu
    nop
    jal wait_1s
    nop
    jal n25_sltu_test   #sltu
    nop
    jal wait_1s
    nop
    jal n26_and_test   #and
    nop
    jal wait_1s
    nop
    jal n27_andi_test   #andi
    nop
    jal wait_1s
    nop
    jal n28_nor_test   #nor
    nop
    jal wait_1s
    nop
    jal n29_ori_test   #ori
    nop
    jal wait_1s
    nop
    jal n30_xor_test   #xor
    nop
    jal wait_1s
    nop
    jal n31_xori_test   #xori 
    nop
    jal wait_1s
    nop
    jal n32_sllv_test   #sllv
    nop
    jal wait_1s
    nop
    jal n33_sra_test   #sra
    nop
    jal wait_1s
    nop
    jal n34_srav_test   #srav
    nop
    jal wait_1s
    nop
    jal n35_srl_test   #srl
    nop
    jal wait_1s
    nop
    jal n36_srlv_test   #srlv
    nop
    jal wait_1s
    nop
    jal n37_bgez_test   #bgez
    nop
    jal wait_1s
    nop
    jal n38_bgtz_test   #bgtz
    nop
    jal wait_1s
    nop
    jal n39_blez_test   #blez
    nop
    jal wait_1s
    nop
    jal n40_bltz_test   #bltz
    nop
    jal wait_1s
    nop
    jal n41_bltzal_test   #bltzal
    nop
    jal wait_1s
    nop
    jal n42_bgezal_test   #bgezal
    nop
    jal wait_1s
    nop
    jal n43_jalr_test   #jalr
    nop
    jal wait_1s
    nop
    jal n44_div_test   #div
    nop
    jal wait_1s
    nop
    jal n45_divu_test   #divu
    nop
    jal wait_1s
    nop
    jal n46_mult_test   #mult
    nop
    jal wait_1s
    nop
    jal n47_multu_test   #multu
    nop
    jal wait_1s
    nop
    jal n48_mfhi_test   #mfhi
    nop
    jal wait_1s
    nop
    jal n49_mflo_test   #mflo
    nop
    jal wait_1s
    nop
    jal n50_mthi_test   #mthi
    nop
    jal wait_1s
    nop
    jal n51_mtlo_test   #mtlo
    nop
    jal wait_1s
    nop
    jal n52_bgez_ds_test   #bgez delay slot
    nop
    jal wait_1s
    nop
    jal n53_bgtz_ds_test   #bgtz delay slot
    nop
    jal wait_1s
    nop
    jal n54_blez_ds_test   #blez delay slot
    nop
    jal wait_1s
    nop
    jal n55_bltz_ds_test   #bltz delay slot
    nop
    jal wait_1s
    nop
    jal n56_bltzal_ds_test   #bltzal delay slot
    nop
    jal wait_1s
    nop
    jal n57_bgezal_ds_test   #bgezal delay slot
    nop
    jal wait_1s
    nop
    jal n58_jalr_ds_test   #jalr delay slot
    nop
    jal wait_1s
    nop
    jal n59_lb_test        #lb
    nop
    jal wait_1s
    nop
    jal n60_lbu_test       #lbu
    nop
    jal wait_1s
    nop
    jal n61_lh_test        #lh
    nop
    jal wait_1s
    nop
    jal n62_lhu_test       #lhu
    nop
    jal wait_1s
    nop
    jal n63_lwl_test       #lwl
    nop
    jal wait_1s
    nop
    jal n64_lwr_test       #lwr
    nop
    jal wait_1s
    nop
    jal n65_sb_test        #sb
    nop
    jal wait_1s
    nop
    jal n66_sh_test        #sh
    nop
    jal wait_1s
    nop
    jal n67_swl_test       #swl
    nop
    jal wait_1s
    nop
    jal n68_swr_test       #swr
    nop
    jal wait_1s
    nop
    jal n69_syscall_test       #syscall
    nop
    jal wait_1s
    nop

test_end:
    LI  (s0, TEST_NUM)
    beq s0, s3, 1f
    nop

    LI (a0, LED_ADDR)
	LI (a1, LED_RG1_ADDR)
    LI (a2, LED_RG0_ADDR)
	
    LI (t1, 0x0002)
    
	sw zero, 0(a0)
    sw t1, 0(a1)
    sw t1, 0(a2)
    b  2f
    nop
1:
    LI (t1, 0x0001)
    LI (a0, LED_RG1_ADDR)
	LI (a1, LED_RG0_ADDR)
    sw t1, 0(a0)
    sw t1, 0(a1)

2:
	j test_finish
    nop

wait_1s:
    LI (t1,SIMU_FLAG_ADDR)
    lui   t0, 0x0
    lw t2, 0x(t1)
    bne  t2, zero, 1f
    nop
    lui   t0, 0x20
1:
    addiu t0, 1
2:
    addiu t0, -1
    bne t0,zero, 2b
    nop
    jr ra
    nop
