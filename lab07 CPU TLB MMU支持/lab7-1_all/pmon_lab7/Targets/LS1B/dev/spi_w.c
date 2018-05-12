#include <stdio.h>
#include "include/fcr.h"
#include <stdlib.h>
#include <ctype.h>
#undef _KERNEL
#include <errno.h>
#include <pmon.h>
#include <include/types.h>
#include <pflash.h>
#include<linux/mtd/mtd.h>
#include <linux/spi.h>
//#include "m25p80.h"

#define SPI_BASE  0x1fe80000
#define PMON_ADDR 0xa1000000
#define FLASH_ADDR 0x000000

#define SPCR      0x0
#define SPSR      0x1
#define TXFIFO    0x2
#define RXFIFO    0x2
#define FIFO      0x2
#define SPER      0x3
#define PARAM     0x4
#define SOFTCS    0x5
#define PARAM2    0x6

#define RFEMPTY 1
#define SPIF_PAGE_SIZE  256


#define SET_SPI(addr,val)        KSEG1_STORE8(SPI_BASE+addr,val)
#define GET_SPI(addr)            KSEG1_LOAD8(SPI_BASE+addr)

#define  CS_L    SET_SPI(SOFTCS,0x01)
#define  CS_H    SET_SPI(SOFTCS,0x11)
#define  SEND_CMD(x)     do{ SET_SPI(TXFIFO,(x));                    \
                            while((GET_SPI(SPSR)&RFEMPTY) == RFEMPTY);  \
                                GET_SPI(RXFIFO);                        \
                        }while(0)

#define  GET_DATA(x)     do{ SET_SPI(TXFIFO,0xff);                    \
                            while((GET_SPI(SPSR)&RFEMPTY) == RFEMPTY);  \
                        (x) = GET_SPI(RXFIFO);                        \
                        }while(0)

#define  SEND_DATA(x) SEND_CMD(x)






int write_sr(char val);
void spi_initw()
{ 
  	SET_SPI(SPSR, 0xc0); 
  	SET_SPI(PARAM, 0x40);             //espr:0100
 	SET_SPI(SPER, 0x05); //spre:01 
  	SET_SPI(PARAM2,0x01); 
  	SET_SPI(SPCR, 0x50);
}

void spi_initr()
{
  	SET_SPI(PARAM, 0x47);             //espr:0100
}
int read_sr(void)
{
    unsigned char val;
    CS_L;
    SEND_CMD(0x05);
    GET_DATA(val);
    CS_H;
    return val;
}
int wait_sr(void)
{
    unsigned char val;

    CS_L;
    SEND_CMD(0x05);
    do{
        GET_DATA(val);
    }while(val&0x1);
    CS_H;
    return val;
}

////////////set write enable//////////
int set_wren(void)
{
    unsigned char val;
    wait_sr();
    CS_L;
    SEND_CMD(0x6);
    CS_H;

    CS_L;
    SEND_CMD(0x05);
    do{
        GET_DATA(val);
    }while(!(val&0x2));
    CS_H;
    return 1;
}

///////////////////////write status reg///////////////////////
int write_sr(char sr)
{
    unsigned char res,val;
    set_wren();
    wait_sr();
    CS_L;
    SEND_CMD(0x1);
    SEND_DATA(sr);
    CS_H;
    return 1;
}

///////////erase all memory/////////////
int erase_all(void)
{
    int res;
    int i=1,val;

    spi_initw();
    write_sr(0);
    set_wren();
    wait_sr();

    CS_L;
    SEND_CMD(0xc7);
    CS_H;

    while(i++){
        //printf("val---==%x\n",read_sr());
        if(read_sr() & 0x3){
            //if(i % 10000 == 0)
           //     printf(".");
            //res=100;while(res--);
        }else{
            //printf("done...\n");
            break;
        }   
    }
    return 1;
}



void spi_read_id(void)
{
    unsigned char val;
    spi_initw();
    wait_sr();
    CS_L;
    SEND_CMD(0x9F);
    GET_DATA(val); 
    printf("Manufacturer's ID:         %x\n",val);
    GET_DATA(val); 
    printf("Device ID-memory_type:     %x\n",val);
    GET_DATA(val); 
    printf("Device ID-memory_capacity: %x\n",val);
    CS_H;
}

void spi_write_byte(unsigned int addr,unsigned char data)
{
    /*byte_prog$31m,CE 0, cmd 0x2,addr2,addr1,addr0,data in,CE 1*/
    unsigned char addr2,addr1,addr0;
    unsigned char val;
    addr2 = (addr & 0xff0000)>>16;
    addr1 = (addr & 0x00ff00)>>8;
    addr0 = (addr & 0x0000ff);
    set_wren();
    wait_sr();
    CS_L;

    SEND_CMD(0x2);
    SEND_DATA(addr2);
    SEND_DATA(addr1);
    SEND_DATA(addr0);
    SEND_DATA(data);
    CS_H;

}


int write_pmon_byte(int argc,char ** argv)
{
    unsigned int addr;
    unsigned char val; 
    if(argc != 3){
        printf("\nuse: write_pmon_byte  dst(flash addr) data\n");
        return -1;
    }
    addr = strtoul(argv[1],0,0);
    val = strtoul(argv[2],0,0);
    spi_write_byte(addr,val);
    return 0;

}
int write_pmon(int argc,char **argv)
{
    long int j=0;
    unsigned char val;
    unsigned int ramaddr,flashaddr,size;
    if(argc != 4){
        printf("\nuse: write_pmon src(ram addr) dst(flash addr) size\n");
        return -1;
    }

    ramaddr = strtoul(argv[1],0,0);
    flashaddr = strtoul(argv[2],0,0);
    size = strtoul(argv[3],0,0);

    spi_erase_area(flashaddr,flashaddr+size,0x10000);
    CS_L;
    // erase the flash     
    write_sr(0x00);
    printf("\nfrom ram 0x%08x  to flash 0x%08x size 0x%08x \n\nprogramming            ",ramaddr,flashaddr,size);
    for(j=0;size > 0;flashaddr++,ramaddr++,size--,j++)
    {
        spi_write_byte(flashaddr,*((unsigned char*)ramaddr));
        if(j % 0x1000 == 0)
            printf("\b\b\b\b\b\b\b\b\b\b0x%08x",j);
    }
    printf("\b\b\b\b\b\b\b\b\b\b0x%08x end...\n",j);
    CS_H;
    return 1;
}
int read_pmon(int argc,char **argv)
{
    unsigned char addr2,addr1,addr0;
    unsigned char data;
    int val,base=0;
    int addr;
    int i;
    if(argc != 3)
    {
        printf("\nuse: read_pmon addr(flash) size\n");
        return -1;
    }
    addr = strtoul(argv[1],0,0);
    i = strtoul(argv[2],0,0);
    spi_initw();
    CS_L;
    SEND_CMD(0x03);
    SEND_DATA(addr>>16);
    SEND_DATA(addr>>8);
    SEND_DATA(addr);
    printf("\n");
    while(i--)
    {

        GET_DATA(data);
        if(base % 16 == 0 ){
            printf("0x%08x    ",base);
        }
        printf("%02x ",data);
        if(base % 16 == 7)
            printf("  ");
        if(base % 16 == 15)
            printf("\n");
        base++;	
    }
    printf("\n");
    CS_H;
    return 1;

}
int spi_erase_area(unsigned int saddr,unsigned int eaddr,unsigned sectorsize)
{
    unsigned int addr;
    spi_initw(); 

    for(addr=saddr;addr<eaddr;addr+=sectorsize)
    {
//        printf(". ");
        set_wren();
        wait_sr();

        CS_L;
        SEND_CMD(0xd8);
        SEND_DATA(addr>>16);
        SEND_DATA(addr>>8);
        SEND_DATA(addr);
        CS_H;
    }
    wait_sr();
    //printf("\n");
    return 0;
}

void spi_write_page(unsigned int addr,unsigned char *buf,unsigned int num)
{
    /*byte_prog$31m,CE 0, cmd 0x2,addr2,addr1,addr0,data in,CE 1*/
    unsigned char addr2,addr1,addr0;
    unsigned int i,real_num;
    addr2 = (addr & 0xff0000)>>16;
    addr1 = (addr & 0x00ff00)>>8;
    addr0 = (addr & 0x0000ff);
    set_wren();
    wait_sr();
    real_num = min(num,SPIF_PAGE_SIZE);

    CS_L;
    SEND_CMD(0x2);
    SEND_DATA(addr2);
    SEND_DATA(addr1);
    SEND_DATA(addr0);
    for(i=0;i<real_num;i++){
        SEND_DATA(buf[i]);
    }
    CS_H;

}


int spi_write_area(int flashaddr,char *buffer,int size)
{
    int j,i;
    spi_initw();

    write_sr(0x00);
    if(getenv("spi-page")){
        for(j=0;(size > 0 &&(flashaddr & (SPIF_PAGE_SIZE -1 )));flashaddr++,size--,j++){
            spi_write_byte(flashaddr,*buffer++);
        }
        for(;size >= SPIF_PAGE_SIZE;){
            spi_write_page(flashaddr,buffer,SPIF_PAGE_SIZE);
            buffer += SPIF_PAGE_SIZE;
            flashaddr += SPIF_PAGE_SIZE;
            size -= SPIF_PAGE_SIZE;
            j += SPIF_PAGE_SIZE;
        } 
        spi_write_page(flashaddr,buffer,size);
    }else{
        for(j=0;size > 0;flashaddr++,size--,j++)
        {
            //        if((j&0xffff)==0)printf("%x\n",j);
            spi_write_byte(flashaddr,buffer[j]);
        }
    }
    wait_sr();
    return 0;
}



int spi_read_area(int flashaddr,char *buffer,int size)
{
    int i;
    spi_initw();

    CS_L;
    SEND_CMD(0x03);
    SEND_DATA(flashaddr>>16);
    SEND_DATA(flashaddr>>8);
    SEND_DATA(flashaddr);
    for(i=0;i<size;i++)
    {
        GET_DATA(buffer[i]);
    }
    CS_H;

    return 0;
}

struct fl_device myflash = {
	.fl_name="spiflash",
	.fl_size=0x100000,
	.fl_secsize=0x10000,
};

struct fl_device *fl_devident(void *base, struct fl_map **m)
{
	if(m)
	*m = fl_find_map(base);
	return &myflash;
}

int fl_program_device(void *fl_base, void *data_base, int data_size, int verbose)
{
	struct fl_map *map;
	int off;
	map = fl_find_map(fl_base);
	off = (int)(fl_base - map->fl_map_base) + map->fl_map_offset;
	spi_write_area(off,data_base,data_size);
	spi_initr();
	return 0;
}


int fl_erase_device(void *fl_base, int size, int verbose)
{
	struct fl_map *map;
	int off;
	map = fl_find_map(fl_base);
	off = (int)(fl_base - map->fl_map_base) + map->fl_map_offset;
	spi_erase_area(off,off+size,0x10000);
	spi_initr();
return 0;
}
//---------------------------------------
#define prefetch(x) (x)

static struct ls1x_spi {
	void	*base;
}  ls1x_spi0 = { KSEG1(SPI_BASE)} ;

static  struct spi_master ls1x_spi_master
= {
};


struct spi_device spi_nand = 
{
.dev = &ls1x_spi0,
.master = &ls1x_spi_master,
.chip_select = 0,
}; 




static char ls1x_spi_write_reg(struct ls1x_spi *spi, 
				unsigned char reg, unsigned char data)
{
	(*(volatile unsigned char *)(spi->base +reg)) = data;
}

static char ls1x_spi_read_reg(struct ls1x_spi *spi, 
				unsigned char reg)
{
	return(*(volatile unsigned char *)(spi->base + reg));
}


static int 
ls1x_spi_write_read_8bit(struct spi_device *spi,
  const u8 **tx_buf, u8 **rx_buf, unsigned int num)
{
	struct ls1x_spi *ls1x_spi = spi->dev;
	unsigned char value;
	int i;
	
	if (tx_buf && *tx_buf){
		ls1x_spi_write_reg(ls1x_spi, FIFO, *((*tx_buf)++));
 		while((ls1x_spi_read_reg(ls1x_spi, SPSR) & 0x1) == 1);
	}else{
		ls1x_spi_write_reg(ls1x_spi, FIFO, 0);
 		while((ls1x_spi_read_reg(ls1x_spi, SPSR) & 0x1) == 1);
	}

	if (rx_buf && *rx_buf) {
		*(*rx_buf)++ = ls1x_spi_read_reg(ls1x_spi, FIFO);
	}else{
		  ls1x_spi_read_reg(ls1x_spi, FIFO);
	}

	return 1;
}


static unsigned int
ls1x_spi_write_read(struct spi_device *spi, struct spi_transfer *xfer)
{
	struct ls1x_spi *ls1x_spi;
	unsigned int count;
	int word_len;
	const u8 *tx = xfer->tx_buf;
	u8 *rx = xfer->rx_buf;

	ls1x_spi = spi->dev;
	count = xfer->len;

	do {
		if (ls1x_spi_write_read_8bit(spi, &tx, &rx, count) < 0)
			goto out;
		count--;
	} while (count);

out:
	return xfer->len - count;
	//return count;

}


int spi_sync(struct spi_device *spi, struct spi_message *m)
{

	struct ls1x_spi *ls1x_spi = &ls1x_spi0;
	struct spi_transfer *t = NULL;
	unsigned long flags;
	int cs;
	int param;
	
	m->actual_length = 0;
	m->status		 = 0;

	if (list_empty(&m->transfers) /*|| !m->complete*/)
		return -EINVAL;


	list_for_each_entry(t, &m->transfers, transfer_list) {
		
		if (t->tx_buf == NULL && t->rx_buf == NULL && t->len) {
			printf("message rejected : "
				"invalid transfer data buffers\n");
			goto msg_rejected;
		}

	/*other things not check*/

	}

	param = ls1x_spi_read_reg(ls1x_spi, PARAM);	
	ls1x_spi_write_reg(ls1x_spi, PARAM, param&~1);
	cs = ls1x_spi_read_reg(ls1x_spi, SOFTCS) & ~(0x11<<spi->chip_select);
	ls1x_spi_write_reg(ls1x_spi, SOFTCS, (0x1 << spi->chip_select)|cs);

	list_for_each_entry(t, &m->transfers, transfer_list) {

		if (t->len)
			m->actual_length +=
				ls1x_spi_write_read(spi, t);
	}

	ls1x_spi_write_reg(ls1x_spi, SOFTCS, (0x11<<spi->chip_select)|cs);
	ls1x_spi_write_reg(ls1x_spi, PARAM, param);

	return 0;
msg_rejected:

	m->status = -EINVAL;
 	if (m->complete)
		m->complete(m->context);
	return -EINVAL;
}


#if NM25P80
int ls1b_m25p_probe()
{
    spi_initw();
    m25p_probe(&spi_nand, "m25p64");
}
#endif

static const Cmd Cmds[] =
{
	{"MyCmds"},
	{"spi_initw","",0,"spi_initw(sst25vf080b)",spi_initw,0,99,CMD_REPEAT},
	{"read_pmon","",0,"read_pmon(sst25vf080b)",read_pmon,0,99,CMD_REPEAT},
	{"write_pmon","",0,"write_pmon(sst25vf080b)",write_pmon,0,99,CMD_REPEAT},
	{"erase_all","",0,"erase_all(sst25vf080b)",erase_all,0,99,CMD_REPEAT},
	{"write_pmon_byte","",0,"write_pmon_byte(sst25vf080b)",write_pmon_byte,0,99,CMD_REPEAT},
	{"read_flash_id","",0,"read_flash_id(sst25vf080b)",spi_read_id,0,99,CMD_REPEAT},
	{0,0}
};

static void init_cmd __P((void)) __attribute__ ((constructor));

static void
init_cmd()
{
	cmdlist_expand(Cmds,1);
}





