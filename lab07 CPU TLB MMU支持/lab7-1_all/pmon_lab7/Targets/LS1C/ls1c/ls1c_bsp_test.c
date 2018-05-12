#include <stdio.h>
#include <termio.h>
#include <string.h>
#include <setjmp.h>
#include <sys/endian.h>
#include <ctype.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#ifdef _KERNEL
#undef _KERNEL
#include <sys/ioctl.h>
#define _KERNEL
#else
#include <sys/ioctl.h>
#endif

#include <machine/cpu.h>

#include <pmon.h>
#include <dev/pci/pcivar.h>
#include <dev/pci/pcidevs.h>
#include <flash.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/net/if.h>
#include "mod_vgacon.h"
#include "mod_display.h"

#include <pflash.h>

#define CONFIG_PAGE_SIZE_64KB
#include <asm/mipsregs.h>
#include "gzip.h"
#if NGZIP > 0
#include <gzipfs.h>
#endif /* NGZIP */


#if 1
typedef char _s8;
typedef unsigned char _u8;

typedef short _s16;
typedef unsigned short _u16;

typedef int _s32;
typedef unsigned int _u32;

typedef float _fp32;
#endif

#define    regrl(addr) ((*(volatile unsigned int *)(addr)))
#define    regwl(addr,val) ((*(volatile unsigned int *)(addr))=(val))

#define WTREG4(addr, val)	(*(volatile _u32 *)(addr) = (val))
#define WTREG1(addr, val)	(*(volatile _u8 *)(addr) = (val))
#define RDREG4(addr, val)	((val) = *(volatile _u32 *)(addr))
#define RDREG1(addr, val)	((val) = *(volatile _u8 *)(addr))

/***************************************************************/
void delay_100ms(int i)
{
	int j;
	for ( ; i>0; i--)
		for( j=0; j<8000000; j++);
}
/***************************************************************/

static void uart_put_char(unsigned int uart_base, char c)
{
	unsigned char val;
	val = *(volatile unsigned char *)(uart_base + 0x5);
	while( !(val & 0x20)){
		val = *(volatile unsigned char *)(uart_base + 0x5);
	}
	*(volatile unsigned char *)(uart_base + 0x0) = c;
}


/***************************************************************************
 * Description:
 * Parameters: 
 * Author    :Sunyoung_yg 
 * Date      : 2014-06-03
 ***************************************************************************/
 void hcntr_test(void)
{
	
}






#define EJTAG_TO_GPIO 0
/***************************************************************/
static int uart_test(unsigned int channel)
{

	unsigned int val, i, uart_base,
				 mux_base1=0xbfd011c0, 
				 mux_base2=0xbfd011d0,
				 mux_base3=0xbfd011e0,
				 mux_base4=0xbfd011f0,
				 mux_base5=0xbfd01200;
		//gpio mux init
		switch(channel)
		{
			case 1:  
#if EJTAG_TO_GPIO
				//uart 1   (gpio 02/03 mux4)
				val = *(volatile unsigned int *)(mux_base1);
				val &= ~(0x3<<(2));
				*(volatile unsigned int *)(mux_base1) = val;
				
				val = *(volatile unsigned int *)(mux_base2);
				val &= ~(0x3<<(2));
				*(volatile unsigned int *)(mux_base2) = val;

				val = *(volatile unsigned int *)(mux_base3);
				val &= ~(0x3<<(2));
				*(volatile unsigned int *)(mux_base3) = val;

				val = *(volatile unsigned int *)(mux_base4);
				val |= (0x3<<(2));
				*(volatile unsigned int *)(mux_base4) = val;
				
				val = *(volatile unsigned int *)(mux_base5);
				val &= ~(0x3<<(2));
				*(volatile unsigned int *)(mux_base5) = val;

#else
				//uart 1   (gpio76/77 mux2)
				val = *(volatile unsigned int *)(mux_base1+0x8);
				val &= ~(0x3<<(76-64));
				*(volatile unsigned int *)(mux_base1+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x8);
				val |= (0x3<<(76-64));
				*(volatile unsigned int *)(mux_base2+0x8) = val;

				val = *(volatile unsigned int *)(mux_base3+0x8);
				val &= ~(0x3<<(76-64));
				*(volatile unsigned int *)(mux_base3+0x8) = val;

				val = *(volatile unsigned int *)(mux_base4+0x8);
				val &= ~(0x3<<(76-64));
				*(volatile unsigned int *)(mux_base4+0x8) = val;

				val = *(volatile unsigned int *)(mux_base5+0x8);
				val &= ~(0x3<<(76-64));
				*(volatile unsigned int *)(mux_base5+0x8) = val;
#endif
				break;

			case 2:	

#if  EJTAG_TO_GPIO
				//uart2  (gpio 04,05 mux4)
				val = *(volatile unsigned int *)(mux_base1);
				val &= ~(0x3<<(4));
				*(volatile unsigned int *)(mux_base1) = val;
				
				val = *(volatile unsigned int *)(mux_base2);
				val &= ~(0x3<<(4));
				*(volatile unsigned int *)(mux_base2) = val;

				val = *(volatile unsigned int *)(mux_base3);
				val &= ~(0x3<<(4));
				*(volatile unsigned int *)(mux_base3) = val;

				val = *(volatile unsigned int *)(mux_base4);
				val |= (0x3<<(4));
				*(volatile unsigned int *)(mux_base4) = val;

				val = *(volatile unsigned int *)(mux_base5);
				val &= ~(0x3<<(4));
				*(volatile unsigned int *)(mux_base5) = val;
//				printf(" mux_4: 0x%08x ...\r\n",  *(volatile unsigned int *)(mux_base4);
#else
				//uart2  (gpio 36/37 mux1)
				val = *(volatile unsigned int *)(mux_base1+0x4);
				val &= ~(0x3<<(36-32));
				*(volatile unsigned int *)(mux_base1+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x4);
				val |= (0x3<<(36-32));
				*(volatile unsigned int *)(mux_base2+0x4) = val;

				val = *(volatile unsigned int *)(mux_base3+0x4);
				val &= ~(0x3<<(36-32));
				*(volatile unsigned int *)(mux_base3+0x4) = val;

				val = *(volatile unsigned int *)(mux_base4+0x4);
				val &= ~(0x3<<(36-32));
				*(volatile unsigned int *)(mux_base4+0x4) = val;

				val = *(volatile unsigned int *)(mux_base5+0x4);
				val &= ~(0x3<<(36-32));
				*(volatile unsigned int *)(mux_base5+0x4) = val;
#endif

				break;
			case 3:
				printf(" ----------------->uart 1233\r\n");
#if 1 //EJTAG_TO_GPIO
				printf(" ejtag to gpio\r\n");
				//uart3  gpio 00,01 mux4
				val = *(volatile unsigned int *)(mux_base1);
				val &= ~(0x3);
				*(volatile unsigned int *)(mux_base1) = val;
				
				val = *(volatile unsigned int *)(mux_base2);
				val &= ~(0x3);
				*(volatile unsigned int *)(mux_base2) = val;

				val = *(volatile unsigned int *)(mux_base3);
				val &= ~(0x3);
				*(volatile unsigned int *)(mux_base3) = val;

				val = *(volatile unsigned int *)(mux_base4);
				val |= (0x3);
				*(volatile unsigned int *)(mux_base4) = val;

				val = *(volatile unsigned int *)(mux_base5);
				val &= ~(0x3);
				*(volatile unsigned int *)(mux_base5) = val;
#else 
				//uart3  gpio 33,34 ? mux2
				val = *(volatile unsigned int *)(mux_base1+0x4);
				val &= ~(0x6);
				*(volatile unsigned int *)(mux_base1+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x4);
				val |= (0x6);
				*(volatile unsigned int *)(mux_base2+0x4) = val;

				val = *(volatile unsigned int *)(mux_base3+0x4);
				val &= ~(0x6);
				*(volatile unsigned int *)(mux_base3+0x4) = val;

				val = *(volatile unsigned int *)(mux_base4+0x4);
				val &= ~(0x6);
				*(volatile unsigned int *)(mux_base4+0x4) = val;

				val = *(volatile unsigned int *)(mux_base5+0x4);
				val &= ~(0x6);
				*(volatile unsigned int *)(mux_base5+0x4) = val;
#endif
				break;
#if 0
			case 4：
			case 5：
			case 6:
				//uart4,5,6 作为普通串口  uart4: gpio 58,59   uart5: gpio 60,61   uart6: gpio 62 63
				
				val = *(volatile unsigned int *)(0xbfd00420);
				val &= ~(0x1<<18);
				*(volatile unsigned int *)(0xbfd00420) = val;

				val = *(volatile unsigned int *)(mux_base1+0x4);
				val &= ~(0x3<<(58+(channel-4)*2-32));
				*(volatile unsigned int *)(mux_base1+0x4) = val;
				break;
#else
			case 4:


				//uart4 普通串口  
				val = *(volatile unsigned int *)(0xbfd00420);
				val &= ~(0x1<<18);
				*(volatile unsigned int *)(0xbfd00420) = val;

				//config  gpio58,59 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x4);
				val &= ~(0x3<<(58-32));
				*(volatile unsigned int *)(mux_base1+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x4);
				val &= ~(0x3<<(58-32));
				*(volatile unsigned int *)(mux_base2+0x4) = val;

				val = *(volatile unsigned int *)(mux_base3+0x4);
				val &= ~(0x3<<(58-32));
				*(volatile unsigned int *)(mux_base3+0x4) = val;

				val = *(volatile unsigned int *)(mux_base4+0x4);
				val &= ~(0x3<<(58-32));
				*(volatile unsigned int *)(mux_base4+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x4);
				val |= (0x3<<(58-32));
				*(volatile unsigned int *)(mux_base5+0x4) = val;
				
				break;
			case 5:
				//uart5 普通串口  
				val = *(volatile unsigned int *)(0xbfd00420);
				val &= ~(0x1<<18);
				*(volatile unsigned int *)(0xbfd00420) = val;
				//config  gpio 60,61 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x4);
				val &= ~(0x3<<(60-32));
				*(volatile unsigned int *)(mux_base1+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x4);
				val &= ~(0x3<<(60-32));
				*(volatile unsigned int *)(mux_base2+0x4) = val;

				val = *(volatile unsigned int *)(mux_base3+0x4);
				val &= ~(0x3<<(60-32));
				*(volatile unsigned int *)(mux_base3+0x4) = val;

				val = *(volatile unsigned int *)(mux_base4+0x4);
				val &= ~(0x3<<(60-32));
				*(volatile unsigned int *)(mux_base4+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x4);
				val |= (0x3<<(60-32));
				*(volatile unsigned int *)(mux_base5+0x4) = val;
				
				break;
			case 6:

				//uart6 普通串口  
				val = *(volatile unsigned int *)(0xbfd00420);
				val &= ~(0x1<<18);
				*(volatile unsigned int *)(0xbfd00420) = val;
#if 0
				//config  gpio 62,63 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x4);
				val &= ~(0x3<<(62-32));
				*(volatile unsigned int *)(mux_base1+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x4);
				val &= ~(0x3<<(62-32));
				*(volatile unsigned int *)(mux_base2+0x4) = val;

				val = *(volatile unsigned int *)(mux_base3+0x4);
				val &= ~(0x3<<(62-32));
				*(volatile unsigned int *)(mux_base3+0x4) = val;

				val = *(volatile unsigned int *)(mux_base4+0x4);
				val &= ~(0x3<<(62-32));
				*(volatile unsigned int *)(mux_base4+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x4);
				val |= (0x3<<(62-32));
				*(volatile unsigned int *)(mux_base5+0x4) = val;
#else
				//config  gpio 46,47 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x4);
				val &= ~(0x3<<(46-32));
				*(volatile unsigned int *)(mux_base1+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x4);
				val &= ~(0x3<<(46-32));
				*(volatile unsigned int *)(mux_base2+0x4) = val;

				val = *(volatile unsigned int *)(mux_base3+0x4);
				val &= ~(0x3<<(46-32));
				*(volatile unsigned int *)(mux_base3+0x4) = val;

				val = *(volatile unsigned int *)(mux_base4+0x4);
				val &= ~(0x3<<(46-32));
				*(volatile unsigned int *)(mux_base4+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x4);
				val |= (0x3<<(46-32));
				*(volatile unsigned int *)(mux_base5+0x4) = val;
				
#endif
				break;
#endif
			case 7:
		    	/*	
				//uart7 普通串口  
				val = *(volatile unsigned int *)(0xbfd00420);
				val &= ~(0x1<<18);
				*(volatile unsigned int *)(0xbfd00420) = val;
			    */
#if 0				
				//config  gpio 64,65 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x8);
				val &= ~(0x3<<(64-64));
				*(volatile unsigned int *)(mux_base1+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x8);
				val &= ~(0x3<<(64-64));
				*(volatile unsigned int *)(mux_base2+0x8) = val;

				val = *(volatile unsigned int *)(mux_base3+0x8);
				val &= ~(0x3<<(64-64));
				*(volatile unsigned int *)(mux_base3+0x8) = val;

				val = *(volatile unsigned int *)(mux_base4+0x8);
				val &= ~(0x3<<(64-64));
				*(volatile unsigned int *)(mux_base4+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x8);
				val |= (0x3<<(64-64));
				*(volatile unsigned int *)(mux_base5+0x8) = val;			
#elif 0
				//config  gpio 87,88 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x8);
				val &= ~(0x3<<(87-64));
				*(volatile unsigned int *)(mux_base1+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x8);
				val &= ~(0x3<<(87-64));
				*(volatile unsigned int *)(mux_base2+0x8) = val;

				val = *(volatile unsigned int *)(mux_base3+0x8);
				val &= ~(0x3<<(87-64));
				*(volatile unsigned int *)(mux_base3+0x8) = val;

				val = *(volatile unsigned int *)(mux_base4+0x8);
				val &= ~(0x3<<(87-64));
				*(volatile unsigned int *)(mux_base4+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x8);
				val |= (0x3<<(87-64));
				*(volatile unsigned int *)(mux_base5+0x8) = val;			
#else
				//config  gpio 56,57 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x4);
				val &= ~(0x3<<(56-32));
				*(volatile unsigned int *)(mux_base1+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x4);
				val &= ~(0x3<<(56-32));
				*(volatile unsigned int *)(mux_base2+0x4) = val;

				val = *(volatile unsigned int *)(mux_base3+0x4);
				val &= ~(0x3<<(56-32));
				*(volatile unsigned int *)(mux_base3+0x4) = val;

				val = *(volatile unsigned int *)(mux_base4+0x4);
				val &= ~(0x3<<(56-32));
				*(volatile unsigned int *)(mux_base4+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x4);
				val |= (0x3<<(56-32));
				*(volatile unsigned int *)(mux_base5+0x4) = val;			
#endif
				break;
			case 8:
		    		
				//uart8 普通串口  
				val = *(volatile unsigned int *)(0xbfe4c904);
				val &= ~(0x1);
				*(volatile unsigned int *)(0xbfe4c904) = val;
			    
#if 0			
				//config  gpio 66,67 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x8);
				val &= ~(0x3<<(66-64));
				*(volatile unsigned int *)(mux_base1+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x8);
				val &= ~(0x3<<(66-64));
				*(volatile unsigned int *)(mux_base2+0x8) = val;

				val = *(volatile unsigned int *)(mux_base3+0x8);
				val &= ~(0x3<<(66-64));
				*(volatile unsigned int *)(mux_base3+0x8) = val;

				val = *(volatile unsigned int *)(mux_base4+0x8);
				val &= ~(0x3<<(66-64));
				*(volatile unsigned int *)(mux_base4+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x8);
				val |= (0x3<<(66-64));
				*(volatile unsigned int *)(mux_base5+0x8) = val;
#elif 0
				//config  gpio 89,90 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x8);
				val &= ~(0x3<<(89-64));
				*(volatile unsigned int *)(mux_base1+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x8);
				val &= ~(0x3<<(89-64));
				*(volatile unsigned int *)(mux_base2+0x8) = val;

				val = *(volatile unsigned int *)(mux_base3+0x8);
				val &= ~(0x3<<(89-64));
				*(volatile unsigned int *)(mux_base3+0x8) = val;

				val = *(volatile unsigned int *)(mux_base4+0x8);
				val &= ~(0x3<<(89-64));
				*(volatile unsigned int *)(mux_base4+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x8);
				val |= (0x3<<(89-64));
				*(volatile unsigned int *)(mux_base5+0x8) = val;
#else
				//config  gpio 54,55 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x4);
				val &= ~(0x3<<(54-32));
				*(volatile unsigned int *)(mux_base1+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x4);
				val &= ~(0x3<<(54-32));
				*(volatile unsigned int *)(mux_base2+0x4) = val;

				val = *(volatile unsigned int *)(mux_base3+0x4);
				val &= ~(0x3<<(54-32));
				*(volatile unsigned int *)(mux_base3+0x4) = val;

				val = *(volatile unsigned int *)(mux_base4+0x4);
				val &= ~(0x3<<(54-32));
				*(volatile unsigned int *)(mux_base4+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x4);
				val |= (0x3<<(54-32));
				*(volatile unsigned int *)(mux_base5+0x4) = val;			
				
#endif
				break;
			case 9:
		    		
				//uart9 普通串口  
				val = *(volatile unsigned int *)(0xbfe4c904);
				val &= ~(0x1);
				*(volatile unsigned int *)(0xbfe4c904) = val;
			
#if 0
				//config  gpio 68,69 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x8);
				val &= ~(0x3<<(68-64));
				*(volatile unsigned int *)(mux_base1+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x8);
				val &= ~(0x3<<(68-64));
				*(volatile unsigned int *)(mux_base2+0x8) = val;

				val = *(volatile unsigned int *)(mux_base3+0x8);
				val &= ~(0x3<<(68-64));
				*(volatile unsigned int *)(mux_base3+0x8) = val;

				val = *(volatile unsigned int *)(mux_base4+0x8);
				val &= ~(0x3<<(68-64));
				*(volatile unsigned int *)(mux_base4+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x8);
				val |= (0x3<<(68-64));
				*(volatile unsigned int *)(mux_base5+0x8) = val;
#elif 0
				//config  gpio 85,86 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x8);
				val &= ~(0x3<<(85-64));
				*(volatile unsigned int *)(mux_base1+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x8);
				val &= ~(0x3<<(85-64));
				*(volatile unsigned int *)(mux_base2+0x8) = val;

				val = *(volatile unsigned int *)(mux_base3+0x8);
				val &= ~(0x3<<(85-64));
				*(volatile unsigned int *)(mux_base3+0x8) = val;

				val = *(volatile unsigned int *)(mux_base4+0x8);
				val &= ~(0x3<<(85-64));
				*(volatile unsigned int *)(mux_base4+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x8);
				val |= (0x3<<(85-64));
				*(volatile unsigned int *)(mux_base5+0x8) = val;
#else
	     		//config  gpio 52,53 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x4);
				val &= ~(0x3<<(52-32));
				*(volatile unsigned int *)(mux_base1+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x4);
				val &= ~(0x3<<(52-32));
				*(volatile unsigned int *)(mux_base2+0x4) = val;

				val = *(volatile unsigned int *)(mux_base3+0x4);
				val &= ~(0x3<<(52-32));
				*(volatile unsigned int *)(mux_base3+0x4) = val;

				val = *(volatile unsigned int *)(mux_base4+0x4);
				val &= ~(0x3<<(52-32));
				*(volatile unsigned int *)(mux_base4+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x4);
				val |= (0x3<<(52-32));
				*(volatile unsigned int *)(mux_base5+0x4) = val;			
				
#endif
				break;
			case 10:	

				//uart10 普通串口  
				val = *(volatile unsigned int *)(0xbfe4c904);
				val &= ~(0x1);
				*(volatile unsigned int *)(0xbfe4c904) = val;
#if 0			    
				//config  gpio 70,71 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x8);
				val &= ~(0x3<<(70-64));
				*(volatile unsigned int *)(mux_base1+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x8);
				val &= ~(0x3<<(70-64));
				*(volatile unsigned int *)(mux_base2+0x8) = val;

				val = *(volatile unsigned int *)(mux_base3+0x8);
				val &= ~(0x3<<(70-64));
				*(volatile unsigned int *)(mux_base3+0x8) = val;

				val = *(volatile unsigned int *)(mux_base4+0x8);
				val &= ~(0x3<<(70-64));
				*(volatile unsigned int *)(mux_base4+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x8);
				val |= (0x3<<(70-64));
				*(volatile unsigned int *)(mux_base5+0x8) = val;
#else
				//config  gpio 50,51 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x4);
				val &= ~(0x3<<(50-32));
				*(volatile unsigned int *)(mux_base1+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x4);
				val &= ~(0x3<<(50-32));
				*(volatile unsigned int *)(mux_base2+0x4) = val;

				val = *(volatile unsigned int *)(mux_base3+0x4);
				val &= ~(0x3<<(50-32));
				*(volatile unsigned int *)(mux_base3+0x4) = val;

				val = *(volatile unsigned int *)(mux_base4+0x4);
				val &= ~(0x3<<(50-32));
				*(volatile unsigned int *)(mux_base4+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x4);
				val |= (0x3<<(50-32));
				*(volatile unsigned int *)(mux_base5+0x4) = val;			
				
#endif
				break;	
			case 11:	
				//uart11 普通串口  
				val = *(volatile unsigned int *)(0xbfe4c904);
				val &= ~(0x1);
				*(volatile unsigned int *)(0xbfe4c904) = val;
#if 0
				//config  gpio 72,73 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x8);
				val &= ~(0x3<<(72-64));
				*(volatile unsigned int *)(mux_base1+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x8);
				val &= ~(0x3<<(72-64));
				*(volatile unsigned int *)(mux_base2+0x8) = val;

				val = *(volatile unsigned int *)(mux_base3+0x8);
				val &= ~(0x3<<(72-64));
				*(volatile unsigned int *)(mux_base3+0x8) = val;

				val = *(volatile unsigned int *)(mux_base4+0x8);
				val &= ~(0x3<<(72-64));
				*(volatile unsigned int *)(mux_base4+0x8) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x8);
				val |= (0x3<<(72-64));
				*(volatile unsigned int *)(mux_base5+0x8) = val;
#else
				//config  gpio 48,49 第五复用
				val = *(volatile unsigned int *)(mux_base1+0x4);
				val &= ~(0x3<<(48-32));
				*(volatile unsigned int *)(mux_base1+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base2+0x4);
				val &= ~(0x3<<(48-32));
				*(volatile unsigned int *)(mux_base2+0x4) = val;

				val = *(volatile unsigned int *)(mux_base3+0x4);
				val &= ~(0x3<<(48-32));
				*(volatile unsigned int *)(mux_base3+0x4) = val;

				val = *(volatile unsigned int *)(mux_base4+0x4);
				val &= ~(0x3<<(48-32));
				*(volatile unsigned int *)(mux_base4+0x4) = val;
				
				val = *(volatile unsigned int *)(mux_base5+0x4);
				val |= (0x3<<(48-32));
				*(volatile unsigned int *)(mux_base5+0x4) = val;			
#endif
				break;	
			default:
				break;
		}
		//##################### uart control regs init
		char str[50]={0};
		switch(channel)
		{
			case 1:
				uart_base = 0xbfe44000;
				strcpy(str, "uart1 test ok!\r\n");
				break;
			case 2:
				uart_base = 0xbfe48000;
				strcpy(str, "uart2 test ok!\r\n");
				break;
			case 3:
				uart_base = 0xbfe4c000;
				strcpy(str, "\r\nuart3 test ok!\r\n");
				break;
#if 1
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
			case 10:
			case 11:
				uart_base = (0xbfe4c000 + channel*0x100);
			//	strcpy(str, "uart[%d] test ok!\r\n", channel);
				sprintf(str, "uart[%d] test ok!\r\n",channel);
				break;
#else
			case 4:
				uart_base = 0xbfe4c400;
				strcpy(str, "uart4 test ok!\r\n");
				break;
			case 5:
				uart_base = 0xbfe4c500;
				strcpy(str, "uart5 test ok!\r\n");
				break;
			case 6:
				uart_base = 0xbfe4c600;
				strcpy(str, "uart6 test ok!\r\n");
				break;
			case 7:
				uart_base = 0xbfe4c700;
				strcpy(str, "uart7 test ok!\r\n");
				break;
			case 8:
				uart_base = 0xbfe4c800;
				strcpy(str, "uart8 test ok!\r\n");
				break;
			case 9:
				uart_base = 0xbfe4c900;
				strcpy(str, "uart9 test ok!\r\n");
				break;
			case 10:
				uart_base = 0xbfe4ca00;
				strcpy(str, "uart10 test ok!\r\n");
				break;
			case 11:
				uart_base = 0xbfe4cb00;
				strcpy(str, "uart11 test ok!\r\n");
				break;
#endif
			default:
				break;
		}
		*(volatile unsigned char *)(uart_base+0x2) = 0x7;
		*(volatile unsigned char *)(uart_base+0x3) = 0x80;
		*(volatile unsigned char *)(uart_base+0x0) = 0x1a;
		*(volatile unsigned char *)(uart_base+0x1) = 0x0;
		*(volatile unsigned char *)(uart_base+0x3) = 0x3;
//		*(volatile unsigned char *)(uart_base+0x4) = 0x3;  //uart9
//		,不能配置此寄存器, bit0 置位后，uart9-11 为uart8的全功能引脚
		*(volatile unsigned char *)(uart_base+0x1) = 0x0;
	
		//########## print test character
		val = strlen(str);
		for(i=0; i<val; i++)
			uart_put_char(uart_base,str[i]);
}


/***************************************************************************
 * Description:
 * Version : 1.00
 * Author  : Sunyoung 
 * Language: C
 * Date    : 2014-01-23
 ***************************************************************************/
#define sys_toywrite0 	0xbfe64024	//W 	TOY低32位数值写入
#define sys_toywrite1 	0xbfe64028	//W 	TOY高32位数值写入
#define sys_toyread0 	0xbfe6402C	//R 	TOY低32位数值读出
#define sys_toyread1 	0xbfe64030	//R 	TOY高32位数值读出

#define sys_rtcctrl 	0xbfe64040	//RW 	TOY和RTC控制寄存器
void rtc_test(void)
{
	_u32 val1, val2;
	_u32 tmp;
	tmp  =  ((0&0xf)<<0);     //msecond, width=4
	tmp |= ((59&0x3f)<<4);    //seconds, width=6
	tmp |= ((30&0x3f)<<10);   //minutes, width=6
	tmp |= ((10&0x1f)<<16);   //hours, width=5
	tmp |= ((30&0x1f)<<21);   //days, width=5
	tmp |= ((9&0x3f)<<26);    //month, width=6

	printf("enter rtc_test...\r\n");
	WTREG4(sys_toywrite0, tmp);

	printf("enter rtc_test...\r\n");
	WTREG4(sys_toywrite1, 2013);
//	WTREG4(sys_rtcctrl, 0x0d00);

//	delay_100ms(20);
	int i;
	printf("year-month-day  hour:minute:second:msec\r\n");
	for ( i = 0; i < 12; i++){
		for(tmp=0; tmp<5; tmp++) {
			RDREG4(sys_toyread0, val1);
			RDREG4(sys_toyread1, val2);
		}

		printf(" %d-%02d-%02d   %02d:%02d:%02d.%d \r\n", val2, ((val1>>26)&0x3f),
		   ((val1>>21)&0x1f), ((val1>>16)&0x1f), ((val1>>10)&0x3f), ((val1>>4)&0x3f), ((val1>>0)&0xf));

		delay_100ms(10);
	}
}

void touch_test(void)
{
	
//	WTREG4(sys_toywrite0, tmp);
   
	unsigned int i,val;

	WTREG4(0xbfe74000, 0x20000010);
	WTREG4(0xbfe74008, 0xc0);
	WTREG4(0xbfe74004, 0x10);
	RDREG4(0xbfe7401c, val);
	
	for(i=0; i<10000; i++)
	{
		RDREG4(0xbfe7401c, val);
		printf("  x:0x%d,  y:0x%d \r\n", (val&(0xffff<<16))>>16, val&0xffff);
		delay_100ms(1);
	}
}
static int cmd_ls1c_bsp_test(int argc,char **argv)
{
	unsigned  int channel;
	if(argc < 2)
	{
		printf(" cmd error!\r\n");
		return -1;
	}
	if(!strcmp(argv[1],"uart"))
	{
		channel=strtoul(argv[2],0,0);
		if((channel<1) || (channel>11)){
			printf("cmd exp:bsp_test uart [channel:1~11] \r\n");
			return -1;
		}
		uart_test(channel);
	}
	else if(!strcmp(argv[1],"rtc"))
	{
		rtc_test();
	}
	else if (!strcmp(argv[1],"touch"))
	{
		touch_test();
	}
}
//----------------------------------
static const Cmd Cmds[] =
{
	{"ls1c_bsp_test"},
	{"ls1c_bsp_test","[dev][args]", 0, "", cmd_ls1c_bsp_test, 0, 99, CMD_REPEAT},
	{0, 0}
};


static void init_cmd __P((void)) __attribute__ ((constructor));

static void
init_cmd()
{
	cmdlist_expand(Cmds, 1);
}


