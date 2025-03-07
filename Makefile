CROSS_PREFIX=aarch64-linux-gnu-

all: test64.elf

test64.o: test64.c
	$(CROSS_PREFIX)gcc -c -g $< -o $@

startup64.o: startup64.s
	$(CROSS_PREFIX)as -c $< -o $@

# 这里的 -Txx.ld 跟随的是自定义的链接脚本，排布一下程序的布局
test64.elf: test64.o startup64.o
	$(CROSS_PREFIX)ld -Ttest64.ld $^ -o $@

# 从ELF生成二进制文件raw data
# bin -- Removes all ELF headers, symbols, and metadata
#        ELF: More debugging information, easier development
# Creates a "flat" binary file
# 常见于 embedded systems and bootloaders
# QEMU可以直接运行这两种 raw flat bin 或者 ELF文件
test64.bin: test64.elf
	$(CROSS_PREFIX)objcopy -O binary $< $@

clean:
	rm -f test64.elf startup64.o test64.o
