#include <pmon.h>
#include <linux/types.h>
#define udelay delay

#define writel(val, addr) (*(volatile u32*)(addr) = (val))
#define readl(addr) (*(volatile u32*)(addr))

#define APB_BASE	0xbfe40000
#define ACPI_BASE	0x3c000+APB_BASE
#define GEN_PMCON_1 ACPI_BASE+0x30
#define GEN_PMCON_2 ACPI_BASE+0x34
#define GEN_PMCON_3 ACPI_BASE+0x38
#define PM1_STS		ACPI_BASE+0x0
#define PM1_EN		ACPI_BASE+0x4
#define PM1_CNT		ACPI_BASE+0x8
#define PM1_TMR		ACPI_BASE+0xc
#define PROC_CNT	ACPI_BASE+0x10

#define GPE_STS		ACPI_BASE+0x20
#define GPE_EN		ACPI_BASE+0x24


static unsigned long wakeup_state_address = 0xa01FFC00;

void read_gmac(int argc, char **argv)
{

	int i=0,temp1=3,temp=0;

	
	sscanf(argv[1], "%d", &temp1);
	for(i = 0; i <= 0xd8; i=i+4){
		if(temp1 == 0){
			temp = *(volatile int *)(0xbfe10000 + i);
			printf("gmc%x[0x%x] = 0x%x\n",temp1,i,temp);}
		else if (temp1 == 1){
			temp = *(volatile int *)(0xbfe20000 + i);
			printf("gmc%x[0x%x] = 0x%x\n",temp1,i,temp);}

	}
	for(i = 0; i <= 0x54; i=i+4){
		if(temp1 == 0){
			temp = *(volatile int *)(0xbfe11000 + i);
			printf("gmc%x DMA[0x%x] = 0x%x\n",temp1,i,temp);}
		else if (temp1 == 1){
			temp = *(volatile int *)(0xbfe21000 + i);
			printf("gmc%x DMA[0x%x] = 0x%x\n",temp1,i,temp);}

	}
	
		

}
#if 1
void delay10(int time)
{	
	int i,j=0;

	for( i = 0; i < time; i ++)
		//printf("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\t");
	//printf("\n");
		while(j < 20000) j++;
}

#endif 

void read_phy(int argc,char **argv)
{

	unsigned int i=0,temp1=3,temp=0;
	
	sscanf(argv[1], "%d", &temp1);
	for(i = 0; i < 32; i++){
		if(temp1 == 0){
			
			*(unsigned volatile int *)0xbfe10010 = (0x180d + (i << 6));
			delay10(10);
			temp =  *(unsigned volatile int *)0xbfe10014;
			
			printf("phy%x[0x%x] = 0x%x\n",temp1,i,temp);}
		else if (temp1 == 1){
			*(unsigned volatile int *)0xbfe20010 = (0x180d + (i << 6));
			
			delay10(10);
			temp =  *(unsigned volatile int *)0xbfe20014;
			temp =  *(unsigned volatile int *)0xbfe20014;
			printf("phy%x[0x%x] = 0x%x\n",temp1,i,temp);}

	}
	for(i = 256; i <= 256 + 7; i++){
		if(temp1 == 0){
			delay10(10);
			*(volatile int *)0xbfe10014 = 0x100 + i - 256;
			delay10(10);
			*(volatile int *)0xbfe10010 = 0x1acf;
			delay10(10);
			*(volatile int *)0xbfe10010 = 0x1b4d;
			delay10(10);
			temp = *(volatile int *)0xbfe10014;

			printf("phy%x extend[0x%x] = 0x%x\n",temp1,i,temp);}
		else if (temp1 == 1){
			*(volatile int *)0xbfe20014 = 0x100 + i - 256;
			delay10(10);
			*(volatile int *)0xbfe20010 = 0x1acf;
			delay10(10);
			*(volatile int *)0xbfe20010 = 0x1b4d;
			delay10(10);
			temp = *(volatile int *)0xbfe20014;

			printf("phy%x extend[0x%x] = 0x%x\n",temp1,i,temp);}
	}
}




int  write_phy(int argc, char **argv)
{

	unsigned int temp=0,temp1=0,temp2=0,temp3=0;

	sscanf(argv[1], "%d", &temp1);
	sscanf(argv[2], "%d", &temp2);
	sscanf(argv[3], "%d", &temp3);

if (temp1 >= 256){
	*(volatile int *)0xbfe20014 = temp2;
			delay10(10);
	*(volatile int *)0xbfe20010 = 0x1b0f;
//	*(volatile int *)0xbfe20010 = 0xb0f;
			delay10(10);
	if (temp1 >= 256)
	*(volatile int *)0xbfe20014 = 0x8100 + temp1 - 256;
			delay10(10);
	*(volatile int *)0xbfe20010 = 0x1acf;
//	*(volatile int *)0xbfe20010 = 0xacf;
			delay10(10);
 /////////read phy/////////////////

	*(volatile int *)0xbfe20014 = 0x100 + temp1 - 256;
			delay10(10);
	*(volatile int *)0xbfe20010 = 0x1acf;
//	*(volatile int *)0xbfe20010 = 0xacf;
			delay10(10);
	*(volatile int *)0xbfe20010 = 0x1b4d;
//	*(volatile int *)0xbfe20010 = 0xb4d;
			delay10(10);
	temp = *(volatile int *)0xbfe20014;
			delay10(10);
	printf("================write-is=0x%x\n",temp);
	}
else
	{
	if(temp3 == 0){
		
		*(volatile int *)0xbfe10014 = temp2;
		*(volatile int *)0xbfe10010 = 0x180f + (temp1 << 6);
	//*(volatile int *)0xbfe20010 = 0x80f + (temp1 << 6);
	}else if(temp3 == 1){

		*(volatile int *)0xbfe20014 = temp2;
		*(volatile int *)0xbfe20010 = 0x180f + (temp1 << 6);
		}

	}
	return 0;

}




#if 1
extern int sb2f_drv_suspend();
extern int sb2f_drv_resume();
#endif 

extern int init_kbd();
extern int kbd_initialize(void);
extern int psaux_init(void);
#if  1 
int acpi_dc(int argc,char **argv)
{
    sb2f_drv_resume();
	return 0;
}
#endif
int acpi_kbd(int argc,char **argv)
{
	init_kbd();
	kbd_initialize();

    psaux_init();
	return 0;
}



int acpi_str(int argc,char **argv)
{
	u32 reg;
	unsigned long flags = 0;
	asm volatile(  
	"move	$8, %0\n\t"
	"la $9,	1f\n\t"
	"sw	$9, ($8)\n\t"
	"sw	$29, 4($8)\n\t"
	"sw	$30, 8($8)\n\t"
	"sw	$28, 12($8)\n\t"
	"sw	$16, 16($8)\n\t"
	"sw	$17, 20($8)\n\t"
    "sw	$18, 24($8)\n\t"
    "sw	$19, 28($8)\n\t"
    "sw	$20, 32($8)\n\t"
    "sw	$21, 36($8)\n\t"
	"sw	$22, 40($8)\n\t"
    "sw	$23, 44($8)\n\t"

    "sw	$26, 48($8)\n\t"//k0
    "sw	$27, 52($8)\n\t"//k1

    "sw	$2, 56($8)\n\t"//v0
    "sw	$3, 60($8)\n\t"//v1

	"mfc0	$9, $12\n\t"
	"mfc0	$10, $4\n\t"
	"sw	$9, 64($8)\n\t"
	"sw	$10, 68($8)\n\t"
	"b 2f\n\t"
	"nop\n\t"
	"1:"
	"li	$8, 0\n\t"
	"li	$9, 0xa0200000\n\t"
	"li	$10, 0xa2000000\n\t"
	"3:"
	"lw	$11,($9)\n\t"
	"addu	$8, $8, $11\n\t"
	"addiu $9, $9, 4\n\t"
	"bne	$9,$10,3b\n\t"
	"nop\n\t"
	"li $9, 0xa0100000\n\t"
	"sw $8, 0x4($9)\n\t"
	"nop\n\t"
	"li $9, 0x31\n\t"
	"li $8, 0xbfe48000\n\t"
	"sb $9, ($8)\n\t"
	"nop\n\t"
	"2:"
	:
	:"r" (wakeup_state_address)
	:"$8","$31","$9","$10","$11"
	);

	*(volatile int *)0xbff10204 = 0x40000000;
	reg = readl((void *)PM1_CNT);
	reg &= (7<<10);
	if(reg!=0)
		goto finish;
	/* Save wakeup_state to low memory*/
	printf("ACPI COPY CONTEXT\n");
	int i;
	volatile unsigned int *tmp1;
	volatile unsigned int tmp2;
	for(i=0;i<18;i++){
		tmp1 =  (unsigned int *)(wakeup_state_address+4*i);
		tmp2 =  *tmp1;
		printf("%x: %x\n ",tmp1, tmp2);
	}

	//local_irq_save(flags);
	/* Clear WAK_STS */
	reg = readl((void *)PM1_STS);
	reg |= (1<<15);
	writel(reg, (void *)PM1_STS);
	/* clear pm1_sts*/
	writel(0xffffffff,(void *)PM1_STS);
	/* get PM1A control */
	reg = readl((void *)PM1_CNT);
	/* Clear the SLP_EN and SLP_TYP fields */
	reg &= ~(15<<10);
	writel(reg, (void *)PM1_CNT);
	/* Insert the SLP_TYP bits */
	reg |= ((3+2)<<10);
	/* Write #1: write the SLP_TYP data to the PM1 Control registers */
	writel(reg, (void *)PM1_CNT);
	/* Insert the sleep enable (SLP_EN) bit */
	//reg |= (1<<13);
	/* Flush caches, as per ACPI specification */

    sb2f_drv_suspend();
	flushcache();
	/* Write #2: Write both SLP_TYP + SLP_EN */
	//writel(reg, (void *)PM1_CNT);
//	((void (*)(void))ioremap_nocache(0x1fc00480, 4)) ();
	printf("ACPI ENTER\n");
	asm volatile(
		"li	$8, 0\n\t"
		"li	$9, 0xa0200000\n\t"
		"li	$10, 0xa2000000\n\t"
		"4:"
		"lw	$11,($9)\n\t"
		"addu	$8, $8, $11\n\t"
		"addiu $9, $9, 4\n\t"
		"bne	$9,$10,4b\n\t"
		"nop\n\t"
		"li $9, 0xa0100000\n\t"
		"sw $8, ($9)\n\t"
		"nop\n\t"
		"li $9, 0x30\n\t"
		"li $8, 0xbfe48000\n\t"
		"sb $9, ($8)\n\t"
		"nop\n\t"
		"li	$26,	0xbfc00480\n\t"
		"jr	$26\n\t"
		"nop"
		:
		:
		:"$4","$5","$6","$7","$8","$9","$10","$11"
	);

	/* Wait until we enter sleep state */
	//do{}while(1);
	/*Hibernation should stop here and won't be executed any more*/

	/*=====================WAKE UP===========================*/
finish:
	//local_irq_restore(flags);
	printf("ACPI FINISH\n");
	//while(1);
	writel(-1, (void *)PM1_STS);
	writel(-1, (void *)GPE_STS);
	writel(0, (void *)PM1_CNT);
	sb2f_drv_resume();
	return 0;
}

static const Cmd Cmds[] =
{
	{"MyCmds"},
	{"acpi_str","",0,"acpi_str",acpi_str,0,99,CMD_REPEAT},
	{"write_phy","",0,"write_phy",write_phy,0,99,CMD_REPEAT},
	{"read_gmac","",0,"read_gmac",read_gmac,0,99,CMD_REPEAT},
	{"read_phy","",0,"read_phy",read_phy,0,99,CMD_REPEAT},
	{"acpi_dc","",0,"acpi_dc",acpi_dc,0,99,CMD_REPEAT},
	{"acpi_kbd","",0,"acpi_kbd",acpi_kbd,0,99,CMD_REPEAT},

	{0, 0}
};

static void init_cmd __P((void)) __attribute__ ((constructor));

static void
init_cmd()
{
	cmdlist_expand(Cmds, 1);
}

