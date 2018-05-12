
/*************************************************************************
    > Filename: ucas_cde.h
    > Author: xingjinzhang
    > Mail: xingjinzhang@loongson.cn
    > Date: 2017-09-24
 ************************************************************************/

//soc confreg
#define UART_ADDR               0xfffffff0
#define SIMU_FLAG_ADDR          0xfffffff4
#define LED_ADDR                0xfffff000
#define LED_RG0_ADDR            0xfffff004
#define LED_RG1_ADDR            0xfffff008
#define NUM_ADDR                0xfffff010

#define LI(reg, imm) \
    li reg, imm

