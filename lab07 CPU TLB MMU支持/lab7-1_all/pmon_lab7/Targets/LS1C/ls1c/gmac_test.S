#include "regdef.h"
//#include "mipsregs.h"
//#include "cacheops.h"

#define MODE_MII
## #define SPEED_10
#define GPIO_CTRL_H            0xbfd00000 + 0x0424 
#define FIRST_EN0              0xbfd00000 + 0x11c0
#define FIRST_EN1              0xbfd00000 + 0x11c4
#define FIRST_EN2              0xbfd00000 + 0x11c8
#define SECOND_EN0             0xbfd00000 + 0x11d0
#define SECOND_EN1             0xbfd00000 + 0x11d4
#define SECOND_EN2             0xbfd00000 + 0x11d8
#define THIRD_EN0              0xbfd00000 + 0x11e0
#define THIRD_EN1              0xbfd00000 + 0x11e4
#define THIRD_EN2              0xbfd00000 + 0x11e8
#define GPIO_CFG0              0xbfd00000 + 0x10c0
#define GPIO_CFG1              0xbfd00000 + 0x10c4
#define GPIO_CFG2              0xbfd00000 + 0x10c8
#define                        CONFREG_BASE  0xbfd00000

//gmac0
#define GMAC0_MAC_REG_ADDR     0xbfe10000       
#define GMAC0_REG_ADDR         0xbfe11000


#define GMAC0_RX_DESC_BASE     0xa0060000
#define GMAC0_RX_DESC_BASE_PHY 0x00060000
#define GMAC0_RDES0_VALUE      0x80000300 #own by DMA,desc_last, desc_first #document is error
#define GMAC0_RDES1_VALUE      0x00000410 #start of frame, end of frame, size 1032
#define GMAC0_RDES1_END_VALUE  0x02000410 #own by DMA,desc_last, desc_first #document is error


//#define GMAC0_RX_BUF_BASE      0x0000000000200c00	//20000+3k
//#define GMAC0_RX_BUF_BASE_VIR  0x9000000000200c00

#define GMAC0_TX_DESC_BASE     0xa0000000
#define GMAC0_TX_DESC_BASE_PHY 0x00000000
#define GMAC0_TDES0_VALUE      0x80000000 #own by DMA  start of frame, end of frame, size 1K
#define GMAC0_TDES1_VALUE      0x60000400 #start of frame, end of frame, size 1K
## 6 [30] = 1'b1 : Last segment
##   [29] = 1'b1 : First segment
## 4 [10] = 1'b1 : Transmit buffer 1 size = 'h400 = 1024
#define GMAC0_TDES1_END_VALUE      0x62000400 #start of frame, end of frame, size 1K
## 2 [25] = 1'b1 : Transmit end of Ring


        .text
        .set    noreorder
        .set    mips2

        .global gmac_test
	.ent	gmac_test
gmac_test:
//sw:test
	li  t0,0x12345678
#  MAC_TX_CTL_i  GPIO_MUX[21]      MAC_TX_CLK_i  GPIO_MUX[22]   MAC_TX0_i  GPIO_MUX[23]  MAC_TX1_i  GPIO_MUX[24]
#  MAC_RX_ERR_i  GPIO_MUX[25]      MAC_CRS_DV_i  GPIO_MUX[26]   MAC_RX0_i  GPIO_MUX[27]  MAC_RX1_i  GPIO_MUX[28]  
#  MAC_MDC_i     GPIO_MUX[29]      MAC_MDIO_i    GPIO_MUX[30]   MAC_RX2_i  GPIO_MUX[31]  MAC_TX2_i  GPIO_MUX[32]
#  MAC_RX3_i     GPIO_MUX[33]      MAC_TX3_i     GPIO_MUX[34]   MII_CRS_ONLY_i GPIO_MUX[35] MAC_COL_i GPIO_MUX[36]
#  MAC_RXC_i     GPIO_MUX[37]  


   li  t0, CONFREG_BASE   
   lw  a1, 0x10c0(t0)
   li  a2, 0x1fff7f
   and  a1,a1,a2 
   sw  a1, 0x10c0(t0)

   li  t0, CONFREG_BASE   
   lw  a1, 0x10c4(t0)
   li  a2, 0xffffffc0
   and  a1,a1,a2 
   sw  a1, 0x10c4(t0)

#ifdef MODE_MII// 

## config port for MII interface
## phy_intf_sel_i = gpio_[62:60] = 3'b000 //000:MII 100:RMII
        li  t0,GPIO_CTRL_H
        lw  t1,0x0(t0)
        li  t2,0x8fffffff
        and t1,t1,t2
        sw  t1,0x0(t0)
#else

## config port for RMII interface
## phy_intf_sel_i = gpio_[62:60] = 3'b100 //000:MII 100:RMII
        li  t0,GPIO_CTRL_H
        lw  t1,0x0(t0)
        li  t2,0x8fffffff
        and t1,t1,t2
        li  t2,0x40000000
        or  t1,t1,t2
        sw  t1,0x0(t0)
#endif
gmac0:
        li  t0,GMAC0_REG_ADDR 
        lw  t1,0x0(t0)
        ori t1,t1,1
        sw  t1,0x0(t0)
        nop
        
        #wait for soft reset complete
        #note rgmii_rx_clk must be valid
1:      lw t1,0x0(t0)
        andi t1,t1,0x1
        bne t1,$0,1b
        nop

        #set the DMABusMode Register
        li t1,0x00000400 #BurstLength 4, DescriptorSkipLength 0,DescriptorSize 4Words
        sw  t1,0x0(t0)

        #Set MAC to full-duplex mode, Otherwise the 
        #hardware loopback device of the RGMII will cause collision
        li t0,GMAC0_MAC_REG_ADDR
        lw  t1,0x0(t0)
##  c [15:14]= 2'b11 Port select: 1 - MII(10/100Mbps)  0 - GMII(1000Mbps)
##                   Speed      : 1 - 100Mbps          0 - 10Mbps
##  8 [11]   = 1'b1  Duplex mode: 1 - full duplex

##   test mdio
//     la     a0, msg_gmac_mdio
//    jal     outputstring
//     nop

    PRINTSTR("\r\n gmac_mdio_seting \r\n")
#if 0
     li    t0, GMAC0_MAC_REG_ADDR
     li    t1, 0x00000009
     sw    t1, 0x10(t0)
     lw    t2, 0x14(t0)
1:
     add   t1, t1,0x400
     sw    t1, 0x10(t0)
     lw    t2, 0x14(t0)
     bne   t1, 0x00004001,1b   
#endif

##     add   t1, t1,0x400
##     sw    t1, 0x10(t0)
##     lw    t2, 0x14(t0)
##     add   t1, t1,0x400
##     sw    t1, 0x10(t0)
##     lw    t2, 0x14(t0)


#ifdef SPEED_10
        ori t1,t1,0x8800       #10Mbps
#else
        ori t1,t1,0xc800     #100Mbps
#endif
        sw  t1,0x0(t0)

        #Set MAC Frame Filter to Receive all
        li  a0,0x80000000
        li t0,GMAC0_MAC_REG_ADDR
        lw  t1,0x4(t0)
        or  t1,t1,a0
        sw  t1,0x4(t0)

#if 1
        li  a0, 0xa1000010
        li  a1, 0xa1000000
        li  a2, 0x5a5aa5a5
1:
        sw  a2, 0x0(a1)
        add a1, 4
        bne a0, a1, 1b
        nop
#endif


        PRINTSTR("\r\n begin to set TX_DESC....\r\n")

	li  t2,0x11
        #setup TX desc ring for 18 desc
        li  t0,GMAC0_TX_DESC_BASE
	
//	la  t3,gmac0_tx_data
	li  t3,0x1000000
#	la  t3,gmac_tx_data_rwk
	and t3,t3,0x1fffffff
#        or   t3,t3,0x40000000                          #ccio
#        li  t3,GMAC0_BUF_BASE
1:
        li  t1,GMAC0_TDES0_VALUE
        sw   t1,0x0(t0)
        li  t1,GMAC0_TDES1_VALUE
        sw   t1,0x4(t0)
        sw  t3,0x8(t0)
        sw  t3,0xc(t0)
	addiu t0,t0,0x10
	addiu t3,t3,0x400
	addiu t2,t2,-0x1
	bnez  t2,1b
	nop

        li  t1,GMAC0_TDES0_VALUE
        sw  t1,0x0(t0)
        li  t1,GMAC0_TDES1_END_VALUE
        sw  t1,0x4(t0)
        sw  t3,0x8(t0)
        sw  t3,0xc(t0)


        PRINTSTR("\r\n begin to set RX_DESC....\r\n")

        
		
############################################################
 	li  t2,0x11
        #setup RX desc ring for 18 desc
        li  t0,GMAC0_RX_DESC_BASE
#        li  t3,GMAC0_RX_BUF_BASE                      
	li  t3,0x1000000
//	la  t3,gmac0_tx_data
	and  t3,t3,0x1fffffff
//        or   t3,t3,0x40000000                           #ccio
	addiu	t3,t3,0xc00

1:
        li  t1,GMAC0_RDES0_VALUE
        sw  t1,0x0(t0)
        li  t1,GMAC0_RDES1_VALUE
        sw  t1,0x4(t0)
        sw  t3,0x8(t0)
        sw  t3,0xc(t0)
	addiu t0,t0,0x10
	addiu t3,t3,0x400
	addiu t2,t2,-0x1
	bnez  t2,1b
	nop

        li  t1,GMAC0_RDES0_VALUE 
        sw  t1,0x0(t0)
        li  t1,GMAC0_RDES1_END_VALUE
        sw  t1,0x4(t0)
        sw  t3,0x8(t0)
        sw  t3,0xc(t0)

###########################################################



        PRINTSTR("\r\n set RX_DESC finished....\r\n")


###########################################################
//gmac0         
        #setup the TX desc base address       
        li t0,GMAC0_REG_ADDR 
        li  t1,GMAC0_TX_DESC_BASE_PHY
        sw  t1,0x10(t0)

        #setup the RX desc base address       
        ##li t0,GMAC0_REG_ADDR 
        li  t1,GMAC0_RX_DESC_BASE_PHY
        sw  t1,0xc(t0)

        #enable GMAC0_MAC_RX 
        #RX must be enabled before TX 
        #Otherwise it will miss the first TX frame
        li t0,GMAC0_MAC_REG_ADDR
        lw  t1,0x0(t0)
        ori t1,t1,0x4
        sw  t1,0x0(t0)

        #enable GMAC0_MAC_TX 
        ##li t0,GMAC0_MAC_REG_ADDR
        lw  t1,0x0(t0)
        ori t1,t1,0x8
        sw  t1,0x0(t0)


        #enable GMAC0_DMA_TX & RX 
        li t0,GMAC0_REG_ADDR 
        lw  t1,0x18(t0)
        ori t1,t1,0x2002
        sw  t1,0x18(t0)

        PRINTSTR("\r\n mac config finished ....\r\n")
loop:
        PRINTSTR("DMA_REG_0 = 0x")
        li  t0, GMAC0_REG_ADDR
        lw  a0, 0x0(t0)
        bal hexserial
        nop

        PRINTSTR("\tTX_DESC_BASE = 0x")
        li  t0, GMAC0_REG_ADDR
        lw  a0, 0x10(t0)
        bal hexserial
        nop

        PRINTSTR("\tTX_DESC = 0x")
        li  t0, GMAC0_REG_ADDR
        lw  a0, 0x48(t0)
        bal hexserial
        nop

        PRINTSTR("\tTX_BUF = 0x")
        li  t0, GMAC0_REG_ADDR
        lw  a0, 0x50(t0)
        bal hexserial
        nop

        PRINTSTR("\r\n")

        b loop
        nop


################################################################

        jr ra
        nop

.end	gmac_test


        .text
        .set    noreorder
        .set    mips2

        .global gmac_check
	.ent	gmac_check

gmac_check:
        addi   sp, sp, 0xfff8
        sw      ra, 0(sp)

check_status:
#	la     a0, msg_gmac_check
#        jal     outputstring
#        nop

        PRINTSTR("\r\n gmac_check .....\r\n")

//check gmac0
        li      t0,GMAC0_REG_ADDR 
        lw      t1,0x14(t0)
        andi    t1,t1,0x84
        beqz    t1,check_status
        nop
 
gmac0_check_value:
	la	t1,gmac0_tx_data
	addiu   t1,t1,0x4800
        or      t1,t1,0xa0000000        //no cache
//1k
	li	t3,0x40
	li	t4,0x11111111
1:
	lw      t2,0x0(t1)
	bne	t2,t4,check_err
	nop
	addiu	t3,t3,-0x1
	addiu	t1,t1,0x4
	bnez    t3,1b
	nop

	li	t3,0x40	
	li	t4,0x22222222
1:
	lw      t2,0x0(t1)
	bne	t2,t4,check_err
	nop
	addiu	t3,t3,-0x1
	addiu	t1,t1,0x4
	bnez    t3,1b
	nop
	
	li	t3,0x40	
	li	t4,0x33333333
1:
	lw      t2,0x0(t1)
	bne	t2,t4,check_err
	nop
	addiu	t3,t3,-0x1
	addiu	t1,t1,0x4
	bnez    t3,1b
	nop

	li	t3,0x23	
	li	t4,0x44444444
1:
	lw      t2,0x0(t1)
	bne	t2,t4,check_err
	nop
	addiu	t3,t3,-0x1
	addiu	t1,t1,0x4
	bnez    t3,1b
	nop


	la	t1,gmac0_tx_data
	addiu  t1,t1,0x4c00
        or      t1,t1,0xa0000000        //no cache
//2k
	li	t3,0x40	
	li	t4,0x55555555
1:
	lw      t2,0x0(t1)
	bne	t2,t4,check_err
	nop
	addiu	t3,t3,-0x1
	addiu	t1,t1,0x4
	bnez    t3,1b
	nop

	li	t3,0x40	
	li	t4,0x66666666
1:
	lw      t2,0x0(t1)
	bne	t2,t4,check_err
	nop
	addiu	t3,t3,-0x1
	addiu	t1,t1,0x4
	bnez    t3,1b
	nop
	
	li	t3,0x40	
	li	t4,0x77777777
1:
	lw      t2,0x0(t1)
	bne	t2,t4,check_err
	nop
	addiu	t3,t3,-0x1
	addiu	t1,t1,0x4
	bnez    t3,1b
	nop

	li	t3,0x23
	li	t4,0x88888888
1:
	lw      t2,0x0(t1)
	bne	t2,t4,check_err
	nop
	addiu	t3,t3,-0x1
	addiu	t1,t1,0x4
	bnez    t3,1b
	nop
        
	la	t1,gmac0_tx_data
	addiu  t1,t1,0x5000
        or      t1,t1,0xa0000000        //no cache
//3k
	li	t3,0x40	
	li	t4,0x99999999
1:
	lw      t2,0x0(t1)
	bne	t2,t4,check_err
	nop
	addiu	t3,t3,-0x1
	addiu	t1,t1,0x4
	bnez    t3,1b
	nop

	li	t3,0x40	
	li	t4,0xaaaaaaaa
1:
	lw      t2,0x0(t1)
	bne	t2,t4,check_err
	nop
	addiu	t3,t3,-0x1
	addiu	t1,t1,0x4
	bnez    t3,1b
	nop
	
	li	t3,0x40	
	li	t4,0xbbbbbbbb
1:
	lw      t2,0x0(t1)
	bne	t2,t4,check_err
	nop
	addiu	t3,t3,-0x1
	addiu	t1,t1,0x4
	bnez    t3,1b
	nop

	li	t3,0x23
	li	t4,0xcccccccc
1:
	lw      t2,0x0(t1)
	bne	t2,t4,check_err
	nop
	addiu	t3,t3,-0x1
	addiu	t1,t1,0x4
	bnez    t3,1b
	nop


pass:
#	la     a0, msg_gmac_pass
#        jal     outputstring
#        nop

    PRINTSTR("\r\n gmac_test_pass ^_^\r\n")

	move	v0,zero
        lw      ra, 0(sp)
	jr	ra
        addiu   sp, sp, 8

check_err:
//	move	v0,t1
//	move	v1,t2

#        la     a0, msg_gmac_fail
#        jal     outputstring
#        nop

    PRINTSTR("\r\n gmac_test_error -_-!!!!!!")

        lw      ra, 0(sp)
	jr	ra
        addiu  sp, sp, 8

.end	gmac_check
        
        .global gmac_rwk_test
        .ent    gmac_rwk_test
gmac_rwk_test:
	li  t0,0x0000000012345678

        li  t0,GMAC0_REG_ADDR 
        lw  t1,0x0(t0)
        ori t1,t1,1
        sw  t1,0x0(t0)
        nop
        
        #wait for soft reset complete
        #note rgmii_rx_clk must be valid
1:      lw t1,0x0(t0)
        andi t1,t1,0x1
        bne t1,$0,1b
        nop


        #Set MAC Frame Filter to Receive all and Promisc Mode
        li  a0,0x80000001
## 8 [31] = 1'b1, Receive all
## 1 [1]  = 1'b1, Promisc mode
        li t0,GMAC0_MAC_REG_ADDR
        lw  t1,0x4(t0)
        or  t1,t1,a0
        sw  t1,0x4(t0)

###################remote wake up test#####################
        li t0,GMAC0_MAC_REG_ADDR 
rwk:
        li  t1,0x01234567       #8times to configure pmt reg
        sw  t1,0x28(t0)
        li  t1,0x89abcdef
        sw  t1,0x28(t0)
        li  t1,0x1bbbbbbb
        sw  t1,0x28(t0)
        li  t1,0x1ccccccc
        sw  t1,0x28(t0)

        li  t1,0x9              //en,multicast
        sw  t1,0x28(t0)
        li  t1,0x0
        sw  t1,0x28(t0)
        li  t1,0xe72d
        sw  t1,0x28(t0)
        li  t1,0xffff
        sw  t1,0x28(t0)

        li  t1,0x80000005                       //reset,rwk_en,pwr_down
        sw  t1,0x2c(t0)

        #enable GMAC0_MAC_RX 
        #RX must be enabled before TX 
        #Otherwise it will miss the first TX frame
        li t0,GMAC0_MAC_REG_ADDR
        lw  t1,0x0(t0)
//        ori t1,t1,0x4
//mii
        ori t1,t1,0xc004
        sw  t1,0x0(t0)

        #enable GMAC0_MAC_TX 
        ##li t0,GMAC0_MAC_REG_ADDR
        lw  t1,0x0(t0)
        ori t1,t1,0x8
        sw  t1,0x0(t0)

        jr ra
        nop

        .end    gmac_rwk_test

        .rdata
        .align  5
msg_gmac_mdio:
        .asciiz "gmac mdio test ...\n"
msg_gmac_pass:
        .asciiz "gmac pass ...\n"
msg_gmac_fail:
        .asciiz "gmac fail ...\n"
msg_gmac_check:
        .asciiz "gmac check dma status ...\n"



	.data
	.align 5

gmac0_tx_data:
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x12345678
.word  0x12345678
.word  0x12345678
.word  0x12345678
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0x12345678
.word  0x12345678
.word  0x12345678
.word  0x12345678

//32k reserved for gmac test data
	.align	15	

	.data
	.align 5

gmac1_tx_data:
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x11111111
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x22222222
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x33333333
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x44444444
.word  0x12345678
.word  0x12345678
.word  0x12345678
.word  0x12345678
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x55555555
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x66666666
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x77777777
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x88888888
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0x99999999
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xaaaaaaaa
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xbbbbbbbb
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0xcccccccc
.word  0x12345678
.word  0x12345678
.word  0x12345678
.word  0x12345678

//32k reserved for gmac test data
	.align	15	

gmac_tx_data_rwk:
.word  0xffffffff
.word  0xffffffff
.word  0xffffffff
.word  0xffffffff
.word  0x76543210
.word  0xfedcba98
.word  0x76543210
.word  0xfedcba98



