#include <pmon.h>

#define LCD_DEBUG 1
#ifdef LCD_DEBUG
void exdelay(void);                     
void lcd_putchar(unsigned int c);           
void putstr(unsigned char *s);     
unsigned char *getchinesecodepos(unsigned int ac);
unsigned char *getenglishcodepos(unsigned char ac);
void putimage(unsigned char *s);   
void putsizeimage(unsigned char XSIZE,unsigned char YSIZE,unsigned char *s);

void point(int b);
void lcd_line(unsigned char x0,unsigned char y0,unsigned char x1,unsigned char y1,int b);
void lcd_lineto(unsigned char x1,unsigned char y1,int b);
void lcd_rect(unsigned char x0,unsigned char y0,unsigned char x1,unsigned char y1,int b);
void lcdfill(unsigned char d);
void lcdpos(void);
void lcdreset(void);
void lcdwd(unsigned char d);            //送图形数据子程序
unsigned char lcdrd(void);              //读图形数据子程序
void lcdwc(unsigned char c);            //送指令子程序
void lcdwaitidle(void);                 //忙检测子程序

void lcdwd1(unsigned char d);           //送图形数据子程序
unsigned char lcdrd1(void);             //读图形数据子程序
void lcdwc1(unsigned char c);           //送指令子程序
void lcdwaitidle1(void);                //忙检测子程序
void lcdwd2(unsigned char d);           //送图形数据子程序
unsigned char lcdrd2(void);             //读图形数据子程序
void lcdwc2(unsigned char c);           //送指令子程序
void lcdwaitidle2(void);                //忙检测子程序
//-------------------------------------------------------------------------------
//SMG12864A产品引脚说明及演示连线
//PIN1: VSS  [电源地]
//PIN2: VDD  [电源正极]
//PIN3: Vo   [LCD偏压输入]
//PIN4: RS   [数据/命令选择端 1:数据 0:命令]
//PIN5: RW   [读写信号选择端 1:读操作 0:写操作]
//PIN6: E    [使能信号输入 高有效]
//PIN7: DB0  [Data I/O]
//PIN8: DB1  [Data I/O]
//PIN9: DB2  [Data I/O]
//PIN10:DB3  [Data I/O]
//PIN11:DB4  [Data I/O]
//PIN12:DB5  [Data I/O]
//PIN13:DB6  [Data I/O]
//PIN14:DB7  [Data I/O]
//PIN15:CS1  [片选1信号输入 高有效]
//PIN16:CS2  [片选2信号输入 高有效]
//PIN17:RST  [复位信号输入(H：正常工作,L:复位)]
//PIN18:VEE  [LCD驱动负压输出(-5V)]
//PIN19:BLA  [背光源正极]
//PIN20:BLK  [背光源负极]
//注:8031的晶振频率为12MHz.
//请参见http://download.sunman.cn/lcm/product/1/SMG12864A.pdf
//-------------------------------------------------------------------------------
//以下为产品接口引脚在演示程序中的预定义
//用户在编写应用程序时,需按自己的实际硬件连线来重新定义
//以下CS(P2.7)=1
/*
 * read status:		RS=L, R/W=H, CS1 CS2=H, E=H
 * write command:	RS=L, R/W=L, D0~D7=command code, CS1 CS2=H, E=H
 * read data:		RS=H, R/W=H, CS1 CS2=H, E=H
 * write data:		RS=H, R/W=L, D0~D7=data, CS1 CS2=H, E=H
 */
#define  LCDC1RREG   *((volatile char *)0xbe000402)
#define  LCDC1WREG   *((volatile char *)0xbe000400)

#define  LCDC2RREG   *((volatile char *)0xbe000602)
#define  LCDC2WREG   *((volatile char *)0xbe000600)

#define  LCDD1RREG   *((volatile char *)0xbe000403)
#define  LCDD1WREG   *((volatile char *)0xbe000401)

#define  LCDD2RREG   *((volatile char *)0xbe000603)
#define  LCDD2WREG   *((volatile char *)0xbe000601)

static volatile char *mmio = 0;

#define GPIO_DATA_LOW		(volatile unsigned int *)(mmio + 0x10000)
#define GPIO_DATA_HIGH		(volatile unsigned int *)(mmio + 0x10004)
#define GPIO_DIR_LOW 		(volatile unsigned int *)(mmio + 0x10008)
#define GPIO_DIR_HIGH 		(volatile unsigned int *)(mmio + 0x1000c)

#define G_OUTPUT		1
#define G_INPUT			0

#define GPIO_E_SHIFT		34
#define	GPIO_RW_SHIFT		31
#define GPIO_CS1_SHIFT		45
#define GPIO_CS2_SHIFT		36
#define	GPIO_RS_SHIFT		29

#define GPIO_DATA_START		16
#define GPIO_DATA_END		23

#define BITS_PER_INT		32


//#define LCD_CALL_DEBUG		1
#ifndef LCD_CALL_DEBUG
#define ENTER()
#define EXIT()
#else
#define ENTER()			do{printf("-->Enter %s\n", __func__);}while(0)
#define EXIT()			do{printf("<--Exit %s\n", __func__);}while(0)
#endif

int read_cp0()
{
	int count;
	*(volatile int *)0xbfc00000;
	asm("mfc0 %0, $9\t":"=r"(count));
	*(volatile int *)0xbfc00000;
	return count;
}

void udelay(int us)
{
	int count;
	*(volatile char *)0xbfc00000;
	count = read_cp0();
	while((read_cp0() - count) < 0x100*us ); 
}

static void lcd_sleep(int ntime)
{
	int i,j=0;
	for(i=0; i<300*ntime; i++)
	{
		j=i;
		j+=i;
	}
}


void lcd_dir(int bit, int ivalue)
{
	int tmp;
	volatile unsigned int *dir_reg;
	if(bit >= BITS_PER_INT/*32*/)
	{
		bit -= BITS_PER_INT;
		dir_reg = GPIO_DIR_HIGH;
	}
	else
	{
		dir_reg = GPIO_DIR_LOW;
	}
	tmp = *dir_reg;
	if(ivalue == 1)
		*dir_reg = tmp|(0x1 << bit);
	else
		*dir_reg = tmp&(~(0x1<<bit));
}


void lcd_bit(int bit, int ivalue)
{
	int tmp;
	volatile unsigned int *data_reg;
	if(bit >= BITS_PER_INT/*32*/)
	{
		bit -= BITS_PER_INT;
		data_reg = GPIO_DATA_HIGH;
	}
	else
	{
		data_reg = GPIO_DATA_LOW;
	}
	
	tmp = *data_reg;
	if(ivalue == 1)
		*data_reg = tmp|(0x1<<bit);
	else
		*data_reg = tmp&(~(0x1<<bit));
}

void lcd_data_dir(int rw)
{
	int i;

	for(i = GPIO_DATA_START; i <= GPIO_DATA_END; i++)
	{
		lcd_dir(i, G_OUTPUT);
	}
}

void lcd_write_data(char c)
{
	int i, j, bit_data;

	for(i = GPIO_DATA_START, j = 0; i <= GPIO_DATA_END; i++, j++)
	{
		bit_data = (c&(0x1 << j)) ? 1: 0;
		lcd_bit(i, bit_data);
	}
}
//-------------------------------------------------------------------------------
//以下XPOS,YPOS变量用于指示当前操作点的位置的预定义
//用户在编写应用程序时,需按自己的实际软件程序需要来重新定义
unsigned char XPOS;                     //列方向LCD点阵位置指针
unsigned char YPOS;                     //行方向LCD点阵位置指针
int CharImageReverse;                   //字符及图形的反显控制,0(正常显示),1(反显)

#define XDOTS   128                     //图形空间X方向大小
#define YDOTS   64                      //图形空间X方向大小
//-------------------------------------------------------------------------------
//以下为精简版中英文字库
//实际使用时请包含由Sunman精简版中英文字符库代码生成器.exe自动生成的charlib.c文
//文件来替换该部分
#define ENGLISHCHARNUMBER  5       //精简版英文字符库中的英文字符的个数
#define CHINESECHARNUMBER  5       //精简版中文字符库中的中文字符的个数
#define ENGLISHCHARSIZE    8       //英文字符X方向显示点的个数
#define CHINESECHARSIZE    16      //中文字符X方向及中英文字符Y方向显示点的个数
#define ENGLISHCHARDOTSIZE 16      //单个英文字符点阵的字节数
#define CHINESECHARDOTSIZE 32      //单个中文字符点阵的字节数

unsigned int EnglishCode[]={
	0x41,    //字符001:[A]
	0x4d,    //字符002:[M]
	0x4e,    //字符003:[N]
	0x53,    //字符004:[S]
	0x55     //字符005:[U]
};

unsigned int ChineseCode[]={
	0x90ade5,	//字符001:[子]
	0xaaa4e5,	//字符002:[太]
	0xb398e9,	//字符003:[阳]
	0xb594e7,	//字符004:[电]
	0xbabae4	//字符005:[人]
};

unsigned char EnglishCharDot[]={
	0x00,0x20,0x00,0x3c,0xc0,0x23,0x38,0x02,   //字符001:[A]
	0xe0,0x02,0x00,0x27,0x00,0x38,0x00,0x00,
	0x08,0x20,0xf8,0x3f,0xf8,0x00,0x00,0x3f,   //字符002:[M]
	0xf8,0x00,0xf8,0x3f,0x08,0x20,0x00,0x00,
	0x08,0x20,0xf8,0x3f,0x30,0x20,0xc0,0x00,   //字符003:[N]
	0x00,0x07,0x08,0x18,0xf8,0x3f,0x00,0x00,
	0x00,0x00,0x70,0x38,0x88,0x20,0x08,0x21,   //字符004:[S]
	0x08,0x21,0x08,0x22,0x38,0x1c,0x00,0x00,
	0x08,0x00,0xf8,0x1f,0x08,0x20,0x00,0x20,   //字符005:[U]
	0x00,0x20,0x08,0x20,0xf8,0x1f,0x00,0x00
};

unsigned char ChineseCharDot[]={
	0x00,0x01,0x00,0x01,0x02,0x01,0x02,0x01,   //字符005:[子]
	0x02,0x01,0x02,0x41,0x02,0x81,0xe2,0x7f,
	0x12,0x01,0x0a,0x01,0x06,0x01,0x02,0x01,
	0x00,0x01,0x80,0x01,0x00,0x01,0x00,0x00,
	0x00,0x00,0x10,0x80,0x10,0x40,0x10,0x20,   //字符003:[太]
	0x10,0x10,0x10,0x0c,0x10,0x03,0xff,0x08,
	0x10,0x71,0x10,0x22,0x10,0x04,0x10,0x18,
	0x10,0x30,0x10,0xe0,0x10,0x40,0x00,0x00,
	0x00,0x00,0xfe,0xff,0x02,0x04,0x22,0x08,   //字符004:[阳]
	0x5a,0x04,0x86,0x03,0x00,0x00,0xfe,0x3f,
	0x42,0x10,0x42,0x10,0x42,0x10,0x42,0x10,
	0x42,0x10,0xfe,0x3f,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0xf8,0x0f,0x48,0x04,   //字符001:[电]
	0x48,0x04,0x48,0x04,0x48,0x04,0xff,0x3f,
	0x48,0x44,0x48,0x44,0x48,0x44,0x48,0x44,
	0xf8,0x4f,0x00,0x40,0x00,0x70,0x00,0x00,
	0x00,0x00,0x00,0x40,0x00,0x20,0x00,0x10,   //字符002:[人]
	0x00,0x0c,0x00,0x03,0xc0,0x00,0x3f,0x00,
	0xc2,0x01,0x00,0x06,0x00,0x0c,0x00,0x18,
	0x00,0x30,0x00,0x60,0x00,0x20,0x00,0x00,
};
//-------------------------------------------------------------------------------
//以下为图片库点阵代码
//实际使用时请包含由SUNMAN图形点阵代码生成器.EXE自动生成的imagelib.c文件来替换该
//部分
unsigned char Img_sunman_32[]={32,32,
	0x00,0xf0,0x0f,0x00,
	0x00,0xfe,0x7f,0x00,
	0x80,0x0f,0xf6,0x01,
	0xc0,0x03,0xc6,0x03,
	0xe0,0x70,0x0e,0x07,
	0x70,0x7c,0x3e,0x0e,
	0x38,0x7f,0xfe,0x1c,
	0x9c,0x7f,0xfe,0x39,
	0xcc,0x7f,0xfe,0x33,
	0xce,0x7f,0xfe,0x73,
	0xe6,0x7f,0xfe,0x67,
	0xe6,0x07,0xe0,0x67,
	0xf3,0x07,0xe0,0xcf,
	0xf3,0xcf,0xff,0xcf,
	0x73,0x9e,0xff,0xcf,
	0x33,0x3c,0xff,0xcf,
	0x33,0x3c,0xff,0xcf,
	0x73,0x9e,0xff,0xcf,
	0xf3,0xcf,0xff,0xcf,
	0xf3,0x07,0xe0,0xcf,
	0xe6,0x07,0xe0,0x67,
	0xe6,0x7f,0xfe,0x67,
	0xce,0x7f,0xfe,0x73,
	0xcc,0x7f,0xfe,0x33,
	0x9c,0x7f,0xfe,0x39,
	0x38,0x7f,0xfe,0x1c,
	0x70,0x7c,0x3e,0x0e,
	0xe0,0x70,0x0e,0x07,
	0xc0,0x63,0xc0,0x03,
	0x80,0x6f,0xf0,0x01,
	0x00,0xfe,0x7f,0x00,
	0x00,0xf0,0x0f,0x00
};

//-------------------------------------------------------------------------------
void lcd_test(void)                     //演示程序
{
	//0.演示前的准备,将LCD液晶显示全部清空
	CharImageReverse=0;                 //反显关闭
	lcdfill(0x0);                         //清屏

	//1.图片测试: 在(8,16)位置显示32点阵SUNMAN图标
	XPOS=8;
	YPOS=16;
	putimage(Img_sunman_32);            //写数据到当前LCDRAM地址中
	//udelay(0x10000000);
	//2.字符串测试: 在(56,16)位置显示"SUNMAN"字符串.
	XPOS=56;
	YPOS=16;
	putstr("SUNMAN");
	//udelay(0x10000000);

	//3.字符串测试: 在(40,32)位置显示"太阳人电子"字符串.
	XPOS=40;
	YPOS=32;
	putstr("太阳人电子");
	//exdelay();                          //延时约600mS
	
	//4.反显测试: 在(40,32)位置反显"太阳人电子"字符串.
	XPOS=40;
	YPOS=32;
	CharImageReverse=1;
	putstr("太阳人电子");
	CharImageReverse=0;
	//udelay(0x10000000);
	
	//5.绘图测试: RECT(6,14)-(122,50),画矩形.
	lcd_rect(6,14,122,50,1);
	//udelay(0x10000000);

	//6.绘图测试: POINT(6,52),画点.
	XPOS=6;
	YPOS=52;
	point(1);
	//udelay(0x10000000);

	//7.绘图测试: LINE(6,52)-(63,63),画线.
	lcd_line(6,52,63,63,1);
	//udelay(0x10000000);

	//8.绘图测试: lcd_lineto(122,52),画线.
	lcd_lineto(122,52,1);
	//udelay(0x10000000);

	//9.绘图测试: lcd_lineto(6,52),画线.
	lcd_lineto(6,52,1);
	//udelay(0x10000000);

	//13.全屏测试: 所有坐标点全部显示.
	//lcdfill(0xff);                      //全显
	//udelay(0x10000000);
}
void exdelay(void)//演示延时子程序
{ 
	unsigned char i,j,k;                  //延时约600mS
	for(i=0;i<200;i++)
		for(j=0;j<64;j++)
			for(k=0;k<100;k++);
}
//-------------------------------------------------------------------------------
//以下lcd_putchar为字符对象的基本子程序,putstr为字符对象的扩充子程序,getchinesecodepos,
//getenglishcodepos为字符对象的辅助子程序.
//-------------------------------------------------------------------------------
//子程序名称:void lcd_putchar(unsigned int c).
//功能:在(XPOS,YPOS)位置写单个字符点阵,若c>128 表示为中文字符,否则为西文字符
//修改日期:2009.8.18
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void lcd_putchar(unsigned int c)            //定位写字符子程序
{   
	ENTER();
	if(c>128)
	{
		putsizeimage(CHINESECHARSIZE,CHINESECHARSIZE,getchinesecodepos(c));
	}
	else
	{
		putsizeimage(ENGLISHCHARSIZE,CHINESECHARSIZE,getenglishcodepos(c));
	}
	EXIT();
}
//-------------------------------------------------------------------------------
//子程序名称:void putstr(unsigned char code *s).
//功能:写字符串点阵,若*s=0 表示字符串结束.
//修改日期:2009.8.18
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void putstr(unsigned char *s)      //显示字符串子程序,字符码为0时退出
{   
	unsigned int c;

	while(1)
	{   c=*s;
		s++;
		if(c==0) break;
		if(c<128)
			lcd_putchar(c);
		else
		{   lcd_putchar(c+(*s)*256+(*(s+1))*256*256);
			s+=2;
		}
	}
}
//-------------------------------------------------------------------------------
//子程序名称:unsigned char code *getchinesecodepos(unsigned char ac).
//功能:根据当前中文字符码查表后计算得到当前中文字符码的字库点阵位置.
//修改日期:2009.8.18
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
unsigned char *getchinesecodepos(unsigned int ac)
{   
	unsigned int min,max,mid,midc;
	min=0;
	max=CHINESECHARNUMBER-1;
	ENTER();
	while(1)
	{   
		if(max-min<2)
		{   if(ChineseCode[min]==ac)
			mid=min;
			else if(ChineseCode[max]==ac)
				mid=max;
			else
				mid=0;
			break;
		}
		mid=(max+min)/2;
		midc=ChineseCode[mid];
		if(midc==ac)
			break;
		else if(midc>ac)
			max=mid-1;
		else
			min=mid+1;
	}
	return ChineseCharDot+mid*CHINESECHARDOTSIZE;
}
//-------------------------------------------------------------------------------
//子程序名称:unsigned char code *getenglishcodepos(unsigned char ac).
//功能:根据当前ASCII字符码查表后计算得到当前ASCII字符码的字库点阵位置.
//修改日期:2009.8.18
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
unsigned char *getenglishcodepos(unsigned char ac)
{  
	unsigned char min,max,mid,midc;
	ENTER();
	min=0;
	max=ENGLISHCHARNUMBER-1;
	while(1)
	{   if(max-min<2)
		{   if(EnglishCode[min]==ac)
			mid=min;
			else if(EnglishCode[max]==ac)
				mid=max;
			else
				mid=0;
			break;
		}
		mid=(max+min)/2;
		midc=EnglishCode[mid];
		if(midc==ac)
			break;
		else if(midc>ac)
			max=mid-1;
		else
			min=mid+1;
	}
	return EnglishCharDot+mid*ENGLISHCHARDOTSIZE;
	EXIT();
}
//-------------------------------------------------------------------------------
//以下putsizeimage为图形对象的基本子程序,putimage为图形对象的扩充子程序
//-------------------------------------------------------------------------------
//子程序名称:void putsizeimage(unsigned char XSIZE,unsigned YSIZE,
//                             unsigned char code *s)
//功能:在(XPOS,YPOS)位置绘制XSIZE列及YISZE行点阵的图形*S.
//修改日期:2009.8.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void putsizeimage(unsigned char XSIZE,unsigned char YSIZE,unsigned char *s)
{  
	unsigned char k,lx,ly,a1,a2,y,Lcd_Mask;
	
	k=YPOS&0x7;
	YSIZE+=k;
	y=YPOS;
	s--;
	for(lx=0;lx<XSIZE;lx++,XPOS++)
	{  
		for(YPOS=y,ly=k;ly<YSIZE;)
		{  
			unsigned char p;
			a1=*s;
			s++;
			a2=*s;
			if(CharImageReverse)
			{   
				a1=~a1;
				a2=~a2;
			}
			for(p=0;p<k;p++)
			{  
				a2>>=1;
				if((a1&0x1)==1)
					a2+=0x80;
				a1>>=1;
			}
			if((k==0) && (YSIZE<ly+8))
			{   
				lcdpos();
				ly+=8;
				YPOS+=8;
			}
			else
			{   
				lcdpos();
				a1=lcdrd();
				lcdpos();
				ly+=8;
				YPOS+=8;
				Lcd_Mask=0xff;
				p=YSIZE&0x7;
				while(p>0)
				{   
					Lcd_Mask>>=1;
					YPOS--;
					p--;
				}
				p=0xff;
				while(YSIZE<ly)
				{   
					ly--;
					YPOS--;
					p<<=1;
				}
				Lcd_Mask&=p;
				a2&=Lcd_Mask;
				a2|=a1&(~Lcd_Mask);
			}
			lcdwd(a2);
		}
		if((k!=0) && (YSIZE&0x7 != 0) && (k >= YSIZE&0x7)) s--;
	}
	YPOS=y;
}
//-------------------------------------------------------------------------------
//子程序名称:void putimage(unsigned char code *s).
//功能:在(XPOS,YPOS)位置绘制XSIZE[*s]列及YISZE[*(s+1)]行点阵的图形[*(s+2)].
//修改日期:2009.8.18
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void putimage(unsigned char *s)    //显示图形子程序
{   
	unsigned char XSIZE,YSIZE;
	ENTER();
	XSIZE=*s;
	s++;
	YSIZE=*s;
	s++;
	putsizeimage(XSIZE,YSIZE,s);
	EXIT();
}
//-------------------------------------------------------------------------------
//以下point为绘图操作的基本子程序,lcd_line,lcd_lineto,lcd_rect为绘图操作的扩充子程序.
//-------------------------------------------------------------------------------
//子程序名称:void point(bit b).
//功能:按b的数据在(XPOS,YPOS)位置绘制点.
//修改日期:2009.8.18
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void point(int b)
{  
	unsigned char i,Lcd_Mask,j;
	ENTER();
	Lcd_Mask=0x01;
	i=YPOS&0x7;
	while(i>0)
	{   
		Lcd_Mask<<=1;
		i--;
	}
	lcdpos();
	j=lcdrd();
	lcdpos();
	if(b)
		lcdwd(j|Lcd_Mask);
	else
		lcdwd(j&(~Lcd_Mask));
	EXIT();
}
//-------------------------------------------------------------------------------
//子程序名称:void lcd_line(unsigned char x0,unsigned char y0,unsigned char x1,unsigned char y1,bit b)
//功能:按b的数据绘制(x0,y0)-(x1,y1)的直线
//修改日期:2009.8.18
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void lcd_line(unsigned char x0,unsigned char y0,unsigned char x1,unsigned char y1,int b)
{   
	unsigned char dx,dy;
	unsigned int dk;
	XPOS=x0;
	YPOS=y0;
	point(b);
	dx=(x1>=x0)?x1-x0:x0-x1;
	dy=(y1>=y0)?y1-y0:y0-y1;
	if(dx==dy)
	{   while(XPOS!=x1)
		{   if(x1>x0) XPOS++;else XPOS--;
			if(y1>y0) YPOS++;else YPOS--;
			point(b);
		}
	}
	else if (dx>dy)
	{   dk=dy;
		dy=0;
		while(XPOS!=x1)
		{   if(x1>x0) XPOS++;else XPOS--;
			dy++;
			if(y1>y0) YPOS=y0+(dk*dy+dx/2)/dx;else YPOS=y0-(dk*dy+dx/2)/dx;
			point(b);
		}
	}
	else
	{   dk=dx;
		dx=0;
		while(YPOS!=y1)
		{   if(y1>y0) YPOS++;else YPOS--;
			dx++;
			if(x1>x0) XPOS=x0+(dk*dx+dy/2)/dy;else XPOS=x0-(dk*dx+dy/2)/dy;
			point(b);
		}
	}
}
//-------------------------------------------------------------------------------
//子程序名称:void lcd_lineto(unsigned char x1,unsigned char y1,bit b)
//功能:按b的数据绘制(XPOS,YPOS)-(x1,y1)的直线
//修改日期:2009.8.18
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void lcd_lineto(unsigned char x1,unsigned char y1,int b)//绘制(XPOS,YPOS)-(X1,Y1)的直线
{   
	lcd_line(XPOS,YPOS,x1,y1,b);
}
//-------------------------------------------------------------------------------
//子程序名称:void lcd_rect(unsigned char x0,unsigned char y0,unsigned char x1,unsigned char y1,bit b)
//功能:按b的数据绘制(x0,y0)-(x1,y1)的矩形
//修改日期:2009.8.18
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void lcd_rect(unsigned char x0,unsigned char y0,unsigned char x1,unsigned char y1,int b)
{   
	lcd_line(x0,y0,x1,y0,b);
	lcd_line(x1,y0,x1,y1,b);
	lcd_line(x1,y1,x0,y1,b);
	lcd_line(x0,y1,x0,y0,b);
}
//-------------------------------------------------------------------------------
//以下lcdfill,lcdpos,lcdreset为KS0108B型硬件接口的12864液晶显示模块的基本子程序
//-------------------------------------------------------------------------------
//子程序名称:void lcdfill(unsigned char d).
//功能:整屏显示d表示的字节数据.
//修改日期:2009.08.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void lcdfill(unsigned char d)           //整屏显示d代表的字节数据子程序
{   
	unsigned char j;
	
	for(YPOS=0;YPOS<64;YPOS+=8)         //8页
	{   XPOS=0;
		lcdpos();
		for(j=0;j<64;j++)              //64列
			lcdwd1(d);                 //送图形数据
		XPOS=64;
		lcdpos();
		for(j=0;j<64;j++)              //64列
			lcdwd2(d);                 //送图形数据
	}
	XPOS=0;
	YPOS=0;
}
//-------------------------------------------------------------------------------
//子程序名称:void lcdpos(void).
//功能:设置坐标点(XPOS,YPOS)位置对应的内部RAM地址.
//修改日期:2009.08.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void lcdpos(void)                       //设置坐标点(XPOS,YPOS)内部RAM地址的子程序
{
	if(XPOS<64)
	{   
		lcdwc1(0xB8|((YPOS/8)&0x7));     //页地址设置
		lcdwc1(0x40|XPOS);               //列地址设置
	}
	else
	{   
		lcdwc2(0xB8|((YPOS/8)&0x7));     //页地址设置
		lcdwc2(0x40|(XPOS&0x3F));        //列地址设置
	}
}
//-------------------------------------------------------------------------------
//子程序名称:void lcdreset(void)
//功能:液晶显示控制器初始化
//修改日期:2009.08.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void lcdreset(void)                     //液晶显示控制器初始化子程序
{
	lcdwc1(0xC0);                       //设置显示初始行
	exdelay();
	lcdwc1(0x3F);                       //开显示
	exdelay();
	lcdwc2(0xC0);                       //设置显示初始行
	exdelay();
	lcdwc2(0x3F);                       //开显示
	exdelay();
}
//-------------------------------------------------------------------------------
//以下lcdwc1,lcdwc2,lcdwd,lcdrd为MCS51总线接口的KS0108B液晶显示控制器的基本
//子程序,lcdwd1,lcdwd2,lcdrd1,lcdrd2,lcdwaitidle1,lcdwaitidle2为内部子程序.
//-------------------------------------------------------------------------------
//子程序名称:unsigned char lcdrd(void).
//功能:从液晶显示控制器中读图形数据.
//修改日期:2009.08.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
unsigned char lcdrd(void)
{
	unsigned char d;
	return 0;
	if(XPOS<64)
	{    d=lcdrd1();
		d=lcdrd1();
	}
	else
	{    d=lcdrd2();
		d=lcdrd2();
	}
	return d;
}
//-------------------------------------------------------------------------------
//子程序名称:void lcdwd(unsigned char d).
//功能:向液晶显示控制器写图形数据.
//修改日期:2009.08.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void lcdwd(unsigned char d)
{   
	if(XPOS<64){
		lcdwd1(d);
	}
	else{
		lcdwd2(d);
	}
}
//-------------------------------------------------------------------------------
//子程序名称:void lcdwd1(unsigned char c).
//功能:向液晶显示控制器1写图形数据.
//修改日期:2009.08.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void gpio_wd(int lcd, unsigned char c)
{
	int CS = ((lcd == 1) ? GPIO_CS1_SHIFT : GPIO_CS2_SHIFT);

	lcd_dir(GPIO_E_SHIFT, G_OUTPUT);
	lcd_dir(GPIO_RW_SHIFT, G_OUTPUT);
	lcd_dir(GPIO_RS_SHIFT, G_OUTPUT);
	lcd_dir(CS, G_OUTPUT);
	lcd_data_dir(G_OUTPUT);
	
	lcd_bit(GPIO_RS_SHIFT, 0);
	lcd_bit(CS, 0);
	lcd_bit(GPIO_E_SHIFT, 0);
	lcd_bit(GPIO_RW_SHIFT, 1);
	udelay(1);

	lcd_write_data(c);
	udelay(1);

	lcd_bit(GPIO_RW_SHIFT, 0);
	lcd_bit(GPIO_RS_SHIFT, 1);
	lcd_bit(CS, 1);
	udelay(1);
	
	lcd_bit(GPIO_E_SHIFT, 1);
	udelay(1);
	
	lcd_bit(GPIO_E_SHIFT, 0);
	udelay(1);

	lcd_bit(GPIO_RW_SHIFT, 1);
	lcd_bit(GPIO_RS_SHIFT, 0);
	lcd_bit(CS, 0);
	udelay(1);
}

void lcdwd1(unsigned char d)
{
	lcdwaitidle1();
	gpio_wd(1, d);
}
//-------------------------------------------------------------------------------
//子程序名称:void lcdwd2(unsigned char d).
//功能:向液晶显示控制器2写图形数据.
//修改日期:2009.08.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void lcdwd2(unsigned char d)
{ 
	lcdwaitidle2();
	gpio_wd(2, d);
}
//-------------------------------------------------------------------------------
//子程序名称:unsigned char lcdrd1(void).
//功能:从液晶显示控制器1中读图形数据.
//修改日期:2009.08.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
unsigned char lcdrd1(void)              //读图形数据子程序
{
	lcdwaitidle1();                     //检测液晶显示控制器是否空闲
	return LCDD1RREG;
}
//-------------------------------------------------------------------------------
//子程序名称:unsigned char lcdrd2(void).
//功能:从液晶显示控制器2中读图形数据.
//修改日期:2009.08.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
unsigned char lcdrd2(void)              //读图形数据子程序
{
	lcdwaitidle2();                     //检测液晶显示控制器是否空闲
	return LCDD2RREG;
}

void gpio_wc(int lcd, unsigned char c)
{
	int CS = ((lcd == 1) ? GPIO_CS1_SHIFT : GPIO_CS2_SHIFT);

	lcd_dir(GPIO_E_SHIFT, G_OUTPUT);
	lcd_dir(GPIO_RW_SHIFT, G_OUTPUT);
	lcd_dir(GPIO_RS_SHIFT, G_OUTPUT);
	lcd_dir(CS, G_OUTPUT);
	lcd_data_dir(G_OUTPUT);
	
	lcd_bit(GPIO_E_SHIFT, 0);
	lcd_bit(GPIO_RW_SHIFT, 1);
	lcd_bit(GPIO_RS_SHIFT, 1);
	lcd_bit(CS, 0);
	udelay(1);

	lcd_write_data(c);
	udelay(1);

	lcd_bit(GPIO_RW_SHIFT, 0);
	lcd_bit(GPIO_RS_SHIFT, 0);
	lcd_bit(CS, 1);
	udelay(1);
	
	lcd_bit(GPIO_E_SHIFT, 1);
	udelay(1);
	
	lcd_bit(GPIO_E_SHIFT, 0);
	udelay(1);

	lcd_bit(GPIO_RW_SHIFT, 1);
	lcd_bit(CS, 0);
	lcd_bit(GPIO_RS_SHIFT, 1);
	udelay(1);
}
//-------------------------------------------------------------------------------
//子程序名称:lcdwc1(unsigned char c).
//功能:向液晶显示控制器1送指令.
//修改日期:2009.08.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void lcdwc1(unsigned char c)            //向液晶显示控制器1送指令
{   
	udelay(1);
	gpio_wc(1, c);
}
//-------------------------------------------------------------------------------
//子程序名称:lcdwc2(unsigned char c).
//功能:向液晶显示控制器2送指令.
//修改日期:2009.08.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void lcdwc2(unsigned char c)            //向液晶显示控制器2送指令
{   
	udelay(1);
	gpio_wc(2, c);
}
//-------------------------------------------------------------------------------
//子程序名称:voidlcdwaitidle1(void).
//功能:忙检测,在对液晶显示控制器操作的每一条指令之前,需检测液晶显示器是否空闲.
//修改日期:2009.08.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void lcdwaitidle1(void)                 //控制器1忙检测子程序
{   
	ENTER();
	udelay(1);
	EXIT();
//	while( (LCDC1RREG&0x80) != 0x0 );  //D7=0 空闲退出
}
//-------------------------------------------------------------------------------
//子程序名称:voidlcdwaitidle2(void).
//功能:忙检测,在对液晶显示控制器操作的每一条指令之前,需检测液晶显示器是否空闲.
//修改日期:2009.08.31
//修改人:chujianjun@sunman.cn,tanchao@sunman.cn
//-------------------------------------------------------------------------------
void lcdwaitidle2(void)                 //控制器2忙检测子程序
{   
	udelay(1);
	//while((LCDC2RREG&0x80) != 0x0);   //D7=0 空闲退出
}
#endif

int cmd_testlcd()
{
	unsigned long tag;
	static int inited=0;
	
	if(!inited)
	{
		tag=_pci_make_tag(0,14,0);

		mmio = (volatile char *)_pci_conf_readn(tag,0x14,4);
		mmio =(volatile char *)((int)mmio|(0xb0000000));
		inited = 1;
		printf("%s: tag = 0x%x, mmio = %p\n", __func__, tag, mmio);
	}

	printf("Testing lcd");
	lcdreset();                     //初始化液晶显示控制器
	lcd_test();
	while(1)
	{
		printf(".");
	}
	return(0);
}

static const Cmd Cmds[] =
{
	{"MyCmds"},
	{"testlcd",	"", 0, "test sm502 lcd using gpio", cmd_testlcd, 0, 99, CMD_REPEAT},
	{0, 0}
};

static void init_cmd __P((void)) __attribute__ ((constructor));

static void
init_cmd()
{
	cmdlist_expand(Cmds, 1);
}
