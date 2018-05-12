#include <stdio.h>
#include <string.h> 
#include <stdlib.h>
#include <machine/pio.h>
#include <pmon.h>
#define udelay delay
#ifndef PFLASH_MAX_TIMEOUT
#define PFLASH_MAX_TIMEOUT 16000
#endif
#define __ww(addr,val)  *((volatile unsigned int*)(addr)) = (val)
#define __rw(addr,val)  val =  *((volatile unsigned int*)(addr))
#define __display(addr,num) do{for(i=0;i<num;i++){printf("0x%08x:0x%08x\n",(addr+i*sizeof(int)),*((volatile unsigned int*)(addr+i*sizeof(int))));}}while(0)
#define NAND_REG_BASE   0xbfe78000
#define NAND_DEV        0x1fe78040
#define DMA_DESP        0xa0800000
#define DMA_DESP_ORDER  0x00800008
#define DMA_ASK_ORDER   0x00800004
#define DDR_PHY         0x02400000
#define DDR_ADDR        0xa2400000

#define STATUS_TIME 100

#define cmd_to_zero  do{            \
            __ww(NAND_REG_BASE,0);  \
            __ww(NAND_REG_BASE,0);  \
            __ww(NAND_REG_BASE,0x400);  \
}while(0)




/*1, define which nand flash to use*/
#undef K9F1208U0C
#define K9F1G08U0C
#undef K9GAG08U0C

/*2, define TEST_MOD or net load MOD(undef)*/
#undef TEST_MOD    

/*3, define use ECC or not*/
#undef USE_ECC
//#define	USE_ECC

/*4, define which area to oprate*/
#undef OP_OOB
#define OP_MAIN 
#undef OP_EAE 

#ifdef USE_ECC
#undef OP_OOB
#define OP_MAIN 
#undef OP_EAE 
#endif

/*5, define how many pages to test*/
#define TEST_PAGES (128*1)

/*6, define how many pages to op at one time*/
#undef PAGES_P_TIME (4) 

/*7, define the nand expect param*/
#ifdef K9F1208U0C
    // 2^PAGE_P_BLOCK = 32 
    #define PAGE_P_BLOCK (5) 
    #define WRITE_SIZE (512)
    #define OOB_SIZE (16)
    #define ERASE_SIZE (32*512)

//0xbfe78018, 
    #ifdef OP_MAIN
        #define NAND_PARAM_V 0x2005c00
    #endif    
    #ifdef OP_OOB
        #define NAND_PARAM_V 0x105c00
    #endif    
    #ifdef OP_EAE
        #define NAND_PARAM_V 0x2105c00
    #endif    

    #ifdef USE_ECC
        #define NAND_PARAM_V 0xCC5C00
    #endif
#endif
#ifdef K9F1G08U0C    //ls1c
    // 2^PAGE_P_BLOCK = 32 / 64
    #define PAGE_P_BLOCK (6) 
    #define WRITE_SIZE (2048)
    #define OOB_SIZE (64)
    #define ERASE_SIZE (64*2048)

//0xbfe78018, 
    #ifdef OP_MAIN
        #define NAND_PARAM_V 0x8005100
    #endif    
    #ifdef OP_OOB
        #define NAND_PARAM_V 0x405100
    #endif    
    #ifdef OP_EAE
        #define NAND_PARAM_V 0x8405100
    #endif    

    #ifdef USE_ECC
        #define NAND_PARAM_V 0x7F85100
    #endif
#endif

#ifdef K9GAG08U0C
    // 2^PAGE_P_BLOCK = 32 / 64
    #define PAGE_P_BLOCK (7) 
    #define WRITE_SIZE (4096)
    #define OOB_SIZE (128)
    #define ERASE_SIZE (128*4096)

//0xbfe78018, 
    #ifdef OP_MAIN
        #define NAND_PARAM_V 0x10005400
    #endif    
    #ifdef OP_OOB
        #define NAND_PARAM_V 0x805400
    #endif    
    #ifdef OP_EAE
        #define NAND_PARAM_V 0x10805400
    #endif    

    #ifdef USE_ECC
        #define NAND_PARAM_V 0xFF05400
    #endif
#endif

/*add by hb, test program nand flash*/
/*
 * Standard NAND flash commands
 */
#define NAND_CMD_READ0		0
#define NAND_CMD_READ1		1
#define NAND_CMD_RNDOUT		5
#define NAND_CMD_PAGEPROG	0x10
#define NAND_CMD_READOOB	0x50
#define NAND_CMD_ERASE1		0x60
#define NAND_CMD_STATUS		0x70
#define NAND_CMD_STATUS_MULTI	0x71
#define NAND_CMD_SEQIN		0x80
#define NAND_CMD_RNDIN		0x85
#define NAND_CMD_READID		0x90
#define NAND_CMD_ERASE2		0xd0
#define NAND_CMD_RESET		0xff

#define DMA_ACCESS_ADDR     0x1fe78040
#define ORDER_REG_ADDR      (0xa0000000 |(0x1fd01160))
#define MAX_BUFF_SIZE	4096
#define PAGE_SHIFT      12
/*
#define NO_SPARE_ADDRH(x)   ((x) >> (32 - (PAGE_SHIFT - 1 )))   
#define NO_SPARE_ADDRL(x)   ((x) << (PAGE_SHIFT - 1))
*/
#define NO_SPARE_ADDRH(x)   (x)
#define NO_SPARE_ADDRL(x)   (0)
/*
#define SPARE_ADDRH(x)      ((x) >> (32 - (PAGE_SHIFT )))   
#define SPARE_ADDRL(x)      ((x) << (PAGE_SHIFT ))
*/
#define SPARE_ADDRH(x)      (x)
#define SPARE_ADDRL(x)      (0)
#define ALIGN_DMA(x)       (((x)+ 3)/4)

#define NAND_CMD        0x1
#define NAND_ADDRL      0x2
#define NAND_ADDRH      0x4
#define NAND_TIMING     0x8
#define NAND_IDL        0x10
#define NAND_STATUS_IDL 0x20
#define NAND_PARAM      0x40
#define NAND_OP_NUM     0X80
#define NAND_CS_RDY_MAP 0x100

#define DMA_ORDERAD     0x1
#define DMA_SADDR       0x2
#define DMA_DADDR       0x4
#define DMA_LENGTH      0x8
#define DMA_STEP_LENGTH 0x10
#define DMA_STEP_TIMES  0x20
#define DMA_CMD         0x40
#define CHIP_DELAY_TIMEOUT (2*1000/10)

#define EAE      1
#define EDC		2	/* Activate ECC/EDC		*/
#define EXTRA		4	/* Read/write spare area	*/

#define write_z_cmd  do{                                    \
            *((volatile unsigned int *)(0xbfe78000)) = 0;   \
            *((volatile unsigned int *)(0xbfe78000)) = 0;   \
            *((volatile unsigned int *)(0xbfe78000)) = 400; \
    }while(0)

#define  _NAND_IDL      ( *((volatile unsigned int*)(0xbfe78010)))
#define  _NAND_IDH       (*((volatile unsigned int*)(0xbfe78014)))
#define  _NAND_BASE      0xbfe78000

#define STATUS_TIME_LOOP_R  30 
#define STATUS_TIME_LOOP_WS  60  
#define STATUS_TIME_LOOP_WM  60  
#define STATUS_TIME_LOOP_E  100  

#define  _NAND_SET_REG(x,y)   do{*((volatile unsigned int*)(_NAND_BASE+x)) = (y);}while(0)
#define  _NAND_READ_REG(x,y)  do{(y) =  *((volatile unsigned int*)(_NAND_BASE+x));}while(0) 


enum{
    STATE_READY = 0,
    STATE_BUSY  ,
};

struct ls1g_nand_cmdset {
        uint32_t    cmd_valid:1;
	uint32_t    read:1;
	uint32_t    write:1;
	uint32_t    erase_one:1;
	uint32_t    erase_con:1;
	uint32_t    read_id:1;
	uint32_t    reset:1;
	uint32_t    read_sr:1;
	uint32_t    op_main:1;
	uint32_t    op_spare:1;
	uint32_t    done:1;
	uint32_t    en_ecc_rd:1;
	uint32_t    en_ecc_wr:1;
	uint32_t    int_en:1;
	uint32_t    ecc_wait_rd:1;	//lxy
        uint32_t    resv1:1;/*15 reserved*/
        uint32_t    nand_rdy:4;/*16-19*/
        uint32_t    nand_ce:4;/*20-23*/
        uint32_t    resv2:8;/*24-32 reserved*/
};

struct ls1g_nand_dma_cmd{
        uint32_t    dma_int_mask:1;
        uint32_t    dma_int:1;
        uint32_t    dma_sl_tran_over:1;
        uint32_t    dma_tran_over:1;
        uint32_t    dma_r_state:4;
        uint32_t    dma_w_state:4;
        uint32_t    dma_r_w:1;
        uint32_t    dma_cmd:2;
        uint32_t    revl:17;
};

struct ls1g_nand_desc{
        uint32_t    cmd;
        uint32_t    addrl;
        uint32_t    addrh;
        uint32_t    timing;
        uint32_t    idl;/*readonly*/
        uint32_t    status_idh;/*readonly*/
        uint32_t    param;
        uint32_t    op_num;
        uint32_t    cs_rdy_map;
};

struct ls1g_nand_dma_desc{
        uint32_t    orderad;
        uint32_t    saddr;
        uint32_t    daddr;
        uint32_t    length;
        uint32_t    step_length;
        uint32_t    step_times;
        uint32_t    cmd;
};

struct ls1g_nand_info {
	unsigned int 		buf_start;
	unsigned int		buf_count;
        /* NAND registers*/
	void 		*mmio_base;
        struct ls1g_nand_desc   nand_regs;
        unsigned int            nand_addrl;
        unsigned int            nand_addrh;
        unsigned int            nand_timing;
        unsigned int            nand_op_num;
        unsigned int            nand_cs_rdy_map;
        unsigned int            nand_cmd;

	/* DMA information */

        struct ls1g_nand_dma_desc  dma_regs;
        unsigned int            order_reg_addr;  
        unsigned int            dma_orderad;
        unsigned int            dma_saddr;
        unsigned int            dma_daddr;
        unsigned int            dma_length;
        unsigned int            dma_step_length;
        unsigned int            dma_step_times;
        unsigned int            dma_cmd;
        int			drcmr_dat;	/*dma descriptor address;*/
	 unsigned int 		drcmr_dat_phys;
        size_t                  drcmr_dat_size;
	unsigned char		*data_buff;/*dma data buffer;*/
	unsigned int 		data_buff_phys;
	size_t			data_buff_size;
        unsigned long           cac_size;
        unsigned long           num;
        unsigned long           size;

        unsigned int            dma_ask;
        unsigned int            dma_ask_phy;

	/* relate to the command */
	unsigned int		state;
/*	int			use_ecc;	*//* use HW ECC ? */
	size_t			data_size;	/* data size in FIFO */
        unsigned int            cmd;
        unsigned int            page_addr;
/*        struct completion 	cmd_complete;*/
        unsigned int            seqin_column;
        unsigned int            seqin_page_addr;
        unsigned int            timing_flag;
        unsigned int            timing_val;

        unsigned int            ori_data;
};

struct ls1g_nand_info ls1A_Nand_Info;
static unsigned char drcmr_data[MAX_BUFF_SIZE+64];

static void ls1g_nand_cmdfunc(unsigned command, int column, int page_addr, int flag);

static char wait_NandDma(void);

static unsigned ls1g_nand_status(struct ls1g_nand_info *info)
{
    return(*((volatile unsigned int*)0xbfe78000) & (0x1<<10));
}

static void ls1g_nand_init_info(struct ls1g_nand_info *info)
{


//    *((volatile unsigned int *)0xbfe78018) = 0x30000;
    info->timing_flag = 1;/*0:read; 1:write;*/
    info->num=0;
    info->size=0;
/*    info->coherent = 0;*/
    info->cac_size = 0; 
    info->state = STATE_READY;
    info->cmd = -1;
    info->page_addr = -1;
    info->nand_addrl = 0x0;
    info->nand_addrh = 0x0;
//    info->nand_timing =0x206;/* 0x4<<8 | 0x12;*/
/*    info->nand_timing = 0x4<<8 | 0x12;*/
    info->nand_op_num = 0x0;
    info->nand_cs_rdy_map = 0x00000000;
    info->nand_cmd = 0;

    info->dma_orderad = 0x0;
    info->dma_saddr = info->data_buff_phys;
    info->dma_daddr = DMA_ACCESS_ADDR;
    info->dma_length = 0x0;
    info->dma_step_length = 0x1;
    info->dma_step_times = 0x1;
    info->dma_cmd = 0x0;

    info->order_reg_addr = ORDER_REG_ADDR;
	printf("------------------info->drcmr_dat is 0x%x\n",ls1A_Nand_Info.drcmr_dat);	  
	/*cacheGodson2eFlush(1, info, sizeof(struct ls1g_nand_info));*/
}

//unsigned char *drcmr_data;
/*assume base: block addr*/
int nand_probe_boot(void)
{
	struct ls1g_nand_info *info = &ls1A_Nand_Info;


	printf("&drcmr_data is: 0x%x\n", &drcmr_data[0]);
	if(((unsigned int)(&drcmr_data[0]) & 0x3f) !=0)
	{
		info->drcmr_dat =((unsigned int)((unsigned int)(&drcmr_data[0]) + (0x40- 0x1)) & (unsigned int)(~(0x40 - 0x1)));
	}
	else
		info->drcmr_dat = (unsigned int)(&drcmr_data[0]);

	info->drcmr_dat |= 0xa0000000; 
	info->drcmr_dat_phys = ((info->drcmr_dat )& 0x0fffffff);	

	info->mmio_base = 0xbfe78000;


	ls1g_nand_init_info(info);

	info->data_buff = malloc(MAX_BUFF_SIZE+64);
	memset(info->data_buff, 0, MAX_BUFF_SIZE+64);


	ls1g_nand_cmdfunc(NAND_CMD_READID, 0, -1, 0);

	free(info->data_buff);


	return 0;
}

/***************************************************************************
 * Description:
 * Parameters: base:  block addr;	size:(bytes)
 * Date    : 2014-02-18
 ***************************************************************************/

int
nand_erase_boot(void *base, int size, int verbose)
{
	int nand_pagePtr;
	unsigned int command;
	unsigned int erase_num = 0;
	int cnt=0;

        struct ls1g_nand_info *info = &ls1A_Nand_Info;

	printf("erase_addr:0x%x, erase_size:0x%x Byte\n", base, size);

	nand_pagePtr = (int)base;
	nand_pagePtr <<= PAGE_P_BLOCK;  // page addr

#ifdef TEST_MOD
    size = ERASE_SIZE * (TEST_PAGES/64); 
	//erase_num = size/(ERASE_SIZE);
	erase_num = (size+ (ERASE_SIZE-1))/(ERASE_SIZE);
#else
//	erase_num = size/(ERASE_SIZE);
	erase_num = (size+ (ERASE_SIZE-1))/(ERASE_SIZE);
#endif
    //erase_num++;
	printf("erase pagePtr is 0x%x\n", nand_pagePtr);
	printf("nand erase blocks num is %d\n", erase_num);

	command = NAND_CMD_ERASE2;
	int i = 0;
	while(erase_num > 0)
	{
		info->nand_regs.op_num = i++;
		ls1g_nand_cmdfunc(command, 0, nand_pagePtr, 0);
		erase_num--;
	 //   erase_num = 0;
		nand_pagePtr += (1 << PAGE_P_BLOCK);

//		printf("in erase while..., erase_num is %d\n", erase_num);
	}

	printf("after erase_nand\n");
	return 0;
}

static unsigned char data_ori[4096];

static unsigned char *wr_data_bf;


int
nand_program_boot(void *fl_base, void *data_base, int data_size, int flag)
{

#ifdef OP_OOB   
    nand_program_op(fl_base, data_base, data_size, EXTRA);
#endif
#ifdef OP_MAIN
    nand_program_op(fl_base, data_base, data_size, EDC);
#endif
#ifdef OP_EAE
    nand_program_op(fl_base, data_base, data_size, EAE);

#endif    

}
int
nand_program_op(void *fl_base, void *data_base, int data_size, int flag)
{
	int nand_pagePtr;
	char tmp;
    int i;
	unsigned int command;
	unsigned int program_num;
	struct ls1g_nand_info *info = &ls1A_Nand_Info;
    unsigned int dat = 0;
    unsigned char * dat1 = NULL;
    unsigned char * dat2 = NULL;

    int op_size = 0;
    int buf_p_size = 0;

	printf("\r\nin nand_program_boot...........\n");
	printf("fl_base is: 0x%x\r\n data_base is 0x%x\n ",fl_base, data_base);
/*
    wr_data_bf = (unsigned char *)malloc(data_size);
    wr_data_bf = (unsigned char *)((unsigned int)wr_data_bf | 0xa0000000);
    data_base = (unsigned char *)((unsigned int)data_base | 0xa0000000);
    memset(wr_data_bf, 0, data_size);
    memcpy(wr_data_bf, data_base, data_size);
*/

    if(flag == EDC)
        op_size = WRITE_SIZE;
    else if(flag == EXTRA)
        op_size = OOB_SIZE;
    else if(flag == EAE)
        op_size = (WRITE_SIZE + OOB_SIZE);

#ifdef USE_ECC
        op_size = (op_size/204)*204;
		buf_p_size = (op_size/204)*188;
#endif



    dat1 = (unsigned char *)0xa1a80000;		//???????????????????  quection

#ifdef TEST_MOD    
        data_size = op_size * TEST_PAGES;
    
        printf("data_sise is %x\n", data_size);

        tmp = *(volatile char *)0xa1a7fffc; 
        for(i=0; i<(WRITE_SIZE + OOB_SIZE)*8; i++)
            dat1[i] = (254 - ((i+tmp)%255));
    
        *(volatile char *)0xa1a7fffc += 1;; 

#else
        printf("data_base is %x\n", data_base);

/*there had some problems for net load big files???????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????????????????`*/
        memcpy(dat1, data_base, data_size);
#endif
    dat = (unsigned int)dat1;

    info->ori_data = dat;

    nand_pagePtr = (int)fl_base;
	nand_pagePtr <<= PAGE_P_BLOCK;

#ifdef PAGES_P_TIME
    op_size *= PAGES_P_TIME;
#endif    

#ifdef	USE_ECC
   	program_num = data_size / buf_p_size;
    if(data_size % buf_p_size != 0)
#else
   	program_num = data_size / op_size;
    if(data_size % op_size != 0)
#endif
    	program_num++;
 
    printf("program_num = %d, flag=%d, dat=%x\n", program_num, flag, dat);        

	while(program_num > 0)
	{

        //for READ OOB
        *(volatile unsigned int *)(0xbfe78018) =  NAND_PARAM_V; 

        if(nand_pagePtr %128 == 0 )
         	printf("p 0x%x\n", nand_pagePtr);

		ls1g_nand_cmdfunc(NAND_CMD_SEQIN, 0x00, nand_pagePtr, flag);
		info->data_buff  = (unsigned char *)dat;
		info->data_buff_phys =(unsigned char *)(dat & 0x1fffffff);
		info->buf_start = op_size; 

        info->dma_saddr = info->data_buff_phys;

		/*	ls1g_nand_write_buf(buffer+2048, 64);*/
        *(volatile unsigned int *)0xbfd01160 = 0x10;        //DMA STOP

        ls1g_nand_cmdfunc(NAND_CMD_PAGEPROG, 0, -1, flag);	
	
		program_num--;

#ifdef PAGES_P_TIME        
        nand_pagePtr += PAGES_P_TIME;
#else        
		nand_pagePtr++;
#endif

#ifdef USE_ECC
        dat += buf_p_size; 
#else
        dat += op_size; 
#endif

#ifdef TEST_MOD        
       if((dat - (unsigned int)dat1) >= (8*WRITE_SIZE))
            dat = (unsigned int)dat1;
#else

#endif

		wait_NandDma();
	}

	
	return 0;
}

static unsigned char data_buff[4096];
//unsigned char *data_buff = 0xa1e00000;
unsigned char * nand_read_boot(int pagePtr, void *data_buf, int flag)
{
        int nand_pagePtr;
    	int i;
        struct ls1g_nand_info *info = &ls1A_Nand_Info;


        nand_pagePtr = pagePtr;
        *(volatile unsigned int *)0xbfd01160 = 0x10;        //DMA STOP
        *(volatile unsigned int *)(0xbfe78018) = NAND_PARAM_V;// 0x00405100;
#if 1 //add by yg  for set env in nand
		unsigned int data_addr = (unsigned int)(&data_buff[0]);
		data_addr |= 0xa0000000;
		info->data_buff_phys =(unsigned char*)( (unsigned int)(data_addr) & 0x1fffffff);
		info->dma_saddr = info->data_buff_phys;
#endif 


        if(flag == EXTRA)
    	    ls1g_nand_cmdfunc(NAND_CMD_READOOB, 0, (unsigned int)nand_pagePtr, EXTRA);
        else if(flag == EDC)
    	    ls1g_nand_cmdfunc(NAND_CMD_READ0, 0, (unsigned int)nand_pagePtr, EDC);
        else if(flag == EAE)
    	    ls1g_nand_cmdfunc(NAND_CMD_READ0, 0, (unsigned int)nand_pagePtr, EAE);

        wait_NandDma();

        //return 0;
		return data_buff;

}


int
nand_verify_boot(void *fl_base, void *data_base, int data_size, int verbose)
{
#ifdef OP_OOB
    nand_verify_op(fl_base, data_base, data_size, EXTRA);
#endif 
#ifdef OP_MAIN
    nand_verify_op(fl_base, data_base, data_size, EDC);
#endif
#ifdef OP_EAE
    nand_verify_op(fl_base, data_base, data_size, EAE);
   
#endif    
}

int
nand_verify_op(void *fl_base, void *data_base, int data_size, int flag)
{
	unsigned char *ori_data_buff;
	unsigned char *data_buf_tmp;
	int cmp_size;
    int nand_pagePtr;
    unsigned  int data_addr;
    int i, j;
    int op_size;
    struct ls1g_nand_info *info = &ls1A_Nand_Info;
	int buf_p_size = 0;


    if(flag == EXTRA)
        op_size = OOB_SIZE;
    else if(flag == EDC)
        op_size = WRITE_SIZE;
    else
        op_size = (WRITE_SIZE + OOB_SIZE);

#ifdef USE_ECC
        op_size = (op_size/204)*204;
		buf_p_size = (op_size/204)*188;
#endif

    ori_data_buff = (unsigned char *)info->ori_data;
#ifdef TEST_MOD 
    data_addr = 0xa1380000;
    data_size = op_size * TEST_PAGES;
#else
	data_addr = (unsigned int)(&data_buff[0]);
#endif

#ifdef PAGES_P_TIME
    op_size *= PAGES_P_TIME;
#endif    

// printf("data_addr is:%x\n", data_addr);

    data_addr |= 0xa0000000;
//	info->data_buff = (unsigned char *)((unsigned int)(&data_buff[0]) | 0xa0000000);
    
//	info->data_buff_phys =(unsigned char*)( (unsigned int)(data_buf_tmp) & 0x1fffffff);
	info->data_buff_phys =(unsigned char*)( (unsigned int)(data_addr) & 0x1fffffff);
	info->dma_saddr = info->data_buff_phys;
		
//	printf("data_buff_phys is 0x%x\n", info->dma_saddr);
    nand_pagePtr  = (int)((int)fl_base << PAGE_P_BLOCK);
	
    printf("flag=%d\n", flag);        
	while(1)
	{
		if(data_size <= 0)
			break;	

    //    printf("data_size=%d\n", data_size);        
        if(nand_pagePtr % 128 == 0)
            printf("rd page 0x%x\n", nand_pagePtr);
        memset((unsigned char *)data_addr, 0, 16);

#ifdef	USE_ECC
   		cmp_size = data_size>buf_p_size ? buf_p_size : data_size;
#else
   		cmp_size = data_size>op_size?op_size:data_size;
#endif

		nand_read_boot(nand_pagePtr, data_buff, flag);

        data_buf_tmp = data_addr;

           for(i=0; i<cmp_size; i++)
                if(data_buf_tmp[i] != ori_data_buff[i])
                {
                    j = i;          
           
                    printf("rd error page 0x%x, i= %d !\n", nand_pagePtr, i);
                    printf("&data_buf_tmp:%x\n", &data_buf_tmp[i]);

                    for(; i<j+5; i++)
                        printf("%x ", data_buf_tmp[i]);

                    printf("\n");

                    i = j;
                    printf("ori_data_buff:%x\n", &ori_data_buff[i]);
            
                    for(; i<j+5; i++)
                        printf("%x ", ori_data_buff[i]);
    
                    printf("\n");

                    return -1;
                } 

        nand_pagePtr ++;
#ifdef	USE_ECC
        data_base += buf_p_size;
        ori_data_buff += buf_p_size;
		data_size -= buf_p_size;
#else
        data_base += cmp_size;
        ori_data_buff += cmp_size;
		data_size -= cmp_size;
#endif
        
        if(cmp_size < op_size) 
    		break;
#ifdef TEST_MOD
        if(((unsigned int)ori_data_buff - 0xa1a80000) >= (8*WRITE_SIZE))
            ori_data_buff = ((unsigned int)0xa1a80000);
#endif            
	}

	printf("nand_verify, OK\n");
	return 0;
}




static void dma_setup(unsigned int flags,struct ls1g_nand_info *info)
{
    struct ls1g_nand_dma_desc *dma_base = (volatile struct ls1g_nand_dma_desc *)(info->drcmr_dat);

    *(volatile unsigned int *)0xbfe78000 = 0x0;
//    printf("*0xbfe78000 is %x\n", *(volatile unsigned int *)0xbfe78000);

//    printf("info->drcmr_dat is %x\n", info->drcmr_dat);

    dma_base->orderad = (flags & DMA_ORDERAD)== DMA_ORDERAD ? info->dma_regs.orderad : info->dma_orderad;

    dma_base->saddr = (flags & DMA_SADDR)== DMA_SADDR ? info->dma_regs.saddr : info->dma_saddr;

    dma_base->daddr = (flags & DMA_DADDR)== DMA_DADDR ? info->dma_regs.daddr : info->dma_daddr;
	
    dma_base->length = (flags & DMA_LENGTH)== DMA_LENGTH ? info->dma_regs.length: info->dma_length;

    dma_base->step_length = (flags & DMA_STEP_LENGTH)== DMA_STEP_LENGTH ? info->dma_regs.step_length: info->dma_step_length;

    dma_base->step_times = (flags & DMA_STEP_TIMES)== DMA_STEP_TIMES ? info->dma_regs.step_times: info->dma_step_times;

    dma_base->cmd = (flags & DMA_CMD)== DMA_CMD ? info->dma_regs.cmd: info->dma_cmd;


//	printf("dma_base0 amd   	 is 0x%x\n",dma_base->cmd);



	#if 0
    printf("orderad     =  %x\n", dma_base->orderad);
    printf("saddr       =  %x\n", dma_base->saddr);
    printf("daddr       =  %x\n", dma_base->daddr);
    printf("length      =  %x\n", dma_base->length);
    printf("step_length =  %x\n", dma_base->step_length);
    printf("step_times  =  %x\n", dma_base->step_times);
    printf("cmd         =  %x\n", dma_base->cmd);

	#endif
	
    if((dma_base->cmd)&(0x1 << 12)){    
        /*cacheGodson2eFlush(DATA_CACHE, (unsigned long)(info->data_buff), info->cac_size);*//*( info->cac_size);*/
    }

#if 0
    {
    long flags;
/*    local_irq_save(flags);		?????ÓëÖÐ¶ÏÓÐ¹Ø£¬¿ÉÄÜÊÇ¹ØdmaÖÐ¶Ïhb*/
/*	printStr("info->order_reg_addr ");printnum(  info->order_reg_addr);printStr("\r\n");		
	printStr("info->drcmr_dat_phys ");printnum(  info->drcmr_dat_phys);printStr("\r\n");	*/
    *(volatile unsigned int *)info->order_reg_addr = ((unsigned int )info->drcmr_dat_phys) | 0x1<<3;
    while ((*(volatile unsigned int *)info->order_reg_addr) & 0x8 )delay(1);
	
/*    local_irq_restore(flags);	??????hb*/
    }
#endif
	/*    cacheGodson2eDCInvalidate((unsigned long)(info->drcmr_dat),0x40);*/

    *(volatile unsigned int *)info->order_reg_addr = ((unsigned int )info->drcmr_dat_phys) | 0x1<<3;
		
//    printf("cmd         =  %x\n", dma_base->cmd);
}

/**
 *  flags & 0x1     cmd
 *  flags & 0x2     addrl
 *  flags & 0x4     addrh
 *  flags & 0x8     timing
 *  flags & 0x10    idl
 *  flags & 0x20    status_idh
 *  flags & 0x40    param
 *  flags & 0x80    op_num
 *  flags & 0x100   cs_rdy_map
 ****/
static void nand_setup(unsigned int flags ,struct ls1g_nand_info *info)
{
    int i,val1,val2,val3;
    struct ls1g_nand_desc *nand_base = (volatile struct ls1g_nand_desc *)(info->mmio_base);
   
	nand_base->cmd = 0;
	nand_base->param = 0x8005000;	//lxy
    nand_base->addrl = (flags & NAND_ADDRL)==NAND_ADDRL ? info->nand_regs.addrl: info->nand_addrl;
    nand_base->addrh = (flags & NAND_ADDRH)==NAND_ADDRH ? info->nand_regs.addrh: info->nand_addrh;
//    nand_base->timing = (flags & NAND_TIMING)==NAND_TIMING ? info->nand_regs.timing: info->nand_timing;
    nand_base->op_num = (flags & NAND_OP_NUM)==NAND_OP_NUM ? info->nand_regs.op_num: info->nand_op_num;
//    nand_base->cs_rdy_map = (flags & NAND_CS_RDY_MAP)==NAND_CS_RDY_MAP ? info->nand_regs.cs_rdy_map: info->nand_cs_rdy_map;
//	printf("dbg nand op num: 0x%x \r\n",nand_base->op_num);
    if(flags & NAND_CMD){
            nand_base->cmd = (info->nand_regs.cmd) & (0xfffffffe);
            nand_base->cmd = nand_base->cmd |0x1;/*  info->nand_regs.cmd;*/
    }
    else
        nand_base->cmd = info->nand_cmd;

#if 0 
	printf("\r\n^^^^^^^^^^^^^^^^^^^^^^^^^^^ dbg ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\r\n");
	printf("nand_base0 amd   	 is 0x%x\n",nand_base->cmd);
	printf("nand_base1 addrl     is 0x%x\n",nand_base->addrl);
	printf("nand_base2 addh	 	 is 0x%x\n",nand_base->addrh);
	printf("nand_base  param	 is 0x%x\n",nand_base->param);
	printf("nand_base op_num	 is 0x%x\n",nand_base->op_num);
#endif

//printf("return nand_setup\n");
    
}

static void ls1g_nand_cmdfunc(unsigned command, int column, int page_addr, int flag)
{

        struct ls1g_nand_info *info = &ls1A_Nand_Info;
        unsigned cmd_prev;
        int status_time,page_prev;
        int timeout = CHIP_DELAY_TIMEOUT;
		int *cmdsPtr = NULL;
	    int tmp,retry = 0;
/*        init_completion(&info->cmd_complete);*/
        cmd_prev = info->cmd;
        page_prev = info->page_addr;

        info->cmd = command;
        info->page_addr = page_addr;
        switch(command){
#if 1 
            case NAND_CMD_READOOB:
                if(info->state == STATE_BUSY){
                    printf("nandflash chip if busy...\n");
                    return;
                }
/*                    printStr("NAND_CMD_READOOB...\r\n");*/
                info->state = STATE_BUSY; 
                info->buf_count = OOB_SIZE;
                info->buf_start = 0;
                info->cac_size = info->buf_count;
                if(info->buf_count <=0 )
                    break;

                info->nand_regs.addrh = SPARE_ADDRH(page_addr);
                info->nand_regs.addrl = SPARE_ADDRL(page_addr)+0x800;/*0x800  ->    mtd->writesize*/
                info->nand_regs.op_num = info->buf_count;
								
               /*nand cmd set */ 
                info->nand_regs.cmd = 0; 
		  info->dma_regs.cmd = 0;

		((struct ls1g_nand_cmdset*)(&(info->nand_regs.cmd)))->read = 1;
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_spare = 1;
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->cmd_valid = 1;
			
                /*dma regs config*/
                info->dma_regs.length =ALIGN_DMA(info->buf_count)+1;
                ((struct ls1g_nand_dma_cmd *)&(info->dma_regs.cmd))->dma_int_mask = 1;	
                /*dma GO set*/       
                dma_setup(DMA_LENGTH|DMA_CMD,info);
                nand_setup(NAND_ADDRL|NAND_ADDRH|NAND_OP_NUM|NAND_CMD,info);	
//       printf("nand read oob......, ok\n"); 			
                break;
#endif
/*            case NAND_CMD_READOOB:*/
            case NAND_CMD_READ0:
                if(info->state == STATE_BUSY){
                    printf("nandflash chip is busy...\n");
                    return;
                }

/*                   printStr("NAND_CMD_READ0...\r\n");*/
                info->state = STATE_BUSY;

//			    printf("NAND_READ0, flag:%d\n", flag);	
                if(flag == EAE)
                    info->buf_count = (WRITE_SIZE + OOB_SIZE);
                else if(flag == EDC)
                    info->buf_count = WRITE_SIZE;

#ifdef USE_ECC
        info->buf_count = (info->buf_count/204)*204;
#endif



                info->buf_start =  0 ;
                info->cac_size = info->buf_count;
                if(info->buf_count <=0 )
                    break;
				
                info->nand_regs.addrh = SPARE_ADDRH(page_addr);

             	  info->nand_regs.addrl = SPARE_ADDRL(page_addr);
		
//                printf("addrh %x ", info->nand_regs.addrh);
//                printf(" info->nand_regs.addrl: %x\n", info->nand_regs.addrl);
                info->nand_regs.op_num = info->buf_count;
	//		    printf("NAND_READ0, op_num:%d\n", info->buf_count);	
               /*nand cmd set */ 
                info->nand_regs.cmd = 0; 
                info->dma_regs.cmd = 0;
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->read = 1;

             	  ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_main = 1;

                if(flag == EAE)
                    ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_spare = 1;

#ifdef USE_ECC
     ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->en_ecc_rd = 1;
     ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->en_ecc_wr = 1;
     ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->ecc_wait_rd = 1;		//lxy
			{((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_main = 0;}
#endif



                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->cmd_valid = 1; 
                /*dma regs config*/
#ifdef USE_ECC
                info->dma_regs.length = ALIGN_DMA((WRITE_SIZE/204)*188);
#else
                info->dma_regs.length = ALIGN_DMA(info->buf_count);
#endif
//			    printf("NAND_READ0,DMA op_num:%d\n", info->dma_regs.length);	
                ((struct ls1g_nand_dma_cmd *)&(info->dma_regs.cmd))->dma_int_mask = 1;	

                dma_setup(DMA_LENGTH|DMA_CMD,info);	
                nand_setup(NAND_ADDRL|NAND_ADDRH|NAND_OP_NUM|NAND_CMD,info);
			
                break;

            case NAND_CMD_SEQIN:
                if(info->state == STATE_BUSY){
                    printf("nandflash chip if busy...\n");
                    return;
                }
                info->state = STATE_BUSY;
                info->buf_count = OOB_SIZE + WRITE_SIZE - column;	/*mtd->oobsize + mtd->writesize - column;*/
                info->buf_start = 0;
                info->seqin_column = column;
                info->seqin_page_addr = page_addr;
/*                complete(&info->cmd_complete);*/

                break;

            case NAND_CMD_PAGEPROG:
/*                info->coherent = 0;*/
/*		printStr("in NAND_CMD_PAGEPROG\r\n");*/
                if(info->state == STATE_BUSY){
                    printf("nandflash chip if busy...\n");
                    return;
                }
                info->state = STATE_BUSY;

                if(cmd_prev != NAND_CMD_SEQIN){
                    printf("Prev cmd don't complete...\n");
                    break;
                }
			
                if(info->buf_count <= 0 )
                 {
			printf("     case NAND_CMD_PAGEPROG: break!!!!!!\n");  
				 break;
                }
                /*nand regs set*/
                info->nand_regs.addrh =  SPARE_ADDRH(info->seqin_page_addr);
                info->nand_regs.addrl =  SPARE_ADDRL(info->seqin_page_addr) + info->seqin_column;
                if(flag == EXTRA)
                     info->nand_regs.addrl += 0x800;


//                printf("addrh %x ", info->nand_regs.addrh);
//                printf(" info->nand_regs.addrl: %x\n", info->nand_regs.addrl);


                info->nand_regs.op_num = info->buf_start;
                /*nand cmd set */ 
                info->nand_regs.cmd = 0; 
                info->dma_regs.cmd = 0;
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->write = 1;


/*		printStr("flag is ");printnum(flag);printStr("\r\n");	*/

		if(flag == EXTRA)
			{((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_spare = 1;}
		else if(flag == EDC)
			{((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_main = 1;}
		if(flag == EAE)
			{((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_spare = 1;}

#ifdef USE_ECC
     ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->en_ecc_rd = 1;
     ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->en_ecc_wr = 1;
			{((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_main = 0;}
#endif
   	        ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->cmd_valid = 1;
			
		/*dma regs config*/
#ifdef USE_ECC
                info->dma_regs.length = ALIGN_DMA((WRITE_SIZE/204)*188);
#else
                info->dma_regs.length = ALIGN_DMA(info->buf_start);						
#endif

                ((struct ls1g_nand_dma_cmd *)&(info->dma_regs.cmd))->dma_int_mask = 1;	
                ((struct ls1g_nand_dma_cmd *)&(info->dma_regs.cmd))->dma_r_w = 1;


                dma_setup(DMA_LENGTH|DMA_CMD,info);
               nand_setup(NAND_ADDRL|NAND_ADDRH|NAND_OP_NUM|NAND_CMD,info);				
		break;
            case NAND_CMD_RESET:
                /*Do reset op anytime*/
/*                info->state = STATE_BUSY;*/
               /*nand cmd set */ 
                info->nand_regs.cmd = 0; 
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->reset = 1;
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->cmd_valid = 1; 
                nand_setup(NAND_CMD,info);
                status_time = STATUS_TIME_LOOP_R;
                while(!ls1g_nand_status(info)){
                    if(!(status_time--)){
                        write_z_cmd;
                        break;
                    }
                    delay(50);
                }
/*                info->state = STATE_READY;*/
/*                complete(&info->cmd_complete);*/
		//sysDelay();
                break;
            case NAND_CMD_ERASE1:
                if(info->state == STATE_BUSY){
                    printf("nandflash chip if busy...\n");
                    return;
                }
                info->state = STATE_BUSY;
                /*nand regs set*/
#if 1
                info->nand_regs.addrh =  NO_SPARE_ADDRH(page_addr);
                info->nand_regs.addrl =  NO_SPARE_ADDRL(page_addr) ;
#else
                info->nand_regs.addrh =  SPARE_ADDRH(page_addr);
                info->nand_regs.addrl =  SPARE_ADDRL(page_addr) ;
#endif

               /*nand cmd set */
                info->nand_regs.cmd = 0; 
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->erase_one = 1;
/*                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->erase_con  = 1;*/				
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->cmd_valid = 1;
		    nand_setup(NAND_ADDRL|NAND_ADDRH|NAND_OP_NUM|NAND_CMD,info);
/*                show_dma_regs(0xbfe78000,0);*/
                status_time = STATUS_TIME_LOOP_E;
/*                udelay(3000);    */
                while(!ls1g_nand_status(info)){
                    if(!(status_time--)){
/*                        write_z_cmd;*/
                        break;
                    }
                    delay(50);    
                }
                info->state = STATE_READY;
/*                complete(&info->cmd_complete);*/
			//sysDelay();
                break;
            case NAND_CMD_STATUS:
                if(info->state == STATE_BUSY){
                    printf("nandflash chip if busy...\n");
                    return;
                }
                info->state = STATE_BUSY;
                info->buf_count = 0x1;
                info->buf_start = 0x0;
                *(unsigned char *)info->data_buff=ls1g_nand_status(info) | 0x80;
/*                complete(&info->cmd_complete);*/
						
		delay(50);
                break;
            case NAND_CMD_READID:
		printf("NAND_CMD_READID...........\n");
                if(info->state == STATE_BUSY){
                    printf("nandflash chip if busy...\n");
                    return;
                }
                info->state = STATE_BUSY;
                info->buf_count = 0x4;
                info->buf_start = 0;
               
                   unsigned int id_val_l=0,id_val_h=0;
                   unsigned int timing = 0;
                   unsigned char *data = (unsigned char *)(info->data_buff);
   
                   int i,j;


                   _NAND_SET_REG(0x0,0x21); //read id

               while( *((volatile unsigned int *)(0xbfe78000)) & 400);// 默认是1还是0？ 
               

					while(((id_val_l = _NAND_IDL) & 0xff)  == 0);
					id_val_h = _NAND_IDH;
				   printf("\r\n new \r\n");

				   printf("id_val_l=0x%08x\nid_val_h=0x%08x\n",id_val_l,id_val_h);
   //                _NAND_SET_REG(0xc,timing);
                   data[3]  = (id_val_h & 0xff);
                   data[2]  = (id_val_l & 0xff000000)>>24;
                   data[1]  = (id_val_l & 0x00ff0000)>>16;
                   data[0]  = (id_val_l & 0x0000ff00)>>8;

		   printf("IDS=============================0x%x\n",*((int *)(info->data_buff)));
                    

	   	if((info->data_buff[0] == 0xec) && (info->data_buff[1] == 0xf1))  //??????????????
			printf("(Samsung NAND 128MiB 3,3V 8-bit)\r\n");
		else if ((info->data_buff[3] == 0xc2) && (info->data_buff[2] == 0xf1))
			printf("(MACRONIX NAND MX30LF1G08AA 128MiB 3,3V 8-bit)\r\n");
		else
			printf("unknown NAND Device \r\n");

                break;
			case NAND_CMD_ERASE2:   //erase one block
				retry=1;
			   //for(tmp = 0; (tmp < 7)&&(retry == 1); tmp++)
			  // {
			       tmp = 0;
				   printf("erase times:%d\r\n",tmp++);
					__ww(NAND_REG_BASE+0x0, 0x0);
					__ww(NAND_REG_BASE+0x0, 0x41);
					__ww(NAND_REG_BASE+0x4, 0x00);
				//	__ww(NAND_REG_BASE+0x0, 0x40);//reset nand 
					status_time = STATUS_TIME+100;
//				for(i=0; i<3; i++){ //1024
					printf("erase block num: 0x%08x\r\n", page_addr>>6);
					__ww(NAND_REG_BASE+0x8, page_addr);	//128K
					__ww(NAND_REG_BASE+0x1c, 1);		// one block
					__ww(NAND_REG_BASE+0x0, 0x38);		//erase option
					__ww(NAND_REG_BASE+0x0, 0x39);		//effective
					udelay(2000);
		
					while((*((volatile unsigned int *)(NAND_REG_BASE)) & 0x1<<10) == 0){
						if(!(status_time--)){
							cmd_to_zero;
							status_time = STATUS_TIME;
							printf(" erase nand time out!\r\n");
							break;
						}
						udelay(100);
					}
					retry = verify_erase( page_addr>>6, -1);
					printf("\r\nretry is:%d\r\n",retry);
					udelay(3000000);
			  // }
				/*
			   if (tmp<3)
					printf(" erase block num:%d  ook\r\n",page_addr>>6);	
			   else 
				   printf("erase block wrong!\r\n");
			   */
		        printf("*************************************************\r\n"); 
				break;
            case NAND_CMD_READ1:
/*                complete(&info->cmd_complete);*/
			delay(50);
                break;
            default :
                printf("non-supported command.\n");
/*                complete(&info->cmd_complete);*/
		delay(50);
		break;
        }
/*        wait_for_completion_timeout(&info->cmd_complete,timeout);*/
#if 0
	{
                int status_time1 = STATUS_TIME_LOOP_E;
/*                udelay(3000);    */
	{
		int i = 0;
		for(; i<10000; i++);
	}
	/*	printStr("status ");printnum((*((volatile unsigned int*)0xbfe78014) & (0xff00)));*/
                while(!ls1g_nand_status(info)){
                    if(!(status_time1--)){
/*                        write_z_cmd;*/
				/*printStr(" *******************************************\r\n");*/
                        break;
                    }
		{
			int i = 0;
			for(; i<10000; i++);
		}
             
		}
/*	
		unsigned long dma_cmd;

		dma_cmd = sysInLong(0xbfe78000);

		while((dma_cmd & 0x400) == 0)
		{
			printnum(dma_cmd);printStr(" ");
			dma_cmd = sysInLong(0xbfe78000);
		}
*/
	}

	delay(100);	/*test, it must be take Interrupt way, whb*/
#endif
        if(info->cmd == NAND_CMD_READ0 || info->cmd == NAND_CMD_READOOB ){
            /*cacheGodson2eDCInvalidate((unsigned long)(info->data_buff),info->cac_size);*/
        }
        info->state = STATE_READY;

}

static void ls1g_nand_cmdfunc_oob(unsigned command, int column, int page_addr, int flag)
{
        struct ls1g_nand_info *info = &ls1A_Nand_Info;
        unsigned cmd_prev;
        int status_time,page_prev;
        int timeout = CHIP_DELAY_TIMEOUT;
	int *cmdsPtr = NULL;
/*        init_completion(&info->cmd_complete);*/
        cmd_prev = info->cmd;
        page_prev = info->page_addr;

        info->cmd = command;
        info->page_addr = page_addr;
        switch(command){
#if 1 
            case NAND_CMD_READOOB:
                if(info->state == STATE_BUSY){
                    printf("nandflash chip if busy...\n");
                    return;
                }
/*                    printStr("NAND_CMD_READOOB...\r\n");*/
                info->state = STATE_BUSY; 
                info->buf_count = OOB_SIZE;
                info->buf_start = 0;
                info->cac_size = info->buf_count;
                if(info->buf_count <=0 )
                    break;
                /*nand regs set*/
/*	printStr("page_addr is 0x");printnum(page_addr);printStr("\r\n");*/

                info->nand_regs.addrh = SPARE_ADDRH(page_addr);
                info->nand_regs.addrl = SPARE_ADDRL(page_addr)+0x800;/*0x800  ->    mtd->writesize*/
                info->nand_regs.op_num = info->buf_count;
/*	printStr("info->nand_regs.addrh is 0x");printnum(info->nand_regs.addrh);printStr("\r\n");
	printStr("info->nand_regs.addrl is 0x");printnum(info->nand_regs.addrl);printStr("\r\n");
*/								
               /*nand cmd set */ 
                info->nand_regs.cmd = 0; 
		  info->dma_regs.cmd = 0;

		((struct ls1g_nand_cmdset*)(&(info->nand_regs.cmd)))->read = 1;
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_spare = 1;
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->cmd_valid = 1;
			
                /*dma regs config*/
                info->dma_regs.length =ALIGN_DMA(info->buf_count)+1;
                ((struct ls1g_nand_dma_cmd *)&(info->dma_regs.cmd))->dma_int_mask = 1;	
                /*dma GO set*/       
                dma_setup(DMA_LENGTH|DMA_CMD,info);
                nand_setup(NAND_ADDRL|NAND_ADDRH|NAND_OP_NUM|NAND_CMD,info);	
//       printf("nand read oob......, ok\n"); 			
                break;
#endif
/*            case NAND_CMD_READOOB:*/
            case NAND_CMD_READ0:
                if(info->state == STATE_BUSY){
                    printf("nandflash chip is busy...\n");
                    return;
                }

/*                   printStr("NAND_CMD_READ0...\r\n");*/
                info->state = STATE_BUSY;

//			    printf("NAND_READ0, flag:%d\n", flag);	
                if(flag == EAE)
                    info->buf_count = (WRITE_SIZE + OOB_SIZE);
                else if(flag == EDC)
                    info->buf_count = WRITE_SIZE;

#ifdef USE_ECC
//        info->buf_count = (info->buf_count/204)*204;
#endif



                info->buf_start =  0 ;
                info->cac_size = info->buf_count;
                if(info->buf_count <=0 )
                    break;
				
                info->nand_regs.addrh = SPARE_ADDRH(page_addr);

             	  info->nand_regs.addrl = SPARE_ADDRL(page_addr);
		
//                printf("addrh %x ", info->nand_regs.addrh);
//                printf(" info->nand_regs.addrl: %x\n", info->nand_regs.addrl);
                info->nand_regs.op_num = info->buf_count;
	//		    printf("NAND_READ0, op_num:%d\n", info->buf_count);	
               /*nand cmd set */ 
                info->nand_regs.cmd = 0; 
                info->dma_regs.cmd = 0;
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->read = 1;

             	  ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_main = 1;

                if(flag == EAE)
                    ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_spare = 1;

#ifdef USE_ECC
     ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->en_ecc_rd = 1;
     ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->en_ecc_wr = 1;
     ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->ecc_wait_rd = 1;		//lxy
			{((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_main = 0;}
#endif



                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->cmd_valid = 1; 
                /*dma regs config*/
#ifdef USE_ECC
                info->dma_regs.length = ALIGN_DMA(1880+8+64);
#else
                info->dma_regs.length = ALIGN_DMA(info->buf_count);
#endif
//			    printf("NAND_READ0,DMA op_num:%d\n", info->dma_regs.length);	
                ((struct ls1g_nand_dma_cmd *)&(info->dma_regs.cmd))->dma_int_mask = 1;	

                dma_setup(DMA_LENGTH|DMA_CMD,info);	
                nand_setup(NAND_ADDRL|NAND_ADDRH|NAND_OP_NUM|NAND_CMD,info);
			
                break;

            case NAND_CMD_SEQIN:
                if(info->state == STATE_BUSY){
                    printf("nandflash chip if busy...\n");
                    return;
                }
                info->state = STATE_BUSY;
                info->buf_count = OOB_SIZE + WRITE_SIZE - column;	/*mtd->oobsize + mtd->writesize - column;*/
                info->buf_start = 0;
                info->seqin_column = column;
                info->seqin_page_addr = page_addr;
/*                complete(&info->cmd_complete);*/

                break;

            case NAND_CMD_PAGEPROG:
/*                info->coherent = 0;*/
/*		printStr("in NAND_CMD_PAGEPROG\r\n");*/
                if(info->state == STATE_BUSY){
                    printf("nandflash chip if busy...\n");
                    return;
                }
                info->state = STATE_BUSY;

                if(cmd_prev != NAND_CMD_SEQIN){
                    printf("Prev cmd don't complete...\n");
                    break;
                }
			
                if(info->buf_count <= 0 )
                 {
			printf("     case NAND_CMD_PAGEPROG: break!!!!!!\n");  
				 break;
                }
                /*nand regs set*/
                info->nand_regs.addrh =  SPARE_ADDRH(info->seqin_page_addr);
                info->nand_regs.addrl =  SPARE_ADDRL(info->seqin_page_addr) + info->seqin_column;
                if(flag == EXTRA)
                     info->nand_regs.addrl += 0x800;


//                printf("addrh %x ", info->nand_regs.addrh);
//                printf(" info->nand_regs.addrl: %x\n", info->nand_regs.addrl);


                info->nand_regs.op_num = info->buf_start;
                /*nand cmd set */ 
                info->nand_regs.cmd = 0; 
                info->dma_regs.cmd = 0;
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->write = 1;


/*		printStr("flag is ");printnum(flag);printStr("\r\n");	*/

		if(flag == EXTRA)
			{((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_spare = 1;}
		else if(flag == EDC)
			{((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_main = 1;}
		if(flag == EAE)
			{((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_spare = 1;}

#ifdef USE_ECC
     ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->en_ecc_rd = 1;
     ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->en_ecc_wr = 1;
			{((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->op_main = 0;}
#endif
   	        ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->cmd_valid = 1;
			
		/*dma regs config*/
#ifdef USE_ECC
                info->dma_regs.length = ALIGN_DMA(1880+8+64);
#else
                info->dma_regs.length = ALIGN_DMA(info->buf_start);						
#endif

                ((struct ls1g_nand_dma_cmd *)&(info->dma_regs.cmd))->dma_int_mask = 1;	
                ((struct ls1g_nand_dma_cmd *)&(info->dma_regs.cmd))->dma_r_w = 1;


                dma_setup(DMA_LENGTH|DMA_CMD,info);
               nand_setup(NAND_ADDRL|NAND_ADDRH|NAND_OP_NUM|NAND_CMD,info);				
		break;
            case NAND_CMD_RESET:
                /*Do reset op anytime*/
/*                info->state = STATE_BUSY;*/
               /*nand cmd set */ 
                info->nand_regs.cmd = 0; 
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->reset = 1;
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->cmd_valid = 1; 
                nand_setup(NAND_CMD,info);
                status_time = STATUS_TIME_LOOP_R;
                while(!ls1g_nand_status(info)){
                    if(!(status_time--)){
                        write_z_cmd;
                        break;
                    }
                    delay(50);
                }
/*                info->state = STATE_READY;*/
/*                complete(&info->cmd_complete);*/
		//sysDelay();
                break;
            case NAND_CMD_ERASE1:
                if(info->state == STATE_BUSY){
                    printf("nandflash chip if busy...\n");
                    return;
                }
                info->state = STATE_BUSY;
                /*nand regs set*/
#if 1
                info->nand_regs.addrh =  NO_SPARE_ADDRH(page_addr);
                info->nand_regs.addrl =  NO_SPARE_ADDRL(page_addr) ;
#else
                info->nand_regs.addrh =  SPARE_ADDRH(page_addr);
                info->nand_regs.addrl =  SPARE_ADDRL(page_addr) ;
#endif

               /*nand cmd set */
                info->nand_regs.cmd = 0; 
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->erase_one = 1;
/*                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->erase_con  = 1;*/				
                ((struct ls1g_nand_cmdset*)&(info->nand_regs.cmd))->cmd_valid = 1;
		    nand_setup(NAND_ADDRL|NAND_ADDRH|NAND_OP_NUM|NAND_CMD,info);
/*                show_dma_regs(0xbfe78000,0);*/
                status_time = STATUS_TIME_LOOP_E;
/*                udelay(3000);    */
                while(!ls1g_nand_status(info)){
                    if(!(status_time--)){
/*                        write_z_cmd;*/
                        break;
                    }
                    delay(50);    
                }
                info->state = STATE_READY;
/*                complete(&info->cmd_complete);*/
			//sysDelay();
                break;
            case NAND_CMD_STATUS:
                if(info->state == STATE_BUSY){
                    printf("nandflash chip if busy...\n");
                    return;
                }
                info->state = STATE_BUSY;
                info->buf_count = 0x1;
                info->buf_start = 0x0;
                *(unsigned char *)info->data_buff=ls1g_nand_status(info) | 0x80;
/*                complete(&info->cmd_complete);*/
						
		delay(50);
                break;
            case NAND_CMD_READID:
		printf("NAND_CMD_READID...........\n");
                if(info->state == STATE_BUSY){
                    printf("nandflash chip if busy...\n");
                    return;
                }
                info->state = STATE_BUSY;
                info->buf_count = 0x4;
                info->buf_start = 0;
                /*
                 * read id use GPIO
                 *
                 * */
#if 0
                *((int *)(info->data_buff)) = nand_gpio_read_id();
			printStr("IDS=============================0x");printnum(*((int *)(info->data_buff)));printStr("\r\n");				
#endif			
/*                printf(KERN_ERR "IDS=============================0x%x\n",*((int *)(info->data_buff)));*/

               {

                   unsigned int id_val_l=0,id_val_h=0;
                   unsigned int timing = 0;
                   unsigned char *data = (unsigned char *)(info->data_buff);
   
                   int i,j;

/*
    j = 0;
	printf("0xbfd00414: 0x%x\n",*(volatile int *)0xbfd00414);
    /for(i=0; i<20; i++ )
    {
    	printf("0xbfe780%2x: 0x%x\n",j,*(volatile int *)(0xbfe78000+j));
        j += 4;
    }

printf("-----------------------------------------------\n");
    *(volatile int *)0xbfd00414 = 0xe0000246;
*/

//                   _NAND_READ_REG(0xc,timing);

  //                 _NAND_SET_REG(0xc,0x30f0); 
                   _NAND_SET_REG(0x0,0x21); 

               while( *((volatile unsigned int *)(0xbfe78000)) & 400); 

                   while(((id_val_l |= _NAND_IDL) & 0xff)  == 0){
                       id_val_h = _NAND_IDH;
                      id_val_h = *(volatile int *)0xbfe78014; 

                   }

                  printf("id_val_l=0x%08x\nid_val_h=0x%08x\n",id_val_l,id_val_h);
   //                _NAND_SET_REG(0xc,timing);
                   data[0]  = (id_val_h & 0xff);
                   data[1]  = (id_val_l & 0xff000000)>>24;
                   data[2]  = (id_val_l & 0x00ff0000)>>16;
                   data[3]  = (id_val_l & 0x0000ff00)>>8;
/*                printf(KERN_ERR "IDS=============================0x%x\n",*((int *)(info->data_buff)));*/
		   printf("IDS=============================0x%x\n",*((int *)(info->data_buff)));
                    

	   	if((info->data_buff[0] == 0xec) && (info->data_buff[1] == 0xf1))
			printf("(Samsung NAND 128MiB 3,3V 8-bit)\r\n");
		else
			printf("unknown NAND Device \r\n");

               }
/*                info->state = STATE_READY;*/
/*                complete(&info->cmd_complete);*/
		//sysDelay();
                break;
            case NAND_CMD_ERASE2:
            case NAND_CMD_READ1:
/*                complete(&info->cmd_complete);*/
			delay(50);
                break;
            default :
                printf("non-supported command.\n");
/*                complete(&info->cmd_complete);*/
		delay(50);
		break;
        }
/*        wait_for_completion_timeout(&info->cmd_complete,timeout);*/
#if 0
	{
                int status_time1 = STATUS_TIME_LOOP_E;
/*                udelay(3000);    */
	{
		int i = 0;
		for(; i<10000; i++);
	}
	/*	printStr("status ");printnum((*((volatile unsigned int*)0xbfe78014) & (0xff00)));*/
                while(!ls1g_nand_status(info)){
                    if(!(status_time1--)){
/*                        write_z_cmd;*/
				/*printStr(" *******************************************\r\n");*/
                        break;
                    }
		{
			int i = 0;
			for(; i<10000; i++);
		}
             
		}
/*	
		unsigned long dma_cmd;

		dma_cmd = sysInLong(0xbfe78000);

		while((dma_cmd & 0x400) == 0)
		{
			printnum(dma_cmd);printStr(" ");
			dma_cmd = sysInLong(0xbfe78000);
		}
*/
	}

	delay(100);	/*test, it must be take Interrupt way, whb*/
#endif
        if(info->cmd == NAND_CMD_READ0 || info->cmd == NAND_CMD_READOOB ){
            /*cacheGodson2eDCInvalidate((unsigned long)(info->data_buff),info->cac_size);*/
        }
        info->state = STATE_READY;

}

static char wait_NandDma(void)
{
#if 0
    struct ls1g_nand_info *info = &ls1A_Nand_Info;
	struct ls1g_nand_dma_desc *dma_base = (volatile struct ls1g_nand_dma_desc *)(info->drcmr_dat);

	*(volatile unsigned int *)info->order_reg_addr = ((unsigned int )info->drcmr_dat_phys) | 0x1<<2;
	while (*(volatile unsigned int *)info->order_reg_addr & 0x4 )delay(1);	

	while(dma_base->cmd & 0x4);

    dma_base->cmd &= ~0x4;
#else
    
        struct ls1g_nand_info *info = &ls1A_Nand_Info;
   unsigned int time_cyc; 
    while(1)
    {
       if(((*(volatile unsigned int *)0xbfe78000) & 0x400) != 0){ 
        time_cyc = *(volatile unsigned int *)0xbfe5c000; 
        break;
       }
/*
        printf("0x%x ", *(volatile unsigned int *)0xbfe78000);
        printf("0x%x ", *(volatile unsigned int *)0xbfe78004);
        printf("0x%x ", *(volatile unsigned int *)0xbfe78008);
        printf("0x%x ", *(volatile unsigned int *)0xbfe7800c);
        printf("0x%x ", *(volatile unsigned int *)0xbfe78010);
        printf("0x%x ", *(volatile unsigned int *)0xbfe78014);
        printf("0x%x ", *(volatile unsigned int *)0xbfe78018);
        printf("0x%x ", *(volatile unsigned int *)0xbfe7801c);
        printf("0x%x \n", *(volatile unsigned int *)0xbfe78020);
*/
    }
/*
    if(((*(volatile unsigned int *)0xbfe78000) & 0x2) != 0) 
         printf("addrh_r=%x,time=%d cycls", info->nand_regs.addrh,time_cyc);
    else
         printf("addrh_w=%x,time=%d cycls", info->nand_regs.addrh,time_cyc);
*/
#endif
   // printf("\n");
	return 0;
}

void nand_write_ecc_test(int argc, char **argv)
{
#define	NAND_PAGE_SIZE	0x840
#define	DMA_PAGE_SIZE	(1880+8+64)
	unsigned char *buf = (unsigned char *)0xa1a80000;
	unsigned int	k;
	unsigned char *p;
	int flag;
	p = (volatile unsigned char *)0xbf000000;
	struct ls1g_nand_info *info = &ls1A_Nand_Info;

	nand_probe_boot();

	for (k = 0; k < DMA_PAGE_SIZE; k++, p++) {
		buf[k] = *p;
	}

	flag = EAE;
	ls1g_nand_cmdfunc_oob(NAND_CMD_SEQIN, 0x00, 0, flag);
	info->data_buff  = buf;
	k = (unsigned int)buf;
	info->data_buff_phys = (unsigned char *)(k & 0x1fffffff);
	info->buf_start = NAND_PAGE_SIZE; 

	info->dma_saddr = info->data_buff_phys;

	/*	ls1g_nand_write_buf(buffer+2048, 64);*/
	*(volatile unsigned int *)0xbfd01160 = 0x10;        //DMA STOP

	ls1g_nand_cmdfunc_oob(NAND_CMD_PAGEPROG, 0, -1, flag);	
	wait_NandDma();

	memset (buf, 0, DMA_PAGE_SIZE);
	*(volatile unsigned int *)0xbfd01160 = 0x10;        //DMA STOP
	k = (unsigned int)buf;
	info->data_buff_phys =(unsigned char *)(k & 0x1fffffff);
	info->dma_saddr = info->data_buff_phys;
	ls1g_nand_cmdfunc_oob(NAND_CMD_READ0, 0, 0, flag);
	wait_NandDma();

	p = (volatile unsigned char *)0xbf000000;
	for (k = 0; k < DMA_PAGE_SIZE; k++) {
		if (buf[k] != p[k])
			printf ("ecc Verify error at %d, 0x%2x -> 0x%2x !\n", k , buf[k], p[k]);
	}

}

static const Cmd Cmds[] =
{
   {"MyCmds"},
   {"nand_write_ecc_test", "", 0, "test nand_ecc", nand_write_ecc_test, 0, 99, 0},
   {0, 0}
};

static void init_cmd __P((void)) __attribute__ ((constructor));

static void
   init_cmd()
{
   cmdlist_expand(Cmds, 1);
}
