/*	$Id: gt96132reg.h,v 1.1.1.1 2006/09/14 01:59:08 root Exp $ */

/*
 * Copyright (c) 2001-2002 Galileo Technology
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by Galileo Technology
 * 4. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */
/* GT96132R.h - GT96132 Internal registers definition file */

/* Copyright - Galileo technology. */

#ifndef __INCgt96132Rh 
#define __INCgt96132Rh

#ifndef GT96132
#define GT96132
#endif

#include <machine/asm.h>

#define HTOLE32(v)      ((((v) & 0xff) << 24) | (((v) & 0xff00) << 8) | \
                         (((v) >> 24) & 0xff) | (((v) >> 8) & 0xff00))

#define GT_WRITE(ofs, data) \
    *(volatile u_int32_t *)(GT_BASE_ADDR+ofs) = HTOLE32(data)
#define GT_WRITE_NOSWAP(ofs, data) \
    *(volatile u_int32_t *)(GT_BASE_ADDR+ofs) = (data)

#define GT_READ(ofs) \
    HTOLE32(*(volatile u_int32_t *)(GT_BASE_ADDR+ofs))
#define GT_READ_NOSWAP(ofs) \
    (*(volatile u_int32_t *)(GT_BASE_ADDR+ofs))

#if defined(GT_HIGH)
#define GT_BASE_ADDR                    0xfe000000
#else
#define GT_BASE_ADDR                    0x14000000
#endif
#define GT_BASE_ADDR_DEFAULT            0x14000000

/****************************************/
/* CPU Configuration 			*/
/****************************************/

#define CPU_INTERFACE_CONFIGURATION		0x000
#define	CPU_CONF				CPU_INTERFACE_CONFIGURATION
#define	MULTI_GT_REGISTER			0x120

/****************************************/
/* Processor Address Space		*/
/****************************************/

#define SCS_1_0_LOW_DECODE_ADDRESS		0x008
#define SCS_1_0_HIGH_DECODE_ADDRESS		0x010
#define SCS_3_2_LOW_DECODE_ADDRESS		0x018
#define SCS_3_2_HIGH_DECODE_ADDRESS		0x020
#define CS_2_0_LOW_DECODE_ADDRESS		0x028
#define CS_2_0_HIGH_DECODE_ADDRESS		0x030
#define CS_3_BOOTCS_LOW_DECODE_ADDRESS		0x038
#define CS_3_BOOTCS_HIGH_DECODE_ADDRESS		0x040
#define PCI_0I_O_LOW_DECODE_ADDRESS		0x048
#define PCI_0I_O_HIGH_DECODE_ADDRESS		0x050
#define PCI_0MEMORY0_LOW_DECODE_ADDRESS		0x058
#define PCI_0MEMORY0_HIGH_DECODE_ADDRESS	0x060
#define PCI_0MEMORY1_LOW_DECODE_ADDRESS		0x080
#define PCI_0MEMORY1_HIGH_DECODE_ADDRESS	0x088
#define PCI_1I_O_LOW_DECODE_ADDRESS		0x090
#define PCI_1I_O_HIGH_DECODE_ADDRESS		0x098
#define PCI_1MEMORY0_LOW_DECODE_ADDRESS		0x0a0
#define PCI_1MEMORY0_HIGH_DECODE_ADDRESS	0x0a8
#define PCI_1MEMORY1_LOW_DECODE_ADDRESS		0x0b0
#define PCI_1MEMORY1_HIGH_DECODE_ADDRESS	0x0b8
#define INTERNAL_SPACE_DECODE			0x068
#define CPU_BUS_ERROR_LOW_ADDRESS 		0x070
#define CPU_BUS_ERROR_HIGH_ADDRESS 		0x078
#define PCI_0SYNC_BARIER_VIRTUAL_REGISTER	0x0c0
#define PCI_1SYNC_BARIER_VIRTUAL_REGISTER	0x0c8
#define SCS_1_0_ADDRESS_REMAP			0x0d0
#define SCS_3_2_ADDRESS_REMAP			0x0d8
#define CS_2_0_ADDRESS_REMAP			0x0e0
#define CS_3_BOOTCS_ADDRESS_REMAP		0x0e8
#define PCI_0I_O_ADDRESS_REMAP			0x0f0
#define PCI_0MEMORY0_ADDRESS_REMAP		0x0f8
#define PCI_0MEMORY1_ADDRESS_REMAP		0x100
#define PCI_1I_O_ADDRESS_REMAP			0x108
#define PCI_1MEMORY0_ADDRESS_REMAP		0x110
#define PCI_1MEMORY1_ADDRESS_REMAP		0x118

/****************************************/
/* SDRAM and Device Address Space	*/
/****************************************/
	
#define SCS_0_LOW_DECODE_ADDRESS		0x400
#define SCS_0_HIGH_DECODE_ADDRESS		0x404
#define SCS_1_LOW_DECODE_ADDRESS		0x408
#define SCS_1_HIGH_DECODE_ADDRESS		0x40C
#define SCS_2_LOW_DECODE_ADDRESS		0x410
#define SCS_2_HIGH_DECODE_ADDRESS		0x414
#define SCS_3_LOW_DECODE_ADDRESS		0x418
#define SCS_3_HIGH_DECODE_ADDRESS		0x41C
#define CS_0_LOW_DECODE_ADDRESS			0x420
#define CS_0_HIGH_DECODE_ADDRESS		0x424
#define CS_1_LOW_DECODE_ADDRESS			0x428
#define CS_1_HIGH_DECODE_ADDRESS		0x42C
#define CS_2_LOW_DECODE_ADDRESS			0x430
#define CS_2_HIGH_DECODE_ADDRESS		0x434
#define CS_3_LOW_DECODE_ADDRESS			0x438
#define CS_3_HIGH_DECODE_ADDRESS		0x43C
#define BOOTCS_LOW_DECODE_ADDRESS		0x440
#define BOOTCS_HIGH_DECODE_ADDRESS		0x444
#define ADDRESS_DECODE_ERROR			0x470
#define ADDRESS_DECODE				0x47C

/****************************************/
/* SDRAM Configuration			*/
/****************************************/

#define SDRAM_CONFIGURATION	 		0x448
#define SDRAM_OPERATION_MODE			0x474
#define SDRAM_ADDRESS_DECODE			0x47C

/****************************************/
/* SDRAM Parameters			*/
/****************************************/
			
#define SDRAM_BANK0PARAMETERS			0x44C
#define SDRAM_BANK1PARAMETERS			0x450
#define SDRAM_BANK2PARAMETERS			0x454
#define SDRAM_BANK3PARAMETERS			0x458

/****************************************/
/* Device Parameters			*/
/****************************************/

#define DEVICE_BANK0PARAMETERS			0x45C
#define DEVICE_BANK1PARAMETERS			0x460
#define DEVICE_BANK2PARAMETERS			0x464
#define DEVICE_BANK3PARAMETERS			0x468
#define DEVICE_BOOT_BANK_PARAMETERS		0x46C

#define	GT_DEV0_PAR				DEVICE_BANK0PARAMETERS
#define	GT_DEV1_PAR				DEVICE_BANK1PARAMETERS
#define	GT_DEV2_PAR				DEVICE_BANK2PARAMETERS
#define	GT_DEV3_PAR				DEVICE_BANK3PARAMETERS
#define	GT_BOOT_PAR				DEVICE_BOOT_BANK_PARAMETERS

/****************************************/
/* DMA Record				*/
/****************************************/

#define CHANNEL0_DMA_BYTE_COUNT			0x800
#define CHANNEL1_DMA_BYTE_COUNT	 		0x804
#define CHANNEL2_DMA_BYTE_COUNT	 		0x808
#define CHANNEL3_DMA_BYTE_COUNT	 		0x80C
#define CHANNEL0_DMA_SOURCE_ADDRESS		0x810
#define CHANNEL1_DMA_SOURCE_ADDRESS		0x814
#define CHANNEL2_DMA_SOURCE_ADDRESS		0x818
#define CHANNEL3_DMA_SOURCE_ADDRESS		0x81C
#define CHANNEL0_DMA_DESTINATION_ADDRESS	0x820
#define CHANNEL1_DMA_DESTINATION_ADDRESS	0x824
#define CHANNEL2_DMA_DESTINATION_ADDRESS	0x828
#define CHANNEL3_DMA_DESTINATION_ADDRESS	0x82C
#define CHANNEL0NEXT_RECORD_POINTER		0x830
#define CHANNEL1NEXT_RECORD_POINTER		0x834
#define CHANNEL2NEXT_RECORD_POINTER		0x838
#define CHANNEL3NEXT_RECORD_POINTER		0x83C
#define CHANNEL0CURRENT_DESCRIPTOR_POINTER	0x870
#define CHANNEL1CURRENT_DESCRIPTOR_POINTER	0x874
#define CHANNEL2CURRENT_DESCRIPTOR_POINTER	0x878
#define CHANNEL3CURRENT_DESCRIPTOR_POINTER	0x87C

/****************************************/
/* DMA Channel Control			*/
/****************************************/

#define CHANNEL0CONTROL				0x840
#define CHANNEL1CONTROL				0x844
#define CHANNEL2CONTROL				0x848
#define CHANNEL3CONTROL				0x84C

/****************************************/
/* DMA Arbiter				*/
/****************************************/

#define ARBITER_CONTROL				0x860

/****************************************/
/* Timer_Counter 			*/
/****************************************/

#define TIMER_COUNTER0				0x850
#define TIMER_COUNTER1				0x854
#define TIMER_COUNTER2				0x858
#define TIMER_COUNTER3				0x85C
#define TIMER_COUNTER_CONTROL			0x864

/****************************************/
/* PCI Internal  			*/
/****************************************/

#define PCI_0COMMAND				0xC00
#define PCI_0TIMEOUT_RETRY			0xC04
#define PCI_0SCS_1_0_BANK_SIZE			0xC08
#define PCI_0SCS_3_2_BANK_SIZE			0xC0C
#define PCI_0CS_2_0_BANK_SIZE			0xC10
#define PCI_0CS_3_BOOTCS_BANK_SIZE		0xC14
#define PCI_0BASE_ADDRESS_REGISTERS_ENABLE 	0xC3C
#define PCI_0PREFETCH_MAX_BURST_SIZE		0xc40
#define PCI_0SCS_1_0_BASE_ADDRESS_REMAP		0xC48
#define PCI_0SCS_3_2_BASE_ADDRESS_REMAP		0xC4C
#define PCI_0CS_2_0_BASE_ADDRESS_REMAP		0xC50
#define PCI_0CS_3_BOOTCS_ADDRESS_REMAP		0xC54
#define PCI_0SWAPPED_SCS_1_0_BASE_ADDRESS_REMAP	0xC58
#define PCI_0SWAPPED_SCS_3_2_BASE_ADDRESS_REMAP	0xC5C
#define PCI_0SWAPPED_CS_3_BOOTCS_BASE_ADDRESS_REMAP	0xC64
#define PCI_0CONFIGURATION_ADDRESS 		0xCF8
#define PCI_0CONFIGURATION_DATA_VIRTUAL_REGISTER	0xCFC
#define PCI_0INTERRUPT_ACKNOWLEDGE_VIRTUAL_REGISTER	0xC34
#define PCI_1COMMAND				0xc80
#define PCI_1TIMEOUT_RETRY			0xc84
#define PCI_1SCS_1_0_BANK_SIZE			0xc88
#define PCI_1SCS_3_2_BANK_SIZE			0xc8c
#define PCI_1CS_2_0_BANK_SIZE			0xc90
#define PCI_1CS_3_BOOTCS_BANK_SIZE		0xc94
#define PCI_1BASE_ADDRESS_REGISTERS_ENABLE 	0xcbc
#define PCI_1PREFETCH_MAX_BURST_SIZE		0xcc0
#define PCI_1SCS_1_0_BASE_ADDRESS_REMAP		0xcc8
#define PCI_1SCS_3_2_BASE_ADDRESS_REMAP		0xccc
#define PCI_1CS_2_0_BASE_ADDRESS_REMAP		0xcd0
#define PCI_1CS_3_BOOTCS_ADDRESS_REMAP		0xcd4
#define PCI_1SWAPPED_SCS_1_0_BASE_ADDRESS_REMAP	0xcd8
#define PCI_1SWAPPED_SCS_3_2_BASE_ADDRESS_REMAP	0xcdc
#define PCI_1SWAPPED_CS_3_BOOTCS_BASE_ADDRESS_REMAP	0xce4
#define PCI_1CONFIGURATION_ADDRESS 		0xcf0
#define PCI_1CONFIGURATION_DATA_VIRTUAL_REGISTER	0xcf4
#define PCI_1INTERRUPT_ACKNOWLEDGE_VIRTUAL_REGISTER	0xc30

/****************************************/
/* Interrupts	  			*/
/****************************************/
  
#define INTERRUPT_MAIN_CAUSE_REGISTER		0xc18
#define INTERRUPT0_MAIN_MASK_REGISTER		0xc1c
#define INTERRUPT1_MAIN_MASK_REGISTER		0xc24
#define INTERRUPT_HIGH_CAUSE_REGISTER		0xc98
#define INTERRUPT0_HIGH_MASK_REGISTER		0xc9c
#define INTERRUPT1_HIGH_MASK_REGISTER		0xcA4
#define INTERRUPT0_SELECT_REGISTER		0xc70
#define INTERRUPT1_SELECT_REGISTER		0xc74
#define INTERRUPT_CAUSE_REGISTER		0xC18
#define HIGH_INTERRUPT_CAUSE_REGISTER		0xc98
#define CPU_INTERRUPT_MASK_REGISTER		0xC1C
#define CPU_HIGH_INTERRUPT_MASK_REGISTER	0xc9c
#define PCI_0INTERRUPT_CAUSE_MASK_REGISTER	0xC24
#define PCI_0HIGH_INTERRUPT_CAUSE_MASK_REGISTER	0xca4
#define PCI_0SERR0_MASK				0xC28
#define PCI_1SERR0_MASK				0xca8

/****************************************/
/* Ethernet, MPSC and GPP port		*/
/****************************************/

#define MAIN_ROUTING_REGISTER			0x101A00
#define RECEIVE_CLOCK_ROUTING_REGISTER		0x101A10
#define TRANSMIT_CLOCK_ROUTING_REGISTER		0x101A20
#define SERIAL_CAUSE_REGISTER			0x103a00
#define SERINT0_MASK_REGISTER			0x103a80
#define SERINT1_MASK_REGISTER			0x103a88
#define ETHERNET0_CAUSE_REGISTER		0x084850
#define ETHERNET0_MASK_REGISTER			0x084858
#define ETHERNET1_CAUSE_REGISTER		0x088850
#define ETHERNET1_MASK_REGISTER			0x088858
#define SDMA_CAUSE_REGISTER			0x103A10
#define SDMA_MASK_REGISTER			0x103A90
#define MPSC0_CAUSE_REGISTER			0x103a20
#define MPSC0_MASK_REGISTER			0x103aa0
#define MPSC1_CAUSE_REGISTER			0x103a24
#define MPSC1_MASK_REGISTER			0x103aa4
#define MPSC2_CAUSE_REGISTER			0x103a28
#define MPSC2_MASK_REGISTER			0x103aa8
#define MPSC3_CAUSE_REGISTER			0x103a2c
#define MPSC3_MASK_REGISTER			0x103aac
#define MPSC4_CAUSE_REGISTER			0x103a30
#define MPSC4_MASK_REGISTER			0x103ab0
#define MPSC5_CAUSE_REGISTER			0x103a34
#define MPSC5_MASK_REGISTER			0x103ab4
#define MPSC6_CAUSE_REGISTER			0x103a38
#define MPSC6_MASK_REGISTER			0x103ab8
#define MPSC7_CAUSE_REGISTER			0x103a3c
#define MPSC7_MASK_REGISTER			0x103abc
#define FLEX_TDM_CAUSE_REGISTER			0x103a40
#define FLEX_TDM_MASK_REGISTER			0x103ac0
#define BRG_CAUSE_REGISTER			0x103a48
#define BRG_MASK_REGISTER			0x103ac8
#define GPP0_CAUSE_REGISTER			0x103a50
#define GPP0_MASK_REGISTER			0x103ad0
#define GPP1_CAUSE_REGISTER			0x103a54
#define GPP1_MASK_REGISTER			0x103ad4
#define GPP2_CAUSE_REGISTER			0x103a58
#define GPP2_MASK_REGISTER			0x103ad8
#define GPP3_CAUSE_REGISTER			0x103a5c
#define GPP3_MASK_REGISTER			0x103adc

/****************************************/
/* PCI Configuration   			*/
/****************************************/

#define PCI_DEVICE_AND_VENDOR_ID 		0x000
#define PCI_STATUS_AND_COMMAND			0x004
#define PCI_CLASS_CODE_AND_REVISION_ID 		0x008
#define PCI_BIST_HEADER_TYPE_LATENCY_TIMER_CACHE_LINE	0x00C
#define PCI_SCS_1_0_BASE_ADDRESS	 	0x010
#define PCI_SCS_3_2_BASE_ADDRESS 		0x014
#define PCI_1SCS_1_0_BASE_ADDRESS	 	0x090
#define PCI_1SCS_3_2_BASE_ADDRESS 		0x094
#define PCI_CS_2_0_BASE_ADDRESS 		0x018
#define PCI_CS_3_BOOTCS_BASE_ADDRESS		0x01C
#define PCI_INTERNAL_REGISTERS_MEMORY_MAPPED_BASE_ADDRESS	0x020
#define PCI_INTERNAL_REGISTERS_I_OMAPPED_BASE_ADDRESS		0x024
/* Erez */
#define PCI_0INTERNAL_REGISTERS_SPACE_SIZE	0xC20
#define PCI_1INTERNAL_REGISTERS_SPACE_SIZE	0xCA0
/* Erez End */
#define PCI_0SUBSYSTEM_ID_AND_SUBSYSTEM_VENDOR_ID	0x02C
#define EXPANSION_ROM_BASE_ADDRESS_REGISTER	0x030
#define PCI_INTERRUPT_PIN_AND_LINE		0x03C

/****************************************/
/* PCI Control                          */
/****************************************/

#define PCI_0ARBITER_CONTROL			0x101ae0
#define PCI_1ARBITER_CONTROL			0x101ae4

/****************************************/
/* PCI Configuration, Function 1	*/
/****************************************/

#define PCI_0SWAPPED_SCS_1_0_BASE_ADDRESS 	0x110
#define PCI_0SWAPPED_SCS_3_2_BASE_ADDRESS 	0x114
#define PCI_0SWAPPED_CS_3_BOOTCS_BASE_ADDRESS	0x11C
#define PCI_1SWAPPED_SCS_1_0_BASE_ADDRESS 	0x190
#define PCI_1SWAPPED_SCS_3_2_BASE_ADDRESS 	0x194
#define PCI_1SWAPPED_CS_3_BOOTCS_BASE_ADDRESS	0x19c


/****************************************/
/* I20 Support registers		*/
/****************************************/

#define INBOUND_MESSAGE_REGISTER0_PCI_SIDE	0x010
#define INBOUND_MESSAGE_REGISTER1_PCI_SIDE  	0x014
#define OUTBOUND_MESSAGE_REGISTER0_PCI_SIDE 	0x018
#define OUTBOUND_MESSAGE_REGISTER1_PCI_SIDE  	0x01C
#define INBOUND_DOORBELL_REGISTER_PCI_SIDE  	0x020
#define INBOUND_INTERRUPT_CAUSE_REGISTER_PCI_SIDE 0x024
#define INBOUND_INTERRUPT_MASK_REGISTER_PCI_SIDE 0x028
#define OUTBOUND_DOORBELL_REGISTER_PCI_SIDE 	0x02C
#define OUTBOUND_INTERRUPT_CAUSE_REGISTER_PCI_SIDE 0x030
#define OUTBOUND_INTERRUPT_MASK_REGISTER_PCI_SIDE 0x034
#define INBOUND_QUEUE_PORT_VIRTUAL_REGISTER_PCI_SIDE 0x040
#define OUTBOUND_QUEUE_PORT_VIRTUAL_REGISTER_PCI_SIDE 0x044
#define QUEUE_CONTROL_REGISTER_PCI_SIDE 	0x050
#define QUEUE_BASE_ADDRESS_REGISTER_PCI_SIDE 	0x054
#define INBOUND_FREE_HEAD_POINTER_REGISTER_PCI_SIDE 0x060
#define INBOUND_FREE_TAIL_POINTER_REGISTER_PCI_SIDE 0x064
#define INBOUND_POST_HEAD_POINTER_REGISTER_PCI_SIDE 0x068
#define INBOUND_POST_TAIL_POINTER_REGISTER_PCI_SIDE 0x06C
#define OUTBOUND_FREE_HEAD_POINTER_REGISTER_PCI_SIDE 0x070
#define OUTBOUND_FREE_TAIL_POINTER_REGISTER_PCI_SIDE 0x074
#define OUTBOUND_POST_HEAD_POINTER_REGISTER_PCI_SIDE 0x078
#define OUTBOUND_POST_TAIL_POINTER_REGISTER_PCI_SIDE 0x07C

#define INBOUND_MESSAGE_REGISTER0_CPU_SIDE	0X1C10
#define INBOUND_MESSAGE_REGISTER1_CPU_SIDE  	0X1C14
#define OUTBOUND_MESSAGE_REGISTER0_CPU_SIDE 	0X1C18
#define OUTBOUND_MESSAGE_REGISTER1_CPU_SIDE  	0X1C1C
#define INBOUND_DOORBELL_REGISTER_CPU_SIDE  	0X1C20
#define INBOUND_INTERRUPT_CAUSE_REGISTER_CPU_SIDE 0X1C24
#define INBOUND_INTERRUPT_MASK_REGISTER_CPU_SIDE 0X1C28
#define OUTBOUND_DOORBELL_REGISTER_CPU_SIDE 	0X1C2C
#define OUTBOUND_INTERRUPT_CAUSE_REGISTER_CPU_SIDE 0X1C30
#define OUTBOUND_INTERRUPT_MASK_REGISTER_CPU_SIDE  0X1C34
#define INBOUND_QUEUE_PORT_VIRTUAL_REGISTER_CPU_SIDE 0X1C40
#define OUTBOUND_QUEUE_PORT_VIRTUAL_REGISTER_CPU_SIDE 0X1C44
#define QUEUE_CONTROL_REGISTER_CPU_SIDE 	0X1C50
#define QUEUE_BASE_ADDRESS_REGISTER_CPU_SIDE 	0X1C54
#define INBOUND_FREE_HEAD_POINTER_REGISTER_CPU_SIDE 0X1C60
#define INBOUND_FREE_TAIL_POINTER_REGISTER_CPU_SIDE 0X1C64
#define INBOUND_POST_HEAD_POINTER_REGISTER_CPU_SIDE 0X1C68
#define INBOUND_POST_TAIL_POINTER_REGISTER_CPU_SIDE 0X1C6C
#define OUTBOUND_FREE_HEAD_POINTER_REGISTER_CPU_SIDE 0X1C70
#define OUTBOUND_FREE_TAIL_POINTER_REGISTER_CPU_SIDE 0X1C74
#define OUTBOUND_POST_HEAD_POINTER_REGISTER_CPU_SIDE 0X1C78
#define OUTBOUND_POST_TAIL_POINTER_REGISTER_CPU_SIDE 0X1C7C


/* Ethernet Ports */
#define ETH_PHY_ADDR_REG	 		0x080800 
#define ETH_SMI_REG				0x080810 
#define GT_SMIR_REG				ETH_SMI_REG
#define	ETHERNET_PORTS_DIFFERENCE_OFFSETS	0x4000

#define ETH0_PORT_CONFIG_REG			0x084800 
#define ETH0_PORT_CONFIG_EXT_REG		0x084808 
#define ETH0_PORT_COMMAND_REG			0x084810 
#define ETH0_PORT_STATUS_REG			0x084818 
#define ETH0_SERIAL_PARAMETRS_REG		0x084820 
#define ETH0_HASH_TABLE_PTR_REG			0x084828 
#define ETH0_FLOW_CNTROL_SOURCE_ADDR_LO    0x084830 
#define ETH0_FLOW_CNTROL_SOURCE_ADDR_HO    0x084838 
#define ETH0_SDMA_CONFIG_REG          0x084840 
#define ETH0_SDMA_COMMAND_REG            0x084848 
#define ETH0_INTERRUPT_CAUSE_REG            0x084850 
#define ETH0_INTERRUPT_MASK_REG             0x084858

#define ETHER0_TOS_PRIORITY_0_LOW       0x084860
#define ETHER0_TOS_PRIORITY_0_HIGH      0x084864
#define ETHER0_TOS_PRIORITY_1_LOW       0x084868
#define ETHER0_TOS_PRIORITY_1_HIGH      0x08486c
#define ETHER0_VLAN_TO_PRIORITY         0x084870
 
#define ETH0_FIRST_RX_DESC_PTR0         0x084880
#define ETH0_FIRST_RX_DESC_PTR1         0x084884
#define ETH0_FIRST_RX_DESC_PTR2         0x084888
#define ETH0_FIRST_RX_DESC_PTR3         0x08488C
#define ETH0_CURRENT_RX_DESC_PTR0        0x0848A0
#define ETH0_CURRENT_RX_DESC_PTR1        0x0848A4
#define ETH0_CURRENT_RX_DESC_PTR2        0x0848A8
#define ETH0_CURRENT_RX_DESC_PTR3        0x0848AC
#define ETH0_CURRENT_TX_DESC_PTR0        0x0848E0
#define ETH0_CURRENT_TX_DESC_PTR1        0x0848E4
#define ETH0_MIB_COUNTER_BASE           0x085800 

#define ETHER1_PORT_CONFIG_REG          0x088800 
#define ETHER1_PORT_CONFIG_EXT_REG      0x088808 
#define ETHER1_PORT_COMM_REG            0x088810 
#define ETHER1_PORT_STATUS_REG          0x088818 
#define ETHER1_SER_PARAM_REG            0x088820 
#define ETHER1_HASH_TBL_PTR_REG         0x088828 
#define ETHER1_FLOW_CNTRL_SRC_ADDR_L    0x088830 
#define ETHER1_FLOW_CNTRL_SRC_ADDR_H    0x088838 
#define ETHER1_SDMA_CONFIG_REG          0x088840 
#define ETHER1_SDMA_COMM_REG            0x088848 
#define ETHER1_INT_CAUSE_REG            0x088850 
#define ETHER1_INT_MASK_REG             0x088858 
#define ETHER1_1ST_RX_DESC_PTR0         0x088880
#define ETHER1_1ST_RX_DESC_PTR1         0x088884
#define ETHER1_1ST_RX_DESC_PTR2         0x088888
#define ETHER1_1ST_RX_DESC_PTR3         0x08888C
#define ETHER1_CURR_RX_DESC_PTR0        0x0888A0
#define ETHER1_CURR_RX_DESC_PTR1        0x0888A4
#define ETHER1_CURR_RX_DESC_PTR2        0x0888A8
#define ETHER1_CURR_RX_DESC_PTR3        0x0888AC
#define ETHER1_CURR_TX_DESC_PTR0        0x0888E0
#define ETHER1_CURR_TX_DESC_PTR1        0x0888E4
#define ETHER1_MIB_COUNT_BASE           0x089800 

/* SDMAs */
#define SDMA_GROUP_CONFIG_REG   0x101AF0
/* SDMA Group 0 */
#define SDMA_G0_CHAN0_CONFIG_REG        0x000900 
#define SDMA_G0_CHAN0_COMM_REG          0x000908 
#define SDMA_G0_CHAN0_RX_DESC_BASE      0x008900 
#define SDMA_G0_CHAN0_CURR_RX_DESC_PTR  0x008910
#define SDMA_G0_CHAN0_TX_DESC_BASE      0x00C900 
#define SDMA_G0_CHAN0_CURR_TX_DESC_PTR  0x00C910
#define SDMA_G0_CHAN0_1ST_TX_DESC_PTR   0x00C914
#define SDMA_G0_CHAN1_CONFIG_REG        0x010900
#define SDMA_G0_CHAN1_COMM_REG          0x010908
#define SDMA_G0_CHAN1_RX_DESC_BASE      0x018900 
#define SDMA_G0_CHAN1_CURR_RX_DESC_PTR  0x018910
#define SDMA_G0_CHAN1_TX_DESC_BASE      0x01C900 
#define SDMA_G0_CHAN1_CURR_TX_DESC_PTR  0x01C910
#define SDMA_G0_CHAN1_1ST_TX_DESC_PTR   0x01C914
#define SDMA_G0_CHAN2_CONFIG_REG        0x020900
#define SDMA_G0_CHAN2_COMM_REG          0x020908
#define SDMA_G0_CHAN2_RX_DESC_BASE      0x028900 
#define SDMA_G0_CHAN2_CURR_RX_DESC_PTR  0x028910
#define SDMA_G0_CHAN2_TX_DESC_BASE      0x02C900 
#define SDMA_G0_CHAN2_CURR_TX_DESC_PTR  0x02C910
#define SDMA_G0_CHAN2_1ST_TX_DESC_PTR   0x02C914
#define SDMA_G0_CHAN3_CONFIG_REG        0x030900
#define SDMA_G0_CHAN3_COMM_REG          0x030908
#define SDMA_G0_CHAN3_RX_DESC_BASE      0x038900 
#define SDMA_G0_CHAN3_CURR_RX_DESC_PTR  0x038910
#define SDMA_G0_CHAN3_TX_DESC_BASE      0x03C900 
#define SDMA_G0_CHAN3_CURR_TX_DESC_PTR  0x03C910
#define SDMA_G0_CHAN3_1ST_TX_DESC_PTR   0x03C914
#define SDMA_G0_CHAN4_CONFIG_REG        0x040900
#define SDMA_G0_CHAN4_COMM_REG          0x040908
#define SDMA_G0_CHAN4_RX_DESC_BASE      0x048900 
#define SDMA_G0_CHAN4_CURR_RX_DESC_PTR  0x048910
#define SDMA_G0_CHAN4_TX_DESC_BASE      0x04C900 
#define SDMA_G0_CHAN4_CURR_TX_DESC_PTR  0x04C910
#define SDMA_G0_CHAN4_1ST_TX_DESC_PTR   0x04C914
#define SDMA_G0_CHAN5_CONFIG_REG        0x050900
#define SDMA_G0_CHAN5_COMM_REG          0x050908
#define SDMA_G0_CHAN5_RX_DESC_BASE      0x058900 
#define SDMA_G0_CHAN5_CURR_RX_DESC_PTR  0x058910
#define SDMA_G0_CHAN5_TX_DESC_BASE      0x05C900 
#define SDMA_G0_CHAN5_CURR_TX_DESC_PTR  0x05C910
#define SDMA_G0_CHAN5_1ST_TX_DESC_PTR   0x05C914
#define SDMA_G0_CHAN6_CONFIG_REG        0x060900
#define SDMA_G0_CHAN6_COMM_REG          0x060908
#define SDMA_G0_CHAN6_RX_DESC_BASE      0x068900 
#define SDMA_G0_CHAN6_CURR_RX_DESC_PTR  0x068910
#define SDMA_G0_CHAN6_TX_DESC_BASE      0x06C900 
#define SDMA_G0_CHAN6_CURR_TX_DESC_PTR  0x06C910
#define SDMA_G0_CHAN6_1ST_TX_DESC_PTR   0x06C914
#define SDMA_G0_CHAN7_CONFIG_REG        0x070900
#define SDMA_G0_CHAN7_COMM_REG          0x070908
#define SDMA_G0_CHAN7_RX_DESC_BASE      0x078900
#define SDMA_G0_CHAN7_CURR_RX_DESC_PTR  0x078910
#define SDMA_G0_CHAN7_TX_DESC_BASE      0x07C900 
#define SDMA_G0_CHAN7_CURR_TX_DESC_PTR  0x07C910
#define SDMA_G0_CHAN7_1ST_TX_DESC_PTR   0x07C914
/* SDMA Group 1 */
#define SDMA_G1_CHAN0_CONFIG_REG        0x100900
#define SDMA_G1_CHAN0_COMM_REG          0x100908
#define SDMA_G1_CHAN0_RX_DESC_BASE      0x108900 
#define SDMA_G1_CHAN0_CURR_RX_DESC_PTR  0x108910
#define SDMA_G1_CHAN0_TX_DESC_BASE      0x10C900 
#define SDMA_G1_CHAN0_CURR_TX_DESC_PTR  0x10C910 
#define SDMA_G1_CHAN0_1ST_TX_DESC_PTR   0x10C914
#define SDMA_G1_CHAN1_CONFIG_REG        0x110900
#define SDMA_G1_CHAN1_COMM_REG          0x110908
#define SDMA_G1_CHAN1_RX_DESC_BASE      0x118900 
#define SDMA_G1_CHAN1_CURR_RX_DESC_PTR  0x118910
#define SDMA_G1_CHAN1_TX_DESC_BASE      0x11C900 
#define SDMA_G1_CHAN1_CURR_TX_DESC_PTR  0x11C910
#define SDMA_G1_CHAN1_1ST_TX_DESC_PTR   0x11C914
#define SDMA_G1_CHAN2_CONFIG_REG        0x120900
#define SDMA_G1_CHAN2_COMM_REG          0x120908
#define SDMA_G1_CHAN2_RX_DESC_BASE      0x128900 
#define SDMA_G1_CHAN2_CURR_RX_DESC_PTR  0x128910
#define SDMA_G1_CHAN2_TX_DESC_BASE      0x12C900 
#define SDMA_G1_CHAN2_CURR_TX_DESC_PTR  0x12C910
#define SDMA_G1_CHAN2_1ST_TX_DESC_PTR   0x12C914
#define SDMA_G1_CHAN3_CONFIG_REG        0x130900
#define SDMA_G1_CHAN3_COMM_REG          0x130908
#define SDMA_G1_CHAN3_RX_DESC_BASE      0x138900 
#define SDMA_G1_CHAN3_CURR_RX_DESC_PTR  0x138910
#define SDMA_G1_CHAN3_TX_DESC_BASE      0x13C900 
#define SDMA_G1_CHAN3_CURR_TX_DESC_PTR  0x13C910
#define SDMA_G1_CHAN3_1ST_TX_DESC_PTR   0x13C914
#define SDMA_G1_CHAN4_CONFIG_REG        0x140900
#define SDMA_G1_CHAN4_COMM_REG          0x140908
#define SDMA_G1_CHAN4_RX_DESC_BASE      0x148900 
#define SDMA_G1_CHAN4_CURR_RX_DESC_PTR  0x148910
#define SDMA_G1_CHAN4_TX_DESC_BASE      0x14C900 
#define SDMA_G1_CHAN4_CURR_TX_DESC_PTR  0x14C910
#define SDMA_G1_CHAN4_1ST_TX_DESC_PTR   0x14C914
#define SDMA_G1_CHAN5_CONFIG_REG        0x150900
#define SDMA_G1_CHAN5_COMM_REG          0x150908
#define SDMA_G1_CHAN5_RX_DESC_BASE      0x158900 
#define SDMA_G1_CHAN5_CURR_RX_DESC_PTR  0x158910
#define SDMA_G1_CHAN5_TX_DESC_BASE      0x15C900 
#define SDMA_G1_CHAN5_CURR_TX_DESC_PTR  0x15C910
#define SDMA_G1_CHAN5_1ST_TX_DESC_PTR   0x15C914
#define SDMA_G1_CHAN6_CONFIG_REG        0x160900
#define SDMA_G1_CHAN6_COMM_REG          0x160908
#define SDMA_G1_CHAN6_RX_DESC_BASE      0x168900 
#define SDMA_G1_CHAN6_CURR_RX_DESC_PTR  0x168910
#define SDMA_G1_CHAN6_TX_DESC_BASE      0x16C900 
#define SDMA_G1_CHAN6_CURR_TX_DESC_PTR  0x16C910
#define SDMA_G1_CHAN6_1ST_TX_DESC_PTR   0x16C914
#define SDMA_G1_CHAN7_CONFIG_REG        0x170900
#define SDMA_G1_CHAN7_COMM_REG          0x170908
#define SDMA_G1_CHAN7_RX_DESC_BASE      0x178900 
#define SDMA_G1_CHAN7_CURR_RX_DESC_PTR  0x178910
#define SDMA_G1_CHAN7_TX_DESC_BASE      0x17C900 
#define SDMA_G1_CHAN7_CURR_TX_DESC_PTR  0x17C910
#define SDMA_G1_CHAN7_1ST_TX_DESC_PTR   0x17C914
/*  MPSCs  */
#define MPSC0_MAIN_CONFIG_LOW   0x000A00 
#define MPSC0_MAIN_CONFIG_HIGH  0x000A04 
#define MPSC0_PROTOCOL_CONFIG   0x000A08 
#define MPSC_CHAN0_REG1         0x000A0C
#define MPSC_CHAN0_REG2         0x000A10
#define MPSC_CHAN0_REG3         0x000A14
#define MPSC_CHAN0_REG4         0x000A18
#define MPSC_CHAN0_REG5         0x000A1C
#define MPSC_CHAN0_REG6         0x000A20 
#define MPSC_CHAN0_REG7         0x000A24
#define MPSC_CHAN0_REG8         0x000A28
#define MPSC_CHAN0_REG9         0x000A2C
#define MPSC_CHAN0_REG10        0x000A30
#define MPSC_CHAN0_REG11        0x000A34
#define MPSC1_MAIN_CONFIG_LOW   0x008A00 
#define MPSC1_MAIN_CONFIG_HIGH  0x008A04 
#define MPSC1_PROTOCOL_CONFIG   0x008A08 
#define MPSC_CHAN1_REG1         0x008A0C
#define MPSC_CHAN1_REG2         0x008A10
#define MPSC_CHAN1_REG3         0x008A14
#define MPSC_CHAN1_REG4         0x008A18
#define MPSC_CHAN1_REG5         0x008A1C
#define MPSC_CHAN1_REG6         0x008A20
#define MPSC_CHAN1_REG7         0x008A24
#define MPSC_CHAN1_REG8         0x008A28
#define MPSC_CHAN1_REG9         0x008A2C
#define MPSC_CHAN1_REG10        0x008A30
#define MPSC_CHAN1_REG11        0x008A34
#define MPSC2_MAIN_CONFIG_LOW   0x010A00 
#define MPSC2_MAIN_CONFIG_HIGH  0x010A04 
#define MPSC2_PROTOCOL_CONFIG   0x010A08 
#define MPSC_CHAN2_REG1         0x010A0C
#define MPSC_CHAN2_REG2         0x010A10
#define MPSC_CHAN2_REG3         0x010A14
#define MPSC_CHAN2_REG4         0x010A18
#define MPSC_CHAN2_REG5         0x010A1C
#define MPSC_CHAN2_REG6         0x010A20 
#define MPSC_CHAN2_REG7         0x010A24
#define MPSC_CHAN2_REG8         0x010A28
#define MPSC_CHAN2_REG9         0x010A2C
#define MPSC_CHAN2_REG10        0x010A30
#define MPSC_CHAN2_REG11        0x010A34
#define MPSC3_MAIN_CONFIG_LOW   0x018A00 
#define MPSC3_MAIN_CONFIG_HIGH  0x018A04
#define MPSC3_PROTOCOL_CONFIG   0x018A08 
#define MPSC_CHAN3_REG1         0x018A0C
#define MPSC_CHAN3_REG2         0x018A10
#define MPSC_CHAN3_REG3         0x018A14
#define MPSC_CHAN3_REG4         0x018A18
#define MPSC_CHAN3_REG5         0x018A1C
#define MPSC_CHAN3_REG6         0x018A20
#define MPSC_CHAN3_REG7         0x018A24
#define MPSC_CHAN3_REG8         0x018A28
#define MPSC_CHAN3_REG9         0x018A2C
#define MPSC_CHAN3_REG10        0x018A30
#define MPSC_CHAN3_REG11        0x018A34
#define MPSC4_MAIN_CONFIG_LOW   0x020A00 
#define MPSC4_MAIN_CONFIG_HIGH  0x020A04
#define MPSC4_PROTOCOL_CONFIG   0x020A08 
#define MPSC_CHAN4_REG1         0x020A0C
#define MPSC_CHAN4_REG2         0x020A10
#define MPSC_CHAN4_REG3         0x020A14
#define MPSC_CHAN4_REG4         0x020A18
#define MPSC_CHAN4_REG5         0x020A1C
#define MPSC_CHAN4_REG6         0x020A20 
#define MPSC_CHAN4_REG7         0x020A24 
#define MPSC_CHAN4_REG8         0x020A28 
#define MPSC_CHAN4_REG9         0x020A2C 
#define MPSC_CHAN4_REG10        0x020A30
#define MPSC_CHAN4_REG11        0x020A34
#define MPSC5_MAIN_CONFIG_LOW   0x028A00 
#define MPSC5_MAIN_CONFIG_HIGH  0x028A04
#define MPSC5_PROTOCOL_CONFIG   0x028A08 
#define MPSC_CHAN5_REG1         0x028A0C
#define MPSC_CHAN5_REG2         0x028A10
#define MPSC_CHAN5_REG3         0x028A14
#define MPSC_CHAN5_REG4         0x028A18
#define MPSC_CHAN5_REG5         0x028A1C
#define MPSC_CHAN5_REG6         0x028A20
#define MPSC_CHAN5_REG7         0x028A24
#define MPSC_CHAN5_REG8         0x028A28
#define MPSC_CHAN5_REG9         0x028A2C
#define MPSC_CHAN5_REG10        0x028A30
#define MPSC_CHAN5_REG11        0x028A34
#define MPSC6_MAIN_CONFIG_LOW   0x030A00 
#define MPSC6_MAIN_CONFIG_HIGH  0x030A04
#define MPSC6_PROTOCOL_CONFIG   0x030A08 
#define MPSC_CHAN6_REG1         0x030A0C
#define MPSC_CHAN6_REG2         0x030A10
#define MPSC_CHAN6_REG3         0x030A14
#define MPSC_CHAN6_REG4         0x030A18
#define MPSC_CHAN6_REG5         0x030A1C
#define MPSC_CHAN6_REG6         0x030A20
#define MPSC_CHAN6_REG7         0x030A24
#define MPSC_CHAN6_REG8         0x030A28
#define MPSC_CHAN6_REG9         0x030A2C
#define MPSC_CHAN6_REG10        0x030A30
#define MPSC_CHAN6_REG11        0x030A34
#define MPSC7_MAIN_CONFIG_LOW   0x038A00 
#define MPSC7_MAIN_CONFIG_HIGH  0x038A04
#define MPSC7_PROTOCOL_CONFIG   0x038A08 
#define MPSC_CHAN7_REG1         0x038A0C
#define MPSC_CHAN7_REG2         0x038A10
#define MPSC_CHAN7_REG3         0x038A14
#define MPSC_CHAN7_REG4         0x038A18
#define MPSC_CHAN7_REG5         0x038A1C
#define MPSC_CHAN7_REG6         0x038A20
#define MPSC_CHAN7_REG7         0x038A24
#define MPSC_CHAN7_REG8         0x038A28
#define MPSC_CHAN7_REG9         0x038A2C
#define MPSC_CHAN7_REG10        0x038A30
#define MPSC_CHAN7_REG11        0x038A34
/*  FlexTDMs  */
#define FXTDM0_TDPR0_BLK0_BASE  0x000B00    /* TDPR0 - Transmit Dual Port RAM. block size 0xff */
#define FXTDM0_TDPR0_BLK1_BASE  0x001B00 
#define FXTDM0_TDPR0_BLK2_BASE  0x002B00 
#define FXTDM0_TDPR0_BLK3_BASE  0x003B00 
#define FXTDM0_RDPR0_BLK0_BASE  0x004B00    /* RDPR0 - Receive Dual Port RAM. block size 0xff */
#define FXTDM0_RDPR0_BLK1_BASE  0x005B00 
#define FXTDM0_RDPR0_BLK2_BASE  0x006B00 
#define FXTDM0_RDPR0_BLK3_BASE  0x007B00 
#define FXTDM0_TX_READ_PTR      0x008B00
#define FXTDM0_RX_READ_PTR      0x008B04
#define FXTDM0_CONFIG_REG       0x008B08
#define FXTDM0_AUX_CHANA_TX_REG 0x008B0C
#define FXTDM0_AUX_CHANA_RX_REG 0x008B10
#define FXTDM0_AUX_CHANB_TX_REG 0x008B14
#define FXTDM0_AUX_CHANB_RX_REG 0x008B18
#define FXTDM1_TDPR1_BLK0_BASE  0x010B00 
#define FXTDM1_TDPR1_BLK1_BASE  0x011B00 
#define FXTDM1_TDPR1_BLK2_BASE  0x012B00 
#define FXTDM1_TDPR1_BLK3_BASE  0x013B00 
#define FXTDM1_RDPR1_BLK0_BASE  0x014B00 
#define FXTDM1_RDPR1_BLK1_BASE  0x015B00 
#define FXTDM1_RDPR1_BLK2_BASE  0x016B00 
#define FXTDM1_RDPR1_BLK3_BASE  0x017B00 
#define FXTDM1_TX_READ_PTR      0x018B00
#define FXTDM1_RX_READ_PTR      0x018B04
#define FXTDM1_CONFIG_REG       0x018B08
#define FXTDM1_AUX_CHANA_TX_REG 0x018B0C
#define FXTDM1_AUX CHANA_RX_REG 0x018B10
#define FLTDM1_AUX_CHANB_TX_REG 0x018B14
#define FLTDM1_AUX_CHANB_RX_REG 0x018B18
#define FLTDM2_TDPR2_BLK0_BASE  0x020B00
#define FLTDM2_TDPR2_BLK1_BASE  0x021B00 
#define FLTDM2_TDPR2_BLK2_BASE  0x022B00
#define FLTDM2_TDPR2_BLK3_BASE  0x023B00
#define FLTDM2_RDPR2_BLK0_BASE  0x024B00
#define FLTDM2_RDPR2_BLK1_BASE  0x025B00
#define FLTDM2_RDPR2_BLK2_BASE  0x026B00
#define FLTDM2_RDPR2_BLK3_BASE  0x027B00
#define FLTDM2_TX_READ_PTR      0x028B00
#define FLTDM2_RX_READ_PTR      0x028B04
#define FLTDM2_CONFIG_REG       0x028B08
#define FLTDM2_AUX_CHANA_TX_REG 0x028B0C
#define FLTDM2_AUX_CHANA_RX_REG 0x028B10
#define FLTDM2_AUX_CHANB_TX_REG 0x028B14
#define FLTDM2_AUX_CHANB_RX_REG 0x028B18
#define FLTDM3_TDPR3_BLK0_BASE  0x030B00
#define FLTDM3_TDPR3_BLK1_BASE  0x031B00
#define FLTDM3_TDPR3_BLK2_BASE  0x032B00
#define FLTDM3_TDPR3_BLK3_BASE  0x033B00
#define FXTDM3_RDPR3_BLK0_BASE  0x034B00
#define FXTDM3_RDPR3_BLK1_BASE  0x035B00
#define FXTDM3_RDPR3_BLK2_BASE  0x036B00
#define FXTDM3_RDPR3_BLK3_BASE  0x037B00
#define FXTDM3_TX_READ_PTR      0x038B00
#define FXTDM3_RX_READ_PTR      0x038B04
#define FXTDM3_CONFIG_REG       0x038B08
#define FXTDM3_AUX_CHANA_TX_REG 0x038B0C
#define FXTDM3_AUX_CHANA_RX_REG 0x038B10
#define FXTDM3_AUX_CHANB_TX_REG 0x038B14
#define FXTDM3_AUX_CHANB_RX_REG 0x038B18
/*  Baud Rate Generators  */
#define BRG0_CONFIG_REG     0x102A00 
#define BRG0_BAUD_TUNE_REG  0x102A04 
#define BRG1_CONFIG_REG     0x102A08 
#define BRG1_BAUD_TUNE_REG  0x102A0C 
#define BRG2_CONFIG_REG     0x102A10 
#define BRG2_BAUD_TUNE_REG  0x102A14 
#define BRG3_CONFIG_REG     0x102A18 
#define BRG3_BAUD_TUNE_REG  0x102A1C 
#define BRG4_CONFIG_REG     0x102A20 
#define BRG4_BAUD_TUNE_REG  0x102A24 
#define BRG5_CONFIG_REG     0x102A28 
#define BRG5_BAUD_TUNE_REG  0x102A2C 
#define BRG6_CONFIG_REG     0x102A30 
#define BRG6_BAUD_TUNE_REG  0x102A34 
#define BRG7_CONFIG_REG     0x102A38 
#define BRG7_BAUD_TUNE_REG  0x102A3C 
/*  Routing Registers  */
#define ROUTE_MAIN_REG      0x101A00 
#define ROUTE_RX_CLOCK_REG  0x101A10 
#define ROUTE_TX_CLOCK_REG  0x101A20 
#define PORT_ROUTING_REGISTER 0x101a30
/*  General Purpose Ports  */
#define GPP_CONFIG0     0x100A00 
#define GPP_CONFIG1     0x100A04 
#define GPP_CONFIG2     0x100A08 
#define GPP_CONFIG3     0x100A0C 
#define GPP_IO0         0x100A20 
#define GPP_IO1         0x100A24 
#define GPP_IO2         0x100A28 
#define GPP_IO3         0x100A2C 
#define GPP_DATA0       0x100A40 
#define GPP_DATA1       0x100A44 
#define GPP_DATA2       0x100A48 
#define GPP_DATA3       0x100A4C 
#define GPP_LEVEL0      0x100A60 
#define GPP_LEVEL1      0x100A64 
#define GPP_LEVEL2      0x100A68 
#define GPP_LEVEL3      0x100A6C 
/*  Watchdog  */
#define WD_CONFIG_REG   0x101A80 
#define WD_VALUE_REG    0x101A84 

/* Communication Unit Arbiter  */
#define COMM_UNIT_ARBTR_CONFIG_REG 0x101AC0
#define COMM_UNIT_ARBTR_EXT_REG    0x101AC4

/* mcsc registers */


/* MCDMA registers */
#define MCDMA_GLOBAL_CONTROL_REGISTER   0x044a00

#define MCSC_GLOBAL_INTERRUPT_CAUSE     0x048a04
#define MCSC_EXTENDED_INTERRUPT_CAUSE   0x048a08

#define MCSC_GLOBAL_INTERRUPT_MASK      0x048a0c
#define MCSC_EXTENDED_INTERRUPT_MASK    0x048a10

#define IQC_FIRST                       0x048a14
#define IQC_LAST                        0x048a18
#define IQC_HEAD                        0x048a1c
#define IQC_TAIL                        0x048a20

#define IQC_ENABLE_INTERRUPTS_REGISTER  0x048a24

/* MCSC registers */
#define MCSC_GLOBAL_CONTROL_REGISTER    0x48a00
         
#endif /* __INCgt96132Rh */
