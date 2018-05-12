#include <pmon.h>
#include <stdlib.h>
#include <stdio.h>

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
#define GC0308_ADDRESS 0x42

//static unsigned char *mem_ptr = CAM_MEM_BASE;
static  fb_xsize, fb_ysize;

/*
static void camera_intr_handler(void *)
{
    
}
*/
unsigned char gc0308_data1[][2] = {
    {0x00, 0x00},
    {0x00, 0xa2},
    {0x00, 0x0f},
    {0x00, 0x02},
};
unsigned char gc0308_windows[][2] = {
    {0x05,0x00},
    {0x06,0x00},
    {0x07,0x00},
    {0x08,0x00},
    {0x09,0x01},
    {0x0a,0xe8},
    {0x0b,0x02},
    {0x0c,0x88},
   
};
unsigned char gc0308_output[][2] = {
    {0x24,0xa6},
};
void set_gc0308_config()
{
    unsigned char i;
    unsigned char *dev_add;
   *dev_add = GC0308_ADDRESS;
   printf("start set gc0308 config\n");
   for(i = 0 ; i < 8; i++)
   {
      tgt_i2cwrite(I2C_SINGLE, dev_add, 1, gc0308_windows[i][0], gc0308_windows[i]+1, 1);     
        
   }
     
   tgt_i2cwrite(I2C_SINGLE, dev_add, 1, gc0308_output[0][0], gc0308_output[0]+1, 1);     
   printf("set gc0308 config ok\n");
    
}
void gc0308_test_type()
{
    unsigned char i;
    unsigned char *dev_add;
    unsigned char read_buf[4];
    *dev_add = GC0308_ADDRESS;

//    for (i=0; i<4; i++)
  //  {
    //    tgt_i2cwrite(I2C_SINGLE, dev_add, 1, gc0308_data[i][0], gc0308_data[i]+1, 1);     
   // }
    
    for (i=0; i<4; i++)
    {
        tgt_i2cread(I2C_SINGLE, dev_add, 1, gc0308_data1[i][0], read_buf+i, 1);
    }

    printf("read data from gc0308: \n");
    for (i=0; i<4; i++)
        printf (" 0x%x, ", read_buf[i]);
    printf ("\n");
}


unsigned char Gc0308_Data[][2] = {
    {0x24,0x00},
};
unsigned char get_camera_type()
{
    unsigned char read_buf;
    unsigned char *dev_add;
    *dev_add = GC0308_ADDRESS;
    tgt_i2cread(I2C_SINGLE,dev_add,1,Gc0308_Data[0][0],read_buf,1);
    return read_buf;
}

void flush_framebuffer2_6()
{
    unsigned int i;
    for(i = 0 ; i <= 640*480*2; i+=4)
    {
        *(volatile unsigned int*)(CAM_MEM_BASE + i)= 0xffffffff ; 
    }    
}
void flush_framebuffer3_6()
{
    unsigned int i;
    for(i = 0 ; i <= 640*480*2; i+=4)
    {
        *(volatile unsigned int*)(CAM_MEM_BASE + i)= 0; 
    }    
}

void flush_framebuffer3()
{
    unsigned int i;
    for(i = 0 ; i <= 800*600*2; i+=4)
    {
        *(volatile unsigned int*)(CAM_MEM_BASE + i)= 0; 
    }    
}

void flush_framebuffer2()
{
    unsigned int i;
    for(i = 0 ; i <= 800*600*2; i+=4)
    {
        *(volatile unsigned int*)(CAM_MEM_BASE + i)= 0xffffffff ; 
    }    
}
void flush_framebuffer()
{
    unsigned int i;
    for(i = 0 ; i <= 800*600*2; i+=4)
    {
        *(volatile unsigned int*)(CAM_MEM_BASE + i)= 0xffff ; 
    }    
}
void cameraif_init()
{
    unsigned int pic_size;
    unsigned int value;
    printf("start camera init\n");
    fb_xsize  = getenv("xres")? strtoul(getenv("xres"),0,0):FB_XSIZE;
    fb_ysize  = getenv("yres")? strtoul(getenv("yres"),0,0):FB_YSIZE;
    pic_size = fb_xsize * fb_ysize;

    *(volatile unsigned int *)(CAMERA_BASE + DMA0_CONFIG) = CAM_MEM_BASE &0x0fffffff; 
    *(volatile unsigned int *)(CAMERA_BASE + DMA1_CONFIG) = CAM_MEM_BASE &0x0fffffff;
    *(volatile unsigned int *)(CAMERA_BASE + DMA2_CONFIG) = CAM_MEM_BASE &0x0fffffff;
    *(volatile unsigned int *)(CAMERA_BASE + DMA3_CONFIG) = CAM_MEM_BASE &0x0fffffff;

/*
    *(volatile unsigned int *)(CAMERA_BASE + DMA1_CONFIG) = CAM_MEM_BASE + pic_size;
    *(volatile unsigned int *)(CAMERA_BASE + DMA2_CONFIG) = CAM_MEM_BASE + (pic_size << 1);
    *(volatile unsigned int *)(CAMERA_BASE + DMA3_CONFIG) = CAM_MEM_BASE + (pic_size * 3);
*/
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
    value = (1 << 31) |(1 << 13) | (1 << 7) |(1 << 2);
    *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG) = value;
    printf("cameraif init ok\n");

 //   value = (1<<13) | (1<<11) | (1<<7) | (1<<0);    
 //   *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG) = value;
   // *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG) |= 0x80000000;
//    pci_intr_establish(0, 0, IPL_BIO, camera_intr_handler, 0, 0);
}
int get_camif_state()
{
return *(volatile unsigned int *)(CAMERA_BASE + CAMIF_CONFIG);   
}
void camera_test()
{
    //gc0308_test();
    gc0308_test_type();
  // camera_type = get_camera_type();
  //  printf("0x%x\n",camera_type);

}
void camera_run()
{
    printf("start run the camera\n");
    set_gc0308_config();

    cameraif_init();
    // flush_framebuffer();

}

void camera_run_black() { flush_framebuffer2_6(); }
void camera_run_write() { flush_framebuffer3_6(); }

static const Cmd Cmds[] =
 {
     {"MyCmds"},
     {"camera_run","",0,"camera_run",camera_run,0,99,CMD_REPEAT},
     {"camera_run_black","",0,"camera_run_black",camera_run_black,0,99,CMD_REPEAT},
     {"camera_run_write","",0,"camera_run_write",camera_run_write,0,99,CMD_REPEAT},
     {"camera_test","",0,"camera_test",camera_test,0,99,CMD_REPEAT},
     {0,0}
 };

 static void init_cmd __P((void)) __attribute__ ((constructor));

 static void init_cmd()
 {
     cmdlist_expand(Cmds, 1);
 }

