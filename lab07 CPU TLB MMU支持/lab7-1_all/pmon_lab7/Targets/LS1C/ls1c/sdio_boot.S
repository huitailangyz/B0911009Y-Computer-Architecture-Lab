
/* BJ-YG: 2014-06-16 */
#define	DMA_DESC_ADDR	0xa0001000
#define CONFREG_BASE    0xbfd00000 
#define SDIO_DES_ADDR   0x1fe6c040
#define SDIO_BASE		0xbfe6c000
#define SDICMDARG		0x08
#define SDICMDCON		0x0c

#define SDIDTIMER		0x24
#define SDIBSIZE		0x28
#define SDIDATCON		0x2C
#define SDIINTMSK		0x3C

#define	DATA_LENGTH		0x80000		//512KB
#define	DMA_READ_WORDS	(DATA_LENGTH >> 2)
#define	SDIO_BLK_CNT	(DATA_LENGTH / 512)

#define	CMD_INDEX		0x12	//multi block read
#define	CMST			0x140
#define	WAIT_RSP		0x1
#define	LONG_RSP		0x0
#define	CHECK_CRC		0x1
#define	START_ADDR		0x0


#defined DBG-YG 
boot:
 
#ifdef DBG-YG
######################## uart3 config ##########################
	li	t1, 0xbfd011c0		#uart3 config mux
	li	t2, 0x0
	sw	t2, 0x4(t1)

	li	t1, 0xbfd011d0		#uart3 config mux
	li	t2, 0x6
	sw	t2, 0x4(t1)

	li	t1, 0xbfd011e0		#uart3 config mux
	li	t2, 0x0
	sw	t2, 0x4(t1)

	li	t1, 0xbfd011f0		#uart3 config mux
	li	t2, 0x0
	sw	t2, 0x4(t1)

initseriala:
	la	v0, COM_BASE
1:
	li	v1, FIFO_ENABLE|FIFO_RCV_RST|FIFO_XMT_RST|FIFO_TRIGGER_1
	sb	v1, NSREG(NS16550_FIFO)(v0)
	li	v1, CFCR_DLAB
	sb	v1, NSREG(NS16550_CFCR)(v0)
 	li	v1, 48*1000000/(16*115200)
	sb	v1, NSREG(NS16550_DATA)(v0)
	srl	v1, 8
	sb	v1, NSREG(NS16550_IER)(v0)
	li	v1, CFCR_8BITS
	sb	v1, NSREG(NS16550_CFCR)(v0)
	li	v1, MCR_DTR|MCR_RTS
	sb	v1, NSREG(NS16550_MCR)(v0)
	li	v1, 0x0
	sb	v1, NSREG(NS16550_IER)(v0)
        li      v1, 0x0
        sb      v1, NSREG(NS16550_IER)(v0)
	// test uart3
	li	a1,'a'
	nop
	la	v0, COM_BASE
1:
	lbu	v1, NSREG(NS16550_LSR)(v0)
	and	v1, LSR_TXRDY
	beqz	v1, 1b
	nop
	sb	a1, NSREG(NS16550_DATA)(v0)
#endif  
    
	//config dma0 used for sdio
    li 	a1, 0xbfd00424
    li	a2, 0x1010000   //sdio use dma1 & spi0 pin
    sw  a2, 0x0(a1)

sdio_dma_read:
    #DMA read ddr operation  
    li a1, DMA_DESC_ADDR
    li a2, (DMA_DESC_ADDR | 0x100)
    sw a2, 0x0(a1) # dma_order_addr
    li a2, (DSR_ADDR & 0x1fffffff)
    sw a2, 0x4(a1) # dma_mem_addr
    li	a2, SDIO_DES_ADDR
    and a2, a2, 0x1fffffff
    sw a2, 0x8(a1) # dma_dev_addr
    li a2, DMA_READ_WORDS
    sw a2, 0xc(a1) # dma_length
    li a2, 0x0
    sw a2, 0x10(a1) # dma_step_length
    li a2, 0x1
    sw a2, 0x14(a1) #step times
    li a2, 0x1 
    sw a2, 0x18(a1)	#dma cmd
    # state_reg [12] =1 read  ddr and write devices, 0 write ddr and read devices 
    li a1, ((DMA_DESC_ADDR & 0x1fffffff) | 0x8 | 0x1) # which dma channel to be configured
    li a2, CONFREG_BASE   
    sw a1, 0x1160(a2)
    nop
###################################

sdio_read_multi_blk:
	li	a0, SDIO_BASE
	li	t0, 0x1
	sw	t0, 0x0(a0)	//wulong

	li	a0, SDIO_BASE
	li	t0, 0x10
	sw	t0, 0x4(a0)	//wulong

	li	a0, SDIO_BASE
	li	t0, 0x1ff
	sw	t0, 0x64(a0)

	li	t0, 0x1ff
	sw	t0, 0x3c(a0)  // wulong

	li	t0, 0x200   //512 bytes
	sw	t0, SDIBSIZE(a0)

	li	t0, 0x7fffff   //timer 
	sw	t0, SDIDTIMER(a0)

	li	t0,	(0x1c000 + SDIO_BLK_CNT)	//set 4 wire mode, set block num.
	sw	t0, SDIDATCON(a0)

	li	t0, START_ADDR
	sw	t0, SDICMDARG(a0)
	li	t0, (CMD_INDEX | CMST | (WAIT_RSP<<9) | (LONG_RSP<<10) | (CHECK_CRC<<13))
	sw	t0, SDICMDCON(a0)
cmd_check:


	lw	t0, SDIINTMSK(a0)
	and	t0, 0x20        //cmd send complete

	beqz	t0, cmd_check
	nop

data_check:

	lw	t0, SDIINTMSK(a0)
	and	t0, 0x01         // data complete
	beqz	t0, data_check
	nop

################################################
#if DBG-YG
	li	t5,	0x0
	li	t6,	0x400
	li	v0,	0xbfc00000
	li  	t0,	0xa1000000
sdram_check:

	lw	a0,	0x0(v0)
	lw	a1,	0x0(t0)
	
	bne	a0,	a1,	NEQ 
	nop
	addiu 	v0,	v0,	0x4
	addiu	t0,	t0,	0x4
	addiu	t5,	t5,	0x4
	bne	t5,	t6,	sdram_check
	nop
NEQ:
#endif
