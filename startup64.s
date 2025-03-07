/*
 * AArch64 Bare Metal Startup Code
 * 
 * Purpose:
 * - Initializes the stack pointer
 * - Jumps to C entry point
 * - Provides system startup functionality
 * 
 * Key Functions:
 * - _Reset: Entry point defined in linker script
 * - Sets up stack using stack_top symbol from linker
 * - Calls c_entry function (main C code entry)
 * - Implements infinite loop after return
 */

    // 缩进不是必须只是一种风格
    .global _Reset        // Make _Reset symbol visible to linker

_Reset:
    // ldr大的立即数的时候，这个是个汇编伪指令，汇编器会进行编译
    //   汇编器会在代码附近创建一个字面量池
    //   将大立即数存储在这个池中, 使用 PC 相对寻址加载这些值
    //   最终将正确的地址值放入 x30 寄存器, 比如这个编译后 objdump 看
    //      40000000:   5800009e        ldr     x30, 40000010 <_Reset+0x10>
    //      40000010:   400010e8        .word   0x400010e8
    ldr x30, =stack_top  // Load address of stack_top into x30
                         // stack_top symbol defined in linker script
    
    // ARM64 对 SP 的操作有特殊限制,不能用 ldr 直接加载
    // ARM64 指令中的立即数字段长度有限, 是 32bit 指令编码里的部分bit位域
    // sp = x30, mov to sp from x30
    mov sp, x30          // Initialize stack pointer (SP) with stack_top address
                         // Now we have a valid stack for function calls
    
    // Saves return address in x30 (Link Register, LR)
    // When c_entry returns, it uses x30 to return here
    bl c_entry           // Branch with link to c_entry function
                         // This will be our main C code entry point
    
    b .                  // Infinite loop after return
                         // '.' means current address, so branch to self
