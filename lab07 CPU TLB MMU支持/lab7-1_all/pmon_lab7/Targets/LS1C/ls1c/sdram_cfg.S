#define	SDRAM_PARAM_DIV_NUM		((1 << (SDRAM_DIV+1)) % 5)
#define	SD_FREQ		((6 * PLL_M) / (CPU_DIV * SDRAM_PARAM_DIV_NUM))

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

/****** 需要根据不同内存芯片进行修改的值 *******/
/*1C Demo核心板上使用两个８位　13(row)x10(col) 的sdram 颗粒并联，相当于16位位宽*/
#define	ROW_WIDTH	13			/*A0~A12*/
#define ROW_VAL     ROW_8K		

#define WIDTH_VAL   WIDTH_16   /*位宽*/
#define COL_VAL		COL_1K
/****************************************/

#define	TIME_SET(x)	(x * SD_FREQ +999)/1000
#define	TRCD		TIME_SET(20)
#define	TCL			(SD_FREQ / 75 + 2)
#define	TRP			TIME_SET(20)
#define	TRFC		TIME_SET(63)
#define	TRAS		TIME_SET(63)
#define	TREF		(((64000 * SD_FREQ)>>ROW_WIDTH) - 8)
#define	TWR			(SD_FREQ/75 + 1)

#define	DEF_SEL		0x1
#define	DEF_SEL_N	0x0
#define	HANG_UP		0x1
#define	HANG_UP_N	0x0
#define	CFG_VALID	0x1

#define	SD_PARA0	((TREF - (TREF & 0xf80))<<25 | \
					(TRAS << 21) | \
					(TRFC << 17) | (TRP << 14) | (TCL << 11) | \
					(TRCD << 8) | (WIDTH_VAL << 6) | (COL_VAL << 3) | \
					ROW_VAL)

#define	SD_PARA1	((CFG_VALID << 9) | (HANG_UP_N << 8) | \
					(DEF_SEL_N << 7) | (TWR << 5) | (TREF >> 7))
