#include <pmon.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <target/i2c.h>

#define CAMERA_BASE 0xbc280000
#define DMA0_CONFIG 0x0
#define DMA1_CONFIG 0x8
#define DMA2_CONFIG 0x10
#define DMA3_CONFIG 0x18
#define PIX_CONFIG  0x20
#define UOFF_CONFIG 0x28
#define VOFF_CONFIG 0x30
#define CAMIF_CONFIG    0x38
#define CAM_MEM_BASE    0xa1800000  //the same as frambuffer base
#define OV9650_ADDRESS 0x60
//#define CATCH_PICS
#define I2C_CLOCK		400000		/* Hz. max 400 Kbits/sec */

/* registers */
#define OCI2C_PRELOW		0
#define OCI2C_PREHIGH		1
#define OCI2C_CONTROL		2
#define OCI2C_DATA		3
#define OCI2C_CMD		4 /* write only */
#define OCI2C_STATUS		4 /* read only, same address as OCI2C_CMD */

#define OCI2C_CTRL_IEN		0x40
#define OCI2C_CTRL_EN		0x80

#define OCI2C_CMD_START		0x90
#define OCI2C_CMD_STOP		0x40
#define OCI2C_CMD_READ		0x20
#define OCI2C_CMD_WRITE		0x10
#define OCI2C_CMD_READ_ACK	0x20
#define OCI2C_CMD_READ_NACK	0x28
#define OCI2C_CMD_IACK		0x00

#define OCI2C_STAT_IF		0x01
#define OCI2C_STAT_TIP		0x02
#define OCI2C_STAT_ARBLOST	0x20
#define OCI2C_STAT_BUSY		0x40
#define OCI2C_STAT_NACK		0x80


#define	MISC_CTRL		0xbfd00424

#define nr_strtol strtoul
/*
 * User tuned register setting values
 */
static unsigned char ov9650_init_reg[][2] = {  //  2010-12-16 kim 
{0xfe,0x00},
{0x0f,0x00},
{0x01,0x6a},
{0x02,0x70},
{0x05,0x00},
{0x06,0x00},
{0x07,0x00},
{0x08,0x00},
{0x09,0x01},
{0x0a,0xe8},
{0x0b,0x02},
{0x0c,0x88},
{0x0d,0x02},
{0x0e,0x02},
{0x10,0x26},
{0x11,0x0d},
{0x12,0x2a},
{0x13,0x00},
{0x14,0x11},// urbetter
{0x15,0x0a},
{0x16,0x05},
{0x17,0x01},
{0x18,0x44},
{0x19,0x44},
{0x1a,0x2a},
{0x1b,0x00},
{0x1c,0x49},
{0x1d,0x9a},
{0x1e,0x61},
{0x20,0xff},
{0x21,0xfa},
{0x22,0x57},
//{0x24,0xa2},//0xa0},
{0x25,0x0f},
{0x26,0x02},//0x03}, // 0x01
{0x2f,0x01},
{0x30,0xf7},
{0x31,0x50},
{0x32,0x00},
{0x39,0x04},
{0x3a,0x20},
{0x3b,0x20},
{0x3c,0x00},
{0x3d,0x00},
{0x3e,0x00},
{0x3f,0x00},
{0x50,0x16}, // 0x14
{0x53,0x80},
{0x54,0x87},
{0x55,0x87},
{0x56,0x80},
{0x8b,0x10},
{0x8c,0x10},
{0x8d,0x10},
{0x8e,0x10},
{0x8f,0x10},
{0x90,0x10},
{0x91,0x3c},
{0x92,0x50},
{0x5d,0x12},
{0x5e,0x1a},
{0x5f,0x24},
{0x60,0x07},
{0x61,0x15},
{0x62,0x0f}, // 0x08
{0x64,0x01},  // 0x03
{0x66,0xe8},
{0x67,0x86},
{0x68,0xa2},
{0x69,0x18},
{0x6a,0x0f},
{0x6b,0x00},
{0x6c,0x5f},
{0x6d,0x8f},
{0x6e,0x55},
{0x6f,0x38},
{0x70,0x15},
{0x71,0x33},
{0x72,0xdc},
{0x73,0x80},
{0x74,0x02},
{0x75,0x3f},
{0x76,0x02},
{0x77,0x57}, // 0x47
{0x78,0x88},
{0x79,0x81},
{0x7a,0x81},
{0x7b,0x22},
{0x7c,0xff},
{0x93,0x46},
{0x94,0x00},
{0x95,0x03},
{0x96,0xd0},
{0x97,0x40},
{0x98,0xf0},
{0xb1,0x3c},
{0xb2,0x3c},
{0xb3,0x44}, //0x40
{0xb6,0xe0},
{0xbd,0x3C},
{0xbe,0x36},
{0xd0,0xC9},
{0xd1,0x10},
{0xd2,0x90},
{0xd3,0x90},
{0xd5,0xF2},
{0xd6,0x10},
{0xdb,0x92},
{0xdc,0xA5},
{0xdf,0x23},
{0xd9,0x00},
{0xda,0x00},
{0xe0,0x09},
{0xed,0x04},
{0xee,0xa0},
{0xef,0x40},
{0x80,0x03},
{0x9F,0x14},
{0xA0,0x28},
{0xA1,0x44},
{0xA2,0x5d},
{0xA3,0x72},
{0xA4,0x86},
{0xA5,0x95},
{0xA6,0xb1},
{0xA7,0xc6},
{0xA8,0xd5},
{0xA9,0xe1},
{0xAA,0xea},
{0xAB,0xf1},
{0xAC,0xf5},
{0xAD,0xFb},
{0xAE,0xFe},
{0xAF,0xFF},
{0xc0,0x00},
{0xc1,0x14},
{0xc2,0x21},
{0xc3,0x36},
{0xc4,0x49},
{0xc5,0x5B},
{0xc6,0x6B},
{0xc7,0x7B},
{0xc8,0x98},
{0xc9,0xB4},
{0xca,0xCE},
{0xcb,0xE8},
{0xcc,0xFF},
{0xf0,0x02},
{0xf1,0x01},
{0xf2,0x04},
{0xf3,0x30},
{0xf9,0x9f},
{0xfa,0x78},
{0xfe,0x01},
{0x00,0xf5},
{0x02,0x20},
{0x04,0x10},
{0x05,0x10},
{0x06,0x20},
{0x08,0x15},
{0x0a,0xa0},
{0x0b,0x64},
{0x0c,0x08},
{0x0e,0x4C},
{0x0f,0x39},
{0x10,0x41},
{0x11,0x37},
{0x12,0x24},
{0x13,0x39},
{0x14,0x45},
{0x15,0x45},
{0x16,0xc2},
{0x17,0xA8},
{0x18,0x18},
{0x19,0x55},
{0x1a,0xd8},
{0x1b,0xf5},
{0x70,0x40},
{0x71,0x58},
{0x72,0x30},
{0x73,0x48},
{0x74,0x20},
{0x75,0x60},
{0x77,0x20},
{0x78,0x32},
{0x30,0x03},
{0x31,0x40},
{0x32,0x10},
{0x33,0xe0},
{0x34,0xe0},
{0x35,0x00},
{0x36,0x80},
{0x37,0x00},
{0x38,0x04},
{0x39,0x09},
{0x3a,0x12},
{0x3b,0x1C},
{0x3c,0x28},
{0x3d,0x31},
{0x3e,0x44},
{0x3f,0x57},
{0x40,0x6C},
{0x41,0x81},
{0x42,0x94},
{0x43,0xA7},
{0x44,0xB8},
{0x45,0xD6},
{0x46,0xEE},
{0x47,0x0d},
{0xfe,0x00}, 
};
#define OV9650_INIT_REGS	(sizeof(ov9650_init_reg) / sizeof(ov9650_init_reg[0]))    

unsigned char ov9650_data1[][2] = {
    {0x00, 0x00},
    {0x00, 0xa2},
    {0x00, 0x0f},
    {0x00, 0x02},
};

unsigned char ov9650_windows_640[][2] = {
    {0x05,0x00},
    {0x06,0x00},
    {0x07,0x00},
    {0x08,0x00},
    {0x09,0x01},
    {0x0a,0xe8},
    {0x0b,0x02},
    {0x0c,0x88},
};

unsigned char ov9650_output_888[][2] = {
    {0x20,0x00},
    {0x21,0x00},
    {0x22,0x00},
    {0x24,0xb8},
    {0x29,0x83},
    {0xd2,0x10},
};

unsigned char ov9650_Data[][2]            = { {0x24,0x00}, };
unsigned char ov9650_output_RGB[][2]      = { {0x24,0xa6}, };
unsigned char ov9650_output_yuv0[][2]     = { {0x24,0xa2}, };
unsigned char ov9650_output_yuv1[][2]     = { {0x24,0xa3}, };
unsigned char ov9650_output_yuv2[][2]     = { {0x24,0xa1}, };
unsigned char ov9650_output_yuv3[][2]     = { {0x24,0xa0}, };
unsigned char ov9650_paddrv[][2]          = { {0x1f,0x33}, };
unsigned char ov9650_syncmode[][2]        = { {0x26,0xf7}, }; // 0xbf by liusu
unsigned char ov9650_syncmode1[][2]       = { {0x26,0xf7}, }; // 0xbf by liusu
unsigned char ov9650_output_en[][2]       = { {0x25,0xff}, };
unsigned char ov9650_windows_2_page1[][2] = { {0xfe,0x01}, };
unsigned char ov9650_windows_2_page0[][2] = { {0xfe,0x00}, };
unsigned char ov9650_windows_2_qvga[][2]  = { {0x54,0x22}, };
unsigned char ov9650_windows_2_vga[][2]   = { {0x54,0x11}, };


static unsigned int i2c_base = 0xbfe58000;

typedef unsigned long  u32;
typedef unsigned short u16;
typedef unsigned char  u8;
typedef signed long  s32;
typedef signed short s16;
typedef signed char  s8;

#define writeb(val, addr) (*(volatile u8*)(addr) = (val))
#define writew(val, addr) (*(volatile u16*)(addr) = (val))
#define writel(val, addr) (*(volatile u32*)(addr) = (val))
#define readb(addr) (*(volatile u8*)(addr))
#define readw(addr) (*(volatile u16*)(addr))
#define readl(addr) (*(volatile u32*)(addr))

/***************************************************************************
 * Description:
 * Parameters: 
 * Author  :Sunyoung_yg 
 * Date    : 2014-12-25
 ***************************************************************************/
struct ls1x_i2c
{
	unsigned int base;
};

struct i2c_msg
{
	u16 addr;
	u16 flags;
#define I2C_M_RD 0x0001
	u16 len;
	u8  *buf;
};

static void udelay(int us)
{
int count0,count1;
int debug=0;
us *= 10; //CPU_COUNT_PER_US;
asm volatile("mfc0 %0,$23;li $2,0x2000000;or $2,%0;mtc0 $2,$23;":"=r"(debug)::"$2");
asm volatile("mfc0 %0,$9":"=r"(count0)); 
do{
asm volatile("mfc0 %0,$9":"=r"(count1)); 
}while(count1 -count0<us);
asm volatile("mtc0 %0,$23;"::"r"(debug));
}


static inline void i2c_writeb(struct ls1x_i2c *i2c, int reg, u8 value)
{
	writeb(value, i2c->base + reg);
}

static inline u8 i2c_readb(struct ls1x_i2c *i2c, int reg)
{
	return readb(i2c->base + reg);
}

void i2c_wb(unsigned int reg, unsigned char val)
{
	printf(" enter i2c_wb....\r\n");
	*(volatile unsigned char *)(i2c_base + reg) = val;
	printf(" out i2c_wb....\r\n");

}

unsigned char i2c_rb(unsigned char reg)
{
	return *(volatile unsigned char *)(i2c_base + reg);
}

/*
 * Poll the i2c status register until the specified bit is set.
 * Returns 0 if timed out (100 msec).
 */
static short ls1x_poll_status(struct ls1x_i2c *i2c, unsigned long bit)
{
	int loop_cntr = 10000;

	do {
		udelay(10);
	} while ((i2c_readb(i2c, OCI2C_STATUS) & bit) && (--loop_cntr > 0));
	return (loop_cntr > 0);
}

static int ls1x_xfer_read(struct ls1x_i2c *i2c, unsigned char *buf, int length) 
{
	int x;
	for (x=0; x<length; x++) {
		/* send ACK last not send ACK */
		if (x != (length -1)) 
			i2c_writeb(i2c, OCI2C_CMD, OCI2C_CMD_READ_NACK); //dbg-yg   NACK test for ov9650 camera, 
		else
			i2c_writeb(i2c, OCI2C_CMD, OCI2C_CMD_READ_NACK);
		if (!ls1x_poll_status(i2c, OCI2C_STAT_TIP)) {
			return -1;
		}
		unsigned char c;
		c = i2c_readb(i2c, OCI2C_DATA);
		*buf++ = c; 
	}
	i2c_writeb(i2c,OCI2C_CMD, OCI2C_CMD_STOP);
		
	return 0;
}

static int ls1x_xfer_write(struct ls1x_i2c *i2c, unsigned char *buf, int length)
{
	int x;

	for (x=0; x<length; x++) {
	//	printk("dbg-yg write buf[%d]:0x%x...\r\n", x, *buf);
		i2c_writeb(i2c, OCI2C_DATA, *buf++);
		i2c_writeb(i2c, OCI2C_CMD, OCI2C_CMD_WRITE);
		if (!ls1x_poll_status(i2c, OCI2C_STAT_TIP)) {
			return -1;
		}

	}
	i2c_writeb(i2c, OCI2C_CMD, OCI2C_CMD_STOP);

	return 0;
}

static int ls1x_xfer(struct ls1x_i2c *i2c, struct i2c_msg *pmsg, int num)
{
	int i, ret;
	int j;
	for (i = 0; i < num; i++) {

		if (!ls1x_poll_status(i2c, OCI2C_STAT_BUSY)) {
			return -1;
		}

		i2c_writeb(i2c, OCI2C_DATA, (pmsg->addr << 1)
			| ((pmsg->flags & I2C_M_RD) ? 1 : 0));
		i2c_writeb(i2c, OCI2C_CMD, OCI2C_CMD_START);

		/* Wait until transfer is finished */
		if (!ls1x_poll_status(i2c, OCI2C_STAT_TIP)) {
			return -1;  //dbg-yg
		}

 		if (pmsg->flags & I2C_M_RD)
			ret = ls1x_xfer_read(i2c, pmsg->buf, pmsg->len);
  		else
			ret = ls1x_xfer_write(i2c, pmsg->buf, pmsg->len);
		if (ret)
			return ret;
		pmsg++;
	}
	return i;
}


static void ls1x_i2c_hwinit(struct ls1x_i2c *i2c)
{
	struct clk *clk;
	int prescale;
	u8 ctrl = i2c_readb(i2c, OCI2C_CONTROL);

	/* make sure the device is disabled */
	i2c_writeb(i2c, OCI2C_CONTROL, ctrl & ~(OCI2C_CTRL_EN|OCI2C_CTRL_IEN));

	prescale = 0x141;
	i2c_writeb(i2c, OCI2C_PRELOW, prescale & 0xff);
	i2c_writeb(i2c, OCI2C_PREHIGH, prescale >> 8);

	/* Init the device */
	i2c_writeb(i2c, OCI2C_CMD, OCI2C_CMD_IACK);
	i2c_writeb(i2c, OCI2C_CONTROL, ctrl | OCI2C_CTRL_IEN | OCI2C_CTRL_EN);
}


/***************************************************************************
 * Description:
 * Parameters: 
 * Author  :Sunyoung_yg 
 * Date    : 2014-12-25
 ***************************************************************************/


void init_i2c0(void)
{
	i2c_wb(0, 0x41);
	i2c_wb(1, 0x01);
	i2c_wb(2, 0xc0);
}

int camera_read(int argc,char **argv)
{
      unsigned char i;
      unsigned char reg,data = 0xa;
       unsigned char dev_add[2];
       unsigned char read_buf;
	struct ls1x_i2c i2c;
	i2c.base = 0xbfe58000;
	struct i2c_msg msg = {
		.addr = 0x30,
		.flags= 0x0,
		.len  = 1,
		.buf  = &data,
	};
	ls1x_i2c_hwinit(&i2c);
#if 0
	i2c_wb(3, 0x60);//addr  write
	i2c_wb(4, 0x90);//start & write

	if (!ls1x_poll_status(&i2c, OCI2C_STAT_TIP)) {
		printf(" poll error!!! write addr\r\n\r\n");
		return -1;  //dbg-yg
	}

	i2c_wb(3, 0x0a);
	i2c_wb(4, 0x10); //write
	if (!ls1x_poll_status(&i2c, OCI2C_STAT_TIP)) {
		printf(" poll error!!! write reg\r\n\r\n");
		return -1;  //dbg-yg
	}
	i2c_wb(4, 0x40); //stop




	i2c_wb(3, 0x61);//addr  read
	i2c_wb(4, 0x90);//start & write
	if (!ls1x_poll_status(&i2c, OCI2C_STAT_TIP)) {
		printf(" poll error!!! write addr\r\n\r\n");
		return -1;  //dbg-yg
	}
	i2c_wb(4, 0x28);// read & nack
	data = i2c_rb(3);

	i2c_wb(4, 0x40); //stop
#endif
#if 1
	ls1x_xfer(&i2c, &msg, 1);

	msg.flags = I2C_M_RD;

	ls1x_xfer(&i2c, &msg, 1);
#endif 	
	printf(" read data is :0x%02x ...\r\n", data);

#if 0
//	i2c_wb(3, 0x60);//addr
//	i2c_wb(4, 0x90);//start
	

	*dev_add = OV9650_ADDRESS;
	   
         if(argc == 2)
           data= 1;
          else
           data= (unsigned char)nr_strtol(argv[2],0,0);
   
		  reg = (unsigned char)nr_strtol(argv[1],0,0);
           for (i=0; i<data; i++)
             {
              tgt_i2cread1(I2C_SINGLE, dev_add, 1, reg,&read_buf, 1);
              printf("addr: 0x%x,data =0x%x\n",reg,read_buf);
              reg++;
             }
#endif
          return 0;
 }

int camera_set(int argc,char **argv)
 {
     unsigned char reg,data;
    unsigned char dev_add[2];
    *dev_add = OV9650_ADDRESS;
     if(argc != 3)
     {
       printf("should be 2 arguments. [register] [data].failed\n");
       return -1;
     }
     reg = (unsigned char)nr_strtol(argv[1],0,0);
     data = (unsigned char)nr_strtol(argv[2],0,0);\
     printf("reg is 0x%x,data is 0x%x\n",reg,data);
     tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, reg, &data, 1);
     printf("OK\n");
     return 0;

}
int set_ov9650_config(unsigned int res, unsigned int yuv)
{
	unsigned char i;
	unsigned char dev_add[2];
	unsigned char read_buf1[1];
	*dev_add = OV9650_ADDRESS;

	for(i = 0; i < OV9650_INIT_REGS; i++ ) 
		tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_init_reg[i][0], ov9650_init_reg[i]+1, 1);     

	tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_windows_2_page1[0][0], ov9650_windows_2_page1[0]+1, 1);     
	if(res==33||res==36)
		tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_windows_2_qvga[0][0], ov9650_windows_2_qvga[0]+1, 1);     
	else
		tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_windows_2_vga[0][0], ov9650_windows_2_vga[0]+1, 1);     
	tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_windows_2_page0[0][0], ov9650_windows_2_page0[0]+1, 1);     

	for(i = 0 ; i < 8; i++)
		tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_windows_640[i][0], ov9650_windows_640[i]+1, 1);     

	if(yuv==0) tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_output_yuv0[0][0], ov9650_output_yuv0[0]+1, 1);
	else if(yuv==1) tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_output_yuv1[0][0], ov9650_output_yuv1[0]+1, 1); 
	else if(yuv==2) tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_output_yuv2[0][0], ov9650_output_yuv2[0]+1, 1); 
	else if(yuv==3) tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_output_yuv3[0][0], ov9650_output_yuv3[0]+1, 1); 
	else            tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_output_RGB [0][0], ov9650_output_RGB [0]+1, 1); 

	tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_paddrv[0][0], ov9650_paddrv[0]+1, 1);    
	//tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_syncmode[0][0], ov9650_syncmode[0]+1, 1);
	if(res==33)
	{tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_syncmode[0][0], ov9650_syncmode[0]+1, 1);}
	else 
	{tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_syncmode1[0][0], ov9650_syncmode1[0]+1, 1);}
	tgt_i2cwrite1(I2C_SINGLE, dev_add, 1, ov9650_output_en[0][0], ov9650_output_en[0]+1, 1);     
	//printf("yuv=%d, set ov9650 config ok\n", yuv);

	//tgt_i2cread1(I2C_SINGLE,dev_add,1,0x24,read_buf,1);
	//printf("cam_reg @ 0x24, data = 0x%x\n", *read_buf);

	tgt_i2cread1(I2C_SINGLE,dev_add,1,0x24,read_buf1+0,1);
	printf("cam_reg @ 0x24, data = 0x%x\n", read_buf1[0]);

	return 0;
}
void camera_test()
{
    unsigned char i;
    unsigned char dev_add[2];
    unsigned char read_buf[4];
    *dev_add = OV9650_ADDRESS;

    for (i=0; i<4; i++)
    {
        tgt_i2cread1(I2C_SINGLE, dev_add, 1, ov9650_data1[i][0], read_buf+i, 1);
    }

    printf("read data from ov9650: \n");
    for (i=0; i<4; i++)
        printf (" 0x%x, ", read_buf[i]);
    printf ("\n");
}

unsigned char get_camera_type()
{
    unsigned char read_buf;
    unsigned char dev_add[2];
    *dev_add = OV9650_ADDRESS;
    tgt_i2cread1(I2C_SINGLE,dev_add,1,ov9650_Data[0][0],read_buf,1);
    return read_buf;
}

int cameraif_init(unsigned int res, unsigned int yuv)
{
    unsigned int value;
    unsigned int yuv_value;
    unsigned int cam_config;
    unsigned int reg_cam_config;
    value = 0;
    yuv_value = 0;
    /**(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG) = value;
    if(*(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG)==0x0)
              printf("camera init is ready for use....\n");
    else { while (*(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG)!=0x40000000) ;
              // *(volatile unsigned int*)(0xbfd00414)&=0xefffffff;
              // *(volatile unsigned int*)(0xbfd00414)|=0x10000000;
          }*/
    *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG)= value;
    cam_config = *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG);
    reg_cam_config = cam_config & 0x40000000;
    if(reg_cam_config == 0x40000000)
    {
      *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG) = cam_config | 0x3fffffff;
      
    }
    cam_config = *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG);
    reg_cam_config = cam_config & 0x40000000;
    if(reg_cam_config == 0x0)
      printf("camera init is ready for use....\n");
    else {
             while (*(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG)!=0x40000000) ;
         }    

    
    //printf("start camera init\n");
    *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG) = 0;
      if(res==63){
         *(volatile unsigned int *)(CAMERA_BASE + DMA0_CONFIG) = (CAM_MEM_BASE &0x0fffffff);
         *(volatile unsigned int *)(CAMERA_BASE + DMA1_CONFIG) = (CAM_MEM_BASE &0x0fffffff)+640;
         *(volatile unsigned int *)(CAMERA_BASE + DMA2_CONFIG) = (CAM_MEM_BASE &0x0fffffff)+640*480;
         *(volatile unsigned int *)(CAMERA_BASE + DMA3_CONFIG) = (CAM_MEM_BASE &0x0fffffff)+640*480+640;
        // *(volatile unsigned int *)(0xbfd00414) &= 0xffcfffff;
         *(volatile unsigned int *)(0xbfd00414) |= 0x200000;
    }
    else  if(res==33){
         *(volatile unsigned int *)(CAMERA_BASE + DMA0_CONFIG) = (CAM_MEM_BASE &0x0fffffff)+640*240+320;
         *(volatile unsigned int *)(CAMERA_BASE + DMA1_CONFIG) = (CAM_MEM_BASE &0x0fffffff)+640*240+320;
         *(volatile unsigned int *)(CAMERA_BASE + DMA2_CONFIG) = (CAM_MEM_BASE &0x0fffffff)+640*240+320;
         *(volatile unsigned int *)(CAMERA_BASE + DMA3_CONFIG) = (CAM_MEM_BASE &0x0fffffff)+640*240+320;
         *(volatile unsigned int *)(0xbfd00414) |= 0x200000;
    }
    else{ 
         *(volatile unsigned int *)(CAMERA_BASE + DMA0_CONFIG) = (CAM_MEM_BASE &0x0fffffff);
         *(volatile unsigned int *)(CAMERA_BASE + DMA1_CONFIG) = (CAM_MEM_BASE &0x0fffffff);
         *(volatile unsigned int *)(CAMERA_BASE + DMA2_CONFIG) = (CAM_MEM_BASE &0x0fffffff);
         *(volatile unsigned int *)(CAMERA_BASE + DMA3_CONFIG) = (CAM_MEM_BASE &0x0fffffff);
       //  *(volatile unsigned int *)(0xbfd00414) &= 0xffcfffff;
        *(volatile unsigned int *)(0xbfd00414) |= 0x200000;
    }
    if(res==33||res==63)
       *(volatile unsigned int *)(CAMERA_BASE + UOFF_CONFIG) = 640;
    else
       *(volatile unsigned int *)(CAMERA_BASE + UOFF_CONFIG) = 0;
    //*(volatile unsigned int *)(CAMERA_BASE + VOFF_CONFIG) = 320;

     //printf("uoff_set= 0x%x, res=%d\n",*(volatile unsigned int*)(0xbc280028), (unsigned int)(res));
/*
    camera enable        [31]
    output data format   [13]
    input data format    [11]
    resolution           [7]
    yuv input format     [4]
    rgb input format     [2]
    hsync level setting  [1]
    vsync level setting  [0]

*/    
      if(yuv!=0xf0) yuv_value = ((yuv&(0x0000000f)) <<4)|0x800;
      else yuv_value = 0;

           if(res==66) value = (1 << 31) |(1 << 13) | (0 << 9) | (1 << 7) | yuv_value;
      else if(res==63) value = (1 << 31) |(1 << 13) | (1 << 9) | (1 << 7) | yuv_value;
      else if(res==33) value = (1 << 31) |(1 << 13) | (0 << 9) | (0 << 7) | yuv_value;
      else if(res==36) value = (1 << 31) |(1 << 13) | (3 << 9) | (0 << 7) | yuv_value;

      printf("CAM config register 0x%x\n",value);
      //printf("yuv_value for CAM config register 0x%x\n",yuv_value);

    *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG) = value;
     #ifdef CATCH_PICS
     { 
      while ( ( (*(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG))&0xf00000)!=0x700000) ;
            *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG) = 0;
      printf("Pics capture ok\n");
      }
     #endif
     /*
      if(res==36)
      {
      while ( ( (*(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG))&0xf00000)==0x000000) ;
            *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG) = 0;
      }
     */
   //   *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG) = value;
   // *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG) |= 0x80000000;
      return 0;
}

int camera_run(int argc,char **argv)
  {
      unsigned int data;
      unsigned int yuv;
      unsigned int cam_cfg_38;
      unsigned int reg_cfg;
         if(argc == 1){
             printf("Zero param: default rgb and res at 640-> 640\n");
             data= 0;
             yuv = 0xf0;
             }
         else if(argc == 2){
             printf("One param:default rgb, 0: 640-> 640, 1: 640-> 320, 2: 320-> 320, 3: 320-> 640!\n");
             data= (unsigned int)nr_strtol(argv[1],0,0);
             yuv = 0xf0;
             }
         else{ 
             printf("First param 0: 640-> 640, 1: 640-> 320, 2: 320-> 320, 3: 320-> 640!\n");
             printf("Secnd param 0: YCbYcr,    1: YCrYCb,    2: CrYCbY,    3: CbYCrY!   \n");
             data= (unsigned int)nr_strtol(argv[1],0,0);
             yuv = (unsigned int)nr_strtol(argv[2],0,0);
             }

           if(data==1) {
             printf("Res_in_out = 640 -> 320, yuv_mode=%d \n",yuv);
             set_ov9650_config(63,yuv);
             cameraif_init(63,yuv);
            /* cam_cfg_38 = *(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG);
             reg_cfg = cam_cfg_38 & 0x10000000;
             while(reg_cfg == !0x10000000)
             {
               cam_cfg_38 = *(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG);
             }
             printf("buffer is full:");
             set_ov9650_config(66,yuv);
             cameraif_init(66,yuv);*/

           }
           else if(data==2){
             printf("Res_in_out = 320 -> 320, yuv_mode=%d \n",yuv);
             set_ov9650_config(33,yuv);
             cameraif_init(33,yuv);
            /* cam_cfg_38 = *(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG);
             reg_cfg = cam_cfg_38 & 0x10000000;
             while(reg_cfg == !0x10000000)
             {
               cam_cfg_38 = *(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG);
             }
             printf("buffer is full:");
             set_ov9650_config(66,yuv);
             cameraif_init(66,yuv);*/
           }
           else if(data==3) {
             printf("Res_in_out = 320 -> 640 , yuv_mode=%d \n",yuv);
             set_ov9650_config(36,yuv);
             cameraif_init(36,yuv);
           }
           else {
             printf("Default: res_in_out = 640 -> 640, yuv_mode=%d \n", yuv);
             set_ov9650_config(66,yuv);
             cameraif_init(66,yuv);
             /*cam_cfg_38 = *(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG);
             reg_cfg = cam_cfg_38 & 0x10000000;
             while(reg_cfg == !0x10000000)
             {
               cam_cfg_38 = *(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG);
             }
             printf("buffer is full:\n");
             set_ov9650_config(66,yuv);
             cameraif_init(66,yuv);*/
               
           } 

        /*cam_cfg_38 = *(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG); 

         while((cam_cfg_38 & 0xf00000) != 0x100000 ) 
         {
            cam_cfg_38 = *(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG); 
         }
        *(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG) = (cam_cfg_38 & 0x0); 
         printf("camera run 1 frame \n");*/
          return 0;

 }

void camera_color() 
{
    unsigned int i;
    for(i = 8 ; i < 640*120*2; i+=4)
    {
        *(volatile unsigned int*)(CAM_MEM_BASE + i)= *(volatile unsigned int*)(0xa1800000); 
    }    
    for(i = 640*120*2 ; i < 640*240*2; i+=4)
    {
        *(volatile unsigned int*)(CAM_MEM_BASE + i)= *(volatile unsigned int*)(0xa1800004); 
    }
    for(i = 640*240*2 ; i < 640*360*2; i+=4)
    {
        *(volatile unsigned int*)(CAM_MEM_BASE + i)= ~(*(volatile unsigned int*)(0xa1800004)); 
    }
    for(i = 640*360*2 ; i < 640*480*2; i+=4)
    {
        *(volatile unsigned int*)(CAM_MEM_BASE + i)= ~(*(volatile unsigned int*)(0xa1800000)); 
    }
}

void cam_run_frame(int argc,char **argv)
{
      unsigned int data;
      unsigned int yuv;
      unsigned int cam_cfg_38;

         if(argc == 1){
             printf("Zero param: default rgb and res at 640-> 640\n");
             data= 0;
             yuv = 0xf0;
             }
         else if(argc == 2){
             printf("One param:default rgb, 0: 640-> 640, 1: 640-> 320, 2: 320-> 320, 3: 320-> 640!\n");
             data= (unsigned int)nr_strtol(argv[1],0,0);
             yuv = 0xf0;
             }
         else{ 
             printf("First param 0: 640-> 640, 1: 640-> 320, 2: 320-> 320, 3: 320-> 640!\n");
             printf("Secnd param 0: YCbYcr,    1: YCrYCb,    2: CrYCbY,    3: CbYCrY!   \n");
             data= (unsigned int)nr_strtol(argv[1],0,0);
             yuv = (unsigned int)nr_strtol(argv[2],0,0);
             }

     camera_run(data,yuv);    

        cam_cfg_38 = *(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG); 

  while((cam_cfg_38 & 0xf00000) != 0x100000 ) 
         {
        cam_cfg_38 = *(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG); 
         }
        *(volatile unsigned int*)(CAMERA_BASE + CAMIF_CONFIG) = (cam_cfg_38 & 0x0); 

    printf("camera run 1 frame \n");
}


static const Cmd Cmds[] =
 {
      {"MyCmds"},
      {"cam_rd",   "[register] [num] ", 0, "read ov9650",  camera_read, 0, 99, CMD_REPEAT},
      {"cam_set",  "[register] [data]", 0, "write ov9650", camera_set,  0, 99, CMD_REPEAT},
      {"cam_run",  "[data]     [yuv] ", 0, "camera_run",   camera_run,  0, 99, CMD_REPEAT},
      {"camera_color","",0,"camera_color",camera_color,0,99,CMD_REPEAT},
      {"camera_test","",0,"camera_test",camera_test,0,99,CMD_REPEAT},
      {"cam_run_frame","[data] [yuv] ", 0,"cam_run_frame",cam_run_frame,0,99,CMD_REPEAT},
      {0,0}
  };

static void init_cmd __P((void)) __attribute__ ((constructor));

static void init_cmd()
{
	cmdlist_expand(Cmds, 1);
}


