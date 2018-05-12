#include <machine/types.h>
#include <linux/mtd/mtd.h>
#include <linux/mtd/nand.h>
#include <linux/mtd/partitions.h>
/*
 * MTD structure for gwi_nand board
 */
static struct mtd_info *gwi_nand_mtd = NULL;



#define NUM_PARTITIONS 1

static void gwi_nand_hwcontrol(struct mtd_info *mtd, int dat,unsigned int ctrl)
{
	struct nand_chip *chip = mtd->priv;

if((ctrl & NAND_CTRL_ALE)==NAND_CTRL_ALE)
		*(volatile unsigned char *)(0xbf000202) = dat;
if ((ctrl & NAND_CTRL_CLE)==NAND_CTRL_CLE)
		*(volatile unsigned char *)(0xbf000201) = dat;
}

static void find_good_part(struct mtd_info *gwi_nand_mtd)
{
int offs;
int start=-1;
char name[20];
int idx=0;
for(offs=0;offs< gwi_nand_mtd->size;offs+=gwi_nand_mtd->erasesize)
{
if(gwi_nand_mtd->block_isbad(gwi_nand_mtd,offs)&& start>=0)
{
	sprintf(name,"g%d",idx++);
	add_mtd_device(gwi_nand_mtd,start,offs-start,name);
	start=-1;
}
else if(start<0)
{
 start=offs;
}

}

if(start>=0)
{
	sprintf(name,"g%d",idx++);
	add_mtd_device(gwi_nand_mtd,start,offs-start,name);
}
}

//Main initialization for yaffs ----- by zhly
int gwi_nand_foryaffs_init(struct mtd_info *mtd)
{
	struct nand_chip *this;
	
	if(!mtd)
	{
		if(!(mtd = kmalloc(sizeof(struct mtd_info),GFP_KERNEL)))
		{
			printk("unable to allocate mtd_info structure!\n");
			return -ENOMEM;
		}
		memset(mtd, 0, sizeof(struct mtd_info));
	}

	this = kmalloc(sizeof(struct nand_chip),GFP_KERNEL);
	if(!this)
	{
		printk("Unable to allocate nand_chip structure!\n");
		return -ENOMEM;
	}
	memset(this,0,sizeof(struct nand_chip));
		
	gwi_nand_mtd=mtd;
	gwi_nand_mtd->priv = this;

	this->IO_ADDR_R = (void *)0xbf000200;
	this->IO_ADDR_W = (void *)0xbf000200;
	this->cmd_ctrl = gwi_nand_hwcontrol;
	this->ecc.mode = NAND_ECC_SOFT;
	
	if(nand_scan(gwi_nand_mtd,1))
	{
		kfree(gwi_nand_mtd);
		printk("nand_scan failed!\n");
		return -1;		
	}

	find_good_part(gwi_nand_mtd);

	return 0;
}

/*
 * Main initialization routine
 */
int gwi_nand_nand_init(void)
{
	struct nand_chip *this;

	/* Allocate memory for MTD device structure and private data */
	gwi_nand_mtd = kmalloc(sizeof(struct mtd_info) + sizeof(struct nand_chip), GFP_KERNEL);
	if (!gwi_nand_mtd) {
		printk("Unable to allocate gwi_nand NAND MTD device structure.\n");
		return -ENOMEM;
	}
	/* Get pointer to private data */
	this = (struct nand_chip *)(&gwi_nand_mtd[1]);

	/* Initialize structures */
	memset(gwi_nand_mtd, 0, sizeof(struct mtd_info));
	memset(this, 0, sizeof(struct nand_chip));

	/* Link the private data with the MTD structure */
	gwi_nand_mtd->priv = this;


	/* Set address of NAND IO lines */
	this->IO_ADDR_R = (void  *)0xbf000200;
	this->IO_ADDR_W = (void  *)0xbf000200;
	/* Set address of hardware control function */
	this->cmd_ctrl = gwi_nand_hwcontrol;
	/* 15 us command delay time */
	this->chip_delay = 15;
	this->ecc.mode = NAND_ECC_SOFT;
	printf("scan nand now\n");
	/* Scan to find existence of the device */
	if (nand_scan(gwi_nand_mtd, 1)) {
		kfree(gwi_nand_mtd);
		return -ENXIO;
	}

	/* Register the partitions */
	add_mtd_device(gwi_nand_mtd,0,0,"total");
	add_mtd_device(gwi_nand_mtd,0,0x2000000,"kernel");

	add_mtd_device(gwi_nand_mtd,0x2000000,0x2000000,"os");
	
	find_good_part(gwi_nand_mtd);


	/* Return happy */
	return 0;
}


