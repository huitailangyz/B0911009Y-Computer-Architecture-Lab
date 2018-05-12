/******************************************************************************
  * Description
  *   This file declare all functions for GMAC networking device driver.
  * Remarks
  *   None.
  * Bugs
  *   None.
  * TODO
  *    * None.
  * Hinetry
  *   <table>
  *   \Author     Date        Change Description
  *   ----------  ----------  -------------------
  *   Justin Wu   2007.5.28    Initialize.
  *   </table>
  *
  ****************************************************************************/

//#include <huaya_bsp.h>

/* Register base address */
#define DMA_REG_BASE				0x00001000
#define MAC_REG_BASE				0x00000000

/* DMA register */
#define DMA_BUS_MODE				(0x0000 + DMA_REG_BASE)	/* CSR0 - Bus Mode Register                          */
#define 	DMA_ADDR_ALIGN_BEATS	0x02000000	/* Address alignment beats                          25     RW                */
#define 	DMA_FIXED_BURST_EN		0x00010000	/* (FB)Fixed Burst SINGLE, INCR4, INCR8 or INCR16   16     RW                */
#define 	DMA_FIXED_BURST_DI		0x00000000	/*             SINGLE, INCR                                          0       */
#define 	DMA_TX_PRI_RATIO11		0x00000000	/* (PR)TX:RX DMA priority ratio 1:1                15:14   RW        00      */
#define 	DMA_TX_PRI_RATIO21		0x00004000	/* (PR)TX:RX DMA priority ratio 2:1                                          */
#define 	DMA_TX_PRI_RATIO31		0x00008000	/* (PR)TX:RX DMA priority ratio 3:1                                          */
#define 	DMA_TX_PRI_RATIO41		0x0000C000	/* (PR)TX:RX DMA priority ratio 4:1                                          */
#define 	DMA_BURST_LEN32			0x00002000	/* (PBL) programmable Dma burst length = 32        13:8    RW                */
#define 	DMA_BURST_LEN16			0x00001000	/* Dma burst length = 16                                                     */
#define 	DMA_BURST_LEN8			0x00000800	/* Dma burst length = 8                                                      */
#define 	DMA_BURST_LEN4			0x00000400	/* Dma burst length = 4                                                      */
#define 	DMA_BURST_LEN2			0x00000200	/* Dma burst length = 2                                                      */
#define 	DMA_BURST_LEN1			0x00000100	/* Dma burst length = 1                                                      */
#define 	DMA_BURST_LEN0			0x00000000	/* Dma burst length = 0                                               0x00   */
#define 	DMA_DES_SKIP16			0x00000040	/* (DSL)Descriptor skip length (no.of dwords)       6:2     RW               */
#define 	DMA_DES_SKIP8			0x00000020	/* between two unchained descriptors                                         */
#define 	DMA_DES_SKIP4			0x00000010	/*                                                                           */
#define 	DMA_DES_SKIP2			0x00000008	/*                                                                           */
#define 	DMA_DES_SKIP1			0x00000004	/*                                                                           */
#define 	DMA_DES_SKIP0			0x00000000	/*                                                                    0x00   */
#define 	DMA_ARB_RR				0x00000000	/* (DA) DMA RR arbitration                            1     RW         0     */
#define 	DMA_ARB_PR				0x00000002	/* Rx has priority over Tx                                                   */
#define 	DMA_RESET_ON			0x00000001	/* (SWR)Software Reset DMA engine                     0     RW               */
#define 	DMA_RESET_OFF			0x00000000	/*                                                                      0    */
#define DMA_TX_POLL					(0x0004 + DMA_REG_BASE)	/* CSR1 - Transmit Poll Demand Register              */
#define DMA_RX_POLL					(0x0008 + DMA_REG_BASE)	/* CSR2 - Receive Poll Demand Register               */
#define DMA_RX_BASE					(0x000C + DMA_REG_BASE)	/* CSR3 - Receive Descriptor list base address       */
#define DMA_TX_BASE					(0x0010 + DMA_REG_BASE)	/* CSR4 - Transmit Descriptor list base address      */
#define DMA_STA						(0x0014 + DMA_REG_BASE)	/* CSR5 - Dma status Register                        */
/*Bit 28 27 and 26 indicate whether the interrupt due to PMT GMACMMC or GMAC LINE Remaining bits are DMA interrupts*/
#define 	GMAC_PMT_INT			0x10000000	/* (GPI)Gmac subsystem interrupt                      28     RO       0       */
#define 	GMAC_MMC_INT			0x08000000	/* (GMI)Gmac MMC subsystem interrupt                  27     RO       0       */
#define 	GMAC_LINE_INT			0x04000000	/* Line interface interrupt                           26     RO       0       */
#define 	DMA_ERR_BIT2			0x02000000	/* (EB)Error bits 0-data buffer, 1-desc. access       25     RO       0       */
#define 	DMA_ERR_BIT1			0x01000000	/* (EB)Error bits 0-write trnsf, 1-read transfr       24     RO       0       */
#define 	DMA_ERR_BIT0			0x00800000	/* (EB)Error bits 0-Rx DMA, 1-Tx DMA                  23     RO       0       */
#define 	DMA_TX_STAT				0x00700000	/* (TS)Transmit process state                         22:20  RO               */
#define 	DMA_TX_STOPPED			0x00000000	/* Stopped - Reset or Stop Tx Command issued                         000      */
#define 	DMA_TX_FETCHING			0x00100000	/* Running - fetching the Tx descriptor                                       */
#define 	DMA_TX_WAITING			0x00200000	/* Running - waiting for status                                               */
#define 	DMA_TX_READING			0x00300000	/* Running - reading the data from host memory                                */
#define 	DMA_TX_SUSPENDED		0x00600000	/* Suspended - Tx Descriptor unavailabe                                       */
#define 	DMA_TX_CLOSING			0x00700000	/* Running - closing Rx descriptor                                            */
#define 	DMA_RX_STAT				0x000E0000	/* (RS)Receive process state                         19:17  RO                */
#define 	DMA_RX_STOPPED			0x00000000	/* Stopped - Reset or Stop Rx Command issued                         000      */
#define 	DMA_RX_FETCHING			0x00020000	/* Running - fetching the Rx descriptor                                       */
#define 	DMA_RX_WAITING			0x00060000	/* Running - waiting for packet                                               */
#define 	DMA_RX_SUSPENDED		0x00080000	/* Suspended - Rx Descriptor unavailable                                      */
#define 	DMA_RX_CLOSING			0x000A0000	/* Running - closing descriptor                                               */
#define 	DMA_RX_QUEUING			0x000E0000	/* Running - queuing the recieve frame into host memory                       */
#define 	DMA_INT_NORMAL			0x00010000	/* (NIS)Normal interrupt summary                     16     RW        0       */
#define 	DMA_INT_ABNORMAL		0x00008000	/* (AIS)Abnormal interrupt summary                   15     RW        0       */
#define 	DMA_INT_EARLY_RX		0x00004000	/* Early receive interrupt (Normal)       RW        0       */
#define 	DMA_INT_BUS_ERR			0x00002000	/* Fatal bus error (Abnormal)             RW        0       */
#define 	DMA_INT_EARLY_TX		0x00000400	/* Early transmit interrupt (Abnormal)    RW        0       */
#define 	DMA_INT_RX_TMO			0x00000200	/* Receive Watchdog Timeout (Abnormal)    RW        0       */
#define 	DMA_INT_RX_STOPPED		0x00000100	/* Receive process stopped (Abnormal)     RW        0       */
#define 	DMA_INT_RX_NO_BUF		0x00000080	/* Receive buffer unavailable (Abnormal)  RW        0       */
#define 	DMA_INT_RX_COMPLETED	0x00000040	/* Completion of frame reception (Normal) RW        0       */
#define 	DMA_INT_TX_UNDERFLOW	0x00000020	/* Transmit underflow (Abnormal)          RW        0       */
#define 	DMA_INT_RX_OVERFLOW		0x00000010	/* Receive Buffer overflow interrupt      RW        0       */
#define 	DMA_INT_TX_JAB_TMO		0x00000008	/* Transmit Jabber Timeout (Abnormal)     RW        0       */
#define 	DMA_INT_TX_NO_BUF		0x00000004	/* Transmit buffer unavailable (Normal)   RW        0       */
#define 	DMA_INT_TX_STOPPED		0x00000002	/* Transmit process stopped (Abnormal)    RW        0       */
#define 	DMA_INT_TX_COMPLETED	0x00000001	/* Transmit completed (Normal)            RW        0       */
#define DMA_CTR						(0x0018 + DMA_REG_BASE)	/* CSR6 - Dma Operation Mode Register                */
#define 	DMA_DI_DROP_TCP_CS		0x04000000	/* (DT) Dis. drop. of tcp/ip CS error frames        26      RW        0       */
#define 	DMA_STORE_FORWARD		0x00200000	/* (SF)Store and forward                            21      RW        0       */
#define 	DMA_FLUSH_TX_FIFO		0x00100000	/* (FTF)Tx FIFO controller is reset to default      20      RW        0       */
#define 	DMA_TX_THR_CTRL			0x0001C000	/* (TTC)Controls thre Threh of MTL tx Fifo          16:14   RW                */
#define 	DMA_TX_THR_CTRL16		0x0001C000	/* (TTC)Controls thre Threh of MTL tx Fifo 16       16:14   RW                */
#define 	DMA_TX_THR_CTRL24		0x00018000	/* (TTC)Controls thre Threh of MTL tx Fifo 24       16:14   RW                */
#define 	DMA_TX_THR_CTRL32		0x00014000	/* (TTC)Controls thre Threh of MTL tx Fifo 32       16:14   RW                */
#define 	DMA_TX_THR_CTRL40		0x00010000	/* (TTC)Controls thre Threh of MTL tx Fifo 40       16:14   RW                */
#define 	DMA_TX_THR_CTRL256		0x0000c000	/* (TTC)Controls thre Threh of MTL tx Fifo 256      16:14   RW                */
#define 	DMA_TX_THR_CTRL192		0x00008000	/* (TTC)Controls thre Threh of MTL tx Fifo 192      16:14   RW                */
#define 	DMA_TX_THR_CTRL128		0x00004000	/* (TTC)Controls thre Threh of MTL tx Fifo 128      16:14   RW                */
#define 	DMA_TX_THR_CTRL64		0x00000000	/* (TTC)Controls thre Threh of MTL tx Fifo 64       16:14   RW        000     */
#define 	DMA_TX_START			0x00002000	/* (ST)Start/Stop transmission                      13      RW        0       */
#define 	DMA_RX_FLOW_CTRL_DEA	0x00001800	/* (RFD)Rx flow control deact. threhold             12:11   RW                 */
#define 	DMA_RX_FLOW_CTRL_DEA1K	0x00000000	/* (RFD)Rx flow control deact. threhold (1kbytes)   12:11   RW        00       */
#define 	DMA_RX_FLOW_CTRL_DEA2K	0x00000800	/* (RFD)Rx flow control deact. threhold (2kbytes)   12:11   RW                 */
#define 	DMA_RX_FLOW_CTRL_DEA3K	0x00001000	/* (RFD)Rx flow control deact. threhold (3kbytes)   12:11   RW                 */
#define 	DMA_RX_FLOW_CTRL_DEA4K	0x00001800	/* (RFD)Rx flow control deact. threhold (4kbytes)   12:11   RW                 */
#define 	DMA_RX_FLOW_CTRL_ACT	0x00001800	/* (RFA)Rx flow control Act. threhold               12:11   RW                 */
#define 	DMA_RX_FLOW_CTRL_ACT1K	0x00000000	/* (RFA)Rx flow control Act. threhold (1kbytes)     12:11   RW        00       */
#define 	DMA_RX_FLOW_CTRL_ACT2K	0x00000800	/* (RFA)Rx flow control Act. threhold (2kbytes)     12:11   RW                 */
#define 	DMA_RX_FLOW_CTRL_ACT3K	0x00001000	/* (RFA)Rx flow control Act. threhold (3kbytes)     12:11   RW                 */
#define 	DMA_RX_FLOW_CTRL_ACT4K	0x00001800	/* (RFA)Rx flow control Act. threhold (4kbytes)     12:11   RW                 */
#define 	DMA_EN_HW_FLOW_CTRL		0x00010000	/* (EFC)Enable HW flow control                      8       RW                 */
#define 	DMA_DI_HW_FLOW_CTRL		0x00000000	/* Disable HW flow control                                            0        */
#define 	DMA_FWD_ERR_FRAMES		0x00000080	/* (FEF)Forward error frames                        7       RW        0       */
#define 	DMA_FWD_USZ_FRAMES		0x00000040	/* (FUF)Forward undersize frames                    6       RW        0       */
#define 	DMA_TX_SEC_FRAME		0x00000004	/* (OSF)Operate on second frame                     4       RW        0       */
#define 	DMA_RX_START			0x00000002	/* (SR)Start/Stop reception                         1       RW        0       */
#define DMA_INT						(0x001C + DMA_REG_BASE)	/* CSR7 - Interrupt enable                           */
#define DMA_MISSED					(0x0020 + DMA_REG_BASE)	/* CSR8 - Missed Frame & Buffer overflow Counter     */
#define DMA_TX_CUR_DES				(0x0048 + DMA_REG_BASE)	/*      - Current host Tx Desc Register              */
#define DMA_RX_CUR_DES				(0x004C + DMA_REG_BASE)	/*      - Current host Rx Desc Register              */
#define DMA_TX_CUR_ADDR				(0x0050 + DMA_REG_BASE)	/* CSR20 - Current host transmit buffer address      */
#define DMA_RX_CUR_ADDR				(0x0054 + DMA_REG_BASE)	/* CSR21 - Current host receive buffer address       */

/* MAC register */
#define GMAC_CONFIG					(0x0000 + MAC_REG_BASE)	/* Mac config Register                       */
#define		GMAC_WDG				0x00800000
#define		GMAC_WDG_DI				0x00800000	/* (WD)Disable watchdog timer on Rx      23           RW                */
#define		GMAC_WDG_EN				0x00000000	/* Enable watchdog timer                                        0       */
#define		GMAC_JAB				0x00400000
#define		GMAC_JAB_DI				0x00400000	/* (JD)Disable jabber timer on Tx        22           RW                */
#define		GMAC_JAB_EN				0x00000000	/* Enable jabber timer                                          0       */
#define		GMAC_FRAME_BURST		0x00200000
#define		GMAC_FRAME_BURST_EN		0x00200000	/* (BE)Enable frame bursting during Tx   21           RW                */
#define		GMAC_FRAME_BURST_DI		0x00000000	/* Disable frame bursting                                       0       */
#define		GMAC_JUM_FRAME			0x00100000
#define		GMAC_JUM_FRAME_EN		0x00100000	/* (JE)Enable jumbo frame for Tx         20           RW                */
#define		GMAC_JUM_FRAME_DI		0x00000000	/* Disable jumbo frame                                          0       */
#define		GMAC_INTER_FRAME_GAP7	0x000E0000	/* (IFG) Config7 - 40 bit times          19:17        RW                */
#define		GMAC_INTER_FRAME_GAP6	0x000C0000	/* (IFG) Config6 - 48 bit times                                         */
#define		GMAC_INTER_FRAME_GAP5	0x000A0000	/* (IFG) Config5 - 56 bit times                                         */
#define		GMAC_INTER_FRAME_GAP4	0x00080000	/* (IFG) Config4 - 64 bit times                                         */
#define		GMAC_INTER_FRAME_GAP3	0x00060000	/* (IFG) Config3 - 72 bit times                                         */
#define		GMAC_INTER_FRAME_GAP2	0x00040000	/* (IFG) Config2 - 80 bit times                                         */
#define		GMAC_INTER_FRAME_GAP1	0x00020000	/* (IFG) Config1 - 88 bit times                                         */
#define		GMAC_INTER_FRAME_GAP0	0x00000000	/* (IFG) Config0 - 96 bit times                                 000     */
#define		GMAC_MII_GMII			0x00008000
#define		GMAC_SEL_MII			0x00008000	/* (PS)Port Select-MII mode              15           RW                */
#define		GMAC_SEL_GMII			0x00000000	/* GMII mode                                                    0       */
#define		GMAC_FE_SPEED100		0x00004000	/*(FES)Fast Ethernet speed 100Mbps       14           RW                */
#define		GMAC_FE_SPEED10			0x00000000	/* 10Mbps                                                       0       */
#define		GMAC_RX_OWN				0x00002000
#define		GMAC_DI_RX_OWN			0x00002000	/* (DO)Disable receive own packets       13           RW                */
#define		GMAC_EN_RX_OWN			0x00000000	/* Enable receive own packets                                   0       */
#define		GMAC_LP					0x00001000
#define		GMAC_LP_ON				0x00001000	/* (LM)Loopback mode for GMII/MII        12           RW                */
#define		GMAC_LP_OFF				0x00000000	/* Normal mode                                                  0       */
#define		GMAC_DUPLEX				0x00000800
#define		GMAC_FULL_DUPLEX		0x00000800	/* (DM)Full duplex mode                  11           RW                */
#define		GMAC_HALF_DUPLEX		0x00000000	/* Half duplex mode                                             0       */
#define		GMAC_RX_IPC_OFFLOAD		0x00000400	/*IPC checksum offload		      10           RW        0       */
#define		GMAC_RETRY				0x00000200
#define		GMAC_RETRY_DI			0x00000200	/* (DR)Disable Retry                      9           RW                */
#define		GMAC_RETRY_EN			0x00000000	/* Enable retransmission as per BL                              0       */
#define		GMAC_LINK_UP			0x00000100	/* (LUD)Link UP                           8           RW                */
#define		GMAC_LINK_DOWN			0x00000100	/* Link Down                                                    0       */
#define		GMAC_PAD_CRC_STRIP		0x00000080
#define		GMAC_PAD_CRC_STRIP_EN	0x00000080	/* (ACS) Automatic Pad/Crc strip enable   7           RW                */
#define		GMAC_PAD_CRC_STRIP_DI	0x00000000	/* Automatic Pad/Crc stripping disable                          0       */
#define		GMAC_BACKOFF_LIMIT		0x00000060
#define		GMAC_BACKOFF_LIMIT3		0x00000060	/* (BL)Back-off limit in HD mode          6:5         RW                */
#define		GMAC_BACKOFF_LIMIT2		0x00000040	/*                                                                      */
#define		GMAC_BACKOFF_LIMIT1		0x00000020	/*                                                                      */
#define		GMAC_BACKOFF_LIMIT0		0x00000000	/*                                                              00      */
#define		GMAC_DEF_CHECK			0x00000010
#define		GMAC_DEF_CHECK_EN		0x00000010	/* (DC)Deferral check enable in HD mode   4           RW                */
#define		GMAC_DEF_CHECK_DI		0x00000000	/* Deferral check disable                                       0       */
#define		GMAC_TX					0x00000008
#define		GMAC_TX_EN				0x00000008	/* (TE)Transmitter enable                 3           RW                */
#define		GMAC_TX_DI				0x00000000	/* Transmitter disable                                          0       */
#define		GMAC_RX					0x00000004
#define		GMAC_RX_EN				0x00000004	/* (RE)Receiver enable                    2           RW                */
#define		GMAC_RX_DI				0x00000000	/* Receiver disable                                             0       */
#define GMAC_FRAME_FILTER			(0x0004 + MAC_REG_BASE)	/* Mac frame filtering controls              */
#define		GMAC_FILTER				0x80000000
#define		GMAC_FILTER_OFF			0x80000000	/* (RA)Receive all incoming packets       31         RW                 */
#define		GMAC_FILTER_ON			0x00000000	/* Receive filtered packets only                                0       */
#define		GMAC_HASH_PFCT_FILT		0x00000400	/* Hash or Perfect Filter enable           10         RW         0       */
#define		GMAC_SRC_ADDR_FILT		0x00000200
#define		GMAC_SRC_ADDR_FILT_EN	0x00000200	/* (SAF)Source Address Filter enable       9         RW                 */
#define		GMAC_SRC_ADDR_FILT_DI	0x00000000	/*                                                              0       */
#define		GMAC_SRC_IADDR_FILT		0x00000100
#define		GMAC_SRC_IADDR_FILT_EN	0x00000100	/* (SAIF)Inv Src Addr Filter enable        8         RW                 */
#define		GMAC_SRC_IADDR_FILT_DI	0x00000000	/*                                                              0       */
#define		GMAC_PASS_CTRL			0x000000C0
#define		GMAC_PASS_CTRL3			0x000000C0	/* (PCS)Forwards ctrl frms that pass AF    7:6       RW                 */
#define		GMAC_PASS_CTRL2			0x00000080	/* Forwards all control frames                                          */
#define		GMAC_PASS_CTRL1			0x00000040	/* Does not pass control frames                                         */
#define		GMAC_PASS_CTRL0			0x00000000	/* Does not pass control frames                                 00      */
#define		GMAC_BCAST				0x00000020
#define		GMAC_BCAST_DI			0x00000020	/* (DBF)Disable Rx of broadcast frames     5         RW                 */
#define		GMAC_BCAST_EN			0x00000000	/* Enable broadcast frames                                      0       */
#define		GMAC_MCAST				0x00000010
#define		GMAC_MCAST_OFF			0x00000010	/* (PM) Pass all multicast packets         4         RW                 */
#define		GMAC_MCAST_ON			0x00000000	/* Pass filtered multicast packets                              0       */
#define		GMAC_DA_FILT			0x00000008
#define		GMAC_DA_FILT_INV		0x00000008	/* (DAIF)Inverse filtering for DA          3         RW                 */
#define		GMAC_DA_FILT_NORMAL		0x00000000	/* Normal filtering for DA                                      0       */
#define		GMAC_MCAST_HASH_FILT	0x00000004
#define		GMAC_MCAST_HASH_FILT_ON	0x00000004	/* (HMC)perfom multicast hash filtering    2         RW                 */
#define		GMAC_MCAST_HASH_FILT_OFF	0x00000000	/* perfect filtering only                                       0       */
#define		GMAC_UCAST_HASH_FILT	0x00000002
#define		GMAC_UCAST_HASH_FILT_ON	0x00000002	/* (HUC)Unicast Hash filtering only        1         RW                 */
#define		GMAC_UCAST_HASH_FILT_OFF	0x00000000	/* perfect filtering only                                       0       */
#define		GMAC_PRO_MODE			0x00000001
#define		GMAC_PRO_MODE_ON		0x00000001	/* Receive all frames                      0         RW                 */
#define		GMAC_PRO_MODE_OFF		0x00000000	/* Receive filtered packets only                                0       */
#define GMAC_HASH_HI				(0x0008 + MAC_REG_BASE)	/* Multi-cast hash table high                */
#define GMAC_HASH_LO				(0x000C + MAC_REG_BASE)	/* Multi-cast hash table low                 */
#define GMAC_GMII_ADDR				(0x0010 + MAC_REG_BASE)	/* GMII address Register(ext. Phy)           */
#define		GMAC_GMII_DEV_MASK		0x0000F800	/* (PA)GMII device address                 15:11     RW         0x00    */
#define		GMAC_GMII_DEV_SHIFT				11
#define		GMAC_GMII_REG_MASK		0x000007C0	/* (GR)GMII register in selected Phy       10:6      RW         0x00    */
#define		GMAC_GMII_REG_SHIFT				6
#define		GMAC_GMII_CSR_CLK_MASK	0x0000001C	/*CSR Clock bit Mask			 4:2			     */
#define		GMAC_GMII_CSR_CLK5		0x00000014	/* (CR)CSR Clock Range     250-300 MHz      4:2      RW         000     */
#define		GMAC_GMII_CSR_CLK4		0x00000010	/*                         150-250 MHz                                  */
#define		GMAC_GMII_CSR_CLK3		0x0000000C	/*                         35-60 MHz                                    */
#define		GMAC_GMII_CSR_CLK2		0x00000008	/*                         20-35 MHz                                    */
#define		GMAC_GMII_CSR_CLK1		0x00000004	/*                         100-150 MHz                                  */
#define		GMAC_GMII_CSR_CLK0		0x00000000	/*                         60-100 MHz                                   */
#define		GMAC_GMII_WRITE			0x00000002	/* (GW)Write to register                      1      RW                 */
#define		GMAC_GMII_READ			0x00000000	/* Read from register                                            0      */
#define		GMAC_GMII_BUSY			0x00000001	/* (GB)GMII interface is busy                 0      RW          0      */
#define GMAC_GMII_DATA				(0x0014 + MAC_REG_BASE)	/* GMII data Register(ext. Phy)              */
#define		GMAC_GMII_DATA_MASK		0x0000FFFF	/* (GD)GMII Data                             15:0    RW         0x0000  */
#define GMAC_FLOW_CTRL				(0x0018 + MAC_REG_BASE)	/* Flow control Register                     */
#define		GMAC_PAUSE_TIME_MASK	0xFFFF0000	/* (PT) PAUSE TIME field in the control frame  31:16   RW       0x0000  */
#define		GMAC_PAUSE_TIME_SHIFT			16
#define		GMAC_PAUSE_LO_THS		0x00000030
#define		GMAC_PAUSE_LO_THS3		0x00000030	/* (PLT)thresh for pause tmr 256 slot time      5:4    RW               */
#define		GMAC_PAUSE_LO_THS2		0x00000020	/*                           144 slot time                              */
#define		GMAC_PAUSE_LO_THS1		0x00000010	/*                            28 slot time                              */
#define		GMAC_PAUSE_LO_THS0		0x00000000	/*                             4 slot time                       000    */
#define		GMAC_UCAST_PAUSE_FRAME	0x00000008
#define		GMAC_UCAST_PAUSE_FRAME_ON	0x00000008	/* (UP)Detect pause frame with unicast addr.     3    RW                */
#define		GMAC_UCAST_PAUSE_FRAME_OFF	0x00000000	/* Detect only pause frame with multicast addr.                   0     */
#define		GMAC_RX_FLOW_CTRL		0x00000004
#define		GMAC_RX_FLOW_CTRL_EN	0x00000004	/* (RFE)Enable Rx flow control                   2    RW                */
#define		GMAC_RX_FLOW_CTRL_DI	0x00000000	/* Disable Rx flow control                                        0     */
#define		GMAC_TX_FLOW_CTRL		0x00000002
#define		GMAC_TX_FLOW_CTRL_EN	0x00000002	/* (TFE)Enable Tx flow control                   1    RW                */
#define		GMAC_TX_FLOW_CTRL_DI	0x00000000	/* Disable flow control                                           0     */
#define		GMAC_FLOW_CTRL_BACK_PRE	0x00000001
#define		GMAC_SEND_PAUSE_FRAME	0x00000001	/* (FCB/PBA)send pause frm/Apply back pressure   0    RW          0     */
#define GMAC_VLAN					(0x001C + MAC_REG_BASE)	/* VLAN tag Register (IEEE 802.1Q)           */
#define GMAC_VER					(0x0020 + MAC_REG_BASE)	/* GMAC Core Version Register                */
#define GMAC_WAKEUP_ADDR			(0x0028 + MAC_REG_BASE)	/* GMAC wake-up frame filter adrress reg     */
#define GMAC_PMT_CTRL_STAT			(0x002C + MAC_REG_BASE)	/* PMT control and status register           */
#define GMAC_INT_STAT				(0x0038 + MAC_REG_BASE)	/* Mac Interrupt ststus register	       */
#define GMAC_INT_MASK				(0x003C + MAC_REG_BASE)	/* Mac Interrupt Mask register	       */
#define GMAC_ADDR_0_HI				(0x0040 + MAC_REG_BASE)	/* Mac address0 high Register                */
#define GMAC_ADDR_0_LO				(0x0044 + MAC_REG_BASE)	/* Mac address0 low Register                 */

/* PHY register */
#define PHY_CTRL					0x0000		/*Control Register*/
#define		PHY_CTRL_RST				0x8000
#define		PHY_CTRL_LP					0x4000	/* Enable Loop back             14              	RW                      */
#define		PHY_CTRL_SPEED10			0x0000	/* 10   Mbps                    6:13         	RW                      */
#define		PHY_CTRL_SPEED100			0x2000	/* 100  Mbps                    6:13         	RW                      */
#define		PHY_CTRL_SPEED1000			0x0040	/* 1000 Mbit/s                  6:13         	RW                      */
#define		PHY_CTRL_AN_EN				0x1000	/* Enable auto negotiation      11              	RW			*/
#define		PHY_CTRL_PD					0x0800	/* Power down			        11              	RW			*/
#define		PHY_CTRL_RESART_AN			0x0200	/* Restart auto negotiation     9              	RW			*/
#define		PHY_CTRL_DUPLEX				0x0100	/* Full Duplex mode             8               	RW                      */
#define PHY_STAT					0x0001		/*Status Register */
#define		PHY_STAT_SPEED100T4			0x8000
#define		PHY_STAT_SPEED100FDX		0x4000
#define		PHY_STAT_SPEED100HDX		0x2000
#define		PHY_STAT_SPEED10FDX			0x1000
#define		PHY_STAT_SPEED10HDX			0x0800
#define		PHY_STAT_SPEED100T2FDX		0x0400
#define		PHY_STAT_SPEED100T2HDX		0x0200
#define		PHY_STAT_AN_CMPLT			0x0020	/* Autonegotiation completed      5              RW                   */
#define		PHY_STAT_LINK				0x0004	/* Link status                    2              RW                   */
#define PHY_ID_HI					0x0002		/*PHY Identifier High Register*/
#define PHY_ID_LO					0x0003		/*PHY Identifier High Register*/
#define PHY_AN_ADV					0x0004		/*Auto-Negotiation Advertisement Register*/
#define PHY_LNK_PART_ABl			0x0005		/*Link Partner Ability Register (Base Page)*/
#define PHY_AN_EXP					0x0006		/*Auto-Negotiation Expansion Register*/
#define PHY_AN_NXT_PAGE_TX			0x0007		/*Next Page Transmit Register*/
#define PHY_LNK_PART_NXT_PAGE		0x0008		/*Link Partner Next Page Register*/
#define PHY_1000BT_CTRL				0x0009		/*1000BASE-T Control Register*/
#define PHY_1000BT_STAT				0x000a		/*1000BASE-T Status Register*/
#define PHY_SPECIFIC_CTRL			0x0010		/*Phy specific control register*/
#define PHY_SPECIFIC_STAT			0x0011		/*Phy specific status register*/
#define		PHY_DSCSR_100FDX			0x8000
#define		PHY_DSCSR_100HDX			0x4000
#define		PHY_DSCSR_10FDX				0x2000
#define		PHY_DSCSR_10HDX				0x1000
#define PHY_INTERRUPT_ENABLE		0x0012		/*Phy interrupt enable register*/
#define PHY_INTERRUPT_STAT			0x0013		/*Phy interrupt status register*/
#define PHY_EXT_PHY_SPC_CTRL		0x0014		/*Extended Phy specific control*/
#define PHY_RX_ERR_COUNTER			0x0015		/*Receive Error Counter*/
#define PHY_EXT_ADDR_CBL_DIAG		0x0016		/*Extended address for cable diagnostic register*/
#define PHY_LED_CTRL				0x0018		/*LED Control*/
#define PHY_MAN_LED_OVERIDE			0x0019		/*Manual LED override register*/
#define PHY_EXT_PHY_SPC_CTRL2		0x001a		/*Extended Phy specific control 2*/
#define PHY_EXT_PHY_SPC_STAT		0x001b		/*Extended Phy specific status*/
#define PHY_CBL_DIAG				0x001c		/*Cable diagnostic registers*/
#define PHY_SPECIAL					0x001F
#define 	PHY_SPECIAL_SPD				0x001C
#define 	PHY_SPECIAL_SPD_10HALF		0x0004
#define 	PHY_SPECIAL_SPD_10FULL		0x0014
#define 	PHY_SPECIAL_SPD_100HALF		0x0008
#define 	PHY_SPECIAL_SPD_100FULL		0x0018

#define DMA_DESC_STATUS				0x0
#define		DESC_OWN					0x80000000	/* (OWN)Descriptor is owned by DMA engine            31      RW                  */
#define		DESC_DA_FILT_FAIL			0x40000000	/* (AFM)Rx - DA Filter Fail for the rx frame         30                          */
#define		DESC_FRAME_LEN_MASK			0x3FFF0000	/* (FL)Receive descriptor frame length               29:16                       */
#define		DESC_FRAME_LEN_SHIFT		16
#define		DESC_ERROR					0x00008000	/* (ES)Error summary bit  - OR of the follo. bits:   15                          */
#define		DESC_RX_TRUNC				0x00004000	/* (DE)Rx - no more descriptors for receive frame    14                          */
#define		DESC_SA_FILT_FAIL			0x00002000	/* (SAF)Rx - SA Filter Fail for the received frame   13                          */
#define		DESC_RX_LEN_ERR				0x00001000	/* (LE)Rx - frm size not matching with len field     12                          */
#define		DESC_RX_DAMAGED				0x00000800	/* (OE)Rx - frm was damaged due to buffer overflow   11                          */
#define		DESC_RX_VLAN				0x00000400	/* (VLAN)Rx - received frame is a VLAN frame         10                          */
#define		DESC_RX_FIRST				0x00000200	/* (FS)Rx - first descriptor of the frame             9                          */
#define		DESC_RX_LAST				0x00000100	/* (LS)Rx - last descriptor of the frame              8                          */
#define		DESC_RX_IPV4_CHK_ERR		0x00000080	/* (IPC CS ERROR)Rx - Ipv4 header checksum error      7                          */
#define		DESC_RX_LONG_FRAME			0x00000080	/* (Giant Frame)Rx - frame is longer than 1518/1522   7                          */
#define		DESC_RX_COLLISION			0x00000040	/* (LC)Rx - late collision occurred during reception  6                          */
#define		DESC_RX_FRAME_ETH			0x00000020	/* (FT)Rx - Frame type - Ethernet, otherwise 802.3    5                          */
#define		DESC_RX_WTD					0x00000010	/* (RWT)Rx - watchdog timer expired during reception  4                          */
#define		DESC_RX_MII_ERR				0x00000008	/* (RE)Rx - error reported by MII interface           3                          */
#define		DESC_RX_DRIB				0x00000004	/* (DE)Rx - frame contains non int multiple of 8 bits 2                          */
#define		DESC_RX_CRC					0x00000002	/* (CE)Rx - CRC error                                 1                          */
#define		DESC_RX_PAY_CHK_ERR			0x00000001	/* ()  Rx - Rx Payload Checksum Error                 0                          */
#define		DESC_RX_MAC_MATCH			0x00000001	/* (RX MAC Address) Rx mac address reg(1 to 15)match  0                          */

#define		DESC_TX_INT_EN				0x80000000	/* (IC)Tx - interrupt on completion                    31                       */
#define		DESC_TX_LAST				0x40000000	/* (LS)Tx - Last segment of the frame                  30                       */
#define		DESC_TX_FIRST				0x20000000	/* (FS)Tx - First segment of the frame                 29                       */
#define		DESC_TX_DI_CRC				0x08000000	/* (DC)Tx - Add CRC disabled (first segment only)      26                       */
#define		DESC_TX_DI_PAD				0x04000000	/* (DP)disable padding                23                       */
#define		DESC_TX_EN_TSE				0x02000000	/* (DP)enable time stamp               23                       */
#define		DESC_TX_CIS_MASK			0x00C00000	/* Tx checksum offloading control mask			28:27			*/
#define		DESC_TX_CIS_BYPASS			0x00000000	/* Checksum bypass								*/
#define		DESC_TX_CIS_IPV4_HDCHK		0x00400000	/* IPv4 header checksum								*/
#define		DESC_TX_CIS_TCP_ONLYCHK		0x00800000	/* TCP/UDP/ICMP checksum. Pseudo header checksum is assumed to be present	*/
#define		DESC_TX_CIS_TCP_FULLCHK		0x00C00000	/* TCP/UDP/ICMP checksum fully in hardware including pseudo header		*/
#define		DESC_TX_END_OF_RING			0x02000000	/* (TER)End of descriptors ring                                                 */
#define		DESC_TX_CHAIN				0x00100000	/* (TCH)Second buffer address is chain address         24                       */
#define		DESC_TX_TSE					0x00020000	/* (DP)enable time stamp               23                       */
#define		DESC_TX_IPV4_CHK_ERR		0x00010000	/* (IHE) Tx Ip header error                           16                         */
#define		DESC_TX_ES					0x00008000	/* (JT)Tx - Transmit error summary                    14                         */
#define		DESC_TX_TMO					0x00004000	/* (JT)Tx - Transmit jabber timeout                   14                         */
#define		DESC_TX_FRAME_FLUSH			0x00002000	/* (FF)Tx - DMA/MTL flushed the frame due to SW flush 13                         */
#define		DESC_TX_PAY_CHK_ERR			0x00001000	/* (PCE) Tx Payload checksum Error                    12                         */
#define		DESC_TX_LOST_CARR			0x00000800	/* (LC)Tx - carrier lost during tramsmission          11                         */
#define		DESC_TX_NO_CARR				0x00000400	/* (NC)Tx - no carrier signal from the tranceiver     10                         */
#define		DESC_TX_LATE_COLLISION		0x00000200	/* (LC)Tx - transmission aborted due to collision      9                         */
#define		DESC_TX_EXC_COLLISION		0x00000100	/* (EC)Tx - transmission aborted after 16 collisions   8                         */
#define		DESC_TX_VLAN				0x00000080	/* (VF)Tx - VLAN-type frame                            7                         */
#define		DESC_TX_COLL_MASK			0x00000078	/* (CC)Tx - Collision count                           6:3                        */
#define		DESC_TX_COLL_SHIFT			3
#define		DESC_TX_EXC_DEFER			0x00000004	/* (ED)Tx - excessive deferral                          2                        */
#define		DESC_TX_UNDERFLOW			0x00000002	/* (UF)Tx - late data arrival from the memory           1                        */
#define		DESC_TX_DEFER				0x00000001	/* (DB)Tx - frame transmision deferred                  0                        */
#define DMA_DESC_LENGTH				0x4
#define		DESC_RX_INT_EN				0x80000000	/* (IC)Rx - interrupt on completion                    31                       */
#define		DESC_SIZE1_MASK				0x01FFF000	/* (TBS2) Buffer 2 size                                21:11                    */
#define		DESC_SIZE1_SHIFT			16
#define		DESC_RX_END_OF_RING			0x02000000	/* (TER)End of descriptors ring                                                 */
#define		DESC_RX_CHAIN				0x00004000	/* (TCH)Second buffer address is chain address         24                       */
#define		DESC_SIZE0_MASK				0x000007FF	/* (TBS1) Buffer 1 size                                10:0                     */
#define		DESC_SIZE0_SHIFT			0
#define DMA_DESC_ADDRESS0			0x8
#define DMA_DESC_ADDRESS1			0xC


/* Network speed (for net_device.speed) */
#define NET_LINK_DOWN				0x00			/* Link is off */
#define NET_HALF_DUPLEX				0x00			/* Half duplex */
#define NET_FULL_DUPLEX				0x01			/* Full duplex */
#define NET_SPEED_10				0x10			/* Link is 10M */
#define NET_SPEED_100				0x20			/* Link is 100M */
#define NET_SPEED_1000				0x40			/* Link is 1000M */
#define NET_SPEED_10000				0x80			/* Link is 10000M */

