/*	$Id: start.S,v 1.1.1.1 2006/09/14 01:59:08 root Exp $ */

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

#ifndef _KERNEL
#define _KERNEL
#endif

#include <asm.h>
#include <regnum.h>
#include <cpu.h>
#include <pte.h>

#include "pmon/dev/ns16550.h"
#include "target/prid.h"
#include "target/sbd.h"
#include "target/fcr.h"
#include "target/via686b.h"
#include "target/i8254.h"
#include "target/isapnpreg.h"
#define DEBUG_LOCORE

#ifndef BOOT_FROM_EJTAG      
#define  BOOT_FROM_EJTAG
#endif
#undef BOOT_FROM_EJTAG

#ifdef DEBUG_LOCORE
#define	TTYDBG(x) \
	.rdata;98: .asciz x; .text; la a0, 98b; bal stringserial; nop
#else
#define TTYDBG(x)
#endif

#define	PRINTSTR(x) \
	.rdata;98: .asciz x; .text; la a0, 98b; bal stringserial; nop

/* Delay macro */
#define	DELAY(count)	\
	li v0, count;	\
99:			\
	bnez	v0, 99b;\
	addiu	v0, -1

#define tmpsize		s1
#define msize		s2
#define bonito		s4
#define dbg			s5
#define sdCfg		s6

#define CP0_CONFIG $16
#define CP0_TAGLO  $28
#define CP0_TAGHI  $29


/*
 *   Register usage:
 *
 *	s0	link versus load offset, used to relocate absolute adresses.
 *	s1	free
 *	s2	memory size.
 *	s3	free.
 *	s4	Bonito base address.
 *	s5	dbg.
 *	s6	sdCfg.
 *	s7	rasave.
 *	s8	L3 Cache size.
 */


	.set	noreorder
	.globl	_start
	.globl	start
	.globl	__main
_start:
start:
	.globl	stack
stack = start - 0x4000		/* Place PMON stack below PMON start in RAM */

/* NOTE!! Not more that 16 instructions here!!! Right now it's FULL! */
	mtc0	zero, COP_0_STATUS_REG
	mtc0	zero, COP_0_CAUSE_REG
	li	t0, SR_BOOT_EXC_VEC	/* Exception to Boostrap Location */
	mtc0	t0, COP_0_STATUS_REG
	la	sp, stack
	la	gp, _gp

//	bal	uncached		/* Switch to uncached address space */
	nop

	bal	locate			/* Get current execute address */
	nop

uncached:
	or	ra, UNCACHED_MEMORY_ADDR
	j	ra
	nop

/*
 *  Reboot vector usable from outside pmon.
 */
	.align	9
ext_map_and_reboot:
	li	a0,0x10000000 /*test from 0xbfcxxxxx or 0xff20xxxx */
	and	a0,ra
	la	a0,_start
	bnez	a0,1f
    nop
	li	s0,0xbfc00000
	subu	s0,a0
1:
	la	a0, v200_msg
	bal	stringserial
	nop
	b	exc_common

	.align	7			/* bfc00280 */
	la	a0, v280_msg
	bal	stringserial
	nop
	b	exc_common

/* Cache error */
	.align	8			/* bfc00300 */
	PRINTSTR("\r\nPANIC! Unexpected Cache Error exception! ")
	mfc0	a0, COP_0_CACHE_ERR
	bal	hexserial
	nop
	b	exc_common

/* General exception */
	.align	7			/* bfc00380 */
	li	a0,0x10000000 /*test from 0xbfcxxxxx or 0xff20xxxx */
	and	a0,ra
	la	a0,_start
	bnez	a0,1f
    nop
	li	s0,0xbfc00000
	subu	s0,a0
1:
	la	a0, v380_msg
	bal	stringserial
	nop
	b	exc_common
	
	.align	9			/* bfc00400 */
	la	a0, v400_msg
	bal	stringserial
	nop
	b	exc_common

	.align	7			/* bfc00480 */
la	a0, v480_msg
	bal	stringserial
	nop
b	exc_common
	nop
	
	.align	8			/* bfc00500 */
exc_common:
	PRINTSTR("\r\nCAUSE=")
	mfc0	a0, COP_0_CAUSE_REG
	bal	hexserial
	nop
	PRINTSTR("\r\nSTATUS=")
	mfc0	a0, COP_0_STATUS_REG
	bal	hexserial
	nop
	PRINTSTR("\r\nERRORPC=")
	mfc0	a0, COP_0_ERROR_PC
	bal	hexserial
	nop
	PRINTSTR("\r\nEPC=")
	mfc0	a0, COP_0_EXC_PC
	bal	hexserial
	nop

	PRINTSTR("\r\nBADADDR=")
	mfc0	a0, COP_0_BAD_VADDR
	bal	hexserial
	nop

	//bal mydebug_main
	//nop
1:
	b 1b
	nop

	.align 9
		nop
	.align 8
	.word read
	.word write
	.word open
	.word close
	.word nullfunction
	.word printf
	.word vsprintf
	.word nullfunction
	.word nullfunction
	.word getenv
	.word nullfunction
	.word nullfunction
	.word nullfunction
	.word nullfunction


/*
 *  We get here from executing a bal to get the PC value of the current execute
 *  location into ra. Check to see if we run from ROM or if this is ramloaded.
 */
locate:
	la	s0,uncached
	subu	s0,ra,s0

	li	    t0,  SR_BOOT_EXC_VEC
	mtc0	t0,  COP_0_STATUS_REG
    mtc0    zero,COP_0_CAUSE_REG
	.set noreorder
/*spi speed*/
    li  t0, 0xbfe80000
    li  t1, 0x17  // div 4, fast_read + burst_en + memory_en
    sb  t1, 0x4(t0) // sfc_param

/*disable all gpio*/
	li a0,0xbfd00000
	sw zero,0x10c0(a0)
	sw zero,0x10c4(a0)

	li a0,0
	bal	initserial
	nop

	PRINTSTR("\r\nPMON2000 MIPS Initializing. Standby...\r\n")
	PRINTSTR("ERRORPC=")
	mfc0	a0, COP_0_ERROR_PC
	bal	hexserial
	nop

	PRINTSTR(" CONFIG=")
	mfc0	a0, COP_0_CONFIG
	bal	hexserial
	nop
	PRINTSTR("\r\n")
	
	PRINTSTR(" PRID=")
	mfc0	a0, COP_0_PRID
	bal	hexserial
	nop
	PRINTSTR("\r\n")

	bnez s0,1f
	nop
	li a0,128
	jal initmips
	nop
1:

#define CF_7_SE         (1 << 3)        /* Secondary cache enable */
#define CF_7_SC         (1 << 31)       /* Secondary cache not present */
#define CF_7_TE         (1 << 12)       /* Tertiary cache enable */
#define CF_7_TC         (1 << 17)       /* Tertiary cache not present */
#define CF_7_TS         (3 << 20)       /* Tertiary cache size */
#define CF_7_TS_AL      20              /* Shift to align */
#define NOP8 nop;nop;nop;nop;nop;nop;nop;nop
do_caches:
	TTYDBG("Init caches... do noting...\r\n")

#if 1 // cache init
	li	s7, 0                   /* no L2 cache */
	li	s8, 0                   /* no L3 cache */

	TTYDBG("godson1 caches found\r\n")
    bal     cache_init
    nop

	TTYDBG("Init caches done, cfg = ")
	mfc0	a0, COP_0_CONFIG
	bal	hexserial
	nop
	TTYDBG("\r\n\r\n")


#if 0
	/* Open cache */
    mfc0   a0,COP_0_CONFIG
    and    a0,a0,~((1<<12) | 3)
	or     a0,a0,3
    mtc0   a0,COP_0_CONFIG
#endif
#endif

bootnow:

#define	FCALL_PRINTSTR(x) \
	.rdata;98: .asciz x; .text; la a0, 98b; la v0, stringserial; addu v0,s0;jalr v0; nop	

#undef BAL
#define BAL(x) \
	la v0,x; \
	addu v0,s0; \
	jalr v0; \
	nop;

#if 1
/*copy copy program to sdram to make copy fast*/

	la t0,121f
	addu t0,s0
	la t1,122f
	addu t1,s0
	
	li t2,0xa0000000
1:
	lw  v0,(t0)
	sw v0,(t2)
	addu t0,4
	addu t2,4
	ble t0,t1,1b
	nop

	li t0,0xa0000000
   	jr t0	
	nop		
#endif

#defined DEBUG_LOCORE
.align 3
121: 
	FCALL_PRINTSTR("Copy PMON to execute location...\r\n")

#ifdef DEBUG_LOCORE
	FCALL_PRINTSTR("  start = 0x")
	la	a0, start
	BAL(hexserial)
	nop
	FCALL_PRINTSTR("\r\n  s0 = 0x")
	move	a0, s0
	BAL	(hexserial)
	nop

	FCALL_PRINTSTR("\r\n  _edata = 0x")
	la	a0, _edata
	BAL	(hexserial)
	nop

	FCALL_PRINTSTR("\r\n  _end = 0x")
	la	a0, _end
	BAL	(hexserial)
	nop
	FCALL_PRINTSTR("\r\n")

#endif

#if 1
	la	a0, start
	addu a1,a0,s0
	la	a2, _edata
        or      a0, 0xa0000000
        or      a2, 0xa0000000
	subu	t1, a2, a0
	srl	t1, t1, 2

	move	t0, a0
	move	t1, a1
	move	t2, a2

	/* copy text section */
	
1:	and	t3,t0,0x0000ffff
	bnez	t3,2f
	nop
	move	a0,t0
	BAL(hexserial)
	nop
	li	a0,'\r'
	BAL(tgt_putchar)
	nop
2:	lw	t3, 0(t1)
	nop
	sw	t3, 0(t0)
	addu	t0, 4
	addu	t1, 4
	bne	t2, t0, 1b
	nop
#else
	la	a0, start
	li	a1, 0xbfc00000
	la	a2, _edata
	/* copy test section */
1:
	lw	a3, 0(a1)
	sw	a3, 0(a0)
	addu	a0, 4
	bne	a2, a0, 1b
	addu	a1, 4
#endif

	FCALL_PRINTSTR("\ncopy text section done.\r\n")
	
	/* Clear BSS */
	la	a0, _edata
	la	a2, _end
2:	sw	zero, 0(a0)
	bne	a2, a0, 2b
	addu	a0, 4


	FCALL_PRINTSTR("Copy PMON to execute location done.\r\n")
	FCALL_PRINTSTR("sp=");
	move a0, sp
	BAL(hexserial)
	nop

	li	a0, 0
	sw	a0, CpuTertiaryCacheSize /* Set L3 cache size */


	li	msize, 0x08000000 // Lc add 128M
	move	a0,msize
	srl	a0,20
	//li	a1, 0

	la	v0, initmips
	jalr	v0
	nop

.align 3
122:

stuck:
	b	stuck
	nop

/*
 *  Clear the TLB. Normally called from start.S.
 */
#if __mips64
#define MTC0 dmtc0
#else 
#define MTC0 mtc0
#endif
LEAF(CPU_TLBClear)
    b CPU_TLBInit
    nop
END(CPU_TLBClear)

/*
 *  Set up the TLB. Normally called from start.S.
 */
LEAF(CPU_TLBInit)
#if 1
########
##TODO: CODE 3: TLB init
########
	.set mips32
	mfc0 a0, COP_0_CONFIG,1
	.set mips0
	sll  a0, 1
	srl  a0, 26
	addiu a0,a0,1
	
	lui  t0, 0x8000
	mtc0 t0, COP_0_TLB_HI
	li   t0, 0
	mtc0 t0, COP_0_TLB_PG_MASK
	mtc0 t0, COP_0_TLB_LO0
	mtc0 t0, COP_0_TLB_LO1
	

write_TLB:
	mtc0 t0, COP_0_TLB_INDEX
	tlbwi
	bne  t0, a0, write_TLB
	addiu t0,t0,1
	
	
########
##TODO: CODE 3: end
########
#endif
TLBInit_finish:
	jr	ra
	nop
END(CPU_TLBInit)

/*
 * Resume the CPU state, jump to the kernel
 */
LEAF(suspend_resume)
	li	t0,	0xa01ffc00
	lw	ra,	(t0)
	lw	sp,	4(t0)
	lw	s8,	8(t0)
	lw	gp,	12(t0)
	lw	s0,	16(t0)
	lw	s1,	20(t0)
	lw	s2,	24(t0)
	lw	s3,	28(t0)
	lw	s4,	32(t0)
	lw	s5,	36(t0)
	lw	s6,	40(t0)
	lw	s7,	44(t0)

	lw	k0,	48(t0)
	lw	k1,	52(t0)

	lw	v0,	56(t0)
	lw	v1,	60(t0)

	lw	t1,	64(t0)
	mtc0	t1,	$12
	lw	t1,	68(t0)
	mtc0	t1,	$4
	lw	t1,	72(t0)
	mtc0	t1,	$5

	jr	ra
	nop
END(suspend_resume)

LEAF(stringserial)
	nop
	move	a2, ra
	addu	a1, a0, s0
	lbu	a0, 0(a1)
1:
	beqz	a0, 2f
	nop
	bal	tgt_putchar
	addiu	a1, 1
	b	1b
	lbu	a0, 0(a1)

2:
	j	a2
	nop
END(stringserial)

LEAF(outstring)
	move	a2, ra
	move	a1, a0
	lbu	a0, 0(a1)
1:
	beqz	a0, 2f
	nop
	bal	tgt_putchar
	addiu	a1, 1
	b	1b
	lbu	a0, 0(a1)

2:
	j	a2
	nop
END(outstring)

LEAF(hexserial)
	nop
	move	a2, ra
	move	a1, a0
	li	a3, 7
1:
	rol	a0, a1, 4
	move	a1, a0
	and	a0, 0xf
	la	v0, hexchar
	addu	v0, s0
	addu	v0, a0
	bal	tgt_putchar
	lbu	a0, 0(v0)

	bnez	a3, 1b
	addu	a3, -1

	j	a2
	nop
END(hexserial)

LEAF(tgt_putchar)
#ifdef CONFIG_EJTAG_SERIAL
	li v0,CONFIG_EJTAG_SERIAL;
	sb a0,(v0);
	nop
	nop
	jr ra 
	nop
#endif
	nop
	la	v0, COM1_BASE_ADDR
1:
	lbu	v1, NSREG(NS16550_LSR)(v0)
	and	v1, LSR_TXRDY
	beqz	v1, 1b
	nop

	sb	a0, NSREG(NS16550_DATA)(v0)
	j	ra
	nop	
END(tgt_putchar)

LEAF(tgt_testchar)
#ifdef CONFIG_EJTAG_SERIAL
	li v0,CONFIG_EJTAG_SERIAL;
	lb v0,1(v0);
	jr ra 
	nop
#endif
	la	v0, COM1_BASE_ADDR
1:
	lbu	v1, NSREG(NS16550_LSR)(v0)
	and	v0,v1, LSR_RXRDY
	jr ra
	nop
END(tgt_testchar)

LEAF(tgt_getchar)
#ifdef CONFIG_EJTAG_SERIAL
	li v0,CONFIG_EJTAG_SERIAL;
	lb v0,(v0);
	jr ra 
	nop
#endif
	la	v0, COM1_BASE_ADDR
1:
	lbu	v1, NSREG(NS16550_LSR)(v0)
	and	v1, LSR_RXRDY
	beqz	v1, 1b
	nop
	lb	v0, NSREG(NS16550_DATA)(v0)
	jr ra
	nop
END(tgt_getchar)


/* baud rate definitions, matching include/termios.h */
#define B0      0
#define B50     50      
#define B75     75
#define B110    110
#define B134    134
#define B150    150
#define B200    200
#define B300    300
#define B600    600
#define B1200   1200
#define B1800   1800
#define B2400   2400
#define B4800   4800
#define B9600   9600
#define B19200  19200
#define B38400  38400
#define B57600  57600
#define B115200 115200

LEAF(initserial)
	la	v0, COM1_BASE_ADDR  #COM1_BASE_ADDR:0xbfe40000
1:
	li	v1, FIFO_ENABLE|FIFO_RCV_RST|FIFO_XMT_RST|FIFO_TRIGGER_4
	sb	v1, NSREG(NS16550_FIFO)(v0)
########
##TODO: CODE 1: set baud rate
########
    li v1,128
	sb v1,3(v0)
	
	li v1,0x12
	sb v1,0(v0)
	
	li v1,0
	sb v1,1(v0)
	
	
	
########
##TODO: CODE 1: end
########
	li	v1, CFCR_8BITS
	sb	v1, NSREG(NS16550_CFCR)(v0)
	li	v1, MCR_DTR|MCR_RTS
	sb	v1, NSREG(NS16550_MCR)(v0)
	li	v1, 0x0
	sb	v1, NSREG(NS16550_IER)(v0)

	j	ra
	nop
END(initserial)

__main:
	j	ra
	nop

	.rdata
transmit_pat_msg:
	.asciz	"\r\nInvalid transmit pattern.  Must be DDDD or DDxDDx\r\n"
v200_msg:
	.asciz	"\r\nPANIC! Unexpected TLB refill exception!\r\n"
v280_msg:
	.asciz	"\r\nPANIC! Unexpected XTLB refill exception!\r\n"
v380_msg:
	.asciz	"\r\nPANIC! Unexpected General exception!\r\n"
v400_msg:
	.asciz	"\r\nPANIC! Unexpected Interrupt exception!\r\n"
v480_msg:
	.asciz	"\r\nPANIC! You have been in the Ejtag Debug MOde Trap is 0!\r\n"
hexchar:
	.ascii	"0123456789abcdef"

	.text
//	.align	2
/*
 *   I2C Functions used in early startup code to get SPD info from
 *   SDRAM modules. This code must be entirely PIC and RAM independent.
 */

#if 1
// Lc add to test memory
    .ent checkerr
checkerr:
    //la  a0, errstr
    //bal stringserial
    //nop
	PRINTSTR("Error!!\r\n");
	li  t1, 0xbfd00010   //confreg cr04
	lw	t0, 0x0(t1)
	andi t0, t0, 0x5f //LED bit 5
	sw  t0, 0x0(t1)
    jr ra
    nop
    .end checkerr
#if 0
	.rdata
	.align	5
errstr:
    .asciz "error"
#endif
#endif

#define Index_Store_Tag_D			0x09
#define Index_Invalidate_I			0x00
#define Index_Writeback_Inv_D			0x01

LEAF(nullfunction)
	jr ra
	nop
END(nullfunction)

	.ent	cache_init
    .global cache_init
    .set noreorder
	.text
    .set mips32
cache_init:
#if 1
########
##TODO: CODE 2: cache init
########
    li  a0, 0
	mtc0 a0, COP_0_TAG_LO
	li  t0,0x100     // 7 bit index * 1 bit way
	li  t1,0x20      // 5 bit offset
	li  t2,0
	lui  a0, 0x8000

init_I:	
	cache 0x08,0(a0)
	add  a0,a0,t1
	add  t2,t2,1
	bne  t2,t0,init_I  
	nop
	
	li  t0,0x100     // 7 bit index * 1 bit way
	li  t1,0x20      // 5 bit offset
	li  t2,0
	lui  a0, 0x8000

init_D:	
	cache 0x09,0(a0)
	add  a0,a0,t1
	add  t2,t2,1
	bne  t2,t0,init_D  
	nop
	
########
##TODO: CODE 2: end
########
#endif
cache_init_finish:
    jr ra
    nop
	.set	mips1
    .set reorder
	.end 	cache_init

#define REG_ADDRESS 0x0
#define CONFIG_BASE 0xaffffe00

#ddr2 by cww 20090901
#if 1
#include "ddr2fconfig.S"
#endif

