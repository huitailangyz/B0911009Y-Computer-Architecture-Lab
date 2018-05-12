#include <stdio.h>
#include <termio.h>
#include <string.h>
#include <setjmp.h>
#include <sys/endian.h>
#include <ctype.h>
#include <unistd.h>
#include <stdlib.h>
#include <pmon.h>
#include <cpu.h>
#include<sys/malloc.h>

typedef unsigned long long  u64;
typedef unsigned long  u32;
typedef unsigned short u16;
typedef unsigned char  u8;
typedef signed long  s32;
typedef signed short s16;
extern s32 synopGMAC_read_phy_reg(u64 RegBase,u32 PhyBase, u32 RegOffset, u16 * data);
extern s32 synopGMAC_write_phy_reg(u64 RegBase, u32 PhyBase, u32 RegOffset, u16 data);

#define F_MAC   0x1
#define F_RST   0x2
#define F_SHA   0x4
#define F_DEEP  0x8
#define F_MII   0x10
#define F_PHYB  0x20
#define F_TESTS  0x40
#define F_PSIZE 0x80
#define F_PNUM  0x100
#define F_GSEL  0x200
#define F_GBASE  0x400
#define F_DISP  0x800
#define F_GMII  0x1000
#define F_MDEC  0x2000


#define PSIZE  0x40
//gmac0


#define GMAC0_RDES0_VALUE      0x00000300  //own by DMA,desc_last, desc_first #document is error
#define GMAC0_RDES1_VALUE      0x00000600  //start of frame, end of frame, size 1032
#define GMAC0_RDES1_END_VALUE  0x02000600  //own by DMA,desc_last, desc_first #document is error

#define GMAC0_TX_DESC_BASE     0xa2000000
#define GMAC0_TX_DESC_BASE_PHY 0x02000000


#define GMAC0_TDES0_VALUE      0x00000000  //own by DMA  start of frame, end of frame, size 1K
#define GMAC0_TDES1_VALUE      0x60000000  //start of frame, end of frame, size 1K
#define GMAC0_TDES1_VALUE_END  0x62000000  //own by DMA


#define    regrl(addr) ((*(volatile unsigned int *)(addr)))
#define    regwl(addr,val) ((*(volatile unsigned int *)(addr))=(val))

typedef struct{
    u32 td0;
    u32 td1;
    u32 td2;
    u32 td3;
}TDESC_D;

typedef struct{
    u32 rd0;
    u32 rd1;
    u32 rd2;
    u32 rd3;
}RDESC_D;

typedef struct gmac_d{
    u32 saddr;
    u32 daddr;
    u32 saddr_phy;
    u32 daddr_phy;
    u32 td;
    u32 rd;
    u32 td_phy;
    u32 rd_phy;
    u32 flags;
    u32 psize;
    u32 pnum;
    u32 mac;
    u32 dma;
    u32 phybase;
    void (*init_data_func)(u32 mem,u32 size,u32 index);
    u32 base;
}GMAC_D;

s32 inline read_phy_reg(GMAC_D *gmac ,u16 reg,u16*data)
{
    return synopGMAC_read_phy_reg(gmac->mac,gmac->phybase,reg,data);
}
s32 inline write_phy_reg(GMAC_D *gmac ,u16 reg,u16 data)
{
    return synopGMAC_write_phy_reg(gmac->mac,gmac->phybase,reg,data);
}

void gmac_delay(GMAC_D *gmac)
{
    s32 timeout=0x50;
//    delay(20);
    while(timeout--){
        if(regrl(gmac->dma+0x14) & 0x40)
            return;
        delay(5);
    }
}
void init_data_example(u32 mem,u32 size,u32 idx)
{
    u32 i;
    for(i=0;i<size;i+=4)
    {
        regwl(mem+i,mem+i);
    }
}

void gmac_init_data(GMAC_D *gmac)
{
    u32 i,pack;
    for(pack=0;pack<gmac->pnum;pack++){
        gmac->init_data_func((gmac->saddr+gmac->psize*pack),gmac->psize,pack);
    }
}
void gmac_start_tran(GMAC_D *gmac)
{
    u32 i,ret,error=0;
    regwl(gmac->dma+0x10,gmac->td_phy);
    regwl(gmac->dma+0xc,gmac->rd_phy);

    regwl(gmac->mac,regrl(gmac->mac)|0x4);//open MAC-RX
    regwl(gmac->mac,regrl(gmac->mac)|0x8);//open MAC-TX
    regwl(gmac->dma+0x18,regrl(gmac->dma+0x18)|0x02202002); //open DMA-RX-TX
    for(i=0;i<gmac->pnum;i++){
        regwl(gmac->dma+0x14,regrl(gmac->dma+0x14)|0);
        regwl(gmac->td+i*sizeof(TDESC_D),GMAC0_RDES0_VALUE|0x80000000); 
        regwl(gmac->rd+i*sizeof(RDESC_D),GMAC0_TDES0_VALUE|0x80000000);
        regwl(gmac->dma+4,0); 
        regwl(gmac->dma+8,0); 
//        while(!(regrl(gmac->dma+0x14) & 0x40));
        gmac_delay(gmac);
        ret = gmac_check(gmac,i);
        if(ret < 0){
            return ;
        }
        printf("TR %d\tst packet(0x%04x byte):from 0x%08x to 0x%08x <Check %s>\n",i,gmac->psize,gmac->saddr+(gmac->psize)*i,gmac->daddr+i*(gmac->psize+4),ret==0?"Pass":"Error");
        if(ret>0)
            error++;
    }
    printf("\n\nTR:%d ERROR-NUM:%d\n\n ",gmac->pnum,error);
}
int inline gmac_s_reset(GMAC_D *gmac)
{
    u32 times=0x1000;
    regwl(gmac->dma,0x1);
    while(times--){
        if((regrl(gmac->dma) & 0x1) == 1){ 
            regwl(gmac->dma,0x1);
            delay(0x100);
            continue;
        }
        return 0;
    }
    printf("Gmac soft reset error...\n");  //wait for soft reset completed
    return -1;
}

//dis wtd,MII/100,LB,DUO,CHK
void inline gmac_mii_dul_force(GMAC_D *gmac)
{
    u32 conf=0;
    regwl(gmac->dma,0x400);
    if (gmac->flags & (F_GMII)){
        conf = 0x800c00;
    }else if(gmac->flags & F_MDEC){
        conf = 0x808c00;
    }else{
        conf = 0x80cc00;
    }
    if (gmac->flags & (F_DEEP | F_SHA)){
        regwl(gmac->mac,regrl(gmac->mac)|conf);
    }else{
        regwl(gmac->mac,regrl(gmac->mac)|(conf|(0x1<<12)));
    }
    regwl(gmac->mac+0x4,regrl(gmac->mac+4)|0x80000000);



} 
int  DDR2_init(GMAC_D *gmac,u32 flags)
{
    u32 i,size = gmac->psize,num = gmac->pnum;
    void *base;

    base  = malloc((2*(size+4)+sizeof(TDESC_D)+sizeof(RDESC_D)) * num + 32 ,M_DMAMAP,M_WAITOK);
    if(base == NULL)
        return -1;
    gmac->base   = (u32)base;
    gmac->saddr  = CACHED_TO_UNCACHED((u32)base+32);
    gmac->daddr  = gmac->saddr + size*num;
    gmac->saddr_phy  = UNCACHED_TO_PHYS(gmac->saddr);
    gmac->daddr_phy  = UNCACHED_TO_PHYS(gmac->daddr);
    gmac->td     = gmac->daddr + (size+4)*num;
    gmac->rd     = gmac->td + sizeof(TDESC_D)*num;
    gmac->td_phy = UNCACHED_TO_PHYS(gmac->td);
    gmac->rd_phy = UNCACHED_TO_PHYS(gmac->rd);
//    gmac->psize  = size; 
//    gmac->pnum   = num;
  
    gmac->flags  = flags;
    gmac->init_data_func =init_data_example; 

    printf("td:0x%08x rd:0x%08x\n",gmac->td,gmac->rd); 
    for(i=0;i<num;i++){
        regwl(gmac->td+i*16+0x0,GMAC0_TDES0_VALUE); 
       regwl(gmac->td+i*16+0x4,(GMAC0_TDES1_VALUE&(~(0x1<11 -1)))|size); 
       regwl(gmac->td+i*16+0x8,gmac->saddr_phy + i*size); 
       regwl(gmac->td+i*16+0xc,0); 
    }
    memset((void *)(gmac->daddr),0,num*(size+4));
    for(i=0;i<num;i++){
       regwl(gmac->rd+i*16+0x0,GMAC0_RDES0_VALUE); 
       regwl(gmac->rd+i*16+0x4,(GMAC0_RDES1_VALUE&(~(0x1<11 -1)))|(4+size)); 
       //regwl(gmac->rd+i*16+0x8,gmac->daddr + i*(size+4)); 
       regwl(gmac->rd+i*16+0x8,gmac->daddr_phy + i*(size+4)); 
       regwl(gmac->rd+i*16+0xc,0); 
    }
   return 0; 
}
int gmac_check(GMAC_D *gmac,int idx)
{
    unsigned int i,j;
    if(idx >= gmac->pnum || idx < 0)
        return (idx>0?-idx:idx);
    for(i=0;i<gmac->psize;i+=4){
        if(regrl(gmac->saddr+gmac->psize*idx) != regrl(gmac->daddr+(gmac->psize + 4)*idx))
            return 1;
    }
    return 0;
}


int gmac_main(GMAC_D *gmac ,u32 flags)
{
    u32 i,ret=0;
#if 0
    GMAC_D *gmac;
    gmac = (GMAC_D*)malloc(sizeof(GMAC_D),M_DEVBUF,M_WAITOK);
    if(gmac == NULL){
        printf("malloc error...\n");
        goto err_out;
    }
#endif    
    ret = DDR2_init(gmac,flags);
    if(ret){
        printf("malloc error...\n");
        goto err_out;
    }
    ret = gmac_s_reset(gmac);      //start with sofe-reset
    if(ret)
        goto free_all;
    gmac_init_data(gmac);
    gmac_mii_dul_force(gmac); //dis wtd,MII/100,LB,DUO,CHK
    gmac_start_tran(gmac);
    printf("\n");
free_all:
    free((void*)(gmac->base),M_DMAMAP);
err_out:
    return 0;
}
int gmac_main_1(int argc,char **argv)
{
    u32 data_32,reg_32,mac,dma,reset,sha,deep,mii_dup,phybase=0,packet_size=PSIZE,packet_num=1,gmac_sel=0,gmac_base;;
    u16 data,reg,i;
    u32 val,c;
    u32 flags = 0;
    u8 * str[100]={0}; 
    GMAC_D *gmac;
    optind = 0;
    //n:mac     normal or MAC loopback
    //r:reset   reset
    //s:sha     phy shallow loopback
    //d:deep    phy deep loopback
    //i:mii_dup MII DUP NO-AN 
    //b:phybase phy addr
    if(argc == 1)
        return -1;
    gmac = (GMAC_D*)malloc(sizeof(GMAC_D),M_DEVBUF,M_WAITOK);
    if(gmac == NULL){
        printf("malloc error...\n");
        return -1;
    }
    while((c = getopt(argc, argv, "hHb:dinrsTp:N:gG:Rkt")) != EOF) {
        switch(c) {
            case 'h':
            case 'H':
                sprintf(str,"%s","h gmac");
                do_cmd(str);
                break;
            case 'b':
                flags |= F_PHYB;//phybase
                phybase = strtoul(optarg,0,0);
                if(phybase < 0){
                    return(-1);
                }
                phybase &= 0x1f;
                break;
            case 'd':
                flags |= F_DEEP;
                break;
            case 'i':
                flags |= F_MII;//MII
                break;
            case 'n':
                flags |= F_MAC;//normal
                break;
            case 'r':
                flags |= F_RST;//reset
                break;
            case 's':
                flags |= F_SHA;
                break;
            case 'T':
                flags |= F_TESTS;
                break;
            case 'p':
                flags |= F_PSIZE;
                packet_size = strtoul(optarg,0,0);
                //printf("size==0x%08x\n",packet_size);
                if(packet_size < 0)
                    packet_size = PSIZE;
                break;
            case 'N':
                flags |= F_PNUM;
                packet_num = strtoul(optarg,0,0);
                if(packet_num <= 0){
                    return(-1);
                }
                break;
            case 'G':
                flags |= F_GBASE;
                gmac_base = strtoul(optarg,0,0);
                if(gmac_base <= 0){
                    return(-1);
                }
                break;
            case 'g':
                flags |= F_GSEL;
                gmac_sel = strtoul(optarg,0,0);
                if(gmac_sel < 0){
                    return(-1);
                }
                break;
            case 'R':
                flags |= F_DISP;
                break;
            case 'k':
                flags |= F_GMII;
                break;
            case 't':
                flags |= F_MDEC;
                break;
            default:
                return(-1);
        }
    }

    packet_size = (packet_size+3)/4*4;
    gmac->psize = packet_size > 0x5e8 ? 0x5e8 : packet_size;
    gmac->pnum = packet_num;
    gmac->phybase = phybase;
    switch(gmac_sel){
        case 0: 
            gmac->mac   =GMAC0_ADDR; 
            gmac->dma   =GMAC0_ADDR+0x1000; 
            break;
        case 1:
            gmac->mac   = GMAC1_ADDR; 
            gmac->dma   = GMAC1_ADDR+0x1000;
            break;
        default:
            gmac->mac   = GMAC0_ADDR; 
            gmac->dma   = GMAC0_ADDR+0x1000;
            break;
    }
    if(flags & F_GBASE){
        gmac->mac = gmac_base;
        gmac->dma = gmac_base + 0x1000;
    }
    if(flags & F_RST){
        write_phy_reg(gmac,0,0x8000);
        delay(0x100);
        read_phy_reg(gmac,0,&data);
        while(data&0x8000)
            read_phy_reg(gmac,0,&data);
        delay(0x1000);
    }
    if(flags & F_MAC){
        read_phy_reg(gmac,0,&data);
        data &= ~(0x1<<10);
        write_phy_reg(gmac,0,data);
    }
    if(flags & F_MII){
        read_phy_reg(gmac,0,&data);
        data = (data & ~0x3140)|0x2100;
        write_phy_reg(gmac,0,data);
    }
    //clear deep loopback 
    read_phy_reg(gmac,0,&data);
    data &= ~(0x1<<14);
    write_phy_reg(gmac,0,data);

    //clear shallowed loopback 
    read_phy_reg(gmac,0x12,&data);
    data &= ~(0x1<<5);
    write_phy_reg(gmac,0x12,data);
    if(flags & F_SHA){
        flags &= ~F_DEEP; //shallowed  first
        read_phy_reg(gmac,0x12,&data);
        data |= (0x1<<5);
        write_phy_reg(gmac,0x12,data);
    }
    if(flags & F_DEEP){
        read_phy_reg(gmac,0,&data);
        data |= (0x1<<14);
        write_phy_reg(gmac,0,data);
    }
    
    if(optind < argc){
        if (!get_rsa(&reg_32, argv[optind++])) {
            return(-1);
        }
        reg = reg_32 & 0xffff; 
        if(optind < argc){
            if (!get_rsa(&data_32, argv[optind++])) {
                return(-1);
            }
            data = data_32 & 0xffff;
            write_phy_reg(gmac,reg,data);
            return 0;
        }
        read_phy_reg(gmac,reg,&data);
        printf("phy-reg:0x%02x == %04x\n",reg,data);
    }
    if(flags & F_DISP){
       for(i=0;i<0x20;i++){
            if(i % 0x10==0 )
                printf("\n0x%02x: ",i);
            if(i % 0x10 == 8)
                printf(" ");
            read_phy_reg(gmac,i,&data);
            printf("%04x ",data);
       }  
       printf("\n");
    }
    if(flags & F_TESTS)
        //gmac_main(flags &(F_DEEP | F_SHA|F_PSIZE|F_PNUM),packet_size,packet_num); 
        gmac_main(gmac,flags); 
 
    free((void*)(gmac),M_DEVBUF);
    return 0;
}

const Optdesc         gmac_opts[] = {
	{"-h", "HELP"},
	{"-H", "HELP"},
	{"-b", "<phybase> :phybase (0~31)"},
	{"-d", "PHY deep loopback mode"},
	{"-i", "Force phy work int mii-duplex and no-AN mode"},
	{"-n", "PHY work normal(AN-ENABLE)"},
	{"-r", "Software reset phy"},
	{"-s", "PHY shallow loopback mode"},
	{"-T", "trans packet test"},
	{"-p", "<packet-size> :set packet size"},
	{"-N", "<packet-num> :set packet num(trans packet-num packets)"},
	{"-g", "<gmac-controller> :select gmac-controller"},
	{"-G", "<gmac-controller-base> :input gmac-controller-base"},
	{"-R", "display all regs of PHY"},
	{"[reg]", "read or write the phy-register (only [reg] no[data] is read-op: read [reg])"},
	{"[reg data]", "write [data] to [reg] register (write-op: write [data] to phy[reg])"},
	{0}
};


static const Cmd Cmds[] =
{
	{"MyCmds"},
	{"gmac",	"[-HhbdinrsTpNGgR] [reg [data]] ", gmac_opts, "gmac-phy OPS",gmac_main_1 , 1, 8, CMD_REPEAT},
	{0, 0}
};

	
static void init_cmd __P((void)) __attribute__ ((constructor));

static void
init_cmd()
{
	cmdlist_expand(Cmds, 1);
}

