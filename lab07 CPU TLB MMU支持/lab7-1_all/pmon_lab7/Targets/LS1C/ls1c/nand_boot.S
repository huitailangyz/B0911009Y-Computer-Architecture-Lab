/*	lxy-gz: 20130321	*/

#define APB_BASE        0xbfe40000
#define NAND_BASE       0x38000
#define NAND_DMA_OFFSET 0x40
#define UART0_BASEADDR  0xbfe4c000
#define CONFREG_BASE    0xbfd00000 
#define	DMA_DESC_ADDR	0xa0001000

###define BOOT_ECCNAND	0	

#define	NAND_2K_PAGE

#ifdef	NAND_2K_PAGE
	#define	PAGE_SIZE		0x800
	#define	NAND_PARAM_VAL	0x8005000  /*2k Bytes, 5Bytes ID, 1Gb & 2K page*/
#endif

#ifdef BOOT_ECCNAND 
		#define	DATA_LENGTH		0x80000		//512KB
        #define NAND_READ_CMD	0x4903
		#define	DMA_READ_WORDS	(((PAGE_SIZE / 204) * 188) >> 2)
		#define	NAND_READ_BYTES	((PAGE_SIZE / 204) * 204)
		#define	TRANS_TIME		(DATA_LENGTH / DMA_READ_WORDS)
#else
		#define	DATA_LENGTH		0x80000		//512KB
        #define DMA_READ_WORDS	((DATA_LENGTH >> 2))
        #define NAND_READ_BYTES 4*DMA_READ_WORDS	
        #define NAND_READ_CMD	0x103
		#define	TRANS_TIME		0x1
#endif


nandboot:
### config dma_desc ,dma_desc_addr is 0xa0001000,
dma_nand_cfg_read:
    #DMA read ddr operation  
    li a1, DMA_DESC_ADDR
    li a2, (DMA_DESC_ADDR | 0x100)
    sw a2, 0x0(a1) # dma_order_addr
    li a2, (DSR_ADDR & 0x1fffffff)
    sw a2, 0x4(a1) # dma_mem_addr
    li t0, APB_BASE      
    li t1, NAND_BASE      
    or a2, t0,t1 
    li t1, NAND_DMA_OFFSET
    or a2, a2, t1
    and a2, a2, 0x1fffffff
    sw a2, 0x8(a1) # dma_dev_addr
    li a2, DMA_READ_WORDS
    sw a2, 0xc(a1) # dma_length
    li a2, 0x0
    sw a2, 0x10(a1) # dma_step_length
    li a2, TRANS_TIME
    sw a2, 0x14(a1) #step times
    li a2, 0x1 
    sw a2, 0x18(a1)	#dma cmd
    # state_reg [12] =1 read  ddr and write devices, 0 write ddr and read devices 
    li a1, ((DMA_DESC_ADDR & 0x1fffffff) | 0x8) # which dma channel to be configured
    li a2, CONFREG_BASE   
    sw a1, 0x1160(a2)
    nop

#	li	t3,	0
#ifdef	BOOT_ECCNAND	
	li	t4, TRANS_TIME
	li	t3, 0x0
#endif
nand_rd_cmd:
    li  t0, APB_BASE
    li  t1, NAND_BASE 
    or  t2, t1, t0
	li	t1, (NAND_PARAM_VAL)
	sw	t1, 0x18(t2)
#//dbg-yg????????? 
#if 0 
	li  t1,	0
	sw  t1,	0x4(t2)
	sw	t1,	0x8(t2)
#endif 
#//dbg-yg?????????
#if 0 
	li 	t1,	0x820
	sw  t1,	0x0c(t2)
#endif
    li  t1, NAND_READ_BYTES
    sw  t1, 0x1c(t2)	//length
#ifdef	BOOT_ECCNAND	
ecc_rd:
	sw	t3, 0x8(t2)		//page addr
#endif
#	sw	t3, 0x8(t2)		//page addr	  ???
	li	t1,	0x102
	sw  t1,	0x0(t2)
    li  t1, NAND_READ_CMD
    sw  t1, 0x0(t2)
    nop
	DELAY(10000)
1:
    lw      a1, 0x0(t2)
    and     a1, a1, 0x400
    beqz    a1, 1b
    nop
#ifdef	BOOT_ECCNAND	
    sw		zero, 0x0(t2)	//clear nand_control's cmd
	sub		t4, 1
	add		t3,	1			//increase page addr
	bnez	t4, ecc_rd
	nop
#endif
    li  t1, 0x10	//stop DMA
    sw  t1, 0x1160(a2)

