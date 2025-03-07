/*
 * AArch64 Bare Metal Link Script
 * This script defines how the sections of the program should be organized in memory
 * 
 * Key points:
 * - Program starts execution at 0x40000000 (typical for QEMU virt machine)
 * - Defines the entry point as _Reset
 * - Organizes code (.text), data (.data), and uninitialized data (.bss)
 * - Allocates 4kB for stack at the end
 */

/**
 *  1. ENTRY 关键字命令用于指定程序执行的第一条指令的位置, 告诉链接器程序从哪里开始执行
 *  2. _Reset 这是一个用户定义的符号，通常在汇编代码中定义
 *            必须在某个源文件（通常是启动文件）中定义这个标签
 *  3. SECTIONS 是链接器脚本中的一个关键字命令，它定义了输出文件中各节（sections）的布局
 */
ENTRY(_Reset)  /* Define program entry point */
SECTIONS
{
	/**
	 *   `.`是一个特殊符号，称为位置计数器（Location Counter）
	 *   表示链接器当前正在处理的内存地址, 可以读取和修改这个值, 可以读取和赋值
	 */
    . = 0x40000000;     /* Set location counter to base address */
    
	/**
	 *  `.startup` 自定义节的名字
	 *  `.` 指定节的地址, 这里使用当前位置计数器的值
	 *  startup64.o 就是特定的目标文件
	 *  (.text) 从该文件中提取的节，只包含对应的代码段
	 *  确保 startup64.o 中的代码位于内存最前面，将启动代码与普通程序代码分开
	 */
    .startup . : {      /* Startup section containing boot code */
        startup64.o(.text)
    }
    
	/**
	 *  1. "*" 是一个通配符，表示"所有输入文件"
	 *  2. 从每个文件中提取 .text 段
	 *  3. 将所有这些 .text 段合并到输出文件的 .text 段中
	 *  4. 跟前面的bootcode不同，这里不指定地址，让链接器自己算，链接器会自动将各个节连续放置
	 */
    .text : {          /* Code section */
        *(.text)
    }
    
    .data : {          /* Initialized data section */
        *(.data)
    }
    
    .bss : {           /* Uninitialized data section */
        *(.bss COMMON)
    }
    
	/**
	 *  1. ALIGN(8) 命令用于将当前位置计数器的值向上舍入到最接近的8字节边界
	 *  2. 预留4k，用于栈，栈从高地址往低地址增加
	 *  3. stack_top 是一个符号，表示栈的顶部，汇编代码中用到
	 */ 
    . = ALIGN(8);      /* Align to 8-byte boundary */
    . = . + 0x1000;    /* Reserve 4kB for stack */
    stack_top = .;     /* Define stack_top symbol at current position */
}
