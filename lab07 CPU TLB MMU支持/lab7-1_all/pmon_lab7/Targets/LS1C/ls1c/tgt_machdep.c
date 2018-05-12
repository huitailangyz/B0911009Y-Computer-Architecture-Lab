/*	$Id: tgt_machdep.c,v 1.1.1.1 2006/09/14 01:59:08 root Exp $ */

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
#if 1
#include <sys/param.h>
#include <sys/syslog.h>
#include <machine/endian.h>
#include <sys/device.h>
#include <machine/cpu.h>
#include <machine/pio.h>
#include <machine/intr.h>
#include <dev/pci/pcivar.h>
#endif
#include <sys/types.h>
#include <termio.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>

#include <dev/ic/mc146818reg.h>
#include <linux/io.h>

#include <autoconf.h>

#include <machine/cpu.h>
#include <machine/pio.h>
#include "pflash.h"
#include "dev/pflash_tgt.h"

#include "include/fcr.h"
#include <pmon/dev/gt64240reg.h>
#include <pmon/dev/ns16550.h>
#include <target/types.h>
#include <target/lcd.h>

#include <pmon.h>

#include "mod_x86emu_int10.h"
#include "mod_x86emu.h"
#include "mod_vgacon.h"
#include "mod_framebuffer.h"

#define DEBUG_YG 0


#if (NMOD_X86EMU_INT10 > 0)||(NMOD_X86EMU >0)
extern int vga_bios_init(void);
#endif
extern int radeon_init(void);
extern int kbd_initialize(void);
extern int write_at_cursor(char val);
extern const char *kbd_error_msgs[];


#include "flash.h"
#if (NMOD_FLASH_AMD + NMOD_FLASH_INTEL + NMOD_FLASH_SST) == 0
#ifdef HAVE_FLASH
#undef HAVE_FLASH
#endif
#else
#define HAVE_FLASH
#endif

#define REG_TOY_READ0 0xbfe6402c
#define REG_TOY_READ1 0xbfe64030
#define REG_TOY_WRITE0 0xbfe64024
#define REG_TOY_WRITE1 0xbfe64028
#define REG_CNTRCTL 0xbfe64040


#undef NVRAM_IN_NAND

extern struct trapframe DBGREG;

extern void *memset(void *, int, size_t);

extern void stringserial(char *);


int kbd_available;
int usb_kbd_available;
int vga_available=0;

static int md_pipefreq = 0;
static int kkkk = 0;
static int md_cpufreq = 0;
static int clk_invalid = 0;
static int nvram_invalid = 0;
static int cksum(void *p, size_t s, int set);
void _probe_frequencies(void);

#ifndef NVRAM_IN_FLASH
void nvram_get(char *);
void nvram_put(char *);
#endif

extern int vgaterm(int op, struct DevEntry * dev, unsigned long param, int data);
extern int fbterm(int op, struct DevEntry * dev, unsigned long param, int data);
void error(unsigned long *adr, unsigned long good, unsigned long bad);
void modtst(int offset, int iter, unsigned long p1, unsigned long p2);
void do_tick(void);
void print_hdr(void);
void ad_err2(unsigned long *adr, unsigned long bad);
void ad_err1(unsigned long *adr1, unsigned long *adr2, unsigned long good, unsigned long bad);
void mv_error(unsigned long *adr, unsigned long good, unsigned long bad);

void print_err( unsigned long *adr, unsigned long good, unsigned long bad, unsigned long xor);
void init_legacy_rtc(void);

/*** changed by sunyoung_yg 2015-07-04 *****/
ConfigEntry	ConfigTable[] =
{
	 { (char *)COM_BASE, 0, ns16550, 256, CONS_BAUD, NS16550HZ},
#ifdef	HAVE_MUT_COM
	 { (char *)COM3_BASE_ADDR, 0, ns16550, 256, CONS_BAUD, NS16550HZ},
#endif
#if NMOD_VGACON >0 && NMOD_FRAMEBUFFER >0
	{ (char *)1, 0, fbterm, 256, CONS_BAUD, NS16550HZ },
#endif
	{ 0 }
};
/*
ConfigEntry	ConfigTable[] =
{
	 { (char *)COM1_BASE_ADDR, 0, ns16550, 256, CONS_BAUD, NS16550HZ},
#ifdef	HAVE_MUT_COM
	 { (char *)COM3_BASE_ADDR, 0, ns16550, 256, CONS_BAUD, NS16550HZ},
#endif
#if NMOD_VGACON >0 && NMOD_FRAMEBUFFER >0
	{ (char *)1, 0, fbterm, 256, CONS_BAUD, NS16550HZ },
#endif
	{ 0 }
};
*/
unsigned long _filebase;

extern int memorysize;
extern int memorysize_high;

extern char MipsException[], MipsExceptionEnd[];

unsigned char hwethadr[6];
static unsigned int pll_reg0,pll_reg1;

void initmips(unsigned int memsz);

void addr_tst1(void);
void addr_tst2(void);
void movinv1(int iter, ulong p1, ulong p2);


//#define	HPET
void hpet_test(void)
{
	hpet_init();

//	while(1)
//		get_hpet_sts();
//	while(!check_intr())
//		;
//	hpet_intr();

}

#define NMOD_SDCARD_STORAGE  1


//#define GS_SOC_CAN
//#ifdef
//void can_test(void);
//#endif

//#define GS_SOC_I2C

#ifdef GS_SOC_I2C
#include <target/i2c.h>
void idelay(int n)
{
	int count = n;
	while(count > 0)
		count--;
	
}

int i2c_test(void)
{
	char i,j;
	
	for(i = 0x10; i < 0x20; i++)
	{	
		i2c_write(i+10,i);
		idelay(100);
		printf("===i2c_read addr: 0x%x  ,val: 0x%x\n",i,i2c_read(i));
	}
}

#endif

void pci_conf_dump(void)
{
	unsigned int * cfg_map;
	unsigned int * conf_reg;
	unsigned long data;
	unsigned long data1;
	int i,j;

	
	data1 = readl(0xbfd00410);
	printf("===%x \n",data1);
	
		cfg_map = (unsigned int *)(0xbfd01120);
		for(i = 0;i < 0x40;i = i+0x4)
		{
			*(cfg_map) = 0x1;
			conf_reg = (unsigned int *)(0xbc100000+i);
		
			data = *(conf_reg);
			printf("==conf_reg %d : %x\n",i,data);
		
		}

}


//#define GMAC
#ifdef GMAC
int ls1f_gmac_init(void)
{
	return	SynopGMAC_Host_Interface_init();	
}

#endif

extern int pwm_test(void);
void
initmips(unsigned int memsz)
{
	/*
	 *	Set up memory address decoders to map entire memory.
	 *	But first move away bootrom map to high memory.
	 */


	SBD_DISPLAY("init",0);
	memorysize = memsz > 256 ? 256 << 20 : memsz << 20;
	memorysize_high = memsz > 256 ? (memsz - 256) << 20 : 0;

   // memorysize -= 0x100000;

	/*
	 *  Probe clock frequencys so delays will work properly.
	 */
	tgt_cpufreq();
	SBD_DISPLAY("DONE",0);
	
	/*
	 *  Init PMON and debug
	 */
	cpuinfotab[0] = &DBGREG;
	dbginit(NULL);

	/*
	 *  Set up exception vectors.
	 */
	SBD_DISPLAY("BEV1",0);
	bcopy(MipsException, (char *)TLB_MISS_EXC_VEC, MipsExceptionEnd - MipsException);
	bcopy(MipsException, (char *)GEN_EXC_VEC, MipsExceptionEnd - MipsException);

	CPU_FlushCache();

	CPU_SetSR(0, SR_BOOT_EXC_VEC);  
	SBD_DISPLAY("BEV0",0);

	printf("BEV in SR set to zero.\n");
	ls1g_soc_nand_init();

#ifdef  MEMSCAN	
	memscan();
#endif	

#ifdef	HPET
	hpet_test();
#endif
	
#ifdef	GMAC	
	ls1f_gmac_init();
#endif	

	//pwm_test();
	/*
	 * Launch!
	 */
	main();
}


#define FCR_PS2_BASE	0xbfe60000		//sw
//#define FCR_PS2_BASE	0xbf508000		//sw
#define PS2_RIBUF		0x00	/* Read */
#define PS2_WOBUF		0x00	/* Write */
#define PS2_RSR			0x04	/* Read */
#define PS2_WSC			0x04	/* Write */
#define PS2_DLL			0x08		//sw: is it right?
#define PS2_DLH			0x09
int init_kbd(void)
{
    int ldd;
    //ldd 5us/(1/clk)=5*t, kbdclk is ddrclk/2/ldd
    ldd = 10*APB_CLK/1000000*DDR_MULT/2;
    KSEG1_STORE8(FCR_PS2_BASE+PS2_DLL, ldd & 0xff);
    KSEG1_STORE8(FCR_PS2_BASE+PS2_DLH, (ldd >> 8) & 0xff);
	//pckbd_init_hw();
   return 1;
}

/*
 *  Put all machine dependent initialization here. This call
 *  is done after console has been initialized so it's safe
 *  to output configuration and debug information with printf.
 */
int psaux_init(void);
extern int video_hw_init (void);

int have_pci=0;		//sw
extern int fb_init(unsigned long,unsigned long);
extern int dc_init(void);

#ifdef GC300
extern unsigned long GPU_fbaddr;
#endif

void
tgt_devconfig(void)
{


#if NMOD_VGACON > 0
	int rc=0;
#if NMOD_FRAMEBUFFER > 0 
	unsigned long fbaddress,ioaddress;
	extern struct pci_device *vga_dev;
#endif
#endif
	if(have_pci)_pci_devinit(1);	/* PCI device initialization */

#if NMOD_FRAMEBUFFER > 0
	printf("begin fb_init\n");
	fbaddress = dc_init();
	fbaddress |= 0xa0000000;
#ifdef GC300
	GPU_fbaddr = fbaddress ;
#endif

	fb_init(fbaddress, 0);
	printf("after fb_init\n");

	rc=1;
#endif
#if (NMOD_FRAMEBUFFER > 0) || (NMOD_VGACON > 0 )
	if (rc > 0){
		if (!getenv("novga")) 
			vga_available=1;
		else 
			vga_available=0;
	}
#endif

	config_init();
   
	/*end usb reset*/
#if LS1ASOC
	/*ls1a usb reset stop*/
	*(volatile int *)0xbff10204 |= 0x40000000;
#elif   LS1BSOC
	/*ls1b usb reset stop*/
	*(volatile int *)0xbfd00424 |= 0x80000000;
#else   

	*(volatile int *)0xbff10204 |= 0x40000000;
    
	//*(volatile int *)0xbfd00424 |= 0x80000000;
#endif

    *((volatile unsigned int *)0xbfd00424) &= ~(7 << 28); //lxy  MII mode
#ifdef RMII
    *((volatile unsigned int *)0xbfd00424) |= (1 << 30); //wl    RMII mode 
#endif

	
	printf("====before configure\n");
	configure();
    
#if (NMOD_VGACON >0) && defined(LS1ASOC)
	printf("====before init ps/2 kbd\n");
	if(getenv("nokbd"))
		rc=1;
	else{
		init_kbd();
		rc=kbd_initialize();
		pckbd_leds(2);
	}
	if(!rc){ 
		kbd_available=1;
	}
	psaux_init();
#endif
//	extern   void norflash_init();
//	norflash_init();           //lxy
   printf("devconfig done.\n");

}

extern int test_icache_1(short *addr);
extern int test_icache_2(int addr);
extern int test_icache_3(int addr);
extern void godson1_cache_flush(void);
#define tgt_putchar_uc(x) (*(void (*)(char)) (((long)tgt_putchar)|0x20000000)) (x)

#define I2C_WRITE
int i2c_init(void);
void init_lcd(void);
void
tgt_devinit(void)
{
	SBD_DISPLAY("DINI",0);
	
	/*
	 *  Gather info about and configure caches.
	 */
	if(getenv("ocache_off")) {
		CpuOnboardCacheOn = 0;
	}
	else {
		CpuOnboardCacheOn = 1;
	}
	if(getenv("ecache_off")) {
		CpuExternalCacheOn = 0;
	}
	else {
		CpuExternalCacheOn = 1;
	}
	
	
	
    CPU_ConfigCache();

#define CONFIG_DE2114X y 
#ifdef 	CONFIG_DE2114X
{
/* something wrong here 	sw
	// *(volatile unsigned long *)(0xa0000000|AHB_MISC_BASE) =0x020b0000;
	unsigned long t = *(volatile unsigned long *)(0xa0000000|AHB_MISC_BASE);
	*(volatile unsigned long *)(0xa0000000|AHB_MISC_BASE) =0x00030000 | t;
	// *(volatile unsigned long *)(0xa0000000|AHB_MISC_BASE) =0x00030000 | 0x020F0000;
*/
}
#endif

#if 0   //lxy
//sw: set clock delay
	(*(volatile u32*)(0xbfd00410) = (0x24a8));
//sw: enable gpio	
	(*(volatile u32*)(0xbfd010c8) = (0xf00004));
	(*(volatile u32*)(0xbfd010d8) = (0xf00000));
//	(*(volatile u32*)(0xbc180000+0x20) = 0x0;
//	(*(volatile u32*)(0xbc180000+0x24) = 0x80000000;
#endif
//	printf("==pci_businit: clock delay %x\n",readl(0xbfd00410));
	printf("==gpio: gpio status %x\n",readl(0xbfd010e8));
	
	if(have_pci)_pci_businit(1);	/* PCI bus initialization */

//extern  gc0308_test(); gc0308_test();

//extern  uda1342_test();
//    uda1342_test();
	
#if 0
#ifdef GS_SOC_I2C	
	i2c_init();
	i2c_test();
	
#endif
#endif

#ifdef GS_SOC_CAN
	can_test();
#endif
	
}



/*
 *  This function makes inital HW setup for debugger and
 *  returns the apropriate setting for the status register.
 */
register_t
tgt_enable(int machtype)
{
	/* XXX Do any HW specific setup */
	return(SR_COP_1_BIT|SR_FR_32|SR_EXL);
}


/*
 *  Target dependent version printout.
 *  Printout available target version information.
 */
void
tgt_cmd_vers(void)
{
}

/*
 *  Display any target specific logo.
 */
void
tgt_logo(void)
{
    printf("\n");
    printf("[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[\n");
    printf("[[[            [[[[   [[[[[[[[[[   [[[[            [[[[   [[[[[[[  [[\n");
    printf("[[   [[[[[[[[   [[[    [[[[[[[[    [[[   [[[[[[[[   [[[    [[[[[[  [[\n");
    printf("[[  [[[[[[[[[[  [[[  [  [[[[[[  [  [[[  [[[[[[[[[[  [[[  [  [[[[[  [[\n");
    printf("[[  [[[[[[[[[[  [[[  [[  [[[[  [[  [[[  [[[[[[[[[[  [[[  [[  [[[[  [[\n");
    printf("[[   [[[[[[[[   [[[  [[[  [[  [[[  [[[  [[[[[[[[[[  [[[  [[[  [[[  [[\n");
    printf("[[             [[[[  [[[[    [[[[  [[[  [[[[[[[[[[  [[[  [[[[  [[  [[\n");
    printf("[[  [[[[[[[[[[[[[[[  [[[[[  [[[[[  [[[  [[[[[[[[[[  [[[  [[[[[  [  [[\n");
    printf("[[  [[[[[[[[[[[[[[[  [[[[[[[[[[[[  [[[  [[[[[[[[[[  [[[  [[[[[[    [[\n");
    printf("[[  [[[[[[[[[[[[[[[  [[[[[[[[[[[[  [[[   [[[[[[[[   [[[  [[[[[[[   [[\n");
    printf("[[  [[[[[[[[[[[[[[[  [[[[[[[[[[[[  [[[[            [[[[  [[[[[[[[  [[\n");
    printf("[[[[[[[2005][[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[\n"); 
}

void init_legacy_rtc(void)
{
	int year, month, date, hour, min, sec;
	unsigned int v;

	outl(REG_CNTRCTL,0x2d00);
	v = inl(REG_TOY_READ0);
	year = inl(REG_TOY_READ1) - 1900;
	month = (v>>26)&0xf;
	date = (v>>21)&0x1f;
	hour = (v>>16)&0x1f;
	min =  (v>>10)&0x3f;
	sec = (v>>4)&0x3f;
	if( (year > 200) || (month < 1 || month > 12) ||
		(date < 1 || date > 31) || (hour > 23) || (min > 59) ||
		(sec > 59) ){
		tgt_printf("RTC time invalid, reset to epoch.\n");

		outl(REG_TOY_WRITE1,2011);
		v = ((4+1)<<26)|(20<<21)|(10<<16)|(1<<10)|(0);
		outl(REG_TOY_WRITE0,v);
	}
}
/*
 *  md_pipefreq  is CPU freq
 *  md_cpufreq   is MEM freq
 * */
                                                                               
void _probe_frequencies(void)
{
	SBD_DISPLAY ("FREQ", CHKPNT_FREQ);
	
	/*clock manager register*/
#define PLL_FREQ_REG(x) *(volatile unsigned int *)(0xbfe78030+x)
#ifdef LS1ASOC
	{
		int val= PLL_FREQ_REG(0);
		md_pipefreq = ((val&7)+1)*APB_CLK;        /* NB FPGA*/
		md_cpufreq  =  (((val>>8)&7)+3)*APB_CLK;
	}
/*
#elif defined    LS1BSOC
	{
		int pll,ctrl,clk;
		pll=PLL_FREQ_REG(0);
		ctrl=PLL_FREQ_REG(4);
		clk=(12+(pll&0x3f))*33333333/2 + ((pll>>8)&0x3ff)*33333333/2/1024;
		md_pipefreq = ((ctrl&0x300)==0x300)?33333333:(ctrl&(1<<25))?clk/((ctrl>>20)&0x1f):clk/2;
		md_cpufreq  = ((ctrl&0xc00)==0xc00)?33333333:(ctrl&(1<<19))?clk/((ctrl>>14)&0x1f):clk/2;
	}
*/
#else
#if 0  //ori
		unsigned int val = *(volatile unsigned int *)0xbfe78030;
		md_pipefreq = ((val >> 8) & 0xff) * 6 / 2 * 1000000 ;
		val = (1 << ((val & 0x3) + 1)) % 5;
		md_cpufreq  = md_pipefreq / val;
#else  //by zmz
		unsigned int val = *(volatile unsigned int *)0xbfe78030;
		unsigned int cpu_div = *(volatile unsigned int*)0xbfe78034;
		cpu_div = (cpu_div >> 8) & 0x3f;
		md_pipefreq = ((val >> 8) & 0xff) * 6 / cpu_div * 1000000 ;
		val = (1 << ((val & 0x3) + 1)) % 5;
		md_cpufreq  = md_pipefreq / val;
#endif
#if 0
		float aa=0;
             static    int bb=0;
                //md_pipefreq = ((val >> 8) & 0xff) * 6 / 2 * 1000000 ;
		//val = (1 << ((val & 0x3) + 1)) % 5;
		//md_cpufreq  = md_pipefreq / val;
		//aa = (APB_CLK/4/CPU_DIV*((val>>8 & 0xff)+(val >>16 &0xff)*1.0/256)) ;
		//bb = (int)(APB_CLK/4/CPU_DIV*((val>>8 & 0xff)+(val >>16 &0xff)*1.0/256)) ;
	        //val = 0x7fffffff;
	        //val =   0x80000000;
                //tgt_printf("val====0x%08x\n",val);
                
                //bb = (int)((0x8064409c)*1.0/1) ;
                //bb = (int)((val)*1.0/1) ;
                //bb = (int)((val)*1.0/1) ;
                //while(1);
		//kkkk = (int)(APB_CLK/4/CPU_DIV*((val>>8 & 0xff)+(val >>16 &0xff)*1.0/256)) ;
		//md_pipefreq = (int)(APB_CLK/4/CPU_DIV*((val>>8 & 0xff)+(val >>16 &0xff)*1.0/256)) ;
  //              printf("aa===%f\n",aa);
		//md_pipefreq =(int) (APB_CLK/4/CPU_DIV*((val>>8 & 0xff)+(val >>16 &0xff)*1.0/256)) ;
		md_pipefreq =(int) (APB_CLK/4/CPU_DIV*((val>>8 & 0xff)+(val >>16 &0xff)/256)) ;
    #ifdef CPU_2_SDRAM_DIV2 
                md_cpufreq  = md_pipefreq /2 ;
    #elif defined CPU_2_SDRAM_DIV3                
                md_cpufreq  = md_pipefreq /3 ;
    #else                
                md_cpufreq  = md_pipefreq /4 ;  
    #endif
#endif
#endif

//clk_invalid用于标记RTC是否有效 1：无效 0：有效
#ifdef HAVE_TOD
//	clk_invalid = 1;
	clk_invalid = 0;
#endif
//如果定义了HAVE_TOD即使用RTC实时时钟（loongson 1B 有实时时钟模块）则执行下面的代码 用于计算CPU和总线(内存)的频率
//这会导致1-2秒钟的延时
//#ifdef HAVE_TOD
#if 0
	int i, timeout, cur, sec, cnt;
	unsigned int v;
	init_legacy_rtc();

	SBD_DISPLAY ("FREI", CHKPNT_FREQ);

	/*
	* Do the next twice for two reasons. First make sure we run from
	* cache. Second make sure synched on second update. (Pun intended!)
	*/
	for(i = 2;  i != 0; i--) {
		cnt = CPU_GetCOUNT();
		timeout = 10000000;
		v = inl(REG_TOY_READ0);
		sec = (v>>4)&0x3f;
				                           
				                           
		do {
			timeout--;
			v = inl(REG_TOY_READ0);
			cur = (v>>4)&0x3f;
		} while(timeout != 0 && cur == sec);
				                           
		cnt = CPU_GetCOUNT() - cnt;
		if(timeout == 0) {
			break;          /* Get out if clock is not running */
		}
	}
		                               
	/*
	*  Calculate the external bus clock frequency.
	*/
	if (timeout != 0) {
		clk_invalid = 0;
		md_pipefreq = cnt / 10000;
		md_pipefreq *= 20000;
		/* we have no simple way to read multiplier value
		*/
	}
#endif /* HAVE_TOD */
}
                                                                               

/*
 *   Returns the CPU pipelie clock frequency
 */
int
tgt_pipefreq(void)
{
	if(md_pipefreq == 0) {
		_probe_frequencies();
	}
	return(md_pipefreq);
}

/*
 *   Returns the external clock frequency, usually the bus clock
 */
int
tgt_cpufreq(void)
{
	if(md_cpufreq == 0) {
		_probe_frequencies();
	}
	return(md_cpufreq);
}

time_t
tgt_gettime(void)
{
	struct tm tm;
	time_t t;

#ifdef HAVE_TOD
	unsigned int year,v;

	if(!clk_invalid) {
		v = inl(REG_TOY_READ0);
		year = inl(REG_TOY_READ1);
				                                       
		tm.tm_sec = (v>>4)&0x3f;
		tm.tm_min = (v>>10)&0x3f;
		tm.tm_hour = (v>>16)&0x1f;
		tm.tm_wday = 0;
		tm.tm_mday = (v>>21)&0x1f;
		tm.tm_mon = ((v>>26)&0xf) - 1;
		tm.tm_year = year - 1900;
		if(tm.tm_year < 50)tm.tm_year += 100;
				                                       
		tm.tm_isdst = tm.tm_gmtoff = 0;
		t = gmmktime(&tm);
	}
	else 
#endif
	{
		t = 957960000;  /* Wed May 10 14:00:00 2000 :-) */
	}
	return(t);
}
                                                                               
/*
 *  Set the current time if a TOD clock is present
 */
void
tgt_settime(time_t t)
{
	struct tm *tm;

	#ifdef HAVE_TOD
	unsigned int year,v;
	if(!clk_invalid) {
		tm = gmtime(&t);

		outl(REG_TOY_WRITE1,tm->tm_year + 1900);
		v = ((tm->tm_mon+1)<<26)|(tm->tm_mday<<21)|(tm->tm_hour<<16)|(tm->tm_min<<10)|(tm->tm_sec);
		outl(REG_TOY_WRITE0,v);
	}
	#endif
}


/*
 *  Print out any target specific memory information
 */
void
tgt_memprint(void)
{
	printf("Primary Instruction cache size %dkb (%d line, %d way)\n",
		CpuPrimaryInstCacheSize / 1024, CpuPrimaryInstCacheLSize, CpuNWayCache);
	printf("Primary Data cache size %dkb (%d line, %d way)\n",
		CpuPrimaryDataCacheSize / 1024, CpuPrimaryDataCacheLSize, CpuNWayCache);
	if(CpuSecondaryCacheSize != 0) {
		printf("Secondary cache size %dkb\n", CpuSecondaryCacheSize / 1024);
	}
	if(CpuTertiaryCacheSize != 0) {
		printf("Tertiary cache size %dkb\n", CpuTertiaryCacheSize / 1024);
	}
}

void
tgt_machprint(void)
{
	printf("Copyright 2000-2002, Opsycon AB, Sweden.\n");
	printf("Copyright 2005, ICT CAS.\n");
	printf("CPU %s @", md_cpuname());
} 

/*
 *  Return a suitable address for the client stack.
 *  Usually top of RAM memory.
 */

register_t
tgt_clienttos(void)
{
	return((register_t)(int)PHYS_TO_UNCACHED(memorysize & ~7) - 64);
}

#ifdef HAVE_FLASH
/*
 *  Flash programming support code.
 */

/*
 *  Table of flash devices on target. See pflash_tgt.h.
 */

struct fl_map tgt_fl_map_boot16[]={
	TARGET_FLASH_DEVICES_16
};


struct fl_map *
tgt_flashmap(void)
{
	return tgt_fl_map_boot16;
}   
void
tgt_flashwrite_disable(void)
{
}

int
tgt_flashwrite_enable(void)
{
#ifdef FLASH_READ_ONLY
	return 0;
#else
	return(1);
#endif
}

void
tgt_flashinfo(void *p, size_t *t)
{
	struct fl_map *map;

	map = fl_find_map(p);
	if(map) {
		*t = map->fl_map_size;
	}
	else {
		*t = 0;
	}
}

void
tgt_flashprogram(void *p, int size, void *s, int endian)
{
	printf("Programming flash %x:%x into %x\n", s, size, p);
	if(fl_erase_device(p, size, TRUE)) {
		printf("Erase failed!\n");
		return;
	}
	if(fl_program_device(p, s, size, TRUE)) {
		printf("Programming failed!\n");
	}
	fl_verify_device(p, s, size, TRUE);
}
#endif /* PFLASH */


/*add by hb, test program nand flash*/
#ifdef NAND_BOOT
 void
tgt_nand_flashinfo(void *p, size_t *t)
{

//	printf("tgt_nand_flashinfo\n");
	nand_probe_boot();
	
	*t = 128*1024;  //  128M
}
/*********************************************************
 *p   : flashaddr  (bytes)
 *size: size (bytes)
 *s   : load from ram  addr
 *endian: 0  (LSB)
 ********************************************************/
void
tgt_nand_flashprogram(void *p, int size, void *s, int endian)
{

//	printf("Programming flash 0x%x:0x%x into 0x%x, edndian? %x\n", s, size, p, endian);
#if 1
	if(nand_erase_boot(p, size, TRUE)) {
		printf("Erase failed!\n");
		return;
	}
	
//	printf("after erase!\n");

	if(nand_program_boot(p, s, size, TRUE)) {
		printf("Programming failed!\n");
	}
#endif
	nand_verify_boot(p, s, size, TRUE);
	
}
#endif



/*
 *  Network stuff.
 */
void
tgt_netinit(void)
{
}

int
tgt_ethaddr(char *p)
{
	bcopy((void *)&hwethadr, p, 6);
	return(0);
}

void
tgt_netreset(void)
{
}

/*************************************************************************/
/*
 *	Target dependent Non volatile memory support code
 *	=================================================
 *
 *
 *  On this target a part of the boot flash memory is used to store
 *  environment. See EV64260.h for mapping details. (offset and size).
 */

/*
 *  Read in environment from NV-ram and set.
 */
void
tgt_mapenv(int (*func) __P((char *, char *)))
{
	char *ep;
	char env[NVRAM_SECSIZE];
	char *nvram;
	int i;

        /*
         *  Check integrity of the NVRAM env area. If not in order
         *  initialize it to empty.
         */
	printf("in envinit\n");
#ifdef NVRAM_IN_FLASH
    nvram = (char *)(tgt_flashmap())->fl_map_base;
	printf("nvram=%08x\n",(unsigned int)nvram);
	if(fl_devident(nvram, NULL) == 0 ||
           cksum(nvram + NVRAM_OFFS, NVRAM_SIZE, 0) != 0) {
#else /**/ 
	size_t * flashsize;
	tgt_nand_flashinfo(NVNAND_POS, &flashsize );  /*初始化 nand 相关结构体*/
    nvram = (char *)malloc(NVRAM_SECSIZE);

#if DEBUG_YG
	unsigned char buf[2048];
//	memset(buf, 0x55, 2048);
	for(i=0;i<2048; i++)
		buf[i] = i&0xff;
	nvram_put(buf);
#endif
	memset(nvram, 0, NVRAM_SECSIZE);
	nvram_get(nvram);
#endif
#if DEBUG_YG
	i = strncmp(buf, nvram, NVRAM-SECSIZE);
	printf(" ----------------------------------------dbg-yg i = %d ...\r\n", i);
	for(i=0; i<100; i++)
	{
		if(i%16==0) printf("\r\n");
		printf(" 0x%02x ",nvram[i]);
		
	}
#endif
	if(cksum(nvram, NVRAM_SIZE, 0) != 0) {
		        printf("NVRAM is invalid!\n");
                nvram_invalid = 1;
        }
        else {
				nvram += NVRAM_OFFS;
                ep = nvram+2;

                while(*ep != 0) {
                        char *val = 0, *p = env;
						i = 0;
                        while((*p++ = *ep++) && (ep <= nvram + NVRAM_SIZE - 1) && i++ < 255) {
                                if((*(p - 1) == '=') && (val == NULL)) {
                                        *(p - 1) = '\0';
                                        val = p;
                                }
                        }
                        if(ep <= nvram + NVRAM_SIZE - 1 && i < 255) {
                                (*func)(env, val);  /* env 是pmon下 set 时显示的“=”左边的变量，val是右边的字符串*/
                        }
                        else {
                                nvram_invalid = 2;
                                break;
                        }
                }
        }

	printf(" -----------------dbg-yg  nvram_invalid is %d .......\r\n", nvram_invalid);
	printf("NVRAM@%x\n",(u_int32_t)nvram);

	/*
	 *  Ethernet address for Galileo ethernet is stored in the last
	 *  six bytes of nvram storage. Set environment to it.
	 */

#if 0   //lxy: disable this for debug
	bcopy(&nvram[ETHER_OFFS], hwethadr, 6);
	sprintf(env, "%02x:%02x:%02x:%02x:%02x:%02x", hwethadr[0], hwethadr[1],
	    hwethadr[2], hwethadr[3], hwethadr[4], hwethadr[5]);
	(*func)("ethaddr", env);

	sprintf(env, "0x%08x",(pll_reg0=*(volatile int *)0xbfe78030));
	(*func)("pll_reg0", env);
	sprintf(env, "0x%08x",(pll_reg1=*(volatile int *)0xbfe78034));
	(*func)("pll_reg1", env);

#ifndef NVRAM_IN_FLASH
	free(nvram);
#endif

#ifdef no_thank_you
    (*func)("vxWorks", env);
#endif
#endif


	sprintf(env, "%d", memorysize / (1024 * 1024));
	(*func)("memsize", env);

	sprintf(env, "%d", memorysize_high / (1024 * 1024));
	(*func)("highmemsize", env);

	sprintf(env, "%d", md_pipefreq);
	(*func)("cpuclock", env);

	sprintf(env, "%d", md_cpufreq);
	(*func)("busclock", env);

	(*func)("systype", SYSTYPE);
	

}

int
tgt_unsetenv(char *name)
{
        char *ep, *np, *sp;
        char *nvram;
        char *nvrambuf;
        char *nvramsecbuf;
	int status;

        if(nvram_invalid) {
                return(0);
        }

	/* Use first defined flash device (we probably have only one) */
#ifdef NVRAM_IN_FLASH
        nvram = (char *)(tgt_flashmap())->fl_map_base;

	/* Map. Deal with an entire sector even if we only use part of it */
        nvram += NVRAM_OFFS & ~(NVRAM_SECSIZE - 1);
	nvramsecbuf = (char *)malloc(NVRAM_SECSIZE);
	if(nvramsecbuf == 0) {
		printf("Warning! Unable to malloc nvrambuffer!\n");
		return(-1);
	}
        memcpy(nvramsecbuf, nvram, NVRAM_SECSIZE);
	nvrambuf = nvramsecbuf + (NVRAM_OFFS & (NVRAM_SECSIZE - 1));
#else
        nvramsecbuf = nvrambuf = nvram = (char *)malloc(NVRAM_SECSIZE);
	nvram_get(nvram);
#endif

        ep = nvrambuf + 2;

	status = 0;
        while((*ep != '\0') && (ep < nvrambuf + NVRAM_SIZE)) {
                np = name;
                sp = ep;

                while((*ep == *np) && (*ep != '=') && (*np != '\0')) {
                        ep++;
                        np++;
                }
                if((*np == '\0') && ((*ep == '\0') || (*ep == '='))) {
                        while(*ep++);
                        while(ep < nvrambuf + NVRAM_SIZE) {
                                *sp++ = *ep++;  /*   */
                        }
                        if(nvrambuf[2] == '\0') {
                                nvrambuf[3] = '\0';
                        }
                        cksum(nvrambuf, NVRAM_SIZE, 1);
#ifdef NVRAM_IN_FLASH
                        if(fl_erase_device(nvram, NVRAM_SECSIZE, FALSE)) {
                                status = -1;
				break;
                        }

                        if(fl_program_device(nvram, nvramsecbuf, NVRAM_SECSIZE, FALSE)) {
                                status = -1;
				break;
                        }
#else
			nvram_put(nvram);
#endif
			status = 1;
			break;
                }
                else if(*ep != '\0') {
                        while(*ep++ != '\0');
                }
        }

	free(nvramsecbuf);
        return(status);
}

int
tgt_setenv(char *name, char *value)
{
        char *ep;
        int envlen;
        char *nvrambuf;
        char *nvramsecbuf;
#ifdef NVRAM_IN_FLASH
        char *nvram;
#endif
	/* Non permanent vars. */
	if(strcmp(EXPERT, name) == 0) {
		return(1);
	}

        /* Calculate total env mem size requiered */
        envlen = strlen(name);
        if(envlen == 0) {
                return(0);
        }
        if(value != NULL) {
                envlen += strlen(value);
        }
        envlen += 2;    /* '=' + null byte */
        if(envlen > 255) {
                return(0);      /* Are you crazy!? */
        }

	/* Use first defined flash device (we probably have only one) */
#ifdef NVRAM_IN_FLASH
        nvram = (char *)(tgt_flashmap())->fl_map_base;

	/* Deal with an entire sector even if we only use part of it */
        nvram += NVRAM_OFFS & ~(NVRAM_SECSIZE - 1);
#endif

        /* If NVRAM is found to be uninitialized, reinit it. */
	if(nvram_invalid) {
		nvramsecbuf = (char *)malloc(NVRAM_SECSIZE);
		if(nvramsecbuf == 0) {
			printf("Warning! Unable to malloc nvrambuffer!\n");
			return(-1);
		}
#ifdef NVRAM_IN_FLASH
		memcpy(nvramsecbuf, nvram, NVRAM_SECSIZE);
#endif
		nvrambuf = nvramsecbuf + (NVRAM_OFFS & (NVRAM_SECSIZE - 1));
                memset(nvrambuf, -1, NVRAM_SIZE);
                nvrambuf[2] = '\0';
                nvrambuf[3] = '\0';
                cksum((void *)nvrambuf, NVRAM_SIZE, 1);
		printf("Warning! NVRAM checksum fail. Reset!\n");  //???
#ifdef NVRAM_IN_FLASH
                if(fl_erase_device(nvram, NVRAM_SECSIZE, FALSE)) {
			printf("Error! Nvram erase failed!\n");
			free(nvramsecbuf);
                        return(-1);
                }
                if(fl_program_device(nvram, nvramsecbuf, NVRAM_SECSIZE, FALSE)) {
			printf("Error! Nvram init failed!\n");
			free(nvramsecbuf);
                        return(-1);
                }
#else
		nvram_put(nvramsecbuf);
#endif
                nvram_invalid = 0;
		free(nvramsecbuf);
        }

        /* Remove any current setting */
        tgt_unsetenv(name);

        /* Find end of evironment strings */
	nvramsecbuf = (char *)malloc(NVRAM_SECSIZE);
	if(nvramsecbuf == 0) {
		printf("Warning! Unable to malloc nvrambuffer!\n");
		return(-1);
	}
#ifndef NVRAM_IN_FLASH
	nvram_get(nvramsecbuf);
#else
        memcpy(nvramsecbuf, nvram, NVRAM_SECSIZE);
#endif
	nvrambuf = nvramsecbuf + (NVRAM_OFFS & (NVRAM_SECSIZE - 1));
	/* Etheraddr is special case to save space */
	if (strcmp("ethaddr", name) == 0) {
		char *s = value;
		int i;
		int32_t v;
		for(i = 0; i < 6; i++) {
			gethex(&v, s, 2);
			hwethadr[i] = v;
			s += 3;         /* Don't get to fancy here :-) */
		}
	}
	else if(strcmp("pll_reg0",name) == 0)
		pll_reg0=strtoul(value,0,0);
	else if(strcmp("pll_reg1",name) == 0)
		pll_reg1=strtoul(value,0,0);
	else {
		ep = nvrambuf+2;
		if(*ep != '\0') {
			do {
				while(*ep++ != '\0');
			} while(*ep++ != '\0');
			ep--;
		}
		if(((int)ep + NVRAM_SIZE - (int)ep) < (envlen + 1)) {
			free(nvramsecbuf);
			return(0);      /* Bummer! */
		}

		/*
		 *  Special case heaptop must always be first since it
		 *  can change how memory allocation works.
		 */
		if(strcmp("heaptop", name) == 0) {

			bcopy(nvrambuf+2, nvrambuf+2 + envlen,
				 ep - nvrambuf+1);

			ep = nvrambuf+2;
			while(*name != '\0') {
				*ep++ = *name++;
			}
			if(value != NULL) {
				*ep++ = '=';
				while((*ep++ = *value++) != '\0');
			}
			else {
				*ep++ = '\0';
			}
		}
		else {  /*把命令行下 name 和 value 加入字符串，并中间加上=*/
			while(*name != '\0') {
				*ep++ = *name++;
			}
			if(value != NULL) {
				*ep++ = '=';
				while((*ep++ = *value++) != '\0');
			}
			else {
				*ep++ = '\0';
			}
			*ep++ = '\0';   /* End of env strings */
		}
	}
        cksum(nvrambuf, NVRAM_SIZE, 1);

	bcopy(hwethadr, &nvramsecbuf[ETHER_OFFS], 6);
	bcopy(&pll_reg0, &nvramsecbuf[PLL_OFFS], 4);
	bcopy(&pll_reg1, &nvramsecbuf[PLL_OFFS + 4], 4);
#ifdef NVRAM_IN_FLASH
        if(fl_erase_device(nvram, NVRAM_SECSIZE, FALSE)) {
		printf("Error! Nvram erase failed!\n");
		free(nvramsecbuf);
                return(0);
        }
        if(fl_program_device(nvram, nvramsecbuf, NVRAM_SECSIZE, FALSE)) {
		printf("Error! Nvram program failed!\n");
		free(nvramsecbuf);
                return(0);
        }
#else
	nvram_put(nvramsecbuf);
#endif
	free(nvramsecbuf);
        return(1);
}


/*
 *  Calculate checksum. If 'set' checksum is calculated and set.
 */
static int
cksum(void *p, size_t s, int set)
{
	u_int16_t sum = 0;
	u_int8_t *sp = p;
	int sz = s / 2;

	if(set) {
		*sp = 0;	/* Clear checksum */
		*(sp+1) = 0;	/* Clear checksum */
	}
	while(sz--) {
		sum += (*sp++) << 8;
		sum += *sp++;
	}
	if(set) {
		sum = -sum;
		*(u_int8_t *)p = sum >> 8;
		*((u_int8_t *)p+1) = sum;
	}
	return(sum);
}

#ifndef NVRAM_IN_FLASH

/*
 *  Read and write data into non volatile memory in clock chip.
 */

void
nvram_get(char *buffer)
{
#ifdef NAND_BOOT
	int i;
	unsigned char *ptr;

    ptr = 	nand_read_boot(NVNAND_POS<<6, buffer, 2);  //2 is EDC
	memcpy(buffer, ptr, NVRAM_SECSIZE);

#else	
	spi_read_area(NVRAM_POS,buffer,NVRAM_SECSIZE);
	spi_initr();
#endif
}

void
nvram_put(char *buffer)
{
	int i;

#ifdef NAND_BOOT
	size_t * flashsize;
	tgt_nand_flashprogram( NVNAND_POS, NVRAM_SECSIZE, (void *)buffer, 0);
#else
	spi_erase_area(NVRAM_POS,NVRAM_POS+NVRAM_SECSIZE,0x10000);
	spi_write_area(NVRAM_POS,buffer,NVRAM_SECSIZE);
	spi_initr();
#endif
}

#endif

/*
 *  Simple display function to display a 4 char string or code.
 *  Called during startup to display progress on any feasible
 *  display before any serial port have been initialized.
 */
void
tgt_display(char *msg, int x)
{
	/* Have simple serial port driver */
	tgt_putchar(msg[0]);
	tgt_putchar(msg[1]);
	tgt_putchar(msg[2]);
	tgt_putchar(msg[3]);
	tgt_putchar('\r');
	tgt_putchar('\n');
}


#include <include/stdarg.h>
int
tgt_printf (const char *fmt, ...)
{
    int  n;
    char buf[1024];
	char *p=buf;
	char c;
	va_list     ap;
	va_start(ap, fmt);
    n = vsprintf (buf, fmt, ap);
    va_end(ap);
	while((c=*p++))
	{ 
	 if(c=='\n')tgt_putchar('\r');
	 tgt_putchar(c);
	}
    return (n);
}

void
clrhndlrs(void)
{
}

int
tgt_getmachtype(void)
{
	return(md_cputype());
}

/*
 *  Create stubs if network is not compiled in
 */
#ifdef INET
void
tgt_netpoll(void)
{
	splx(splhigh());
}

#else
extern void longjmp(label_t *, int);
void gsignal(label_t *jb, int sig);
void
gsignal(label_t *jb, int sig)
{
	if(jb != NULL) {
		longjmp(jb, 1);
	}
};

int	netopen (const char *, int);
int	netread (int, void *, int);
int	netwrite (int, const void *, int);
long	netlseek (int, long, int);
int	netioctl (int, int, void *);
int	netclose (int);
int netopen(const char *p, int i)	{ return -1;}
int netread(int i, void *p, int j)	{ return -1;}
int netwrite(int i, const void *p, int j)	{ return -1;}
int netclose(int i)	{ return -1;}
long int netlseek(int i, long j, int k)	{ return -1;}
int netioctl(int j, int i, void *p)	{ return -1;}
void tgt_netpoll()	{};

#endif /*INET*/

void
tgt_reboot(void)
{
	/*	(*longreach)();
	*(volatile unsigned int *)0xbfe5c060 = 0x1;		//lxy: watchdog EN
	*(volatile unsigned int *)0xbfe5c064 = 0x1;		//lxy: watchdog timer
	*(volatile unsigned int *)0xbfe5c068 = 0x1;		//lxy: watchdog start
	*/
		printf("===-----------------------------n");
	*(volatile unsigned int *)0xa0100000 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0100004 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0100008 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa010000c = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0100010 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0100014 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0100018 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa010001c = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0100020 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0100024 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0100028 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa010002c = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0100030 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0100034 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0100038 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa010003c = 0xffffffff;	//mhb


	*(volatile unsigned int *)0xa0200000 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0200004 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0200008 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa020000c = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0200010 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0200014 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0200018 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa020001c = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0200020 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0200024 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0200028 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa020002c = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0200030 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0200034 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa0200038 = 0xffffffff;	//mhb
	*(volatile unsigned int *)0xa020003c = 0xffffffff;	//mhb

	*(volatile unsigned int *)0xbfd00414 |= 0x10000;	//mhb
	*(volatile unsigned int *)0xbfd00414 &= 0xfffeffff;	//mhb
	*(volatile unsigned int *)0xbfd00414 |= 0xb000;		//mhb
	while(1);
}

