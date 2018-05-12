export LD_PRELOAD =

##set your cpu frequency
##if your cpu is 33MHz, set 33
CPU_Freq_MHz= 50

CFLAGS := -D_KERNEL -DCONFIG_PAGE_SIZE_16KB -fno-builtin -mips1 -DCACHELOCK_MEM -DMEMSTART=0x80000000 -DMEMSIZE=0x04000 -DTIMER_COUNT_PER_US=100 -I include -include common.h -DAPB_CLK=33333333
CFLAGS += -DLS1FSOC -msoft-float 
CFLAGS += -DCPU_COUNT_PER_US=$(CPU_Freq_MHz)

OBJDIR = obj

export AR CFLAGS CPU_Freq_MHz
export CROSS_COMPILE ?= mipsel-linux-

GAME_TARGET = ./memory_game/memory_main.o

all:
	mkdir -p $(OBJDIR)
	make generate

libtinyc.a :
	make -C lib $@

generate: main.bin main.data convert
	./convert main.bin main.data $(OBJDIR)/

main.bin: main.elf
	${CROSS_COMPILE}objcopy -O binary -j .text $(OBJDIR)/$< $(OBJDIR)/$@ 
main.data: main.elf
	${CROSS_COMPILE}objcopy -O binary -j .data $(OBJDIR)/$< $(OBJDIR)/$@ 

main.elf: start.o libtinyc.a bin.lds $(GAME_TARGET)
	${CROSS_COMPILE}ld -g -T bin.lds start.o $(GAME_TARGET) lib/libtinyc.a -o $(OBJDIR)/$@
	${CROSS_COMPILE}objdump -alD $(OBJDIR)/$(BENCH_DIR)/$@ > $(OBJDIR)/$(BENCH_DIR)/test.s

$(GAME_TARGET):
	make -C memory_game

bin.lds: bin.lds.S
	${CROSS_COMPILE}gcc -E -P -Umips -D_LOADER -U_MAIN $(CFLAGS) $< -o $@

start.o: start.S
	${CROSS_COMPILE}gcc -O2 $(CFLAGS) -fno-pic -mno-abicalls -g -DGUEST -I ../include -c $< -nostdinc -nostdlib

convert: convert.c
	gcc -o convert convert.c
clean:
	rm -f *.o *.a 
	rm -rf obj
	make -C lib clean
	make -C memory_game clean
reset:
	make clean
	rm -f bin.lds convert

help:
	@echo "################################################################"
	@echo "### help for compiling memory game"
	@echo "################################################################"
	@echo "### options:"
	@echo "###     make      : get compiled result, which is saved in ./obj"
	@echo "###     make clean: remove *.o, *.a, and ./obj"
	@echo "###     make reset: "make clean" and remove convert, bin.lds"
	@echo "###     make help : show help information"
	@echo "###############################################################"

#-include rules.make
