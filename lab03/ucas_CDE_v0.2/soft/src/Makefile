ver = test_nodelay_ram
#ver = test_delay_ram
#ver = sim

TOPDIR=$(shell pwd)

export LD_PRELOAD =
CFLAGS := -D_KERNEL -DCONFIG_PAGE_SIZE_16KB -fno-builtin -mips1 -DCACHELOCK_MEM -DMEMSTART=0x80000000 -DMEMSIZE=0x01000 -DCPU_COUNT_PER_US=10 -I $(TOPDIR)/include -include common.h -DAPB_CLK=33333333
CFLAGS += -DLS1FSOC  -DCPU_MULT=6 -DDDR_MULT=6 $(ALIGNED) 
#CFLAGS += -fno-reorder-blocks -fno-reorder-funcions

ifeq ($(ver), test_delay_ram)
CFLAGS += -DTEST_DELAY_RAM
else ifeq ($(ver), sim)
CFLAGS += -DSIM
endif


export TOPDIR AR CFLAGS

export CROSS_COMPILE ?= mipsel-linux-

ifeq ($(ver), test_delay_ram)
all: main.bin main.data convert
	./convert
	cp *.coe ../delay_ram_coe/.
	cp *.mif ../delay_ram_coe/.
else ifeq ($(ver), sim)
all: main.bin main.data convert
	./convert
	cp *.coe ../sim_ram_coe/.
	cp *.mif ../sim_ram_coe/.
else
all: main.bin main.data convert
	./convert
	cp *.coe ../nodelay_ram_coe/.
	cp *.mif ../nodelay_ram_coe/.
endif

libinst.a:
	make -C inst $(TOPDIR)/$@


%.elf: start.o libinst.a 
	${CROSS_COMPILE}gcc -E -P -Umips -D_LOADER -U_MAIN $(CFLAGS) bin.lds.S -o bin.lds
	${CROSS_COMPILE}ld -g -T  bin.lds  -o $@ start.o -L . -linst
	${CROSS_COMPILE}objdump -alD $@ > test.s

main.bin:main.elf
	${CROSS_COMPILE}objcopy -O binary -j .text $< $@ 

main.data:main.elf
	${CROSS_COMPILE}objcopy -O binary -j .data $< $@ 

convert:convert.c
	gcc  $(ALIGNED) -o convert  convert.c

clean:
	rm -f *.o *.bin *.data *.elf *.a *.s *.vlog *.coe *.mif bin.lds convert
	make -C inst clean

-include rules.make
