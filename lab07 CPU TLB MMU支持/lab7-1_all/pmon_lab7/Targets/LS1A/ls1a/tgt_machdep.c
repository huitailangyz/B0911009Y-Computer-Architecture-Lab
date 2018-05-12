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
#include "nand.h"
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

extern struct trapframe DBGREG;

extern void *memset(void *, int, size_t);

extern void stringserial(char *);

#ifdef CONFIG_USB_HOTPLUG
extern int usb_hotplug_handler(void);
#endif


int kbd_available;
int usb_kbd_available;
int vga_available=0;

static int md_pipefreq = 0;
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
static void init_legacy_rtc(void);

#ifdef CONFIG_EJTAG_SERIAL
/*used for debug,only work on ejtag mode*/
int ejtag_serial (int op, struct DevEntry *dev, unsigned long param, int data)
{
	switch (op) {
		case OP_INIT:
		case OP_XBAUD:
		case OP_BAUD:
		case OP_RXSTOP:
			break;
		case OP_TXRDY:
			return 1;
		case OP_TX:
			*(volatile char *)CONFIG_EJTAG_SERIAL=data;
			break;
		case OP_RXRDY:
			return *(volatile char *)(CONFIG_EJTAG_SERIAL+1);
		case OP_RX:
			return *(volatile char *)CONFIG_EJTAG_SERIAL;
	}
	return 0;
}
#endif

ConfigEntry	ConfigTable[] =
{
#ifdef CONFIG_EJTAG_SERIAL
	 { (char *)COM1_BASE_ADDR, 0, ejtag_serial, 256, CONS_BAUD, NS16550HZ},
#else
	 { (char *)COM1_BASE_ADDR, 0, ns16550, 256, CONS_BAUD, NS16550HZ},
#endif
#if NMOD_VGACON >0 && NMOD_FRAMEBUFFER >0
	{ (char *)1, 0, fbterm, 256, CONS_BAUD, NS16550HZ },
#endif
	{ 0 }
};

unsigned long _filebase;

extern int memorysize;
extern int memorysize_high;

extern char MipsException[], MipsExceptionEnd[];

unsigned char hwethadr[6];
static unsigned int pll_reg0,pll_reg1;
static unsigned int xres,yres,depth;

void initmips(unsigned int memsz);

void addr_tst1(void);
void addr_tst2(void);
void movinv1(int iter, ulong p1, ulong p2);


//#define	HPET
void hpet_test()
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

void pci_conf_dump()
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
int ls1f_gmac_init()
{
	return	SynopGMAC_Host_Interface_init();	
}

#endif

void
initmips(unsigned int memsz)
{
//	memsz=64;
	
	
	/*
	 *	Set up memory address decoders to map entire memory.
	 *	But first move away bootrom map to high memory.
	 */
	memorysize = memsz > 256 ? 256 << 20 : memsz << 20;
	memorysize_high = memsz > 256 ? (memsz - 256) << 20 : 0;

    /*enable float*/
//    tgt_fpuenable();  //zgj-2010-3-17

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
#if NNAND
#ifdef LS1FSOC
	/*mutex nand use lpc pin*/
    *((volatile unsigned int *)0xbfd00420) = (*((volatile unsigned int *)0xbfd00420) & 0x01ffffff) |0x0a000000;
#endif
	ls1g_soc_nand_init();
#endif

#ifdef  MEMSCAN	
	memscan();
#endif	

#ifdef	HPET
	hpet_test();
#endif

#ifdef CONFIG_USB_HOTPLUG
	tgt_poll_register(1, usb_hotplug_handler, 0);
#endif
	
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
int init_kbd()
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

#ifdef USE_PCI
int have_pci=1;
#else
int have_pci=0;
#endif

extern int fb_init(unsigned long,unsigned long);
extern int dc_init();

#ifdef GC300
extern unsigned long GPU_fbaddr;
#endif

#if 1

#ifndef CONFIG_PM
#define CONFIG_PM
#endif 

#ifdef CONFIG_PM
extern  enum{
OF_BUF_CONFIG=0,
OF_BUF_ADDR=0x20,
OF_BUF_STRIDE=0x40,
OF_BUF_ORIG=0x60,
OF_DITHER_CONFIG=0x120,
OF_DITHER_TABLE_LOW=0x140,
OF_DITHER_TABLE_HIGH=0x160,
OF_PAN_CONFIG=0x180,
OF_PAN_TIMING=0x1a0,
OF_HDISPLAY=0x1c0,
OF_HSYNC=0x1e0,
OF_VDISPLAY=0x240,
OF_VSYNC=0x260,
OF_DBLBUF=0x340,
};

#define SB2F_LCD_BASE_VA   0xbc301240

#define	SB2F_LCD_BASE1_VA (SB2F_LCD_BASE_VA + 0x10)

unsigned int dc_initreg[10];
unsigned int dc_initreg1[10];
int sb2f_drv_suspend()
{
#if 1
  	dc_initreg[0] = *(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_HDISPLAY);
  	dc_initreg[1] = *(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_HSYNC);
  	dc_initreg[2] = *(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_VDISPLAY );
  	dc_initreg[3] = *(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_VSYNC);
  	dc_initreg[4] = *(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_BUF_STRIDE);
  	dc_initreg[5] = *(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_BUF_ADDR);
  	dc_initreg[6] = *(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_DBLBUF);

#endif
	int i = 0;
	for (; i < 7; i++)
		printf("dc0_reg[%d] : 0x%x\n", i, dc_initreg[i]);
#if 1
  	dc_initreg1[0] = *(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_HDISPLAY);
  	dc_initreg1[1] = *(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_HSYNC);
  	dc_initreg1[2] = *(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_VDISPLAY );
  	dc_initreg1[3] = *(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_VSYNC);
  	dc_initreg1[4] = *(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_BUF_STRIDE);
  	dc_initreg1[5] = *(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_BUF_ADDR);
  	dc_initreg1[6] = *(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_DBLBUF);
	for (i = 0; i < 7; i++)
		printf("dc1_reg[%d] : 0x%x\n", i, dc_initreg1[i]);
#endif 

	dc_initreg1[7] = *(volatile unsigned int *)0xbfd00414;
   	/*output pix1 clock  pll ctrl*/
   	dc_initreg1[8] = *(volatile unsigned int *)0xbfd00410;
   	/*output pix2 clock pll ctrl */
   	dc_initreg1[9] = *(volatile unsigned int *)0xbfd00424;
//  	*(volatile unsigned char *)(0xbfe4c000) = 'B';

	return 0;
}


int sb2f_drv_resume()
{

	
  	//*(volatile unsigned char *)(0xbfe4c000) = 'K';

	*(volatile unsigned int *)0xbfd00414 = dc_initreg1[7] + 1;
   	/*output pix1 clock  pll ctrl*/
   	*(volatile unsigned int *)0xbfd00410 = dc_initreg1[8];
   	/*output pix2 clock pll ctrl */
   	//*(volatile unsigned int *)0xbfd00424 = 0xc5ea641e;
   	*(volatile unsigned int *)0xbfd00424 = dc_initreg1[9];

#if 1
   	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_BUF_CONFIG) = 0x00000000;
	// framebuffer configuration RGB565
	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_BUF_CONFIG) = 0x00000003;
	//*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_BUF_ADDR) = 0xe400000;
	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_BUF_ADDR) = dc_initreg[5];
	//*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_BUF_ADDR) = 0xd800000;
	//*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_DBLBUF) = 0xc800000;
	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_DBLBUF) = dc_initreg[6];
	//*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_DBLBUF) = 0xd800000;
	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_DITHER_CONFIG) = 0x00000000;
  	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_DITHER_TABLE_LOW) = 0x00000000;
  	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_DITHER_TABLE_HIGH) = 0x00000000;
  	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_PAN_CONFIG) = 0x80001311;
  	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_PAN_TIMING) = 0x00000000;
  	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_HDISPLAY)= dc_initreg[0] ;
  	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_HSYNC)= dc_initreg[1];
  	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_VDISPLAY ) =dc_initreg[2];
  	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_VSYNC)= dc_initreg[3];
  	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_BUF_CONFIG) = 0x00100103;
  	*(volatile unsigned int *)(SB2F_LCD_BASE_VA + OF_BUF_STRIDE)=dc_initreg[4];
#endif 
#if 1	
   	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_BUF_CONFIG) = 0x00000000;
	// framebuffer configuration RGB565
	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_BUF_CONFIG) = 0x00000003;
	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_BUF_ADDR) = dc_initreg1[5];
	//*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_DBLBUF) = 0xce00000;
	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_DBLBUF) = dc_initreg1[6];
	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_DITHER_CONFIG) = 0x00000000;
  	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_DITHER_TABLE_LOW) = 0x00000000;
  	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_DITHER_TABLE_HIGH) = 0x00000000;
  	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_PAN_CONFIG) = 0x80001311;
  	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_PAN_TIMING) = 0x00000000;
  	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_HDISPLAY)= dc_initreg1[0] ;
  	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_HSYNC)= dc_initreg1[1];
  	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_VDISPLAY ) =dc_initreg1[2];
  	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_VSYNC)= dc_initreg1[3];
  	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_BUF_CONFIG) = 0x00100103;
  	*(volatile unsigned int *)(SB2F_LCD_BASE1_VA + OF_BUF_STRIDE)=dc_initreg1[4];
#endif 

	//printk("====================sb2f==\n");
	return 0;
}

#else
#define sb2f_drv_suspend NULL
#define sb2f_drv_resume NULL
#endif

#endif 

void
tgt_devconfig()
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
    if (rc > 0)
	if(!getenv("novga")) 
        vga_available=1;
	else 
        vga_available=0;
#endif

    config_init();

    /*end usb reset*/
#if LS1FSOC
	/*ls1f usb reset stop*/
	*(volatile int *)0xbff10204 = 0x40000000;
#endif

    printf("====before configure\n");
    configure();
   
    printf("====before init ps/2 kbd\n");
#if (NMOD_VGACON >0) && defined(LS1FSOC)
        if(getenv("nokbd")) 
	rc=1;
	else{
	init_kbd();
#if 0
	rc=kbd_initialize();
	*(volatile char *)0xbfe60000 = 0xff;
#else
	*(volatile char *)0xbfe60004 = 0x60;
	*(volatile char *)0xbfe60000 = 0x44;
	//*(volatile char *)0xbfe60000 = 0xff;
	rc = 0;
#endif

	}
	if(!rc){ 
		kbd_available=1;
	}
	//psaux_init();
   
#endif
   printf("devconfig done.\n");
}

extern int test_icache_1(short *addr);
extern int test_icache_2(int addr);
extern int test_icache_3(int addr);
extern void godson1_cache_flush(void);
#define tgt_putchar_uc(x) (*(void (*)(char)) (((long)tgt_putchar)|0x20000000)) (x)

#define I2C_WRITE
int i2c_init();
void init_lcd();
void
tgt_devinit()
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

//sw: set clock delay
	(*(volatile u32*)(0xbfd00410) = (0x24a8));
//sw: enable gpio	
	(*(volatile u32*)(0xbfd010c8) = (0xf00004));
	(*(volatile u32*)(0xbfd010d8) = (0xf00000));
//	(*(volatile u32*)(0xbc180000+0x20) = 0x0;
//	(*(volatile u32*)(0xbc180000+0x24) = 0x80000000;
	printf("==pci_businit: clock delay %x\n",readl(0xbfd00410));
	printf("==gpio: gpio status %x\n",readl(0xbfd010e8));
	
	if(have_pci)_pci_businit(1);	/* PCI bus initialization */

	
#ifdef GS_SOC_I2C	
	i2c_init();
	i2c_test();
	
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
tgt_cmd_vers()
{
}

/*
 *  Display any target specific logo.
 */
void
tgt_logo()
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

static void init_legacy_rtc(void)
{
        int year, month, date, hour, min, sec;
	unsigned int v;

	outl(REG_CNTRCTL,0x2d00);
	v=inl(REG_TOY_READ0);
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
		v=((4+1)<<26)|(20<<21)|(10<<16)|(1<<10)|(0);
		outl(REG_TOY_WRITE0,v);
        }
                                                                               
}

                                                                               
void
_probe_frequencies()
{
#ifdef HAVE_TOD
        int i, timeout, cur, sec, cnt;
	unsigned int v;
#endif
                                                                               
        SBD_DISPLAY ("FREQ", CHKPNT_FREQ);
                                                                               
                                                                               
/*clock manager register*/
#define PLL_FREQ_REG(x) *(volatile unsigned int *)(0xbfc00000+(NVRAM_POS+PLL_OFFS+x*4))
	{
		int val= PLL_FREQ_REG(0);
		if((val&0xffff0000) == 0x12340000)
		{
			md_pipefreq = ((val&7)+4)*APB_CLK;        /* NB FPGA*/
			md_cpufreq  =  (((val>>8)&7)+3)*APB_CLK;
		}
		else
		{
			md_pipefreq = CPU_MULT*APB_CLK;        /* NB FPGA*/
			md_cpufreq  = DDR_MULT*APB_CLK;
		}
	}

        clk_invalid = 1;
#ifdef HAVE_TOD
        init_legacy_rtc();

        SBD_DISPLAY ("FREI", CHKPNT_FREQ);

        /*
         * Do the next twice for two reasons. First make sure we run from
         * cache. Second make sure synched on second update. (Pun intended!)
         */
        for(i = 2;  i != 0; i--) {
                cnt = CPU_GetCOUNT();
                timeout = 10000000;
		v=inl(REG_TOY_READ0);
                sec = (v>>4)&0x3f;
                                                                               
                                                                               
                do {
                        timeout--;
			v=inl(REG_TOY_READ0);
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
tgt_pipefreq()
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
tgt_cpufreq()
{
	if(md_cpufreq == 0) {
		_probe_frequencies();
	}
	return(md_cpufreq);
}

time_t
tgt_gettime()
{
        struct tm tm;
        time_t t;

#ifdef HAVE_TOD
	unsigned int year,v;

        if(!clk_invalid) {
		v=inl(REG_TOY_READ0);
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
		v=((tm->tm_mon+1)<<26)|(tm->tm_mday<<21)|(tm->tm_hour<<16)|(tm->tm_min<<10)|(tm->tm_sec << 4);
		outl(REG_TOY_WRITE0,v);
                                                                               
        }
#endif
}


/*
 *  Print out any target specific memory information
 */
void
tgt_memprint()
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
tgt_machprint()
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
tgt_clienttos()
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
tgt_flashmap()
{
	return tgt_fl_map_boot16;
}   
void
tgt_flashwrite_disable()
{
}

int
tgt_flashwrite_enable()
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

/*
 *  Network stuff.
 */
void
tgt_netinit()
{
}

int
tgt_ethaddr(char *p)
{
	bcopy((void *)&hwethadr, p, 6);
	return(0);
}

void
tgt_netreset()
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
	char env[512];
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
#else
    nvram = (char *)malloc(NVRAM_SECSIZE);
	nvram_get(nvram);
	if(cksum(nvram, NVRAM_SIZE, 0) != 0) {
#endif
		        printf("NVRAM is invalid!\n");
                nvram_invalid = 1;
        }
        else {
				nvram += NVRAM_OFFS;
                ep = nvram+2;;

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
                                (*func)(env, val);
                        }
                        else {
                                nvram_invalid = 2;
                                break;
                        }
                }
        }

	printf("NVRAM@%x\n",(u_int32_t)nvram);

	/*
	 *  Ethernet address for Galileo ethernet is stored in the last
	 *  six bytes of nvram storage. Set environment to it.
	 */
	bcopy(&nvram[ETHER_OFFS], hwethadr, 6);
	sprintf(env, "%02x:%02x:%02x:%02x:%02x:%02x", hwethadr[0], hwethadr[1],
	    hwethadr[2], hwethadr[3], hwethadr[4], hwethadr[5]);
	(*func)("ethaddr", env);

	bcopy(&nvram[PLL_OFFS], &pll_reg0, 4);
	sprintf(env, "0x%08x",pll_reg0);
	(*func)("pll_reg0", env);

	bcopy(&nvram[XRES_OFFS], &xres, 2);
	bcopy(&nvram[YRES_OFFS], &yres, 2);
	bcopy(&nvram[DEPTH_OFFS], &depth, 1);

	if(xres>0 && xres<2000)
	{
	sprintf(env, "%d",xres);
	(*func)("xres", env);
	}

	if(yres>0 && yres<2000)
	{
	sprintf(env, "%d",yres);
	(*func)("yres", env);
	}

	if(depth == 16 || depth == 32)
	{
	sprintf(env, "%d",depth);
	(*func)("depth", env);
	}

#ifndef NVRAM_IN_FLASH
	free(nvram);
#endif

#ifdef no_thank_you
    (*func)("vxWorks", env);
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
                                *sp++ = *ep++;
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
		printf("Warning! NVRAM checksum fail. Reset!\n");
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
	else if(strcmp("xres",name) == 0)
		xres=strtoul(value,0,0);
	else if(strcmp("yres",name) == 0)
		yres=strtoul(value,0,0);
	else if(strcmp("depth",name) == 0)
		depth=strtoul(value,0,0);
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
		else {
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
	bcopy(&xres, &nvramsecbuf[XRES_OFFS], 2);
	bcopy(&yres, &nvramsecbuf[YRES_OFFS], 2);
	bcopy(&depth, &nvramsecbuf[DEPTH_OFFS], 1);
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
	spi_read_area(NVRAM_POS,buffer,NVRAM_SECSIZE);
	spi_initr();
}

void
nvram_put(char *buffer)
{
	int i;
	spi_erase_area(NVRAM_POS,NVRAM_POS+NVRAM_SECSIZE,0x10000);
	spi_write_area(NVRAM_POS,buffer,NVRAM_SECSIZE);
	spi_initr();
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
clrhndlrs()
{
}

int
tgt_getmachtype()
{
	return(md_cputype());
}

/*
 *  Create stubs if network is not compiled in
 */
#ifdef INET
void
tgt_netpoll()
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
tgt_reboot()
{

	void (*longreach) (void);

    #if defined(GC300)
        *(volatile unsigned int *)0xbc301520 = 0x0 ;
        *(volatile unsigned int *)0xbc301250 = 0x01100004 ;
        *(volatile unsigned int *)0xbc301240 = 0x01100004 ;
    #endif

	/*enable watch dog*/
outl(0xbfe7c060,1);
outl(0xbfe7c064,1);
outl(0xbfe7c068,1);

	while(1);

}
void
tgt_poweroff()/* zmz add */
{
	unsigned int* pm1_cnt = (volatile unsigned int *) 0xbfe7c008;
        *pm1_cnt = (*pm1_cnt) | 0x3d00;
}                                                                                                                                  

