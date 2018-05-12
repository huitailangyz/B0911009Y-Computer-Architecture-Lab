#/*	$Id: start.S,v 1.1.1.1 2006/09/14 01:59:08 root Exp $ */

/*
 * Copyright (c) 2001 Opsycon AB  (www.opsycon.se)
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by Opsycon AB, Sweden.
 * 4. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */

#define SIM
#ifndef _KERNEL
#define _KERNEL
#endif

#ifdef SIM
#define WAIT_COUNT 00000001
#else
    #ifndef TEST_DELAY_RAM
    #define WAIT_COUNT 11000000
    #else
    #define WAIT_COUNT 05000000
    #endif
#endif

#include <asm/asm.h>
#include <asm/regdef.h>
#include <cpu.h>
#include <machine.h>
#include <ns16550.h>
#include <asm/context.h>

#define CONFREG_BASE            0xbfd00000
#define LED_ADDR                0xbfd0f000
#define LED_RG0_ADDR            0xbfd0f004
#define LED_RG1_ADDR            0xbfd0f008
#define NUM_ADDR                0xbfd0f010

	.set	noreorder
	.globl	_start
	.globl	start
	.globl	__main
#   .set noat
_start:
start:

	j	locate			/* Get current execute address */
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

    li t1, 0x0002
    li t0, LED_RG1_ADDR
    sw t1, 0(t0)

    li t1, 0x0001
    li t0, LED_RG0_ADDR
    sw t1, 0(t0)

    li t1, 0x0000ffff
    li t0, LED_ADDR
    sw t1, 0(t0)

    li s1, NUM_ADDR
    lui s3, 0
    sw s3, 0(s1)
inst_test:
    jal n1_add_test   #add
    nop
    jal wait_1s
    nop
    jal n2_addi_test  #addi
    nop
    jal wait_1s
    nop
    jal n3_addu_test  #addu
    nop
    jal wait_1s
    nop
    jal n4_addiu_test    #addiu
    nop
    jal wait_1s
    nop
    jal n5_sub_test      #sub
    nop
    jal wait_1s
    nop
    jal n6_subu_test     #subu
    nop
    jal wait_1s
    nop
    jal n7_slt_test      #slt
    nop
    jal wait_1s
    nop
    jal n8_slti_test     #slti
    nop
    jal wait_1s
    nop
    jal n9_sltu_test     #sltu
    nop
    jal wait_1s
    nop
    jal n10_sltiu_test   #sltiu
    nop
    jal wait_1s
    nop
    jal n11_div_test     #div
    nop
    jal wait_1s
    nop
    jal n12_divu_test    #divu
    nop
    jal wait_1s
    nop
    jal n13_mult_test    #mult
    nop
    jal wait_1s
    nop
    jal n14_multu_test   #multu
    nop
    jal wait_1s
    nop
    jal n15_and_test     #and
    nop
    jal wait_1s
    nop
    jal n16_andi_test    #andi
    nop
    jal wait_1s
    nop
    jal n17_lui_test     #lui
    nop
    jal wait_1s
    nop
    jal n18_nor_test     #nor
    nop
    jal wait_1s
    nop
    jal n19_or_test      #or
    nop
    jal wait_1s
    nop
    jal n20_ori_test     #ori
    nop
    jal wait_1s
    nop
    jal n21_xor_test     #xor
    nop
    jal wait_1s
    nop
    jal n22_xori_test    #xori
    nop
    jal wait_1s
    nop
    jal n23_sll_test     #sll
    nop
    jal wait_1s
    nop
    jal n24_sllv_test    #sllv
    nop
    jal wait_1s
    nop
    jal n25_sra_test     #sra
    nop
    jal wait_1s
    nop
    jal n26_srav_test    #srav
    nop
    jal wait_1s
    nop
    jal n27_srl_test     #srl
    nop
    jal wait_1s
    nop
    jal n28_srlv_test    #srlv
    nop
    jal wait_1s
    nop
    jal n29_beq_test     #beq
    nop
    jal wait_1s
    nop
    jal n30_bne_test     #bne
    nop
    jal wait_1s
    nop
    jal n31_bgez_test    #bgez
    nop
    jal wait_1s
    nop
    jal n32_bgtz_test    #bgtz
    nop
    jal wait_1s
    nop
    jal n33_blez_test    #blez
    nop
    jal wait_1s
    nop
    jal n34_bltz_test    #bltz
    nop
    jal wait_1s
    nop
    jal n35_bltzal_test   #bltzal
    nop
    jal wait_1s
    nop
    jal n36_bgezal_test  #bgezal
    nop
    jal wait_1s
    nop
    jal n37_j_test       #j
    nop
    jal wait_1s
    nop
    jal n38_jal_test     #jal
    nop
    jal wait_1s
    nop
    jal n39_jr_test      #jr
    nop
    jal wait_1s
    nop
    jal n40_jalr_test    #jalr
    nop
    jal wait_1s
    nop
    jal n41_mfhi_test    #mfhi
    nop
    jal wait_1s
    nop
    jal n42_mflo_test    #mflo
    nop
    jal wait_1s
    nop
    jal n43_mthi_test    #mthi
    nop
    jal wait_1s
    nop
    jal n44_mtlo_test    #mtlo
    nop
    jal wait_1s
    nop

    jal n47_lb_test      #lb
    nop
    jal wait_1s
    nop
    jal n48_lbu_test     #lbu
    nop
    jal wait_1s
    nop
    jal n49_lh_test      #lh
    nop
    jal wait_1s
    nop
    jal n50_lhu_test     #lhu
    nop
    jal wait_1s
    nop
    jal n51_lw_test      #lw
    nop
    jal wait_1s
    nop
 #  jal n52_lwl_test     #lwl
 #  nop
 #  jal wait_1s
 #  nop
 #  jal n53_lwr_test     #lwr
 #  nop
 #  jal wait_1s
 #  nop
    jal n52_sb_test      #sb
    nop
    jal wait_1s
    nop
    jal n53_sh_test      #sh
    nop
    jal wait_1s
    nop
    jal n54_sw_test      #sw
    nop
    jal wait_1s
    nop
 ###jal n57_swl_test     #swl
 ###nop
 ###jal wait_1s
 ###nop
 ###jal n58_swr_test     #swr
 ###nop
 ###jal wait_1s
 ###nop

    la v0, n68_beq_ds_test     #beq_ds
    jalr v0
    nop
    jal wait_1s
    nop
    la v0, n69_bne_ds_test     #bne_ds
    jalr v0
    nop
    jal wait_1s
    nop
    la v0, n70_bgez_ds_test    #bgez_ds
    jalr v0
    nop
    jal wait_1s
    nop
    la v0, n71_bgtz_ds_test    #bgtz_ds
    jalr v0
    nop
    jal wait_1s
    nop
    la v0, n72_blez_ds_test    #blez_ds
    jalr v0
    nop
    jal wait_1s
    nop
    la v0, n73_bltz_ds_test    #bltz_ds
    jalr v0
    nop
    jal wait_1s
    nop
    la v0, n74_bltzal_ds_test   #bltzal_ds
    jalr v0
    nop
    jal wait_1s
    nop
    la v0, n75_bgezal_ds_test  #bgezal_ds
    jalr v0
    nop
    jal wait_1s
    nop
    la v0, n76_j_ds_test       #j_ds
    jalr v0
    nop
    jal wait_1s
    nop
    la v0, n77_jal_ds_test     #jal_ds
    jalr v0
    nop
    jal wait_1s
    nop
    la v0, n78_jr_ds_test      #jr_ds
    jalr v0
    nop
    jal wait_1s
    nop
    la v0, n79_jalr_ds_test    #jalr_ds
    jalr v0
    nop
    jal wait_1s
    nop


test_end:
    li  a0, 0x5b
    beq a0, s3, 1f
    nop

    li t0, LED_ADDR
    sw zero, 0(t0)

    li t1, 0x0002
    li t0, LED_RG1_ADDR
    sw t1, 0(t0)

    li t1, 0x0002 
    li t0, LED_RG0_ADDR
    sw t1, 0(t0)
    b  2f
    nop
1:
    li t1, 0x0001
    li t0, LED_RG1_ADDR
    sw t1, 0(t0)

    li t1, 0x0001 
    li t0, LED_RG0_ADDR
    sw t1, 0(t0)


2:  b 2b
    nop

wait_1s:
#    li t0, 11000000
    li t0, WAIT_COUNT
1:
    addiu t0, -1
    bne t0,zero, 1b
    nop
    jr ra
    nop
