## OS Lab0.5+Lab1

### Lab0.5:

#### 练习1：使用GDB验证启动流程

##### 为了熟悉使用qemu和gdb进行调试工作,使用gdb调试QEMU模拟的RISC-V计算机加电开始运行到执行应用程序的第一条指令（即跳转到0x80200000）这个阶段的执行过程，说明RISC-V硬件加电后的几条指令在哪里？完成了哪些功能？要求在报告中简要写出练习过程和回答。

打开两个终端，先在其中一个终端输入`make debug`，运行qemu并等待gdb连接，再在另一个终端输入`make gdb`，连接到端口1234并进行调试。

在gdb中输入`x/10i $pc `，得到接下来要运行的十条汇编指令如下所示：

```assembly
0x1000:	auipc	t0,0x0
0x1004:	addi	a1,t0,32
0x1008:	csrr	a0,mhartid
0x100c:	ld	t0,24(t0)
0x1010:	jr	t0
0x1014:	unimp
0x1016:	unimp
0x1018:	unimp
0x101a:	0x8000
0x101c:	unimp
```

可以看出，在QEMU模拟的RISC-V计算机加电开始运行后，跳转到了0x1000地址处开始执行命令，我们现在想知道的是程序怎么运行0x80200000处，观察上述汇编指令不难看到0x100c处有一条指令`jr t0`,那么我们对代码进行分析。

`auipc t0,0x0`：按照官方文档说法auipc含义为The AUIPC instruction, which adds a 20 bit upper immediate to the PC, replaces the RDNPC instruction, which only read the current PC value. This results in significant savings for position-independent code.也就是说这条指令执行后，t0存放的是当前PC地址加上高20位立即数，又因为立即数为0x0，所以执行后t0存放的也就为PC地址0x1000

`addi a1,t0,32`：$a1 = t0 +32$ , 执行后a1存放的为0x1020。

`csrr a0,mhartid`：csrr系列指令在官方文档中一般用于操作控制寄存器，这里也就是将mhartid寄存器内容读到a0，输入`info r mhartid`查看mhartid寄存器内容，为0，因此这条指令在这里并不影响寄存器内容，a0还是0x0。

`ld t0,24(t0)`：加载t0偏移量24处的数据，存放到t0中。偏移量24，t0此时为0x1000, 所读取的是0x1018处的数据，我们利用`x/1g 0x1018`读取对应的内容，得到下面内容。

```assembly
0x1018:	0x0000000080000000
```

所以指令执行后，t0存放的也就是0x0000000080000000。

`jr t0`：根据t0存放内容，接下来指令会无条件跳转到0x80000000处继续执行，这里加电后至程序执行前的过程也就大致如上了，下面我们再看一看后面执行的代码

0x80000000处汇编指令如下：

```assembly
0x80000000:	csrr	a6,mhartid
0x80000004:	bgtz	a6,0x80000108
0x80000008:	auipc	t0,0x0
0x8000000c:	addi	t0,t0,1032
0x80000010:	auipc	t1,0x0
0x80000014:	addi	t1,t1,-16
0x80000018:	sd	t1,0(t0)
0x8000001c:	auipc	t0,0x0
0x80000020:	addi	t0,t0,1020
0x80000024:	ld	t0,0(t0)
```

这也就是后续的其他工作了，代码也就不一一解释了。没看到`jr`指令那么我们直接`break *0x80200000`设置断点，此时终端显示Breakpoint 1 at 0x80200000: file kern/init/entry.S, line 7.这个我们后面Lab1分析代码讲，`continue`执行到对应位置。发现已经启动完成了。

上面是利用gdb看指令执行的过程，下面从源码看一看如何实现的。首先是cpu将PC指向复位地址，这里就不贴代码了，找到qemu-4.1.1>hw>riscv>virt.c的static void riscv_virt_board_init(MachineState *machine)中，我们可以看到下面代码:

```c
/* boot rom */
memory_region_init_rom(mask_rom, NULL, "riscv_virt_board.mrom",memmap[VIRT_MROM].size, &error_fatal);
memory_region_add_subregion(system_memory, memmap[VIRT_MROM].base,mask_rom);
riscv_find_and_load_firmware(machine, BIOS_FILENAME,
memmap[VIRT_DRAM].base);
```

其中我们可以得到相关信息，VIRT_MROM为0x1000，VIRT_DRAM为0x80000000，RISCV开发板加电后，其先跳转到复位地址处，也就是这里虚拟ROM中存放的0x1000。而DRAM放的也就是我们待跳转的位置，我们上面看到的RISCV指令码也在这个函数中，如下：

```c
/* reset vector */
uint32_t reset_vec[8] = {
0x00000297, 		/* 1:  auipc  t0, %pcrel_hi(dtb) */
0x02028593, 		/* addi   a1, t0, %pcrel_lo(1b) */
0xf1402573,         /*     csrr   a0, mhartid  */
#if defined(TARGET_RISCV32)
0x0182a283,         /*     lw     t0, 24(t0) */
#elif defined(TARGET_RISCV64)
0x0182b283,         /*     ld     t0, 24(t0) */
#endif
0x00028067,         /*     jr     t0 */
0x00000000,
memmap[VIRT_DRAM].base, /* start: .dword memmap[VIRT_DRAM].base */
0x00000000, /* dtb: */
};
```

这也就是我们之前使用gdb看到的指令。如果仅从汇编代码看，我们并看不出什么功能，但是看这个函数的代码我们可以发现，再这些指令码前，加电后，我们先执行了复位地址处相应代码，这部分代码主要是初始化相关代码，然后完成后，则跳转到了程序的入口地址。其实从下面四个注释我们就能大致看出初始化详细过程：也就是

```c
/* Initialize SOC */
/* register system main memory (actual RAM) */
/* create device tree */
/* boot rom */
```

初始化系统的SoC->注册系统的主内存（实际为RAM）->创建设备树->处理启动固件，大致流程如上，更详细的代码可以看源码。

0x80000000到0x80200000个人也有`si`慢慢调试，发现还是相当多的，因此我们直接看源码注释：

```c
/* copy in the reset vector in little_endian byte order */
/* copy in the device tree */
/* create PLIC hart topology configuration string */
/* MMIO */
```

大致也就是复制复位向量->复制设备树->创建PLIC hart拓扑配置字符串->内存映射输入/输出

#### 知识点：

操作系统启动的一些原理：从qemu启动流程看,在执行复位地址0x1000代码前，在cpu.c中初始化会先把PC指向0x1000，然后PC从这里开始执行一些初始化代码，再跳转到执行程序的代码。

搜索时发现上面提到的——创建PLIC hart拓扑配置字符串，是用于处理中断以及中断优先级的，联想到课上讲的并发的一些优先级知识点。

#### 遗漏知识点：

学艺不精，暂时想不出

### Lab1:

#### 练习1：理解内核启动中的程序入口操作

##### 阅读 kern/init/entry.S内容代码，结合操作系统内核启动流程，说明指令 la sp, bootstacktop 完成了什么操作，目的是什么？ tail kern_init 完成了什么操作，目的是什么？

在Lab0.5中，我们当时在0x80200000处设置了一个断点，其定位到了kern/init/entry.S, line 7，也就是`la sp, bootstacktop`这条指令处，而这条指令的含义是将sp设置为 bootstacktop的地址，sp在汇编中也就是我们常说的栈顶指针，再观察entry.s的其他代码，例如下面代码：

```assembly
.section .data
    # .align 2^12
    .align PGSHIFT
    .global bootstack
bootstack:
    .space KSTACKSIZE
    .global bootstacktop
bootstacktop:
```

bootstack是有一个空间以及一个名字的，bootstacktop还没内容，显然就是`la sp, bootstacktop`这条指令确定的了，也就是说，这里bootstack是单独分出来的一个栈，具体目的暂时不清楚，联系下一条指令我们可以大致猜出大概是用于隔离内核和用户。

`la sp, bootstacktop`的下一条指令是`tail kern_init`，查阅资料发现tail是一条伪指令，在RISCV上会被解释为

```assembly
auipc x6, offset[32:12]
jalr x0, x6, offset[11:0]
```

简而言之就是跳转，那么我们也很好理解就是跳转到kern_init处了。联系着看就说得通了，先分配一个栈，然后跳转到初始化内核代码处，这个栈很大可能是专门给内核初始化用的。这样就不会影响到用户的栈了。

#### 练习2：完善中断处理 （需要编程）

##### 请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写kern/trap/trap.c函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用sbi.h中的shut_down()函数关机。

##### 要求完成问题1提出的相关函数实现，提交改进后的源代码包（可以编译执行），并在实验报告中简要说明实现过程和定时器中断中断处理的流程。实现要求的部分代码后，运行整个系统，大约每1秒会输出一次”100 ticks”，输出10行。

在trap.c中，找到时钟中断处的代码，添加如下代码:

```c
//设置下次时钟中断
clock_set_next_event();
//计数器（ticks）加一
ticks++;
//当计数器加到100的时候
if (ticks % TICK_NUM == 0)
{
     //输出一个`100ticks`
     print_ticks();
     //打印次数（num）加一
     num += 1;
     //判断打印次数，当打印次数为10时
     if (num == 10) 
     {
         //调用<sbi.h>中的关机函数关机
         sbi_shutdown();
     }
}
```

即可完成编程，详细见注释

#### 扩展练习 Challenge1：描述与理解中断流程

##### 回答：描述ucore中处理中断异常的流程（从异常的产生开始），其中mov a0，sp的目的是什么？SAVE_ALL中寄寄存器保存在栈中的位置是什么确定的？对于任何中断，__alltraps 中都需要保存所有寄存器吗？请说明理由。

首先我们看到中断入口

```c
/**
 * @brief      Load supervisor trap entry in RISC-V
 */
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
}

```

`write_csr(sscratch, 0);`表示将sscratch设置为0，查阅资料，应该是给予supervisor权限

`write_csr(stvec, &__alltraps);`表示将stvec寄存器的值设置为`&__alltraps`

那么根据这些条件，我们大致能推出`__alltrap`就是中断相关了，找到`__alltrap`,其代码如下：

```assembly
__alltraps:
    SAVE_ALL

    move  a0, sp
    jal trap
    # sp should be the same as before "jal trap"

    .globl __trapret
```

这里就出现了`SAVE_ALL`，`SAVE_ALL`出现在开头，保存的应该是中断发生时寄存器的内容。以及`move a0,sp`，`move a0,sp`在把栈指针值赋值给了a0后就跳转到了trap，所以推测这里`move a0,sp`应该也是一个保存现场的作用。

跳转后应该就是异常处理了，就又回到了trap.c中，根据处理决定下一步，应该就是完整的异常处理流程了。

有关对于任何中断或异常__alltraps 函数需要保存所有寄存器的状态的问题，应该得看中断或者异常的情况，例如我们也经常遇到exe未响应的情况，类似的，我们不需要把其他无关软件状态都给保存下来，但是如果遇到死机我们也许就需要全部保存了。

#### 扩增练习 Challenge2：理解上下文切换机制

##### 回答：在trapentry.S中汇编代码 csrw sscratch, sp；csrrw s0, sscratch, x0实现了什么操作，目的是什么？save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？那这样store的意义何在呢？

`csrw sscratch, sp`位于开头，保存栈指针后就是一系列的保存操作，之后就是`csrrw s0, sscratch, x0`,那么此时s0应该存放这之前的sp，不难看出，到这我们之前的状态就已经存放完成了，也就是上文，完成这些并保存异常信息，如下：

```assembly
csrrw s0, sscratch, x0
csrr s1, sstatus
csrr s2, sepc
csrr s3, sbadaddr
csrr s4, scause
```

这部分代码之后就是加载很多数据然后`RESTORE_ALL`了，也就是下文，所以上下文切换可以理解为保存上一个任务（这里是中断），加载下一个任务。上面说到了stval scause这些csr是保存异常信息，所以恢复我们并不一定需要恢复这些东西。

#### 扩展练习Challenge3：完善异常中断

##### 编程完善在触发一条非法指令异常 mret和，在 kern/trap/trap.c的异常处理函数中捕获，并对其进行处理，简单输出异常类型和异常指令触发地址，即“Illegal instruction caught at 0x(地址)”，“ebreak caught at 0x（地址）”与“Exception type:Illegal instruction"，“Exception type: breakpoint”。

根据处理中断的函数`void interrupt_handler(struct trapframe *tf)`，我们可以看出结构体`trapframe`应该是存放着中断相关信息的，例如这个函数中我们根据`tf->cause`来判断中断类别。结构体为：

```c
struct trapframe {
    struct pushregs gpr;
    uintptr_t status;
    uintptr_t epc;
    uintptr_t badvaddr;
    uintptr_t cause;
};
```

又在Challenge的trapentry.S中，SAVE_ALL有下列代码

```assembly
    csrrw s0, sscratch, x0
    csrr s1, sstatus
    csrr s2, sepc
    csrr s3, sbadaddr
    csrr s4, scause
```

所以我们就可以对应上下面四个寄存器内容了。

查阅资料得这四个寄存器内容：

`sstatus` 寄存器包含了处理器的当前状态信息，包括特权级别（例如，是不是在Supervisor模式下运行）、中断使能位、硬件中断优先级等。

`sepc` 寄存器存储了触发异常时的程序计数器（PC）的值，即异常的发生点

`sbadaddr` 寄存器通常在发生页错误（Page Fault）等异常时，用于存储导致异常的地址，例如访问无效的内存地址时存储该地址的值。

`scause` 寄存器存储了导致当前异常或中断的原因，例如是因为系统调用、页错误、外部中断等。

因此中断地址应该就是tf->epc。

具体编程如下：

```c
//print
cprintf("Exception type:Illegal instruction\n");
cprintf("Illegal instruction caught at 0x%016llx\n", tf->epc);
//更新 tf->epc寄存器
tf->epc=tf->epc+2;
```

```c
//print
cprintf("Exception type: breakpoint\n");
cprintf("ebreak caught at 0x%016llx\n", tf->epc);
//更新 tf->epc寄存器
tf->epc=tf->epc+2;
```

这里`tf->epc=tf->epc+2`是来源于他人群里提问的灵感:smile:,查阅资料发现原因是RISC-V中，大多数指令的长度为4字节（32位)，也就不同于主流的+4了。

#### 知识点：

上下文切换感觉和理论课学习的并发非常相似，理论课上讲到的宏观上虽然我们同时运行很多个程序，但是实际只有一个在运行，其中应该蕴含了很多保存上一个任务的状态然后进行下一个任务状态的道理

#### 遗漏知识点：

学艺不精，暂时想不出
