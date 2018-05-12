#include <pmon.h>
#include <dev/pci/pcivar.h>
#include <fcntl.h>
static int mmio=0;
#define GPIO_DIR_REG 		(volatile unsigned int *)(mmio + 0x10008)
#define GPIO_DATA_REG		(volatile unsigned int *)(mmio + 0x10000)
#define G_OUTPUT		1
#define G_INPUT			0

#define GPIO_CONF_DONE	(1<<17)
#define GPIO_DCLK	(1<<18)
#define GPIO_nCONFIG	(1<<19)
#define GPIO_DATA	(1<<20)
#define GPIO_nSTATUS	(1<<21)

static int fpga_init()
{
pcitag_t tag;
int tmp;
		if(!mmio)
		{
		tag=_pci_make_tag(0,14,0);
	
		mmio = _pci_conf_readn(tag,0x14,4);
		mmio =(int)mmio|(0xb0000000);
		tmp = *(volatile int *)(mmio + 0x40);
		*(volatile int *)(mmio + 0x40) =tmp|0x40;
		
		}
	*GPIO_DATA_REG = (*GPIO_DATA_REG & ~GPIO_DCLK)| GPIO_nCONFIG|GPIO_DATA;
	*GPIO_DIR_REG =  (*GPIO_DIR_REG & ~( GPIO_CONF_DONE | GPIO_nSTATUS)) | GPIO_DCLK|GPIO_nCONFIG|GPIO_DATA;
	*GPIO_DATA_REG;
		return 0;
}

#include "rbf.c"
static int cmd_fpga(int argc,char **argv)
{
int fd;
unsigned char c;
unsigned int val0;
char *rbfname,buf[100];
fpga_init();
#define set_gpio(clk,val) *GPIO_DATA_REG = val0|((clk)?GPIO_DCLK:0)|((val)?GPIO_DATA:0);*GPIO_DATA_REG;

	sprintf(buf,"/dev/ram@0x%08x,0x%08x",rbf,sizeof(rbf));

	rbfname = argc>1? argv[1]:buf;

	fd = open(rbfname,O_RDONLY);
	printf("open file %s,fd=%d\n",rbfname,fd);
	printf("done=%d\n",!!(*GPIO_DATA_REG &GPIO_CONF_DONE));

		*GPIO_DATA_REG &= ~GPIO_nCONFIG;
		while(*GPIO_DATA_REG & GPIO_nSTATUS) delay(1);
		delay(10);
		*GPIO_DATA_REG |= GPIO_nCONFIG;
		*GPIO_DATA_REG;
		delay(10);
		while(*GPIO_DATA_REG & GPIO_nSTATUS == 0) delay(1);
		delay(1);

		val0 =  (*GPIO_DATA_REG & ~(GPIO_DCLK|GPIO_DATA)) | GPIO_nCONFIG;;

	printf("val0=0x%x,done=%d\n",val0,!!(*GPIO_DATA_REG &GPIO_CONF_DONE));

	while(read(fd,&c,1) == 1)
	{
		int i;
		for(i=0;i<8;i++)
		{
		set_gpio(0,c&1);
		delay(1);
		set_gpio(1,c&1);
		delay(1);
		c = c>>1;
		}

	}
		close(fd);
	delay(1000);
	printf("done=%d\n",!!(*GPIO_DATA_REG &GPIO_CONF_DONE));
	return 0;
}



static const Cmd Cmds[] =
{
	{"MyCmds"},
	{"fpga",	"binfile", 0, "fpga program ", cmd_fpga, 0, 99, CMD_REPEAT},
	{0, 0}
};



static void init_cmd __P((void)) __attribute__ ((constructor));

static void
init_cmd()
{
	cmdlist_expand(Cmds, 1);
}
