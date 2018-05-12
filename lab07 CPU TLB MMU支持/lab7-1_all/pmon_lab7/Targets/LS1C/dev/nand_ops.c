#include<pmon.h>
#include<asm.h>
#include<machine/types.h>
#include<linux/mtd/mtd.h>
#include<linux/mtd/nand.h>
#include<linux/mtd/partitions.h>
#include<sys/malloc.h>
#define MYDBG 
//#define ECC               
#define NAND_2k_page              
//#define NAND_512_page              
//#define NAND_4k_page              
//printf("%s:%x\n",__func__,__LINE__);

#define _WL(x,y)    (*((volatile unsigned int*)(x)) = (y))
#define _RL(x,y)    ((y) = *((volatile unsigned int*)(x)))

#define NAND_WL(x,y)    _WL((x) + NAND_BASE,(y))
#define NAND_RL(x,y)    _RL((x) + NAND_BASE,(y))
#define DMA_WL(x,y)    _WL((x) + DMA_DESP,(y))
#define DMA_RL(x,y)    _RL((x) + DMA_DESP,(y))



#define RAM_ADDR            0xa4100000
#define DMA_DESP            0xa4001000
#define NAND_TMP            0xa4800000

#ifdef NAND_4k_page
  #define BLOCK_TO_PAGE(x)  ((x)<<7)
  #define PAGE_TO_BLOCK(x)  ((x)>>7)
  #define PAGE_TO_FLASH(x)  ((x)<<12)
  #define PAGE_TO_FLASH_H(x)  ((x)<<21)
  #define PAGE_TO_FLASH_S(x)  ((x)<<13)  // spare area
  #define PAGE_TO_FLASH_H_S(x)  ((x)>>20)
  #define FLASH_TO_PAGE(x)  ((x)>>11) //2k
  #define PAGES_A_BLOCK       0x80
#else
#ifdef NAND_2k_page
  #define BLOCK_TO_PAGE(x)  ((x)<<6)
  #define PAGE_TO_BLOCK(x)  ((x)>>6)
  #define PAGE_TO_FLASH(x)  ((x)<<11)
  #define PAGE_TO_FLASH_H(x)  ((x)<<21)
  #define PAGE_TO_FLASH_S(x)  ((x)<<12)  // spare area
  #define PAGE_TO_FLASH_H_S(x)  ((x)>>20)
  #define FLASH_TO_PAGE(x)  ((x)>>11)
  #define PAGES_A_BLOCK       0x40
#else
#ifdef NAND_512_page
  #define BLOCK_TO_PAGE(x)  ((x)<<5)
  #define PAGE_TO_BLOCK(x)  ((x)>>5)
  #define PAGE_TO_FLASH(x)  ((x)<<9)
  #define PAGE_TO_FLASH_H(x)  ((x)<<21)
  #define PAGE_TO_FLASH_S(x)  ((x)<<10)   // spare area
  #define PAGE_TO_FLASH_H_S(x)  ((x)>>20)
  #define FLASH_TO_PAGE(x)  ((x)>>9)
  #define PAGES_A_BLOCK       0x20
#endif
#endif
#endif



#define VT_TO_PHY(x)      ((x) & 0x0fffffff)   


#define NAND_BASE           0xbfe78000
#define CMD                 0x0
#define ADDR_COL            0x4
#define ADDR_ROW            0x8
#define TIMING              0xc
#define IDL                 0x10
#define IDH                 0x14
#define PARAM               0x18
#define OPNUM               0x1c
#define CS_RDY_MAP          0x20
#define DMA_ACCESS_ADDR     0x40


#define DMA_ORDER           0x0
#define DMA_SADDR           0x4
#define DMA_DEV             0x8
#define DMA_LEN             0xc
#define DMA_SET_LEN         0x10
#define DMA_TIMES           0x14
#define DMA_CMD             0x18

#define STOP_DMA            (_WL(0xbfd01160,0x10))
#define START_DMA(x)       do{  _WL(0xbfd01160,(VT_TO_PHY(x)|0x8));}while(0)
#define ASK_DMA(x)          (_WL(0xbfd01160,(VT_TO_PHY(x)|0x4)))

#define en_count(tmp)            do{asm volatile("mfc0 %0,$23;li $2,0x2000000;or $2,%0;mtc0 $2,$23;":"=r"(tmp)::"$2"); }while(0)
#define dis_count(tmp)           do{asm volatile("mtc0 %0,$23;"::"r"(tmp)); }while(0)

//#define SET_GPIO0_OUT(x)    do{x=(x==0?0:1);x=(*((volatile unsigned int*)0xbfd010f0) & ~0x1)|x; _WL(0xbfd010f0,(x));}while(0)
//#define SET_GPIO1_IN(x)    ((*((volatile unsigned int*)0xbfd010e0) & 0x2)>>1)

#define  LS1CSOC
#if 0
typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int  u32;
typedef unsigned long long u64;
#endif
int is_bad_block(u32 block);
int erase_block(u32 block);
int read_pages(u32 ram,u32 page,u32 pages,u8 flag,u8 ecc_flag);//flag:0==main 1==spare 2==main+spare
int write_pages(u32 ram,u32 page,u32 pages,u8 flag,u8 ecc_flag);//flag:0==main 1==spare 2==main+spare
int read_nand(u32 ram,u32 flash, u32 len,u8 flag,u8 ecc_flag);
int write_nand(u32 ram,u32 flash,u32 len,u8 flag,u8 ecc_flag);
int erase_nand(u32 start,u32 blocks);

int chipsize = 0x08000000;

void nand_udelay(unsigned int us)
{
	int tmp=0;
//	en_count(tmp);
	udelay(us);
//	dis_count(tmp);
}

/*
static void nand_send_cmd(u32 cmd, u32 page)//Send addr and cmd
{
	//#define CMD 0x0
	NAND_WL(CMD, 0);
	
	//操作发生在NAND的SPARE区
	if(cmd & (0x1<<9)){
		//操作发生在NAND的MAIN区
		if(cmd &(0x1<<8)){
			//#define PAGE_TO_FLASH_S(x)  ((x)<<12)
			NAND_WL(ADDR_COL, PAGE_TO_FLASH_S(page));
		}else{
			NAND_WL(ADDR_COL, PAGE_TO_FLASH_S(page)+0x800); //起始地址在2K处 备用区
		}
//		NAND_WL(ADDRH,PAGE_TO_FLASH_H_S(page));
	}else{
		//#define PAGE_TO_FLASH(x)  ((x)<<11)  2K
		NAND_WL(ADDR_COL, PAGE_TO_FLASH(page));
//		NAND_WL(ADDR_ROW, PAGE_TO_FLASH_H_S(page));
	}
	
	{
	int val=0;
//	printf("flashaddr==0x%08x,cmd==%d\n",NAND_RL(ADDR_COL,val),cmd);
	}

	NAND_WL(CMD, cmd & (~0xff));
	NAND_WL(CMD, cmd);
}
*/

static void nand_send_cmd(u32 cmd, u32 page)//Send addr and cmd
{
	NAND_WL(CMD, 0);

    if((cmd & 0x300) == 0)
    ;
    else if((cmd & 0x300) == 0x100)  // main area
         {
         NAND_WL(ADDR_COL,0x0);
         NAND_WL(ADDR_ROW,page);
         }
    else if((cmd & 0x300) == 0x200)  // spare area
        {
        #ifdef NAND_2k_page
         NAND_WL(ADDR_COL,0x800);    // addr_col >2k is spare area
        #else
        #ifdef NAND_4k_page
         NAND_WL(ADDR_COL,0x1000);   // addr_col >4k is spare area
        #else
        #ifdef NAND_512_page
         NAND_WL(ADDR_COL,0x200);    // addr_col >512 is spare area
        #endif
        #endif
        #endif
         NAND_WL(ADDR_ROW,page);
        }
    else                             // main + spare area
        {
         NAND_WL(ADDR_COL,0x0);
         NAND_WL(ADDR_ROW,page);
        }

	NAND_WL(CMD, cmd & (~0xff));
	NAND_WL(CMD, cmd);
}

#if 0
void gpio_init(void)
{
    _WL(0xbfd010c0,0x3);//enable gpio0 and gpio1
    _WL(0xbfd010d0,0x2);//gpio0 output,gpio1 intput
    
}
#endif

static u8 rdy_status(void)
{
	//外部NAND芯片RDY情况
	return ((*((u32*) (NAND_BASE+CMD)) & (0x1<<16)) == 0 ? 0:1);
}

static u8 nand_op_ok(u32 len, u32 ram)
{
    u32 ask=0, dmalen=0, dmastatus=0;
    
	while(1){
		ASK_DMA(DMA_DESP);	//用户请求将当前DMA操作的相关信息写回到指定的内存地址
		_RL(DMA_DESP+0x4, ask);	//DMA操作的内存地址
		_RL(DMA_DESP+0xc, dmalen);
		_RL(DMA_DESP+0x18, dmastatus);
//		printf("ask       ==0x%08x,damlen==0x%08x,dmastatus==0x%08x\n",ask,dmalen,dmastatus);
//		printf("ask should==0x%08x,len==0x%08x\n", (VT_TO_PHY(ram)+((len+3)/4)*4),len);
		//判断读取的值是否是写入的值
		if(ask == (VT_TO_PHY(ram)+((len+3)/4)*4)){break;}else{return 0;}	//THF
		nand_udelay(60);
	}
	while(!rdy_status())
		nand_udelay(20);
	return 0;
}

static void dma_config(u32 len,u32 ddr,u32 cmd)
{
	MYDBG
	DMA_WL(DMA_ORDER, 0);				//下一个描述符地址寄存器 这里设置为无效
	MYDBG
	DMA_WL(DMA_SADDR, VT_TO_PHY(ddr));	//内存地址寄存器
	MYDBG
	DMA_WL(DMA_DEV, 0x1fe78040);		//设备地址寄存器 Loongson 1B的NAND Flash DMA存取地址
	MYDBG
	DMA_WL(DMA_LEN, (len+3)/4);			//长度寄存器 代表一块被搬运内容的长度，单位是字  由于从NAND Flash读取回的数据以字节为单位 所以除以4 加3是？
	MYDBG
	DMA_WL(DMA_SET_LEN, 0);				//间隔长度寄存器 间隔长度说明两块被搬运内存数据块之间的长度，前一个step的结束地址与后一个step的开始地址之间的间隔
	MYDBG
	DMA_WL(DMA_TIMES, 1);				//循环次数寄存器 循环次数说明在一次DMA操作中需要搬运的块的数目
	MYDBG
	DMA_WL(DMA_CMD, cmd);				//控制寄存器
	MYDBG
}

int is_bad_block(u32 block)
{
	u32 page=0;
	//#define BLOCK_TO_PAGE(x)  ((x)<<6)
	page = BLOCK_TO_PAGE(block);	//Block 对应的页起始地址？ 以64页为1个Block
	read_pages(RAM_ADDR, page, 1, 1, 0);	//最后的1代表读取64B备用区
    #ifdef  NAND_512_page
	if(*((u8*) (RAM_ADDR+5)) != 0xff){return 1;}	//判断是否为坏块 参考nand flash数据手册 // 6th byte is the flag of bad page
    #else
	if(*((u8*) RAM_ADDR) != 0xff){return 1;}	//判断是否为坏块 参考nand flash数据手册 // 6th byte is 1he flag of bad page
    #endif
	return 0;
}

int erase_block(u32 block)
{
	u32 flash_l=0,flash_h=0;
#ifdef LS1CSOC
	NAND_WL(TIMING, 0x209);
#else
	NAND_WL(TIMING, 0x206);	//NAND命令有效需等待的周期数 NAND一次读写所需总时钟周期数
#endif
	NAND_WL(OPNUM, 0x1);		//NAND读写操作Byte数；擦除为块数
//	printf("block==0x%08x\n",block);
	nand_send_cmd(0x9, BLOCK_TO_PAGE(block));
	MYDBG
	nand_udelay(50);
	MYDBG
	while(!rdy_status())
	nand_udelay(30);
	return 0;
}
/***************************************************************************
 * Description:
 * Version : 1.00
 * Author  : cc
 * Language: C
 * Date    : 2013-05-13
 ***************************************************************************/
//ram		: ramaddr
//page		: read nand start page
//pages		:
//flag		: 0==main 1==spare 2==main+spare
//ecc_flag	:
//

int read_pages(u32 ram, u32 page, u32 pages, u8 flag, u8 ecc_flag)
{
	u32 len=0,dma_cmd=0,nand_cmd=0;
	u32 ret = 0,tmp;
    u32 dmalen = 0;	

  if(ecc_flag == 0)
    {
      #ifdef NAND_2k_page
      switch(flag){
      	case 0:
      		len = pages * 0x800;	//2K（K9F1G08U0C）
      		nand_cmd = 0x103;		//操作发生在NAND的MAIN区+读操作+命令有效
      	break;
      	case 1:
      		len = pages * 0x40;	//64B
      		nand_cmd = 0x203;		//操作发生在NAND的SPARE区+读操作+命令有效
      	break;
      	case 2:
      		len = pages * 0x840;	//2K + 64B
      		nand_cmd = 0x303;		//操作发生在NAND的SPARE区+操作发生在NAND的MAIN区+读操作+命令有效
      	break;
      	default:
      		len = 0;
      		nand_cmd = 0;
      	break;
      }
      #else
      #ifdef NAND_512_page
      switch(flag){
      	case 0:
      		len = pages*0x200;  // 512 page
      		nand_cmd = 0x103;
      	break;
      	case 1:
      		len = pages*0x10;
      		nand_cmd = 0x203;
      	break;
      	case 2:
      		len = pages*0x210;
      		nand_cmd = 0x303;
      	break;
      	default:
      		len = 0;
      		nand_cmd = 0;
      	break;
      }
      #else
      #ifdef NAND_4k_page
      switch(flag){
      	case 0:
      		len = pages*0x1000;  // 4k page
      		nand_cmd = 0x103;
      	break;
      	case 1:
      		len = pages*0x80;
      		nand_cmd = 0x203;
      	break;
      	case 2:
      		len = pages*0x1080;
      		nand_cmd = 0x303;
      	break;
      	default:
      		len = 0;
      		nand_cmd = 0;
      	break;
      }
      #endif
      #endif
      #endif
          dmalen = len;
    }
  else
    {
      #ifdef NAND_2k_page
	  switch(flag){
	  	case 0:
	  		len = pages * 0x7f8;	//2040（K9F1G08U0C）
	  		nand_cmd = 0x4903;		//操作发生在NAND的MAIN区+读操作+命令有效
	  		dmalen = pages * 0x758;	//1880（K9F1G08U0C）
	  	break;
	  	case 1:
	  		len = pages * 0x40;	//64B
	  		nand_cmd = 0x203;		//操作发生在NAND的SPARE区+读操作+命令有效
	  		dmalen = len;	//64
	  	break;
	  	case 2:
	  		len = pages * 0x840;	//2K + 64B
	  		nand_cmd = 0x4b03;		//操作发生在NAND的SPARE区+操作发生在NAND的MAIN区+读操作+命令有效
	  		dmalen = pages * 0x798;	//1880+64（K9F1G08U0C）
	  	break;
	  	default:
	  		len = 0;
	  		nand_cmd = 0;
	  	break;
	  }
      #else
      #ifdef NAND_512_page
	  switch(flag){
	  	case 0:
	  		len = pages*0x198;  // 512 page
	  		nand_cmd = 0x4903;
	  		dmalen = pages * 0x178;	//376（K9F1G08U0C）
	  	break;
	  	case 1:
	  		len = pages*0x10;  // 16
	  		nand_cmd = 0x203;
	  		dmalen = len;
	  	break;
	  	case 2:
	  		len = pages*0x210;
	  		nand_cmd = 0x4b03;
	  		dmalen = pages*0x188; // 376 + 16
	  	break;
	  	default:
	  		len = 0;
	  		nand_cmd = 0;
	  		dmalen = len;
	  	break;
	  }
      #else
      #ifdef NAND_4k_page
	  switch(flag){
	  	case 0:
	  		len = pages*0xff0;  // 4080 Byte / page
	  		nand_cmd = 0x4903;
	  		dmalen = pages*0xeb0; // 3760 Byte 
	  	break;
	  	case 1:
	  		len = pages*0x80;  // 128 Byte
	  		nand_cmd = 0x203;
	  		dmalen = len;
	  	break;
	  	case 2:
	  		len = pages*0x1080; //
	  		nand_cmd = 0x4b03;
	  		dmalen = pages*0xf30; // 3760  + 128Byte 
	  	break;
	  	default:
	  		len = 0;
	  		nand_cmd = 0;
	  		dmalen = len;
	  	break;
	  }
      #endif
      #endif
      #endif
    }
	MYDBG
    printf("dbg len==0x%08x,pages==0x%08x\n",dmalen,pages); // wulong1111
	dma_config(dmalen, ram, dma_cmd);	//配置DMA
	MYDBG
	//#define STOP_DMA            (_WL(0xbfd01160,0x10))
	STOP_DMA;	//用户请求停止DMA操作
	MYDBG
	nand_udelay(5);
	MYDBG
	//#define START_DMA(x)       do{  _WL(0xbfd01160,(VT_TO_PHY(x)|0x8));}while(0)
	START_DMA(DMA_DESP);
//	printf("0xbfd00116206=0x%08x\n",*(volatile unsigned int *)(0xbfd01160));
	NAND_WL(TIMING, 0x206);	//NAND命令有效需等待的周期数 NAND一次读写所需总时钟周期数
//	NAND_WL(TIMING, 0x40a);	//NAND命令有效需等待的周期数 NAND一次读写所需总时钟周期数
//	NAND_WL(TIMING, 0x60c);	//NAND命令有效需等待的周期数 NAND一次读写所需总时钟周期数
	NAND_WL(OPNUM, len);		//NAND读写操作Byte数；擦除为块数
	nand_send_cmd(nand_cmd, page);
	nand_udelay(20000);
	MYDBG
	ret = nand_op_ok(len, ram);
//	nand_udelay(100);
	MYDBG
	if(ret){
		printf("nandread 0x%08x page 0x%08x pages have some error\n",page,pages);
	} 
	return ret;
}

#if 0
int write_pages(u32 ram,u32 page,u32 pages,u8 flag)
{
    u32 len=0,dma_cmd=0x1000,nand_cmd=0;
    u32 ret=0;
    switch(flag){
        case 0:
            len = pages * 0x800;
            nand_cmd = 0x105;
            break;
        case 1:
            len = pages * 0x40;
            nand_cmd = 0x205;
            break;
        case 2:
            len = pages * 0x840;
            nand_cmd = 0x305;
            break;
        default:
            len = 0;
            nand_cmd = 0;
            break;
    }
    printf("len==0x%08x,pages==0x%08x\n",len,pages);
    dma_config(len,ram,dma_cmd);
    STOP_DMA;
    nand_udelay(10);
    START_DMA(DMA_DESP);
    NAND_WL(TIMING,0x412);
    NAND_WL(OPNUM,len);
    nand_send_cmd(nand_cmd,page);
    nand_udelay(1000);
        MYDBG;
    ret = nand_op_ok(len,ram);
        MYDBG;
   if(ret){
        printf("nandwrite 0x%08x page 0x%08x pages have some error\n",page,pages);
   } 
   return ret;
}
#endif

int write_pages(u32 ram,u32 page,u32 pages,u8 flag,u8 ecc_flag)
{
	u32 len=0,dma_cmd=0x1000,nand_cmd=0;
	u32 ret=0,step=1;
	int val=pages;
    u32 dmalen = 0;	

  if(ecc_flag == 0)
    {
      #ifdef NAND_2k_page
	  switch(flag){
	  	case 0:
	  		len = step*0x800;  // 2k page
	  		nand_cmd = 0x105;
	  	break;
	  	case 1:
	  		len =  step*0x40;
	  		nand_cmd = 0x205;
	  	break;
	  	case 2:
	  		len = step*0x840;
	  		nand_cmd = 0x305;
	  	break;
	  	default:
	  		len = 0;
	  		nand_cmd = 0;
	  	break;
	  }
      #else
      #ifdef NAND_512_page
	  switch(flag){
	  	case 0:
	  		len = step*0x200;  // 512 page
	  		nand_cmd = 0x105;
	  	break;
	  	case 1:
	  		len =  step*0x10;
	  		nand_cmd = 0x205;
	  	break;
	  	case 2:
	  		len = step*0x210;
	  		nand_cmd = 0x305;
	  	break;
	  	default:
	  		len = 0;
	  		nand_cmd = 0;
	  	break;
	  }
      #else
      #ifdef NAND_4k_page
	  switch(flag){
	  	case 0:
	  		len = step*0x1000;  // 4k page
	  		nand_cmd = 0x105;
	  	break;
	  	case 1:
	  		len =  step*0x80;
	  		nand_cmd = 0x205;
	  	break;
	  	case 2:
	  		len = step*0x1080;
	  		nand_cmd = 0x305;
	  	break;
	  	default:
	  		len = 0;
	  		nand_cmd = 0;
	  	break;
	  }
      #endif
      #endif
      #endif
      dmalen = len;
    }
  else
    {
      #ifdef NAND_2k_page
	  switch(flag){
	  	case 0:
	  		len = step*0x7f8; //2040 page
	  		nand_cmd = 0x1105;
	  		dmalen = pages * 0x758;	//1880（K9F1G08U0C）
	  	break;
	  	case 1:
	  		len =  step*0x40;
	  		nand_cmd = 0x205;
              dmalen = len;
	  	break;
	  	case 2:
	  		len = step*0x840;
	  		nand_cmd = 0x1305;
	  		dmalen = pages * 0x798;	//1880+ 64（K9F1G08U0C）
	  	break;
	  	default:
	  		len = 0;
	  		nand_cmd = 0;
              dmalen = len;
	  	break;
	  }
      #else
      #ifdef NAND_512_page
	  switch(flag){
	  	case 0:
	  		len = step*0x198;  // 408 page
	  		nand_cmd = 0x1105;
	  		dmalen = pages * 0x178;	//376（K9F1G08U0C）
	  	break;
	  	case 1:
	  		len =  step*0x10;
	  		nand_cmd = 0x205;
              dmalen = len;
	  	break;
	  	case 2:
	  		len = step*0x210;
	  		nand_cmd = 0x1305;
	  		dmalen = pages * 0x188;	//376+16（K9F1G08U0C）
	  	break;
	  	default:
	  		len = 0;
	  		nand_cmd = 0;
              dmalen = len;
	  	break;
	  }
      #else
      #ifdef NAND_4k_page
	  switch(flag){
	  	case 0:
	  		len = step*0xff0;  // 4080 page
	  		nand_cmd = 0x1105;
	  		dmalen = pages*0xeb0; // 3760 Byte 
	  	break;
	  	case 1:
	  		len =  step*0x80;
	  		nand_cmd = 0x205;
              dmalen = len;
	  	break;
	  	case 2:
	  		len = step*0x1080;
	  		nand_cmd = 0x1305;
	  		dmalen = pages*0xf30; // 3760  + 128Byte 
	  	break;
	  	default:
	  		len = 0;
	  		nand_cmd = 0;
              dmalen = len;
	  	break;
	  }
      #endif
      #endif
      #endif
    }
		printf("len==0x%08x,pages==0x%08x\n",dmalen,val); // wulong1111
	for(; val>0; val-=step){
		dma_config(dmalen,ram,dma_cmd);
		STOP_DMA;
		nand_udelay(10);
		START_DMA(DMA_DESP);
		NAND_WL(TIMING,0x206);
//		NAND_WL(TIMING,0x40a);
		NAND_WL(OPNUM,len);
		nand_send_cmd(nand_cmd,page);
		nand_udelay(300);
		ret = nand_op_ok(len,ram);
		ram += len;
		page += step;
		MYDBG;
		if(ret){
			printf("nandwrite 0x%08x page 0x%08x pages have some error\n",page,pages);
		}
	} 
	return ret;
}

//检查输入的参数是否在可处理的范围内
int error_check(u32 ram, u32 flash, u32 len)
{ 
	if(FLASH_TO_PAGE(flash) >= 0xffffffff){
		printf("the FLASH addr is big,this program don't work on this FLASH addr...\n");
		return -1;
	} 
	if(flash & 0x7ff){
		printf("the FLASH addr don't align/* Need 0x800B alignment*/\n");	//以2K(K9F1G08U0C)为1页
		return -1;
	}
	if(ram & 0x1f){
		printf("the RAM addr 0x%08x don't align/* Need 32B alignment*/\n",ram);
		return -1;
	}
	if(len < 0 || len > chipsize){
		printf("the LEN 0x%08x(%d) is a unvalid number\n",len,len);
		return -1;
	}
	return 0;
}

int read_nand(u32 ram,u32 flash,u32 len,u8 flag,u8 ecc_flag)
{
	u32 page = 0;
	u32 ret = 0;
	u32 b_pages = 0,a_pages = 0;
	u32 pages = 0, block = 0, chunkblock = 0, chunkpage = 0;
	int badblock_count=0;		//lxy
	
	ret = error_check(ram, flash, len);	//检查输入的参数是否在可处理的范围内
	if(ret)
		return ret;
	//#define FLASH_TO_PAGE(x)  ((x)>>11)
	//把输入的flash地址转换为页地址 这里页大小为2K 如果换用不同的Flash会如何？
	page = FLASH_TO_PAGE(flash);//start page 
	printf("%x:page==0x%08x\n",__LINE__,page);
/*
	while(is_bad_block(PAGE_TO_BLOCK(page))){
//		printf("%x:page==0x%08x\n",__LINE__,page);
//		printf("%x:block==0x%08x\n",__LINE__,PAGE_TO_BLOCK(page));
//		printf("block==%x,page==%x\n",PAGE_TO_BLOCK(page),page);
//		MYDBG;
		//#define PAGES_A_BLOCK       0x40
		page += PAGES_A_BLOCK;	//页大小（2K）+ 64B （K9F1G08U0C）
		badblock_count++;
		//#define BLOCK_TO_PAGE(x)  ((x)<<6)
		//#define PAGE_TO_BLOCK(x)  ((x)>>6)
		page = (BLOCK_TO_PAGE(PAGE_TO_BLOCK(page)));	//64页 组成1个Block 擦除以Block为单位
//		printf("%x:page==0x%08x\n",__LINE__,page);
		printf("the FLASH addr 0x%08x is a bad block,auto change FLASH addr 0x%08x\n", flash, PAGE_TO_FLASH(page));
	}
*/
	printf(" dbg flag:0x%x ,ecc_flag:0x%x \r\n",flag, ecc_flag);
if(ecc_flag == 0)
  {
     #ifdef NAND_2k_page
      switch(flag){
      	case 0:
      		chunkblock = 0x20000;	//128K
      		chunkpage = 0x800;
			printf(" 2k page  ,128k block\r\n");
      	break;
      	case 1:
      		chunkblock = 0x1000;		//4K
      		chunkpage = 0x40;
      	break;
      	case 2:
      		chunkblock = 0x21000;	//128K+4K
      		chunkpage = 0x840;
      	break;
      	default:
      		chunkblock = 0;
      		chunkpage = 0;
      	break;
      }    
     #else
     #ifdef NAND_512_page
      switch(flag){
      	case 0:
      		chunkblock = 0x4000;	//512*32=16k
      		chunkpage = 0x200;
      	break;
      	case 1:
      		chunkblock = 0x200;		//16*32=1K
      		chunkpage = 0x10;
      	break;
      	case 2:
      		chunkblock = 0x4200;	//32K+1K
      		chunkpage = 0x210;
      	break;
      	default:
      		chunkblock = 0;
      		chunkpage = 0;
      	break;
      }    
     #else
     #ifdef NAND_4k_page
      switch(flag){
      	case 0:
      		chunkblock = 0x80000;	//512K
      		chunkpage = 0x1000;
      	break;
      	case 1:
      		chunkblock = 0x4000;    //16K
      		chunkpage = 0x80;
      	break;
      	case 2:
      		chunkblock = 0x84000;	//512K+16K
      		chunkpage = 0x1080;
      	break;
      	default:
      		chunkblock = 0;
      		chunkpage = 0;
      	break;
      }    
    #endif
    #endif
    #endif
  }
  else
  {
     #ifdef NAND_2k_page
      switch(flag){
      	case 0:
      		chunkblock = 0x1fe00;	//2040 * 64
      		chunkpage = 0x7f8;
      	break;
      	case 1:
      		chunkblock = 0x1000;		//64 * 64
      		chunkpage = 0x40;
      	break;
      	case 2:
      		chunkblock = 0x21000;	//128K+4K
      		chunkpage = 0x840;
      	break;
      	default:
      		chunkblock = 0;
      		chunkpage = 0;
      	break;
      }    
     #else
     #ifdef NAND_512_page
      switch(flag){
      	case 0:
      		chunkblock = 0x3300;	//408 * 32
      		chunkpage = 0x198;
      	break;
      	case 1:
      		chunkblock = 0x200;		//16*32
      		chunkpage = 0x10;
      	break;
      	case 2:
      		chunkblock = 0x4200;	//16K+512
      		chunkpage = 0x210;
      	break;
      	default:
      		chunkblock = 0;
      		chunkpage = 0;
      	break;
      }    
     #else
     #ifdef NAND_4k_page
      switch(flag){
      	case 0:
      		chunkblock = 0x7f800;	//4080*128
      		chunkpage = 0xff0;
      	break;
      	case 1:
      		chunkblock = 0x4000;    //128*128
      		chunkpage = 0x80;
      	break;
      	case 2:
      		chunkblock = 0x84000;	//512K+16K
      		chunkpage = 0x1080;
      	break;
      	default:
      		chunkblock = 0;
      		chunkpage = 0;
      	break;
      }    
    #endif
    #endif
    #endif
  }
//	printf("reading ");
	pages = (len + chunkpage - 1)/chunkpage;
//	printf("%x:pages==0x%08x\n",__LINE__,pages);
	b_pages = page % PAGES_A_BLOCK;	//每Block的Page数 余数为0
	b_pages = (PAGES_A_BLOCK - b_pages);
//	printf("%x:pages==0x%08x  b_pages=%x\n", __LINE__, pages, b_pages);
	if(pages > b_pages && b_pages > 0){                      // read overcross a block,then read the rest pages of the 1st block(as b_pages)
		ret = read_pages(ram, page, b_pages, flag, ecc_flag);
		pages -= b_pages;
		page += b_pages;
		ram += (chunkpage * b_pages);
	}else if(pages <= b_pages && b_pages > 0){              // read in a block, then read normally 
		ret = read_pages(ram, page, pages, flag, ecc_flag);
		pages = 0;
	}
	if(ret){return ret;}
	if(pages){                            // finished reading the data in 1st block,then aligned block base addr
		block = pages / PAGES_A_BLOCK;
		a_pages = pages % PAGES_A_BLOCK;  // pages in the last block
	}
	for(;block > 0;block--){
		while(is_bad_block(PAGE_TO_BLOCK(page))){
			printf("the FLASH addr 0x%08x is bad block,try next block...\n",PAGE_TO_FLASH(page));
			page += PAGES_A_BLOCK;
		}
		ret = read_pages(ram, page, PAGES_A_BLOCK, flag, ecc_flag);
//		printf(". ");
		if(ret) {return ret;}
		pages -= PAGES_A_BLOCK;
		page += PAGES_A_BLOCK ;
		ram += chunkblock;
	} 
	if(a_pages){
		while(is_bad_block(PAGE_TO_BLOCK(page))){
			printf("the FLASH addr 0x%08x is bad block,try next block...\n",PAGE_TO_FLASH(page));
			page += PAGES_A_BLOCK;
		}
		ret = read_pages(ram,page,a_pages,flag, ecc_flag);
		if(ret){return ret;}
	}
	
//	printf("... done\n");
	/*
	{
		int i;
		unsigned char *temp = (unsigned char *)ram;
		for (i=0; i<256; i++)
		{
			if((i%16) == 0)
				printf("\n");
		//	printf("%x ", *(unsigned int *)(ram+(i*4)));
			printf("%02x ", *(temp+i));
		}
		printf("\n");
	}
	*/
//	return ret;
	return badblock_count;
}


int write_nand(u32 ram, u32 flash, u32 len, u8 flag, u8 ecc_flag)
{
	u32 page=0,start_page=0;
	u32 ret = 0;
	u32 b_pages = 0,a_pages=0;
	u32 pages = 0,block=0,chunkblock=0,chunkpage=0;
	int badblock_count=0;		//lxy
    int i;

	ret = error_check(ram,flash,len);	//检查输入的参数是否在可处理的范围内
	if(ret)
		return ret;
	//#define FLASH_TO_PAGE(x)  ((x)>>11)
	//把输入的flash地址转换为页地址 这里页大小为2K 如果换用不同的Flash会如何？
	page = FLASH_TO_PAGE(flash);//start page
	//检查该页是否为坏块
	while(is_bad_block(PAGE_TO_BLOCK(page))){
		page += PAGES_A_BLOCK;
		badblock_count++;
		page = (BLOCK_TO_PAGE(PAGE_TO_BLOCK(page)));
		printf("the FLASH addr 0x%08x is a bad block,auto change FLASH addr 0x%08x\n", flash, PAGE_TO_FLASH(page));
	}

if(ecc_flag == 0)
  {
     #ifdef NAND_2k_page
      switch(flag){
      	case 0:
      		chunkblock = 0x20000;	//128K
      		chunkpage = 0x800;      //2k
      	break;
      	case 1:
      		chunkblock = 0x1000;		//4K
      		chunkpage = 0x40;
      	break;
      	case 2:
      		chunkblock = 0x21000;	//128K+4K
      		chunkpage = 0x840;
      	break;
      	default:
      		chunkblock = 0;
      		chunkpage = 0;
      	break;
      }    
     #else
     #ifdef NAND_512_page
      switch(flag){
      	case 0:
      		chunkblock = 0x4000;	//16K
      		chunkpage = 0x200;
      	break;
      	case 1:
      		chunkblock = 0x200;		//512
      		chunkpage = 0x10;
      	break;
      	case 2:
      		chunkblock = 0x4200;	//16K+512
      		chunkpage = 0x210;
      	break;
      	default:
      		chunkblock = 0;
      		chunkpage = 0;
      	break;
      }    
     #else
     #ifdef NAND_4k_page
      switch(flag){
      	case 0:
      		chunkblock = 0x80000;	//512K
      		chunkpage = 0x1000;
      	break;
      	case 1:
      		chunkblock = 0x4000;    //16K
      		chunkpage = 0x80;
      	break;
      	case 2:
      		chunkblock = 0x84000;	//512K+16K
      		chunkpage = 0x1080;
      	break;
      	default:
      		chunkblock = 0;
      		chunkpage = 0;
      	break;
      }    
    #endif
    #endif
    #endif
  }
else
  {
     #ifdef NAND_2k_page
      switch(flag){
      	case 0:
      		chunkblock = 0x1fe00;	//2040 * 64
      		chunkpage = 0x7f8;
      	break;
      	case 1:
      		chunkblock = 0x1000;		//64 * 64
      		chunkpage = 0x40;
      	break;
      	case 2:
      		chunkblock = 0x21000;	//128K+4K
      		chunkpage = 0x840;
      	break;
      	default:
      		chunkblock = 0;
      		chunkpage = 0;
      	break;
      }    
     #else
     #ifdef NAND_512_page
      switch(flag){
      	case 0:
      		chunkblock = 0x3300;	//408 * 32
      		chunkpage = 0x198;
      	break;
      	case 1:
      		chunkblock = 0x200;		//16*32
      		chunkpage = 0x10;
      	break;
      	case 2:
      		chunkblock = 0x4200;	//16K+512
      		chunkpage = 0x210;
      	break;
      	default:
      		chunkblock = 0;
      		chunkpage = 0;
      	break;
      }    
     #else
     #ifdef NAND_4k_page
      switch(flag){
      	case 0:
      		chunkblock = 0x7f800;	//4080*128
      		chunkpage = 0xff0;
      	break;
      	case 1:
      		chunkblock = 0x4000;    //128*128
      		chunkpage = 0x80;
      	break;
      	case 2:
      		chunkblock = 0x84000;	//512K+16K
      		chunkpage = 0x1080;
      	break;
      	default:
      		chunkblock = 0;
      		chunkpage = 0;
      	break;
      }    
    #endif
    #endif
    #endif
  }
    for(i=0;i<len/4;i++)       //???
    {*((volatile unsigned int *)(ram + 4*i)) = len - 4*i;}

//	printf("writing. ");    
	pages = (len + chunkpage - 1)/chunkpage;
//	printf("%x:pages==0x%08x\n",__LINE__,pages);
	start_page = page % PAGES_A_BLOCK;	//页在块中的相对起始地址
	if(start_page){
		b_pages = (PAGES_A_BLOCK - start_page);
	}
	if(b_pages > 0){
		//读取需要写入的页在对应块中的该块的数据，暂存
		ret = read_pages(NAND_TMP, page - start_page, start_page, 2,0); //page - start_page = 以块为单位块中的第一个页地址
		if(ret){return ret;}
		erase_block(PAGE_TO_BLOCK(page));//擦除该块
		ret = write_pages(NAND_TMP, page - start_page, start_page, 2,0);
//		printf(". ");
		if(ret){return ret;}
	}
	if(pages > b_pages && b_pages > 0){
		ret = write_pages(ram, page, b_pages, flag, ecc_flag);
		pages -= b_pages;
		page += b_pages;
		ram += (chunkpage * b_pages);
	}else if(pages <= b_pages && b_pages > 0){
		ret = write_pages(ram,page,pages,flag,ecc_flag);
		pages = 0;
	}
	if(ret){return ret;}
	if(pages){
		block = pages / PAGES_A_BLOCK;
		a_pages = pages % PAGES_A_BLOCK;
	}
//	printf("block==0x%08x,a_pages==0x%08x\n",block,a_pages);
	for(;block > 0;block--){
		printf("  dbg  block:%d \r\n",block);
		MYDBG
		erase_block(PAGE_TO_BLOCK(page));
		while(is_bad_block(PAGE_TO_BLOCK(page))){
			printf("the FLASH addr 0x%08x is bad block,try next block...\n",PAGE_TO_FLASH(page));
			page += PAGES_A_BLOCK;
			erase_block(PAGE_TO_BLOCK(page));
		}
		MYDBG
		ret = write_pages(ram,page,PAGES_A_BLOCK,flag,ecc_flag);
		MYDBG
//		printf(". ");
		if(ret) {return ret;}
		pages -= PAGES_A_BLOCK;
		page += PAGES_A_BLOCK;
		ram += chunkblock;
	} 
	MYDBG
	if(a_pages){
		erase_block(page);
		while(is_bad_block(PAGE_TO_BLOCK(page))){
			printf("the FLASH addr 0x%08x is bad block,try next block...\n",PAGE_TO_FLASH(page));
			page += PAGES_A_BLOCK;
			erase_block(PAGE_TO_BLOCK(page));
		}
		ret = write_pages(ram,page,a_pages,flag,ecc_flag);
		if(ret){return ret;}
	}
//	printf("... done\n");
//	return ret;
	return badblock_count;
}

int erase_nand(u32 start,u32 blocks)
{
	int i = 0;
//	printf("erasing ");
	for(; i<blocks; i++){
		erase_block(i+start);
//		printf(". ");
	}
//	printf(" done\n");
	MYDBG
	return 0;
}
#if 1
//int mymain_nand(u8 ops,u32 ram,u32 flash,u32 len,u8 flag)
int mymain_nand(int argc,char **argv)
{
    u8 ops = 0, flag = 0;
    u32 ram = 0, flash = 0;
    u32 len = 0;
    
    printf("\n\t\t*****Nand Flash OPS*****\n\n");
    {
        printf("Uargs:callbin ./bin/nand_ops.bin OPS startblock blocks\n");
        printf("Uargs:callbin ./bin/nand_ops.bin OPS ram flashaddr len flag\n");
        printf("Uargs:flag: 0=main; 1=spare; 2=spare+main\n\n");
        printf("Uargs:OPS:  0=write nand; 1=read nand; 2=erase nand\n\n");
    }
//    printf("\nbuf==0x%08x,ram==0x%08x,flash==0x%08x,len==0x%08x,flag==0x%08x\n",buf,ram,flash,len,flag);

    ops=strtoul(argv[1],0,0);
    ram=strtoul(argv[2],0,0);
    flash=strtoul(argv[3],0,0);
    len=strtoul(argv[4],0,0);
    flag=strtoul(argv[5],0,0);
#if 1
    switch(ops){
        case 2:
            erase_nand(ram,flash);
            printf("erase nand ops OK...\n");
            break;
        case 1:
            read_nand(ram,flash,len,flag,0);
            printf("read nand ops OK...\n");
            break;
        case 0:
            write_nand(ram,flash,len,flag,0);
            printf("write nand ops OK...\n");
            break;
        default:
            printf("\ninput invalid OPS(0 erase_nand; 1 read_nand; 2 write_nand)...\n\n");
            break;
    }
#endif

    return 0;
}
#endif

int mynand_erase(int argc,char **argv)
{
	u32 start=0,blocks=0;
	
	if(argc!=3){
		printf("args error...\n");
		printf("uargs:erase_nand <startblock> <blocks>\n");
		printf("example:erase_nand 1 0x10\n");
		return -1;
	}
	start = strtoul(argv[1],0,0);	//擦除块起始地址 128K为1块 0为第0块 1为第1块.....等等
	blocks = strtoul(argv[2],0,0);	//擦除的块数 0为不擦除
//	printf("start==0x%08x,blocks==0x%08x\n",start,blocks);
	erase_nand(start, blocks);
//	printf("erase nand ops OK...\n");
	return 0;
}

int mynand_read(int argc,char **argv)
{
	u32 ram=0,flash=0,len=0;
	u8 m_s_flag=0, ecc_flag=0;
	char *dst=NULL;

	if(argc<5){
		printf("args error...\n");
		printf("uargs:read_nand <ramaddr>  <flashaddr>  <len> <flag>\n");
		printf("uargs:flag = (m/M(main),s/S(spare),a/A(main+spare))\n");
		printf("example:read_nand 0xa1000000  0x0  0x20000 m\n");
		return -1;
	}
	if(!strncmp(argv[4],"m",1) || !strncmp(argv[4],"M",1)){m_s_flag=0;}		//main区
	else if(!strncmp(argv[4],"s",1) || !strncmp(argv[4],"S",1)){m_s_flag=1;}	//备用区
	else if(!strncmp(argv[4],"a",1) || !strncmp(argv[4],"A",1)){m_s_flag=2;}	//main+备用区
	else{m_s_flag=0;}
	ram = strtoul(argv[1],0,0);		//读取的NAND Flash数据保存到的内存地址？
	flash = strtoul(argv[2],0,0);	//读取的NAND Flash起始地址？
	len = strtoul(argv[3],0,0);		//读取长度
	ecc_flag = strtoul(argv[5],0,0);	//ecc flag
//	printf("ram==0x%08x,flash==0x%08x\n",ram,flash,len,flag);
	read_nand(ram, flash, len, m_s_flag, ecc_flag);
//	printf("read nand ops OK...\n");
	return 0;
}

int mynand_write(int argc,char **argv)
{
	u32 ram=0,flash=0,len=0;
	u8 m_s_flag=0, ecc_flag=0;
	char *dst=NULL;
	if(argc<5){
		printf("args error...\n");
		printf("uargs:write_nand <ramaddr>  <flashaddr>  <len>  <flag>\n");
		printf("uargs:flag = (m/M(main),s/S(spare),a/A(main+spare))\n");
		printf("example:write_nand 0xa1000000  0x0  0x20000 m\n");
		return -1;
	}
	if(!strncmp(argv[4],"m",1) || !strncmp(argv[4],"M",1)){m_s_flag=0;}		//main区
	else if(!strncmp(argv[4],"s",1) || !strncmp(argv[4],"S",1)){m_s_flag=1;}	//备用区
	else if(!strncmp(argv[4],"a",1) || !strncmp(argv[4],"A",1)){m_s_flag=2;}	//main+备用区
	else{m_s_flag=0;}
	ram = strtoul(argv[1],0,0);	//将要写到NAND Flash中的，暂存在内存中的数据首地址？
	flash = strtoul(argv[2],0,0);	//写入的NAND Flash起始地址？
	len = strtoul(argv[3],0,0);	//写入长度
	ecc_flag = strtoul(argv[5],0,0);	//ecc flag
//	printf("ram==0x%08x,flash==0x%08x\n",ram,flash,len,flag);
	printf(" dbg  mynand_write...\r\n");
	write_nand(ram, flash, len, m_s_flag,ecc_flag);
//	printf("write nand ops OK...\n");
	return 0;
}
static void mynand_init(int argc,char **argv) // ???????
{
//  u32 param = 0;
    u8  ecc_flag =0;

	if(argc!=2){
		printf("args error...\n");
    }
    ecc_flag = strtoul(argv[2],0,0);
//    sd_config[61] = nand_use_pad, as sdram[31:16] && nand pins reused on 1c verification board
    *((volatile unsigned int *)0xbfd00414) |= (1 << 29); //
if(ecc_flag == 0)
  {
    #ifdef NAND_2k_page      // 2k page
    	NAND_WL(PARAM, 0x8005000);	//NAND parameter 1Gbit op_scpoe= 0x800
    #else
      #ifdef NAND_512_page    // 512B page
    	NAND_WL(PARAM, 0x2005c00);	//NAND parameter 512Mbit op_scpoe= 0x100
    #else
      #ifdef NAND_4k_page     // 4k page
    	NAND_WL(PARAM, 0x10005400);	//NAND parameter 16Gbit op_scpoe= 0x2000
    #endif  
    #endif  
    #endif  
  }
  else
  {
    #ifdef NAND_2k_page      // 2k page
    	NAND_WL(PARAM, 0x7f81000);	//NAND parameter 1Gbit op_scpoe= 204x10 =0x800
    #else
      #ifdef NAND_512_page    // 512B page
    	NAND_WL(PARAM, 0x1981c00);	//NAND parameter 512Mbit op_scpoe= 204x2 = 0x198
    #else
      #ifdef NAND_4k_page     // 4k page
    	NAND_WL(PARAM, 0xff01400);	//NAND parameter 16Gbit op_scpoe= 204x20 = 0xff0
    #endif  
    #endif  
    #endif  
  }
}

static const Cmd Cmds[] =
{
	{"MyCmds"},
	{"init_nand","",0,"nand_init",mynand_init,0,99,CMD_REPEAT},
	{"erase_nand","val",0,"NANDFlash OPS:erase_nand <startblock> <blocks>",mynand_erase,0,99,CMD_REPEAT},
	{"read_nand","val",0,"NANDFlash OPS:read_nand <ramaddr>  <flashaddr>  <len>  <flag(a/A/m/M/s/S)> <flag_ecc>",mynand_read,0,99,CMD_REPEAT},
	{"write_nand","val",0,"NANDFlash OPS:write_nand <ramaddr>  <flashaddr>  <len>  <flag(a/A/m/M/s/S)> <flag_ecc>",mynand_write,0,99,CMD_REPEAT},
	{0, 0}
};

static void init_cmd __P((void)) __attribute__ ((constructor));
static void init_cmd()
{
	cmdlist_expand(Cmds, 1);
}

