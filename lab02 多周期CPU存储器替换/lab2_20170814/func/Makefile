simu_test = 1

TOPDIR=$(shell pwd)

export LD_PRELOAD =
CFLAGS := -D_KERNEL -fno-builtin -mips1 -DMEMSTART=0x80000000 -DMEMSIZE=0x04000 -DCPU_COUNT_PER_US=1000 -I $(TOPDIR)/include 
CFLAGS += -fno-reorder-blocks -fno-reorder-functions

ifeq ($(simu_test), 1)
CFLAGS += -DSIM
OBJDIR = ./obj/sim_test_ram
else
CFLAGS += -DSYN
OBJDIR = ./obj/syn_test_ram
endif


export TOPDIR AR CFLAGS
export CROSS_COMPILE ?= mipsel-linux-

all:
	make clean
	make compile

compile:main.bin main.data convert
	./convert
	mkdir -p $(OBJDIR)
	mv main.elf  $(OBJDIR)/.
	mv test.s    $(OBJDIR)/.
	mv main.bin  $(OBJDIR)/.
	mv main.data $(OBJDIR)/.
	mv *.coe     $(OBJDIR)/.
	mv *.mif     $(OBJDIR)/.

main.bin:main.elf
	${CROSS_COMPILE}objcopy -O binary -j .text $< $@ 

main.data:main.elf
	${CROSS_COMPILE}objcopy -O binary -j .data $< $@ 

main.elf: start.o libinst.a 
	${CROSS_COMPILE}gcc -E -P -Umips -D_LOADER -U_MAIN $(CFLAGS) bin.lds.S -o bin.lds
	${CROSS_COMPILE}ld -g -T  bin.lds  -o $@ start.o -L . -linst
	${CROSS_COMPILE}objdump -alD $@ > test.s

libinst.a:
	make -C inst $(TOPDIR)/$@

convert:convert.c
	gcc  $(ALIGNED) -o convert  convert.c

clean:
	rm -f *.o *.a bin.lds convert
	make -C inst clean

reset:
	make clean
	rm -rf obj

help:
	@echo "##############################################################"
	@echo "### help for comipling func"
	@echo "##############################################################"
	@echo "### the comipled result of is in ./obj/,"
	@echo "### the result for simulation is different from synthesis,"
	@echo "### the difference is only in func \"wait_1s\". "
	@echo "##############################################################"
	@echo "### options:"
	@echo "###     make            : get comipled result for simulation"
	@echo "###                       the result is in ./obj/sim_test_ram/"
	@echo "###     make simu_test=1: same as \"make\""
	@echo "###     make simu_test=0: get comipled result for synthesis"
	@echo "###                       the result is in ./obj/syn_test_ram/"
	@echo "###     make clean      : remove *.o, *.a, convert, bin.ld"
	@echo "###     make reset      : "make clean" and remove /obj/"
	@echo "###     make help       : show help information"
	@echo "##############################################################"

-include rules.make
