
//----------------------------------------------------------
#define INET
static void netdev_init(struct net_device *netdev,void *pa)
{
	static int irq=0;

	netdev->priv=kmalloc(sizeof(struct lakers_priv));//&netdev->em;
	memset(netdev->priv,0,sizeof(struct lakers_priv));
	netdev->addr_len=6;
	netdev->pcidev.irq=irq++;
}

static int lakes_ether_ioctl(struct ifnet *ifp,FXP_IOCTLCMD_TYPE cmd,caddr_t data);

static struct pci_device_id *lakes_pci_id=0;
/*
 * Check if a device is an 82557.
 */
static void lakes_start(struct ifnet *ifp);
static int
lakes_match(parent, match, aux)
	struct device *parent;
#if defined(__BROKEN_INDIRECT_CONFIG) || defined(__OpenBSD__)
	void *match;
#else
	struct cfdata *match;
#endif
	void *aux;
{
return 1;
}

static void
lakes_shutdown(sc)
        void *sc;
{
}


extern char activeif_name[];
static int lakes_intr(void *data)
{
struct net_device *netdev = data;
int irq=netdev->irq;
struct ifnet *ifp = &netdev->arpcom.ac_if;
	if(ifp->if_flags & IFF_RUNNING && interrupt)
	{
		   interrupt(0,data);
		   if (ifp->if_snd.ifq_head != NULL)
		   lakes_start(ifp);
	return 1;
	}
	return 0;
}

static void lakers_watchdog( struct ifnet *ifp )
{
	struct net_device *dev = ifp->if_softc;
	net_lakers_timer(dev);
}

static struct net_device *mynic_ste;
static void
lakes_attach(parent, self, aux)
	struct device *parent, *self;
	void *aux;
{
	struct net_device  *sc = (struct net_device *)self;
	struct pci_attach_args *pa = aux;
	//pci_chipset_tag_t pc = pa->pa_pc;
	pci_intr_handle_t ih;
	const char *intrstr = NULL;
	struct ifnet *ifp;
#ifdef __OpenBSD__
	//bus_space_tag_t iot = pa->pa_iot;
	//bus_addr_t iobase;
	//bus_size_t iosize;
#endif

	mynic_ste = sc;

	tgt_poll_register(IPL_NET, lakes_intr, sc);

	netdev_init(sc,pa);
	/* Do generic parts of attach. */
	if(net_lakers_drv_probe(sc)) {
		/* Failed! */
		return;
	}

#ifdef __OpenBSD__
	ifp = &sc->arpcom.ac_if;
	bcopy(sc->dev_addr, sc->arpcom.ac_enaddr, sc->addr_len);
#else
	ifp = &sc->sc_ethercom.ec_if;
#endif
	bcopy(sc->sc_dev.dv_xname, ifp->if_xname, IFNAMSIZ);
	
	ifp->if_softc = sc;
	ifp->if_flags = IFF_BROADCAST | IFF_SIMPLEX | IFF_MULTICAST;
	ifp->if_ioctl = lakes_ether_ioctl;
	ifp->if_start = lakes_start;
	ifp->if_watchdog = lakers_watchdog;

	printf(": %s, address %s\n", intrstr,
	    ether_sprintf(sc->arpcom.ac_enaddr));

	/*
	 * Attach the interface.
	 */
	if_attach(ifp);
	/*
	 * Let the system queue as many packets as we have available
	 * TX descriptors.
	 */
	ifp->if_snd.ifq_maxlen = 4;
#ifdef __NetBSD__
	ether_ifattach(ifp, sc->dev_addr);
#else
	ether_ifattach(ifp);
#endif
#if NBPFILTER > 0
#ifdef __OpenBSD__
	bpfattach(&sc->arpcom.ac_if.if_bpf, ifp, DLT_EN10MB,
	    sizeof(struct ether_header));
#else
	bpfattach(&sc->sc_ethercom.ec_if.if_bpf, ifp, DLT_EN10MB,
	    sizeof(struct ether_header));
#endif
#endif

	/*
	 * Add shutdown hook so that DMA is disabled prior to reboot. Not
	 * doing do could allow DMA to corrupt kernel memory during the
	 * reboot before the driver initializes.
	 */
	shutdownhook_establish(lakes_shutdown, sc);

#ifndef PMON
	/*
	 * Add suspend hook, for similiar reasons..
	 */
	powerhook_establish(lakes_power, sc);
#endif
}


/*
 * Start packet transmission on the interface.
 */



static void lakes_start(struct ifnet *ifp)
{
	struct net_device *sc = ifp->if_softc;
	struct mbuf *mb_head;		
	struct sk_buff *skb;

	while(ifp->if_snd.ifq_head != NULL ){
		
		IF_DEQUEUE(&ifp->if_snd, mb_head);
		
		skb=dev_alloc_skb(mb_head->m_pkthdr.len);
		m_copydata(mb_head, 0, mb_head->m_pkthdr.len, skb->data);
		skb->len=mb_head->m_pkthdr.len;
		sc->hard_start_xmit(skb,sc);

		m_freem(mb_head);
		wbflush();
	} 
}

static int
lakes_init(struct net_device *netdev)
{
    struct ifnet *ifp = &netdev->arpcom.ac_if;
	int stat=0;
	if(!netdev->opencount){ stat=netdev->open(netdev);netdev->opencount++;}
    ifp->if_flags |= IFF_RUNNING;
	return stat;
}

static int
lakes_stop(struct net_device *netdev)
{
    struct ifnet *ifp = &netdev->arpcom.ac_if;
	ifp->if_timer = 0;
	if(netdev->opencount){netdev->stop(netdev);netdev->opencount--;}
	ifp->if_flags &= ~(IFF_RUNNING | IFF_OACTIVE);
	return 0;
}

static int
lakes_ether_ioctl(ifp, cmd, data)
	struct ifnet *ifp;
	FXP_IOCTLCMD_TYPE cmd;
	caddr_t data;
{
	struct ifaddr *ifa = (struct ifaddr *) data;
	struct net_device *sc = ifp->if_softc;
	int error = 0;
	
	int s;
	s = splimp();
		
	switch (cmd) {
#ifdef PMON
	case SIOCPOLL:
		break;
#endif
	case SIOCSIFADDR:

		switch (ifa->ifa_addr->sa_family) {
#ifdef INET
		case AF_INET:
			error = lakes_init(sc);
			if(error <0 )
				return(error);
			ifp->if_flags |= IFF_UP;

#ifdef __OpenBSD__
			arp_ifinit(&sc->arpcom, ifa);
#else
			arp_ifinit(ifp, ifa);
#endif
			
			break;
#endif

		default:
			error = lakes_init(sc);
			if(error <0 )
				return(error);
			ifp->if_flags |= IFF_UP;
			break;
		}
		break;
	case SIOCSIFFLAGS:

		/*
		 * If interface is marked up and not running, then start it.
		 * If it is marked down and running, stop it.
		 * XXX If it's up then re-initialize it. This is so flags
		 * such as IFF_PROMISC are handled.
		 */
		if (ifp->if_flags & IFF_UP) {
			error = lakes_init(sc);
			if(error <0 )
				return(error);
		} else {
			if (ifp->if_flags & IFF_RUNNING)
				lakes_stop(sc);
		}
		break;

        case SIOCETHTOOL:
        {
        long *p=data;
        mynic_ste = sc;
        }
        break;
       case SIOCRDEEPROM:
                {
                long *p=data;
                mynic_ste = sc;
                }
                break;
       case SIOCWREEPROM:
                {
                long *p=data;
                mynic_ste = sc;
                }
                break;
	default:
		error = EINVAL;
	}

	splx(s);
	return (error);
}

struct cfattach lakers_ca = {
	sizeof(struct net_device), lakes_match, lakes_attach
};

struct cfdriver lakers_cd = {
	NULL, "lakers", DV_IFNET
};

