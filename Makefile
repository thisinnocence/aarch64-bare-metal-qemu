osname := $(shell uname -s)

ifeq ($(osname), Linux)
CROSS_PREFIX=aarch64-linux-gnu-
else
CROSS_PREFIX=aarch64-none-elf-
endif

all: test64.elf

test64.o: test64.c
	$(CROSS_PREFIX)gcc -c $< -o $@

startup64.o: startup64.s
	$(CROSS_PREFIX)as -c $< -o $@

test64.elf: test64.o startup64.o
	$(CROSS_PREFIX)ld -Ttest64.ld $^ -o $@

test64.bin: test64.elf
	$(CROSS_PREFIX)objcopy -O binary $< $@

clean:
	rm -f test64.elf startup64.o test64.o
