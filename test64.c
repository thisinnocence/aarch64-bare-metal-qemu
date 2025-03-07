// `volatile` Tells compiler not to optimize/cache the value
//   Every access hits the actual hardware register
//   Forces read/write to actual memory location
// 因为IO地址和MEM地址都是统一物理地址空间，统一的访存指令，
// 所以编译器默认都会按照是MEM来优化，对吧，所以一定要加 volatile 关键字对于 IO
// REG 如果是访问Memory, 访问顺序可以重排（在不影响程序逻辑的前提下）

volatile unsigned int *const UART0DR = (unsigned int *)0x09000000;

void print_uart0(const char *s)
{
    while (*s != '\0') {
        *UART0DR = (unsigned int)(*s);
        s++;
    }
}

// CPU下电，让QEMU正常的退出， 0x84000008 -- SYSTEM_OFF
void psci_system_off(void)
{
    // Use movz/movk to load the large constant
    // movz: 将寄存器其他位清零，加载指定值
    // movk: 保持其他位不变，在指定位置加载值
    //       lsl #16: imm左移16位(Logical Shift Left)，其他位不变，写入x0
    __asm__ volatile(
          "movz x0, #0x0008\n"           // Load lower 16 bits
          "movk x0, #0x8400, lsl #16\n"  // Load upper 16 bits
          "hvc #0\n"                     // Hypervisor call
          :                              // 第一个冒号: 输出操作数
          :                              // 第二个冒号: 输入操作数
          : "x0"                         // 第三个冒号: 被修改的寄存器列表
    );
}

void c_entry()
{
    print_uart0("Hello world!\n");
    psci_system_off();
}
