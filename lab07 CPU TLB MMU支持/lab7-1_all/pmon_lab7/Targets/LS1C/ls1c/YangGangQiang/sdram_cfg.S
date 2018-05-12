//#define	SD_FREQ		(6 * PLL_M) / (2 * SDRAM_PARAM_DIV_NUM)
#define	ROW_WIDTH	13
#define	ROW_1K		0x7
#define	ROW_2K		0x0
#define	ROW_4K		0x1
#define	ROW_8K		0x2
#define	ROW_16K		0x3

#define	COL_256		0x7
#define	COL_512		0x0
#define	COL_1K		0x1
#define	COL_2K		0x2
#define	COL_4K		0x3

#define	WIDTH_8		0x0
#define	WIDTH_16	0x1
#define	WIDTH_32	0x2
#if 0
#define	TIME_SET(x)	(x * SD_FREQ +999)/1000
#define	TRCD		TIME_SET(20)
#define	TCL			(SD_FREQ / 75 + 2)
#define	TRP			TIME_SET(20)
#define	TRFC		TIME_SET(63)
#define	TRAS		TIME_SET(63)
#define	TREF		(((64000 * SD_FREQ)>>ROW_WIDTH) - 8)
#define	TWR			(SD_FREQ/75 + 1)

#else

#define	TRCD    3		
#define	TCL	3	
#define	TRP	3	
#define	TRFC	7     //9	
#define	TRAS    6		
#define	TREF	0x818	
#define	TWR	2
#endif

#define	DEF_SEL		0x1
#define	DEF_SEL_N	0x0
#define	HANG_UP		0x1
#define	HANG_UP_N	0x0
#define	CFG_VALID	0x1


//#define	SD_PARA0	((TREF - (TREF & 0xf80))<<25 | 
#define	SD_PARA0	((TREF & 0xfe)<<25 | \
					(TRAS << 21) | \
					(TRFC << 17) | (TRP << 14) | (TCL << 11) | \
					(TRCD << 8) | (WIDTH_16 << 6) | (COL_512 << 3) | \
					ROW_8K)

//#define	SD_PARA1	((CFG_VALID << 9) | (HANG_UP_N << 8) | 
#define	SD_PARA1	((HANG_UP_N << 8) | \
					(DEF_SEL_N << 7) | (TWR << 5) | (TREF >> 7))
    
    li  t1, 0xbfd00410
    li  a1, SD_PARA0		#50MHz
    sw  a1, 0x0(t1)
    li  a1, SD_PARA1		#50MHz 32M
#   li  a1, 0x70465182      #40MHz double sdram
#   li  a1, 0x70465142      #40MHz single sdram
    sw  a1, 0x4(t1)
    sw  a1, 0x4(t1)
    li  a1, (SD_PARA1|CFG_VALID <<9)		#50MHz 32M
    sw  a1, 0x4(t1)
    DELAY(1000)
