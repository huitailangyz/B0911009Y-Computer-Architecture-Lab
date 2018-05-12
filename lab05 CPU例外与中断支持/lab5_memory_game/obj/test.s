
obj//main.elf:     file format elf32-tradlittlemips
obj//main.elf


Disassembly of section .text:

bfc00000 <_ftext>:
/root/lab5_memory_game/start.S:51
bfc00000:	3c0a0040 	lui	t2,0x40
/root/lab5_memory_game/start.S:52
bfc00004:	408a6000 	mtc0	t2,c0_sr
/root/lab5_memory_game/start.S:53
bfc00008:	40806800 	mtc0	zero,c0_cause
/root/lab5_memory_game/start.S:54
bfc0000c:	3c1d8000 	lui	sp,0x8000
bfc00010:	27bd41a8 	addiu	sp,sp,16808
/root/lab5_memory_game/start.S:55
bfc00014:	3c1c8001 	lui	gp,0x8001
bfc00018:	279c81d0 	addiu	gp,gp,-32304
/root/lab5_memory_game/start.S:57
bfc0001c:	04110544 	bal	bfc01530 <memory_game>
/root/lab5_memory_game/start.S:58
bfc00020:	00000000 	nop

bfc00024 <exit>:
/root/lab5_memory_game/start.S:61
bfc00024:	340900ff 	li	t1,0xff
/root/lab5_memory_game/start.S:62
bfc00028:	a0097ffc 	sb	t1,32764(zero)
	...
/root/lab5_memory_game/start.S:65
bfc00380:	0ff008f2 	jal	bfc023c8 <exception>
/root/lab5_memory_game/start.S:66
bfc00384:	00000000 	nop
/root/lab5_memory_game/start.S:67
bfc00388:	0bf00009 	j	bfc00024 <exit>
/root/lab5_memory_game/start.S:68
bfc0038c:	00000000 	nop

bfc00390 <delay>:
delay():
bfc00390:	27bdfff8 	addiu	sp,sp,-8
bfc00394:	afa00000 	sw	zero,0(sp)
bfc00398:	8fa30000 	lw	v1,0(sp)
bfc0039c:	00000000 	nop
bfc003a0:	0064102b 	sltu	v0,v1,a0
bfc003a4:	10400058 	beqz	v0,bfc00508 <delay+0x178>
bfc003a8:	00000000 	nop
bfc003ac:	afa00004 	sw	zero,4(sp)
bfc003b0:	8fa60004 	lw	a2,4(sp)
bfc003b4:	00000000 	nop
bfc003b8:	2cc52710 	sltiu	a1,a2,10000
bfc003bc:	10a00049 	beqz	a1,bfc004e4 <delay+0x154>
bfc003c0:	00000000 	nop
bfc003c4:	8faa0004 	lw	t2,4(sp)
bfc003c8:	00000000 	nop
bfc003cc:	25490001 	addiu	t1,t2,1
bfc003d0:	afa90004 	sw	t1,4(sp)
bfc003d4:	8fa80004 	lw	t0,4(sp)
bfc003d8:	00000000 	nop
bfc003dc:	2d072710 	sltiu	a3,t0,10000
bfc003e0:	10e00040 	beqz	a3,bfc004e4 <delay+0x154>
bfc003e4:	00000000 	nop
bfc003e8:	8fa20004 	lw	v0,4(sp)
bfc003ec:	00000000 	nop
bfc003f0:	24590001 	addiu	t9,v0,1
bfc003f4:	afb90004 	sw	t9,4(sp)
bfc003f8:	8fb80004 	lw	t8,4(sp)
bfc003fc:	00000000 	nop
bfc00400:	2f0f2710 	sltiu	t7,t8,10000
bfc00404:	11e00037 	beqz	t7,bfc004e4 <delay+0x154>
bfc00408:	00000000 	nop
bfc0040c:	8fa70004 	lw	a3,4(sp)
bfc00410:	00000000 	nop
bfc00414:	24e60001 	addiu	a2,a3,1
bfc00418:	afa60004 	sw	a2,4(sp)
bfc0041c:	8fa50004 	lw	a1,4(sp)
bfc00420:	00000000 	nop
bfc00424:	2ca32710 	sltiu	v1,a1,10000
bfc00428:	1060002e 	beqz	v1,bfc004e4 <delay+0x154>
bfc0042c:	00000000 	nop
bfc00430:	8fab0004 	lw	t3,4(sp)
bfc00434:	00000000 	nop
bfc00438:	256a0001 	addiu	t2,t3,1
bfc0043c:	afaa0004 	sw	t2,4(sp)
bfc00440:	8fa90004 	lw	t1,4(sp)
bfc00444:	00000000 	nop
bfc00448:	2d282710 	sltiu	t0,t1,10000
bfc0044c:	11000025 	beqz	t0,bfc004e4 <delay+0x154>
bfc00450:	00000000 	nop
bfc00454:	8faf0004 	lw	t7,4(sp)
bfc00458:	00000000 	nop
bfc0045c:	25ee0001 	addiu	t6,t7,1
bfc00460:	afae0004 	sw	t6,4(sp)
bfc00464:	8fad0004 	lw	t5,4(sp)
bfc00468:	00000000 	nop
bfc0046c:	2dac2710 	sltiu	t4,t5,10000
bfc00470:	1180001c 	beqz	t4,bfc004e4 <delay+0x154>
bfc00474:	00000000 	nop
bfc00478:	8fa30004 	lw	v1,4(sp)
bfc0047c:	00000000 	nop
bfc00480:	24620001 	addiu	v0,v1,1
bfc00484:	afa20004 	sw	v0,4(sp)
bfc00488:	8fb90004 	lw	t9,4(sp)
bfc0048c:	00000000 	nop
bfc00490:	2f382710 	sltiu	t8,t9,10000
bfc00494:	13000013 	beqz	t8,bfc004e4 <delay+0x154>
bfc00498:	00000000 	nop
bfc0049c:	8fa80004 	lw	t0,4(sp)
bfc004a0:	00000000 	nop
bfc004a4:	25070001 	addiu	a3,t0,1
bfc004a8:	afa70004 	sw	a3,4(sp)
bfc004ac:	8fa60004 	lw	a2,4(sp)
bfc004b0:	00000000 	nop
bfc004b4:	2cc52710 	sltiu	a1,a2,10000
bfc004b8:	10a0000a 	beqz	a1,bfc004e4 <delay+0x154>
bfc004bc:	00000000 	nop
bfc004c0:	8fac0004 	lw	t4,4(sp)
bfc004c4:	00000000 	nop
bfc004c8:	258b0001 	addiu	t3,t4,1
bfc004cc:	afab0004 	sw	t3,4(sp)
bfc004d0:	8faa0004 	lw	t2,4(sp)
bfc004d4:	00000000 	nop
bfc004d8:	2d492710 	sltiu	t1,t2,10000
bfc004dc:	1520ffb9 	bnez	t1,bfc003c4 <delay+0x34>
bfc004e0:	00000000 	nop
bfc004e4:	8fae0000 	lw	t6,0(sp)
bfc004e8:	00000000 	nop
bfc004ec:	25cd0001 	addiu	t5,t6,1
bfc004f0:	afad0000 	sw	t5,0(sp)
bfc004f4:	8fac0000 	lw	t4,0(sp)
bfc004f8:	00000000 	nop
bfc004fc:	0184582b 	sltu	t3,t4,a0
bfc00500:	1560ffaa 	bnez	t3,bfc003ac <delay+0x1c>
bfc00504:	00000000 	nop
bfc00508:	03e00008 	jr	ra
bfc0050c:	27bd0008 	addiu	sp,sp,8

bfc00510 <getUserPress>:
getUserPress():
bfc00510:	27bdfff8 	addiu	sp,sp,-8
bfc00514:	8c05f024 	lw	a1,-4060(zero)
bfc00518:	00000000 	nop
bfc0051c:	30a4f000 	andi	a0,a1,0xf000
bfc00520:	00041302 	srl	v0,a0,0xc
bfc00524:	afa20000 	sw	v0,0(sp)
bfc00528:	8fa30000 	lw	v1,0(sp)
bfc0052c:	00000000 	nop
bfc00530:	14600040 	bnez	v1,bfc00634 <getUserPress+0x124>
bfc00534:	00000000 	nop
bfc00538:	8c04f024 	lw	a0,-4060(zero)
bfc0053c:	00000000 	nop
bfc00540:	3082f000 	andi	v0,a0,0xf000
bfc00544:	00021b02 	srl	v1,v0,0xc
bfc00548:	afa30000 	sw	v1,0(sp)
bfc0054c:	8fb90000 	lw	t9,0(sp)
bfc00550:	00000000 	nop
bfc00554:	17200037 	bnez	t9,bfc00634 <getUserPress+0x124>
bfc00558:	00000000 	nop
bfc0055c:	8c08f024 	lw	t0,-4060(zero)
bfc00560:	00000000 	nop
bfc00564:	3107f000 	andi	a3,t0,0xf000
bfc00568:	00073302 	srl	a2,a3,0xc
bfc0056c:	afa60000 	sw	a2,0(sp)
bfc00570:	8fa50000 	lw	a1,0(sp)
bfc00574:	00000000 	nop
bfc00578:	14a0002e 	bnez	a1,bfc00634 <getUserPress+0x124>
bfc0057c:	00000000 	nop
bfc00580:	8c0cf024 	lw	t4,-4060(zero)
bfc00584:	00000000 	nop
bfc00588:	318bf000 	andi	t3,t4,0xf000
bfc0058c:	000b5302 	srl	t2,t3,0xc
bfc00590:	afaa0000 	sw	t2,0(sp)
bfc00594:	8fa90000 	lw	t1,0(sp)
bfc00598:	00000000 	nop
bfc0059c:	15200025 	bnez	t1,bfc00634 <getUserPress+0x124>
bfc005a0:	00000000 	nop
bfc005a4:	8c18f024 	lw	t8,-4060(zero)
bfc005a8:	00000000 	nop
bfc005ac:	330ff000 	andi	t7,t8,0xf000
bfc005b0:	000f7302 	srl	t6,t7,0xc
bfc005b4:	afae0000 	sw	t6,0(sp)
bfc005b8:	8fad0000 	lw	t5,0(sp)
bfc005bc:	00000000 	nop
bfc005c0:	15a0001c 	bnez	t5,bfc00634 <getUserPress+0x124>
bfc005c4:	00000000 	nop
bfc005c8:	8c04f024 	lw	a0,-4060(zero)
bfc005cc:	00000000 	nop
bfc005d0:	3082f000 	andi	v0,a0,0xf000
bfc005d4:	00021b02 	srl	v1,v0,0xc
bfc005d8:	afa30000 	sw	v1,0(sp)
bfc005dc:	8fb90000 	lw	t9,0(sp)
bfc005e0:	00000000 	nop
bfc005e4:	17200013 	bnez	t9,bfc00634 <getUserPress+0x124>
bfc005e8:	00000000 	nop
bfc005ec:	8c08f024 	lw	t0,-4060(zero)
bfc005f0:	00000000 	nop
bfc005f4:	3107f000 	andi	a3,t0,0xf000
bfc005f8:	00073302 	srl	a2,a3,0xc
bfc005fc:	afa60000 	sw	a2,0(sp)
bfc00600:	8fa50000 	lw	a1,0(sp)
bfc00604:	00000000 	nop
bfc00608:	14a0000a 	bnez	a1,bfc00634 <getUserPress+0x124>
bfc0060c:	00000000 	nop
bfc00610:	8c0cf024 	lw	t4,-4060(zero)
bfc00614:	00000000 	nop
bfc00618:	318bf000 	andi	t3,t4,0xf000
bfc0061c:	000b5302 	srl	t2,t3,0xc
bfc00620:	afaa0000 	sw	t2,0(sp)
bfc00624:	8fa90000 	lw	t1,0(sp)
bfc00628:	00000000 	nop
bfc0062c:	1120ffb9 	beqz	t1,bfc00514 <getUserPress+0x4>
bfc00630:	00000000 	nop
bfc00634:	8fab0000 	lw	t3,0(sp)
bfc00638:	27bd0008 	addiu	sp,sp,8
bfc0063c:	31780001 	andi	t8,t3,0x1
bfc00640:	000b78c3 	sra	t7,t3,0x3
bfc00644:	001868c0 	sll	t5,t8,0x3
bfc00648:	31ee0001 	andi	t6,t7,0x1
bfc0064c:	000b6042 	srl	t4,t3,0x1
bfc00650:	01ae4825 	or	t1,t5,t6
bfc00654:	318a0002 	andi	t2,t4,0x2
bfc00658:	000b4040 	sll	t0,t3,0x1
bfc0065c:	012a3825 	or	a3,t1,t2
bfc00660:	31060004 	andi	a2,t0,0x4
bfc00664:	03e00008 	jr	ra
bfc00668:	00e61025 	or	v0,a3,a2
bfc0066c:	00000000 	nop

bfc00670 <getUserRelease>:
getUserRelease():
bfc00670:	27bdfff8 	addiu	sp,sp,-8
bfc00674:	8c05f024 	lw	a1,-4060(zero)
bfc00678:	00000000 	nop
bfc0067c:	30a4f000 	andi	a0,a1,0xf000
bfc00680:	00041302 	srl	v0,a0,0xc
bfc00684:	afa20000 	sw	v0,0(sp)
bfc00688:	8fa30000 	lw	v1,0(sp)
bfc0068c:	00000000 	nop
bfc00690:	10600040 	beqz	v1,bfc00794 <getUserRelease+0x124>
bfc00694:	00000000 	nop
bfc00698:	8c09f024 	lw	t1,-4060(zero)
bfc0069c:	00000000 	nop
bfc006a0:	3128f000 	andi	t0,t1,0xf000
bfc006a4:	00083b02 	srl	a3,t0,0xc
bfc006a8:	afa70000 	sw	a3,0(sp)
bfc006ac:	8fa60000 	lw	a2,0(sp)
bfc006b0:	00000000 	nop
bfc006b4:	10c00037 	beqz	a2,bfc00794 <getUserRelease+0x124>
bfc006b8:	00000000 	nop
bfc006bc:	8c0df024 	lw	t5,-4060(zero)
bfc006c0:	00000000 	nop
bfc006c4:	31acf000 	andi	t4,t5,0xf000
bfc006c8:	000c5b02 	srl	t3,t4,0xc
bfc006cc:	afab0000 	sw	t3,0(sp)
bfc006d0:	8faa0000 	lw	t2,0(sp)
bfc006d4:	00000000 	nop
bfc006d8:	1140002e 	beqz	t2,bfc00794 <getUserRelease+0x124>
bfc006dc:	00000000 	nop
bfc006e0:	8c19f024 	lw	t9,-4060(zero)
bfc006e4:	00000000 	nop
bfc006e8:	3338f000 	andi	t8,t9,0xf000
bfc006ec:	00187b02 	srl	t7,t8,0xc
bfc006f0:	afaf0000 	sw	t7,0(sp)
bfc006f4:	8fae0000 	lw	t6,0(sp)
bfc006f8:	00000000 	nop
bfc006fc:	11c00025 	beqz	t6,bfc00794 <getUserRelease+0x124>
bfc00700:	00000000 	nop
bfc00704:	8c05f024 	lw	a1,-4060(zero)
bfc00708:	00000000 	nop
bfc0070c:	30a4f000 	andi	a0,a1,0xf000
bfc00710:	00041302 	srl	v0,a0,0xc
bfc00714:	afa20000 	sw	v0,0(sp)
bfc00718:	8fa30000 	lw	v1,0(sp)
bfc0071c:	00000000 	nop
bfc00720:	1060001c 	beqz	v1,bfc00794 <getUserRelease+0x124>
bfc00724:	00000000 	nop
bfc00728:	8c09f024 	lw	t1,-4060(zero)
bfc0072c:	00000000 	nop
bfc00730:	3128f000 	andi	t0,t1,0xf000
bfc00734:	00083b02 	srl	a3,t0,0xc
bfc00738:	afa70000 	sw	a3,0(sp)
bfc0073c:	8fa60000 	lw	a2,0(sp)
bfc00740:	00000000 	nop
bfc00744:	10c00013 	beqz	a2,bfc00794 <getUserRelease+0x124>
bfc00748:	00000000 	nop
bfc0074c:	8c0df024 	lw	t5,-4060(zero)
bfc00750:	00000000 	nop
bfc00754:	31acf000 	andi	t4,t5,0xf000
bfc00758:	000c5b02 	srl	t3,t4,0xc
bfc0075c:	afab0000 	sw	t3,0(sp)
bfc00760:	8faa0000 	lw	t2,0(sp)
bfc00764:	00000000 	nop
bfc00768:	1140000a 	beqz	t2,bfc00794 <getUserRelease+0x124>
bfc0076c:	00000000 	nop
bfc00770:	8c19f024 	lw	t9,-4060(zero)
bfc00774:	00000000 	nop
bfc00778:	3338f000 	andi	t8,t9,0xf000
bfc0077c:	00187b02 	srl	t7,t8,0xc
bfc00780:	afaf0000 	sw	t7,0(sp)
bfc00784:	8fae0000 	lw	t6,0(sp)
bfc00788:	00000000 	nop
bfc0078c:	15c0ffb9 	bnez	t6,bfc00674 <getUserRelease+0x4>
bfc00790:	00000000 	nop
bfc00794:	03e00008 	jr	ra
bfc00798:	27bd0008 	addiu	sp,sp,8
bfc0079c:	00000000 	nop

bfc007a0 <displayPattern>:
displayPattern():
bfc007a0:	27bdfff0 	addiu	sp,sp,-16
bfc007a4:	3405ffff 	li	a1,0xffff
bfc007a8:	ac05f000 	sw	a1,-4096(zero)
bfc007ac:	afa00004 	sw	zero,4(sp)
bfc007b0:	8fa30004 	lw	v1,4(sp)
bfc007b4:	00000000 	nop
bfc007b8:	2c6201f4 	sltiu	v0,v1,500
bfc007bc:	10400058 	beqz	v0,bfc00920 <displayPattern+0x180>
bfc007c0:	00000000 	nop
bfc007c4:	afa00008 	sw	zero,8(sp)
bfc007c8:	8fa70008 	lw	a3,8(sp)
bfc007cc:	00000000 	nop
bfc007d0:	2ce62710 	sltiu	a2,a3,10000
bfc007d4:	10c00049 	beqz	a2,bfc008fc <displayPattern+0x15c>
bfc007d8:	00000000 	nop
bfc007dc:	8fab0008 	lw	t3,8(sp)
bfc007e0:	00000000 	nop
bfc007e4:	256a0001 	addiu	t2,t3,1
bfc007e8:	afaa0008 	sw	t2,8(sp)
bfc007ec:	8fa90008 	lw	t1,8(sp)
bfc007f0:	00000000 	nop
bfc007f4:	2d282710 	sltiu	t0,t1,10000
bfc007f8:	11000040 	beqz	t0,bfc008fc <displayPattern+0x15c>
bfc007fc:	00000000 	nop
bfc00800:	8fab0008 	lw	t3,8(sp)
bfc00804:	00000000 	nop
bfc00808:	256a0001 	addiu	t2,t3,1
bfc0080c:	afaa0008 	sw	t2,8(sp)
bfc00810:	8fa90008 	lw	t1,8(sp)
bfc00814:	00000000 	nop
bfc00818:	2d252710 	sltiu	a1,t1,10000
bfc0081c:	10a00037 	beqz	a1,bfc008fc <displayPattern+0x15c>
bfc00820:	00000000 	nop
bfc00824:	8faf0008 	lw	t7,8(sp)
bfc00828:	00000000 	nop
bfc0082c:	25ee0001 	addiu	t6,t7,1
bfc00830:	afae0008 	sw	t6,8(sp)
bfc00834:	8fad0008 	lw	t5,8(sp)
bfc00838:	00000000 	nop
bfc0083c:	2dac2710 	sltiu	t4,t5,10000
bfc00840:	1180002e 	beqz	t4,bfc008fc <displayPattern+0x15c>
bfc00844:	00000000 	nop
bfc00848:	8fa30008 	lw	v1,8(sp)
bfc0084c:	00000000 	nop
bfc00850:	24620001 	addiu	v0,v1,1
bfc00854:	afa20008 	sw	v0,8(sp)
bfc00858:	8fb90008 	lw	t9,8(sp)
bfc0085c:	00000000 	nop
bfc00860:	2f382710 	sltiu	t8,t9,10000
bfc00864:	13000025 	beqz	t8,bfc008fc <displayPattern+0x15c>
bfc00868:	00000000 	nop
bfc0086c:	8fa50008 	lw	a1,8(sp)
bfc00870:	00000000 	nop
bfc00874:	24a80001 	addiu	t0,a1,1
bfc00878:	afa80008 	sw	t0,8(sp)
bfc0087c:	8fa70008 	lw	a3,8(sp)
bfc00880:	00000000 	nop
bfc00884:	2ce62710 	sltiu	a2,a3,10000
bfc00888:	10c0001c 	beqz	a2,bfc008fc <displayPattern+0x15c>
bfc0088c:	00000000 	nop
bfc00890:	8fac0008 	lw	t4,8(sp)
bfc00894:	00000000 	nop
bfc00898:	258b0001 	addiu	t3,t4,1
bfc0089c:	afab0008 	sw	t3,8(sp)
bfc008a0:	8faa0008 	lw	t2,8(sp)
bfc008a4:	00000000 	nop
bfc008a8:	2d492710 	sltiu	t1,t2,10000
bfc008ac:	11200013 	beqz	t1,bfc008fc <displayPattern+0x15c>
bfc008b0:	00000000 	nop
bfc008b4:	8fb80008 	lw	t8,8(sp)
bfc008b8:	00000000 	nop
bfc008bc:	270f0001 	addiu	t7,t8,1
bfc008c0:	afaf0008 	sw	t7,8(sp)
bfc008c4:	8fae0008 	lw	t6,8(sp)
bfc008c8:	00000000 	nop
bfc008cc:	2dcd2710 	sltiu	t5,t6,10000
bfc008d0:	11a0000a 	beqz	t5,bfc008fc <displayPattern+0x15c>
bfc008d4:	00000000 	nop
bfc008d8:	8fa60008 	lw	a2,8(sp)
bfc008dc:	00000000 	nop
bfc008e0:	24c30001 	addiu	v1,a2,1
bfc008e4:	afa30008 	sw	v1,8(sp)
bfc008e8:	8fa20008 	lw	v0,8(sp)
bfc008ec:	00000000 	nop
bfc008f0:	2c592710 	sltiu	t9,v0,10000
bfc008f4:	1720ffb9 	bnez	t9,bfc007dc <displayPattern+0x3c>
bfc008f8:	00000000 	nop
bfc008fc:	8faf0004 	lw	t7,4(sp)
bfc00900:	00000000 	nop
bfc00904:	25ee0001 	addiu	t6,t7,1
bfc00908:	afae0004 	sw	t6,4(sp)
bfc0090c:	8fad0004 	lw	t5,4(sp)
bfc00910:	00000000 	nop
bfc00914:	2dac01f4 	sltiu	t4,t5,500
bfc00918:	1580ffaa 	bnez	t4,bfc007c4 <displayPattern+0x24>
bfc0091c:	00000000 	nop
bfc00920:	afa00000 	sw	zero,0(sp)
bfc00924:	8fb90000 	lw	t9,0(sp)
bfc00928:	00000000 	nop
bfc0092c:	2b380008 	slti	t8,t9,8
bfc00930:	130000ce 	beqz	t8,bfc00c6c <displayPattern+0x4cc>
bfc00934:	00000000 	nop
bfc00938:	3405ffff 	li	a1,0xffff
bfc0093c:	8faa0000 	lw	t2,0(sp)
bfc00940:	00000000 	nop
bfc00944:	000a4880 	sll	t1,t2,0x2
bfc00948:	00894021 	addu	t0,a0,t1
bfc0094c:	8d070000 	lw	a3,0(t0)
bfc00950:	00000000 	nop
bfc00954:	00073027 	nor	a2,zero,a3
bfc00958:	ac06f000 	sw	a2,-4096(zero)
bfc0095c:	afa00008 	sw	zero,8(sp)
bfc00960:	8fa30008 	lw	v1,8(sp)
bfc00964:	00000000 	nop
bfc00968:	2c6200c8 	sltiu	v0,v1,200
bfc0096c:	10400058 	beqz	v0,bfc00ad0 <displayPattern+0x330>
bfc00970:	00000000 	nop
bfc00974:	afa00004 	sw	zero,4(sp)
bfc00978:	8fac0004 	lw	t4,4(sp)
bfc0097c:	00000000 	nop
bfc00980:	2d8b2710 	sltiu	t3,t4,10000
bfc00984:	11600049 	beqz	t3,bfc00aac <displayPattern+0x30c>
bfc00988:	00000000 	nop
bfc0098c:	8fb80004 	lw	t8,4(sp)
bfc00990:	00000000 	nop
bfc00994:	270f0001 	addiu	t7,t8,1
bfc00998:	afaf0004 	sw	t7,4(sp)
bfc0099c:	8fae0004 	lw	t6,4(sp)
bfc009a0:	00000000 	nop
bfc009a4:	2dcd2710 	sltiu	t5,t6,10000
bfc009a8:	11a00040 	beqz	t5,bfc00aac <displayPattern+0x30c>
bfc009ac:	00000000 	nop
bfc009b0:	8fac0004 	lw	t4,4(sp)
bfc009b4:	00000000 	nop
bfc009b8:	258b0001 	addiu	t3,t4,1
bfc009bc:	afab0004 	sw	t3,4(sp)
bfc009c0:	8faa0004 	lw	t2,4(sp)
bfc009c4:	00000000 	nop
bfc009c8:	2d492710 	sltiu	t1,t2,10000
bfc009cc:	11200037 	beqz	t1,bfc00aac <displayPattern+0x30c>
bfc009d0:	00000000 	nop
bfc009d4:	8fb80004 	lw	t8,4(sp)
bfc009d8:	00000000 	nop
bfc009dc:	270f0001 	addiu	t7,t8,1
bfc009e0:	afaf0004 	sw	t7,4(sp)
bfc009e4:	8fae0004 	lw	t6,4(sp)
bfc009e8:	00000000 	nop
bfc009ec:	2dcd2710 	sltiu	t5,t6,10000
bfc009f0:	11a0002e 	beqz	t5,bfc00aac <displayPattern+0x30c>
bfc009f4:	00000000 	nop
bfc009f8:	8fa60004 	lw	a2,4(sp)
bfc009fc:	00000000 	nop
bfc00a00:	24c30001 	addiu	v1,a2,1
bfc00a04:	afa30004 	sw	v1,4(sp)
bfc00a08:	8fa20004 	lw	v0,4(sp)
bfc00a0c:	00000000 	nop
bfc00a10:	2c592710 	sltiu	t9,v0,10000
bfc00a14:	13200025 	beqz	t9,bfc00aac <displayPattern+0x30c>
bfc00a18:	00000000 	nop
bfc00a1c:	8faa0004 	lw	t2,4(sp)
bfc00a20:	00000000 	nop
bfc00a24:	25490001 	addiu	t1,t2,1
bfc00a28:	afa90004 	sw	t1,4(sp)
bfc00a2c:	8fa80004 	lw	t0,4(sp)
bfc00a30:	00000000 	nop
bfc00a34:	2d072710 	sltiu	a3,t0,10000
bfc00a38:	10e0001c 	beqz	a3,bfc00aac <displayPattern+0x30c>
bfc00a3c:	00000000 	nop
bfc00a40:	8fae0004 	lw	t6,4(sp)
bfc00a44:	00000000 	nop
bfc00a48:	25cd0001 	addiu	t5,t6,1
bfc00a4c:	afad0004 	sw	t5,4(sp)
bfc00a50:	8fac0004 	lw	t4,4(sp)
bfc00a54:	00000000 	nop
bfc00a58:	2d8b2710 	sltiu	t3,t4,10000
bfc00a5c:	11600013 	beqz	t3,bfc00aac <displayPattern+0x30c>
bfc00a60:	00000000 	nop
bfc00a64:	8fa20004 	lw	v0,4(sp)
bfc00a68:	00000000 	nop
bfc00a6c:	24590001 	addiu	t9,v0,1
bfc00a70:	afb90004 	sw	t9,4(sp)
bfc00a74:	8fb80004 	lw	t8,4(sp)
bfc00a78:	00000000 	nop
bfc00a7c:	2f0f2710 	sltiu	t7,t8,10000
bfc00a80:	11e0000a 	beqz	t7,bfc00aac <displayPattern+0x30c>
bfc00a84:	00000000 	nop
bfc00a88:	8fa80004 	lw	t0,4(sp)
bfc00a8c:	00000000 	nop
bfc00a90:	25070001 	addiu	a3,t0,1
bfc00a94:	afa70004 	sw	a3,4(sp)
bfc00a98:	8fa60004 	lw	a2,4(sp)
bfc00a9c:	00000000 	nop
bfc00aa0:	2cc32710 	sltiu	v1,a2,10000
bfc00aa4:	1460ffb9 	bnez	v1,bfc0098c <displayPattern+0x1ec>
bfc00aa8:	00000000 	nop
bfc00aac:	8fa60008 	lw	a2,8(sp)
bfc00ab0:	00000000 	nop
bfc00ab4:	24c30001 	addiu	v1,a2,1
bfc00ab8:	afa30008 	sw	v1,8(sp)
bfc00abc:	8fa20008 	lw	v0,8(sp)
bfc00ac0:	00000000 	nop
bfc00ac4:	2c5900c8 	sltiu	t9,v0,200
bfc00ac8:	1720ffaa 	bnez	t9,bfc00974 <displayPattern+0x1d4>
bfc00acc:	00000000 	nop
bfc00ad0:	ac05f000 	sw	a1,-4096(zero)
bfc00ad4:	afa00004 	sw	zero,4(sp)
bfc00ad8:	8fa80004 	lw	t0,4(sp)
bfc00adc:	00000000 	nop
bfc00ae0:	2d070064 	sltiu	a3,t0,100
bfc00ae4:	10e00058 	beqz	a3,bfc00c48 <displayPattern+0x4a8>
bfc00ae8:	00000000 	nop
bfc00aec:	afa00008 	sw	zero,8(sp)
bfc00af0:	8faa0008 	lw	t2,8(sp)
bfc00af4:	00000000 	nop
bfc00af8:	2d492710 	sltiu	t1,t2,10000
bfc00afc:	11200049 	beqz	t1,bfc00c24 <displayPattern+0x484>
bfc00b00:	00000000 	nop
bfc00b04:	8fae0008 	lw	t6,8(sp)
bfc00b08:	00000000 	nop
bfc00b0c:	25cd0001 	addiu	t5,t6,1
bfc00b10:	afad0008 	sw	t5,8(sp)
bfc00b14:	8fac0008 	lw	t4,8(sp)
bfc00b18:	00000000 	nop
bfc00b1c:	2d8b2710 	sltiu	t3,t4,10000
bfc00b20:	11600040 	beqz	t3,bfc00c24 <displayPattern+0x484>
bfc00b24:	00000000 	nop
bfc00b28:	8fac0008 	lw	t4,8(sp)
bfc00b2c:	00000000 	nop
bfc00b30:	258b0001 	addiu	t3,t4,1
bfc00b34:	afab0008 	sw	t3,8(sp)
bfc00b38:	8faa0008 	lw	t2,8(sp)
bfc00b3c:	00000000 	nop
bfc00b40:	2d492710 	sltiu	t1,t2,10000
bfc00b44:	11200037 	beqz	t1,bfc00c24 <displayPattern+0x484>
bfc00b48:	00000000 	nop
bfc00b4c:	8fb80008 	lw	t8,8(sp)
bfc00b50:	00000000 	nop
bfc00b54:	270f0001 	addiu	t7,t8,1
bfc00b58:	afaf0008 	sw	t7,8(sp)
bfc00b5c:	8fae0008 	lw	t6,8(sp)
bfc00b60:	00000000 	nop
bfc00b64:	2dcd2710 	sltiu	t5,t6,10000
bfc00b68:	11a0002e 	beqz	t5,bfc00c24 <displayPattern+0x484>
bfc00b6c:	00000000 	nop
bfc00b70:	8fa60008 	lw	a2,8(sp)
bfc00b74:	00000000 	nop
bfc00b78:	24c30001 	addiu	v1,a2,1
bfc00b7c:	afa30008 	sw	v1,8(sp)
bfc00b80:	8fa20008 	lw	v0,8(sp)
bfc00b84:	00000000 	nop
bfc00b88:	2c592710 	sltiu	t9,v0,10000
bfc00b8c:	13200025 	beqz	t9,bfc00c24 <displayPattern+0x484>
bfc00b90:	00000000 	nop
bfc00b94:	8faa0008 	lw	t2,8(sp)
bfc00b98:	00000000 	nop
bfc00b9c:	25490001 	addiu	t1,t2,1
bfc00ba0:	afa90008 	sw	t1,8(sp)
bfc00ba4:	8fa80008 	lw	t0,8(sp)
bfc00ba8:	00000000 	nop
bfc00bac:	2d072710 	sltiu	a3,t0,10000
bfc00bb0:	10e0001c 	beqz	a3,bfc00c24 <displayPattern+0x484>
bfc00bb4:	00000000 	nop
bfc00bb8:	8fae0008 	lw	t6,8(sp)
bfc00bbc:	00000000 	nop
bfc00bc0:	25cd0001 	addiu	t5,t6,1
bfc00bc4:	afad0008 	sw	t5,8(sp)
bfc00bc8:	8fac0008 	lw	t4,8(sp)
bfc00bcc:	00000000 	nop
bfc00bd0:	2d8b2710 	sltiu	t3,t4,10000
bfc00bd4:	11600013 	beqz	t3,bfc00c24 <displayPattern+0x484>
bfc00bd8:	00000000 	nop
bfc00bdc:	8fa20008 	lw	v0,8(sp)
bfc00be0:	00000000 	nop
bfc00be4:	24590001 	addiu	t9,v0,1
bfc00be8:	afb90008 	sw	t9,8(sp)
bfc00bec:	8fb80008 	lw	t8,8(sp)
bfc00bf0:	00000000 	nop
bfc00bf4:	2f0f2710 	sltiu	t7,t8,10000
bfc00bf8:	11e0000a 	beqz	t7,bfc00c24 <displayPattern+0x484>
bfc00bfc:	00000000 	nop
bfc00c00:	8fa80008 	lw	t0,8(sp)
bfc00c04:	00000000 	nop
bfc00c08:	25070001 	addiu	a3,t0,1
bfc00c0c:	afa70008 	sw	a3,8(sp)
bfc00c10:	8fa60008 	lw	a2,8(sp)
bfc00c14:	00000000 	nop
bfc00c18:	2cc32710 	sltiu	v1,a2,10000
bfc00c1c:	1460ffb9 	bnez	v1,bfc00b04 <displayPattern+0x364>
bfc00c20:	00000000 	nop
bfc00c24:	8fa20004 	lw	v0,4(sp)
bfc00c28:	00000000 	nop
bfc00c2c:	24590001 	addiu	t9,v0,1
bfc00c30:	afb90004 	sw	t9,4(sp)
bfc00c34:	8fb80004 	lw	t8,4(sp)
bfc00c38:	00000000 	nop
bfc00c3c:	2f0f0064 	sltiu	t7,t8,100
bfc00c40:	15e0ffaa 	bnez	t7,bfc00aec <displayPattern+0x34c>
bfc00c44:	00000000 	nop
bfc00c48:	8fa80000 	lw	t0,0(sp)
bfc00c4c:	00000000 	nop
bfc00c50:	25070001 	addiu	a3,t0,1
bfc00c54:	afa70000 	sw	a3,0(sp)
bfc00c58:	8fa60000 	lw	a2,0(sp)
bfc00c5c:	00000000 	nop
bfc00c60:	28c30008 	slti	v1,a2,8
bfc00c64:	1460ff35 	bnez	v1,bfc0093c <displayPattern+0x19c>
bfc00c68:	00000000 	nop
bfc00c6c:	3404ffff 	li	a0,0xffff
bfc00c70:	ac04f000 	sw	a0,-4096(zero)
bfc00c74:	03e00008 	jr	ra
bfc00c78:	27bd0010 	addiu	sp,sp,16
bfc00c7c:	00000000 	nop

bfc00c80 <displayScore>:
displayScore():
bfc00c80:	27bdfff0 	addiu	sp,sp,-16
bfc00c84:	afa00004 	sw	zero,4(sp)
bfc00c88:	ac00f000 	sw	zero,-4096(zero)
bfc00c8c:	afa00008 	sw	zero,8(sp)
bfc00c90:	8fa30008 	lw	v1,8(sp)
bfc00c94:	00803021 	move	a2,a0
bfc00c98:	2c6200c8 	sltiu	v0,v1,200
bfc00c9c:	10400058 	beqz	v0,bfc00e00 <displayScore+0x180>
bfc00ca0:	00a03821 	move	a3,a1
bfc00ca4:	afa0000c 	sw	zero,12(sp)
bfc00ca8:	8fa5000c 	lw	a1,12(sp)
bfc00cac:	00000000 	nop
bfc00cb0:	2ca42710 	sltiu	a0,a1,10000
bfc00cb4:	10800049 	beqz	a0,bfc00ddc <displayScore+0x15c>
bfc00cb8:	00000000 	nop
bfc00cbc:	8fab000c 	lw	t3,12(sp)
bfc00cc0:	00000000 	nop
bfc00cc4:	256a0001 	addiu	t2,t3,1
bfc00cc8:	afaa000c 	sw	t2,12(sp)
bfc00ccc:	8fa9000c 	lw	t1,12(sp)
bfc00cd0:	00000000 	nop
bfc00cd4:	2d282710 	sltiu	t0,t1,10000
bfc00cd8:	11000040 	beqz	t0,bfc00ddc <displayScore+0x15c>
bfc00cdc:	00000000 	nop
bfc00ce0:	8fac000c 	lw	t4,12(sp)
bfc00ce4:	00000000 	nop
bfc00ce8:	258b0001 	addiu	t3,t4,1
bfc00cec:	afab000c 	sw	t3,12(sp)
bfc00cf0:	8faa000c 	lw	t2,12(sp)
bfc00cf4:	00000000 	nop
bfc00cf8:	2d492710 	sltiu	t1,t2,10000
bfc00cfc:	11200037 	beqz	t1,bfc00ddc <displayScore+0x15c>
bfc00d00:	00000000 	nop
bfc00d04:	8fb8000c 	lw	t8,12(sp)
bfc00d08:	00000000 	nop
bfc00d0c:	270f0001 	addiu	t7,t8,1
bfc00d10:	afaf000c 	sw	t7,12(sp)
bfc00d14:	8fae000c 	lw	t6,12(sp)
bfc00d18:	00000000 	nop
bfc00d1c:	2dcd2710 	sltiu	t5,t6,10000
bfc00d20:	11a0002e 	beqz	t5,bfc00ddc <displayScore+0x15c>
bfc00d24:	00000000 	nop
bfc00d28:	8fa8000c 	lw	t0,12(sp)
bfc00d2c:	00000000 	nop
bfc00d30:	25050001 	addiu	a1,t0,1
bfc00d34:	afa5000c 	sw	a1,12(sp)
bfc00d38:	8fa2000c 	lw	v0,12(sp)
bfc00d3c:	00000000 	nop
bfc00d40:	2c592710 	sltiu	t9,v0,10000
bfc00d44:	13200025 	beqz	t9,bfc00ddc <displayScore+0x15c>
bfc00d48:	00000000 	nop
bfc00d4c:	8faa000c 	lw	t2,12(sp)
bfc00d50:	00000000 	nop
bfc00d54:	25490001 	addiu	t1,t2,1
bfc00d58:	afa9000c 	sw	t1,12(sp)
bfc00d5c:	8fa4000c 	lw	a0,12(sp)
bfc00d60:	00000000 	nop
bfc00d64:	2c832710 	sltiu	v1,a0,10000
bfc00d68:	1060001c 	beqz	v1,bfc00ddc <displayScore+0x15c>
bfc00d6c:	00000000 	nop
bfc00d70:	8fae000c 	lw	t6,12(sp)
bfc00d74:	00000000 	nop
bfc00d78:	25cd0001 	addiu	t5,t6,1
bfc00d7c:	afad000c 	sw	t5,12(sp)
bfc00d80:	8fac000c 	lw	t4,12(sp)
bfc00d84:	00000000 	nop
bfc00d88:	2d8b2710 	sltiu	t3,t4,10000
bfc00d8c:	11600013 	beqz	t3,bfc00ddc <displayScore+0x15c>
bfc00d90:	00000000 	nop
bfc00d94:	8fa2000c 	lw	v0,12(sp)
bfc00d98:	00000000 	nop
bfc00d9c:	24590001 	addiu	t9,v0,1
bfc00da0:	afb9000c 	sw	t9,12(sp)
bfc00da4:	8fb8000c 	lw	t8,12(sp)
bfc00da8:	00000000 	nop
bfc00dac:	2f0f2710 	sltiu	t7,t8,10000
bfc00db0:	11e0000a 	beqz	t7,bfc00ddc <displayScore+0x15c>
bfc00db4:	00000000 	nop
bfc00db8:	8fa4000c 	lw	a0,12(sp)
bfc00dbc:	00000000 	nop
bfc00dc0:	24830001 	addiu	v1,a0,1
bfc00dc4:	afa3000c 	sw	v1,12(sp)
bfc00dc8:	8fa8000c 	lw	t0,12(sp)
bfc00dcc:	00000000 	nop
bfc00dd0:	2d052710 	sltiu	a1,t0,10000
bfc00dd4:	14a0ffb9 	bnez	a1,bfc00cbc <displayScore+0x3c>
bfc00dd8:	00000000 	nop
bfc00ddc:	8faf0008 	lw	t7,8(sp)
bfc00de0:	00000000 	nop
bfc00de4:	25ee0001 	addiu	t6,t7,1
bfc00de8:	afae0008 	sw	t6,8(sp)
bfc00dec:	8fad0008 	lw	t5,8(sp)
bfc00df0:	00000000 	nop
bfc00df4:	2dac00c8 	sltiu	t4,t5,200
bfc00df8:	1580ffaa 	bnez	t4,bfc00ca4 <displayScore+0x24>
bfc00dfc:	00000000 	nop
bfc00e00:	3402ffff 	li	v0,0xffff
bfc00e04:	ac02f000 	sw	v0,-4096(zero)
bfc00e08:	afa00000 	sw	zero,0(sp)
bfc00e0c:	8fb90000 	lw	t9,0(sp)
bfc00e10:	00000000 	nop
bfc00e14:	2b380008 	slti	t8,t9,8
bfc00e18:	1700000e 	bnez	t8,bfc00e54 <displayScore+0x1d4>
bfc00e1c:	00000000 	nop
bfc00e20:	0bf003ad 	j	bfc00eb4 <displayScore+0x234>
bfc00e24:	00000000 	nop
	...
bfc00e30:	8fa20000 	lw	v0,0(sp)
bfc00e34:	00000000 	nop
bfc00e38:	24590001 	addiu	t9,v0,1
bfc00e3c:	afb90000 	sw	t9,0(sp)
bfc00e40:	8fb80000 	lw	t8,0(sp)
bfc00e44:	00000000 	nop
bfc00e48:	2b0f0008 	slti	t7,t8,8
bfc00e4c:	11e00019 	beqz	t7,bfc00eb4 <displayScore+0x234>
bfc00e50:	00000000 	nop
bfc00e54:	8fac0000 	lw	t4,0(sp)
bfc00e58:	8fab0000 	lw	t3,0(sp)
bfc00e5c:	000c5080 	sll	t2,t4,0x2
bfc00e60:	000b4880 	sll	t1,t3,0x2
bfc00e64:	00ca4021 	addu	t0,a2,t2
bfc00e68:	00e91821 	addu	v1,a3,t1
bfc00e6c:	8d050000 	lw	a1,0(t0)
bfc00e70:	8c640000 	lw	a0,0(v1)
bfc00e74:	00000000 	nop
bfc00e78:	14a4ffed 	bne	a1,a0,bfc00e30 <displayScore+0x1b0>
bfc00e7c:	00000000 	nop
bfc00e80:	8fae0004 	lw	t6,4(sp)
bfc00e84:	00000000 	nop
bfc00e88:	25cd0001 	addiu	t5,t6,1
bfc00e8c:	afad0004 	sw	t5,4(sp)
bfc00e90:	8fa20000 	lw	v0,0(sp)
bfc00e94:	00000000 	nop
bfc00e98:	24590001 	addiu	t9,v0,1
bfc00e9c:	afb90000 	sw	t9,0(sp)
bfc00ea0:	8fb80000 	lw	t8,0(sp)
bfc00ea4:	00000000 	nop
bfc00ea8:	2b0f0008 	slti	t7,t8,8
bfc00eac:	15e0ffe9 	bnez	t7,bfc00e54 <displayScore+0x1d4>
bfc00eb0:	00000000 	nop
bfc00eb4:	8c03f010 	lw	v1,-4080(zero)
bfc00eb8:	8fa80004 	lw	t0,4(sp)
bfc00ebc:	24040001 	li	a0,1
bfc00ec0:	01032825 	or	a1,t0,v1
bfc00ec4:	ac05f010 	sw	a1,-4080(zero)
bfc00ec8:	ac04f004 	sw	a0,-4092(zero)
bfc00ecc:	8fa70004 	lw	a3,4(sp)
bfc00ed0:	24060008 	li	a2,8
bfc00ed4:	10e60006 	beq	a3,a2,bfc00ef0 <displayScore+0x270>
bfc00ed8:	00000000 	nop
bfc00edc:	24040002 	li	a0,2
bfc00ee0:	ac04f008 	sw	a0,-4088(zero)
bfc00ee4:	03e00008 	jr	ra
bfc00ee8:	27bd0010 	addiu	sp,sp,16
bfc00eec:	00000000 	nop
bfc00ef0:	ac04f008 	sw	a0,-4088(zero)
bfc00ef4:	03e00008 	jr	ra
bfc00ef8:	27bd0010 	addiu	sp,sp,16
bfc00efc:	00000000 	nop

bfc00f00 <my_rand>:
my_rand():
bfc00f00:	8f868010 	lw	a2,-32752(gp)
bfc00f04:	3c0741c6 	lui	a3,0x41c6
bfc00f08:	34e54e6d 	ori	a1,a3,0x4e6d
bfc00f0c:	00c50018 	mult	a2,a1
bfc00f10:	00002012 	mflo	a0
bfc00f14:	24833039 	addiu	v1,a0,12345
bfc00f18:	00031402 	srl	v0,v1,0x10
bfc00f1c:	af838010 	sw	v1,-32752(gp)
bfc00f20:	03e00008 	jr	ra
bfc00f24:	30427fff 	andi	v0,v0,0x7fff
	...

bfc00f30 <my_srand>:
my_srand():
bfc00f30:	03e00008 	jr	ra
bfc00f34:	af848010 	sw	a0,-32752(gp)
	...

bfc00f40 <generateRandomPattern>:
generateRandomPattern():
bfc00f40:	27bdfff8 	addiu	sp,sp,-8
bfc00f44:	afa00000 	sw	zero,0(sp)
bfc00f48:	8fa30000 	lw	v1,0(sp)
bfc00f4c:	00000000 	nop
bfc00f50:	28620008 	slti	v0,v1,8
bfc00f54:	10400031 	beqz	v0,bfc0101c <generateRandomPattern+0xdc>
bfc00f58:	00804821 	move	t1,a0
bfc00f5c:	3c0441c6 	lui	a0,0x41c6
bfc00f60:	8f868010 	lw	a2,-32752(gp)
bfc00f64:	34884e6d 	ori	t0,a0,0x4e6d
bfc00f68:	0bf003f1 	j	bfc00fc4 <generateRandomPattern+0x84>
bfc00f6c:	24070001 	li	a3,1
bfc00f70:	00c80018 	mult	a2,t0
bfc00f74:	00005812 	mflo	t3
bfc00f78:	25663039 	addiu	a2,t3,12345
bfc00f7c:	00065402 	srl	t2,a2,0x10
bfc00f80:	31440003 	andi	a0,t2,0x3
bfc00f84:	afa40004 	sw	a0,4(sp)
bfc00f88:	8fa30004 	lw	v1,4(sp)
bfc00f8c:	00000000 	nop
bfc00f90:	00671004 	sllv	v0,a3,v1
bfc00f94:	afa20004 	sw	v0,4(sp)
bfc00f98:	8fb90000 	lw	t9,0(sp)
bfc00f9c:	8fa50004 	lw	a1,4(sp)
bfc00fa0:	8fb80000 	lw	t8,0(sp)
bfc00fa4:	00197080 	sll	t6,t9,0x2
bfc00fa8:	270f0001 	addiu	t7,t8,1
bfc00fac:	afaf0000 	sw	t7,0(sp)
bfc00fb0:	8fad0000 	lw	t5,0(sp)
bfc00fb4:	012e6021 	addu	t4,t1,t6
bfc00fb8:	29ab0008 	slti	t3,t5,8
bfc00fbc:	11600016 	beqz	t3,bfc01018 <generateRandomPattern+0xd8>
bfc00fc0:	ad850000 	sw	a1,0(t4)
bfc00fc4:	00c80018 	mult	a2,t0
bfc00fc8:	00005012 	mflo	t2
bfc00fcc:	25463039 	addiu	a2,t2,12345
bfc00fd0:	00062402 	srl	a0,a2,0x10
bfc00fd4:	30830003 	andi	v1,a0,0x3
bfc00fd8:	afa30004 	sw	v1,4(sp)
bfc00fdc:	8fa20004 	lw	v0,4(sp)
bfc00fe0:	00000000 	nop
bfc00fe4:	0047c804 	sllv	t9,a3,v0
bfc00fe8:	afb90004 	sw	t9,4(sp)
bfc00fec:	8fb80000 	lw	t8,0(sp)
bfc00ff0:	8fa50004 	lw	a1,4(sp)
bfc00ff4:	8faf0000 	lw	t7,0(sp)
bfc00ff8:	00186880 	sll	t5,t8,0x2
bfc00ffc:	25ee0001 	addiu	t6,t7,1
bfc01000:	afae0000 	sw	t6,0(sp)
bfc01004:	8fac0000 	lw	t4,0(sp)
bfc01008:	012d5821 	addu	t3,t1,t5
bfc0100c:	298a0008 	slti	t2,t4,8
bfc01010:	1540ffd7 	bnez	t2,bfc00f70 <generateRandomPattern+0x30>
bfc01014:	ad650000 	sw	a1,0(t3)
bfc01018:	af868010 	sw	a2,-32752(gp)
bfc0101c:	03e00008 	jr	ra
bfc01020:	27bd0008 	addiu	sp,sp,8
	...

bfc01030 <detectKeyPresses>:
detectKeyPresses():
bfc01030:	27bdffe8 	addiu	sp,sp,-24
bfc01034:	afa00008 	sw	zero,8(sp)
bfc01038:	afa00004 	sw	zero,4(sp)
bfc0103c:	8fa30004 	lw	v1,4(sp)
bfc01040:	00000000 	nop
bfc01044:	28620008 	slti	v0,v1,8
bfc01048:	104000d8 	beqz	v0,bfc013ac <detectKeyPresses+0x37c>
bfc0104c:	00803021 	move	a2,a0
bfc01050:	3407ffff 	li	a3,0xffff
bfc01054:	8c09f024 	lw	t1,-4060(zero)
bfc01058:	00000000 	nop
bfc0105c:	3128f000 	andi	t0,t1,0xf000
bfc01060:	00082b02 	srl	a1,t0,0xc
bfc01064:	afa50010 	sw	a1,16(sp)
bfc01068:	8fa40010 	lw	a0,16(sp)
bfc0106c:	00000000 	nop
bfc01070:	1080fff8 	beqz	a0,bfc01054 <detectKeyPresses+0x24>
bfc01074:	00000000 	nop
bfc01078:	8faa0010 	lw	t2,16(sp)
bfc0107c:	00000000 	nop
bfc01080:	314f0001 	andi	t7,t2,0x1
bfc01084:	000a70c3 	sra	t6,t2,0x3
bfc01088:	000f60c0 	sll	t4,t7,0x3
bfc0108c:	31cd0001 	andi	t5,t6,0x1
bfc01090:	000a5842 	srl	t3,t2,0x1
bfc01094:	018d4825 	or	t1,t4,t5
bfc01098:	31650002 	andi	a1,t3,0x2
bfc0109c:	000a4040 	sll	t0,t2,0x1
bfc010a0:	01252025 	or	a0,t1,a1
bfc010a4:	31030004 	andi	v1,t0,0x4
bfc010a8:	00831025 	or	v0,a0,v1
bfc010ac:	afa20000 	sw	v0,0(sp)
bfc010b0:	8fb90004 	lw	t9,4(sp)
bfc010b4:	8fae0000 	lw	t6,0(sp)
bfc010b8:	8faf0000 	lw	t7,0(sp)
bfc010bc:	0019c080 	sll	t8,t9,0x2
bfc010c0:	00d86821 	addu	t5,a2,t8
bfc010c4:	000f6027 	nor	t4,zero,t7
bfc010c8:	adae0000 	sw	t6,0(t5)
bfc010cc:	ac0cf000 	sw	t4,-4096(zero)
bfc010d0:	afa00010 	sw	zero,16(sp)
bfc010d4:	8fab0010 	lw	t3,16(sp)
bfc010d8:	00000000 	nop
bfc010dc:	2d6a0064 	sltiu	t2,t3,100
bfc010e0:	11400058 	beqz	t2,bfc01244 <detectKeyPresses+0x214>
bfc010e4:	00000000 	nop
bfc010e8:	afa0000c 	sw	zero,12(sp)
bfc010ec:	8fb9000c 	lw	t9,12(sp)
bfc010f0:	00000000 	nop
bfc010f4:	2f382710 	sltiu	t8,t9,10000
bfc010f8:	13000049 	beqz	t8,bfc01220 <detectKeyPresses+0x1f0>
bfc010fc:	00000000 	nop
bfc01100:	8fa8000c 	lw	t0,12(sp)
bfc01104:	00000000 	nop
bfc01108:	25030001 	addiu	v1,t0,1
bfc0110c:	afa3000c 	sw	v1,12(sp)
bfc01110:	8fa4000c 	lw	a0,12(sp)
bfc01114:	00000000 	nop
bfc01118:	2c822710 	sltiu	v0,a0,10000
bfc0111c:	10400040 	beqz	v0,bfc01220 <detectKeyPresses+0x1f0>
bfc01120:	00000000 	nop
bfc01124:	8fa4000c 	lw	a0,12(sp)
bfc01128:	00000000 	nop
bfc0112c:	24820001 	addiu	v0,a0,1
bfc01130:	afa2000c 	sw	v0,12(sp)
bfc01134:	8fb9000c 	lw	t9,12(sp)
bfc01138:	00000000 	nop
bfc0113c:	2f382710 	sltiu	t8,t9,10000
bfc01140:	13000037 	beqz	t8,bfc01220 <detectKeyPresses+0x1f0>
bfc01144:	00000000 	nop
bfc01148:	8fa5000c 	lw	a1,12(sp)
bfc0114c:	00000000 	nop
bfc01150:	24a90001 	addiu	t1,a1,1
bfc01154:	afa9000c 	sw	t1,12(sp)
bfc01158:	8fa8000c 	lw	t0,12(sp)
bfc0115c:	00000000 	nop
bfc01160:	2d032710 	sltiu	v1,t0,10000
bfc01164:	1060002e 	beqz	v1,bfc01220 <detectKeyPresses+0x1f0>
bfc01168:	00000000 	nop
bfc0116c:	8fad000c 	lw	t5,12(sp)
bfc01170:	00000000 	nop
bfc01174:	25ac0001 	addiu	t4,t5,1
bfc01178:	afac000c 	sw	t4,12(sp)
bfc0117c:	8fab000c 	lw	t3,12(sp)
bfc01180:	00000000 	nop
bfc01184:	2d6a2710 	sltiu	t2,t3,10000
bfc01188:	11400025 	beqz	t2,bfc01220 <detectKeyPresses+0x1f0>
bfc0118c:	00000000 	nop
bfc01190:	8fb9000c 	lw	t9,12(sp)
bfc01194:	00000000 	nop
bfc01198:	27380001 	addiu	t8,t9,1
bfc0119c:	afb8000c 	sw	t8,12(sp)
bfc011a0:	8faf000c 	lw	t7,12(sp)
bfc011a4:	00000000 	nop
bfc011a8:	2dee2710 	sltiu	t6,t7,10000
bfc011ac:	11c0001c 	beqz	t6,bfc01220 <detectKeyPresses+0x1f0>
bfc011b0:	00000000 	nop
bfc011b4:	8fa8000c 	lw	t0,12(sp)
bfc011b8:	00000000 	nop
bfc011bc:	25030001 	addiu	v1,t0,1
bfc011c0:	afa3000c 	sw	v1,12(sp)
bfc011c4:	8fa4000c 	lw	a0,12(sp)
bfc011c8:	00000000 	nop
bfc011cc:	2c822710 	sltiu	v0,a0,10000
bfc011d0:	10400013 	beqz	v0,bfc01220 <detectKeyPresses+0x1f0>
bfc011d4:	00000000 	nop
bfc011d8:	8fab000c 	lw	t3,12(sp)
bfc011dc:	00000000 	nop
bfc011e0:	256a0001 	addiu	t2,t3,1
bfc011e4:	afaa000c 	sw	t2,12(sp)
bfc011e8:	8fa5000c 	lw	a1,12(sp)
bfc011ec:	00000000 	nop
bfc011f0:	2ca92710 	sltiu	t1,a1,10000
bfc011f4:	1120000a 	beqz	t1,bfc01220 <detectKeyPresses+0x1f0>
bfc011f8:	00000000 	nop
bfc011fc:	8faf000c 	lw	t7,12(sp)
bfc01200:	00000000 	nop
bfc01204:	25ee0001 	addiu	t6,t7,1
bfc01208:	afae000c 	sw	t6,12(sp)
bfc0120c:	8fad000c 	lw	t5,12(sp)
bfc01210:	00000000 	nop
bfc01214:	2dac2710 	sltiu	t4,t5,10000
bfc01218:	1580ffb9 	bnez	t4,bfc01100 <detectKeyPresses+0xd0>
bfc0121c:	00000000 	nop
bfc01220:	8fab0010 	lw	t3,16(sp)
bfc01224:	00000000 	nop
bfc01228:	256a0001 	addiu	t2,t3,1
bfc0122c:	afaa0010 	sw	t2,16(sp)
bfc01230:	8fa50010 	lw	a1,16(sp)
bfc01234:	00000000 	nop
bfc01238:	2ca90064 	sltiu	t1,a1,100
bfc0123c:	1520ffaa 	bnez	t1,bfc010e8 <detectKeyPresses+0xb8>
bfc01240:	00000000 	nop
bfc01244:	8c0ff024 	lw	t7,-4060(zero)
bfc01248:	00000000 	nop
bfc0124c:	31eef000 	andi	t6,t7,0xf000
bfc01250:	000e6b02 	srl	t5,t6,0xc
bfc01254:	afad000c 	sw	t5,12(sp)
bfc01258:	8fac000c 	lw	t4,12(sp)
bfc0125c:	00000000 	nop
bfc01260:	11800040 	beqz	t4,bfc01364 <detectKeyPresses+0x334>
bfc01264:	00000000 	nop
bfc01268:	8c04f024 	lw	a0,-4060(zero)
bfc0126c:	00000000 	nop
bfc01270:	3082f000 	andi	v0,a0,0xf000
bfc01274:	0002cb02 	srl	t9,v0,0xc
bfc01278:	afb9000c 	sw	t9,12(sp)
bfc0127c:	8fb8000c 	lw	t8,12(sp)
bfc01280:	00000000 	nop
bfc01284:	13000037 	beqz	t8,bfc01364 <detectKeyPresses+0x334>
bfc01288:	00000000 	nop
bfc0128c:	8c05f024 	lw	a1,-4060(zero)
bfc01290:	00000000 	nop
bfc01294:	30a9f000 	andi	t1,a1,0xf000
bfc01298:	00094302 	srl	t0,t1,0xc
bfc0129c:	afa8000c 	sw	t0,12(sp)
bfc012a0:	8fa3000c 	lw	v1,12(sp)
bfc012a4:	00000000 	nop
bfc012a8:	1060002e 	beqz	v1,bfc01364 <detectKeyPresses+0x334>
bfc012ac:	00000000 	nop
bfc012b0:	8c0df024 	lw	t5,-4060(zero)
bfc012b4:	00000000 	nop
bfc012b8:	31acf000 	andi	t4,t5,0xf000
bfc012bc:	000c5b02 	srl	t3,t4,0xc
bfc012c0:	afab000c 	sw	t3,12(sp)
bfc012c4:	8faa000c 	lw	t2,12(sp)
bfc012c8:	00000000 	nop
bfc012cc:	11400025 	beqz	t2,bfc01364 <detectKeyPresses+0x334>
bfc012d0:	00000000 	nop
bfc012d4:	8c19f024 	lw	t9,-4060(zero)
bfc012d8:	00000000 	nop
bfc012dc:	3338f000 	andi	t8,t9,0xf000
bfc012e0:	00187b02 	srl	t7,t8,0xc
bfc012e4:	afaf000c 	sw	t7,12(sp)
bfc012e8:	8fae000c 	lw	t6,12(sp)
bfc012ec:	00000000 	nop
bfc012f0:	11c0001c 	beqz	t6,bfc01364 <detectKeyPresses+0x334>
bfc012f4:	00000000 	nop
bfc012f8:	8c08f024 	lw	t0,-4060(zero)
bfc012fc:	00000000 	nop
bfc01300:	3103f000 	andi	v1,t0,0xf000
bfc01304:	00032302 	srl	a0,v1,0xc
bfc01308:	afa4000c 	sw	a0,12(sp)
bfc0130c:	8fa2000c 	lw	v0,12(sp)
bfc01310:	00000000 	nop
bfc01314:	10400013 	beqz	v0,bfc01364 <detectKeyPresses+0x334>
bfc01318:	00000000 	nop
bfc0131c:	8c0bf024 	lw	t3,-4060(zero)
bfc01320:	00000000 	nop
bfc01324:	316af000 	andi	t2,t3,0xf000
bfc01328:	000a2b02 	srl	a1,t2,0xc
bfc0132c:	afa5000c 	sw	a1,12(sp)
bfc01330:	8fa9000c 	lw	t1,12(sp)
bfc01334:	00000000 	nop
bfc01338:	1120000a 	beqz	t1,bfc01364 <detectKeyPresses+0x334>
bfc0133c:	00000000 	nop
bfc01340:	8c0ff024 	lw	t7,-4060(zero)
bfc01344:	00000000 	nop
bfc01348:	31eef000 	andi	t6,t7,0xf000
bfc0134c:	000e6b02 	srl	t5,t6,0xc
bfc01350:	afad000c 	sw	t5,12(sp)
bfc01354:	8fac000c 	lw	t4,12(sp)
bfc01358:	00000000 	nop
bfc0135c:	1580ffb9 	bnez	t4,bfc01244 <detectKeyPresses+0x214>
bfc01360:	00000000 	nop
bfc01364:	ac07f000 	sw	a3,-4096(zero)
bfc01368:	8fa50008 	lw	a1,8(sp)
bfc0136c:	00000000 	nop
bfc01370:	24a90001 	addiu	t1,a1,1
bfc01374:	afa90008 	sw	t1,8(sp)
bfc01378:	8fa80008 	lw	t0,8(sp)
bfc0137c:	00000000 	nop
bfc01380:	00081e00 	sll	v1,t0,0x18
bfc01384:	ac03f010 	sw	v1,-4080(zero)
bfc01388:	8fa40004 	lw	a0,4(sp)
bfc0138c:	00000000 	nop
bfc01390:	24820001 	addiu	v0,a0,1
bfc01394:	afa20004 	sw	v0,4(sp)
bfc01398:	8fb90004 	lw	t9,4(sp)
bfc0139c:	00000000 	nop
bfc013a0:	2b380008 	slti	t8,t9,8
bfc013a4:	1700ff2b 	bnez	t8,bfc01054 <detectKeyPresses+0x24>
bfc013a8:	00000000 	nop
bfc013ac:	afa0000c 	sw	zero,12(sp)
bfc013b0:	8fa7000c 	lw	a3,12(sp)
bfc013b4:	00000000 	nop
bfc013b8:	2ce6012c 	sltiu	a2,a3,300
bfc013bc:	10c00058 	beqz	a2,bfc01520 <detectKeyPresses+0x4f0>
bfc013c0:	00000000 	nop
bfc013c4:	afa00010 	sw	zero,16(sp)
bfc013c8:	8fab0010 	lw	t3,16(sp)
bfc013cc:	00000000 	nop
bfc013d0:	2d6a2710 	sltiu	t2,t3,10000
bfc013d4:	11400049 	beqz	t2,bfc014fc <detectKeyPresses+0x4cc>
bfc013d8:	00000000 	nop
bfc013dc:	8faf0010 	lw	t7,16(sp)
bfc013e0:	00000000 	nop
bfc013e4:	25ee0001 	addiu	t6,t7,1
bfc013e8:	afae0010 	sw	t6,16(sp)
bfc013ec:	8fad0010 	lw	t5,16(sp)
bfc013f0:	00000000 	nop
bfc013f4:	2dac2710 	sltiu	t4,t5,10000
bfc013f8:	11800040 	beqz	t4,bfc014fc <detectKeyPresses+0x4cc>
bfc013fc:	00000000 	nop
bfc01400:	8fa50010 	lw	a1,16(sp)
bfc01404:	00000000 	nop
bfc01408:	24a90001 	addiu	t1,a1,1
bfc0140c:	afa90010 	sw	t1,16(sp)
bfc01410:	8fa80010 	lw	t0,16(sp)
bfc01414:	00000000 	nop
bfc01418:	2d032710 	sltiu	v1,t0,10000
bfc0141c:	10600037 	beqz	v1,bfc014fc <detectKeyPresses+0x4cc>
bfc01420:	00000000 	nop
bfc01424:	8fab0010 	lw	t3,16(sp)
bfc01428:	00000000 	nop
bfc0142c:	256a0001 	addiu	t2,t3,1
bfc01430:	afaa0010 	sw	t2,16(sp)
bfc01434:	8fa70010 	lw	a3,16(sp)
bfc01438:	00000000 	nop
bfc0143c:	2ce62710 	sltiu	a2,a3,10000
bfc01440:	10c0002e 	beqz	a2,bfc014fc <detectKeyPresses+0x4cc>
bfc01444:	00000000 	nop
bfc01448:	8faf0010 	lw	t7,16(sp)
bfc0144c:	00000000 	nop
bfc01450:	25ee0001 	addiu	t6,t7,1
bfc01454:	afae0010 	sw	t6,16(sp)
bfc01458:	8fad0010 	lw	t5,16(sp)
bfc0145c:	00000000 	nop
bfc01460:	2dac2710 	sltiu	t4,t5,10000
bfc01464:	11800025 	beqz	t4,bfc014fc <detectKeyPresses+0x4cc>
bfc01468:	00000000 	nop
bfc0146c:	8fa40010 	lw	a0,16(sp)
bfc01470:	00000000 	nop
bfc01474:	24820001 	addiu	v0,a0,1
bfc01478:	afa20010 	sw	v0,16(sp)
bfc0147c:	8fb90010 	lw	t9,16(sp)
bfc01480:	00000000 	nop
bfc01484:	2f382710 	sltiu	t8,t9,10000
bfc01488:	1300001c 	beqz	t8,bfc014fc <detectKeyPresses+0x4cc>
bfc0148c:	00000000 	nop
bfc01490:	8fa50010 	lw	a1,16(sp)
bfc01494:	00000000 	nop
bfc01498:	24a90001 	addiu	t1,a1,1
bfc0149c:	afa90010 	sw	t1,16(sp)
bfc014a0:	8fa80010 	lw	t0,16(sp)
bfc014a4:	00000000 	nop
bfc014a8:	2d032710 	sltiu	v1,t0,10000
bfc014ac:	10600013 	beqz	v1,bfc014fc <detectKeyPresses+0x4cc>
bfc014b0:	00000000 	nop
bfc014b4:	8fab0010 	lw	t3,16(sp)
bfc014b8:	00000000 	nop
bfc014bc:	256a0001 	addiu	t2,t3,1
bfc014c0:	afaa0010 	sw	t2,16(sp)
bfc014c4:	8fa70010 	lw	a3,16(sp)
bfc014c8:	00000000 	nop
bfc014cc:	2ce62710 	sltiu	a2,a3,10000
bfc014d0:	10c0000a 	beqz	a2,bfc014fc <detectKeyPresses+0x4cc>
bfc014d4:	00000000 	nop
bfc014d8:	8faf0010 	lw	t7,16(sp)
bfc014dc:	00000000 	nop
bfc014e0:	25ee0001 	addiu	t6,t7,1
bfc014e4:	afae0010 	sw	t6,16(sp)
bfc014e8:	8fad0010 	lw	t5,16(sp)
bfc014ec:	00000000 	nop
bfc014f0:	2dac2710 	sltiu	t4,t5,10000
bfc014f4:	1580ffb9 	bnez	t4,bfc013dc <detectKeyPresses+0x3ac>
bfc014f8:	00000000 	nop
bfc014fc:	8fa4000c 	lw	a0,12(sp)
bfc01500:	00000000 	nop
bfc01504:	24820001 	addiu	v0,a0,1
bfc01508:	afa2000c 	sw	v0,12(sp)
bfc0150c:	8fb9000c 	lw	t9,12(sp)
bfc01510:	00000000 	nop
bfc01514:	2f38012c 	sltiu	t8,t9,300
bfc01518:	1700ffaa 	bnez	t8,bfc013c4 <detectKeyPresses+0x394>
bfc0151c:	00000000 	nop
bfc01520:	03e00008 	jr	ra
bfc01524:	27bd0018 	addiu	sp,sp,24
	...

bfc01530 <memory_game>:
memory_game():
bfc01530:	27bdff58 	addiu	sp,sp,-168
bfc01534:	3403ffff 	li	v1,0xffff
bfc01538:	afbf00a4 	sw	ra,164(sp)
bfc0153c:	ac03f000 	sw	v1,-4096(zero)
bfc01540:	0ff008ab 	jal	bfc022ac <get_count>
bfc01544:	00000000 	nop
bfc01548:	00403021 	move	a2,v0
bfc0154c:	af828010 	sw	v0,-32752(gp)
bfc01550:	3c0241c6 	lui	v0,0x41c6
bfc01554:	34494e6d 	ori	t1,v0,0x4e6d
bfc01558:	27a70024 	addiu	a3,sp,36
bfc0155c:	27a80060 	addiu	t0,sp,96
bfc01560:	240a0001 	li	t2,1
bfc01564:	340bffff 	li	t3,0xffff
bfc01568:	240c0008 	li	t4,8
bfc0156c:	240d0002 	li	t5,2
bfc01570:	8c0ff024 	lw	t7,-4060(zero)
bfc01574:	00000000 	nop
bfc01578:	31eef000 	andi	t6,t7,0xf000
bfc0157c:	000e2b02 	srl	a1,t6,0xc
bfc01580:	afa50020 	sw	a1,32(sp)
bfc01584:	8fa40020 	lw	a0,32(sp)
bfc01588:	00000000 	nop
bfc0158c:	1080fff8 	beqz	a0,bfc01570 <memory_game+0x40>
bfc01590:	00000000 	nop
bfc01594:	8fa20020 	lw	v0,32(sp)
bfc01598:	afa00020 	sw	zero,32(sp)
bfc0159c:	8fb90020 	lw	t9,32(sp)
bfc015a0:	00000000 	nop
bfc015a4:	2b380008 	slti	t8,t9,8
bfc015a8:	1700001c 	bnez	t8,bfc0161c <memory_game+0xec>
bfc015ac:	00c90018 	mult	a2,t1
bfc015b0:	0bf0059e 	j	bfc01678 <memory_game+0x148>
bfc015b4:	00000000 	nop
	...
bfc015c0:	0000f812 	mflo	ra
bfc015c4:	27e63039 	addiu	a2,ra,12345
bfc015c8:	0006cc02 	srl	t9,a2,0x10
bfc015cc:	33250003 	andi	a1,t9,0x3
bfc015d0:	afa5001c 	sw	a1,28(sp)
bfc015d4:	8fb8001c 	lw	t8,28(sp)
bfc015d8:	00000000 	nop
bfc015dc:	030a1804 	sllv	v1,t2,t8
bfc015e0:	afa3001c 	sw	v1,28(sp)
bfc015e4:	8faf0020 	lw	t7,32(sp)
bfc015e8:	8fa2001c 	lw	v0,28(sp)
bfc015ec:	000f7080 	sll	t6,t7,0x2
bfc015f0:	01c72021 	addu	a0,t6,a3
bfc015f4:	ac820000 	sw	v0,0(a0)
bfc015f8:	8fbf0020 	lw	ra,32(sp)
bfc015fc:	00000000 	nop
bfc01600:	27f90001 	addiu	t9,ra,1
bfc01604:	afb90020 	sw	t9,32(sp)
bfc01608:	8fa50020 	lw	a1,32(sp)
bfc0160c:	00000000 	nop
bfc01610:	28b80008 	slti	t8,a1,8
bfc01614:	13000018 	beqz	t8,bfc01678 <memory_game+0x148>
bfc01618:	00c90018 	mult	a2,t1
bfc0161c:	00002012 	mflo	a0
bfc01620:	24863039 	addiu	a2,a0,12345
bfc01624:	00061c02 	srl	v1,a2,0x10
bfc01628:	30620003 	andi	v0,v1,0x3
bfc0162c:	afa2001c 	sw	v0,28(sp)
bfc01630:	8fbf001c 	lw	ra,28(sp)
bfc01634:	00000000 	nop
bfc01638:	03eac804 	sllv	t9,t2,ra
bfc0163c:	afb9001c 	sw	t9,28(sp)
bfc01640:	8fb80020 	lw	t8,32(sp)
bfc01644:	8fa5001c 	lw	a1,28(sp)
bfc01648:	00187880 	sll	t7,t8,0x2
bfc0164c:	01e77021 	addu	t6,t7,a3
bfc01650:	adc50000 	sw	a1,0(t6)
bfc01654:	8fa40020 	lw	a0,32(sp)
bfc01658:	00000000 	nop
bfc0165c:	24830001 	addiu	v1,a0,1
bfc01660:	afa30020 	sw	v1,32(sp)
bfc01664:	8fa20020 	lw	v0,32(sp)
bfc01668:	00000000 	nop
bfc0166c:	285f0008 	slti	ra,v0,8
bfc01670:	17e0ffd3 	bnez	ra,bfc015c0 <memory_game+0x90>
bfc01674:	00c90018 	mult	a2,t1
bfc01678:	ac0bf000 	sw	t3,-4096(zero)
bfc0167c:	afa00020 	sw	zero,32(sp)
bfc01680:	8fae0020 	lw	t6,32(sp)
bfc01684:	00000000 	nop
bfc01688:	2dc501f4 	sltiu	a1,t6,500
bfc0168c:	10a00058 	beqz	a1,bfc017f0 <memory_game+0x2c0>
bfc01690:	00000000 	nop
bfc01694:	afa00010 	sw	zero,16(sp)
bfc01698:	8fb80010 	lw	t8,16(sp)
bfc0169c:	00000000 	nop
bfc016a0:	2f0f2710 	sltiu	t7,t8,10000
bfc016a4:	11e00049 	beqz	t7,bfc017cc <memory_game+0x29c>
bfc016a8:	00000000 	nop
bfc016ac:	8fa30010 	lw	v1,16(sp)
bfc016b0:	00000000 	nop
bfc016b4:	24620001 	addiu	v0,v1,1
bfc016b8:	afa20010 	sw	v0,16(sp)
bfc016bc:	8fbf0010 	lw	ra,16(sp)
bfc016c0:	00000000 	nop
bfc016c4:	2ff92710 	sltiu	t9,ra,10000
bfc016c8:	13200040 	beqz	t9,bfc017cc <memory_game+0x29c>
bfc016cc:	00000000 	nop
bfc016d0:	8fb90010 	lw	t9,16(sp)
bfc016d4:	00000000 	nop
bfc016d8:	27250001 	addiu	a1,t9,1
bfc016dc:	afa50010 	sw	a1,16(sp)
bfc016e0:	8fb80010 	lw	t8,16(sp)
bfc016e4:	00000000 	nop
bfc016e8:	2f032710 	sltiu	v1,t8,10000
bfc016ec:	10600037 	beqz	v1,bfc017cc <memory_game+0x29c>
bfc016f0:	00000000 	nop
bfc016f4:	8fae0010 	lw	t6,16(sp)
bfc016f8:	00000000 	nop
bfc016fc:	25c20001 	addiu	v0,t6,1
bfc01700:	afa20010 	sw	v0,16(sp)
bfc01704:	8fa40010 	lw	a0,16(sp)
bfc01708:	00000000 	nop
bfc0170c:	2c9f2710 	sltiu	ra,a0,10000
bfc01710:	13e0002e 	beqz	ra,bfc017cc <memory_game+0x29c>
bfc01714:	00000000 	nop
bfc01718:	8fa50010 	lw	a1,16(sp)
bfc0171c:	00000000 	nop
bfc01720:	24b80001 	addiu	t8,a1,1
bfc01724:	afb80010 	sw	t8,16(sp)
bfc01728:	8fa30010 	lw	v1,16(sp)
bfc0172c:	00000000 	nop
bfc01730:	2c6f2710 	sltiu	t7,v1,10000
bfc01734:	11e00025 	beqz	t7,bfc017cc <memory_game+0x29c>
bfc01738:	00000000 	nop
bfc0173c:	8fa20010 	lw	v0,16(sp)
bfc01740:	00000000 	nop
bfc01744:	24440001 	addiu	a0,v0,1
bfc01748:	afa40010 	sw	a0,16(sp)
bfc0174c:	8fbf0010 	lw	ra,16(sp)
bfc01750:	00000000 	nop
bfc01754:	2ff92710 	sltiu	t9,ra,10000
bfc01758:	1320001c 	beqz	t9,bfc017cc <memory_game+0x29c>
bfc0175c:	00000000 	nop
bfc01760:	8fb80010 	lw	t8,16(sp)
bfc01764:	00000000 	nop
bfc01768:	27030001 	addiu	v1,t8,1
bfc0176c:	afa30010 	sw	v1,16(sp)
bfc01770:	8faf0010 	lw	t7,16(sp)
bfc01774:	00000000 	nop
bfc01778:	2dee2710 	sltiu	t6,t7,10000
bfc0177c:	11c00013 	beqz	t6,bfc017cc <memory_game+0x29c>
bfc01780:	00000000 	nop
bfc01784:	8fa40010 	lw	a0,16(sp)
bfc01788:	00000000 	nop
bfc0178c:	249f0001 	addiu	ra,a0,1
bfc01790:	afbf0010 	sw	ra,16(sp)
bfc01794:	8fb90010 	lw	t9,16(sp)
bfc01798:	00000000 	nop
bfc0179c:	2f252710 	sltiu	a1,t9,10000
bfc017a0:	10a0000a 	beqz	a1,bfc017cc <memory_game+0x29c>
bfc017a4:	00000000 	nop
bfc017a8:	8fa30010 	lw	v1,16(sp)
bfc017ac:	00000000 	nop
bfc017b0:	246f0001 	addiu	t7,v1,1
bfc017b4:	afaf0010 	sw	t7,16(sp)
bfc017b8:	8fae0010 	lw	t6,16(sp)
bfc017bc:	00000000 	nop
bfc017c0:	2dc22710 	sltiu	v0,t6,10000
bfc017c4:	1440ffb9 	bnez	v0,bfc016ac <memory_game+0x17c>
bfc017c8:	00000000 	nop
bfc017cc:	8faf0020 	lw	t7,32(sp)
bfc017d0:	00000000 	nop
bfc017d4:	25ee0001 	addiu	t6,t7,1
bfc017d8:	afae0020 	sw	t6,32(sp)
bfc017dc:	8fa50020 	lw	a1,32(sp)
bfc017e0:	00000000 	nop
bfc017e4:	2ca401f4 	sltiu	a0,a1,500
bfc017e8:	1480ffaa 	bnez	a0,bfc01694 <memory_game+0x164>
bfc017ec:	00000000 	nop
bfc017f0:	afa0001c 	sw	zero,28(sp)
bfc017f4:	8fb9001c 	lw	t9,28(sp)
bfc017f8:	00000000 	nop
bfc017fc:	2b380008 	slti	t8,t9,8
bfc01800:	130000cd 	beqz	t8,bfc01b38 <memory_game+0x608>
bfc01804:	00000000 	nop
bfc01808:	8faf001c 	lw	t7,28(sp)
bfc0180c:	00000000 	nop
bfc01810:	000f7080 	sll	t6,t7,0x2
bfc01814:	01c72821 	addu	a1,t6,a3
bfc01818:	8ca40000 	lw	a0,0(a1)
bfc0181c:	00000000 	nop
bfc01820:	00041827 	nor	v1,zero,a0
bfc01824:	ac03f000 	sw	v1,-4096(zero)
bfc01828:	afa00010 	sw	zero,16(sp)
bfc0182c:	8fa20010 	lw	v0,16(sp)
bfc01830:	00000000 	nop
bfc01834:	2c5f00c8 	sltiu	ra,v0,200
bfc01838:	13e00058 	beqz	ra,bfc0199c <memory_game+0x46c>
bfc0183c:	00000000 	nop
bfc01840:	afa00020 	sw	zero,32(sp)
bfc01844:	8fb90020 	lw	t9,32(sp)
bfc01848:	00000000 	nop
bfc0184c:	2f382710 	sltiu	t8,t9,10000
bfc01850:	13000049 	beqz	t8,bfc01978 <memory_game+0x448>
bfc01854:	00000000 	nop
bfc01858:	8fa40020 	lw	a0,32(sp)
bfc0185c:	00000000 	nop
bfc01860:	24830001 	addiu	v1,a0,1
bfc01864:	afa30020 	sw	v1,32(sp)
bfc01868:	8fa20020 	lw	v0,32(sp)
bfc0186c:	00000000 	nop
bfc01870:	2c5f2710 	sltiu	ra,v0,10000
bfc01874:	13e00040 	beqz	ra,bfc01978 <memory_game+0x448>
bfc01878:	00000000 	nop
bfc0187c:	8fa50020 	lw	a1,32(sp)
bfc01880:	00000000 	nop
bfc01884:	24b80001 	addiu	t8,a1,1
bfc01888:	afb80020 	sw	t8,32(sp)
bfc0188c:	8fa30020 	lw	v1,32(sp)
bfc01890:	00000000 	nop
bfc01894:	2c6f2710 	sltiu	t7,v1,10000
bfc01898:	11e00037 	beqz	t7,bfc01978 <memory_game+0x448>
bfc0189c:	00000000 	nop
bfc018a0:	8fa20020 	lw	v0,32(sp)
bfc018a4:	00000000 	nop
bfc018a8:	24440001 	addiu	a0,v0,1
bfc018ac:	afa40020 	sw	a0,32(sp)
bfc018b0:	8fbf0020 	lw	ra,32(sp)
bfc018b4:	00000000 	nop
bfc018b8:	2ff92710 	sltiu	t9,ra,10000
bfc018bc:	1320002e 	beqz	t9,bfc01978 <memory_game+0x448>
bfc018c0:	00000000 	nop
bfc018c4:	8fb80020 	lw	t8,32(sp)
bfc018c8:	00000000 	nop
bfc018cc:	27030001 	addiu	v1,t8,1
bfc018d0:	afa30020 	sw	v1,32(sp)
bfc018d4:	8faf0020 	lw	t7,32(sp)
bfc018d8:	00000000 	nop
bfc018dc:	2dee2710 	sltiu	t6,t7,10000
bfc018e0:	11c00025 	beqz	t6,bfc01978 <memory_game+0x448>
bfc018e4:	00000000 	nop
bfc018e8:	8fa40020 	lw	a0,32(sp)
bfc018ec:	00000000 	nop
bfc018f0:	249f0001 	addiu	ra,a0,1
bfc018f4:	afbf0020 	sw	ra,32(sp)
bfc018f8:	8fb90020 	lw	t9,32(sp)
bfc018fc:	00000000 	nop
bfc01900:	2f252710 	sltiu	a1,t9,10000
bfc01904:	10a0001c 	beqz	a1,bfc01978 <memory_game+0x448>
bfc01908:	00000000 	nop
bfc0190c:	8fa30020 	lw	v1,32(sp)
bfc01910:	00000000 	nop
bfc01914:	246f0001 	addiu	t7,v1,1
bfc01918:	afaf0020 	sw	t7,32(sp)
bfc0191c:	8fae0020 	lw	t6,32(sp)
bfc01920:	00000000 	nop
bfc01924:	2dc22710 	sltiu	v0,t6,10000
bfc01928:	10400013 	beqz	v0,bfc01978 <memory_game+0x448>
bfc0192c:	00000000 	nop
bfc01930:	8fbf0020 	lw	ra,32(sp)
bfc01934:	00000000 	nop
bfc01938:	27f90001 	addiu	t9,ra,1
bfc0193c:	afb90020 	sw	t9,32(sp)
bfc01940:	8fa50020 	lw	a1,32(sp)
bfc01944:	00000000 	nop
bfc01948:	2cb82710 	sltiu	t8,a1,10000
bfc0194c:	1300000a 	beqz	t8,bfc01978 <memory_game+0x448>
bfc01950:	00000000 	nop
bfc01954:	8faf0020 	lw	t7,32(sp)
bfc01958:	00000000 	nop
bfc0195c:	25ee0001 	addiu	t6,t7,1
bfc01960:	afae0020 	sw	t6,32(sp)
bfc01964:	8fa20020 	lw	v0,32(sp)
bfc01968:	00000000 	nop
bfc0196c:	2c442710 	sltiu	a0,v0,10000
bfc01970:	1480ffb9 	bnez	a0,bfc01858 <memory_game+0x328>
bfc01974:	00000000 	nop
bfc01978:	8fb80010 	lw	t8,16(sp)
bfc0197c:	00000000 	nop
bfc01980:	270f0001 	addiu	t7,t8,1
bfc01984:	afaf0010 	sw	t7,16(sp)
bfc01988:	8fae0010 	lw	t6,16(sp)
bfc0198c:	00000000 	nop
bfc01990:	2dc500c8 	sltiu	a1,t6,200
bfc01994:	14a0ffaa 	bnez	a1,bfc01840 <memory_game+0x310>
bfc01998:	00000000 	nop
bfc0199c:	ac0bf000 	sw	t3,-4096(zero)
bfc019a0:	afa00020 	sw	zero,32(sp)
bfc019a4:	8fbf0020 	lw	ra,32(sp)
bfc019a8:	00000000 	nop
bfc019ac:	2ff90064 	sltiu	t9,ra,100
bfc019b0:	13200058 	beqz	t9,bfc01b14 <memory_game+0x5e4>
bfc019b4:	00000000 	nop
bfc019b8:	afa00010 	sw	zero,16(sp)
bfc019bc:	8fa30010 	lw	v1,16(sp)
bfc019c0:	00000000 	nop
bfc019c4:	2c622710 	sltiu	v0,v1,10000
bfc019c8:	10400049 	beqz	v0,bfc01af0 <memory_game+0x5c0>
bfc019cc:	00000000 	nop
bfc019d0:	8faf0010 	lw	t7,16(sp)
bfc019d4:	00000000 	nop
bfc019d8:	25ee0001 	addiu	t6,t7,1
bfc019dc:	afae0010 	sw	t6,16(sp)
bfc019e0:	8fa50010 	lw	a1,16(sp)
bfc019e4:	00000000 	nop
bfc019e8:	2ca42710 	sltiu	a0,a1,10000
bfc019ec:	10800040 	beqz	a0,bfc01af0 <memory_game+0x5c0>
bfc019f0:	00000000 	nop
bfc019f4:	8fb80010 	lw	t8,16(sp)
bfc019f8:	00000000 	nop
bfc019fc:	27030001 	addiu	v1,t8,1
bfc01a00:	afa30010 	sw	v1,16(sp)
bfc01a04:	8faf0010 	lw	t7,16(sp)
bfc01a08:	00000000 	nop
bfc01a0c:	2dee2710 	sltiu	t6,t7,10000
bfc01a10:	11c00037 	beqz	t6,bfc01af0 <memory_game+0x5c0>
bfc01a14:	00000000 	nop
bfc01a18:	8fa40010 	lw	a0,16(sp)
bfc01a1c:	00000000 	nop
bfc01a20:	249f0001 	addiu	ra,a0,1
bfc01a24:	afbf0010 	sw	ra,16(sp)
bfc01a28:	8fb90010 	lw	t9,16(sp)
bfc01a2c:	00000000 	nop
bfc01a30:	2f252710 	sltiu	a1,t9,10000
bfc01a34:	10a0002e 	beqz	a1,bfc01af0 <memory_game+0x5c0>
bfc01a38:	00000000 	nop
bfc01a3c:	8fa30010 	lw	v1,16(sp)
bfc01a40:	00000000 	nop
bfc01a44:	246f0001 	addiu	t7,v1,1
bfc01a48:	afaf0010 	sw	t7,16(sp)
bfc01a4c:	8fae0010 	lw	t6,16(sp)
bfc01a50:	00000000 	nop
bfc01a54:	2dc22710 	sltiu	v0,t6,10000
bfc01a58:	10400025 	beqz	v0,bfc01af0 <memory_game+0x5c0>
bfc01a5c:	00000000 	nop
bfc01a60:	8fbf0010 	lw	ra,16(sp)
bfc01a64:	00000000 	nop
bfc01a68:	27f90001 	addiu	t9,ra,1
bfc01a6c:	afb90010 	sw	t9,16(sp)
bfc01a70:	8fa50010 	lw	a1,16(sp)
bfc01a74:	00000000 	nop
bfc01a78:	2cb82710 	sltiu	t8,a1,10000
bfc01a7c:	1300001c 	beqz	t8,bfc01af0 <memory_game+0x5c0>
bfc01a80:	00000000 	nop
bfc01a84:	8faf0010 	lw	t7,16(sp)
bfc01a88:	00000000 	nop
bfc01a8c:	25ee0001 	addiu	t6,t7,1
bfc01a90:	afae0010 	sw	t6,16(sp)
bfc01a94:	8fa20010 	lw	v0,16(sp)
bfc01a98:	00000000 	nop
bfc01a9c:	2c442710 	sltiu	a0,v0,10000
bfc01aa0:	10800013 	beqz	a0,bfc01af0 <memory_game+0x5c0>
bfc01aa4:	00000000 	nop
bfc01aa8:	8fb90010 	lw	t9,16(sp)
bfc01aac:	00000000 	nop
bfc01ab0:	27250001 	addiu	a1,t9,1
bfc01ab4:	afa50010 	sw	a1,16(sp)
bfc01ab8:	8fb80010 	lw	t8,16(sp)
bfc01abc:	00000000 	nop
bfc01ac0:	2f032710 	sltiu	v1,t8,10000
bfc01ac4:	1060000a 	beqz	v1,bfc01af0 <memory_game+0x5c0>
bfc01ac8:	00000000 	nop
bfc01acc:	8fae0010 	lw	t6,16(sp)
bfc01ad0:	00000000 	nop
bfc01ad4:	25c20001 	addiu	v0,t6,1
bfc01ad8:	afa20010 	sw	v0,16(sp)
bfc01adc:	8fa40010 	lw	a0,16(sp)
bfc01ae0:	00000000 	nop
bfc01ae4:	2c9f2710 	sltiu	ra,a0,10000
bfc01ae8:	17e0ffb9 	bnez	ra,bfc019d0 <memory_game+0x4a0>
bfc01aec:	00000000 	nop
bfc01af0:	8fa20020 	lw	v0,32(sp)
bfc01af4:	00000000 	nop
bfc01af8:	245f0001 	addiu	ra,v0,1
bfc01afc:	afbf0020 	sw	ra,32(sp)
bfc01b00:	8fb90020 	lw	t9,32(sp)
bfc01b04:	00000000 	nop
bfc01b08:	2f380064 	sltiu	t8,t9,100
bfc01b0c:	1700ffaa 	bnez	t8,bfc019b8 <memory_game+0x488>
bfc01b10:	00000000 	nop
bfc01b14:	8fae001c 	lw	t6,28(sp)
bfc01b18:	00000000 	nop
bfc01b1c:	25c50001 	addiu	a1,t6,1
bfc01b20:	afa5001c 	sw	a1,28(sp)
bfc01b24:	8fa4001c 	lw	a0,28(sp)
bfc01b28:	00000000 	nop
bfc01b2c:	28830008 	slti	v1,a0,8
bfc01b30:	1460ff35 	bnez	v1,bfc01808 <memory_game+0x2d8>
bfc01b34:	00000000 	nop
bfc01b38:	ac0bf000 	sw	t3,-4096(zero)
bfc01b3c:	afa0001c 	sw	zero,28(sp)
bfc01b40:	afa00020 	sw	zero,32(sp)
bfc01b44:	8fb80020 	lw	t8,32(sp)
bfc01b48:	00000000 	nop
bfc01b4c:	2b0f0008 	slti	t7,t8,8
bfc01b50:	11e000d8 	beqz	t7,bfc01eb4 <memory_game+0x984>
bfc01b54:	00000000 	nop
bfc01b58:	8c03f024 	lw	v1,-4060(zero)
bfc01b5c:	00000000 	nop
bfc01b60:	3062f000 	andi	v0,v1,0xf000
bfc01b64:	0002fb02 	srl	ra,v0,0xc
bfc01b68:	afbf0014 	sw	ra,20(sp)
bfc01b6c:	8fb90014 	lw	t9,20(sp)
bfc01b70:	00000000 	nop
bfc01b74:	1320fff8 	beqz	t9,bfc01b58 <memory_game+0x628>
bfc01b78:	00000000 	nop
bfc01b7c:	8fb90014 	lw	t9,20(sp)
bfc01b80:	00000000 	nop
bfc01b84:	33230001 	andi	v1,t9,0x1
bfc01b88:	001970c3 	sra	t6,t9,0x3
bfc01b8c:	000310c0 	sll	v0,v1,0x3
bfc01b90:	31c40001 	andi	a0,t6,0x1
bfc01b94:	0019f842 	srl	ra,t9,0x1
bfc01b98:	0044c025 	or	t8,v0,a0
bfc01b9c:	33e50002 	andi	a1,ra,0x2
bfc01ba0:	00197840 	sll	t7,t9,0x1
bfc01ba4:	03057025 	or	t6,t8,a1
bfc01ba8:	31e30004 	andi	v1,t7,0x4
bfc01bac:	01c32025 	or	a0,t6,v1
bfc01bb0:	afa40010 	sw	a0,16(sp)
bfc01bb4:	8fa20020 	lw	v0,32(sp)
bfc01bb8:	8fb90010 	lw	t9,16(sp)
bfc01bbc:	0002f880 	sll	ra,v0,0x2
bfc01bc0:	03e8c021 	addu	t8,ra,t0
bfc01bc4:	af190000 	sw	t9,0(t8)
bfc01bc8:	8faf0010 	lw	t7,16(sp)
bfc01bcc:	00000000 	nop
bfc01bd0:	000f7027 	nor	t6,zero,t7
bfc01bd4:	ac0ef000 	sw	t6,-4096(zero)
bfc01bd8:	afa00014 	sw	zero,20(sp)
bfc01bdc:	8fa50014 	lw	a1,20(sp)
bfc01be0:	00000000 	nop
bfc01be4:	2ca40064 	sltiu	a0,a1,100
bfc01be8:	10800058 	beqz	a0,bfc01d4c <memory_game+0x81c>
bfc01bec:	00000000 	nop
bfc01bf0:	afa00018 	sw	zero,24(sp)
bfc01bf4:	8fb80018 	lw	t8,24(sp)
bfc01bf8:	00000000 	nop
bfc01bfc:	2f0f2710 	sltiu	t7,t8,10000
bfc01c00:	11e00049 	beqz	t7,bfc01d28 <memory_game+0x7f8>
bfc01c04:	00000000 	nop
bfc01c08:	8fa20018 	lw	v0,24(sp)
bfc01c0c:	00000000 	nop
bfc01c10:	245f0001 	addiu	ra,v0,1
bfc01c14:	afbf0018 	sw	ra,24(sp)
bfc01c18:	8fb90018 	lw	t9,24(sp)
bfc01c1c:	00000000 	nop
bfc01c20:	2f252710 	sltiu	a1,t9,10000
bfc01c24:	10a00040 	beqz	a1,bfc01d28 <memory_game+0x7f8>
bfc01c28:	00000000 	nop
bfc01c2c:	8fa30018 	lw	v1,24(sp)
bfc01c30:	00000000 	nop
bfc01c34:	246f0001 	addiu	t7,v1,1
bfc01c38:	afaf0018 	sw	t7,24(sp)
bfc01c3c:	8fae0018 	lw	t6,24(sp)
bfc01c40:	00000000 	nop
bfc01c44:	2dc22710 	sltiu	v0,t6,10000
bfc01c48:	10400037 	beqz	v0,bfc01d28 <memory_game+0x7f8>
bfc01c4c:	00000000 	nop
bfc01c50:	8fbf0018 	lw	ra,24(sp)
bfc01c54:	00000000 	nop
bfc01c58:	27f90001 	addiu	t9,ra,1
bfc01c5c:	afb90018 	sw	t9,24(sp)
bfc01c60:	8fa50018 	lw	a1,24(sp)
bfc01c64:	00000000 	nop
bfc01c68:	2cb82710 	sltiu	t8,a1,10000
bfc01c6c:	1300002e 	beqz	t8,bfc01d28 <memory_game+0x7f8>
bfc01c70:	00000000 	nop
bfc01c74:	8faf0018 	lw	t7,24(sp)
bfc01c78:	00000000 	nop
bfc01c7c:	25ee0001 	addiu	t6,t7,1
bfc01c80:	afae0018 	sw	t6,24(sp)
bfc01c84:	8fa20018 	lw	v0,24(sp)
bfc01c88:	00000000 	nop
bfc01c8c:	2c442710 	sltiu	a0,v0,10000
bfc01c90:	10800025 	beqz	a0,bfc01d28 <memory_game+0x7f8>
bfc01c94:	00000000 	nop
bfc01c98:	8fb90018 	lw	t9,24(sp)
bfc01c9c:	00000000 	nop
bfc01ca0:	27250001 	addiu	a1,t9,1
bfc01ca4:	afa50018 	sw	a1,24(sp)
bfc01ca8:	8fb80018 	lw	t8,24(sp)
bfc01cac:	00000000 	nop
bfc01cb0:	2f032710 	sltiu	v1,t8,10000
bfc01cb4:	1060001c 	beqz	v1,bfc01d28 <memory_game+0x7f8>
bfc01cb8:	00000000 	nop
bfc01cbc:	8fae0018 	lw	t6,24(sp)
bfc01cc0:	00000000 	nop
bfc01cc4:	25c20001 	addiu	v0,t6,1
bfc01cc8:	afa20018 	sw	v0,24(sp)
bfc01ccc:	8fa40018 	lw	a0,24(sp)
bfc01cd0:	00000000 	nop
bfc01cd4:	2c9f2710 	sltiu	ra,a0,10000
bfc01cd8:	13e00013 	beqz	ra,bfc01d28 <memory_game+0x7f8>
bfc01cdc:	00000000 	nop
bfc01ce0:	8fa50018 	lw	a1,24(sp)
bfc01ce4:	00000000 	nop
bfc01ce8:	24b80001 	addiu	t8,a1,1
bfc01cec:	afb80018 	sw	t8,24(sp)
bfc01cf0:	8fa30018 	lw	v1,24(sp)
bfc01cf4:	00000000 	nop
bfc01cf8:	2c6f2710 	sltiu	t7,v1,10000
bfc01cfc:	11e0000a 	beqz	t7,bfc01d28 <memory_game+0x7f8>
bfc01d00:	00000000 	nop
bfc01d04:	8fa20018 	lw	v0,24(sp)
bfc01d08:	00000000 	nop
bfc01d0c:	24440001 	addiu	a0,v0,1
bfc01d10:	afa40018 	sw	a0,24(sp)
bfc01d14:	8fbf0018 	lw	ra,24(sp)
bfc01d18:	00000000 	nop
bfc01d1c:	2ff92710 	sltiu	t9,ra,10000
bfc01d20:	1720ffb9 	bnez	t9,bfc01c08 <memory_game+0x6d8>
bfc01d24:	00000000 	nop
bfc01d28:	8faf0014 	lw	t7,20(sp)
bfc01d2c:	00000000 	nop
bfc01d30:	25e30001 	addiu	v1,t7,1
bfc01d34:	afa30014 	sw	v1,20(sp)
bfc01d38:	8fae0014 	lw	t6,20(sp)
bfc01d3c:	00000000 	nop
bfc01d40:	2dc40064 	sltiu	a0,t6,100
bfc01d44:	1480ffaa 	bnez	a0,bfc01bf0 <memory_game+0x6c0>
bfc01d48:	00000000 	nop
bfc01d4c:	8c1ff024 	lw	ra,-4060(zero)
bfc01d50:	00000000 	nop
bfc01d54:	33f9f000 	andi	t9,ra,0xf000
bfc01d58:	00192b02 	srl	a1,t9,0xc
bfc01d5c:	afa50018 	sw	a1,24(sp)
bfc01d60:	8fb80018 	lw	t8,24(sp)
bfc01d64:	00000000 	nop
bfc01d68:	13000040 	beqz	t8,bfc01e6c <memory_game+0x93c>
bfc01d6c:	00000000 	nop
bfc01d70:	8c0ff024 	lw	t7,-4060(zero)
bfc01d74:	00000000 	nop
bfc01d78:	31eef000 	andi	t6,t7,0xf000
bfc01d7c:	000e1302 	srl	v0,t6,0xc
bfc01d80:	afa20018 	sw	v0,24(sp)
bfc01d84:	8fa40018 	lw	a0,24(sp)
bfc01d88:	00000000 	nop
bfc01d8c:	10800037 	beqz	a0,bfc01e6c <memory_game+0x93c>
bfc01d90:	00000000 	nop
bfc01d94:	8c19f024 	lw	t9,-4060(zero)
bfc01d98:	00000000 	nop
bfc01d9c:	3325f000 	andi	a1,t9,0xf000
bfc01da0:	0005c302 	srl	t8,a1,0xc
bfc01da4:	afb80018 	sw	t8,24(sp)
bfc01da8:	8fa30018 	lw	v1,24(sp)
bfc01dac:	00000000 	nop
bfc01db0:	1060002e 	beqz	v1,bfc01e6c <memory_game+0x93c>
bfc01db4:	00000000 	nop
bfc01db8:	8c0ef024 	lw	t6,-4060(zero)
bfc01dbc:	00000000 	nop
bfc01dc0:	31c2f000 	andi	v0,t6,0xf000
bfc01dc4:	00022302 	srl	a0,v0,0xc
bfc01dc8:	afa40018 	sw	a0,24(sp)
bfc01dcc:	8fbf0018 	lw	ra,24(sp)
bfc01dd0:	00000000 	nop
bfc01dd4:	13e00025 	beqz	ra,bfc01e6c <memory_game+0x93c>
bfc01dd8:	00000000 	nop
bfc01ddc:	8c05f024 	lw	a1,-4060(zero)
bfc01de0:	00000000 	nop
bfc01de4:	30b8f000 	andi	t8,a1,0xf000
bfc01de8:	00181b02 	srl	v1,t8,0xc
bfc01dec:	afa30018 	sw	v1,24(sp)
bfc01df0:	8faf0018 	lw	t7,24(sp)
bfc01df4:	00000000 	nop
bfc01df8:	11e0001c 	beqz	t7,bfc01e6c <memory_game+0x93c>
bfc01dfc:	00000000 	nop
bfc01e00:	8c02f024 	lw	v0,-4060(zero)
bfc01e04:	00000000 	nop
bfc01e08:	3044f000 	andi	a0,v0,0xf000
bfc01e0c:	0004fb02 	srl	ra,a0,0xc
bfc01e10:	afbf0018 	sw	ra,24(sp)
bfc01e14:	8fb90018 	lw	t9,24(sp)
bfc01e18:	00000000 	nop
bfc01e1c:	13200013 	beqz	t9,bfc01e6c <memory_game+0x93c>
bfc01e20:	00000000 	nop
bfc01e24:	8c18f024 	lw	t8,-4060(zero)
bfc01e28:	00000000 	nop
bfc01e2c:	3303f000 	andi	v1,t8,0xf000
bfc01e30:	00037b02 	srl	t7,v1,0xc
bfc01e34:	afaf0018 	sw	t7,24(sp)
bfc01e38:	8fae0018 	lw	t6,24(sp)
bfc01e3c:	00000000 	nop
bfc01e40:	11c0000a 	beqz	t6,bfc01e6c <memory_game+0x93c>
bfc01e44:	00000000 	nop
bfc01e48:	8c04f024 	lw	a0,-4060(zero)
bfc01e4c:	00000000 	nop
bfc01e50:	309ff000 	andi	ra,a0,0xf000
bfc01e54:	001fcb02 	srl	t9,ra,0xc
bfc01e58:	afb90018 	sw	t9,24(sp)
bfc01e5c:	8fa50018 	lw	a1,24(sp)
bfc01e60:	00000000 	nop
bfc01e64:	14a0ffb9 	bnez	a1,bfc01d4c <memory_game+0x81c>
bfc01e68:	00000000 	nop
bfc01e6c:	ac0bf000 	sw	t3,-4096(zero)
bfc01e70:	8fb9001c 	lw	t9,28(sp)
bfc01e74:	00000000 	nop
bfc01e78:	27250001 	addiu	a1,t9,1
bfc01e7c:	afa5001c 	sw	a1,28(sp)
bfc01e80:	8fb8001c 	lw	t8,28(sp)
bfc01e84:	00000000 	nop
bfc01e88:	00187e00 	sll	t7,t8,0x18
bfc01e8c:	ac0ff010 	sw	t7,-4080(zero)
bfc01e90:	8fa30020 	lw	v1,32(sp)
bfc01e94:	00000000 	nop
bfc01e98:	246e0001 	addiu	t6,v1,1
bfc01e9c:	afae0020 	sw	t6,32(sp)
bfc01ea0:	8fa40020 	lw	a0,32(sp)
bfc01ea4:	00000000 	nop
bfc01ea8:	28820008 	slti	v0,a0,8
bfc01eac:	1440ff2a 	bnez	v0,bfc01b58 <memory_game+0x628>
bfc01eb0:	00000000 	nop
bfc01eb4:	afa00018 	sw	zero,24(sp)
bfc01eb8:	8fa20018 	lw	v0,24(sp)
bfc01ebc:	00000000 	nop
bfc01ec0:	2c5f012c 	sltiu	ra,v0,300
bfc01ec4:	13e00058 	beqz	ra,bfc02028 <memory_game+0xaf8>
bfc01ec8:	00000000 	nop
bfc01ecc:	afa00014 	sw	zero,20(sp)
bfc01ed0:	8fae0014 	lw	t6,20(sp)
bfc01ed4:	00000000 	nop
bfc01ed8:	2dc42710 	sltiu	a0,t6,10000
bfc01edc:	10800049 	beqz	a0,bfc02004 <memory_game+0xad4>
bfc01ee0:	00000000 	nop
bfc01ee4:	8fa50014 	lw	a1,20(sp)
bfc01ee8:	00000000 	nop
bfc01eec:	24b80001 	addiu	t8,a1,1
bfc01ef0:	afb80014 	sw	t8,20(sp)
bfc01ef4:	8faf0014 	lw	t7,20(sp)
bfc01ef8:	00000000 	nop
bfc01efc:	2de32710 	sltiu	v1,t7,10000
bfc01f00:	10600040 	beqz	v1,bfc02004 <memory_game+0xad4>
bfc01f04:	00000000 	nop
bfc01f08:	8fae0014 	lw	t6,20(sp)
bfc01f0c:	00000000 	nop
bfc01f10:	25c20001 	addiu	v0,t6,1
bfc01f14:	afa20014 	sw	v0,20(sp)
bfc01f18:	8fa40014 	lw	a0,20(sp)
bfc01f1c:	00000000 	nop
bfc01f20:	2c9f2710 	sltiu	ra,a0,10000
bfc01f24:	13e00037 	beqz	ra,bfc02004 <memory_game+0xad4>
bfc01f28:	00000000 	nop
bfc01f2c:	8fa50014 	lw	a1,20(sp)
bfc01f30:	00000000 	nop
bfc01f34:	24b80001 	addiu	t8,a1,1
bfc01f38:	afb80014 	sw	t8,20(sp)
bfc01f3c:	8fa30014 	lw	v1,20(sp)
bfc01f40:	00000000 	nop
bfc01f44:	2c6f2710 	sltiu	t7,v1,10000
bfc01f48:	11e0002e 	beqz	t7,bfc02004 <memory_game+0xad4>
bfc01f4c:	00000000 	nop
bfc01f50:	8fa20014 	lw	v0,20(sp)
bfc01f54:	00000000 	nop
bfc01f58:	24440001 	addiu	a0,v0,1
bfc01f5c:	afa40014 	sw	a0,20(sp)
bfc01f60:	8fbf0014 	lw	ra,20(sp)
bfc01f64:	00000000 	nop
bfc01f68:	2ff92710 	sltiu	t9,ra,10000
bfc01f6c:	13200025 	beqz	t9,bfc02004 <memory_game+0xad4>
bfc01f70:	00000000 	nop
bfc01f74:	8fb80014 	lw	t8,20(sp)
bfc01f78:	00000000 	nop
bfc01f7c:	27030001 	addiu	v1,t8,1
bfc01f80:	afa30014 	sw	v1,20(sp)
bfc01f84:	8faf0014 	lw	t7,20(sp)
bfc01f88:	00000000 	nop
bfc01f8c:	2dee2710 	sltiu	t6,t7,10000
bfc01f90:	11c0001c 	beqz	t6,bfc02004 <memory_game+0xad4>
bfc01f94:	00000000 	nop
bfc01f98:	8fa40014 	lw	a0,20(sp)
bfc01f9c:	00000000 	nop
bfc01fa0:	249f0001 	addiu	ra,a0,1
bfc01fa4:	afbf0014 	sw	ra,20(sp)
bfc01fa8:	8fb90014 	lw	t9,20(sp)
bfc01fac:	00000000 	nop
bfc01fb0:	2f252710 	sltiu	a1,t9,10000
bfc01fb4:	10a00013 	beqz	a1,bfc02004 <memory_game+0xad4>
bfc01fb8:	00000000 	nop
bfc01fbc:	8fa30014 	lw	v1,20(sp)
bfc01fc0:	00000000 	nop
bfc01fc4:	246f0001 	addiu	t7,v1,1
bfc01fc8:	afaf0014 	sw	t7,20(sp)
bfc01fcc:	8fae0014 	lw	t6,20(sp)
bfc01fd0:	00000000 	nop
bfc01fd4:	2dc22710 	sltiu	v0,t6,10000
bfc01fd8:	1040000a 	beqz	v0,bfc02004 <memory_game+0xad4>
bfc01fdc:	00000000 	nop
bfc01fe0:	8fbf0014 	lw	ra,20(sp)
bfc01fe4:	00000000 	nop
bfc01fe8:	27f90001 	addiu	t9,ra,1
bfc01fec:	afb90014 	sw	t9,20(sp)
bfc01ff0:	8fa50014 	lw	a1,20(sp)
bfc01ff4:	00000000 	nop
bfc01ff8:	2cb82710 	sltiu	t8,a1,10000
bfc01ffc:	1700ffb9 	bnez	t8,bfc01ee4 <memory_game+0x9b4>
bfc02000:	00000000 	nop
bfc02004:	8fa40018 	lw	a0,24(sp)
bfc02008:	00000000 	nop
bfc0200c:	24820001 	addiu	v0,a0,1
bfc02010:	afa20018 	sw	v0,24(sp)
bfc02014:	8fbf0018 	lw	ra,24(sp)
bfc02018:	00000000 	nop
bfc0201c:	2ff9012c 	sltiu	t9,ra,300
bfc02020:	1720ffaa 	bnez	t9,bfc01ecc <memory_game+0x99c>
bfc02024:	00000000 	nop
bfc02028:	afa00018 	sw	zero,24(sp)
bfc0202c:	ac00f000 	sw	zero,-4096(zero)
bfc02030:	afa0001c 	sw	zero,28(sp)
bfc02034:	8fa3001c 	lw	v1,28(sp)
bfc02038:	00000000 	nop
bfc0203c:	2c6e00c8 	sltiu	t6,v1,200
bfc02040:	11c00058 	beqz	t6,bfc021a4 <memory_game+0xc74>
bfc02044:	00000000 	nop
bfc02048:	afa00020 	sw	zero,32(sp)
bfc0204c:	8fb80020 	lw	t8,32(sp)
bfc02050:	00000000 	nop
bfc02054:	2f0f2710 	sltiu	t7,t8,10000
bfc02058:	11e00049 	beqz	t7,bfc02180 <memory_game+0xc50>
bfc0205c:	00000000 	nop
bfc02060:	8fa20020 	lw	v0,32(sp)
bfc02064:	00000000 	nop
bfc02068:	245f0001 	addiu	ra,v0,1
bfc0206c:	afbf0020 	sw	ra,32(sp)
bfc02070:	8fb90020 	lw	t9,32(sp)
bfc02074:	00000000 	nop
bfc02078:	2f252710 	sltiu	a1,t9,10000
bfc0207c:	10a00040 	beqz	a1,bfc02180 <memory_game+0xc50>
bfc02080:	00000000 	nop
bfc02084:	8fa20020 	lw	v0,32(sp)
bfc02088:	00000000 	nop
bfc0208c:	24440001 	addiu	a0,v0,1
bfc02090:	afa40020 	sw	a0,32(sp)
bfc02094:	8fbf0020 	lw	ra,32(sp)
bfc02098:	00000000 	nop
bfc0209c:	2ff92710 	sltiu	t9,ra,10000
bfc020a0:	13200037 	beqz	t9,bfc02180 <memory_game+0xc50>
bfc020a4:	00000000 	nop
bfc020a8:	8fb80020 	lw	t8,32(sp)
bfc020ac:	00000000 	nop
bfc020b0:	27030001 	addiu	v1,t8,1
bfc020b4:	afa30020 	sw	v1,32(sp)
bfc020b8:	8faf0020 	lw	t7,32(sp)
bfc020bc:	00000000 	nop
bfc020c0:	2dee2710 	sltiu	t6,t7,10000
bfc020c4:	11c0002e 	beqz	t6,bfc02180 <memory_game+0xc50>
bfc020c8:	00000000 	nop
bfc020cc:	8fa40020 	lw	a0,32(sp)
bfc020d0:	00000000 	nop
bfc020d4:	249f0001 	addiu	ra,a0,1
bfc020d8:	afbf0020 	sw	ra,32(sp)
bfc020dc:	8fb90020 	lw	t9,32(sp)
bfc020e0:	00000000 	nop
bfc020e4:	2f252710 	sltiu	a1,t9,10000
bfc020e8:	10a00025 	beqz	a1,bfc02180 <memory_game+0xc50>
bfc020ec:	00000000 	nop
bfc020f0:	8fa30020 	lw	v1,32(sp)
bfc020f4:	00000000 	nop
bfc020f8:	246f0001 	addiu	t7,v1,1
bfc020fc:	afaf0020 	sw	t7,32(sp)
bfc02100:	8fae0020 	lw	t6,32(sp)
bfc02104:	00000000 	nop
bfc02108:	2dc22710 	sltiu	v0,t6,10000
bfc0210c:	1040001c 	beqz	v0,bfc02180 <memory_game+0xc50>
bfc02110:	00000000 	nop
bfc02114:	8fbf0020 	lw	ra,32(sp)
bfc02118:	00000000 	nop
bfc0211c:	27f90001 	addiu	t9,ra,1
bfc02120:	afb90020 	sw	t9,32(sp)
bfc02124:	8fa50020 	lw	a1,32(sp)
bfc02128:	00000000 	nop
bfc0212c:	2cb82710 	sltiu	t8,a1,10000
bfc02130:	13000013 	beqz	t8,bfc02180 <memory_game+0xc50>
bfc02134:	00000000 	nop
bfc02138:	8faf0020 	lw	t7,32(sp)
bfc0213c:	00000000 	nop
bfc02140:	25ee0001 	addiu	t6,t7,1
bfc02144:	afae0020 	sw	t6,32(sp)
bfc02148:	8fa20020 	lw	v0,32(sp)
bfc0214c:	00000000 	nop
bfc02150:	2c442710 	sltiu	a0,v0,10000
bfc02154:	1080000a 	beqz	a0,bfc02180 <memory_game+0xc50>
bfc02158:	00000000 	nop
bfc0215c:	8fb90020 	lw	t9,32(sp)
bfc02160:	00000000 	nop
bfc02164:	27250001 	addiu	a1,t9,1
bfc02168:	afa50020 	sw	a1,32(sp)
bfc0216c:	8fb80020 	lw	t8,32(sp)
bfc02170:	00000000 	nop
bfc02174:	2f032710 	sltiu	v1,t8,10000
bfc02178:	1460ffb9 	bnez	v1,bfc02060 <memory_game+0xb30>
bfc0217c:	00000000 	nop
bfc02180:	8faf001c 	lw	t7,28(sp)
bfc02184:	00000000 	nop
bfc02188:	25e30001 	addiu	v1,t7,1
bfc0218c:	afa3001c 	sw	v1,28(sp)
bfc02190:	8fae001c 	lw	t6,28(sp)
bfc02194:	00000000 	nop
bfc02198:	2dc400c8 	sltiu	a0,t6,200
bfc0219c:	1480ffaa 	bnez	a0,bfc02048 <memory_game+0xb18>
bfc021a0:	00000000 	nop
bfc021a4:	ac0bf000 	sw	t3,-4096(zero)
bfc021a8:	afa00014 	sw	zero,20(sp)
bfc021ac:	8fa50014 	lw	a1,20(sp)
bfc021b0:	00000000 	nop
bfc021b4:	28b80008 	slti	t8,a1,8
bfc021b8:	1700000e 	bnez	t8,bfc021f4 <memory_game+0xcc4>
bfc021bc:	00000000 	nop
bfc021c0:	0bf00895 	j	bfc02254 <memory_game+0xd24>
bfc021c4:	00000000 	nop
	...
bfc021d0:	8fae0014 	lw	t6,20(sp)
bfc021d4:	00000000 	nop
bfc021d8:	25c20001 	addiu	v0,t6,1
bfc021dc:	afa20014 	sw	v0,20(sp)
bfc021e0:	8fa40014 	lw	a0,20(sp)
bfc021e4:	00000000 	nop
bfc021e8:	289f0008 	slti	ra,a0,8
bfc021ec:	13e00019 	beqz	ra,bfc02254 <memory_game+0xd24>
bfc021f0:	00000000 	nop
bfc021f4:	8fb80014 	lw	t8,20(sp)
bfc021f8:	8fa30014 	lw	v1,20(sp)
bfc021fc:	00187880 	sll	t7,t8,0x2
bfc02200:	00037080 	sll	t6,v1,0x2
bfc02204:	01e71021 	addu	v0,t7,a3
bfc02208:	01c82021 	addu	a0,t6,t0
bfc0220c:	8c5f0000 	lw	ra,0(v0)
bfc02210:	8c990000 	lw	t9,0(a0)
bfc02214:	00000000 	nop
bfc02218:	17f9ffed 	bne	ra,t9,bfc021d0 <memory_game+0xca0>
bfc0221c:	00000000 	nop
bfc02220:	8fb90018 	lw	t9,24(sp)
bfc02224:	00000000 	nop
bfc02228:	27250001 	addiu	a1,t9,1
bfc0222c:	afa50018 	sw	a1,24(sp)
bfc02230:	8fae0014 	lw	t6,20(sp)
bfc02234:	00000000 	nop
bfc02238:	25c20001 	addiu	v0,t6,1
bfc0223c:	afa20014 	sw	v0,20(sp)
bfc02240:	8fa40014 	lw	a0,20(sp)
bfc02244:	00000000 	nop
bfc02248:	289f0008 	slti	ra,a0,8
bfc0224c:	17e0ffe9 	bnez	ra,bfc021f4 <memory_game+0xcc4>
bfc02250:	00000000 	nop
bfc02254:	8c05f010 	lw	a1,-4080(zero)
bfc02258:	8fb80018 	lw	t8,24(sp)
bfc0225c:	00000000 	nop
bfc02260:	03051825 	or	v1,t8,a1
bfc02264:	ac03f010 	sw	v1,-4080(zero)
bfc02268:	ac0af004 	sw	t2,-4092(zero)
bfc0226c:	8faf0018 	lw	t7,24(sp)
bfc02270:	00000000 	nop
bfc02274:	11ec0004 	beq	t7,t4,bfc02288 <memory_game+0xd58>
bfc02278:	00000000 	nop
bfc0227c:	ac0df008 	sw	t5,-4088(zero)
bfc02280:	0bf0055c 	j	bfc01570 <memory_game+0x40>
bfc02284:	00000000 	nop
bfc02288:	ac0af008 	sw	t2,-4088(zero)
bfc0228c:	0bf0055c 	j	bfc01570 <memory_game+0x40>
bfc02290:	00000000 	nop
	...

bfc022a0 <_get_count>:
_get_count():
/root/lab5_memory_game/lib/time.c:6
bfc022a0:	8c02e000 	lw	v0,-8192(zero)
/root/lab5_memory_game/lib/time.c:11
bfc022a4:	03e00008 	jr	ra
bfc022a8:	00000000 	nop

bfc022ac <get_count>:
/root/lab5_memory_game/lib/time.c:6
bfc022ac:	8c02e000 	lw	v0,-8192(zero)
get_count():
/root/lab5_memory_game/lib/time.c:16
bfc022b0:	03e00008 	jr	ra
bfc022b4:	00000000 	nop

bfc022b8 <get_clock>:
_get_count():
/root/lab5_memory_game/lib/time.c:6
bfc022b8:	8c02e000 	lw	v0,-8192(zero)
get_clock():
/root/lab5_memory_game/lib/time.c:35
bfc022bc:	03e00008 	jr	ra
bfc022c0:	00000000 	nop

bfc022c4 <get_ns>:
_get_count():
/root/lab5_memory_game/lib/time.c:6
bfc022c4:	8c02e000 	lw	v0,-8192(zero)
bfc022c8:	00000000 	nop
bfc022cc:	000218c0 	sll	v1,v0,0x3
bfc022d0:	00021040 	sll	v0,v0,0x1
get_ns():
/root/lab5_memory_game/lib/time.c:43
bfc022d4:	03e00008 	jr	ra
bfc022d8:	00431021 	addu	v0,v0,v1

bfc022dc <clock_gettime>:
clock_gettime():
/root/lab5_memory_game/lib/time.c:19
bfc022dc:	27bdffe8 	addiu	sp,sp,-24
bfc022e0:	afbf0014 	sw	ra,20(sp)
bfc022e4:	00a05021 	move	t2,a1
_get_count():
/root/lab5_memory_game/lib/time.c:6
bfc022e8:	8c06e000 	lw	a2,-8192(zero)
clock_gettime():
/root/lab5_memory_game/lib/time.c:24
bfc022ec:	3c030001 	lui	v1,0x1
bfc022f0:	346386a0 	ori	v1,v1,0x86a0
bfc022f4:	14600002 	bnez	v1,bfc02300 <clock_gettime+0x24>
bfc022f8:	00c3001b 	divu	zero,a2,v1
bfc022fc:	0007000d 	break	0x7
/root/lab5_memory_game/lib/time.c:23
bfc02300:	24080064 	li	t0,100
/root/lab5_memory_game/lib/time.c:25
bfc02304:	3c054876 	lui	a1,0x4876
bfc02308:	34a5e800 	ori	a1,a1,0xe800
/root/lab5_memory_game/lib/time.c:22
bfc0230c:	000610c0 	sll	v0,a2,0x3
bfc02310:	00063840 	sll	a3,a2,0x1
bfc02314:	00e23821 	addu	a3,a3,v0
bfc02318:	240203e8 	li	v0,1000
/root/lab5_memory_game/lib/time.c:26
bfc0231c:	3c048000 	lui	a0,0x8000
bfc02320:	24840000 	addiu	a0,a0,0
/root/lab5_memory_game/lib/time.c:24
bfc02324:	00001812 	mflo	v1
bfc02328:	00000000 	nop
/root/lab5_memory_game/lib/time.c:23
bfc0232c:	15000002 	bnez	t0,bfc02338 <clock_gettime+0x5c>
bfc02330:	00c8001b 	divu	zero,a2,t0
bfc02334:	0007000d 	break	0x7
bfc02338:	00004012 	mflo	t0
bfc0233c:	00000000 	nop
/root/lab5_memory_game/lib/time.c:25
bfc02340:	14a00002 	bnez	a1,bfc0234c <clock_gettime+0x70>
bfc02344:	00c5001b 	divu	zero,a2,a1
bfc02348:	0007000d 	break	0x7
bfc0234c:	00003012 	mflo	a2
bfc02350:	ad460000 	sw	a2,0(t2)
/root/lab5_memory_game/lib/time.c:24
bfc02354:	14400002 	bnez	v0,bfc02360 <clock_gettime+0x84>
bfc02358:	0062001b 	divu	zero,v1,v0
bfc0235c:	0007000d 	break	0x7
bfc02360:	00004810 	mfhi	t1
bfc02364:	ad49000c 	sw	t1,12(t2)
/root/lab5_memory_game/lib/time.c:22
bfc02368:	14400002 	bnez	v0,bfc02374 <clock_gettime+0x98>
bfc0236c:	00e2001b 	divu	zero,a3,v0
bfc02370:	0007000d 	break	0x7
bfc02374:	00002810 	mfhi	a1
bfc02378:	ad450004 	sw	a1,4(t2)
/root/lab5_memory_game/lib/time.c:23
bfc0237c:	14400002 	bnez	v0,bfc02388 <clock_gettime+0xac>
bfc02380:	0102001b 	divu	zero,t0,v0
bfc02384:	0007000d 	break	0x7
bfc02388:	00001810 	mfhi	v1
/root/lab5_memory_game/lib/time.c:26
bfc0238c:	0ff00904 	jal	bfc02410 <printf>
bfc02390:	ad430008 	sw	v1,8(t2)
/root/lab5_memory_game/lib/time.c:28
bfc02394:	8fbf0014 	lw	ra,20(sp)
bfc02398:	00001021 	move	v0,zero
bfc0239c:	03e00008 	jr	ra
bfc023a0:	27bd0018 	addiu	sp,sp,24
	...

bfc023b0 <get_epc>:
get_epc():
/root/lab5_memory_game/lib/exception.c:4
bfc023b0:	40027000 	mfc0	v0,c0_epc
/root/lab5_memory_game/lib/exception.c:9
bfc023b4:	03e00008 	jr	ra
bfc023b8:	00000000 	nop

bfc023bc <get_cause>:
get_cause():
/root/lab5_memory_game/lib/exception.c:14
bfc023bc:	40026800 	mfc0	v0,c0_cause
/root/lab5_memory_game/lib/exception.c:19
bfc023c0:	03e00008 	jr	ra
bfc023c4:	00000000 	nop

bfc023c8 <exception>:
exception():
/root/lab5_memory_game/lib/exception.c:24
bfc023c8:	3c048000 	lui	a0,0x8000
/root/lab5_memory_game/lib/exception.c:22
bfc023cc:	27bdffe8 	addiu	sp,sp,-24
bfc023d0:	afbf0014 	sw	ra,20(sp)
/root/lab5_memory_game/lib/exception.c:24
bfc023d4:	0ff00904 	jal	bfc02410 <printf>
bfc023d8:	24840014 	addiu	a0,a0,20
/root/lab5_memory_game/lib/exception.c:26
bfc023dc:	3c048000 	lui	a0,0x8000
bfc023e0:	24840030 	addiu	a0,a0,48
get_epc():
/root/lab5_memory_game/lib/exception.c:4
bfc023e4:	40057000 	mfc0	a1,c0_epc
exception():
/root/lab5_memory_game/lib/exception.c:26
bfc023e8:	0ff00904 	jal	bfc02410 <printf>
bfc023ec:	00000000 	nop
/root/lab5_memory_game/lib/exception.c:28
bfc023f0:	3c048000 	lui	a0,0x8000
/root/lab5_memory_game/lib/exception.c:30
bfc023f4:	8fbf0014 	lw	ra,20(sp)
/root/lab5_memory_game/lib/exception.c:28
bfc023f8:	24840040 	addiu	a0,a0,64
/root/lab5_memory_game/lib/exception.c:30
bfc023fc:	27bd0018 	addiu	sp,sp,24
get_cause():
/root/lab5_memory_game/lib/exception.c:14
bfc02400:	40056800 	mfc0	a1,c0_cause
exception():
/root/lab5_memory_game/lib/exception.c:28
bfc02404:	0bf00904 	j	bfc02410 <printf>
bfc02408:	00000000 	nop
bfc0240c:	00000000 	nop

bfc02410 <printf>:
printf():
/root/lab5_memory_game/lib/printf.c:2
bfc02410:	27bdffc8 	addiu	sp,sp,-56
bfc02414:	afb30024 	sw	s3,36(sp)
bfc02418:	afbf0034 	sw	ra,52(sp)
bfc0241c:	afb60030 	sw	s6,48(sp)
bfc02420:	afb5002c 	sw	s5,44(sp)
bfc02424:	afb40028 	sw	s4,40(sp)
bfc02428:	afb20020 	sw	s2,32(sp)
bfc0242c:	afb1001c 	sw	s1,28(sp)
bfc02430:	afb00018 	sw	s0,24(sp)
/root/lab5_memory_game/lib/printf.c:10
bfc02434:	80900000 	lb	s0,0(a0)
/root/lab5_memory_game/lib/printf.c:2
bfc02438:	00809821 	move	s3,a0
/root/lab5_memory_game/lib/printf.c:8
bfc0243c:	27a4003c 	addiu	a0,sp,60
/root/lab5_memory_game/lib/printf.c:2
bfc02440:	afa5003c 	sw	a1,60(sp)
bfc02444:	afa60040 	sw	a2,64(sp)
bfc02448:	afa70044 	sw	a3,68(sp)
/root/lab5_memory_game/lib/printf.c:10
bfc0244c:	12000013 	beqz	s0,bfc0249c <printf+0x8c>
bfc02450:	afa40010 	sw	a0,16(sp)
/root/lab5_memory_game/lib/printf.c:17
bfc02454:	3c028000 	lui	v0,0x8000
/root/lab5_memory_game/lib/printf.c:9
bfc02458:	00809021 	move	s2,a0
/root/lab5_memory_game/lib/printf.c:17
bfc0245c:	24560060 	addiu	s6,v0,96
/root/lab5_memory_game/lib/printf.c:9
bfc02460:	00008821 	move	s1,zero
/root/lab5_memory_game/lib/printf.c:13
bfc02464:	24140025 	li	s4,37
/root/lab5_memory_game/lib/printf.c:79
bfc02468:	2415000a 	li	s5,10
/root/lab5_memory_game/lib/printf.c:13
bfc0246c:	12140016 	beq	s0,s4,bfc024c8 <printf+0xb8>
bfc02470:	02711021 	addu	v0,s3,s1
/root/lab5_memory_game/lib/printf.c:79
bfc02474:	1215002f 	beq	s0,s5,bfc02534 <printf+0x124>
bfc02478:	00000000 	nop
/root/lab5_memory_game/lib/printf.c:80
bfc0247c:	0ff0099c 	jal	bfc02670 <putchar>
bfc02480:	02002021 	move	a0,s0
/root/lab5_memory_game/lib/printf.c:10
bfc02484:	26310001 	addiu	s1,s1,1
bfc02488:	02711021 	addu	v0,s3,s1
bfc0248c:	80500000 	lb	s0,0(v0)
bfc02490:	00000000 	nop
bfc02494:	1600fff5 	bnez	s0,bfc0246c <printf+0x5c>
bfc02498:	00000000 	nop
/root/lab5_memory_game/lib/printf.c:84
bfc0249c:	8fbf0034 	lw	ra,52(sp)
bfc024a0:	00001021 	move	v0,zero
bfc024a4:	8fb60030 	lw	s6,48(sp)
bfc024a8:	8fb5002c 	lw	s5,44(sp)
bfc024ac:	8fb40028 	lw	s4,40(sp)
bfc024b0:	8fb30024 	lw	s3,36(sp)
bfc024b4:	8fb20020 	lw	s2,32(sp)
bfc024b8:	8fb1001c 	lw	s1,28(sp)
bfc024bc:	8fb00018 	lw	s0,24(sp)
bfc024c0:	03e00008 	jr	ra
bfc024c4:	27bd0038 	addiu	sp,sp,56
/root/lab5_memory_game/lib/printf.c:13
bfc024c8:	80440001 	lb	a0,1(v0)
bfc024cc:	24050001 	li	a1,1
/root/lab5_memory_game/lib/printf.c:17
bfc024d0:	2482ffdb 	addiu	v0,a0,-37
bfc024d4:	304200ff 	andi	v0,v0,0xff
bfc024d8:	2c430054 	sltiu	v1,v0,84
bfc024dc:	14600005 	bnez	v1,bfc024f4 <printf+0xe4>
bfc024e0:	00021080 	sll	v0,v0,0x2
/root/lab5_memory_game/lib/printf.c:73
bfc024e4:	0ff0099c 	jal	bfc02670 <putchar>
bfc024e8:	24040025 	li	a0,37
/root/lab5_memory_game/lib/printf.c:10
bfc024ec:	0bf00922 	j	bfc02488 <printf+0x78>
bfc024f0:	26310001 	addiu	s1,s1,1
/root/lab5_memory_game/lib/printf.c:17
bfc024f4:	02c21021 	addu	v0,s6,v0
bfc024f8:	8c430000 	lw	v1,0(v0)
bfc024fc:	00000000 	nop
bfc02500:	00600008 	jr	v1
bfc02504:	00000000 	nop
/root/lab5_memory_game/lib/printf.c:65
bfc02508:	26310001 	addiu	s1,s1,1
bfc0250c:	02711021 	addu	v0,s3,s1
bfc02510:	80440001 	lb	a0,1(v0)
bfc02514:	00000000 	nop
/root/lab5_memory_game/lib/printf.c:67
bfc02518:	2482ffcf 	addiu	v0,a0,-49
bfc0251c:	304200ff 	andi	v0,v0,0xff
bfc02520:	2c420009 	sltiu	v0,v0,9
bfc02524:	1440003f 	bnez	v0,bfc02624 <printf+0x214>
bfc02528:	00002821 	move	a1,zero
/root/lab5_memory_game/lib/printf.c:17
bfc0252c:	0bf00935 	j	bfc024d4 <printf+0xc4>
bfc02530:	2482ffdb 	addiu	v0,a0,-37
/root/lab5_memory_game/lib/printf.c:79
bfc02534:	0ff0099c 	jal	bfc02670 <putchar>
bfc02538:	2404000d 	li	a0,13
bfc0253c:	0bf0091f 	j	bfc0247c <printf+0x6c>
bfc02540:	00000000 	nop
/root/lab5_memory_game/lib/printf.c:30
bfc02544:	8e440000 	lw	a0,0(s2)
bfc02548:	2406000a 	li	a2,10
bfc0254c:	0ff009d4 	jal	bfc02750 <printbase>
bfc02550:	00003821 	move	a3,zero
/root/lab5_memory_game/lib/printf.c:31
bfc02554:	26520004 	addiu	s2,s2,4
/root/lab5_memory_game/lib/printf.c:32
bfc02558:	0bf00921 	j	bfc02484 <printf+0x74>
bfc0255c:	26310001 	addiu	s1,s1,1
/root/lab5_memory_game/lib/printf.c:20
bfc02560:	8e440000 	lw	a0,0(s2)
bfc02564:	0ff009a4 	jal	bfc02690 <putstring>
bfc02568:	26310001 	addiu	s1,s1,1
/root/lab5_memory_game/lib/printf.c:21
bfc0256c:	0bf00921 	j	bfc02484 <printf+0x74>
bfc02570:	26520004 	addiu	s2,s2,4
/root/lab5_memory_game/lib/printf.c:56
bfc02574:	8e440000 	lw	a0,0(s2)
bfc02578:	24060010 	li	a2,16
bfc0257c:	0ff009d4 	jal	bfc02750 <printbase>
bfc02580:	00003821 	move	a3,zero
/root/lab5_memory_game/lib/printf.c:57
bfc02584:	26520004 	addiu	s2,s2,4
/root/lab5_memory_game/lib/printf.c:58
bfc02588:	0bf00921 	j	bfc02484 <printf+0x74>
bfc0258c:	26310001 	addiu	s1,s1,1
/root/lab5_memory_game/lib/printf.c:45
bfc02590:	8e440000 	lw	a0,0(s2)
bfc02594:	24060008 	li	a2,8
bfc02598:	0ff009d4 	jal	bfc02750 <printbase>
bfc0259c:	00003821 	move	a3,zero
/root/lab5_memory_game/lib/printf.c:46
bfc025a0:	26520004 	addiu	s2,s2,4
/root/lab5_memory_game/lib/printf.c:47
bfc025a4:	0bf00921 	j	bfc02484 <printf+0x74>
bfc025a8:	26310001 	addiu	s1,s1,1
/root/lab5_memory_game/lib/printf.c:40
bfc025ac:	8e440000 	lw	a0,0(s2)
bfc025b0:	2406000a 	li	a2,10
bfc025b4:	0ff009d4 	jal	bfc02750 <printbase>
bfc025b8:	00003821 	move	a3,zero
/root/lab5_memory_game/lib/printf.c:41
bfc025bc:	26520004 	addiu	s2,s2,4
/root/lab5_memory_game/lib/printf.c:42
bfc025c0:	0bf00921 	j	bfc02484 <printf+0x74>
bfc025c4:	26310002 	addiu	s1,s1,2
/root/lab5_memory_game/lib/printf.c:35
bfc025c8:	8e440000 	lw	a0,0(s2)
bfc025cc:	2406000a 	li	a2,10
bfc025d0:	0ff009d4 	jal	bfc02750 <printbase>
bfc025d4:	24070001 	li	a3,1
/root/lab5_memory_game/lib/printf.c:36
bfc025d8:	26520004 	addiu	s2,s2,4
/root/lab5_memory_game/lib/printf.c:37
bfc025dc:	0bf00921 	j	bfc02484 <printf+0x74>
bfc025e0:	26310001 	addiu	s1,s1,1
/root/lab5_memory_game/lib/printf.c:25
bfc025e4:	8e440000 	lw	a0,0(s2)
bfc025e8:	0ff0099c 	jal	bfc02670 <putchar>
bfc025ec:	26310001 	addiu	s1,s1,1
/root/lab5_memory_game/lib/printf.c:26
bfc025f0:	0bf00921 	j	bfc02484 <printf+0x74>
bfc025f4:	26520004 	addiu	s2,s2,4
/root/lab5_memory_game/lib/printf.c:50
bfc025f8:	8e440000 	lw	a0,0(s2)
bfc025fc:	24060002 	li	a2,2
bfc02600:	0ff009d4 	jal	bfc02750 <printbase>
bfc02604:	00003821 	move	a3,zero
/root/lab5_memory_game/lib/printf.c:51
bfc02608:	26520004 	addiu	s2,s2,4
/root/lab5_memory_game/lib/printf.c:52
bfc0260c:	0bf00921 	j	bfc02484 <printf+0x74>
bfc02610:	26310001 	addiu	s1,s1,1
/root/lab5_memory_game/lib/printf.c:61
bfc02614:	0ff0099c 	jal	bfc02670 <putchar>
bfc02618:	24040025 	li	a0,37
/root/lab5_memory_game/lib/printf.c:62
bfc0261c:	0bf00921 	j	bfc02484 <printf+0x74>
bfc02620:	26310001 	addiu	s1,s1,1
/root/lab5_memory_game/lib/printf.c:67
bfc02624:	02713021 	addu	a2,s3,s1
/root/lab5_memory_game/lib/printf.c:68
bfc02628:	000510c0 	sll	v0,a1,0x3
bfc0262c:	00051840 	sll	v1,a1,0x1
bfc02630:	00621821 	addu	v1,v1,v0
bfc02634:	00641821 	addu	v1,v1,a0
/root/lab5_memory_game/lib/printf.c:67
bfc02638:	80c40002 	lb	a0,2(a2)
/root/lab5_memory_game/lib/printf.c:68
bfc0263c:	2465ffd0 	addiu	a1,v1,-48
/root/lab5_memory_game/lib/printf.c:67
bfc02640:	2482ffcf 	addiu	v0,a0,-49
bfc02644:	304200ff 	andi	v0,v0,0xff
bfc02648:	2c420009 	sltiu	v0,v0,9
bfc0264c:	26310001 	addiu	s1,s1,1
bfc02650:	1040ff9f 	beqz	v0,bfc024d0 <printf+0xc0>
bfc02654:	24c60001 	addiu	a2,a2,1
/root/lab5_memory_game/lib/printf.c:68
bfc02658:	0bf0098b 	j	bfc0262c <printf+0x21c>
bfc0265c:	000510c0 	sll	v0,a1,0x3

bfc02660 <tgt_putchar>:
tgt_putchar():
/root/lab5_memory_game/lib/putchar.c:9
bfc02660:	03e00008 	jr	ra
bfc02664:	a004fff0 	sb	a0,-16(zero)
/root/lab5_memory_game/lib/putchar.c:17
bfc02668:	03e00008 	jr	ra
bfc0266c:	00000000 	nop

bfc02670 <putchar>:
putchar():
/root/lab5_memory_game/lib/putchar.c:2
bfc02670:	27bdffe8 	addiu	sp,sp,-24
bfc02674:	afbf0014 	sw	ra,20(sp)
/root/lab5_memory_game/lib/putchar.c:3
bfc02678:	0ff00998 	jal	bfc02660 <tgt_putchar>
bfc0267c:	00000000 	nop
/root/lab5_memory_game/lib/putchar.c:5
bfc02680:	8fbf0014 	lw	ra,20(sp)
bfc02684:	00001021 	move	v0,zero
bfc02688:	03e00008 	jr	ra
bfc0268c:	27bd0018 	addiu	sp,sp,24

bfc02690 <putstring>:
putstring():
/root/lab5_memory_game/lib/puts.c:2
bfc02690:	27bdffe0 	addiu	sp,sp,-32
bfc02694:	afb10014 	sw	s1,20(sp)
bfc02698:	afbf001c 	sw	ra,28(sp)
bfc0269c:	afb20018 	sw	s2,24(sp)
bfc026a0:	afb00010 	sw	s0,16(sp)
/root/lab5_memory_game/lib/puts.c:4
bfc026a4:	80900000 	lb	s0,0(a0)
bfc026a8:	00000000 	nop
bfc026ac:	12000013 	beqz	s0,bfc026fc <putstring+0x6c>
bfc026b0:	00808821 	move	s1,a0
/root/lab5_memory_game/lib/puts.c:6
bfc026b4:	0bf009b5 	j	bfc026d4 <putstring+0x44>
bfc026b8:	2412000a 	li	s2,10
/root/lab5_memory_game/lib/puts.c:7
bfc026bc:	0ff0099c 	jal	bfc02670 <putchar>
bfc026c0:	02002021 	move	a0,s0
/root/lab5_memory_game/lib/puts.c:4
bfc026c4:	82300000 	lb	s0,0(s1)
bfc026c8:	00000000 	nop
bfc026cc:	1200000b 	beqz	s0,bfc026fc <putstring+0x6c>
bfc026d0:	00000000 	nop
/root/lab5_memory_game/lib/puts.c:6
bfc026d4:	1612fff9 	bne	s0,s2,bfc026bc <putstring+0x2c>
bfc026d8:	26310001 	addiu	s1,s1,1
bfc026dc:	0ff0099c 	jal	bfc02670 <putchar>
bfc026e0:	2404000d 	li	a0,13
/root/lab5_memory_game/lib/puts.c:7
bfc026e4:	0ff0099c 	jal	bfc02670 <putchar>
bfc026e8:	02002021 	move	a0,s0
/root/lab5_memory_game/lib/puts.c:4
bfc026ec:	82300000 	lb	s0,0(s1)
bfc026f0:	00000000 	nop
bfc026f4:	1600fff7 	bnez	s0,bfc026d4 <putstring+0x44>
bfc026f8:	00000000 	nop
/root/lab5_memory_game/lib/puts.c:11
bfc026fc:	8fbf001c 	lw	ra,28(sp)
bfc02700:	00001021 	move	v0,zero
bfc02704:	8fb20018 	lw	s2,24(sp)
bfc02708:	8fb10014 	lw	s1,20(sp)
bfc0270c:	8fb00010 	lw	s0,16(sp)
bfc02710:	03e00008 	jr	ra
bfc02714:	27bd0020 	addiu	sp,sp,32

bfc02718 <puts>:
puts():
/root/lab5_memory_game/lib/puts.c:15
bfc02718:	27bdffe8 	addiu	sp,sp,-24
bfc0271c:	afbf0014 	sw	ra,20(sp)
/root/lab5_memory_game/lib/puts.c:16
bfc02720:	0ff009a4 	jal	bfc02690 <putstring>
bfc02724:	00000000 	nop
/root/lab5_memory_game/lib/puts.c:17
bfc02728:	0ff0099c 	jal	bfc02670 <putchar>
bfc0272c:	2404000d 	li	a0,13
/root/lab5_memory_game/lib/puts.c:18
bfc02730:	0ff0099c 	jal	bfc02670 <putchar>
bfc02734:	2404000a 	li	a0,10
/root/lab5_memory_game/lib/puts.c:20
bfc02738:	8fbf0014 	lw	ra,20(sp)
bfc0273c:	00001021 	move	v0,zero
bfc02740:	03e00008 	jr	ra
bfc02744:	27bd0018 	addiu	sp,sp,24
	...

bfc02750 <printbase>:
printbase():
/root/lab5_memory_game/lib/printbase.c:2
bfc02750:	27bdff98 	addiu	sp,sp,-104
bfc02754:	afb30060 	sw	s3,96(sp)
bfc02758:	afb2005c 	sw	s2,92(sp)
bfc0275c:	afbf0064 	sw	ra,100(sp)
bfc02760:	afb10058 	sw	s1,88(sp)
bfc02764:	afb00054 	sw	s0,84(sp)
bfc02768:	00801821 	move	v1,a0
bfc0276c:	00a09821 	move	s3,a1
/root/lab5_memory_game/lib/printbase.c:7
bfc02770:	10e00003 	beqz	a3,bfc02780 <printbase+0x30>
bfc02774:	00c09021 	move	s2,a2
bfc02778:	0480002f 	bltz	a0,bfc02838 <printbase+0xe8>
bfc0277c:	2404002d 	li	a0,45
/root/lab5_memory_game/lib/printbase.c:12
bfc02780:	00608021 	move	s0,v1
/root/lab5_memory_game/lib/printbase.c:14
bfc02784:	1200000c 	beqz	s0,bfc027b8 <printbase+0x68>
bfc02788:	00008821 	move	s1,zero
bfc0278c:	27a50010 	addiu	a1,sp,16
/root/lab5_memory_game/lib/printbase.c:16
bfc02790:	16400002 	bnez	s2,bfc0279c <printbase+0x4c>
bfc02794:	0212001b 	divu	zero,s0,s2
bfc02798:	0007000d 	break	0x7
bfc0279c:	00b12021 	addu	a0,a1,s1
/root/lab5_memory_game/lib/printbase.c:14
bfc027a0:	26310001 	addiu	s1,s1,1
/root/lab5_memory_game/lib/printbase.c:16
bfc027a4:	00001010 	mfhi	v0
bfc027a8:	a0820000 	sb	v0,0(a0)
bfc027ac:	00001812 	mflo	v1
/root/lab5_memory_game/lib/printbase.c:14
bfc027b0:	1460fff7 	bnez	v1,bfc02790 <printbase+0x40>
bfc027b4:	00608021 	move	s0,v1
/root/lab5_memory_game/lib/printbase.c:22
bfc027b8:	0233102a 	slt	v0,s1,s3
bfc027bc:	10400002 	beqz	v0,bfc027c8 <printbase+0x78>
bfc027c0:	02201821 	move	v1,s1
bfc027c4:	02601821 	move	v1,s3
bfc027c8:	1060000c 	beqz	v1,bfc027fc <printbase+0xac>
bfc027cc:	2470ffff 	addiu	s0,v1,-1
/root/lab5_memory_game/lib/printbase.c:2
bfc027d0:	27a20010 	addiu	v0,sp,16
bfc027d4:	00509021 	addu	s2,v0,s0
/root/lab5_memory_game/lib/printbase.c:24
bfc027d8:	26020001 	addiu	v0,s0,1
bfc027dc:	0222102a 	slt	v0,s1,v0
bfc027e0:	1040000e 	beqz	v0,bfc0281c <printbase+0xcc>
bfc027e4:	24040030 	li	a0,48
/root/lab5_memory_game/lib/printbase.c:25
bfc027e8:	02009821 	move	s3,s0
bfc027ec:	0ff0099c 	jal	bfc02670 <putchar>
bfc027f0:	2610ffff 	addiu	s0,s0,-1
/root/lab5_memory_game/lib/printbase.c:22
bfc027f4:	1660fff8 	bnez	s3,bfc027d8 <printbase+0x88>
bfc027f8:	2652ffff 	addiu	s2,s2,-1
/root/lab5_memory_game/lib/printbase.c:28
bfc027fc:	8fbf0064 	lw	ra,100(sp)
bfc02800:	00001021 	move	v0,zero
bfc02804:	8fb30060 	lw	s3,96(sp)
bfc02808:	8fb2005c 	lw	s2,92(sp)
bfc0280c:	8fb10058 	lw	s1,88(sp)
bfc02810:	8fb00054 	lw	s0,84(sp)
bfc02814:	03e00008 	jr	ra
bfc02818:	27bd0068 	addiu	sp,sp,104
/root/lab5_memory_game/lib/printbase.c:24
bfc0281c:	82440000 	lb	a0,0(s2)
bfc02820:	00000000 	nop
/root/lab5_memory_game/lib/printbase.c:25
bfc02824:	2882000a 	slti	v0,a0,10
bfc02828:	14400007 	bnez	v0,bfc02848 <printbase+0xf8>
bfc0282c:	02009821 	move	s3,s0
bfc02830:	0bf009fb 	j	bfc027ec <printbase+0x9c>
bfc02834:	24840057 	addiu	a0,a0,87
/root/lab5_memory_game/lib/printbase.c:10
bfc02838:	0ff0099c 	jal	bfc02670 <putchar>
bfc0283c:	00038023 	negu	s0,v1
bfc02840:	0bf009e1 	j	bfc02784 <printbase+0x34>
bfc02844:	00000000 	nop
/root/lab5_memory_game/lib/printbase.c:25
bfc02848:	0bf009fa 	j	bfc027e8 <printbase+0x98>
bfc0284c:	24840030 	addiu	a0,a0,48

Disassembly of section .data:

80000000 <_fdata-0x1c8>:
80000000:	636f6c63 	0x636f6c63
80000004:	736e206b 	0x736e206b
80000008:	2c64253d 	sltiu	a0,v1,9533
8000000c:	3d636573 	0x3d636573
80000010:	000a6425 	0xa6425
80000014:	72656854 	0x72656854
80000018:	73692065 	0x73692065
8000001c:	206e6120 	addi	t6,v1,24864
80000020:	65637865 	0x65637865
80000024:	6f697470 	0x6f697470
80000028:	0a21216e 	j	888485b8 <_gp+0x88403e8>
8000002c:	00000000 	nop
80000030:	20656854 	addi	a1,v1,26708
80000034:	20637065 	addi	v1,v1,28773
80000038:	25207369 	addiu	zero,t1,29545
8000003c:	00000a78 	0xa78
80000040:	20656854 	addi	a1,v1,26708
80000044:	73756163 	0x73756163
80000048:	73692065 	0x73692065
8000004c:	0a782520 	j	89e09480 <_gp+0x9e012b0>
80000050:	00000000 	nop
	...
80000060:	bfc02614 	0xbfc02614
80000064:	bfc024e4 	0xbfc024e4
80000068:	bfc024e4 	0xbfc024e4
8000006c:	bfc024e4 	0xbfc024e4
80000070:	bfc024e4 	0xbfc024e4
80000074:	bfc024e4 	0xbfc024e4
80000078:	bfc024e4 	0xbfc024e4
8000007c:	bfc024e4 	0xbfc024e4
80000080:	bfc024e4 	0xbfc024e4
80000084:	bfc024e4 	0xbfc024e4
80000088:	bfc024e4 	0xbfc024e4
8000008c:	bfc02508 	0xbfc02508
80000090:	bfc02518 	0xbfc02518
80000094:	bfc02518 	0xbfc02518
80000098:	bfc02518 	0xbfc02518
8000009c:	bfc02518 	0xbfc02518
800000a0:	bfc02518 	0xbfc02518
800000a4:	bfc02518 	0xbfc02518
800000a8:	bfc02518 	0xbfc02518
800000ac:	bfc02518 	0xbfc02518
800000b0:	bfc02518 	0xbfc02518
800000b4:	bfc024e4 	0xbfc024e4
800000b8:	bfc024e4 	0xbfc024e4
800000bc:	bfc024e4 	0xbfc024e4
800000c0:	bfc024e4 	0xbfc024e4
800000c4:	bfc024e4 	0xbfc024e4
800000c8:	bfc024e4 	0xbfc024e4
800000cc:	bfc024e4 	0xbfc024e4
800000d0:	bfc024e4 	0xbfc024e4
800000d4:	bfc024e4 	0xbfc024e4
800000d8:	bfc024e4 	0xbfc024e4
800000dc:	bfc024e4 	0xbfc024e4
800000e0:	bfc024e4 	0xbfc024e4
800000e4:	bfc024e4 	0xbfc024e4
800000e8:	bfc024e4 	0xbfc024e4
800000ec:	bfc024e4 	0xbfc024e4
800000f0:	bfc024e4 	0xbfc024e4
800000f4:	bfc024e4 	0xbfc024e4
800000f8:	bfc024e4 	0xbfc024e4
800000fc:	bfc024e4 	0xbfc024e4
80000100:	bfc024e4 	0xbfc024e4
80000104:	bfc024e4 	0xbfc024e4
80000108:	bfc024e4 	0xbfc024e4
8000010c:	bfc024e4 	0xbfc024e4
80000110:	bfc024e4 	0xbfc024e4
80000114:	bfc024e4 	0xbfc024e4
80000118:	bfc024e4 	0xbfc024e4
8000011c:	bfc024e4 	0xbfc024e4
80000120:	bfc024e4 	0xbfc024e4
80000124:	bfc024e4 	0xbfc024e4
80000128:	bfc024e4 	0xbfc024e4
8000012c:	bfc024e4 	0xbfc024e4
80000130:	bfc024e4 	0xbfc024e4
80000134:	bfc024e4 	0xbfc024e4
80000138:	bfc024e4 	0xbfc024e4
8000013c:	bfc024e4 	0xbfc024e4
80000140:	bfc024e4 	0xbfc024e4
80000144:	bfc024e4 	0xbfc024e4
80000148:	bfc024e4 	0xbfc024e4
8000014c:	bfc024e4 	0xbfc024e4
80000150:	bfc024e4 	0xbfc024e4
80000154:	bfc025f8 	0xbfc025f8
80000158:	bfc025e4 	0xbfc025e4
8000015c:	bfc025c8 	0xbfc025c8
80000160:	bfc024e4 	0xbfc024e4
80000164:	bfc024e4 	0xbfc024e4
80000168:	bfc024e4 	0xbfc024e4
8000016c:	bfc024e4 	0xbfc024e4
80000170:	bfc024e4 	0xbfc024e4
80000174:	bfc024e4 	0xbfc024e4
80000178:	bfc024e4 	0xbfc024e4
8000017c:	bfc025ac 	0xbfc025ac
80000180:	bfc024e4 	0xbfc024e4
80000184:	bfc024e4 	0xbfc024e4
80000188:	bfc02590 	0xbfc02590
8000018c:	bfc02574 	0xbfc02574
80000190:	bfc024e4 	0xbfc024e4
80000194:	bfc024e4 	0xbfc024e4
80000198:	bfc02560 	0xbfc02560
8000019c:	bfc024e4 	0xbfc024e4
800001a0:	bfc02544 	0xbfc02544
800001a4:	bfc024e4 	0xbfc024e4
800001a8:	bfc024e4 	0xbfc024e4
800001ac:	bfc02574 	0xbfc02574
800001b0:	b0000600 	0xb0000600
	...

800001c8 <_fdata>:
	...

800001d0 <__CTOR_LIST__>:
	...

800001d8 <__CTOR_END__>:
	...

800001e0 <__DTOR_END__>:
__DTOR_END__():
800001e0:	00000001 	0x1

Disassembly of section .debug_aranges:

00000000 <.debug_aranges>:
   0:	0000001c 	0x1c
   4:	00000002 	srl	zero,zero,0x0
   8:	00040000 	sll	zero,a0,0x0
   c:	00000000 	nop
  10:	bfc00000 	0xbfc00000
  14:	00000390 	0x390
	...
  20:	0000001c 	0x1c
  24:	00480002 	0x480002
  28:	00040000 	sll	zero,a0,0x0
  2c:	00000000 	nop
  30:	bfc022a0 	0xbfc022a0
  34:	00000104 	0x104
	...
  40:	0000001c 	0x1c
  44:	025c0002 	0x25c0002
  48:	00040000 	sll	zero,a0,0x0
  4c:	00000000 	nop
  50:	bfc023b0 	0xbfc023b0
  54:	0000005c 	0x5c
	...
  60:	0000001c 	0x1c
  64:	03730002 	0x3730002
  68:	00040000 	sll	zero,a0,0x0
  6c:	00000000 	nop
  70:	bfc02410 	0xbfc02410
  74:	00000250 	0x250
	...
  80:	0000001c 	0x1c
  84:	04400002 	bltz	v0,90 <data_size-0x154>
  88:	00040000 	sll	zero,a0,0x0
  8c:	00000000 	nop
  90:	bfc02660 	0xbfc02660
  94:	00000030 	0x30
	...
  a0:	0000001c 	0x1c
  a4:	04cc0002 	0x4cc0002
  a8:	00040000 	sll	zero,a0,0x0
  ac:	00000000 	nop
  b0:	bfc02690 	0xbfc02690
  b4:	000000b8 	0xb8
	...
  c0:	0000001c 	0x1c
  c4:	057b0002 	0x57b0002
  c8:	00040000 	sll	zero,a0,0x0
  cc:	00000000 	nop
  d0:	bfc02750 	0xbfc02750
  d4:	00000100 	sll	zero,zero,0x4
	...

Disassembly of section .debug_pubnames:

00000000 <.debug_pubnames>:
   0:	00000056 	0x56
   4:	00480002 	0x480002
   8:	02140000 	0x2140000
   c:	00a70000 	0xa70000
  10:	675f0000 	0x675f0000
  14:	635f7465 	0x635f7465
  18:	746e756f 	jalx	1b9d5bc <data_size+0x1b9d3d8>
  1c:	0000c800 	sll	t9,zero,0x0
  20:	74656700 	jalx	1959c00 <data_size+0x1959a1c>
  24:	756f635f 	jalx	5bd8d7c <data_size+0x5bd8b98>
  28:	0a00746e 	j	801d1b8 <data_size+0x801cfd4>
  2c:	67000001 	0x67000001
  30:	635f7465 	0x635f7465
  34:	6b636f6c 	0x6b636f6c
  38:	00015500 	sll	t2,at,0x14
  3c:	74656700 	jalx	1959c00 <data_size+0x1959a1c>
  40:	00736e5f 	0x736e5f
  44:	000001a1 	0x1a1
  48:	636f6c63 	0x636f6c63
  4c:	65675f6b 	0x65675f6b
  50:	6d697474 	0x6d697474
  54:	00000065 	0x65
  58:	00360000 	0x360000
  5c:	00020000 	sll	zero,v0,0x0
  60:	0000025c 	0x25c
  64:	00000117 	0x117
  68:	0000006b 	0x6b
  6c:	5f746567 	0x5f746567
  70:	00637065 	0x637065
  74:	0000008c 	syscall	0x2
  78:	5f746567 	0x5f746567
  7c:	73756163 	0x73756163
  80:	00ad0065 	0xad0065
  84:	78650000 	0x78650000
  88:	74706563 	jalx	1c1958c <data_size+0x1c193a8>
  8c:	006e6f69 	0x6e6f69
  90:	00000000 	nop
  94:	00000019 	multu	zero,zero
  98:	03730002 	0x3730002
  9c:	00cd0000 	0xcd0000
  a0:	00350000 	0x350000
  a4:	72700000 	0x72700000
  a8:	66746e69 	0x66746e69
  ac:	00000000 	nop
  b0:	00002a00 	sll	a1,zero,0x8
  b4:	40000200 	0x40000200
  b8:	8c000004 	lw	zero,4(zero)
  bc:	33000000 	andi	zero,t8,0x0
  c0:	74000000 	jalx	0 <data_size-0x1e4>
  c4:	705f7467 	0x705f7467
  c8:	68637475 	0x68637475
  cc:	60007261 	0x60007261
  d0:	70000000 	0x70000000
  d4:	68637475 	0x68637475
  d8:	00007261 	0x7261
  dc:	25000000 	addiu	zero,t0,0
  e0:	02000000 	0x2000000
  e4:	0004cc00 	sll	t9,a0,0x10
  e8:	0000af00 	sll	s5,zero,0x1c
  ec:	00003300 	sll	a2,zero,0xc
  f0:	74757000 	jalx	1d5c000 <data_size+0x1d5be1c>
  f4:	69727473 	0x69727473
  f8:	8300676e 	lb	zero,26478(t8)
  fc:	70000000 	0x70000000
 100:	00737475 	0x737475
 104:	00000000 	nop
 108:	0000001c 	0x1c
 10c:	057b0002 	0x57b0002
 110:	00fb0000 	0xfb0000
 114:	00330000 	0x330000
 118:	72700000 	0x72700000
 11c:	62746e69 	0x62746e69
 120:	00657361 	0x657361
 124:	00000000 	nop

Disassembly of section .pdr:

00000000 <.pdr>:
   0:	bfc00390 	0xbfc00390
	...
  14:	00000008 	jr	zero
  18:	0000001d 	0x1d
  1c:	0000001f 	0x1f
  20:	bfc00510 	0xbfc00510
	...
  34:	00000008 	jr	zero
  38:	0000001d 	0x1d
  3c:	0000001f 	0x1f
  40:	bfc00670 	0xbfc00670
	...
  54:	00000008 	jr	zero
  58:	0000001d 	0x1d
  5c:	0000001f 	0x1f
  60:	bfc007a0 	0xbfc007a0
	...
  74:	00000010 	mfhi	zero
  78:	0000001d 	0x1d
  7c:	0000001f 	0x1f
  80:	bfc00c80 	0xbfc00c80
	...
  94:	00000010 	mfhi	zero
  98:	0000001d 	0x1d
  9c:	0000001f 	0x1f
  a0:	bfc00f00 	0xbfc00f00
	...
  b8:	0000001d 	0x1d
  bc:	0000001f 	0x1f
  c0:	bfc00f30 	0xbfc00f30
	...
  d8:	0000001d 	0x1d
  dc:	0000001f 	0x1f
  e0:	bfc00f40 	0xbfc00f40
	...
  f4:	00000008 	jr	zero
  f8:	0000001d 	0x1d
  fc:	0000001f 	0x1f
 100:	bfc01030 	0xbfc01030
	...
 114:	00000018 	mult	zero,zero
 118:	0000001d 	0x1d
 11c:	0000001f 	0x1f
 120:	bfc01530 	0xbfc01530
 124:	80000000 	lb	zero,0(zero)
 128:	fffffffc 	0xfffffffc
	...
 134:	000000a8 	0xa8
 138:	0000001d 	0x1d
 13c:	0000001f 	0x1f
 140:	bfc022a0 	0xbfc022a0
	...
 158:	0000001d 	0x1d
 15c:	0000001f 	0x1f
 160:	bfc022ac 	0xbfc022ac
	...
 178:	0000001d 	0x1d
 17c:	0000001f 	0x1f
 180:	bfc022b8 	0xbfc022b8
	...
 198:	0000001d 	0x1d
 19c:	0000001f 	0x1f
 1a0:	bfc022c4 	0xbfc022c4
	...
 1b8:	0000001d 	0x1d
 1bc:	0000001f 	0x1f
 1c0:	bfc022dc 	0xbfc022dc
 1c4:	80000000 	lb	zero,0(zero)
 1c8:	fffffffc 	0xfffffffc
	...
 1d4:	00000018 	mult	zero,zero
 1d8:	0000001d 	0x1d
 1dc:	0000001f 	0x1f
 1e0:	bfc023b0 	0xbfc023b0
	...
 1f8:	0000001d 	0x1d
 1fc:	0000001f 	0x1f
 200:	bfc023bc 	0xbfc023bc
	...
 218:	0000001d 	0x1d
 21c:	0000001f 	0x1f
 220:	bfc023c8 	0xbfc023c8
 224:	80000000 	lb	zero,0(zero)
 228:	fffffffc 	0xfffffffc
	...
 234:	00000018 	mult	zero,zero
 238:	0000001d 	0x1d
 23c:	0000001f 	0x1f
 240:	bfc02410 	0xbfc02410
 244:	807f0000 	lb	ra,0(v1)
 248:	fffffffc 	0xfffffffc
	...
 254:	00000038 	0x38
 258:	0000001d 	0x1d
 25c:	0000001f 	0x1f
 260:	bfc02660 	0xbfc02660
	...
 278:	0000001d 	0x1d
 27c:	0000001f 	0x1f
 280:	bfc02670 	0xbfc02670
 284:	80000000 	lb	zero,0(zero)
 288:	fffffffc 	0xfffffffc
	...
 294:	00000018 	mult	zero,zero
 298:	0000001d 	0x1d
 29c:	0000001f 	0x1f
 2a0:	bfc02690 	0xbfc02690
 2a4:	80070000 	lb	a3,0(zero)
 2a8:	fffffffc 	0xfffffffc
	...
 2b4:	00000020 	add	zero,zero,zero
 2b8:	0000001d 	0x1d
 2bc:	0000001f 	0x1f
 2c0:	bfc02718 	0xbfc02718
 2c4:	80000000 	lb	zero,0(zero)
 2c8:	fffffffc 	0xfffffffc
	...
 2d4:	00000018 	mult	zero,zero
 2d8:	0000001d 	0x1d
 2dc:	0000001f 	0x1f
 2e0:	bfc02750 	0xbfc02750
 2e4:	800f0000 	lb	t7,0(zero)
 2e8:	fffffffc 	0xfffffffc
	...
 2f4:	00000068 	0x68
 2f8:	0000001d 	0x1d
 2fc:	0000001f 	0x1f

Disassembly of section .debug_line:

00000000 <.debug_line>:
   0:	00000042 	srl	zero,zero,0x1
   4:	001e0002 	srl	zero,s8,0x0
   8:	01010000 	0x1010000
   c:	000d0efb 	0xd0efb
  10:	01010101 	0x1010101
  14:	01000000 	0x1000000
  18:	00010000 	sll	zero,at,0x0
  1c:	72617473 	0x72617473
  20:	00532e74 	0x532e74
  24:	00000000 	nop
  28:	00020500 	sll	zero,v0,0x14
  2c:	03bfc000 	0x3bfc000
  30:	4b4b0132 	c2	0x14b0132
  34:	4b84834b 	c2	0x184834b
  38:	d8024b4d 	0xd8024b4d
  3c:	4b4b1506 	c2	0x14b1506
  40:	0004024b 	0x4024b
  44:	00790101 	0x790101
  48:	00020000 	sll	zero,v0,0x0
  4c:	00000032 	0x32
  50:	0efb0101 	jal	bec0404 <data_size+0xbec0220>
  54:	0101000d 	break	0x101
  58:	00000101 	0x101
  5c:	00000100 	sll	zero,zero,0x4
  60:	2f2e2e01 	sltiu	t6,t9,11777
  64:	6c636e69 	0x6c636e69
  68:	00656475 	0x656475
  6c:	6d697400 	0x6d697400
  70:	00632e65 	0x632e65
  74:	74000000 	jalx	0 <data_size-0x1e4>
  78:	2e656d69 	sltiu	a1,s3,28009
  7c:	00010068 	0x10068
  80:	05000000 	bltz	t0,84 <data_size-0x160>
  84:	c022a002 	lwc0	$2,-24574(at)
  88:	4f1415bf 	c3	0x11415bf
  8c:	01780385 	0x1780385
  90:	034a0a03 	0x34a0a03
  94:	6703820f 	0x6703820f
  98:	4a1d0301 	c2	0x1d0301
  9c:	01600385 	0x1600385
  a0:	03f22503 	0x3f22503
  a4:	03828268 	0x3828268
  a8:	12034a73 	beq	s0,v1,12a78 <data_size+0x12894>
  ac:	4c3b084a 	0x4c3b084a
  b0:	8180f67f 	lb	zero,-2433(t4)
  b4:	3b083e08 	xori	t0,t8,0x3e08
  b8:	3d083a08 	0x3d083a08
  bc:	100284f5 	beq	zero,v0,fffe1494 <_etext+0x403dec44>
  c0:	4f010100 	c3	0x1010100
  c4:	02000000 	0x2000000
  c8:	00002200 	sll	a0,zero,0x8
  cc:	fb010100 	0xfb010100
  d0:	01000d0e 	0x1000d0e
  d4:	00010101 	0x10101
  d8:	00010000 	sll	zero,at,0x0
  dc:	65000100 	0x65000100
  e0:	70656378 	0x70656378
  e4:	6e6f6974 	0x6e6f6974
  e8:	0000632e 	0x632e
  ec:	00000000 	nop
  f0:	23b00205 	addi	s0,sp,517
  f4:	1413bfc0 	bne	zero,s3,fffefff8 <_etext+0x403ed7a8>
  f8:	4f14854f 	c3	0x114854f
  fc:	84481485 	lh	t0,5253(v0)
 100:	826a0384 	lb	t2,900(s3)
 104:	844a1603 	lh	t2,5635(v0)
 108:	034c484c 	syscall	0xd3121
 10c:	0e034a70 	jal	80d29c0 <data_size+0x80d27dc>
 110:	0008024a 	0x8024a
 114:	00a80101 	0xa80101
 118:	00020000 	sll	zero,v0,0x0
 11c:	0000001f 	0x1f
 120:	0efb0101 	jal	bec0404 <data_size+0xbec0220>
 124:	0101000d 	break	0x101
 128:	00000101 	0x101
 12c:	00000100 	sll	zero,zero,0x4
 130:	72700001 	0x72700001
 134:	66746e69 	0x66746e69
 138:	0000632e 	0x632e
 13c:	00000000 	nop
 140:	24100205 	li	s0,517
 144:	0213bfc0 	0x213bfc0
 148:	78031a24 	0x78031a24
 14c:	7a03504a 	0x7a03504a
 150:	0389c24a 	0x389c24a
 154:	03524a78 	0x3524a78
 158:	034e4a78 	0x34e4a78
 15c:	034a00c2 	0x34a00c2
 160:	034a7fbe 	0x34a7fbe
 164:	838200c2 	lb	v0,194(gp)
 168:	827fba03 	lb	ra,-17917(s3)
 16c:	0800ca03 	j	3280c <data_size+0x32628>
 170:	7fb90374 	0x7fb90374
 174:	86012c02 	lh	at,11266(s0)
 178:	3c083803 	lui	t0,0x3803
 17c:	89824103 	lwl	v0,16643(t4)
 180:	3c083003 	lui	t0,0x3003
 184:	084e03f4 	j	1380fd0 <data_size+0x1380dec>
 188:	823e033c 	lb	s8,828(s1)
 18c:	f3f24f03 	0xf3f24f03
 190:	8274034b 	lb	s4,843(s3)
 194:	822303bb 	lb	v1,955(s1)
 198:	73034bf3 	0x73034bf3
 19c:	034bf382 	0x34bf382
 1a0:	4bf38279 	c2	0x1f38279
 1a4:	f3827903 	0xf3827903
 1a8:	8274034b 	lb	s4,843(s3)
 1ac:	821803bb 	lb	t8,955(s0)
 1b0:	09034bf3 	j	40d2fcc <data_size+0x40d2de8>
 1b4:	4b878382 	c2	0x1878382
 1b8:	08494bf1 	j	1252fc4 <data_size+0x1252de0>
 1bc:	00080275 	0x80275
 1c0:	003a0101 	0x3a0101
 1c4:	00020000 	sll	zero,v0,0x0
 1c8:	00000020 	add	zero,zero,zero
 1cc:	0efb0101 	jal	bec0404 <data_size+0xbec0220>
 1d0:	0101000d 	break	0x101
 1d4:	00000101 	0x101
 1d8:	00000100 	sll	zero,zero,0x4
 1dc:	75700001 	jalx	5c00004 <data_size+0x5bffe20>
 1e0:	61686374 	0x61686374
 1e4:	00632e72 	0x632e72
 1e8:	00000000 	nop
 1ec:	60020500 	0x60020500
 1f0:	19bfc026 	0x19bfc026
 1f4:	71038a13 	0x71038a13
 1f8:	02848382 	0x2848382
 1fc:	01010010 	0x1010010
 200:	0000003f 	0x3f
 204:	001d0002 	srl	zero,sp,0x0
 208:	01010000 	0x1010000
 20c:	000d0efb 	0xd0efb
 210:	01010101 	0x1010101
 214:	01000000 	0x1000000
 218:	00010000 	sll	zero,at,0x0
 21c:	73747570 	0x73747570
 220:	0000632e 	0x632e
 224:	00000000 	nop
 228:	26900205 	addiu	s0,s4,517
 22c:	0813bfc0 	j	4eff00 <data_size+0x4efd1c>
 230:	7f83f43e 	0x7f83f43e
 234:	f97ff3f4 	0xf97ff3f4
 238:	8383b008 	lb	v1,-20472(gp)
 23c:	10028483 	beq	zero,v0,fffe144c <_etext+0x403debfc>
 240:	53010100 	0x53010100
 244:	02000000 	0x2000000
 248:	00002200 	sll	a0,zero,0x8
 24c:	fb010100 	0xfb010100
 250:	01000d0e 	0x1000d0e
 254:	00010101 	0x10101
 258:	00010000 	sll	zero,at,0x0
 25c:	70000100 	0x70000100
 260:	746e6972 	jalx	1b9a5c8 <data_size+0x1b9a3e4>
 264:	65736162 	0x65736162
 268:	0000632e 	0x632e
 26c:	00000000 	nop
 270:	27500205 	addiu	s0,k0,517
 274:	0813bfc0 	j	4eff00 <data_size+0x4efd1c>
 278:	4cf78774 	0x4cf78774
 27c:	b84cf0bc 	swr	t4,-3908(v0)
 280:	086c038a 	j	1b00e28 <data_size+0x1b00c44>
 284:	82160374 	lb	s6,884(s0)
 288:	0888b7f3 	j	222dfcc <data_size+0x222dde8>
 28c:	710383e0 	0x710383e0
 290:	0f033c08 	jal	c0cf020 <data_size+0xc0cee3c>
 294:	000802f2 	0x802f2
 298:	Address 0x0000000000000298 is out of bounds.


Disassembly of section .debug_info:

00000000 <.debug_info>:
   0:	00000044 	0x44
   4:	00000002 	srl	zero,zero,0x0
   8:	01040000 	0x1040000
   c:	00000000 	nop
  10:	bfc00000 	0xbfc00000
  14:	bfc00390 	0xbfc00390
  18:	72617473 	0x72617473
  1c:	00532e74 	0x532e74
  20:	6f6f722f 	0x6f6f722f
  24:	616c2f74 	0x616c2f74
  28:	6d5f3562 	0x6d5f3562
  2c:	726f6d65 	0x726f6d65
  30:	61675f79 	0x61675f79
  34:	4700656d 	c1	0x100656d
  38:	4120554e 	0x4120554e
  3c:	2e322053 	sltiu	s2,s1,8275
  40:	352e3831 	ori	t6,t1,0x3831
  44:	80010030 	lb	at,48(zero)
  48:	00000210 	0x210
  4c:	00140002 	srl	zero,s4,0x0
  50:	01040000 	0x1040000
  54:	00000082 	srl	zero,zero,0x2
  58:	00003e01 	0x3e01
  5c:	00006700 	sll	t4,zero,0x1c
  60:	c022a000 	lwc0	$2,-24576(at)
  64:	c023a4bf 	lwc0	$3,-23361(at)
  68:	000046bf 	0x46bf
  6c:	07040200 	0x7040200
  70:	00000022 	neg	zero,zero
  74:	1d070402 	0x1d070402
  78:	03000000 	0x3000000
  7c:	00000014 	0x14
  80:	002c0302 	0x2c0302
  84:	04040000 	0x4040000
  88:	746e6905 	jalx	1b9a414 <data_size+0x1b9a230>
  8c:	000b0500 	sll	zero,t3,0x14
  90:	02100000 	0x2100000
  94:	00008a1f 	0x8a1f
  98:	00600600 	0x600600
  9c:	20020000 	addi	v0,zero,0
  a0:	00000033 	0x33
  a4:	06001002 	bltz	s0,40b0 <data_size+0x3ecc>
  a8:	00000091 	0x91
  ac:	00332102 	0x332102
  b0:	10020000 	beq	zero,v0,b4 <data_size-0x130>
  b4:	00580604 	0x580604
  b8:	22020000 	addi	v0,s0,0
  bc:	00000033 	0x33
  c0:	06081002 	0x6081002
  c4:	0000002f 	0x2f
  c8:	00332302 	0x332302
  cc:	10020000 	beq	zero,v0,d0 <data_size-0x114>
  d0:	0107000c 	syscall	0x41c00
  d4:	00000000 	nop
  d8:	002c0401 	0x2c0401
  dc:	a7000000 	sh	zero,0(t8)
  e0:	08000000 	j	0 <data_size-0x1e4>
  e4:	00000045 	0x45
  e8:	002c0501 	0x2c0501
  ec:	09000000 	j	4000000 <data_size+0x3fffe1c>
  f0:	0000008a 	0x8a
  f4:	bfc022a0 	0xbfc022a0
  f8:	bfc022ac 	0xbfc022ac
  fc:	00000010 	mfhi	zero
 100:	00c86d01 	0xc86d01
 104:	9b0a0000 	lwr	t2,0(t8)
	...
 110:	0001010b 	0x1010b
 114:	0e010000 	jal	8040000 <data_size+0x803fe1c>
 118:	0000002c 	0x2c
 11c:	bfc022ac 	0xbfc022ac
 120:	bfc022b8 	0xbfc022b8
 124:	00000020 	add	zero,zero,zero
 128:	010a6d01 	0x10a6d01
 12c:	8a0c0000 	lwl	t4,0(s0)
 130:	ac000000 	sw	zero,0(zero)
 134:	b0bfc022 	0xb0bfc022
 138:	01bfc022 	sub	t8,t5,ra
 13c:	22ac0d0f 	addi	t4,s5,3343
 140:	22b0bfc0 	addi	s0,s5,-16448
 144:	9b0abfc0 	lwr	t2,-16448(t8)
 148:	13000000 	beqz	t8,14c <data_size-0x98>
 14c:	00000000 	nop
 150:	010b0000 	0x10b0000
 154:	0000004e 	0x4e
 158:	002c1f01 	0x2c1f01
 15c:	22b80000 	addi	t8,s5,0
 160:	22c4bfc0 	addi	a0,s6,-16448
 164:	0030bfc0 	0x30bfc0
 168:	6d010000 	0x6d010000
 16c:	00000155 	0x155
 170:	01006e0e 	0x1006e0e
 174:	00002c20 	0x2c20
 178:	00002600 	sll	a0,zero,0x18
 17c:	008a0c00 	0x8a0c00
 180:	22b80000 	addi	t8,s5,0
 184:	22bcbfc0 	addi	gp,s5,-16448
 188:	2101bfc0 	addi	at,t0,-16448
 18c:	c022b80d 	lwc0	$2,-18419(at)
 190:	c022bcbf 	lwc0	$2,-17217(at)
 194:	009b0fbf 	0x9b0fbf
 198:	00000000 	nop
 19c:	37011000 	ori	at,t8,0x1000
 1a0:	01000000 	0x1000000
 1a4:	002c0126 	0x2c0126
 1a8:	22c40000 	addi	a0,s6,0
 1ac:	22dcbfc0 	addi	gp,s6,-16448
 1b0:	0040bfc0 	0x40bfc0
 1b4:	6d010000 	0x6d010000
 1b8:	000001a1 	0x1a1
 1bc:	01006e0e 	0x1006e0e
 1c0:	00002c27 	0x2c27
 1c4:	00003900 	sll	a3,zero,0x4
 1c8:	008a0c00 	0x8a0c00
 1cc:	22c40000 	addi	a0,s6,0
 1d0:	22d4bfc0 	addi	s4,s6,-16448
 1d4:	2801bfc0 	slti	at,zero,-16448
 1d8:	c022c40d 	lwc0	$2,-15347(at)
 1dc:	c022d4bf 	lwc0	$2,-11073(at)
 1e0:	009b0fbf 	0x9b0fbf
 1e4:	00000000 	nop
 1e8:	99011100 	lwr	at,4352(t0)
 1ec:	01000000 	0x1000000
 1f0:	002c0113 	0x2c0113
 1f4:	22dc0000 	addi	gp,s6,0
 1f8:	23a4bfc0 	addi	a0,sp,-16448
 1fc:	0050bfc0 	0x50bfc0
 200:	004c0000 	0x4c0000
 204:	020d0000 	0x20d0000
 208:	73120000 	0x73120000
 20c:	01006c65 	0x1006c65
 210:	00003e12 	0x3e12
 214:	00006b00 	sll	t5,zero,0xc
 218:	6d741200 	0x6d741200
 21c:	12010070 	beq	s0,at,3e0 <data_size+0x1fc>
 220:	0000020d 	break	0x0,0x8
 224:	0000007e 	0x7e
 228:	01006e0e 	0x1006e0e
 22c:	00002c14 	0x2c14
 230:	00009c00 	sll	s3,zero,0x10
 234:	008a0c00 	0x8a0c00
 238:	22e80000 	addi	t0,s7,0
 23c:	22ecbfc0 	addi	t4,s7,-16448
 240:	1501bfc0 	bne	t0,at,ffff0144 <_etext+0x403ed8f4>
 244:	c022e80d 	lwc0	$2,-6131(at)
 248:	c022ecbf 	lwc0	$2,-4929(at)
 24c:	009b0fbf 	0x9b0fbf
 250:	00000000 	nop
 254:	45041300 	0x45041300
 258:	00000000 	nop
 25c:	00000113 	0x113
 260:	013c0002 	0x13c0002
 264:	01040000 	0x1040000
 268:	00000082 	srl	zero,zero,0x2
 26c:	0000b101 	0xb101
 270:	00006700 	sll	t4,zero,0x1c
 274:	c023b000 	lwc0	$3,-20480(at)
 278:	c0240cbf 	lwc0	$4,3263(at)
 27c:	0000c3bf 	0xc3bf
 280:	07040200 	0x7040200
 284:	00000022 	neg	zero,zero
 288:	1d070402 	0x1d070402
 28c:	03000000 	0x3000000
 290:	0000bd01 	0xbd01
 294:	01020100 	0x1020100
 298:	0000002c 	0x2c
 29c:	00004f00 	sll	t1,zero,0x1c
 2a0:	006e0400 	0x6e0400
 2a4:	002c0301 	0x2c0301
 2a8:	03000000 	0x3000000
 2ac:	0000a701 	0xa701
 2b0:	010c0100 	0x10c0100
 2b4:	0000002c 	0x2c
 2b8:	00006b00 	sll	t5,zero,0xc
 2bc:	006e0400 	0x6e0400
 2c0:	002c0d01 	0x2c0d01
 2c4:	05000000 	bltz	t0,2c8 <data_size+0xe4>
 2c8:	00000033 	0x33
 2cc:	bfc023b0 	0xbfc023b0
 2d0:	bfc023bc 	0xbfc023bc
 2d4:	00000078 	0x78
 2d8:	008c6d01 	0x8c6d01
 2dc:	45060000 	0x45060000
 2e0:	af000000 	sw	zero,0(t8)
 2e4:	00000000 	nop
 2e8:	00004f05 	0x4f05
 2ec:	c023bc00 	lwc0	$3,-17408(at)
 2f0:	c023c8bf 	lwc0	$3,-14145(at)
 2f4:	000088bf 	0x88bf
 2f8:	ad6d0100 	sw	t5,256(t3)
 2fc:	06000000 	bltz	s0,300 <data_size+0x11c>
 300:	00000061 	0x61
 304:	000000c2 	srl	zero,zero,0x3
 308:	c5010700 	lwc1	$f1,1792(t0)
 30c:	01000000 	0x1000000
 310:	23c80116 	addi	t0,s8,278
 314:	240cbfc0 	li	t4,-16448
 318:	0098bfc0 	0x98bfc0
 31c:	00d50000 	0xd50000
 320:	6e080000 	0x6e080000
 324:	2c170100 	sltiu	s7,zero,256
 328:	f4000000 	0xf4000000
 32c:	09000000 	j	4000000 <data_size+0x3fffe1c>
 330:	00000033 	0x33
 334:	bfc023e4 	0xbfc023e4
 338:	bfc023e8 	0xbfc023e8
 33c:	00f61901 	0xf61901
 340:	e40a0000 	swc1	$f10,0(zero)
 344:	e8bfc023 	swc2	$31,-16349(a1)
 348:	0bbfc023 	j	eff008c <data_size+0xefefea8>
 34c:	00000045 	0x45
 350:	4f0c0000 	c3	0x10c0000
 354:	00000000 	nop
 358:	04bfc024 	0x4bfc024
 35c:	01bfc024 	and	t8,t5,ra
 360:	24000a1b 	li	zero,2587
 364:	2404bfc0 	li	a0,-16448
 368:	610bbfc0 	0x610bbfc0
 36c:	00000000 	nop
 370:	c9000000 	lwc2	$0,0(t0)
 374:	02000000 	0x2000000
 378:	0001ef00 	sll	sp,at,0x1c
 37c:	82010400 	lb	at,1024(s0)
 380:	01000000 	0x1000000
 384:	000000d5 	0xd5
 388:	00000067 	0x67
 38c:	bfc02410 	0xbfc02410
 390:	bfc02660 	0xbfc02660
 394:	00000116 	0x116
 398:	04030402 	0x4030402
 39c:	00002207 	0x2207
 3a0:	07040300 	0x7040300
 3a4:	0000001d 	0x1d
 3a8:	00de0104 	0xde0104
 3ac:	02010000 	0x2010000
 3b0:	0000ad01 	0xad01
 3b4:	c0241000 	lwc0	$4,4096(at)
 3b8:	c02660bf 	lwc0	$6,24767(at)
 3bc:	0000c0bf 	0xc0bf
 3c0:	00011200 	sll	v0,at,0x8
 3c4:	0000ad00 	sll	s5,zero,0x14
 3c8:	6d660500 	0x6d660500
 3cc:	01010074 	0x1010074
 3d0:	000000b4 	0xb4
 3d4:	00000131 	0x131
 3d8:	00690706 	0x690706
 3dc:	00ad0301 	0xad0301
 3e0:	015a0000 	0x15a0000
 3e4:	63080000 	0x63080000
 3e8:	bf040100 	0xbf040100
 3ec:	07000000 	bltz	t8,3f0 <data_size+0x20c>
 3f0:	00677261 	0x677261
 3f4:	00c60501 	0xc60501
 3f8:	01780000 	0x1780000
 3fc:	61090000 	0x61090000
 400:	06010070 	bgez	s0,5c4 <data_size+0x3e0>
 404:	00000025 	move	zero,zero
 408:	07108d02 	bltzal	t8,fffe3814 <_etext+0x403e0fc4>
 40c:	07010077 	bgez	t8,5ec <data_size+0x408>
 410:	000000ad 	0xad
 414:	00000196 	0x196
 418:	0000cf0a 	0xcf0a
 41c:	00450100 	0x450100
 420:	6905040b 	0x6905040b
 424:	0c00746e 	jal	1d1b8 <data_size+0x1cfd4>
 428:	0000ba04 	0xba04
 42c:	00bf0d00 	0xbf0d00
 430:	01030000 	0x1030000
 434:	0000ec06 	0xec06
 438:	25040c00 	addiu	a0,t0,3072
 43c:	00000000 	nop
 440:	00000088 	0x88
 444:	02960002 	0x2960002
 448:	01040000 	0x1040000
 44c:	00000082 	srl	zero,zero,0x2
 450:	0000f101 	0xf101
 454:	00006700 	sll	t4,zero,0x1c
 458:	c0266000 	lwc0	$6,24576(at)
 45c:	c02690bf 	lwc0	$6,-28481(at)
 460:	0001c2bf 	0x1c2bf
 464:	07040200 	0x7040200
 468:	00000022 	neg	zero,zero
 46c:	1d070402 	0x1d070402
 470:	03000000 	0x3000000
 474:	0000e501 	0xe501
 478:	60080100 	0x60080100
 47c:	70bfc026 	0x70bfc026
 480:	f4bfc026 	0xf4bfc026
 484:	01000000 	0x1000000
 488:	0000596d 	0x596d
 48c:	00630400 	0x630400
 490:	00590801 	0x590801
 494:	54010000 	0x54010000
 498:	05040500 	0x5040500
 49c:	00746e69 	0x746e69
 4a0:	00e90106 	0xe90106
 4a4:	02010000 	0x2010000
 4a8:	00005901 	0x5901
 4ac:	c0267000 	lwc0	$6,28672(at)
 4b0:	c02690bf 	lwc0	$6,-28481(at)
 4b4:	000104bf 	0x104bf
 4b8:	00022200 	sll	a0,v0,0x8
 4bc:	00630700 	0x630700
 4c0:	00590101 	0x590101
 4c4:	02410000 	0x2410000
 4c8:	00000000 	nop
 4cc:	000000ab 	0xab
 4d0:	03100002 	0x3100002
 4d4:	01040000 	0x1040000
 4d8:	00000082 	srl	zero,zero,0x2
 4dc:	0000fb01 	0xfb01
 4e0:	00006700 	sll	t4,zero,0x1c
 4e4:	c0269000 	lwc0	$6,-28672(at)
 4e8:	c02748bf 	lwc0	$7,18623(at)
 4ec:	000200bf 	0x200bf
 4f0:	07040200 	0x7040200
 4f4:	00000022 	neg	zero,zero
 4f8:	1d070402 	0x1d070402
 4fc:	03000000 	0x3000000
 500:	00010701 	0x10701
 504:	01020100 	0x1020100
 508:	0000006f 	0x6f
 50c:	bfc02690 	0xbfc02690
 510:	bfc02718 	0xbfc02718
 514:	0000012c 	0x12c
 518:	00000254 	0x254
 51c:	0000006f 	0x6f
 520:	01007304 	0x1007304
 524:	00007601 	0x7601
 528:	00027300 	sll	t6,v0,0xc
 52c:	00630500 	0x630500
 530:	007c0301 	0x7c0301
 534:	029c0000 	0x29c0000
 538:	06000000 	bltz	s0,53c <data_size+0x358>
 53c:	6e690504 	0x6e690504
 540:	04070074 	0x4070074
 544:	0000007c 	0x7c
 548:	ec060102 	swc3	$6,258(zero)
 54c:	08000000 	j	0 <data_size-0x1e4>
 550:	00010201 	0x10201
 554:	010f0100 	0x10f0100
 558:	0000006f 	0x6f
 55c:	bfc02718 	0xbfc02718
 560:	bfc02748 	0xbfc02748
 564:	00000148 	0x148
 568:	000002af 	0x2af
 56c:	01007304 	0x1007304
 570:	0000760e 	0x760e
 574:	0002ce00 	sll	t9,v0,0x18
 578:	f7000000 	0xf7000000
 57c:	02000000 	0x2000000
 580:	00039700 	sll	s2,v1,0x1c
 584:	82010400 	lb	at,1024(s0)
 588:	01000000 	0x1000000
 58c:	00000111 	0x111
 590:	00000067 	0x67
 594:	bfc02750 	0xbfc02750
 598:	bfc02850 	0xbfc02850
 59c:	00000243 	sra	zero,zero,0x9
 5a0:	22070402 	addi	a3,s0,1026
 5a4:	02000000 	0x2000000
 5a8:	001d0704 	0x1d0704
 5ac:	01030000 	0x1030000
 5b0:	00000131 	0x131
 5b4:	d2010201 	0xd2010201
 5b8:	50000000 	0x50000000
 5bc:	50bfc027 	0x50bfc027
 5c0:	70bfc028 	0x70bfc028
 5c4:	e1000001 	swc0	$0,1(t0)
 5c8:	d2000002 	0xd2000002
 5cc:	04000000 	bltz	zero,5d0 <data_size+0x3ec>
 5d0:	01010076 	0x1010076
 5d4:	000000d9 	0xd9
 5d8:	00000301 	0x301
 5dc:	01007704 	0x1007704
 5e0:	0000d201 	0xd201
 5e4:	00036100 	sll	t4,v1,0x4
 5e8:	01360500 	0x1360500
 5ec:	01010000 	0x1010000
 5f0:	000000d2 	0xd2
 5f4:	000003cc 	syscall	0xf
 5f8:	00012c05 	0x12c05
 5fc:	d2010100 	0xd2010100
 600:	21000000 	addi	zero,t0,0
 604:	06000004 	bltz	s0,618 <data_size+0x434>
 608:	03010069 	0x3010069
 60c:	000000d2 	0xd2
 610:	0000044a 	0x44a
 614:	01006a06 	0x1006a06
 618:	0000d203 	sra	k0,zero,0x8
 61c:	00047300 	sll	t6,a0,0xc
 620:	00630600 	0x630600
 624:	00d20401 	0xd20401
 628:	049c0000 	0x49c0000
 62c:	62070000 	0x62070000
 630:	01006675 	0x1006675
 634:	0000e005 	0xe005
 638:	a8910300 	swl	s1,768(a0)
 63c:	011d087f 	0x11d087f
 640:	06010000 	bgez	s0,644 <data_size+0x460>
 644:	0000002c 	0x2c
 648:	000004ba 	0x4ba
 64c:	05040900 	0x5040900
 650:	00746e69 	0x746e69
 654:	23050402 	addi	a1,t8,1026
 658:	0a000001 	j	8000004 <data_size+0x7fffe20>
 65c:	000000f3 	0xf3
 660:	000000f0 	0xf0
 664:	0000f00b 	0xf00b
 668:	0c003f00 	jal	fc00 <data_size+0xfa1c>
 66c:	01020704 	0x1020704
 670:	0000ec06 	0xec06
	...

Disassembly of section .debug_abbrev:

00000000 <.debug_abbrev>:
   0:	10001101 	b	4408 <data_size+0x4224>
   4:	12011106 	beq	s0,at,4420 <data_size+0x423c>
   8:	1b080301 	0x1b080301
   c:	13082508 	beq	t8,t0,9430 <data_size+0x924c>
  10:	00000005 	0x5
  14:	25011101 	addiu	at,t0,4353
  18:	030b130e 	0x30b130e
  1c:	110e1b0e 	beq	t0,t6,6c58 <data_size+0x6a74>
  20:	10011201 	beq	zero,at,4828 <data_size+0x4644>
  24:	02000006 	srlv	zero,zero,s0
  28:	0b0b0024 	j	c2c0090 <data_size+0xc2bfeac>
  2c:	0e030b3e 	jal	80c2cf8 <data_size+0x80c2b14>
  30:	16030000 	bne	s0,v1,34 <data_size-0x1b0>
  34:	3a0e0300 	xori	t6,s0,0x300
  38:	490b3b0b 	0x490b3b0b
  3c:	04000013 	bltz	zero,8c <data_size-0x158>
  40:	0b0b0024 	j	c2c0090 <data_size+0xc2bfeac>
  44:	08030b3e 	j	c2cf8 <data_size+0xc2b14>
  48:	13050000 	beq	t8,a1,4c <data_size-0x198>
  4c:	0b0e0301 	j	c380c04 <data_size+0xc380a20>
  50:	3b0b3a0b 	xori	t3,t8,0x3a0b
  54:	0013010b 	0x13010b
  58:	000d0600 	sll	zero,t5,0x18
  5c:	0b3a0e03 	j	ce8380c <data_size+0xce83628>
  60:	13490b3b 	beq	k0,t1,2d50 <data_size+0x2b6c>
  64:	00000a38 	0xa38
  68:	3f012e07 	0x3f012e07
  6c:	3a0e030c 	xori	t6,s0,0x30c
  70:	490b3b0b 	0x490b3b0b
  74:	010b2013 	0x10b2013
  78:	08000013 	j	4c <data_size-0x198>
  7c:	0e030034 	jal	80c00d0 <data_size+0x80bfeec>
  80:	0b3b0b3a 	j	cec2ce8 <data_size+0xcec2b04>
  84:	00001349 	0x1349
  88:	31012e09 	andi	at,t0,0x2e09
  8c:	12011113 	beq	s0,at,44dc <data_size+0x42f8>
  90:	06408101 	bltz	s2,fffe0498 <_etext+0x403ddc48>
  94:	13010a40 	beq	t8,at,2998 <data_size+0x27b4>
  98:	340a0000 	li	t2,0x0
  9c:	02133100 	0x2133100
  a0:	0b000006 	j	c000018 <data_size+0xbfffe34>
  a4:	0c3f012e 	jal	fc04b8 <data_size+0xfc02d4>
  a8:	0b3a0e03 	j	ce8380c <data_size+0xce83628>
  ac:	13490b3b 	beq	k0,t1,2d9c <data_size+0x2bb8>
  b0:	01120111 	0x1120111
  b4:	40064081 	0x40064081
  b8:	0013010a 	0x13010a
  bc:	011d0c00 	0x11d0c00
  c0:	01111331 	0x1111331
  c4:	0b580112 	j	d600448 <data_size+0xd600264>
  c8:	00000b59 	0xb59
  cc:	11010b0d 	beq	t0,at,2d04 <data_size+0x2b20>
  d0:	00011201 	0x11201
  d4:	00340e00 	0x340e00
  d8:	0b3a0803 	j	ce8200c <data_size+0xce81e28>
  dc:	13490b3b 	beq	k0,t1,2dcc <data_size+0x2be8>
  e0:	00000602 	srl	zero,zero,0x18
  e4:	3100340f 	andi	zero,t0,0x340f
  e8:	10000013 	b	138 <data_size-0xac>
  ec:	0c3f012e 	jal	fc04b8 <data_size+0xfc02d4>
  f0:	0b3a0e03 	j	ce8380c <data_size+0xce83628>
  f4:	0c270b3b 	jal	9c2cec <data_size+0x9c2b08>
  f8:	01111349 	0x1111349
  fc:	40810112 	0x40810112
 100:	010a4006 	srlv	t0,t2,t0
 104:	11000013 	beqz	t0,154 <data_size-0x90>
 108:	0c3f012e 	jal	fc04b8 <data_size+0xfc02d4>
 10c:	0b3a0e03 	j	ce8380c <data_size+0xce83628>
 110:	0c270b3b 	jal	9c2cec <data_size+0x9c2b08>
 114:	01111349 	0x1111349
 118:	40810112 	0x40810112
 11c:	01064006 	srlv	t0,a2,t0
 120:	12000013 	beqz	s0,170 <data_size-0x74>
 124:	08030005 	j	c0014 <data_size+0xbfe30>
 128:	0b3b0b3a 	j	cec2ce8 <data_size+0xcec2b04>
 12c:	06021349 	0x6021349
 130:	0f130000 	jal	c4c0000 <data_size+0xc4bfe1c>
 134:	490b0b00 	0x490b0b00
 138:	00000013 	mtlo	zero
 13c:	25011101 	addiu	at,t0,4353
 140:	030b130e 	0x30b130e
 144:	110e1b0e 	beq	t0,t6,6d80 <data_size+0x6b9c>
 148:	10011201 	beq	zero,at,4950 <data_size+0x476c>
 14c:	02000006 	srlv	zero,zero,s0
 150:	0b0b0024 	j	c2c0090 <data_size+0xc2bfeac>
 154:	0e030b3e 	jal	80c2cf8 <data_size+0x80c2b14>
 158:	2e030000 	sltiu	v1,s0,0
 15c:	030c3f01 	0x30c3f01
 160:	3b0b3a0e 	xori	t3,t8,0x3a0e
 164:	490c270b 	0x490c270b
 168:	010b2013 	0x10b2013
 16c:	04000013 	bltz	zero,1bc <data_size-0x28>
 170:	08030034 	j	c00d0 <data_size+0xbfeec>
 174:	0b3b0b3a 	j	cec2ce8 <data_size+0xcec2b04>
 178:	00001349 	0x1349
 17c:	31012e05 	andi	at,t0,0x2e05
 180:	12011113 	beq	s0,at,45d0 <data_size+0x43ec>
 184:	06408101 	bltz	s2,fffe058c <_etext+0x403ddd3c>
 188:	13010a40 	beq	t8,at,2a8c <data_size+0x28a8>
 18c:	34060000 	li	a2,0x0
 190:	02133100 	0x2133100
 194:	07000006 	bltz	t8,1b0 <data_size-0x34>
 198:	0c3f012e 	jal	fc04b8 <data_size+0xfc02d4>
 19c:	0b3a0e03 	j	ce8380c <data_size+0xce83628>
 1a0:	0c270b3b 	jal	9c2cec <data_size+0x9c2b08>
 1a4:	01120111 	0x1120111
 1a8:	40064081 	0x40064081
 1ac:	08000006 	j	18 <data_size-0x1cc>
 1b0:	08030034 	j	c00d0 <data_size+0xbfeec>
 1b4:	0b3b0b3a 	j	cec2ce8 <data_size+0xcec2b04>
 1b8:	06021349 	0x6021349
 1bc:	1d090000 	0x1d090000
 1c0:	11133101 	beq	t0,s3,c5c8 <data_size+0xc3e4>
 1c4:	58011201 	0x58011201
 1c8:	010b590b 	0x10b590b
 1cc:	0a000013 	j	800004c <data_size+0x7fffe68>
 1d0:	0111010b 	0x111010b
 1d4:	00000112 	0x112
 1d8:	3100340b 	andi	zero,t0,0x340b
 1dc:	0c000013 	jal	4c <data_size-0x198>
 1e0:	1331011d 	beq	t9,s1,658 <data_size+0x474>
 1e4:	01120111 	0x1120111
 1e8:	0b590b58 	j	d642d60 <data_size+0xd642b7c>
 1ec:	01000000 	0x1000000
 1f0:	0e250111 	jal	8940444 <data_size+0x8940260>
 1f4:	0e030b13 	jal	80c2c4c <data_size+0x80c2a68>
 1f8:	01110e1b 	0x1110e1b
 1fc:	06100112 	bltzal	s0,648 <data_size+0x464>
 200:	0f020000 	jal	c080000 <data_size+0xc07fe1c>
 204:	000b0b00 	sll	at,t3,0xc
 208:	00240300 	0x240300
 20c:	0b3e0b0b 	j	cf82c2c <data_size+0xcf82a48>
 210:	00000e03 	sra	at,zero,0x18
 214:	3f012e04 	0x3f012e04
 218:	3a0e030c 	xori	t6,s0,0x30c
 21c:	270b3b0b 	addiu	t3,t8,15115
 220:	1113490c 	beq	t0,s3,12654 <data_size+0x12470>
 224:	81011201 	lb	at,4609(t0)
 228:	06400640 	bltz	s2,1b2c <data_size+0x1948>
 22c:	00001301 	0x1301
 230:	03000505 	0x3000505
 234:	3b0b3a08 	xori	t3,t8,0x3a08
 238:	0213490b 	0x213490b
 23c:	06000006 	bltz	s0,258 <data_size+0x74>
 240:	00000018 	mult	zero,zero
 244:	03003407 	0x3003407
 248:	3b0b3a08 	xori	t3,t8,0x3a08
 24c:	0213490b 	0x213490b
 250:	08000006 	j	18 <data_size-0x1cc>
 254:	08030034 	j	c00d0 <data_size+0xbfeec>
 258:	0b3b0b3a 	j	cec2ce8 <data_size+0xcec2b04>
 25c:	00001349 	0x1349
 260:	03003409 	0x3003409
 264:	3b0b3a08 	xori	t3,t8,0x3a08
 268:	0213490b 	0x213490b
 26c:	0a00000a 	j	8000028 <data_size+0x7fffe44>
 270:	0e03000a 	jal	80c0028 <data_size+0x80bfe44>
 274:	0b3b0b3a 	j	cec2ce8 <data_size+0xcec2b04>
 278:	240b0000 	li	t3,0
 27c:	3e0b0b00 	0x3e0b0b00
 280:	0008030b 	0x8030b
 284:	000f0c00 	sll	at,t7,0x10
 288:	13490b0b 	beq	k0,t1,2eb8 <data_size+0x2cd4>
 28c:	260d0000 	addiu	t5,s0,0
 290:	00134900 	sll	t1,s3,0x4
 294:	11010000 	beq	t0,at,298 <data_size+0xb4>
 298:	130e2501 	beq	t8,t6,96a0 <data_size+0x94bc>
 29c:	1b0e030b 	0x1b0e030b
 2a0:	1201110e 	beq	s0,at,46dc <data_size+0x44f8>
 2a4:	00061001 	0x61001
 2a8:	00240200 	0x240200
 2ac:	0b3e0b0b 	j	cf82c2c <data_size+0xcf82a48>
 2b0:	00000e03 	sra	at,zero,0x18
 2b4:	3f012e03 	0x3f012e03
 2b8:	3a0e030c 	xori	t6,s0,0x30c
 2bc:	110b3b0b 	beq	t0,t3,eeec <data_size+0xed08>
 2c0:	81011201 	lb	at,4609(t0)
 2c4:	0a400640 	j	9001900 <data_size+0x900171c>
 2c8:	00001301 	0x1301
 2cc:	03000504 	0x3000504
 2d0:	3b0b3a08 	xori	t3,t8,0x3a08
 2d4:	0213490b 	0x213490b
 2d8:	0500000a 	bltz	t0,304 <data_size+0x120>
 2dc:	0b0b0024 	j	c2c0090 <data_size+0xc2bfeac>
 2e0:	08030b3e 	j	c2cf8 <data_size+0xc2b14>
 2e4:	2e060000 	sltiu	a2,s0,0
 2e8:	030c3f01 	0x30c3f01
 2ec:	3b0b3a0e 	xori	t3,t8,0x3a0e
 2f0:	490c270b 	0x490c270b
 2f4:	12011113 	beq	s0,at,4744 <data_size+0x4560>
 2f8:	06408101 	bltz	s2,fffe0700 <_etext+0x403ddeb0>
 2fc:	00000640 	sll	zero,zero,0x19
 300:	03000507 	0x3000507
 304:	3b0b3a08 	xori	t3,t8,0x3a08
 308:	0213490b 	0x213490b
 30c:	00000006 	srlv	zero,zero,zero
 310:	25011101 	addiu	at,t0,4353
 314:	030b130e 	0x30b130e
 318:	110e1b0e 	beq	t0,t6,6f54 <data_size+0x6d70>
 31c:	10011201 	beq	zero,at,4b24 <data_size+0x4940>
 320:	02000006 	srlv	zero,zero,s0
 324:	0b0b0024 	j	c2c0090 <data_size+0xc2bfeac>
 328:	0e030b3e 	jal	80c2cf8 <data_size+0x80c2b14>
 32c:	2e030000 	sltiu	v1,s0,0
 330:	030c3f01 	0x30c3f01
 334:	3b0b3a0e 	xori	t3,t8,0x3a0e
 338:	490c270b 	0x490c270b
 33c:	12011113 	beq	s0,at,478c <data_size+0x45a8>
 340:	06408101 	bltz	s2,fffe0748 <_etext+0x403ddef8>
 344:	13010640 	beq	t8,at,1c48 <data_size+0x1a64>
 348:	05040000 	0x5040000
 34c:	3a080300 	xori	t0,s0,0x300
 350:	490b3b0b 	0x490b3b0b
 354:	00060213 	0x60213
 358:	00340500 	0x340500
 35c:	0b3a0803 	j	ce8200c <data_size+0xce81e28>
 360:	13490b3b 	beq	k0,t1,3050 <data_size+0x2e6c>
 364:	00000602 	srl	zero,zero,0x18
 368:	0b002406 	j	c009018 <data_size+0xc008e34>
 36c:	030b3e0b 	0x30b3e0b
 370:	07000008 	bltz	t8,394 <data_size+0x1b0>
 374:	0b0b000f 	j	c2c003c <data_size+0xc2bfe58>
 378:	00001349 	0x1349
 37c:	3f012e08 	0x3f012e08
 380:	3a0e030c 	xori	t6,s0,0x30c
 384:	270b3b0b 	addiu	t3,t8,15115
 388:	1113490c 	beq	t0,s3,127bc <data_size+0x125d8>
 38c:	81011201 	lb	at,4609(t0)
 390:	06400640 	bltz	s2,1c94 <data_size+0x1ab0>
 394:	01000000 	0x1000000
 398:	0e250111 	jal	8940444 <data_size+0x8940260>
 39c:	0e030b13 	jal	80c2c4c <data_size+0x80c2a68>
 3a0:	01110e1b 	0x1110e1b
 3a4:	06100112 	bltzal	s0,7f0 <data_size+0x60c>
 3a8:	24020000 	li	v0,0
 3ac:	3e0b0b00 	0x3e0b0b00
 3b0:	000e030b 	0xe030b
 3b4:	012e0300 	0x12e0300
 3b8:	0e030c3f 	jal	80c30fc <data_size+0x80c2f18>
 3bc:	0b3b0b3a 	j	cec2ce8 <data_size+0xcec2b04>
 3c0:	13490c27 	beq	k0,t1,3460 <data_size+0x327c>
 3c4:	01120111 	0x1120111
 3c8:	40064081 	0x40064081
 3cc:	00130106 	0x130106
 3d0:	00050400 	sll	zero,a1,0x10
 3d4:	0b3a0803 	j	ce8200c <data_size+0xce81e28>
 3d8:	13490b3b 	beq	k0,t1,30c8 <data_size+0x2ee4>
 3dc:	00000602 	srl	zero,zero,0x18
 3e0:	03000505 	0x3000505
 3e4:	3b0b3a0e 	xori	t3,t8,0x3a0e
 3e8:	0213490b 	0x213490b
 3ec:	06000006 	bltz	s0,408 <data_size+0x224>
 3f0:	08030034 	j	c00d0 <data_size+0xbfeec>
 3f4:	0b3b0b3a 	j	cec2ce8 <data_size+0xcec2b04>
 3f8:	06021349 	0x6021349
 3fc:	34070000 	li	a3,0x0
 400:	3a080300 	xori	t0,s0,0x300
 404:	490b3b0b 	0x490b3b0b
 408:	000a0213 	0xa0213
 40c:	00340800 	0x340800
 410:	0b3a0e03 	j	ce8380c <data_size+0xce83628>
 414:	13490b3b 	beq	k0,t1,3104 <data_size+0x2f20>
 418:	00000602 	srl	zero,zero,0x18
 41c:	0b002409 	j	c009024 <data_size+0xc008e40>
 420:	030b3e0b 	0x30b3e0b
 424:	0a000008 	j	8000020 <data_size+0x7fffe3c>
 428:	13490101 	beq	k0,t1,830 <data_size+0x64c>
 42c:	00001301 	0x1301
 430:	4900210b 	bc2f	8860 <data_size+0x867c>
 434:	000b2f13 	0xb2f13
 438:	00240c00 	0x240c00
 43c:	0b3e0b0b 	j	cf82c2c <data_size+0xcf82a48>
 440:	Address 0x0000000000000440 is out of bounds.


Disassembly of section .comment:

00000000 <.comment>:
   0:	43434700 	c0	0x1434700
   4:	4728203a 	c1	0x128203a
   8:	2029554e 	addi	t1,at,21838
   c:	2e332e34 	sltiu	s3,s1,11828
  10:	47000030 	c1	0x1000030
  14:	203a4343 	addi	k0,at,17219
  18:	554e4728 	0x554e4728
  1c:	2e342029 	sltiu	s4,s1,8233
  20:	00302e33 	0x302e33
  24:	43434700 	c0	0x1434700
  28:	4728203a 	c1	0x128203a
  2c:	2029554e 	addi	t1,at,21838
  30:	2e332e34 	sltiu	s3,s1,11828
  34:	47000030 	c1	0x1000030
  38:	203a4343 	addi	k0,at,17219
  3c:	554e4728 	0x554e4728
  40:	2e342029 	sltiu	s4,s1,8233
  44:	00302e33 	0x302e33
  48:	43434700 	c0	0x1434700
  4c:	4728203a 	c1	0x128203a
  50:	2029554e 	addi	t1,at,21838
  54:	2e332e34 	sltiu	s3,s1,11828
  58:	47000030 	c1	0x1000030
  5c:	203a4343 	addi	k0,at,17219
  60:	554e4728 	0x554e4728
  64:	2e342029 	sltiu	s4,s1,8233
  68:	00302e33 	0x302e33
  6c:	43434700 	c0	0x1434700
  70:	4728203a 	c1	0x128203a
  74:	2029554e 	addi	t1,at,21838
  78:	2e332e34 	sltiu	s3,s1,11828
  7c:	Address 0x000000000000007c is out of bounds.


Disassembly of section .gnu.attributes:

00000000 <.gnu.attributes>:
   0:	00000f41 	0xf41
   4:	756e6700 	jalx	5b99c00 <data_size+0x5b99a1c>
   8:	00070100 	sll	zero,a3,0x4
   c:	03040000 	0x3040000

Disassembly of section .debug_frame:

00000000 <.debug_frame>:
   0:	0000000c 	syscall
   4:	ffffffff 	0xffffffff
   8:	7c010001 	0x7c010001
   c:	001d0c1f 	0x1d0c1f
  10:	0000000c 	syscall
  14:	00000000 	nop
  18:	bfc022a0 	0xbfc022a0
  1c:	0000000c 	syscall
  20:	0000000c 	syscall
  24:	00000000 	nop
  28:	bfc022ac 	0xbfc022ac
  2c:	0000000c 	syscall
  30:	0000000c 	syscall
  34:	00000000 	nop
  38:	bfc022b8 	0xbfc022b8
  3c:	0000000c 	syscall
  40:	0000000c 	syscall
  44:	00000000 	nop
  48:	bfc022c4 	0xbfc022c4
  4c:	00000018 	mult	zero,zero
  50:	00000014 	0x14
  54:	00000000 	nop
  58:	bfc022dc 	0xbfc022dc
  5c:	000000c8 	0xc8
  60:	44180e44 	0x44180e44
  64:	0000019f 	0x19f
  68:	0000000c 	syscall
  6c:	ffffffff 	0xffffffff
  70:	7c010001 	0x7c010001
  74:	001d0c1f 	0x1d0c1f
  78:	0000000c 	syscall
  7c:	00000068 	0x68
  80:	bfc023b0 	0xbfc023b0
  84:	0000000c 	syscall
  88:	0000000c 	syscall
  8c:	00000068 	0x68
  90:	bfc023bc 	0xbfc023bc
  94:	0000000c 	syscall
  98:	00000014 	0x14
  9c:	00000068 	0x68
  a0:	bfc023c8 	0xbfc023c8
  a4:	00000044 	0x44
  a8:	44180e48 	0x44180e48
  ac:	0000019f 	0x19f
  b0:	0000000c 	syscall
  b4:	ffffffff 	0xffffffff
  b8:	7c010001 	0x7c010001
  bc:	001d0c1f 	0x1d0c1f
  c0:	00000020 	add	zero,zero,zero
  c4:	000000b0 	0xb0
  c8:	bfc02410 	0xbfc02410
  cc:	00000250 	0x250
  d0:	60380e44 	0x60380e44
  d4:	07910890 	bgezal	gp,2318 <data_size+0x2134>
  d8:	04940692 	0x4940692
  dc:	02960395 	0x2960395
  e0:	0593019f 	0x593019f
  e4:	0000000c 	syscall
  e8:	ffffffff 	0xffffffff
  ec:	7c010001 	0x7c010001
  f0:	001d0c1f 	0x1d0c1f
  f4:	0000000c 	syscall
  f8:	000000e4 	0xe4
  fc:	bfc02660 	0xbfc02660
 100:	00000010 	mfhi	zero
 104:	00000014 	0x14
 108:	000000e4 	0xe4
 10c:	bfc02670 	0xbfc02670
 110:	00000020 	add	zero,zero,zero
 114:	44180e44 	0x44180e44
 118:	0000019f 	0x19f
 11c:	0000000c 	syscall
 120:	ffffffff 	0xffffffff
 124:	7c010001 	0x7c010001
 128:	001d0c1f 	0x1d0c1f
 12c:	00000018 	mult	zero,zero
 130:	0000011c 	0x11c
 134:	bfc02690 	0xbfc02690
 138:	00000088 	0x88
 13c:	50200e44 	0x50200e44
 140:	02920490 	0x2920490
 144:	0391019f 	0x391019f
 148:	00000014 	0x14
 14c:	0000011c 	0x11c
 150:	bfc02718 	0xbfc02718
 154:	00000030 	0x30
 158:	44180e44 	0x44180e44
 15c:	0000019f 	0x19f
 160:	0000000c 	syscall
 164:	ffffffff 	0xffffffff
 168:	7c010001 	0x7c010001
 16c:	001d0c1f 	0x1d0c1f
 170:	0000001c 	0x1c
 174:	00000160 	0x160
 178:	bfc02750 	0xbfc02750
 17c:	00000100 	sll	zero,zero,0x4
 180:	54680e44 	0x54680e44
 184:	04910590 	bgezal	a0,17c8 <data_size+0x15e4>
 188:	0392019f 	0x392019f
 18c:	00000293 	0x293

Disassembly of section .debug_loc:

00000000 <.debug_loc>:
   0:	00000004 	sllv	zero,zero,zero
   4:	00000004 	sllv	zero,zero,zero
   8:	00520001 	0x520001
   c:	00000000 	nop
  10:	10000000 	b	14 <data_size-0x1d0>
  14:	10000000 	b	18 <data_size-0x1cc>
  18:	01000000 	0x1000000
  1c:	00005200 	sll	t2,zero,0x8
  20:	00000000 	nop
  24:	001c0000 	sll	zero,gp,0x0
  28:	001c0000 	sll	zero,gp,0x0
  2c:	00010000 	sll	zero,at,0x0
  30:	00000052 	0x52
  34:	00000000 	nop
  38:	00002c00 	sll	a1,zero,0x10
  3c:	00003400 	sll	a2,zero,0x10
  40:	52000100 	0x52000100
	...
  4c:	0000003c 	0x3c
  50:	00000040 	sll	zero,zero,0x1
  54:	406d0001 	0x406d0001
  58:	04000000 	bltz	zero,5c <data_size-0x188>
  5c:	02000001 	0x2000001
  60:	00188d00 	sll	s1,t8,0x14
  64:	00000000 	nop
  68:	3c000000 	lui	zero,0x0
  6c:	80000000 	lb	zero,0(zero)
  70:	01000000 	0x1000000
  74:	00005400 	sll	t2,zero,0x10
  78:	00000000 	nop
  7c:	003c0000 	0x3c0000
  80:	00680000 	0x680000
  84:	00010000 	sll	zero,at,0x0
  88:	00006855 	0x6855
  8c:	0000f400 	sll	s8,zero,0x10
  90:	5a000100 	0x5a000100
	...
  9c:	0000004c 	syscall	0x1
  a0:	000000b0 	0xb0
  a4:	00560001 	0x560001
  a8:	00000000 	nop
  ac:	04000000 	bltz	zero,b0 <data_size-0x134>
  b0:	04000000 	bltz	zero,b4 <data_size-0x130>
  b4:	01000000 	0x1000000
  b8:	00005200 	sll	t2,zero,0x8
  bc:	00000000 	nop
  c0:	00100000 	sll	zero,s0,0x0
  c4:	00100000 	sll	zero,s0,0x0
  c8:	00010000 	sll	zero,at,0x0
  cc:	00000052 	0x52
  d0:	00000000 	nop
  d4:	00001800 	sll	v1,zero,0x0
  d8:	00002000 	sll	a0,zero,0x0
  dc:	6d000100 	0x6d000100
  e0:	00000020 	add	zero,zero,zero
  e4:	0000005c 	0x5c
  e8:	188d0002 	0x188d0002
	...
  f4:	00000038 	0x38
  f8:	00000040 	sll	zero,zero,0x1
  fc:	54550001 	0x54550001
 100:	5c000000 	0x5c000000
 104:	01000000 	0x1000000
 108:	00005500 	sll	t2,zero,0x14
	...
 114:	00040000 	sll	zero,a0,0x0
 118:	00010000 	sll	zero,at,0x0
 11c:	0000046d 	0x46d
 120:	00025000 	sll	t2,v0,0x0
 124:	8d000200 	lw	zero,512(t0)
 128:	00000038 	0x38
	...
 134:	00003000 	sll	a2,zero,0x0
 138:	54000100 	0x54000100
 13c:	00000030 	0x30
 140:	000000a4 	0xa4
 144:	b8630001 	swr	v1,1(v1)
 148:	50000000 	0x50000000
 14c:	01000002 	0x1000002
 150:	00006300 	sll	t4,zero,0xc
 154:	00000000 	nop
 158:	00540000 	0x540000
 15c:	00ac0000 	0xac0000
 160:	00010000 	sll	zero,at,0x0
 164:	0000b861 	0xb861
 168:	00025000 	sll	t2,v0,0x0
 16c:	61000100 	0x61000100
	...
 178:	0000004c 	syscall	0x1
 17c:	000000a8 	0xa8
 180:	b8620001 	swr	v0,1(v1)
 184:	50000000 	0x50000000
 188:	01000002 	0x1000002
 18c:	00006200 	sll	t4,zero,0x8
 190:	00000000 	nop
 194:	00c00000 	0xc00000
 198:	00dc0000 	0xdc0000
 19c:	00010000 	sll	zero,at,0x0
 1a0:	0000e455 	0xe455
 1a4:	00012400 	sll	a0,at,0x10
 1a8:	55000100 	0x55000100
 1ac:	00000134 	0x134
 1b0:	00000144 	0x144
 1b4:	50550001 	0x50550001
 1b8:	5c000001 	0x5c000001
 1bc:	01000001 	0x1000001
 1c0:	01645500 	0x1645500
 1c4:	01740000 	0x1740000
 1c8:	00010000 	sll	zero,at,0x0
 1cc:	00018055 	0x18055
 1d0:	00019000 	sll	s2,at,0x0
 1d4:	55000100 	0x55000100
 1d8:	0000019c 	0x19c
 1dc:	000001ac 	0x1ac
 1e0:	b8550001 	swr	s5,1(v0)
 1e4:	c8000001 	lwc2	$0,1(zero)
 1e8:	01000001 	0x1000001
 1ec:	01d45500 	0x1d45500
 1f0:	01e00000 	0x1e00000
 1f4:	00010000 	sll	zero,at,0x0
 1f8:	0001e855 	0x1e855
 1fc:	0001f800 	sll	ra,at,0x0
 200:	55000100 	0x55000100
 204:	00000204 	0x204
 208:	0000020c 	syscall	0x8
 20c:	14550001 	bne	v0,s5,214 <data_size+0x30>
 210:	50000002 	0x50000002
 214:	01000002 	0x1000002
 218:	00005500 	sll	t2,zero,0x14
 21c:	00000000 	nop
 220:	00100000 	sll	zero,s0,0x0
 224:	00140000 	sll	zero,s4,0x0
 228:	00010000 	sll	zero,at,0x0
 22c:	0000146d 	0x146d
 230:	00003000 	sll	a2,zero,0x0
 234:	8d000200 	lw	zero,512(t0)
 238:	00000018 	mult	zero,zero
 23c:	00000000 	nop
 240:	00001000 	sll	v0,zero,0x0
 244:	00002000 	sll	a0,zero,0x0
 248:	54000100 	0x54000100
	...
 258:	00000004 	sllv	zero,zero,zero
 25c:	046d0001 	0x46d0001
 260:	88000000 	lwl	zero,0(zero)
 264:	02000000 	0x2000000
 268:	00208d00 	0x208d00
	...
 274:	24000000 	li	zero,0
 278:	01000000 	0x1000000
 27c:	00245400 	0x245400
 280:	007c0000 	0x7c0000
 284:	00010000 	sll	zero,at,0x0
 288:	00007c61 	0x7c61
 28c:	00008800 	sll	s1,zero,0x0
 290:	54000100 	0x54000100
	...
 29c:	0000001c 	0x1c
 2a0:	00000080 	sll	zero,zero,0x2
 2a4:	00600001 	0x600001
 2a8:	00000000 	nop
 2ac:	88000000 	lwl	zero,0(zero)
 2b0:	8c000000 	lw	zero,0(zero)
 2b4:	01000000 	0x1000000
 2b8:	008c6d00 	0x8c6d00
 2bc:	00b80000 	0xb80000
 2c0:	00020000 	sll	zero,v0,0x0
 2c4:	0000188d 	break	0x0,0x62
 2c8:	00000000 	nop
 2cc:	00880000 	0x880000
 2d0:	00980000 	0x980000
 2d4:	00010000 	sll	zero,at,0x0
 2d8:	00000054 	0x54
	...
 2e4:	00000400 	sll	zero,zero,0x10
 2e8:	6d000100 	0x6d000100
 2ec:	00000004 	sllv	zero,zero,zero
 2f0:	00000100 	sll	zero,zero,0x4
 2f4:	e88d0003 	swc2	$13,3(a0)
	...
 304:	00002800 	sll	a1,zero,0x0
 308:	54000100 	0x54000100
 30c:	00000028 	0x28
 310:	00000060 	0x60
 314:	68530001 	0x68530001
 318:	6c000000 	0x6c000000
 31c:	01000000 	0x1000000
 320:	006c5300 	0x6c5300
 324:	00980000 	0x980000
 328:	00010000 	sll	zero,at,0x0
 32c:	0000ac54 	0xac54
 330:	0000d400 	sll	k0,zero,0x10
 334:	54000100 	0x54000100
 338:	000000e8 	0xe8
 33c:	000000e8 	0xe8
 340:	e8540001 	swc2	$20,1(v0)
 344:	f0000000 	0xf0000000
 348:	01000000 	0x1000000
 34c:	00f85300 	0xf85300
 350:	00f80000 	0xf80000
 354:	00010000 	sll	zero,at,0x0
 358:	00000053 	0x53
	...
 364:	00002800 	sll	a1,zero,0x0
 368:	55000100 	0x55000100
 36c:	00000028 	0x28
 370:	00000098 	0x98
 374:	98630001 	lwr	v1,1(v1)
 378:	a4000000 	sh	zero,0(zero)
 37c:	01000000 	0x1000000
 380:	00ac5500 	0xac5500
 384:	00b80000 	0xb80000
 388:	00010000 	sll	zero,at,0x0
 38c:	0000b863 	0xb863
 390:	0000cc00 	sll	t9,zero,0x10
 394:	55000100 	0x55000100
 398:	000000cc 	syscall	0x3
 39c:	000000d4 	0xd4
 3a0:	d4630001 	0xd4630001
 3a4:	e8000000 	swc2	$0,0(zero)
 3a8:	01000000 	0x1000000
 3ac:	00e85500 	0xe85500
 3b0:	00f80000 	0xf80000
 3b4:	00010000 	sll	zero,at,0x0
 3b8:	0000f863 	0xf863
 3bc:	00010000 	sll	zero,at,0x0
 3c0:	55000100 	0x55000100
	...
 3d0:	00000028 	0x28
 3d4:	28560001 	slti	s6,v0,1
 3d8:	88000000 	lwl	zero,0(zero)
 3dc:	01000000 	0x1000000
 3e0:	00886200 	0x886200
 3e4:	00a40000 	0xa40000
 3e8:	00010000 	sll	zero,at,0x0
 3ec:	0000ac56 	0xac56
 3f0:	0000bc00 	sll	s7,zero,0x10
 3f4:	62000100 	0x62000100
 3f8:	000000bc 	0xbc
 3fc:	000000e8 	0xe8
 400:	e8560001 	swc2	$22,1(v0)
 404:	f8000000 	0xf8000000
 408:	01000000 	0x1000000
 40c:	00f86200 	0xf86200
 410:	01000000 	0x1000000
 414:	00010000 	sll	zero,at,0x0
 418:	00000056 	0x56
	...
 424:	0000a400 	sll	s4,zero,0x10
 428:	57000100 	0x57000100
 42c:	000000ac 	0xac
 430:	000000f0 	0xf0
 434:	f8570001 	0xf8570001
 438:	00000000 	nop
 43c:	01000001 	0x1000001
 440:	00005700 	sll	t2,zero,0x1c
 444:	00000000 	nop
 448:	003c0000 	0x3c0000
 44c:	00c00000 	0xc00000
 450:	00010000 	sll	zero,at,0x0
 454:	0000cc61 	0xcc61
 458:	0000e800 	sll	sp,zero,0x0
 45c:	61000100 	0x61000100
 460:	000000f8 	0xf8
 464:	00000100 	sll	zero,zero,0x4
 468:	00610001 	0x610001
 46c:	00000000 	nop
 470:	6c000000 	0x6c000000
 474:	a4000000 	sh	zero,0(zero)
 478:	01000000 	0x1000000
 47c:	00ac5300 	0xac5300
 480:	00e80000 	0xe80000
 484:	00010000 	sll	zero,at,0x0
 488:	0000f853 	0xf853
 48c:	00010000 	sll	zero,at,0x0
 490:	53000100 	0x53000100
	...
 49c:	000000d4 	0xd4
 4a0:	000000e0 	0xe0
 4a4:	f8540001 	0xf8540001
 4a8:	f8000000 	0xf8000000
 4ac:	01000000 	0x1000000
 4b0:	00005400 	sll	t2,zero,0x10
 4b4:	00000000 	nop
 4b8:	00340000 	0x340000
 4bc:	00800000 	0x800000
 4c0:	00010000 	sll	zero,at,0x0
 4c4:	0000ac60 	0xac60
 4c8:	0000c400 	sll	t8,zero,0x10
 4cc:	60000100 	0x60000100
 4d0:	000000e8 	0xe8
 4d4:	000000f8 	0xf8
 4d8:	00600001 	0x600001
 4dc:	00000000 	nop
 4e0:	Address 0x00000000000004e0 is out of bounds.


Disassembly of section .debug_str:

00000000 <.debug_str>:
   0:	7465675f 	jalx	1959d7c <data_size+0x1959b98>
   4:	756f635f 	jalx	5bd8d7c <data_size+0x5bd8b98>
   8:	7400746e 	jalx	1d1b8 <data_size+0x1cfd4>
   c:	73656d69 	0x73656d69
  10:	00636570 	0x636570
  14:	6f6c635f 	0x6f6c635f
  18:	745f6b63 	jalx	17dad8c <data_size+0x17daba8>
  1c:	6e6f6c00 	0x6e6f6c00
  20:	6e752067 	0x6e752067
  24:	6e676973 	0x6e676973
  28:	69206465 	0x69206465
  2c:	7400746e 	jalx	1d1b8 <data_size+0x1cfd4>
  30:	736d5f76 	0x736d5f76
  34:	67006365 	0x67006365
  38:	6e5f7465 	0x6e5f7465
  3c:	69740073 	0x69740073
  40:	632e656d 	0x632e656d
  44:	6f635f00 	0x6f635f00
  48:	6176746e 	0x6176746e
  4c:	6567006c 	0x6567006c
  50:	6c635f74 	0x6c635f74
  54:	006b636f 	0x6b636f
  58:	755f7674 	jalx	57dd9d0 <data_size+0x57dd7ec>
  5c:	00636573 	0x636573
  60:	735f7674 	0x735f7674
  64:	2f006365 	sltiu	zero,t8,25445
  68:	746f6f72 	jalx	1bdbdc8 <data_size+0x1bdbbe4>
  6c:	62616c2f 	0x62616c2f
  70:	656d5f35 	0x656d5f35
  74:	79726f6d 	0x79726f6d
  78:	6d61675f 	0x6d61675f
  7c:	696c2f65 	0x696c2f65
  80:	4e470062 	c3	0x470062
  84:	20432055 	addi	v1,v0,8277
  88:	2e332e34 	sltiu	s3,s1,11828
  8c:	672d2030 	0x672d2030
  90:	5f767400 	0x5f767400
  94:	6365736e 	0x6365736e
  98:	6f6c6300 	0x6f6c6300
  9c:	675f6b63 	0x675f6b63
  a0:	69747465 	0x69747465
  a4:	6700656d 	0x6700656d
  a8:	635f7465 	0x635f7465
  ac:	65737561 	0x65737561
  b0:	63786500 	0x63786500
  b4:	69747065 	0x69747065
  b8:	632e6e6f 	0x632e6e6f
  bc:	74656700 	jalx	1959c00 <data_size+0x1959a1c>
  c0:	6370655f 	0x6370655f
  c4:	63786500 	0x63786500
  c8:	69747065 	0x69747065
  cc:	61006e6f 	0x61006e6f
  d0:	6e696167 	0x6e696167
  d4:	69727000 	0x69727000
  d8:	2e66746e 	sltiu	a2,s3,29806
  dc:	72700063 	0x72700063
  e0:	66746e69 	0x66746e69
  e4:	74677400 	jalx	19dd000 <data_size+0x19dce1c>
  e8:	7475705f 	jalx	1d5c17c <data_size+0x1d5bf98>
  ec:	72616863 	0x72616863
  f0:	74757000 	jalx	1d5c000 <data_size+0x1d5be1c>
  f4:	72616863 	0x72616863
  f8:	7000632e 	0x7000632e
  fc:	2e737475 	sltiu	s3,s3,29813
 100:	75700063 	jalx	5c0018c <data_size+0x5bfffa8>
 104:	70007374 	0x70007374
 108:	74737475 	jalx	1cdd1d4 <data_size+0x1cdcff0>
 10c:	676e6972 	0x676e6972
 110:	69727000 	0x69727000
 114:	6162746e 	0x6162746e
 118:	632e6573 	0x632e6573
 11c:	6c617600 	0x6c617600
 120:	6c006575 	0x6c006575
 124:	20676e6f 	addi	a3,v1,28271
 128:	00746e69 	0x746e69
 12c:	6e676973 	0x6e676973
 130:	69727000 	0x69727000
 134:	6162746e 	0x6162746e
 138:	Address 0x0000000000000138 is out of bounds.

