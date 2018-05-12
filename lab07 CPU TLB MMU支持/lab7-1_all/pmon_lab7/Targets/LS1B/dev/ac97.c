
/***************************************************
 *
 *
 ***************************************************
 */
#include <pmon.h>
#include <linux/types.h>
#define udelay delay
#define ac97_base 0xbfe74000  // 0xbfe74000
#define confreg_base 0xbfd00000
#define dma_base  0xbfe74080  //0xbf004280
#define ac97_reg_write(addr ,val) do{ *(volatile u32 *)(ac97_base+(addr))=val; }while(0)
#define ac97_reg_read(addr) *(volatile u32 * )(ac97_base+(addr))
//#define udelay(n)   
#define dma_reg_write(addr ,val) do{ *(volatile u32 *)(dma_base+(addr))=val; }while(0)
//#define dma_reg_read(addr) *(volatile u32 * )(dma_base+(addr))
#define dma_reg_read(addr) *(volatile u32 *)(addr)
#define codec_wait(n) do{ int __i=n;\
        while (__i-->0){ \
            if (ac97_reg_read(0x5c)&0x3!=0) break;\
            udelay(100); }\
            if (__i>0){ \
                ac97_reg_read(0x6c);\
                ac97_reg_read(0x68);\
            }\
        }while (0)

//yq:0x70-->0x68
        
#define DMA_BUF 0x00800000
#define  BUF_SIZE 0x200000        //0x200000
//#define  BUF_SIZE 0x7000
#define SYNC_W 1    //sync cache for writing data
#define CPU2FIFO 1

#define AC97_RECORD 0
#define AC97_PLAY   1 

#define REC_DMA_BUF   (DMA_BUF+ BUF_SIZE)        //0x00a00000
#define  REC_BUF_SIZE  (BUF_SIZE>>1)

 

static unsigned short sample_rate=0xac44;

static int ac97_rw=0;

//static unsigned u32 *dma_rec_des_base=(unsigned u32*)(DMA_DESC_BASE);
//static unsigned u32  *dma_play_des_base=dma_rec_des_base;
static struct desc{
	u32 ordered;
	u32 saddr;
	u32 daddr;
	u32 length;
	u32 step_length;
	u32 step_times;
	u32 cmd;
};


static struct desc *DMA_DESC_BASE;
static struct desc *dma_desc2_addr;

static u32 play_desc1[7]={
	0x1,                       //need to be filled
	DMA_BUF&0x1fffffff,     
	0xdfe72420,                    //(ac97_base&0x9fffffff)+0x20,           //9fffffff?fun
	
	0x8,
	0x0,
	(BUF_SIZE/8/4),
	0x00001001
};

static u32 play_desc2[7]={
	0x00001,
	DMA_BUF&0x1fffffff,
	0xdfe72420,                                //( ac97_base&0x9fffffff)+0x20,
	0x6,
	0x0,
	(BUF_SIZE/8/6/2),
	0x00001001	
};

static u32 rec_desc1[7]={
	0x0,                       //need to be filled
	//0xdfe72420,
	(REC_DMA_BUF|0xa0000000)&0x1fffffff,                    //(ac97_base&0x9fffffff)+0x20,           //9fffffff?func
	0x9fe74c4c,
	0x8,
	0x0,
	0x4000,
	0x00000001
};

static u32 rec_desc2[7]={
	0x00001200,                       //need to be filled   
	//0xdfe72420,                    //(ac97_base&0x9fffffff)+0x20,           //9fffffff?func
	(REC_DMA_BUF|0xa0000000)&0x1fffffff,                    //(ac97_base&0x9fffffff)+0x20,      //9fffffff?func
	0x9fe74c4c,
	0x6,
	0x0,
	0x30,
	0x00000001
};



 void  init_audio_data(void )
 {
 
 //    volatile unsigned int *data= (volatile unsigned int*)(DMA_BUF|0xa0000000);
  
     unsigned int *data= (unsigned int*)(DMA_BUF|0xa0000000);
   
   int i;


   //;data=(unsigned int *)malloc(BUF_SIZE*sizeof(int));
   
  for (i=0;i<((BUF_SIZE)>>3);i++)
   {     
	//printf("===data=%x\n",data);
	//printf("==data=%x,   %x\n",(data+(i*8)),(i*8));
        data[i*2]=0x7fffe000;
	//printf("===data=%x,   %x\n",(data+(i*8+4)),(i*8+4));
        data[i*2+1]=0x1f2e3d4c;
   }
  
//   memset()
   //CPU_IOFlushDCache((DMA_BUF|0xa0000000),BUF_SIZE,SYNC_W);
   for(i=0;i<40;i++){
	   printf("%x:  data:%x\n",((DMA_BUF|0xa0000000)+(i*4)),*(volatile unsigned int *)(DMA_BUF|0xa0000000+(i*4)));
	
	   
   }
   printf("=======init audio data complete\n");
  
 }
 
int ac97_config()
 {
     int i=0;
    printf("ac97 config enter===\n");
    /*
    ac97_reg_write(0x58,0x0000036f);
    ac97_reg_write(0x4,0x6b6b6b6b);
    ac97_reg_write(0x10,0x006b6b6b);
    */
    
    //ac97_reg_write(0x4,0x6969|0x202); //OCCR0   L&& R enable ; 3/4 empty; dma enabled;16bits;var rate(0x202);
      ac97_reg_write(0x4,0x6b6b6b6b);
    
    //ac97_reg_write(0x4,0x6969); //OCCR0   L&& R enable ; 3/4 empty; dma enabled;16 bits;fix rate;
    printf("OCCR0 complete:%x\n",ac97_reg_read(0x4));
    ac97_reg_write(0x10,0x006b6b6b);
    //ac97_reg_write(0x10,0x690000|0x20000);//ICCR
    printf("ICCR complete\n");
    ac97_reg_write(0x58,0x3); //INTM
    printf("INTM complete\n");
    //codec
    ac97_reg_write(0x18,0x0|(0x0<<16)|(0<<31)); //codec reset
    
    codec_wait(10);

    printf("register 0x18 content1:%x\n",ac97_reg_read(0x18)&0xffffffff);
    ac97_reg_write(0x18,0|(0x0<<16)|(0<<31));
    codec_wait(10);
    printf("======0x00:%x\n",ac97_reg_read(0x0)&0xffffffff);
    ac97_reg_write(0x18,0|(0x7c<<16)|(1<<31));    //codec register addr(read)
    
    //printf("register 0x18 content1:%x\n",ac97_reg_read(0x18));
    codec_wait(10);

    printf("register 0x18 content2:%x\n",ac97_reg_read(0x18));
    printf("codec id %x \n",ac97_reg_read(0x18)&0xffff); //read ID 
    
    for(i=5;i>0;i--){
    	ac97_reg_write(0x18,0x0|(0x26<<16)|(1<<31));
    	codec_wait(10);
    	printf("=====D/A status:%x\n",ac97_reg_read(0x18)&0xffffffff);
    }
    
    ac97_reg_write(0x18,0x0808|(0x2<<16)|(0<<31));      //Master Vol. data=0x0808
    printf("register 0x18 Master Vol.content2:%x\n",ac97_reg_read(0x18));
    codec_wait(10);
    ac97_reg_write(0x18,0x0808|(0x4<<16)|(0<<31));      //headphone Vol.
    
    codec_wait(10);

    ac97_reg_write(0x18,0x0008|(0x6<<16)|(0<<31));      //headphone Vol.
    
    codec_wait(10);

    ac97_reg_write(0x18,0x0008|(0xc<<16)|(0<<31));      //phone Vol.
    
    codec_wait(10);
     
    ac97_reg_write(0x18,0x0808|(0x18<<16)|(0<<31));     //PCM Out Vol.
    
    codec_wait(10);
    
    ac97_reg_write(0x18,0x1|(0x2A<<16)|(0<<31));        //Extended Audio Status  and control
    
    codec_wait(10);
    
    ac97_reg_write(0x18,sample_rate|(0x2c<<16)|(0<<31));     //PCM Out Vol. FIXME:22k can play 44k wav data?
    
    codec_wait(10);
	//////////////////////
    if (ac97_rw==AC97_RECORD) //record
    {
	    printf("===record config\n");
            ac97_reg_write(0x18,sample_rate|(0x32<<16)|(0<<31));     //ADC rate .
    
            codec_wait(10);

            ac97_reg_write(0x18,0x035f|(0x0E<<16)|(0<<31));     //Mic vol .
    
            codec_wait(10);

            ac97_reg_write(0x18,0x0f0f|(0x1E<<16)|(0<<31));     //MIC Gain ADC.
    
            codec_wait(10);

            ac97_reg_write(0x18,sample_rate|(0x34<<16)|(0<<31));     //MIC rate.
    
            codec_wait(10);
        //0x1a  sele
    }

   printf("exit\n"); 
   return 0;
 }


	
void dma_config(void){	
	int i=10000;
	u32 addr;
	u32 addr2;
	
	DMA_DESC_BASE=(struct desc*)malloc(sizeof(struct desc)+32);
	addr = DMA_DESC_BASE=((u32)DMA_DESC_BASE+31)&~31;
			
	printf("======addr:%x\n",DMA_DESC_BASE);
	dma_desc2_addr=(struct desc*)malloc(sizeof(struct desc)+32);
	addr2 = dma_desc2_addr = ((u32)dma_desc2_addr+31)&~31;
	printf("===addr2:%x\n",dma_desc2_addr);
	
     if (AC97_PLAY==ac97_rw) //play
      {
	 DMA_DESC_BASE->ordered=play_desc1[0]|(addr2&0x1fffffff);    ///addr&0xffffffe0;
	 DMA_DESC_BASE->saddr=play_desc1[1];   //0x00010000;//addr&0x1fffffff;
	 DMA_DESC_BASE->daddr=play_desc1[2];
	 DMA_DESC_BASE->length=play_desc1[3];
	 DMA_DESC_BASE->step_length=play_desc1[4];
	 DMA_DESC_BASE->step_times=play_desc1[5];
	 DMA_DESC_BASE->cmd=play_desc1[6];
	 printf("========play1\n");
	 CPU_IOFlushDCache((unsigned long)addr,32*7,SYNC_W);
	 
	 printf("====desc:%x;%x,%x,%x,%x\n",DMA_DESC_BASE->ordered,DMA_DESC_BASE->saddr,DMA_DESC_BASE->daddr,DMA_DESC_BASE->length,DMA_DESC_BASE->step_times);	 
	 printf("====mem desc:%x,%x\n",*(volatile unsigned int*)(addr),*(volatile unsigned int*)(addr+4));
	 dma_desc2_addr->ordered=play_desc2[0]|(addr&0x1fffffff);
	 dma_desc2_addr->saddr=play_desc2[1];//0x00001000;//addr2&0x1fffffff;                     //play_desc2[1];
	 dma_desc2_addr->daddr=play_desc2[2];
	 dma_desc2_addr->length=play_desc2[3];
	 dma_desc2_addr->step_length=play_desc2[4];
	 dma_desc2_addr->step_times=play_desc2[5];
	 dma_desc2_addr->cmd=play_desc2[6];
	 CPU_IOFlushDCache((unsigned long)addr2,32*7,SYNC_W);
	 printf("===play2");
	 printf("====desc2:%x\n",dma_desc2_addr->ordered);
    
	 addr=(u32)(addr&0x1fffffff);
     
         printf("====addr:%x\n",addr);
         printf("====addr':%x",addr|0x00000009);
         do{
	     *(volatile u32*)(confreg_base+0x1160)=addr|0x00000009;
	     delay(1000000);	
             printf("dma register:%x\n",(*(volatile u32*)(confreg_base+0x1160)));
	  
          }while(0);
      }
     else       //record
     {	    
	     
	 DMA_DESC_BASE->ordered=rec_desc1[0]|(addr2&0x1fffffff);    ///addr&0xffffffe0;
	 DMA_DESC_BASE->saddr=rec_desc1[1];   //0x00010000;//addr&0x1fffffff;
	 DMA_DESC_BASE->daddr=rec_desc1[2];
	 DMA_DESC_BASE->length=rec_desc1[3];
	 DMA_DESC_BASE->step_length=rec_desc1[4];
	 DMA_DESC_BASE->step_times=rec_desc1[5];
	 DMA_DESC_BASE->cmd=rec_desc1[6];
	 printf("========rec1\n");
	 CPU_IOFlushDCache((unsigned long)addr,32*7,SYNC_W);
	 
	 printf("====rec desc:%x;%x,%x,%x,%x\n",DMA_DESC_BASE->ordered,DMA_DESC_BASE->saddr,DMA_DESC_BASE->daddr,DMA_DESC_BASE->length,DMA_DESC_BASE->step_times);	 
	 dma_desc2_addr->ordered=rec_desc2[0];
	 dma_desc2_addr->saddr=rec_desc2[1];//0x00001000;//addr2&0x1fffffff;                     //play_desc2[1];
	 dma_desc2_addr->daddr=rec_desc2[2];
	 dma_desc2_addr->length=rec_desc2[3];
	 dma_desc2_addr->step_length=rec_desc2[4];
	 dma_desc2_addr->step_times=rec_desc2[5];
	 dma_desc2_addr->cmd=rec_desc2[6];
	 CPU_IOFlushDCache((unsigned long)addr2,32*7,SYNC_W);
	 printf("===rec2");
	 printf("====desc2:%x\n",dma_desc2_addr->ordered);
 
	 addr=(u32)(addr&0x1fffffff);    
         printf("====addr:%x\n",addr);
         printf("====addr':%x",addr|0x0000000a);
        do{
	     *(volatile u32*)(confreg_base+0x1160)=addr|0x0000000a;
	     delay(1000);	
             printf("dma register:%x\n",(*(volatile u32*)(confreg_base+0x1160)));
	  
          }while(0);
     }

}


 /*void dma_setup_trans(u32 * src_addr,u32 size)
 {
    
    if (AC97_PLAY==ac97_rw) //play
    {
            dma_reg_write(0x0,src_addr);
            dma_reg_write(0x4,size>>2);
    }
    else //record
    {
        dma_reg_write(0x10,src_addr);
        dma_reg_write(0x14,size>>2);
    }
 }*/

 int ac97_test(int argc,char **argv)
 {
    
	char cmdbuf[100];
    int i;
    
	if(argc!=2 && argc!=1)return -1;
	if(argc==2){
	sprintf(cmdbuf,"load -o 0x%x -r %s",DMA_BUF|0xa0000000,argv[1]);
	do_cmd(cmdbuf);
	}
   
    ac97_rw=AC97_PLAY;
   
   // init_audio_data();
   // ac97_config();
    
    dma_config();
    
    //printf("%d\n",dma_reg_read(0x8));
    //printf("%d\n",dma_reg_read(0xc));
   
    //dma_setup_trans(DMA_BUF,BUF_SIZE);
 
        
    //printf("%d\n",dma_reg_read(0x8));
    //printf("%d\n",dma_reg_read(0xc));

    delay(100);
    printf("play data on 0x%x,sz=0x%x\n",(DMA_BUF|0xa0000000),BUF_SIZE);

    do{
	    *(volatile u32*)(confreg_base+0x1160)=0x00200005;
    }while(0);
    delay(100);
  
    printf("dma state1:%x\n%x\n%x\n%x\n%x\n",dma_reg_read(0xa0200004),dma_reg_read(0xa0200008),dma_reg_read(0xa020000c),dma_reg_read(0xa0200014),dma_reg_read(0xa0200018));
    delay(1000);

    do{
	    *(volatile u32*)(confreg_base+0x1160)=0x00200005;
    }while(0);
    delay(100);
  
    printf("dma state2:%x\n%x\n%x\n%x\n%x\n",dma_reg_read(0xa0200004),dma_reg_read(0xa0200008),dma_reg_read(0xa020000c),dma_reg_read(0xa0200014),dma_reg_read(0xa0200018));
   
	    //1.wait a trans complete
	    //
       // while(((dma_reg_read(0x2c))&0x1)==0)
	//	idle();
        
        //2.clear int status  bit.
        //dma_reg_write(0x2c,0x1);

return 0;
 }

int ac97_read(int argc,char **argv)
{
    int i,l;
    unsigned int j;
    unsigned int k;
    unsigned int m;

     unsigned short * rec_buff;
     unsigned int  *  ply_buff;
    ac97_rw=AC97_RECORD;
    
    init_audio_data();
    
    /*1.dma_config read*/
    
    /*2.ac97 config read*/
    
     ac97_config();
     dma_config();

    /*3.set dma desc*/
    printf("wait 5s ");
    for(i=0;i<5;i++)	    
    {
        udelay(1000000);
        printf("."); 
    }
    printf("rec done\n");
    delay(10000);
    do{
	    *(volatile u32*)(confreg_base+0x1160)=0x00200006;
    }while(0);
    delay(5000);
  
    printf("dma state1:%x\n%x\n%x\n%x\n%x\n",dma_reg_read(0xa0200004),dma_reg_read(0xa0200008),dma_reg_read(0xa020000c),dma_reg_read(0xa0200014),dma_reg_read(0xa0200018));
    
    //dma_setup_trans(REC_DMA_BUF,REC_BUF_SIZE);
    
    /*4.wait dma done,return*/ 
    //while(((dma_reg_read(0x2c))&0x8)==0)
      //   udelay(1000);//1 ms 

    //dma_reg_write(0x2c,0x8);
    /*5.transform single channel to double channel*/
    //l = 0;
    //printf("record complete\n");
    
   // printf("%d\n",sizeof(short));
   
   rec_buff=( unsigned short * )(REC_DMA_BUF|0xa0000000);
    ply_buff=( unsigned int * )(DMA_BUF|0xa0000000);
    
    
    for(i=0;i<(REC_BUF_SIZE<<1);i++)
    {
        j = 0x0000ffff & (unsigned int) rec_buff[i];
        
        //ply_buff[i]=(rec_buff[i]<<16)|(rec_buff[i]);
        ply_buff[i]=(j<<16)|(j);
    }
    
    /*
    for(i=0;i<REC_BUF_SIZE;i++)
    {
         j = *((int *)((i<<2)+(0xa0000000|REC_DMA_BUF)));
         
         k = j<<16;
         m = j>>16;
         
         *((volatile unsigned int *)((l<<2)+(0xa0000000|DMA_BUF))) = (k & 0xffff0000)|(j & 0xffff);
         *((volatile unsigned int *)((l<<2)+(0xa0000004|DMA_BUF))) = (j & 0xffff0000)|(m & 0xffff);
         l = l+2;
     }
     */

return 0;
}



static const Cmd Cmds[] =
{
	{"MyCmds"},
	{"ac97_test","file",0,"ac97_test file",ac97_test,0,99,CMD_REPEAT},
	{"ac97_read","",0,"ac97_read",ac97_read,0,99,CMD_REPEAT},
	{"ac97_config","",0,"ac97_config",ac97_config,0,99,CMD_REPEAT},
	{0, 0}
};

static void init_cmd __P((void)) __attribute__ ((constructor));

static void
init_cmd()
{
	cmdlist_expand(Cmds, 1);
}

