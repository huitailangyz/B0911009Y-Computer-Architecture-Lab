#include <asm.h>
#include <regdef.h>
#include <ucas_cde.h>

#define  CYCLE  25000000 
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
	.set noreorder
	mfc0 t1,$13
	nop
	mfc0 t2,$12
	nop
	and  t1,t2,t1
	add  t2,t1,zero
	andi t2,t2,0x8000
	bne  t2,zero,timer   #IP7
	nop
	add  t2,t1,zero
	andi t2,t2,0x2000
	bne  t2,zero,second  #IP5
	nop
	add  t2,t1,zero
	andi t2,t2,0x1000
	bne  t2,zero,minute   #IP4
	nop
	add  t2,t1,zero
	andi t2,t2,0x0800     #IP3
	bne  t2,zero,hour
	nop
	add  t2,t1,zero
	andi t2,t2,0x0400     #IP2
	bne  t2,zero,change_mode
	nop
	
	
change_mode:
	##run for 0.2 s
	
	add t2,zero,zero
	li  t1,2000000
waste_time1:
	nop
	nop
	add t2,t2,1
	bne t2,t1,waste_time1
	nop
	
	beq  a1,zero,goto_set
	nop
	
leave_set: 
	.set noreorder
	addi a1,a1,-1      # change to run mode
	mfc0 t1,$12    
	ori  t1,0x8000 
	li   t2,0xffffc7ff
	and  t1,t1,t2
	mtc0 t1,$12         # enable time interrupt and disable second/minute/hour change
	mtc0 a2,$9        # take back the CP0_COUNT
.set mips32
	eret
	nop
.set mips0
	
goto_set:
	.set noreorder
	mfc0 a2,$9        # a2   save CP0_COUNT while in set mode
	nop
	mfc0 t1,$12    
	nop
	li   t2,0xffff7fff   
	and  t1,t1,t2     
	li   t2,0x00003800
	or   t1,t1,t2
	mtc0 t1,$12         # disable time interrupt and enable second/minute/hour change
	nop
	addi a1,a1,1      # change to set mode
.set mips32
	eret
	nop
.set mips0

	
timer:
	.set noreorder
	addi a3,a3,1
	
	addi t1,zero,60
	addi t4,zero,10	
	and  t0,t0,zero
	add  t7,a3,zero
	divu zero,t7,t1
	mfhi t2        #second
	nop
	mflo t3     
	nop
	divu zero,t2,t4
	mfhi t5       
	nop
	mflo t6
	nop
	sll  t6,t6,4
	add  t5,t5,t6
	add  t0,t0,t5
	
	divu zero,t3,t1
	mfhi t2        #minute
	nop
	mflo t3        #hour
	nop
	divu zero,t2,t4
	mfhi t5       
	nop
	mflo t6
	nop
	sll  t6,t6,4
	add  t5,t5,t6
	sll  t5,8
	add  t0,t0,t5
	
	divu zero,t3,t4
	mfhi t5       
	nop
	mflo t6
	nop
	sll  t6,t6,4
	add  t5,t5,t6
	sll  t5,16
	add  t0,t0,t5
	sw   t0,(a0)
	
	li   t1, CYCLE
	mtc0 t1, $11         # CP0  compare
	nop
	mtc0 zero, $9          # CP0  count
	nop
.set mips32
	eret
	nop
.set mips0
	
hour:
	addi a3,a3,3600
	j display
	nop
	
minute:
	addi a3,a3,60
	j display
	nop
	
second:
	addi a3,a3,1
	j display
	nop
	
display:
	.set noreorder
	addi t1,zero,60
	addi t4,zero,10
	and  t0,t0,zero
	add  t7,a3,zero
	divu zero,t7,t1
	mfhi t2        #second
	nop
	mflo t3     
	nop
	divu zero,t2,t4
	mfhi t5       
	nop
	mflo t6
	nop
	sll  t6,t6,4
	add  t5,t5,t6
	add  t0,t0,t5
	
	divu zero,t3,t1
	mfhi t2        #minute
	nop
	mflo t3        #hour
	nop
	divu zero,t2,t4
	mfhi t5       
	nop
	mflo t6
	nop
	sll  t6,t6,4
	add  t5,t5,t6
	sll  t5,8
	add  t0,t0,t5
	
	divu zero,t3,t4
	mfhi t5       
	nop
	mflo t6
	nop
	sll  t6,t6,4
	add  t5,t5,t6
	sll  t5,16
	add  t0,t0,t5
	
	##run for 0.2 s
	add t2,zero,zero
	li  t1,2000000
waste_time:
	nop
	nop
	add t2,t2,1
	bne t2,t1,waste_time
	nop
	
	sw   t0,(a0)
.set mips32	
	eret
	nop
.set mips0

locate:
	.set noreorder
	LI (a0,LED_ADDR)           
	LI (t3, 0x0000ffff)  #close the led, liang xia le!!!-_-
	sw t3,(a0)
    LI (a0, NUM_ADDR)    # a0   digital num addr
 	and  a1,zero,a1      # a1   0 : run mode   1: set mode
    and  a3,zero,a3      # a3   save the current time
	
	li t1,0x10408400
	mtc0 t1, $12         # CP0  status	         
	nop
	li   t1, CYCLE
	mtc0 t1, $11         # CP0  compare
	nop
	mtc0 zero, $13       # CP0  cause
	nop
	mtc0 zero, $9        # CP0  count
	nop
	li t1,0x10408401
	mtc0 t1, $12         # CP0  status  open timer and change mode interrupt
	nop
loop:
	j loop
    nop


