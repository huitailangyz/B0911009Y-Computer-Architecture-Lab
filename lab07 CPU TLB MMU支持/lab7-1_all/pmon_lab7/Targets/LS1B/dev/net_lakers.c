/*
 * net_lakers.c
 * This is a driver for Huaya Micor's Ethernet devices (GMAC).
 *
 * Copyright 2010 Huaya Micro
 *	   Derived from the synopsis GMAC driver by Justin Wu
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Arguments:
 *	 net_watchdog  = TX net_watchdog timeout
 *
 * History:
 *	  02/25/2010	Justin Wu		 Initial version
 */

#include "linux_net_head.h"
#include "net_lakers.h"


#define RX_DESC_NUM			16				/* RX DMA descriptor number */
#define TX_DESC_NUM			16				/* TX DMA descriptor number */
#define PACKET_BUF_SZ		1536			/* Size of each temporary Rx buffer.*/

#define DMA_NRX_INT			(DMA_INT_NORMAL | DMA_INT_ABNORMAL | DMA_INT_BUS_ERR \
						   | DMA_INT_TX_COMPLETED | DMA_INT_TX_UNDERFLOW \
						   | DMA_INT_TX_STOPPED)
#define DMA_RX_INT			(DMA_INT_RX_COMPLETED | DMA_INT_RX_OVERFLOW | DMA_INT_RX_NO_BUF \
						   | DMA_INT_RX_STOPPED)
#define DMA_ALL_INT			(DMA_NRX_INT | DMA_RX_INT)

#define DRIVER_NAME			"net_lakers"
char version[] = "net_lakers.c: v1.0 02-25-2010 by Justin Wu <justin_mail@21cn.com>\n";

static unsigned int net_watchdog = (5 * HZ);
static unsigned int net_mclock = 0;
static char mac_addr[MAX_ADDR_LEN] = {0x00, 0xd0, 0xaa, 0xbb, 0xcc, 0xdd};


#define PRINTK(args...)		printf(args)

#define TX_DESC_FREEED(priv)									\
	(((priv)->tx_pend <= (priv)->tx_curr) ?						\
	  (priv)->tx_pend + (TX_DESC_NUM - 1) - (priv)->tx_curr :	\
	  (priv)->tx_pend - (priv)->tx_curr - 1)

#define mac_read32(reg_base, index)			*((volatile uint32_t *)((reg_base) + (index)))
#if defined CONFIG_MACH_HUAYA_LAKERS
#define mac_write32(reg_base, index, data)								\
	mac_read32(ndev->base_addr, DMA_BUS_MODE);	/* Patch for IC bug */	\
	HAL_PUT_UINT32((UINT32 *)((reg_base) + (index)), (data));	\
	mac_read32(ndev->base_addr, DMA_BUS_MODE)	/* Patch for IC bug */
#else
#define mac_write32(reg_base, index, data)	*(volatile uint32_t *)((reg_base) + (index))= (data)
#endif

struct dma_descriptor {
	unsigned int			status;			/* Status 									*/
	unsigned int			length;			/* Buffer 0 and Buffer 1 length 						*/
	unsigned int			address0;		/* Network Buffer 0 pointer (Dma-able) 							*/
	unsigned int			address1;		/* Network Buffer 1 pointer or next descriptor pointer (Dma-able)in chain structure 	*/
	unsigned int			dummy[4];		/* It's MUST, else cause coherent issue when descriptor access */
};

struct lakers_priv {
	struct net_device 		*ndev;
	struct device 			*dev;
	spinlock_t				lock;
	struct timer_list		timer;
	struct mii_if_info		mii;
	unsigned int			msg_enable;

	unsigned int			mclock;			/* Module working clock in Hz */
	unsigned int			speed;

	unsigned short			rx_curr;		/* The index of avaliable RX descriptor for CPU */
	unsigned short			tx_curr;		/* The index of avaliable TX descriptor for CPU */
	unsigned short			tx_pend;		/* The index of pending TX descriptor for CPU */
	dma_addr_t				pdesc_addr;
	unsigned char			*vdesc_addr;
	struct dma_descriptor	*rx_pdesc;		/* RX descriptors in physical address */
	struct dma_descriptor	*tx_pdesc;		/* TX descriptors in physical address */
	struct dma_descriptor	*rx_vdesc;		/* RX descriptors in virtual address */
	struct dma_descriptor	*tx_vdesc;		/* TX descriptors in virtual address */
};


static unsigned int mac_init(struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned int data, data1;

	/* Setup GMAC core working mode */
	data =//GMAC_WDG |					/* Enable watchdog */
			GMAC_JAB |					/* Enable jab */
			GMAC_FRAME_BURST |			/* Enable frame burst */
//			GMAC_JUM_FRAME |			/* Disable jumbo frame */
//			GMAC_RX_OWN |				/* Enable RX own */
//			GMAC_LP |					/* Loopback off */
			GMAC_RX_IPC_OFFLOAD |		/* Enable RX checksum offload */
//			GMAC_RETRY |				/* Enable retry */
//			GMAC_PAD_CRC_STRIP |		/* Disable PAD CRC strip */
			GMAC_BACKOFF_LIMIT0 |		/* Set back off limit */
//			GMAC_DEF_CHECK |			/* Disable deferral check */
			GMAC_TX |					/* Enable TX */
			GMAC_RX |					/* Enable RX */
			0;
	/* Set to 100/10 mode */
	if ((priv->speed & NET_SPEED_100) != 0) {
		data |= (GMAC_MII_GMII | GMAC_FE_SPEED100);
	} if ((priv->speed & NET_SPEED_10) != 0) {
		data |= GMAC_MII_GMII;
	}
	/* Set duplex mode */
	if (priv->speed & NET_FULL_DUPLEX) {
		data |= GMAC_DUPLEX;
	}
	mac_write32(ndev->base_addr, GMAC_CONFIG, data);

	/* Setup GMAC core filter mode */
	data = GMAC_FILTER |				/* Frame Filter Configuration*/
			GMAC_HASH_PFCT_FILT |		/* Pass both perfect and hash filter */
//			GMAC_SRC_ADDR_FILT |		/* Disable source address filter */
//			GMAC_SRC_IADDR_FILT |		/* Disable inverted source address filter */
			GMAC_PASS_CTRL0 |			/* Set pass control */
//			GMAC_BCAST |				/* Enable broadcast */
//			GMAC_MCAST |				/* Disable multicast all */
//			GMAC_DA_FILT |				/* Set dest address filter normal mode */
//			GMAC_MCAST_HASH_FILT |		/* Disable multicast hash filter */
//			GMAC_UCAST_HASH_FILT |		/* Disable unicast hash filter */
			GMAC_PRO_MODE |				/* Disable promisc */
			0;
	data1 = mac_read32(ndev->base_addr, GMAC_FRAME_FILTER);
	mac_write32(ndev->base_addr, GMAC_FRAME_FILTER, data | data1);

	/* Setup flow control mode */
	data =  GMAC_PAUSE_LO_THS0 |
//			GMAC_UCAST_PAUSE_FRAME  |	/* Disable unicast pause frame detect */
//			GMAC_FLOW_CTRL_BACK_PRE |
			0;
	if (priv->speed & NET_FULL_DUPLEX) {
		/* Enable TX/RX flow control */
		mac_write32(ndev->base_addr, GMAC_FLOW_CTRL, data | GMAC_RX_FLOW_CTRL | GMAC_TX_FLOW_CTRL);
	} else {
		/* Disable TX/RX flow control */
		mac_write32(ndev->base_addr, GMAC_FLOW_CTRL, data & ~(GMAC_RX_FLOW_CTRL | GMAC_TX_FLOW_CTRL));
	}
	return SUCCESS;
}

static int phy_read16(struct net_device *ndev, int phy_addr, int index)
{
	unsigned int reg_base = ndev->base_addr;
	unsigned int addr;
	int i;

	addr = mac_read32(reg_base, GMAC_GMII_ADDR) & GMAC_GMII_CSR_CLK_MASK;
	addr |= ((phy_addr << GMAC_GMII_DEV_SHIFT) & GMAC_GMII_DEV_MASK) | ((index << GMAC_GMII_REG_SHIFT) & GMAC_GMII_REG_MASK) | GMAC_GMII_BUSY;
	mac_write32(reg_base, GMAC_GMII_ADDR, addr);

	/* Wait until not busy */
	for (i = 0; i < 5; i++) {
		if ((mac_read32(reg_base, GMAC_GMII_ADDR) & GMAC_GMII_BUSY) == 0)
			break;
		mdelay(5);
	}
	if (i >= 5) {
        PRINTK("phy_read16: PHY not responding busy bit did not get cleared !\n");
		return 0xFFFF;
	}

	return mac_read32(reg_base, GMAC_GMII_DATA) & GMAC_GMII_DATA_MASK;
}

static void phy_write16(struct net_device *ndev, int phy_addr, int index, int data)
{
	unsigned int reg_base = ndev->base_addr;
	unsigned int addr;
	int i;

	mac_write32(reg_base, GMAC_GMII_DATA, data);

	addr = mac_read32(reg_base, GMAC_GMII_ADDR) & GMAC_GMII_CSR_CLK_MASK;
	addr |= ((phy_addr << GMAC_GMII_DEV_SHIFT) & GMAC_GMII_DEV_MASK) | ((index << GMAC_GMII_REG_SHIFT) & GMAC_GMII_REG_MASK) | GMAC_GMII_BUSY | GMAC_GMII_WRITE;
	mac_write32(reg_base, GMAC_GMII_ADDR, addr);

	/* Wait until not busy */
	for (i = 0; i < 5; i++) {
		if ((mac_read32(reg_base, GMAC_GMII_ADDR) & GMAC_GMII_BUSY) == 0)
			break;
		mdelay(1);
	}
	if (i >= 5) {
        PRINTK("phy_write16: PHY not responding busy bit did not get cleared !\n");
	}
}

static void phy_detect(struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned int phy_id;
	int i;

	/* Detect PHY by read PHY ID register and shouldn't be all 1 */
	for (i = 0; i < 0x20; i++) {
		phy_id = ((unsigned int)phy_read16(ndev, i, PHY_ID_HI) << 16) | phy_read16(ndev, i, PHY_ID_LO);
		if (phy_id != 0xFFFFFFFF && phy_id != 0x00000000) {
			PRINTK("phy_detect: PHY address is 0x%02x\n", i);
			priv->mii.phy_id = i;
			break;
		}
	}
	if (i == 32) {
		PRINTK("phy_detect: can't find PHY!\n");
	}
}

static unsigned int phy_init(struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned int oui;
	unsigned short status, data[2];

	/* Check link up or not */
	status = phy_read16(ndev, priv->mii.phy_id, PHY_STAT);
	if ((status & PHY_STAT_LINK) == 0) {
		priv->speed = NET_LINK_DOWN;
		return ERR_FAILURE;
	}
	/* Update duplex/speed status */
	oui = (phy_read16(ndev, priv->mii.phy_id, PHY_ID_HI) << 6) |
		  (phy_read16(ndev, priv->mii.phy_id, PHY_ID_LO) >> 10);
	data[0] = phy_read16(ndev, priv->mii.phy_id, PHY_AN_ADV);
	data[1] = phy_read16(ndev, priv->mii.phy_id, PHY_LNK_PART_ABl);
	status = ((data[0] & data[1]) >> 5) & 0xF;
	if (status & 8) {
		priv->speed = NET_FULL_DUPLEX;
		priv->speed |= NET_SPEED_100;
	} else if (status & 4) {
		priv->speed = NET_HALF_DUPLEX;
		priv->speed |= NET_SPEED_100;
	} else if (status & 2) {
		priv->speed = NET_FULL_DUPLEX;
		priv->speed |= NET_SPEED_10;
	} else if (status & 1) {
		priv->speed = NET_HALF_DUPLEX;
		priv->speed |= NET_SPEED_10;
	} else {
		priv->speed = NET_LINK_DOWN;
	}

	return SUCCESS;
}

static void net_lakers_descs_alloc(struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	int i;

	/* Initial TX buffer link */
	for (i = 0; i < TX_DESC_NUM; i++) {
		priv->tx_vdesc[i].status = 0;
		priv->tx_vdesc[i].length = 0;
		priv->tx_vdesc[i].address0 = 0;
		priv->tx_vdesc[i].address1 = 0;
	}
	priv->tx_vdesc[TX_DESC_NUM - 1].length |= DESC_TX_END_OF_RING;
	priv->tx_curr = priv->tx_pend = 0;

	/* Allocate RX buffer link */
	for (i = 0; i < RX_DESC_NUM; i++) {
		struct sk_buff *skb;
		dma_addr_t mapping;

		priv->rx_vdesc[i].status = DESC_OWN;
		/* Allocate default continue buffer for each descriptor */
		skb = netdev_alloc_skb(ndev, PACKET_BUF_SZ + NET_IP_ALIGN);
		if (skb != NULL) {
			skb_reserve(skb, NET_IP_ALIGN);
			mapping = dma_map_single(priv->dev, skb->data, PACKET_BUF_SZ, DMA_FROM_DEVICE);
			priv->rx_vdesc[i].length = ((PACKET_BUF_SZ << DESC_SIZE0_SHIFT) & DESC_SIZE0_MASK);
			priv->rx_vdesc[i].address0 = mapping;
			priv->rx_vdesc[i].address1 = (unsigned int)skb;
		} else {
			priv->rx_vdesc[i].length = 0;
			priv->rx_vdesc[i].address0 = 0;
			priv->rx_vdesc[i].address1 = 0;
		}
	}
	priv->rx_vdesc[RX_DESC_NUM - 1].length |= DESC_RX_END_OF_RING;
	priv->rx_curr = 0;
}

static void net_lakers_descs_free(struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	struct dma_descriptor *cur_desc;
	struct sk_buff *skb;
	int i;

	/* Free TX buffer link */
	for (i = 0; i < TX_DESC_NUM; i++) {
		cur_desc = &priv->tx_vdesc[i];
		skb = (struct sk_buff *)(cur_desc->address1);
		if (skb != NULL) {
			dma_unmap_single(priv->dev, cur_desc->address0,
					 (cur_desc->length & DESC_SIZE0_MASK) >> DESC_SIZE0_SHIFT,
					 DMA_TO_DEVICE);
			dev_kfree_skb(skb);
			cur_desc->address1 = 0;
			priv->ndev->stats.tx_dropped++;
		}
	}

	/* Allocate RX buffer link */
	for (i = 0; i < RX_DESC_NUM; i++) {
		cur_desc = &priv->rx_vdesc[i];
		skb = (struct sk_buff *)(cur_desc->address1);
		if (skb != NULL) {
			dma_unmap_single(priv->dev, cur_desc->address0,
					 (cur_desc->length & DESC_SIZE0_MASK) >> DESC_SIZE0_SHIFT,
					 DMA_FROM_DEVICE);
			dev_kfree_skb(skb);
		}
	}

	memset(priv->tx_vdesc, 0, sizeof(struct dma_descriptor) * TX_DESC_NUM);
	memset(priv->rx_vdesc, 0, sizeof(struct dma_descriptor) * RX_DESC_NUM);
}

static void net_lakers_rx_err_proc(struct net_device *ndev, u32 status, u32 len)
{
	ndev->stats.rx_errors++;
	if (status & (DESC_RX_IPV4_CHK_ERR | DESC_RX_COLLISION)) {
		ndev->stats.rx_frame_errors++;
	}
	if (status & DESC_RX_CRC) {
		ndev->stats.rx_crc_errors++;
	}
	if (status & (DESC_RX_LEN_ERR | DESC_RX_TRUNC | DESC_RX_LONG_FRAME | DESC_RX_DRIB)) {
		ndev->stats.rx_length_errors++;
	}
	if ((status & (DESC_RX_FIRST | DESC_RX_LAST)) != (DESC_RX_FIRST | DESC_RX_LAST)) {
		ndev->stats.rx_length_errors++;
	}
	if (status & DESC_RX_DAMAGED) {
		ndev->stats.rx_fifo_errors++;
	}
}

static int net_lakers_rx_poll(struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned short rx_head = priv->rx_curr;
	int rx;

	rx = 0;
	/* Clear RX interrupts */
	mac_write32(ndev->base_addr, DMA_STA, DMA_RX_INT);

	/* If some RX descriptor be filled, recieve those data. */
	while (1) {
		struct dma_descriptor *cur_desc;
		struct sk_buff *skb, *new_skb;
		dma_addr_t mapping;
		unsigned int len;

		cur_desc = &(priv->rx_vdesc[rx_head]);
		if ((cur_desc->status & DESC_OWN) != 0) {
			break;
		}
		skb = (struct sk_buff *)cur_desc->address1;
		len = (cur_desc->status & DESC_FRAME_LEN_MASK) >> DESC_FRAME_LEN_SHIFT;
		mapping = cur_desc->address0;
		if ((cur_desc->status & (DESC_RX_FIRST | DESC_RX_LAST)) != (DESC_RX_FIRST | DESC_RX_LAST)) {
			/* Don't support incoming fragmented frames, and we attempt to ensure that the
			 * pre-allocated RX skbs are properly sized such that RX fragments are never
			 * encountered
			 */
			ndev->stats.rx_dropped++;
			net_lakers_rx_err_proc(ndev, cur_desc->status, len);
			PRINTK("net_lakers_rx_poll: Package error\n");
			goto next;
		}
		if (cur_desc->status & DESC_ERROR) {
			net_lakers_rx_err_proc(ndev, cur_desc->status, len);
			PRINTK("net_lakers_rx_poll: RX error\n");
			goto next;
		}
		/* Alloce new skb */
		new_skb = netdev_alloc_skb(ndev, PACKET_BUF_SZ + NET_IP_ALIGN);
		if (!new_skb) {
			PRINTK("net_lakers_rx_poll: SKB fail\n");
			ndev->stats.rx_dropped++;
			goto next;
		}

		skb_reserve(new_skb, NET_IP_ALIGN); /* Receive package */
		dma_unmap_single(priv->dev, mapping, PACKET_BUF_SZ, DMA_FROM_DEVICE);
#if 0
		if ((cur_desc->status & DESC_RX_PAY_CHK_ERR) == 0) {
			skb->ip_summed = CHECKSUM_UNNECESSARY;
		} else {
			skb->ip_summed = CHECKSUM_NONE;
		}
#endif
		skb_put(skb, len);

		mapping = dma_map_single(priv->dev, new_skb->data, PACKET_BUF_SZ, DMA_FROM_DEVICE);
		cur_desc->address1 = (unsigned int)new_skb;

		//skb->protocol = eth_type_trans(skb, ndev);
		ndev->stats.rx_packets++;
		ndev->stats.rx_bytes += skb->len;
		ndev->last_rx = jiffies;
		netif_receive_skb(skb);

		rx++;
next:
		cur_desc->address0 = mapping;
		cur_desc->length = ((PACKET_BUF_SZ << DESC_SIZE0_SHIFT) & DESC_SIZE0_MASK);
		cur_desc->length |= (rx_head == RX_DESC_NUM - 1) ? DESC_RX_END_OF_RING : 0;
		cur_desc->status = DESC_OWN;

		/* Next TX descriptor */
		rx_head = ((rx_head + 1) & (RX_DESC_NUM - 1));

			//break;
	}
	priv->rx_curr = rx_head;


	return rx;
}

static int net_lakers_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	struct dma_descriptor *cur_desc;
	unsigned short tx_head;
	unsigned long flags;
	dma_addr_t mapping;

	spin_lock_irqsave(&priv->lock, flags);

	/* Check & get free descriptor number */
	if (TX_DESC_FREEED(priv) < /*(skb_shinfo(skb)->nr_frags + 1)*/1) {
		netif_stop_queue(ndev);
		spin_unlock_irqrestore(&priv->lock, flags);
		PRINTK("net_lakers_hard_start_xmit: no room\n");
		return 1;
	}
	/* Generate TX descriptor */
	tx_head = priv->tx_curr;
//	if (skb_shinfo(skb)->nr_frags == 0) 
	{
		//cache_sync();
		mapping = dma_map_single(priv->dev, skb->data, skb->len, DMA_TO_DEVICE);
		cur_desc = &(priv->tx_vdesc[tx_head]);
		cur_desc->length |= ((skb->len << DESC_SIZE0_SHIFT) & DESC_SIZE0_MASK);
		cur_desc->length |= DESC_TX_FIRST | DESC_TX_LAST | DESC_TX_INT_EN;
		cur_desc->address0 = mapping;
		cur_desc->address1 = (unsigned int)skb;
		cur_desc->status = DESC_OWN;

		///| DESC_OWN | DESC_TX_FIRST | DESC_TX_LAST | DESC_TX_INT_EN;
#if defined CONFIG_MACH_HUAYA_LAKERS
		mac_read32(ndev->base_addr, DMA_BUS_MODE);	/* Patch for IC bug */
#endif
		tx_head = ((tx_head + 1) & (TX_DESC_NUM - 1));
	} 
	priv->tx_curr = tx_head;

	/* Force kick off start transmission */
	mac_write32(ndev->base_addr, DMA_TX_POLL, 1);
	ndev->trans_start = jiffies;
	spin_unlock_irqrestore(&priv->lock, flags);

	return 0;
}

static void net_lakers_tx_done(struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	struct dma_descriptor *cur_desc;
	unsigned short tx_tail = priv->tx_pend, tx_head = priv->tx_curr;
	struct sk_buff *skb;

	/* Collect the TX status */
	while (tx_tail != tx_head) {
		cur_desc = &(priv->tx_vdesc[tx_tail]);
		if (cur_desc->status & DESC_OWN) {
			break;
		}

		dma_unmap_single(priv->dev, cur_desc->address0,
				 (cur_desc->length & DESC_SIZE0_MASK) >> DESC_SIZE0_SHIFT,
				 DMA_TO_DEVICE);
		if (cur_desc->status & DESC_TX_LAST) {
			skb = (struct sk_buff *)cur_desc->address1;
			if (cur_desc->status & (DESC_TX_ES | DESC_TX_IPV4_CHK_ERR)) {
				ndev->stats.tx_errors++;
				if (cur_desc->status & DESC_TX_LATE_COLLISION)
					ndev->stats.tx_window_errors++;
				if (cur_desc->status & (DESC_TX_EXC_COLLISION))
					ndev->stats.tx_aborted_errors++;
				if (cur_desc->status & (DESC_TX_NO_CARR | DESC_TX_LOST_CARR))
					ndev->stats.tx_carrier_errors++;
				if (cur_desc->status & DESC_TX_UNDERFLOW)
					ndev->stats.tx_fifo_errors++;
			} else {
				ndev->stats.collisions += ((cur_desc->status & DESC_TX_COLL_MASK) >> DESC_TX_COLL_SHIFT);
				ndev->stats.tx_packets++;
				ndev->stats.tx_bytes += skb->len;
			}
			dev_kfree_skb_irq(skb);
			cur_desc->address1 = 0;
		}

		tx_tail = ((tx_tail + 1) & (TX_DESC_NUM - 1));
	}
	priv->tx_pend = tx_tail;

	if (TX_DESC_FREEED(priv) > (MAX_SKB_FRAGS + 1)) {
		netif_wake_queue(ndev);
	}
}

static irqreturn_t net_lakers_interrupt(int irq, void *dev_id)
{
	struct net_device *ndev = dev_id;
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned int istatus;

	//spin_lock(&priv->lock);

	/* Check MAC interrupts */
	istatus = mac_read32(ndev->base_addr, DMA_STA);

	/* Check power managment interrupt. */
	/* Check mac management counter interrupt */
	/* Check line interface interrupt */

	if (istatus & DMA_INT_RX_OVERFLOW) {
		PRINTK("net_lakers_interrupt: DMA_INT_RX_OVERFLOW\n");
	}

	/* Check DMA error interrupts: bus error */
	if (istatus & DMA_INT_BUS_ERR) {
		PRINTK("net_lakers_interrupt: DMA_INT_BUS_ERR\n");
	}
	/* Check DMA RX interrupts: RX interrupt */
	if (istatus & (DMA_INT_RX_COMPLETED | DMA_INT_RX_NO_BUF | DMA_INT_RX_STOPPED)) {
		net_lakers_rx_poll(ndev);
	}
	/* Check DMA TX interrupts: TX interrupt & TX underflow */
	if ((istatus & DMA_INT_TX_COMPLETED) || (istatus & DMA_INT_TX_UNDERFLOW)) {
		net_lakers_tx_done(ndev);
	}
	/* Check DMA TX stopped interrupts: TX stopped */
	if (istatus & DMA_INT_TX_STOPPED) {
		PRINTK("net_lakers_interrupt: DMA_INT_TX_STOPPED\n");
	}

	/* Clear interrupt (but RX for it clear in NAPI) */
	mac_write32(ndev->base_addr, DMA_STA, istatus & ~DMA_RX_INT);

	//spin_unlock(&priv->lock);
	//printf("------------dma status = %x-------------\n",istatus);

	return IRQ_HANDLED;
}

/* Our net_watchdog timed out. Called by the networking layer */
static void net_lakers_tx_timeout(struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned long flags;
	unsigned int data;

	spin_lock_irqsave(&priv->lock, flags);

	/* Disable DMA RX/TX */
	data = mac_read32(ndev->base_addr, DMA_CTR);
	mac_write32(ndev->base_addr, DMA_CTR, data & ~(DMA_RX_START | DMA_TX_START));

	/* Disable interrupt */
	mac_write32(ndev->base_addr, DMA_INT, 0);

	net_lakers_descs_free(ndev);

	net_lakers_descs_alloc(ndev);

	/* Clear interrupt */
	data = mac_read32(ndev->base_addr, DMA_STA);
	mac_write32(ndev->base_addr, DMA_STA, data);
	/* Enable interrupt */
	mac_write32(ndev->base_addr, DMA_INT, DMA_ALL_INT);
	/* Enable DMA RX/TX */
	data = mac_read32(ndev->base_addr, DMA_CTR);
	mac_write32(ndev->base_addr, DMA_CTR, data | DMA_RX_START | DMA_TX_START);

	netif_wake_queue(ndev);

	spin_unlock_irqrestore(&priv->lock, flags);
}

static int net_lakers_set_mac_address(struct net_device *ndev, void *addr)
{
	struct sockaddr *mac_s = addr;
	unsigned char *mac = ndev->dev_addr;

	/* Just record address, and set it when open */
	memcpy(ndev->dev_addr, mac_s->sa_data, ndev->addr_len);

	/* Set MAC address */
	mac_write32(ndev->base_addr, GMAC_ADDR_0_LO, mac[0] | (mac[1] << 8) | (mac[2] << 16) | (mac[3] << 24));
	mac_write32(ndev->base_addr, GMAC_ADDR_0_HI, mac[4] | (mac[5] << 8) | (mac[6] << 16) | (mac[7] << 24));

	return 0;
}
#if 0
static void net_lakers_set_multicast_list(struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned int data, hashh = 0, hashl = 0, update_multicast = 0;
	unsigned long flags;

	spin_lock_irqsave(&priv->lock, flags);
	data = mac_read32(ndev->base_addr, GMAC_FRAME_FILTER);
	spin_unlock_irqrestore(&priv->lock, flags);

	if (ndev->flags & IFF_PROMISC) {
		data &= ~(GMAC_DA_FILT);
		data |= GMAC_PRO_MODE;
	} else if (ndev->flags & IFF_ALLMULTI || ndev->mc_count > 16) {
		data &= ~(GMAC_DA_FILT | GMAC_PRO_MODE);
		data |= GMAC_MCAST;
	} else if (ndev->mc_count)  {
		struct dev_mc_list *cur_list;
		unsigned int mask, bitnum;
		int i;

		data &= ~(GMAC_DA_FILT | GMAC_PRO_MODE | GMAC_MCAST);
		data |= GMAC_MCAST_HASH_FILT;

		cur_list = ndev->mc_list;
		for (i = 0; i < ndev->mc_count; i++, cur_list = cur_list->next) {
			if (!cur_list)
				break;

			/* make sure this is a multicast address -
				shouldn't this be a given if we have it here ? */
			if (!(*cur_list->dmi_addr & 1))
				 continue;

			/* upper 6 bits are used as hash index */
			bitnum = ether_crc(ETH_ALEN, cur_list->dmi_addr) >> 26;
			mask = 0x01UL;
			mask <<= (bitnum & 0x1FUL);
			if (bitnum & 0x20UL) {
				hashh |= mask;
			} else {
				hashl |= mask;
			}
		}
		update_multicast = 1;
	} else	 {
		data &= ~(GMAC_DA_FILT | GMAC_PRO_MODE | GMAC_MCAST | GMAC_MCAST_HASH_FILT);
		hashh = hashl = 0;
		update_multicast = 1;
	}

	spin_lock_irqsave(&priv->lock, flags);
	mac_write32(ndev->base_addr, GMAC_FRAME_FILTER, data);
	if (update_multicast) {
		mac_write32(ndev->base_addr, GMAC_HASH_HI, hashh);
		mac_write32(ndev->base_addr, GMAC_HASH_LO, hashl);
	}
	spin_unlock_irqrestore(&priv->lock, flags);
}
#endif

static int net_lakers_change_mtu(struct net_device *ndev, int new_mtu)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned long flags;

	PRINTK("net_lakers_change_mtu!\n");

	if (new_mtu > PACKET_BUF_SZ || new_mtu < 64)
		return -EINVAL;

	spin_lock_irqsave(&priv->lock, flags);
	ndev->mtu = new_mtu;
	spin_unlock_irqrestore(&priv->lock, flags);

	return 0;
}

static void net_lakers_timer(unsigned long data)
{
	struct net_device *ndev = (struct net_device *)data;
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned long flags;

	spin_lock_irqsave(&priv->lock, flags);
	if (mii_check_media(&priv->mii, netif_msg_link(priv), false)) {
		phy_init(ndev);
		mac_init(ndev);
	}
	spin_unlock_irqrestore(&priv->lock, flags);
//	mod_timer(&priv->timer, jiffies + HZ * 2);
}

static int net_lakers_open(struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned long flags;
	unsigned int data, phy_clk;
	unsigned char *mac = ndev->dev_addr;
	int i;

	spin_lock_irqsave(&priv->lock, flags);
	/* Initialize hardware */
	/* Reset chip */
	mac_write32(ndev->base_addr, DMA_BUS_MODE, DMA_RESET_ON);
	for (i = 0; i < 5; i++) {
		if ((mac_read32(ndev->base_addr, DMA_BUS_MODE) & DMA_RESET_ON) == DMA_RESET_OFF)
			break;
		msleep(1);
	}
	if (i >= 5) {
		return -EBUSY;
	}

//	napi_enable(&priv->napi);

	if (request_irq(ndev->irq, &net_lakers_interrupt, IRQF_SHARED, ndev->name, ndev))
		return -EBUSY;

	/* Read chip version */
	PRINTK("net_lakers_open: GMAC version 0x%08x\n", mac_read32(ndev->base_addr, GMAC_VER));

	/* Set MAC address */
	mac_write32(ndev->base_addr, GMAC_ADDR_0_LO, mac[0] | (mac[1] << 8) | (mac[2] << 16) | (mac[3] << 24));
	mac_write32(ndev->base_addr, GMAC_ADDR_0_HI, mac[4] | (mac[5] << 8) | (mac[6] << 16) | (mac[7] << 24));

	/* Set broadcast address */
	/* Do noting here */

	/* Init MII management interface */
	if (priv->mclock < 35000000) {
		phy_clk = GMAC_GMII_CSR_CLK2;
	} else if (priv->mclock < 60000000) {
		phy_clk = GMAC_GMII_CSR_CLK3;
	} else if (priv->mclock < 100000000) {
		phy_clk = GMAC_GMII_CSR_CLK0;
	} else if (priv->mclock < 150000000) {
		phy_clk = GMAC_GMII_CSR_CLK1;
	} else if (priv->mclock < 250000000) {
		phy_clk = GMAC_GMII_CSR_CLK4;
	} else if (priv->mclock < 300000000) {
		phy_clk = GMAC_GMII_CSR_CLK5;
	} else {
		phy_clk = GMAC_GMII_CSR_CLK0;
	}
	data = mac_read32(ndev->base_addr, GMAC_GMII_ADDR);
	data &= (~GMAC_GMII_CSR_CLK_MASK);
	data |= phy_clk;
	mac_write32(ndev->base_addr, GMAC_GMII_ADDR, data);

	/* Auto detect PHY address */
	phy_detect(ndev);
	/* Wakeup from power down and start AN */
//	data = phy_read16(ndev, priv->mii.phy_id, PHY_CTRL);
//	phy_write16(ndev, priv->mii.phy_id, PHY_CTRL, (data & ~PHY_CTRL_PD));

	/* Setup the TX and RX descriptor link. */
	net_lakers_descs_alloc(ndev);

	/* Initialize DMA */
	mac_write32(ndev->base_addr, DMA_TX_BASE, (unsigned int)(priv->tx_pdesc));
	mac_write32(ndev->base_addr, DMA_RX_BASE, (unsigned int)(priv->rx_pdesc));
//	mac_write32(ndev->base_addr, DMA_BUS_MODE, DMA_ADDR_ALIGN_BEATS | DMA_FIXED_BURST_EN | DMA_BURST_LEN16 | DMA_DES_SKIP4);
	mac_write32(ndev->base_addr, DMA_BUS_MODE, DMA_DES_SKIP1 | DMA_BURST_LEN4);
	mac_write32(ndev->base_addr, DMA_CTR, 0x02200000 |0x00000004 |0x00000018 | 0x00000080);

	/* Enable RX TCPIP checksum drop */
	/* The FEF bit in DMA control register is configured to 0 indicating DMA to drop the errored frames. */
	data = mac_read32(ndev->base_addr, DMA_CTR);
	//mac_write32(ndev->base_addr, DMA_CTR, (data & ~DMA_DI_DROP_TCP_CS) | DMA_FWD_ERR_FRAMES | DMA_FWD_USZ_FRAMES);

	/* Initialize interrupts */
//	hal_exception_set_attrib(1 << ndev->irq, SOC_INT_TRIG_HIGH, 0);

	/* Clear interrupt */
	data = mac_read32(ndev->base_addr, DMA_STA);
	mac_write32(ndev->base_addr, DMA_STA, data);
	/* Enable interrupt */
	mac_write32(ndev->base_addr, DMA_INT, 0 /*DMA_ALL_INT */);
	/* Enable DMA RX/TX */
	data = mac_read32(ndev->base_addr, DMA_CTR);
	mac_write32(ndev->base_addr, DMA_CTR, data | DMA_RX_START | DMA_TX_START);

	spin_unlock_irqrestore(&priv->lock, flags);

	netif_carrier_off(ndev);
	if (mii_check_media(&priv->mii, netif_msg_link(priv), true)) {
		phy_init(ndev);
		mac_init(ndev);
	}
	netif_start_queue(ndev);

#if 0
	init_timer(&priv->timer);
	priv->timer.function = net_lakers_timer;
	priv->timer.data = (unsigned int)ndev;
	mod_timer(&priv->timer, jiffies + HZ * 2);
#endif

	return 0;
}

static int net_lakers_close(struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned long flags;
	unsigned int data;
	int i;

//	del_timer_sync(&priv->timer);

//	napi_disable(&priv->napi);

	spin_lock_irqsave(&priv->lock, flags);

	netif_stop_queue(ndev);
	netif_carrier_off(ndev);

	/* Disable all the interrupts */
	mac_write32(ndev->base_addr, DMA_INT, 0);

	/* Disable RX/TX */
	data = mac_read32(ndev->base_addr, GMAC_CONFIG);
	mac_write32(ndev->base_addr, GMAC_CONFIG, data & ~(GMAC_TX | GMAC_RX));

	/* Disable DMA RX/TX */
	data = mac_read32(ndev->base_addr, DMA_CTR);
	mac_write32(ndev->base_addr, DMA_CTR, data & ~(DMA_RX_START | DMA_TX_START));

	/* Take the ownership of RX descriptor ring */
	for (i = 0; i < RX_DESC_NUM; i++) {
		priv->rx_vdesc[i].status &= ~DESC_OWN;
		/* Free buffer link for each descriptor */
		if ((priv->rx_vdesc[i].length & DESC_SIZE0_MASK) != 0) {
			dev_kfree_skb((struct sk_buff *)(priv->rx_vdesc[i].address1));
		}
	}
	priv->rx_curr = 0;

	/* Take the ownership of TX descriptor link */
	for (i = 0; i < TX_DESC_NUM; i++) {
		priv->tx_vdesc[i].status &= ~DESC_OWN;
	}
	priv->tx_curr = 0;
	priv->tx_pend = 0;

	/* Make sure enter power down */
//	data = phy_read16(ndev, priv->mii.phy_id, PHY_CTRL);
//	phy_write16(ndev, priv->mii.phy_id, PHY_CTRL, data | PHY_CTRL_PD);

	free_irq(ndev->irq, ndev);

	spin_unlock_irqrestore(&priv->lock, flags);

	return 0;
}

#if 0
/*
 * Ethtool support
 */
static int
net_lakers_ethtool_getsettings(struct net_device *ndev, struct ethtool_cmd *cmd)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned long flags;
	int ret;

	spin_lock_irqsave(&priv->lock, flags);
	ret = mii_ethtool_gset(&priv->mii, cmd);
	spin_unlock_irqrestore(&priv->lock, flags);

	return ret;
}

static int
net_lakers_ethtool_setsettings(struct net_device *ndev, struct ethtool_cmd *cmd)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned long flags;
	int ret;

	spin_lock_irqsave(&priv->lock, flags);
	ret = mii_ethtool_sset(&priv->mii, cmd);
	spin_unlock_irqrestore(&priv->lock, flags);

	return ret;
}

static void
net_lakers_ethtool_getdrvinfo(struct net_device *ndev, struct ethtool_drvinfo *info)
{
	strncpy(info->driver, DRIVER_NAME, sizeof(info->driver));
	strncpy(info->version, version, sizeof(info->version));
	strncpy(info->bus_info, ndev->dev.parent->bus_id, sizeof(info->bus_info));
}

static int net_lakers_ethtool_nwayreset(struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned long flags;
	int ret;

	spin_lock_irqsave(&priv->lock, flags);
	ret = mii_nway_restart(&priv->mii);
	spin_unlock_irqrestore(&priv->lock, flags);

	return ret;
}

static u32 net_lakers_ethtool_getmsglevel(struct net_device *ndev)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	return priv->msg_enable;
}

static void net_lakers_ethtool_setmsglevel(struct net_device *ndev, u32 level)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	priv->msg_enable = level;
}

static int net_lakers_ethtool_getregslen(struct net_device *ndev)
{
	return 0x2000;
}

static void net_lakers_ethtool_getregs(struct net_device *ndev,
										struct ethtool_regs* regs, void *buf)
{
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned long flags;
	int i;

	regs->version = 1;
	spin_lock_irqsave(&priv->lock, flags);
	for (i = 0; i < 0x2000; i += 4) {
		((unsigned int *)buf)[i] = mac_read32(ndev->base_addr, i);
	}
	spin_unlock_irqrestore(&priv->lock, flags);
}

static int net_lakers_ethtool_geteeprom(struct net_device *ndev,
									  struct ethtool_eeprom *eeprom, u8 *data)
{
	return 0;
}

static int net_lakers_ethtool_seteeprom(struct net_device *ndev,
									   struct ethtool_eeprom *eeprom, u8 *data)
{
	return 0;
}

static int net_lakers_ethtool_geteeprom_len(struct net_device *ndev)
{
	return 0;
}

static const struct ethtool_ops net_lakers_ethtool_ops = {
	.get_settings	= net_lakers_ethtool_getsettings,
	.set_settings	= net_lakers_ethtool_setsettings,
	.get_drvinfo	= net_lakers_ethtool_getdrvinfo,
	.get_msglevel	= net_lakers_ethtool_getmsglevel,
	.set_msglevel	= net_lakers_ethtool_setmsglevel,
	.nway_reset		= net_lakers_ethtool_nwayreset,
	.get_link		= ethtool_op_get_link,
	.get_regs_len	= net_lakers_ethtool_getregslen,
	.get_regs		= net_lakers_ethtool_getregs,
	.get_eeprom_len	= net_lakers_ethtool_geteeprom_len,
	.get_eeprom		= net_lakers_ethtool_geteeprom,
	.set_eeprom		= net_lakers_ethtool_seteeprom,
};
#endif


static int __devinit net_lakers_drv_probe(struct net_device *ndev)
{
	struct lakers_priv *priv;
	//struct resource *res;
	int ret;

	//res = platform_get_resource(pdev, IORESOURCE_MEM, 0);

	priv = netdev_priv(ndev);			/* Space just after net_device */
	priv->ndev = ndev;
	//priv->dev = &pdev->dev;
	priv->mclock = net_mclock;// ? net_mclock : hal_get_sb_clk();
	priv->vdesc_addr = dma_alloc_coherent(0,
								sizeof(struct dma_descriptor) * (RX_DESC_NUM + TX_DESC_NUM),
								&priv->pdesc_addr,
								GFP_KERNEL);
	priv->rx_pdesc = (struct dma_descriptor	*)(priv->pdesc_addr);
	priv->tx_pdesc = &priv->rx_pdesc[RX_DESC_NUM];
	priv->rx_vdesc = (struct dma_descriptor	*)(priv->vdesc_addr);
	priv->tx_vdesc = &priv->rx_vdesc[RX_DESC_NUM];
	spin_lock_init(&priv->lock);

	//platform_set_drvdata(pdev, ndev);
	//ndev->features |= (NETIF_F_SG | NETIF_F_HIGHDMA);
	//ndev->irq = platform_get_irq(pdev, 0);
	ndev->base_addr = NETLAKERS_ADDR;

	memcpy(ndev->dev_addr, mac_addr, MAX_ADDR_LEN);

#if 0
	ether_setup(ndev);
#endif
	ndev->open = net_lakers_open;
	ndev->stop = net_lakers_close;
	ndev->hard_start_xmit = net_lakers_hard_start_xmit;
#if 0
	ndev->tx_timeout = net_lakers_tx_timeout;
	ndev->watchdog_timeo = msecs_to_jiffies(net_watchdog);
	ndev->set_mac_address = net_lakers_set_mac_address;
	ndev->set_multicast_list = net_lakers_set_multicast_list;
	ndev->ethtool_ops = &net_lakers_ethtool_ops;
	netif_napi_add(ndev, &priv->napi, net_lakers_rx_poll, 16);
	ndev->change_mtu = net_lakers_change_mtu;
#endif

	priv->mii.phy_id_mask = 0x1f;
	priv->mii.reg_num_mask = 0x1f;
	priv->mii.force_media = 0;
	priv->mii.full_duplex = 0;
	priv->mii.dev = ndev;
	priv->mii.mdio_read = phy_read16;
	priv->mii.mdio_write = phy_write16;


	return 0;
}

#if 0
static int net_lakers_drv_remove(struct platform_device *pdev)
{
	struct net_device *ndev = platform_get_drvdata(pdev);
	struct lakers_priv *priv = netdev_priv(ndev);
	struct resource *res;

	platform_set_drvdata(pdev, NULL);
	unregister_netdev(ndev);
	netif_napi_del(&priv->napi);

	dma_free_coherent(&pdev->dev, sizeof(struct dma_descriptor) * (RX_DESC_NUM + TX_DESC_NUM + 1),
					  priv->vdesc_addr, priv->pdesc_addr);
	iounmap((void *)ndev->base_addr);
	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	release_mem_region(res->start, res->end - res->start + 1);
	free_netdev(ndev);

	return 0;
}

static void net_lakers_drv_shutdown(struct platform_device *pdev)
{
	struct net_device *ndev = platform_get_drvdata(pdev);
	struct lakers_priv *priv = netdev_priv(ndev);
	unsigned long flags;
	unsigned int data;

	spin_lock_irqsave(&priv->lock, flags);

	/* Disable RX/TX */
	data = mac_read32(ndev->base_addr, GMAC_CONFIG);
	mac_write32(ndev->base_addr, GMAC_CONFIG, data & ~(GMAC_TX | GMAC_RX));

	/* Disable DMA RX/TX */
	data = mac_read32(ndev->base_addr, DMA_CTR);
	mac_write32(ndev->base_addr, DMA_CTR, data & ~(DMA_RX_START | DMA_TX_START));

	/* Disable interrupt */
	mac_write32(ndev->base_addr, DMA_INT, 0);

	/* Clear interrupt */
	data = mac_read32(ndev->base_addr, DMA_STA);
	mac_write32(ndev->base_addr, DMA_STA, data);

	spin_unlock_irqrestore(&priv->lock, flags);
}
static struct platform_driver net_lakers_driver = {
	.probe		= net_lakers_drv_probe,
	.remove		= net_lakers_drv_remove,
	.suspend	= NULL,
	.resume		= NULL,
	.shutdown	= net_lakers_drv_shutdown,
	.driver		= {
		.name	= DRIVER_NAME,
		.owner	= THIS_MODULE,
	},
};

static int __init net_lakers_init(void)
{
	return platform_driver_register(&net_lakers_driver);
}

static void __exit net_lakers_exit(void)
{
	platform_driver_unregister(&net_lakers_driver);
}

module_init(net_lakers_init);
module_exit(net_lakers_exit);

MODULE_AUTHOR("Justin Wu <justin_mail@21cn.com>");
MODULE_DESCRIPTION("Huaya Lakers Net Driver");
MODULE_LICENSE("GPL v2");
MODULE_ALIAS("platform:" DRIVER_NAME);

module_param(net_watchdog, uint, 0400);
MODULE_PARM_DESC(net_watchdog, "Transmit timeout in milliseconds");

module_param(net_mclock, uint, 0644);
MODULE_PARM_DESC(net_mclock, "net_lakers working clock, 0 for auto detect.");
module_param_array(mac_addr, byte, NULL, 0644);
MODULE_PARM_DESC(mac_addr, "net_lakers default MAC addrss.");
#endif

#include "linux_net_tail.h"
