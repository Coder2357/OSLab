
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020e2b7          	lui	t0,0xc020e
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c020e137          	lui	sp,0xc020e

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	000be517          	auipc	a0,0xbe
ffffffffc020003a:	d2250513          	addi	a0,a0,-734 # ffffffffc02bdd58 <edata>
ffffffffc020003e:	000c9617          	auipc	a2,0xc9
ffffffffc0200042:	2da60613          	addi	a2,a2,730 # ffffffffc02c9318 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	0aa090ef          	jal	ra,ffffffffc02090f8 <memset>
    cons_init();                // init the console
ffffffffc0200052:	52e000ef          	jal	ra,ffffffffc0200580 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00009597          	auipc	a1,0x9
ffffffffc020005a:	0d258593          	addi	a1,a1,210 # ffffffffc0209128 <etext+0x6>
ffffffffc020005e:	00009517          	auipc	a0,0x9
ffffffffc0200062:	0ea50513          	addi	a0,a0,234 # ffffffffc0209148 <etext+0x26>
ffffffffc0200066:	12c000ef          	jal	ra,ffffffffc0200192 <cprintf>

    print_kerninfo();
ffffffffc020006a:	1b0000ef          	jal	ra,ffffffffc020021a <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5b6020ef          	jal	ra,ffffffffc0202624 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e6000ef          	jal	ra,ffffffffc0200658 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5e4000ef          	jal	ra,ffffffffc020065a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	3d8040ef          	jal	ra,ffffffffc0204452 <vmm_init>
    sched_init();
ffffffffc020007e:	0ef080ef          	jal	ra,ffffffffc020896c <sched_init>
    proc_init();                // init process table
ffffffffc0200082:	50d050ef          	jal	ra,ffffffffc0205d8e <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200086:	56e000ef          	jal	ra,ffffffffc02005f4 <ide_init>
    swap_init();                // init swap
ffffffffc020008a:	2f2030ef          	jal	ra,ffffffffc020337c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008e:	4a8000ef          	jal	ra,ffffffffc0200536 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc0200092:	5ba000ef          	jal	ra,ffffffffc020064c <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
ffffffffc0200096:	645050ef          	jal	ra,ffffffffc0205eda <cpu_idle>

ffffffffc020009a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020009a:	715d                	addi	sp,sp,-80
ffffffffc020009c:	e486                	sd	ra,72(sp)
ffffffffc020009e:	e0a2                	sd	s0,64(sp)
ffffffffc02000a0:	fc26                	sd	s1,56(sp)
ffffffffc02000a2:	f84a                	sd	s2,48(sp)
ffffffffc02000a4:	f44e                	sd	s3,40(sp)
ffffffffc02000a6:	f052                	sd	s4,32(sp)
ffffffffc02000a8:	ec56                	sd	s5,24(sp)
ffffffffc02000aa:	e85a                	sd	s6,16(sp)
ffffffffc02000ac:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000ae:	c901                	beqz	a0,ffffffffc02000be <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000b0:	85aa                	mv	a1,a0
ffffffffc02000b2:	00009517          	auipc	a0,0x9
ffffffffc02000b6:	09e50513          	addi	a0,a0,158 # ffffffffc0209150 <etext+0x2e>
ffffffffc02000ba:	0d8000ef          	jal	ra,ffffffffc0200192 <cprintf>
readline(const char *prompt) {
ffffffffc02000be:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c0:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000c2:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c4:	4aa9                	li	s5,10
ffffffffc02000c6:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c8:	000beb97          	auipc	s7,0xbe
ffffffffc02000cc:	c90b8b93          	addi	s7,s7,-880 # ffffffffc02bdd58 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d0:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d4:	136000ef          	jal	ra,ffffffffc020020a <getchar>
ffffffffc02000d8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000da:	00054b63          	bltz	a0,ffffffffc02000f0 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000de:	00a95b63          	ble	a0,s2,ffffffffc02000f4 <readline+0x5a>
ffffffffc02000e2:	029a5463          	ble	s1,s4,ffffffffc020010a <readline+0x70>
        c = getchar();
ffffffffc02000e6:	124000ef          	jal	ra,ffffffffc020020a <getchar>
ffffffffc02000ea:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000ec:	fe0559e3          	bgez	a0,ffffffffc02000de <readline+0x44>
            return NULL;
ffffffffc02000f0:	4501                	li	a0,0
ffffffffc02000f2:	a099                	j	ffffffffc0200138 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f4:	03341463          	bne	s0,s3,ffffffffc020011c <readline+0x82>
ffffffffc02000f8:	e8b9                	bnez	s1,ffffffffc020014e <readline+0xb4>
        c = getchar();
ffffffffc02000fa:	110000ef          	jal	ra,ffffffffc020020a <getchar>
ffffffffc02000fe:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200100:	fe0548e3          	bltz	a0,ffffffffc02000f0 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200104:	fea958e3          	ble	a0,s2,ffffffffc02000f4 <readline+0x5a>
ffffffffc0200108:	4481                	li	s1,0
            cputchar(c);
ffffffffc020010a:	8522                	mv	a0,s0
ffffffffc020010c:	0ba000ef          	jal	ra,ffffffffc02001c6 <cputchar>
            buf[i ++] = c;
ffffffffc0200110:	009b87b3          	add	a5,s7,s1
ffffffffc0200114:	00878023          	sb	s0,0(a5)
ffffffffc0200118:	2485                	addiw	s1,s1,1
ffffffffc020011a:	bf6d                	j	ffffffffc02000d4 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020011c:	01540463          	beq	s0,s5,ffffffffc0200124 <readline+0x8a>
ffffffffc0200120:	fb641ae3          	bne	s0,s6,ffffffffc02000d4 <readline+0x3a>
            cputchar(c);
ffffffffc0200124:	8522                	mv	a0,s0
ffffffffc0200126:	0a0000ef          	jal	ra,ffffffffc02001c6 <cputchar>
            buf[i] = '\0';
ffffffffc020012a:	000be517          	auipc	a0,0xbe
ffffffffc020012e:	c2e50513          	addi	a0,a0,-978 # ffffffffc02bdd58 <edata>
ffffffffc0200132:	94aa                	add	s1,s1,a0
ffffffffc0200134:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200138:	60a6                	ld	ra,72(sp)
ffffffffc020013a:	6406                	ld	s0,64(sp)
ffffffffc020013c:	74e2                	ld	s1,56(sp)
ffffffffc020013e:	7942                	ld	s2,48(sp)
ffffffffc0200140:	79a2                	ld	s3,40(sp)
ffffffffc0200142:	7a02                	ld	s4,32(sp)
ffffffffc0200144:	6ae2                	ld	s5,24(sp)
ffffffffc0200146:	6b42                	ld	s6,16(sp)
ffffffffc0200148:	6ba2                	ld	s7,8(sp)
ffffffffc020014a:	6161                	addi	sp,sp,80
ffffffffc020014c:	8082                	ret
            cputchar(c);
ffffffffc020014e:	4521                	li	a0,8
ffffffffc0200150:	076000ef          	jal	ra,ffffffffc02001c6 <cputchar>
            i --;
ffffffffc0200154:	34fd                	addiw	s1,s1,-1
ffffffffc0200156:	bfbd                	j	ffffffffc02000d4 <readline+0x3a>

ffffffffc0200158 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200158:	1141                	addi	sp,sp,-16
ffffffffc020015a:	e022                	sd	s0,0(sp)
ffffffffc020015c:	e406                	sd	ra,8(sp)
ffffffffc020015e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200160:	422000ef          	jal	ra,ffffffffc0200582 <cons_putc>
    (*cnt) ++;
ffffffffc0200164:	401c                	lw	a5,0(s0)
}
ffffffffc0200166:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200168:	2785                	addiw	a5,a5,1
ffffffffc020016a:	c01c                	sw	a5,0(s0)
}
ffffffffc020016c:	6402                	ld	s0,0(sp)
ffffffffc020016e:	0141                	addi	sp,sp,16
ffffffffc0200170:	8082                	ret

ffffffffc0200172 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200172:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	86ae                	mv	a3,a1
ffffffffc0200176:	862a                	mv	a2,a0
ffffffffc0200178:	006c                	addi	a1,sp,12
ffffffffc020017a:	00000517          	auipc	a0,0x0
ffffffffc020017e:	fde50513          	addi	a0,a0,-34 # ffffffffc0200158 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200182:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200184:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200186:	349080ef          	jal	ra,ffffffffc0208cce <vprintfmt>
    return cnt;
}
ffffffffc020018a:	60e2                	ld	ra,24(sp)
ffffffffc020018c:	4532                	lw	a0,12(sp)
ffffffffc020018e:	6105                	addi	sp,sp,32
ffffffffc0200190:	8082                	ret

ffffffffc0200192 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200192:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200194:	02810313          	addi	t1,sp,40 # ffffffffc020e028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200198:	f42e                	sd	a1,40(sp)
ffffffffc020019a:	f832                	sd	a2,48(sp)
ffffffffc020019c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019e:	862a                	mv	a2,a0
ffffffffc02001a0:	004c                	addi	a1,sp,4
ffffffffc02001a2:	00000517          	auipc	a0,0x0
ffffffffc02001a6:	fb650513          	addi	a0,a0,-74 # ffffffffc0200158 <cputch>
ffffffffc02001aa:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001ac:	ec06                	sd	ra,24(sp)
ffffffffc02001ae:	e0ba                	sd	a4,64(sp)
ffffffffc02001b0:	e4be                	sd	a5,72(sp)
ffffffffc02001b2:	e8c2                	sd	a6,80(sp)
ffffffffc02001b4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001ba:	315080ef          	jal	ra,ffffffffc0208cce <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001be:	60e2                	ld	ra,24(sp)
ffffffffc02001c0:	4512                	lw	a0,4(sp)
ffffffffc02001c2:	6125                	addi	sp,sp,96
ffffffffc02001c4:	8082                	ret

ffffffffc02001c6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c6:	3bc0006f          	j	ffffffffc0200582 <cons_putc>

ffffffffc02001ca <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001ca:	1101                	addi	sp,sp,-32
ffffffffc02001cc:	e822                	sd	s0,16(sp)
ffffffffc02001ce:	ec06                	sd	ra,24(sp)
ffffffffc02001d0:	e426                	sd	s1,8(sp)
ffffffffc02001d2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001d4:	00054503          	lbu	a0,0(a0)
ffffffffc02001d8:	c51d                	beqz	a0,ffffffffc0200206 <cputs+0x3c>
ffffffffc02001da:	0405                	addi	s0,s0,1
ffffffffc02001dc:	4485                	li	s1,1
ffffffffc02001de:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001e0:	3a2000ef          	jal	ra,ffffffffc0200582 <cons_putc>
    (*cnt) ++;
ffffffffc02001e4:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc02001e8:	0405                	addi	s0,s0,1
ffffffffc02001ea:	fff44503          	lbu	a0,-1(s0)
ffffffffc02001ee:	f96d                	bnez	a0,ffffffffc02001e0 <cputs+0x16>
ffffffffc02001f0:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001f4:	4529                	li	a0,10
ffffffffc02001f6:	38c000ef          	jal	ra,ffffffffc0200582 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001fa:	8522                	mv	a0,s0
ffffffffc02001fc:	60e2                	ld	ra,24(sp)
ffffffffc02001fe:	6442                	ld	s0,16(sp)
ffffffffc0200200:	64a2                	ld	s1,8(sp)
ffffffffc0200202:	6105                	addi	sp,sp,32
ffffffffc0200204:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200206:	4405                	li	s0,1
ffffffffc0200208:	b7f5                	j	ffffffffc02001f4 <cputs+0x2a>

ffffffffc020020a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020020a:	1141                	addi	sp,sp,-16
ffffffffc020020c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020020e:	3aa000ef          	jal	ra,ffffffffc02005b8 <cons_getc>
ffffffffc0200212:	dd75                	beqz	a0,ffffffffc020020e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200214:	60a2                	ld	ra,8(sp)
ffffffffc0200216:	0141                	addi	sp,sp,16
ffffffffc0200218:	8082                	ret

ffffffffc020021a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020021a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020021c:	00009517          	auipc	a0,0x9
ffffffffc0200220:	f6c50513          	addi	a0,a0,-148 # ffffffffc0209188 <etext+0x66>
void print_kerninfo(void) {
ffffffffc0200224:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200226:	f6dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020022a:	00000597          	auipc	a1,0x0
ffffffffc020022e:	e0c58593          	addi	a1,a1,-500 # ffffffffc0200036 <kern_init>
ffffffffc0200232:	00009517          	auipc	a0,0x9
ffffffffc0200236:	f7650513          	addi	a0,a0,-138 # ffffffffc02091a8 <etext+0x86>
ffffffffc020023a:	f59ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020023e:	00009597          	auipc	a1,0x9
ffffffffc0200242:	ee458593          	addi	a1,a1,-284 # ffffffffc0209122 <etext>
ffffffffc0200246:	00009517          	auipc	a0,0x9
ffffffffc020024a:	f8250513          	addi	a0,a0,-126 # ffffffffc02091c8 <etext+0xa6>
ffffffffc020024e:	f45ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200252:	000be597          	auipc	a1,0xbe
ffffffffc0200256:	b0658593          	addi	a1,a1,-1274 # ffffffffc02bdd58 <edata>
ffffffffc020025a:	00009517          	auipc	a0,0x9
ffffffffc020025e:	f8e50513          	addi	a0,a0,-114 # ffffffffc02091e8 <etext+0xc6>
ffffffffc0200262:	f31ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200266:	000c9597          	auipc	a1,0xc9
ffffffffc020026a:	0b258593          	addi	a1,a1,178 # ffffffffc02c9318 <end>
ffffffffc020026e:	00009517          	auipc	a0,0x9
ffffffffc0200272:	f9a50513          	addi	a0,a0,-102 # ffffffffc0209208 <etext+0xe6>
ffffffffc0200276:	f1dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020027a:	000c9597          	auipc	a1,0xc9
ffffffffc020027e:	49d58593          	addi	a1,a1,1181 # ffffffffc02c9717 <end+0x3ff>
ffffffffc0200282:	00000797          	auipc	a5,0x0
ffffffffc0200286:	db478793          	addi	a5,a5,-588 # ffffffffc0200036 <kern_init>
ffffffffc020028a:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028e:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200292:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200294:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200298:	95be                	add	a1,a1,a5
ffffffffc020029a:	85a9                	srai	a1,a1,0xa
ffffffffc020029c:	00009517          	auipc	a0,0x9
ffffffffc02002a0:	f8c50513          	addi	a0,a0,-116 # ffffffffc0209228 <etext+0x106>
}
ffffffffc02002a4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a6:	eedff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc02002aa <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002aa:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002ac:	00009617          	auipc	a2,0x9
ffffffffc02002b0:	eac60613          	addi	a2,a2,-340 # ffffffffc0209158 <etext+0x36>
ffffffffc02002b4:	04d00593          	li	a1,77
ffffffffc02002b8:	00009517          	auipc	a0,0x9
ffffffffc02002bc:	eb850513          	addi	a0,a0,-328 # ffffffffc0209170 <etext+0x4e>
void print_stackframe(void) {
ffffffffc02002c0:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002c2:	1c6000ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02002c6 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002c6:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c8:	00009617          	auipc	a2,0x9
ffffffffc02002cc:	07060613          	addi	a2,a2,112 # ffffffffc0209338 <commands+0xe0>
ffffffffc02002d0:	00009597          	auipc	a1,0x9
ffffffffc02002d4:	08858593          	addi	a1,a1,136 # ffffffffc0209358 <commands+0x100>
ffffffffc02002d8:	00009517          	auipc	a0,0x9
ffffffffc02002dc:	08850513          	addi	a0,a0,136 # ffffffffc0209360 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e2:	eb1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc02002e6:	00009617          	auipc	a2,0x9
ffffffffc02002ea:	08a60613          	addi	a2,a2,138 # ffffffffc0209370 <commands+0x118>
ffffffffc02002ee:	00009597          	auipc	a1,0x9
ffffffffc02002f2:	0aa58593          	addi	a1,a1,170 # ffffffffc0209398 <commands+0x140>
ffffffffc02002f6:	00009517          	auipc	a0,0x9
ffffffffc02002fa:	06a50513          	addi	a0,a0,106 # ffffffffc0209360 <commands+0x108>
ffffffffc02002fe:	e95ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0200302:	00009617          	auipc	a2,0x9
ffffffffc0200306:	0a660613          	addi	a2,a2,166 # ffffffffc02093a8 <commands+0x150>
ffffffffc020030a:	00009597          	auipc	a1,0x9
ffffffffc020030e:	0be58593          	addi	a1,a1,190 # ffffffffc02093c8 <commands+0x170>
ffffffffc0200312:	00009517          	auipc	a0,0x9
ffffffffc0200316:	04e50513          	addi	a0,a0,78 # ffffffffc0209360 <commands+0x108>
ffffffffc020031a:	e79ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    }
    return 0;
}
ffffffffc020031e:	60a2                	ld	ra,8(sp)
ffffffffc0200320:	4501                	li	a0,0
ffffffffc0200322:	0141                	addi	sp,sp,16
ffffffffc0200324:	8082                	ret

ffffffffc0200326 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200326:	1141                	addi	sp,sp,-16
ffffffffc0200328:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020032a:	ef1ff0ef          	jal	ra,ffffffffc020021a <print_kerninfo>
    return 0;
}
ffffffffc020032e:	60a2                	ld	ra,8(sp)
ffffffffc0200330:	4501                	li	a0,0
ffffffffc0200332:	0141                	addi	sp,sp,16
ffffffffc0200334:	8082                	ret

ffffffffc0200336 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200336:	1141                	addi	sp,sp,-16
ffffffffc0200338:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020033a:	f71ff0ef          	jal	ra,ffffffffc02002aa <print_stackframe>
    return 0;
}
ffffffffc020033e:	60a2                	ld	ra,8(sp)
ffffffffc0200340:	4501                	li	a0,0
ffffffffc0200342:	0141                	addi	sp,sp,16
ffffffffc0200344:	8082                	ret

ffffffffc0200346 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200346:	7115                	addi	sp,sp,-224
ffffffffc0200348:	e962                	sd	s8,144(sp)
ffffffffc020034a:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020034c:	00009517          	auipc	a0,0x9
ffffffffc0200350:	f5450513          	addi	a0,a0,-172 # ffffffffc02092a0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200354:	ed86                	sd	ra,216(sp)
ffffffffc0200356:	e9a2                	sd	s0,208(sp)
ffffffffc0200358:	e5a6                	sd	s1,200(sp)
ffffffffc020035a:	e1ca                	sd	s2,192(sp)
ffffffffc020035c:	fd4e                	sd	s3,184(sp)
ffffffffc020035e:	f952                	sd	s4,176(sp)
ffffffffc0200360:	f556                	sd	s5,168(sp)
ffffffffc0200362:	f15a                	sd	s6,160(sp)
ffffffffc0200364:	ed5e                	sd	s7,152(sp)
ffffffffc0200366:	e566                	sd	s9,136(sp)
ffffffffc0200368:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020036a:	e29ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020036e:	00009517          	auipc	a0,0x9
ffffffffc0200372:	f5a50513          	addi	a0,a0,-166 # ffffffffc02092c8 <commands+0x70>
ffffffffc0200376:	e1dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    if (tf != NULL) {
ffffffffc020037a:	000c0563          	beqz	s8,ffffffffc0200384 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037e:	8562                	mv	a0,s8
ffffffffc0200380:	4c2000ef          	jal	ra,ffffffffc0200842 <print_trapframe>
ffffffffc0200384:	00009c97          	auipc	s9,0x9
ffffffffc0200388:	ed4c8c93          	addi	s9,s9,-300 # ffffffffc0209258 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020038c:	00009997          	auipc	s3,0x9
ffffffffc0200390:	f6498993          	addi	s3,s3,-156 # ffffffffc02092f0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200394:	00009917          	auipc	s2,0x9
ffffffffc0200398:	f6490913          	addi	s2,s2,-156 # ffffffffc02092f8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc020039c:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039e:	00009b17          	auipc	s6,0x9
ffffffffc02003a2:	f62b0b13          	addi	s6,s6,-158 # ffffffffc0209300 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003a6:	00009a97          	auipc	s5,0x9
ffffffffc02003aa:	fb2a8a93          	addi	s5,s5,-78 # ffffffffc0209358 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ae:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003b0:	854e                	mv	a0,s3
ffffffffc02003b2:	ce9ff0ef          	jal	ra,ffffffffc020009a <readline>
ffffffffc02003b6:	842a                	mv	s0,a0
ffffffffc02003b8:	dd65                	beqz	a0,ffffffffc02003b0 <kmonitor+0x6a>
ffffffffc02003ba:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003be:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003c0:	c999                	beqz	a1,ffffffffc02003d6 <kmonitor+0x90>
ffffffffc02003c2:	854a                	mv	a0,s2
ffffffffc02003c4:	517080ef          	jal	ra,ffffffffc02090da <strchr>
ffffffffc02003c8:	c925                	beqz	a0,ffffffffc0200438 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02003ca:	00144583          	lbu	a1,1(s0)
ffffffffc02003ce:	00040023          	sb	zero,0(s0)
ffffffffc02003d2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d4:	f5fd                	bnez	a1,ffffffffc02003c2 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02003d6:	dce9                	beqz	s1,ffffffffc02003b0 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d8:	6582                	ld	a1,0(sp)
ffffffffc02003da:	00009d17          	auipc	s10,0x9
ffffffffc02003de:	e7ed0d13          	addi	s10,s10,-386 # ffffffffc0209258 <commands>
    if (argc == 0) {
ffffffffc02003e2:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e4:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e6:	0d61                	addi	s10,s10,24
ffffffffc02003e8:	4c9080ef          	jal	ra,ffffffffc02090b0 <strcmp>
ffffffffc02003ec:	c919                	beqz	a0,ffffffffc0200402 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ee:	2405                	addiw	s0,s0,1
ffffffffc02003f0:	09740463          	beq	s0,s7,ffffffffc0200478 <kmonitor+0x132>
ffffffffc02003f4:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	0d61                	addi	s10,s10,24
ffffffffc02003fc:	4b5080ef          	jal	ra,ffffffffc02090b0 <strcmp>
ffffffffc0200400:	f57d                	bnez	a0,ffffffffc02003ee <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200402:	00141793          	slli	a5,s0,0x1
ffffffffc0200406:	97a2                	add	a5,a5,s0
ffffffffc0200408:	078e                	slli	a5,a5,0x3
ffffffffc020040a:	97e6                	add	a5,a5,s9
ffffffffc020040c:	6b9c                	ld	a5,16(a5)
ffffffffc020040e:	8662                	mv	a2,s8
ffffffffc0200410:	002c                	addi	a1,sp,8
ffffffffc0200412:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200416:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200418:	f8055ce3          	bgez	a0,ffffffffc02003b0 <kmonitor+0x6a>
}
ffffffffc020041c:	60ee                	ld	ra,216(sp)
ffffffffc020041e:	644e                	ld	s0,208(sp)
ffffffffc0200420:	64ae                	ld	s1,200(sp)
ffffffffc0200422:	690e                	ld	s2,192(sp)
ffffffffc0200424:	79ea                	ld	s3,184(sp)
ffffffffc0200426:	7a4a                	ld	s4,176(sp)
ffffffffc0200428:	7aaa                	ld	s5,168(sp)
ffffffffc020042a:	7b0a                	ld	s6,160(sp)
ffffffffc020042c:	6bea                	ld	s7,152(sp)
ffffffffc020042e:	6c4a                	ld	s8,144(sp)
ffffffffc0200430:	6caa                	ld	s9,136(sp)
ffffffffc0200432:	6d0a                	ld	s10,128(sp)
ffffffffc0200434:	612d                	addi	sp,sp,224
ffffffffc0200436:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200438:	00044783          	lbu	a5,0(s0)
ffffffffc020043c:	dfc9                	beqz	a5,ffffffffc02003d6 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020043e:	03448863          	beq	s1,s4,ffffffffc020046e <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200442:	00349793          	slli	a5,s1,0x3
ffffffffc0200446:	0118                	addi	a4,sp,128
ffffffffc0200448:	97ba                	add	a5,a5,a4
ffffffffc020044a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200452:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200454:	e591                	bnez	a1,ffffffffc0200460 <kmonitor+0x11a>
ffffffffc0200456:	b749                	j	ffffffffc02003d8 <kmonitor+0x92>
            buf ++;
ffffffffc0200458:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020045a:	00044583          	lbu	a1,0(s0)
ffffffffc020045e:	ddad                	beqz	a1,ffffffffc02003d8 <kmonitor+0x92>
ffffffffc0200460:	854a                	mv	a0,s2
ffffffffc0200462:	479080ef          	jal	ra,ffffffffc02090da <strchr>
ffffffffc0200466:	d96d                	beqz	a0,ffffffffc0200458 <kmonitor+0x112>
ffffffffc0200468:	00044583          	lbu	a1,0(s0)
ffffffffc020046c:	bf91                	j	ffffffffc02003c0 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020046e:	45c1                	li	a1,16
ffffffffc0200470:	855a                	mv	a0,s6
ffffffffc0200472:	d21ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0200476:	b7f1                	j	ffffffffc0200442 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200478:	6582                	ld	a1,0(sp)
ffffffffc020047a:	00009517          	auipc	a0,0x9
ffffffffc020047e:	ea650513          	addi	a0,a0,-346 # ffffffffc0209320 <commands+0xc8>
ffffffffc0200482:	d11ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    return 0;
ffffffffc0200486:	b72d                	j	ffffffffc02003b0 <kmonitor+0x6a>

ffffffffc0200488 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200488:	000c9317          	auipc	t1,0xc9
ffffffffc020048c:	d0030313          	addi	t1,t1,-768 # ffffffffc02c9188 <is_panic>
ffffffffc0200490:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200494:	715d                	addi	sp,sp,-80
ffffffffc0200496:	ec06                	sd	ra,24(sp)
ffffffffc0200498:	e822                	sd	s0,16(sp)
ffffffffc020049a:	f436                	sd	a3,40(sp)
ffffffffc020049c:	f83a                	sd	a4,48(sp)
ffffffffc020049e:	fc3e                	sd	a5,56(sp)
ffffffffc02004a0:	e0c2                	sd	a6,64(sp)
ffffffffc02004a2:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02004a4:	02031c63          	bnez	t1,ffffffffc02004dc <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004a8:	4785                	li	a5,1
ffffffffc02004aa:	8432                	mv	s0,a2
ffffffffc02004ac:	000c9717          	auipc	a4,0xc9
ffffffffc02004b0:	ccf73e23          	sd	a5,-804(a4) # ffffffffc02c9188 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b4:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004b6:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b8:	85aa                	mv	a1,a0
ffffffffc02004ba:	00009517          	auipc	a0,0x9
ffffffffc02004be:	f1e50513          	addi	a0,a0,-226 # ffffffffc02093d8 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004c2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c4:	ccfff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c8:	65a2                	ld	a1,8(sp)
ffffffffc02004ca:	8522                	mv	a0,s0
ffffffffc02004cc:	ca7ff0ef          	jal	ra,ffffffffc0200172 <vcprintf>
    cprintf("\n");
ffffffffc02004d0:	0000a517          	auipc	a0,0xa
ffffffffc02004d4:	ec850513          	addi	a0,a0,-312 # ffffffffc020a398 <default_pmm_manager+0x538>
ffffffffc02004d8:	cbbff0ef          	jal	ra,ffffffffc0200192 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004dc:	4501                	li	a0,0
ffffffffc02004de:	4581                	li	a1,0
ffffffffc02004e0:	4601                	li	a2,0
ffffffffc02004e2:	48a1                	li	a7,8
ffffffffc02004e4:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004e8:	16a000ef          	jal	ra,ffffffffc0200652 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004ec:	4501                	li	a0,0
ffffffffc02004ee:	e59ff0ef          	jal	ra,ffffffffc0200346 <kmonitor>
ffffffffc02004f2:	bfed                	j	ffffffffc02004ec <__panic+0x64>

ffffffffc02004f4 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004f4:	715d                	addi	sp,sp,-80
ffffffffc02004f6:	e822                	sd	s0,16(sp)
ffffffffc02004f8:	fc3e                	sd	a5,56(sp)
ffffffffc02004fa:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004fc:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004fe:	862e                	mv	a2,a1
ffffffffc0200500:	85aa                	mv	a1,a0
ffffffffc0200502:	00009517          	auipc	a0,0x9
ffffffffc0200506:	ef650513          	addi	a0,a0,-266 # ffffffffc02093f8 <commands+0x1a0>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc020050a:	ec06                	sd	ra,24(sp)
ffffffffc020050c:	f436                	sd	a3,40(sp)
ffffffffc020050e:	f83a                	sd	a4,48(sp)
ffffffffc0200510:	e0c2                	sd	a6,64(sp)
ffffffffc0200512:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200514:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200516:	c7dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020051a:	65a2                	ld	a1,8(sp)
ffffffffc020051c:	8522                	mv	a0,s0
ffffffffc020051e:	c55ff0ef          	jal	ra,ffffffffc0200172 <vcprintf>
    cprintf("\n");
ffffffffc0200522:	0000a517          	auipc	a0,0xa
ffffffffc0200526:	e7650513          	addi	a0,a0,-394 # ffffffffc020a398 <default_pmm_manager+0x538>
ffffffffc020052a:	c69ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    va_end(ap);
}
ffffffffc020052e:	60e2                	ld	ra,24(sp)
ffffffffc0200530:	6442                	ld	s0,16(sp)
ffffffffc0200532:	6161                	addi	sp,sp,80
ffffffffc0200534:	8082                	ret

ffffffffc0200536 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    set_csr(sie, MIP_STIP);
ffffffffc0200536:	02000793          	li	a5,32
ffffffffc020053a:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020053e:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200542:	67e1                	lui	a5,0x18
ffffffffc0200544:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xcc48>
ffffffffc0200548:	953e                	add	a0,a0,a5
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020054a:	4581                	li	a1,0
ffffffffc020054c:	4601                	li	a2,0
ffffffffc020054e:	4881                	li	a7,0
ffffffffc0200550:	00000073          	ecall
    cprintf("++ setup timer interrupts\n");
ffffffffc0200554:	00009517          	auipc	a0,0x9
ffffffffc0200558:	ec450513          	addi	a0,a0,-316 # ffffffffc0209418 <commands+0x1c0>
    ticks = 0;
ffffffffc020055c:	000c9797          	auipc	a5,0xc9
ffffffffc0200560:	c807b623          	sd	zero,-884(a5) # ffffffffc02c91e8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200564:	c2fff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0200568 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200568:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020056c:	67e1                	lui	a5,0x18
ffffffffc020056e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xcc48>
ffffffffc0200572:	953e                	add	a0,a0,a5
ffffffffc0200574:	4581                	li	a1,0
ffffffffc0200576:	4601                	li	a2,0
ffffffffc0200578:	4881                	li	a7,0
ffffffffc020057a:	00000073          	ecall
ffffffffc020057e:	8082                	ret

ffffffffc0200580 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <cons_putc>:
#include <riscv.h>
#include <assert.h>
#include <atomic.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200582:	100027f3          	csrr	a5,sstatus
ffffffffc0200586:	8b89                	andi	a5,a5,2
ffffffffc0200588:	0ff57513          	andi	a0,a0,255
ffffffffc020058c:	e799                	bnez	a5,ffffffffc020059a <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020058e:	4581                	li	a1,0
ffffffffc0200590:	4601                	li	a2,0
ffffffffc0200592:	4885                	li	a7,1
ffffffffc0200594:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200598:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020059a:	1101                	addi	sp,sp,-32
ffffffffc020059c:	ec06                	sd	ra,24(sp)
ffffffffc020059e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005a0:	0b2000ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc02005a4:	6522                	ld	a0,8(sp)
ffffffffc02005a6:	4581                	li	a1,0
ffffffffc02005a8:	4601                	li	a2,0
ffffffffc02005aa:	4885                	li	a7,1
ffffffffc02005ac:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005b0:	60e2                	ld	ra,24(sp)
ffffffffc02005b2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005b4:	0980006f          	j	ffffffffc020064c <intr_enable>

ffffffffc02005b8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005b8:	100027f3          	csrr	a5,sstatus
ffffffffc02005bc:	8b89                	andi	a5,a5,2
ffffffffc02005be:	eb89                	bnez	a5,ffffffffc02005d0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005c0:	4501                	li	a0,0
ffffffffc02005c2:	4581                	li	a1,0
ffffffffc02005c4:	4601                	li	a2,0
ffffffffc02005c6:	4889                	li	a7,2
ffffffffc02005c8:	00000073          	ecall
ffffffffc02005cc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005ce:	8082                	ret
int cons_getc(void) {
ffffffffc02005d0:	1101                	addi	sp,sp,-32
ffffffffc02005d2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005d4:	07e000ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc02005d8:	4501                	li	a0,0
ffffffffc02005da:	4581                	li	a1,0
ffffffffc02005dc:	4601                	li	a2,0
ffffffffc02005de:	4889                	li	a7,2
ffffffffc02005e0:	00000073          	ecall
ffffffffc02005e4:	2501                	sext.w	a0,a0
ffffffffc02005e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005e8:	064000ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc02005ec:	60e2                	ld	ra,24(sp)
ffffffffc02005ee:	6522                	ld	a0,8(sp)
ffffffffc02005f0:	6105                	addi	sp,sp,32
ffffffffc02005f2:	8082                	ret

ffffffffc02005f4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005f4:	8082                	ret

ffffffffc02005f6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005f6:	00253513          	sltiu	a0,a0,2
ffffffffc02005fa:	8082                	ret

ffffffffc02005fc <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005fc:	03800513          	li	a0,56
ffffffffc0200600:	8082                	ret

ffffffffc0200602 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200602:	000be797          	auipc	a5,0xbe
ffffffffc0200606:	b5678793          	addi	a5,a5,-1194 # ffffffffc02be158 <ide>
ffffffffc020060a:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020060e:	1141                	addi	sp,sp,-16
ffffffffc0200610:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200612:	95be                	add	a1,a1,a5
ffffffffc0200614:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200618:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020061a:	2f1080ef          	jal	ra,ffffffffc020910a <memcpy>
    return 0;
}
ffffffffc020061e:	60a2                	ld	ra,8(sp)
ffffffffc0200620:	4501                	li	a0,0
ffffffffc0200622:	0141                	addi	sp,sp,16
ffffffffc0200624:	8082                	ret

ffffffffc0200626 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200626:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200628:	0095979b          	slliw	a5,a1,0x9
ffffffffc020062c:	000be517          	auipc	a0,0xbe
ffffffffc0200630:	b2c50513          	addi	a0,a0,-1236 # ffffffffc02be158 <ide>
                   size_t nsecs) {
ffffffffc0200634:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200636:	00969613          	slli	a2,a3,0x9
ffffffffc020063a:	85ba                	mv	a1,a4
ffffffffc020063c:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020063e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200640:	2cb080ef          	jal	ra,ffffffffc020910a <memcpy>
    return 0;
}
ffffffffc0200644:	60a2                	ld	ra,8(sp)
ffffffffc0200646:	4501                	li	a0,0
ffffffffc0200648:	0141                	addi	sp,sp,16
ffffffffc020064a:	8082                	ret

ffffffffc020064c <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020064c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200650:	8082                	ret

ffffffffc0200652 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200652:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200656:	8082                	ret

ffffffffc0200658 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200658:	8082                	ret

ffffffffc020065a <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020065a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020065e:	00000797          	auipc	a5,0x0
ffffffffc0200662:	67278793          	addi	a5,a5,1650 # ffffffffc0200cd0 <__alltraps>
ffffffffc0200666:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020066a:	000407b7          	lui	a5,0x40
ffffffffc020066e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200672:	8082                	ret

ffffffffc0200674 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200676:	1141                	addi	sp,sp,-16
ffffffffc0200678:	e022                	sd	s0,0(sp)
ffffffffc020067a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	00009517          	auipc	a0,0x9
ffffffffc0200680:	0e450513          	addi	a0,a0,228 # ffffffffc0209760 <commands+0x508>
void print_regs(struct pushregs* gpr) {
ffffffffc0200684:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200686:	b0dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020068a:	640c                	ld	a1,8(s0)
ffffffffc020068c:	00009517          	auipc	a0,0x9
ffffffffc0200690:	0ec50513          	addi	a0,a0,236 # ffffffffc0209778 <commands+0x520>
ffffffffc0200694:	affff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200698:	680c                	ld	a1,16(s0)
ffffffffc020069a:	00009517          	auipc	a0,0x9
ffffffffc020069e:	0f650513          	addi	a0,a0,246 # ffffffffc0209790 <commands+0x538>
ffffffffc02006a2:	af1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006a6:	6c0c                	ld	a1,24(s0)
ffffffffc02006a8:	00009517          	auipc	a0,0x9
ffffffffc02006ac:	10050513          	addi	a0,a0,256 # ffffffffc02097a8 <commands+0x550>
ffffffffc02006b0:	ae3ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006b4:	700c                	ld	a1,32(s0)
ffffffffc02006b6:	00009517          	auipc	a0,0x9
ffffffffc02006ba:	10a50513          	addi	a0,a0,266 # ffffffffc02097c0 <commands+0x568>
ffffffffc02006be:	ad5ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006c2:	740c                	ld	a1,40(s0)
ffffffffc02006c4:	00009517          	auipc	a0,0x9
ffffffffc02006c8:	11450513          	addi	a0,a0,276 # ffffffffc02097d8 <commands+0x580>
ffffffffc02006cc:	ac7ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d0:	780c                	ld	a1,48(s0)
ffffffffc02006d2:	00009517          	auipc	a0,0x9
ffffffffc02006d6:	11e50513          	addi	a0,a0,286 # ffffffffc02097f0 <commands+0x598>
ffffffffc02006da:	ab9ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006de:	7c0c                	ld	a1,56(s0)
ffffffffc02006e0:	00009517          	auipc	a0,0x9
ffffffffc02006e4:	12850513          	addi	a0,a0,296 # ffffffffc0209808 <commands+0x5b0>
ffffffffc02006e8:	aabff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006ec:	602c                	ld	a1,64(s0)
ffffffffc02006ee:	00009517          	auipc	a0,0x9
ffffffffc02006f2:	13250513          	addi	a0,a0,306 # ffffffffc0209820 <commands+0x5c8>
ffffffffc02006f6:	a9dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006fa:	642c                	ld	a1,72(s0)
ffffffffc02006fc:	00009517          	auipc	a0,0x9
ffffffffc0200700:	13c50513          	addi	a0,a0,316 # ffffffffc0209838 <commands+0x5e0>
ffffffffc0200704:	a8fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200708:	682c                	ld	a1,80(s0)
ffffffffc020070a:	00009517          	auipc	a0,0x9
ffffffffc020070e:	14650513          	addi	a0,a0,326 # ffffffffc0209850 <commands+0x5f8>
ffffffffc0200712:	a81ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200716:	6c2c                	ld	a1,88(s0)
ffffffffc0200718:	00009517          	auipc	a0,0x9
ffffffffc020071c:	15050513          	addi	a0,a0,336 # ffffffffc0209868 <commands+0x610>
ffffffffc0200720:	a73ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200724:	702c                	ld	a1,96(s0)
ffffffffc0200726:	00009517          	auipc	a0,0x9
ffffffffc020072a:	15a50513          	addi	a0,a0,346 # ffffffffc0209880 <commands+0x628>
ffffffffc020072e:	a65ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200732:	742c                	ld	a1,104(s0)
ffffffffc0200734:	00009517          	auipc	a0,0x9
ffffffffc0200738:	16450513          	addi	a0,a0,356 # ffffffffc0209898 <commands+0x640>
ffffffffc020073c:	a57ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200740:	782c                	ld	a1,112(s0)
ffffffffc0200742:	00009517          	auipc	a0,0x9
ffffffffc0200746:	16e50513          	addi	a0,a0,366 # ffffffffc02098b0 <commands+0x658>
ffffffffc020074a:	a49ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020074e:	7c2c                	ld	a1,120(s0)
ffffffffc0200750:	00009517          	auipc	a0,0x9
ffffffffc0200754:	17850513          	addi	a0,a0,376 # ffffffffc02098c8 <commands+0x670>
ffffffffc0200758:	a3bff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020075c:	604c                	ld	a1,128(s0)
ffffffffc020075e:	00009517          	auipc	a0,0x9
ffffffffc0200762:	18250513          	addi	a0,a0,386 # ffffffffc02098e0 <commands+0x688>
ffffffffc0200766:	a2dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020076a:	644c                	ld	a1,136(s0)
ffffffffc020076c:	00009517          	auipc	a0,0x9
ffffffffc0200770:	18c50513          	addi	a0,a0,396 # ffffffffc02098f8 <commands+0x6a0>
ffffffffc0200774:	a1fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200778:	684c                	ld	a1,144(s0)
ffffffffc020077a:	00009517          	auipc	a0,0x9
ffffffffc020077e:	19650513          	addi	a0,a0,406 # ffffffffc0209910 <commands+0x6b8>
ffffffffc0200782:	a11ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200786:	6c4c                	ld	a1,152(s0)
ffffffffc0200788:	00009517          	auipc	a0,0x9
ffffffffc020078c:	1a050513          	addi	a0,a0,416 # ffffffffc0209928 <commands+0x6d0>
ffffffffc0200790:	a03ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200794:	704c                	ld	a1,160(s0)
ffffffffc0200796:	00009517          	auipc	a0,0x9
ffffffffc020079a:	1aa50513          	addi	a0,a0,426 # ffffffffc0209940 <commands+0x6e8>
ffffffffc020079e:	9f5ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007a2:	744c                	ld	a1,168(s0)
ffffffffc02007a4:	00009517          	auipc	a0,0x9
ffffffffc02007a8:	1b450513          	addi	a0,a0,436 # ffffffffc0209958 <commands+0x700>
ffffffffc02007ac:	9e7ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b0:	784c                	ld	a1,176(s0)
ffffffffc02007b2:	00009517          	auipc	a0,0x9
ffffffffc02007b6:	1be50513          	addi	a0,a0,446 # ffffffffc0209970 <commands+0x718>
ffffffffc02007ba:	9d9ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007be:	7c4c                	ld	a1,184(s0)
ffffffffc02007c0:	00009517          	auipc	a0,0x9
ffffffffc02007c4:	1c850513          	addi	a0,a0,456 # ffffffffc0209988 <commands+0x730>
ffffffffc02007c8:	9cbff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007cc:	606c                	ld	a1,192(s0)
ffffffffc02007ce:	00009517          	auipc	a0,0x9
ffffffffc02007d2:	1d250513          	addi	a0,a0,466 # ffffffffc02099a0 <commands+0x748>
ffffffffc02007d6:	9bdff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007da:	646c                	ld	a1,200(s0)
ffffffffc02007dc:	00009517          	auipc	a0,0x9
ffffffffc02007e0:	1dc50513          	addi	a0,a0,476 # ffffffffc02099b8 <commands+0x760>
ffffffffc02007e4:	9afff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e8:	686c                	ld	a1,208(s0)
ffffffffc02007ea:	00009517          	auipc	a0,0x9
ffffffffc02007ee:	1e650513          	addi	a0,a0,486 # ffffffffc02099d0 <commands+0x778>
ffffffffc02007f2:	9a1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007f6:	6c6c                	ld	a1,216(s0)
ffffffffc02007f8:	00009517          	auipc	a0,0x9
ffffffffc02007fc:	1f050513          	addi	a0,a0,496 # ffffffffc02099e8 <commands+0x790>
ffffffffc0200800:	993ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200804:	706c                	ld	a1,224(s0)
ffffffffc0200806:	00009517          	auipc	a0,0x9
ffffffffc020080a:	1fa50513          	addi	a0,a0,506 # ffffffffc0209a00 <commands+0x7a8>
ffffffffc020080e:	985ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200812:	746c                	ld	a1,232(s0)
ffffffffc0200814:	00009517          	auipc	a0,0x9
ffffffffc0200818:	20450513          	addi	a0,a0,516 # ffffffffc0209a18 <commands+0x7c0>
ffffffffc020081c:	977ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200820:	786c                	ld	a1,240(s0)
ffffffffc0200822:	00009517          	auipc	a0,0x9
ffffffffc0200826:	20e50513          	addi	a0,a0,526 # ffffffffc0209a30 <commands+0x7d8>
ffffffffc020082a:	969ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200830:	6402                	ld	s0,0(sp)
ffffffffc0200832:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200834:	00009517          	auipc	a0,0x9
ffffffffc0200838:	21450513          	addi	a0,a0,532 # ffffffffc0209a48 <commands+0x7f0>
}
ffffffffc020083c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083e:	955ff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0200842 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200842:	1141                	addi	sp,sp,-16
ffffffffc0200844:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200846:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200848:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020084a:	00009517          	auipc	a0,0x9
ffffffffc020084e:	21650513          	addi	a0,a0,534 # ffffffffc0209a60 <commands+0x808>
print_trapframe(struct trapframe *tf) {
ffffffffc0200852:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200854:	93fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200858:	8522                	mv	a0,s0
ffffffffc020085a:	e1bff0ef          	jal	ra,ffffffffc0200674 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020085e:	10043583          	ld	a1,256(s0)
ffffffffc0200862:	00009517          	auipc	a0,0x9
ffffffffc0200866:	21650513          	addi	a0,a0,534 # ffffffffc0209a78 <commands+0x820>
ffffffffc020086a:	929ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020086e:	10843583          	ld	a1,264(s0)
ffffffffc0200872:	00009517          	auipc	a0,0x9
ffffffffc0200876:	21e50513          	addi	a0,a0,542 # ffffffffc0209a90 <commands+0x838>
ffffffffc020087a:	919ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020087e:	11043583          	ld	a1,272(s0)
ffffffffc0200882:	00009517          	auipc	a0,0x9
ffffffffc0200886:	22650513          	addi	a0,a0,550 # ffffffffc0209aa8 <commands+0x850>
ffffffffc020088a:	909ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200892:	6402                	ld	s0,0(sp)
ffffffffc0200894:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	00009517          	auipc	a0,0x9
ffffffffc020089a:	22250513          	addi	a0,a0,546 # ffffffffc0209ab8 <commands+0x860>
}
ffffffffc020089e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a0:	8f3ff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc02008a4 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a4:	1101                	addi	sp,sp,-32
ffffffffc02008a6:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008a8:	000c9497          	auipc	s1,0xc9
ffffffffc02008ac:	a5848493          	addi	s1,s1,-1448 # ffffffffc02c9300 <check_mm_struct>
ffffffffc02008b0:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008b2:	e822                	sd	s0,16(sp)
ffffffffc02008b4:	ec06                	sd	ra,24(sp)
ffffffffc02008b6:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b8:	cbbd                	beqz	a5,ffffffffc020092e <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ba:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008be:	11053583          	ld	a1,272(a0)
ffffffffc02008c2:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c6:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008ca:	cba1                	beqz	a5,ffffffffc020091a <pgfault_handler+0x76>
ffffffffc02008cc:	11843703          	ld	a4,280(s0)
ffffffffc02008d0:	47bd                	li	a5,15
ffffffffc02008d2:	05700693          	li	a3,87
ffffffffc02008d6:	00f70463          	beq	a4,a5,ffffffffc02008de <pgfault_handler+0x3a>
ffffffffc02008da:	05200693          	li	a3,82
ffffffffc02008de:	00009517          	auipc	a0,0x9
ffffffffc02008e2:	e0250513          	addi	a0,a0,-510 # ffffffffc02096e0 <commands+0x488>
ffffffffc02008e6:	8adff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008ea:	6088                	ld	a0,0(s1)
ffffffffc02008ec:	c129                	beqz	a0,ffffffffc020092e <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008ee:	000c9797          	auipc	a5,0xc9
ffffffffc02008f2:	8ca78793          	addi	a5,a5,-1846 # ffffffffc02c91b8 <current>
ffffffffc02008f6:	6398                	ld	a4,0(a5)
ffffffffc02008f8:	000c9797          	auipc	a5,0xc9
ffffffffc02008fc:	8c878793          	addi	a5,a5,-1848 # ffffffffc02c91c0 <idleproc>
ffffffffc0200900:	639c                	ld	a5,0(a5)
ffffffffc0200902:	04f71763          	bne	a4,a5,ffffffffc0200950 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200906:	11043603          	ld	a2,272(s0)
ffffffffc020090a:	11843583          	ld	a1,280(s0)
}
ffffffffc020090e:	6442                	ld	s0,16(sp)
ffffffffc0200910:	60e2                	ld	ra,24(sp)
ffffffffc0200912:	64a2                	ld	s1,8(sp)
ffffffffc0200914:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200916:	0820406f          	j	ffffffffc0204998 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020091a:	11843703          	ld	a4,280(s0)
ffffffffc020091e:	47bd                	li	a5,15
ffffffffc0200920:	05500613          	li	a2,85
ffffffffc0200924:	05700693          	li	a3,87
ffffffffc0200928:	faf719e3          	bne	a4,a5,ffffffffc02008da <pgfault_handler+0x36>
ffffffffc020092c:	bf4d                	j	ffffffffc02008de <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020092e:	000c9797          	auipc	a5,0xc9
ffffffffc0200932:	88a78793          	addi	a5,a5,-1910 # ffffffffc02c91b8 <current>
ffffffffc0200936:	639c                	ld	a5,0(a5)
ffffffffc0200938:	cf85                	beqz	a5,ffffffffc0200970 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020093a:	11043603          	ld	a2,272(s0)
ffffffffc020093e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200942:	6442                	ld	s0,16(sp)
ffffffffc0200944:	60e2                	ld	ra,24(sp)
ffffffffc0200946:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200948:	7788                	ld	a0,40(a5)
}
ffffffffc020094a:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020094c:	04c0406f          	j	ffffffffc0204998 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200950:	00009697          	auipc	a3,0x9
ffffffffc0200954:	db068693          	addi	a3,a3,-592 # ffffffffc0209700 <commands+0x4a8>
ffffffffc0200958:	00009617          	auipc	a2,0x9
ffffffffc020095c:	dc060613          	addi	a2,a2,-576 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0200960:	06c00593          	li	a1,108
ffffffffc0200964:	00009517          	auipc	a0,0x9
ffffffffc0200968:	dcc50513          	addi	a0,a0,-564 # ffffffffc0209730 <commands+0x4d8>
ffffffffc020096c:	b1dff0ef          	jal	ra,ffffffffc0200488 <__panic>
            print_trapframe(tf);
ffffffffc0200970:	8522                	mv	a0,s0
ffffffffc0200972:	ed1ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200976:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020097a:	11043583          	ld	a1,272(s0)
ffffffffc020097e:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200982:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200986:	e399                	bnez	a5,ffffffffc020098c <pgfault_handler+0xe8>
ffffffffc0200988:	05500613          	li	a2,85
ffffffffc020098c:	11843703          	ld	a4,280(s0)
ffffffffc0200990:	47bd                	li	a5,15
ffffffffc0200992:	02f70663          	beq	a4,a5,ffffffffc02009be <pgfault_handler+0x11a>
ffffffffc0200996:	05200693          	li	a3,82
ffffffffc020099a:	00009517          	auipc	a0,0x9
ffffffffc020099e:	d4650513          	addi	a0,a0,-698 # ffffffffc02096e0 <commands+0x488>
ffffffffc02009a2:	ff0ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009a6:	00009617          	auipc	a2,0x9
ffffffffc02009aa:	da260613          	addi	a2,a2,-606 # ffffffffc0209748 <commands+0x4f0>
ffffffffc02009ae:	07300593          	li	a1,115
ffffffffc02009b2:	00009517          	auipc	a0,0x9
ffffffffc02009b6:	d7e50513          	addi	a0,a0,-642 # ffffffffc0209730 <commands+0x4d8>
ffffffffc02009ba:	acfff0ef          	jal	ra,ffffffffc0200488 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009be:	05700693          	li	a3,87
ffffffffc02009c2:	bfe1                	j	ffffffffc020099a <pgfault_handler+0xf6>

ffffffffc02009c4 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009c4:	11853783          	ld	a5,280(a0)
ffffffffc02009c8:	577d                	li	a4,-1
ffffffffc02009ca:	8305                	srli	a4,a4,0x1
ffffffffc02009cc:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009ce:	472d                	li	a4,11
ffffffffc02009d0:	08f76163          	bltu	a4,a5,ffffffffc0200a52 <interrupt_handler+0x8e>
ffffffffc02009d4:	00009717          	auipc	a4,0x9
ffffffffc02009d8:	a6070713          	addi	a4,a4,-1440 # ffffffffc0209434 <commands+0x1dc>
ffffffffc02009dc:	078a                	slli	a5,a5,0x2
ffffffffc02009de:	97ba                	add	a5,a5,a4
ffffffffc02009e0:	439c                	lw	a5,0(a5)
ffffffffc02009e2:	97ba                	add	a5,a5,a4
ffffffffc02009e4:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009e6:	00009517          	auipc	a0,0x9
ffffffffc02009ea:	cba50513          	addi	a0,a0,-838 # ffffffffc02096a0 <commands+0x448>
ffffffffc02009ee:	fa4ff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009f2:	00009517          	auipc	a0,0x9
ffffffffc02009f6:	c8e50513          	addi	a0,a0,-882 # ffffffffc0209680 <commands+0x428>
ffffffffc02009fa:	f98ff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009fe:	00009517          	auipc	a0,0x9
ffffffffc0200a02:	c4250513          	addi	a0,a0,-958 # ffffffffc0209640 <commands+0x3e8>
ffffffffc0200a06:	f8cff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a0a:	00009517          	auipc	a0,0x9
ffffffffc0200a0e:	c5650513          	addi	a0,a0,-938 # ffffffffc0209660 <commands+0x408>
ffffffffc0200a12:	f80ff06f          	j	ffffffffc0200192 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a16:	00009517          	auipc	a0,0x9
ffffffffc0200a1a:	caa50513          	addi	a0,a0,-854 # ffffffffc02096c0 <commands+0x468>
ffffffffc0200a1e:	f74ff06f          	j	ffffffffc0200192 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a22:	1141                	addi	sp,sp,-16
ffffffffc0200a24:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a26:	b43ff0ef          	jal	ra,ffffffffc0200568 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 ) {
ffffffffc0200a2a:	000c8797          	auipc	a5,0xc8
ffffffffc0200a2e:	7be78793          	addi	a5,a5,1982 # ffffffffc02c91e8 <ticks>
ffffffffc0200a32:	639c                	ld	a5,0(a5)
            if (current){
ffffffffc0200a34:	000c8717          	auipc	a4,0xc8
ffffffffc0200a38:	78470713          	addi	a4,a4,1924 # ffffffffc02c91b8 <current>
ffffffffc0200a3c:	6308                	ld	a0,0(a4)
            if (++ticks % TICK_NUM == 0 ) {
ffffffffc0200a3e:	0785                	addi	a5,a5,1
ffffffffc0200a40:	000c8717          	auipc	a4,0xc8
ffffffffc0200a44:	7af73423          	sd	a5,1960(a4) # ffffffffc02c91e8 <ticks>
            if (current){
ffffffffc0200a48:	c519                	beqz	a0,ffffffffc0200a56 <interrupt_handler+0x92>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a4a:	60a2                	ld	ra,8(sp)
ffffffffc0200a4c:	0141                	addi	sp,sp,16
                sched_class_proc_tick(current); 
ffffffffc0200a4e:	6ef0706f          	j	ffffffffc020893c <sched_class_proc_tick>
            print_trapframe(tf);
ffffffffc0200a52:	df1ff06f          	j	ffffffffc0200842 <print_trapframe>
}
ffffffffc0200a56:	60a2                	ld	ra,8(sp)
ffffffffc0200a58:	0141                	addi	sp,sp,16
ffffffffc0200a5a:	8082                	ret

ffffffffc0200a5c <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a5c:	11853783          	ld	a5,280(a0)
ffffffffc0200a60:	473d                	li	a4,15
ffffffffc0200a62:	1af76e63          	bltu	a4,a5,ffffffffc0200c1e <exception_handler+0x1c2>
ffffffffc0200a66:	00009717          	auipc	a4,0x9
ffffffffc0200a6a:	9fe70713          	addi	a4,a4,-1538 # ffffffffc0209464 <commands+0x20c>
ffffffffc0200a6e:	078a                	slli	a5,a5,0x2
ffffffffc0200a70:	97ba                	add	a5,a5,a4
ffffffffc0200a72:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a74:	1101                	addi	sp,sp,-32
ffffffffc0200a76:	e822                	sd	s0,16(sp)
ffffffffc0200a78:	ec06                	sd	ra,24(sp)
ffffffffc0200a7a:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a7c:	97ba                	add	a5,a5,a4
ffffffffc0200a7e:	842a                	mv	s0,a0
ffffffffc0200a80:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a82:	00009517          	auipc	a0,0x9
ffffffffc0200a86:	b1650513          	addi	a0,a0,-1258 # ffffffffc0209598 <commands+0x340>
ffffffffc0200a8a:	f08ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            tf->epc += 4;
ffffffffc0200a8e:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a92:	60e2                	ld	ra,24(sp)
ffffffffc0200a94:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a96:	0791                	addi	a5,a5,4
ffffffffc0200a98:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a9c:	6442                	ld	s0,16(sp)
ffffffffc0200a9e:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aa0:	1280806f          	j	ffffffffc0208bc8 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200aa4:	00009517          	auipc	a0,0x9
ffffffffc0200aa8:	b1450513          	addi	a0,a0,-1260 # ffffffffc02095b8 <commands+0x360>
}
ffffffffc0200aac:	6442                	ld	s0,16(sp)
ffffffffc0200aae:	60e2                	ld	ra,24(sp)
ffffffffc0200ab0:	64a2                	ld	s1,8(sp)
ffffffffc0200ab2:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ab4:	edeff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ab8:	00009517          	auipc	a0,0x9
ffffffffc0200abc:	b2050513          	addi	a0,a0,-1248 # ffffffffc02095d8 <commands+0x380>
ffffffffc0200ac0:	b7f5                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ac2:	00009517          	auipc	a0,0x9
ffffffffc0200ac6:	b3650513          	addi	a0,a0,-1226 # ffffffffc02095f8 <commands+0x3a0>
ffffffffc0200aca:	b7cd                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200acc:	00009517          	auipc	a0,0x9
ffffffffc0200ad0:	b4450513          	addi	a0,a0,-1212 # ffffffffc0209610 <commands+0x3b8>
ffffffffc0200ad4:	ebeff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ad8:	8522                	mv	a0,s0
ffffffffc0200ada:	dcbff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200ade:	84aa                	mv	s1,a0
ffffffffc0200ae0:	14051163          	bnez	a0,ffffffffc0200c22 <exception_handler+0x1c6>
}
ffffffffc0200ae4:	60e2                	ld	ra,24(sp)
ffffffffc0200ae6:	6442                	ld	s0,16(sp)
ffffffffc0200ae8:	64a2                	ld	s1,8(sp)
ffffffffc0200aea:	6105                	addi	sp,sp,32
ffffffffc0200aec:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200aee:	00009517          	auipc	a0,0x9
ffffffffc0200af2:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0209628 <commands+0x3d0>
ffffffffc0200af6:	e9cff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200afa:	8522                	mv	a0,s0
ffffffffc0200afc:	da9ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200b00:	84aa                	mv	s1,a0
ffffffffc0200b02:	d16d                	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b04:	8522                	mv	a0,s0
ffffffffc0200b06:	d3dff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b0a:	86a6                	mv	a3,s1
ffffffffc0200b0c:	00009617          	auipc	a2,0x9
ffffffffc0200b10:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0209548 <commands+0x2f0>
ffffffffc0200b14:	0fc00593          	li	a1,252
ffffffffc0200b18:	00009517          	auipc	a0,0x9
ffffffffc0200b1c:	c1850513          	addi	a0,a0,-1000 # ffffffffc0209730 <commands+0x4d8>
ffffffffc0200b20:	969ff0ef          	jal	ra,ffffffffc0200488 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b24:	00009517          	auipc	a0,0x9
ffffffffc0200b28:	98450513          	addi	a0,a0,-1660 # ffffffffc02094a8 <commands+0x250>
ffffffffc0200b2c:	b741                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b2e:	00009517          	auipc	a0,0x9
ffffffffc0200b32:	99a50513          	addi	a0,a0,-1638 # ffffffffc02094c8 <commands+0x270>
ffffffffc0200b36:	bf9d                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b38:	00009517          	auipc	a0,0x9
ffffffffc0200b3c:	9b050513          	addi	a0,a0,-1616 # ffffffffc02094e8 <commands+0x290>
ffffffffc0200b40:	b7b5                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b42:	00009517          	auipc	a0,0x9
ffffffffc0200b46:	9be50513          	addi	a0,a0,-1602 # ffffffffc0209500 <commands+0x2a8>
ffffffffc0200b4a:	e48ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b4e:	6458                	ld	a4,136(s0)
ffffffffc0200b50:	47a9                	li	a5,10
ffffffffc0200b52:	f8f719e3          	bne	a4,a5,ffffffffc0200ae4 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b56:	10843783          	ld	a5,264(s0)
ffffffffc0200b5a:	0791                	addi	a5,a5,4
ffffffffc0200b5c:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b60:	068080ef          	jal	ra,ffffffffc0208bc8 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b64:	000c8797          	auipc	a5,0xc8
ffffffffc0200b68:	65478793          	addi	a5,a5,1620 # ffffffffc02c91b8 <current>
ffffffffc0200b6c:	639c                	ld	a5,0(a5)
ffffffffc0200b6e:	8522                	mv	a0,s0
}
ffffffffc0200b70:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b74:	60e2                	ld	ra,24(sp)
ffffffffc0200b76:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b78:	6589                	lui	a1,0x2
ffffffffc0200b7a:	95be                	add	a1,a1,a5
}
ffffffffc0200b7c:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b7e:	2200006f          	j	ffffffffc0200d9e <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b82:	00009517          	auipc	a0,0x9
ffffffffc0200b86:	98e50513          	addi	a0,a0,-1650 # ffffffffc0209510 <commands+0x2b8>
ffffffffc0200b8a:	b70d                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b8c:	00009517          	auipc	a0,0x9
ffffffffc0200b90:	9a450513          	addi	a0,a0,-1628 # ffffffffc0209530 <commands+0x2d8>
ffffffffc0200b94:	dfeff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b98:	8522                	mv	a0,s0
ffffffffc0200b9a:	d0bff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200b9e:	84aa                	mv	s1,a0
ffffffffc0200ba0:	d131                	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ba2:	8522                	mv	a0,s0
ffffffffc0200ba4:	c9fff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ba8:	86a6                	mv	a3,s1
ffffffffc0200baa:	00009617          	auipc	a2,0x9
ffffffffc0200bae:	99e60613          	addi	a2,a2,-1634 # ffffffffc0209548 <commands+0x2f0>
ffffffffc0200bb2:	0d100593          	li	a1,209
ffffffffc0200bb6:	00009517          	auipc	a0,0x9
ffffffffc0200bba:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0209730 <commands+0x4d8>
ffffffffc0200bbe:	8cbff0ef          	jal	ra,ffffffffc0200488 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bc2:	00009517          	auipc	a0,0x9
ffffffffc0200bc6:	9be50513          	addi	a0,a0,-1602 # ffffffffc0209580 <commands+0x328>
ffffffffc0200bca:	dc8ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bce:	8522                	mv	a0,s0
ffffffffc0200bd0:	cd5ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200bd4:	84aa                	mv	s1,a0
ffffffffc0200bd6:	f00507e3          	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bda:	8522                	mv	a0,s0
ffffffffc0200bdc:	c67ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200be0:	86a6                	mv	a3,s1
ffffffffc0200be2:	00009617          	auipc	a2,0x9
ffffffffc0200be6:	96660613          	addi	a2,a2,-1690 # ffffffffc0209548 <commands+0x2f0>
ffffffffc0200bea:	0db00593          	li	a1,219
ffffffffc0200bee:	00009517          	auipc	a0,0x9
ffffffffc0200bf2:	b4250513          	addi	a0,a0,-1214 # ffffffffc0209730 <commands+0x4d8>
ffffffffc0200bf6:	893ff0ef          	jal	ra,ffffffffc0200488 <__panic>
}
ffffffffc0200bfa:	6442                	ld	s0,16(sp)
ffffffffc0200bfc:	60e2                	ld	ra,24(sp)
ffffffffc0200bfe:	64a2                	ld	s1,8(sp)
ffffffffc0200c00:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c02:	c41ff06f          	j	ffffffffc0200842 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c06:	00009617          	auipc	a2,0x9
ffffffffc0200c0a:	96260613          	addi	a2,a2,-1694 # ffffffffc0209568 <commands+0x310>
ffffffffc0200c0e:	0d500593          	li	a1,213
ffffffffc0200c12:	00009517          	auipc	a0,0x9
ffffffffc0200c16:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0209730 <commands+0x4d8>
ffffffffc0200c1a:	86fff0ef          	jal	ra,ffffffffc0200488 <__panic>
            print_trapframe(tf);
ffffffffc0200c1e:	c25ff06f          	j	ffffffffc0200842 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c22:	8522                	mv	a0,s0
ffffffffc0200c24:	c1fff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c28:	86a6                	mv	a3,s1
ffffffffc0200c2a:	00009617          	auipc	a2,0x9
ffffffffc0200c2e:	91e60613          	addi	a2,a2,-1762 # ffffffffc0209548 <commands+0x2f0>
ffffffffc0200c32:	0f500593          	li	a1,245
ffffffffc0200c36:	00009517          	auipc	a0,0x9
ffffffffc0200c3a:	afa50513          	addi	a0,a0,-1286 # ffffffffc0209730 <commands+0x4d8>
ffffffffc0200c3e:	84bff0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0200c42 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c42:	1101                	addi	sp,sp,-32
ffffffffc0200c44:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c46:	000c8417          	auipc	s0,0xc8
ffffffffc0200c4a:	57240413          	addi	s0,s0,1394 # ffffffffc02c91b8 <current>
ffffffffc0200c4e:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c50:	ec06                	sd	ra,24(sp)
ffffffffc0200c52:	e426                	sd	s1,8(sp)
ffffffffc0200c54:	e04a                	sd	s2,0(sp)
ffffffffc0200c56:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c5a:	cf1d                	beqz	a4,ffffffffc0200c98 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c5c:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c60:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c64:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c66:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c6a:	0206c463          	bltz	a3,ffffffffc0200c92 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c6e:	defff0ef          	jal	ra,ffffffffc0200a5c <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c72:	601c                	ld	a5,0(s0)
ffffffffc0200c74:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c78:	e499                	bnez	s1,ffffffffc0200c86 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c7a:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c7e:	8b05                	andi	a4,a4,1
ffffffffc0200c80:	e339                	bnez	a4,ffffffffc0200cc6 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c82:	6f9c                	ld	a5,24(a5)
ffffffffc0200c84:	eb95                	bnez	a5,ffffffffc0200cb8 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c86:	60e2                	ld	ra,24(sp)
ffffffffc0200c88:	6442                	ld	s0,16(sp)
ffffffffc0200c8a:	64a2                	ld	s1,8(sp)
ffffffffc0200c8c:	6902                	ld	s2,0(sp)
ffffffffc0200c8e:	6105                	addi	sp,sp,32
ffffffffc0200c90:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c92:	d33ff0ef          	jal	ra,ffffffffc02009c4 <interrupt_handler>
ffffffffc0200c96:	bff1                	j	ffffffffc0200c72 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c98:	0006c963          	bltz	a3,ffffffffc0200caa <trap+0x68>
}
ffffffffc0200c9c:	6442                	ld	s0,16(sp)
ffffffffc0200c9e:	60e2                	ld	ra,24(sp)
ffffffffc0200ca0:	64a2                	ld	s1,8(sp)
ffffffffc0200ca2:	6902                	ld	s2,0(sp)
ffffffffc0200ca4:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200ca6:	db7ff06f          	j	ffffffffc0200a5c <exception_handler>
}
ffffffffc0200caa:	6442                	ld	s0,16(sp)
ffffffffc0200cac:	60e2                	ld	ra,24(sp)
ffffffffc0200cae:	64a2                	ld	s1,8(sp)
ffffffffc0200cb0:	6902                	ld	s2,0(sp)
ffffffffc0200cb2:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cb4:	d11ff06f          	j	ffffffffc02009c4 <interrupt_handler>
}
ffffffffc0200cb8:	6442                	ld	s0,16(sp)
ffffffffc0200cba:	60e2                	ld	ra,24(sp)
ffffffffc0200cbc:	64a2                	ld	s1,8(sp)
ffffffffc0200cbe:	6902                	ld	s2,0(sp)
ffffffffc0200cc0:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cc2:	5b90706f          	j	ffffffffc0208a7a <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cc6:	555d                	li	a0,-9
ffffffffc0200cc8:	70c040ef          	jal	ra,ffffffffc02053d4 <do_exit>
ffffffffc0200ccc:	601c                	ld	a5,0(s0)
ffffffffc0200cce:	bf55                	j	ffffffffc0200c82 <trap+0x40>

ffffffffc0200cd0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cd0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cd4:	00011463          	bnez	sp,ffffffffc0200cdc <__alltraps+0xc>
ffffffffc0200cd8:	14002173          	csrr	sp,sscratch
ffffffffc0200cdc:	712d                	addi	sp,sp,-288
ffffffffc0200cde:	e002                	sd	zero,0(sp)
ffffffffc0200ce0:	e406                	sd	ra,8(sp)
ffffffffc0200ce2:	ec0e                	sd	gp,24(sp)
ffffffffc0200ce4:	f012                	sd	tp,32(sp)
ffffffffc0200ce6:	f416                	sd	t0,40(sp)
ffffffffc0200ce8:	f81a                	sd	t1,48(sp)
ffffffffc0200cea:	fc1e                	sd	t2,56(sp)
ffffffffc0200cec:	e0a2                	sd	s0,64(sp)
ffffffffc0200cee:	e4a6                	sd	s1,72(sp)
ffffffffc0200cf0:	e8aa                	sd	a0,80(sp)
ffffffffc0200cf2:	ecae                	sd	a1,88(sp)
ffffffffc0200cf4:	f0b2                	sd	a2,96(sp)
ffffffffc0200cf6:	f4b6                	sd	a3,104(sp)
ffffffffc0200cf8:	f8ba                	sd	a4,112(sp)
ffffffffc0200cfa:	fcbe                	sd	a5,120(sp)
ffffffffc0200cfc:	e142                	sd	a6,128(sp)
ffffffffc0200cfe:	e546                	sd	a7,136(sp)
ffffffffc0200d00:	e94a                	sd	s2,144(sp)
ffffffffc0200d02:	ed4e                	sd	s3,152(sp)
ffffffffc0200d04:	f152                	sd	s4,160(sp)
ffffffffc0200d06:	f556                	sd	s5,168(sp)
ffffffffc0200d08:	f95a                	sd	s6,176(sp)
ffffffffc0200d0a:	fd5e                	sd	s7,184(sp)
ffffffffc0200d0c:	e1e2                	sd	s8,192(sp)
ffffffffc0200d0e:	e5e6                	sd	s9,200(sp)
ffffffffc0200d10:	e9ea                	sd	s10,208(sp)
ffffffffc0200d12:	edee                	sd	s11,216(sp)
ffffffffc0200d14:	f1f2                	sd	t3,224(sp)
ffffffffc0200d16:	f5f6                	sd	t4,232(sp)
ffffffffc0200d18:	f9fa                	sd	t5,240(sp)
ffffffffc0200d1a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d1c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d20:	100024f3          	csrr	s1,sstatus
ffffffffc0200d24:	14102973          	csrr	s2,sepc
ffffffffc0200d28:	143029f3          	csrr	s3,stval
ffffffffc0200d2c:	14202a73          	csrr	s4,scause
ffffffffc0200d30:	e822                	sd	s0,16(sp)
ffffffffc0200d32:	e226                	sd	s1,256(sp)
ffffffffc0200d34:	e64a                	sd	s2,264(sp)
ffffffffc0200d36:	ea4e                	sd	s3,272(sp)
ffffffffc0200d38:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d3a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d3c:	f07ff0ef          	jal	ra,ffffffffc0200c42 <trap>

ffffffffc0200d40 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d40:	6492                	ld	s1,256(sp)
ffffffffc0200d42:	6932                	ld	s2,264(sp)
ffffffffc0200d44:	1004f413          	andi	s0,s1,256
ffffffffc0200d48:	e401                	bnez	s0,ffffffffc0200d50 <__trapret+0x10>
ffffffffc0200d4a:	1200                	addi	s0,sp,288
ffffffffc0200d4c:	14041073          	csrw	sscratch,s0
ffffffffc0200d50:	10049073          	csrw	sstatus,s1
ffffffffc0200d54:	14191073          	csrw	sepc,s2
ffffffffc0200d58:	60a2                	ld	ra,8(sp)
ffffffffc0200d5a:	61e2                	ld	gp,24(sp)
ffffffffc0200d5c:	7202                	ld	tp,32(sp)
ffffffffc0200d5e:	72a2                	ld	t0,40(sp)
ffffffffc0200d60:	7342                	ld	t1,48(sp)
ffffffffc0200d62:	73e2                	ld	t2,56(sp)
ffffffffc0200d64:	6406                	ld	s0,64(sp)
ffffffffc0200d66:	64a6                	ld	s1,72(sp)
ffffffffc0200d68:	6546                	ld	a0,80(sp)
ffffffffc0200d6a:	65e6                	ld	a1,88(sp)
ffffffffc0200d6c:	7606                	ld	a2,96(sp)
ffffffffc0200d6e:	76a6                	ld	a3,104(sp)
ffffffffc0200d70:	7746                	ld	a4,112(sp)
ffffffffc0200d72:	77e6                	ld	a5,120(sp)
ffffffffc0200d74:	680a                	ld	a6,128(sp)
ffffffffc0200d76:	68aa                	ld	a7,136(sp)
ffffffffc0200d78:	694a                	ld	s2,144(sp)
ffffffffc0200d7a:	69ea                	ld	s3,152(sp)
ffffffffc0200d7c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d7e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d80:	7b4a                	ld	s6,176(sp)
ffffffffc0200d82:	7bea                	ld	s7,184(sp)
ffffffffc0200d84:	6c0e                	ld	s8,192(sp)
ffffffffc0200d86:	6cae                	ld	s9,200(sp)
ffffffffc0200d88:	6d4e                	ld	s10,208(sp)
ffffffffc0200d8a:	6dee                	ld	s11,216(sp)
ffffffffc0200d8c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d8e:	7eae                	ld	t4,232(sp)
ffffffffc0200d90:	7f4e                	ld	t5,240(sp)
ffffffffc0200d92:	7fee                	ld	t6,248(sp)
ffffffffc0200d94:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d96:	10200073          	sret

ffffffffc0200d9a <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d9a:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d9c:	b755                	j	ffffffffc0200d40 <__trapret>

ffffffffc0200d9e <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d9e:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7a10>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200da2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200da6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200daa:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dae:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200db2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200db6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dba:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dbe:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dc2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dc4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dc6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dc8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dca:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200dcc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dce:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dd0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dd2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200dd4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200dd6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dd8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dda:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200ddc:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dde:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200de0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200de2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200de4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200de6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200de8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dea:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dec:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dee:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200df0:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200df2:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200df4:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200df6:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200df8:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dfa:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dfc:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dfe:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e00:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e02:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e04:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e06:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e08:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e0a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e0c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e0e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e10:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e12:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e14:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e16:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e18:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e1a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e1c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e1e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e20:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e22:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e24:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e26:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e28:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e2a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e2c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e2e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e30:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e32:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e34:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e36:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e38:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e3a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e3c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e3e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e40:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e42:	812e                	mv	sp,a1
ffffffffc0200e44:	bdf5                	j	ffffffffc0200d40 <__trapret>

ffffffffc0200e46 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e46:	000c8797          	auipc	a5,0xc8
ffffffffc0200e4a:	3aa78793          	addi	a5,a5,938 # ffffffffc02c91f0 <free_area>
ffffffffc0200e4e:	e79c                	sd	a5,8(a5)
ffffffffc0200e50:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e52:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e56:	8082                	ret

ffffffffc0200e58 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e58:	000c8517          	auipc	a0,0xc8
ffffffffc0200e5c:	3a856503          	lwu	a0,936(a0) # ffffffffc02c9200 <free_area+0x10>
ffffffffc0200e60:	8082                	ret

ffffffffc0200e62 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e62:	715d                	addi	sp,sp,-80
ffffffffc0200e64:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e66:	000c8917          	auipc	s2,0xc8
ffffffffc0200e6a:	38a90913          	addi	s2,s2,906 # ffffffffc02c91f0 <free_area>
ffffffffc0200e6e:	00893783          	ld	a5,8(s2)
ffffffffc0200e72:	e486                	sd	ra,72(sp)
ffffffffc0200e74:	e0a2                	sd	s0,64(sp)
ffffffffc0200e76:	fc26                	sd	s1,56(sp)
ffffffffc0200e78:	f44e                	sd	s3,40(sp)
ffffffffc0200e7a:	f052                	sd	s4,32(sp)
ffffffffc0200e7c:	ec56                	sd	s5,24(sp)
ffffffffc0200e7e:	e85a                	sd	s6,16(sp)
ffffffffc0200e80:	e45e                	sd	s7,8(sp)
ffffffffc0200e82:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e84:	31278463          	beq	a5,s2,ffffffffc020118c <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e88:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e8c:	8305                	srli	a4,a4,0x1
ffffffffc0200e8e:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e90:	30070263          	beqz	a4,ffffffffc0201194 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200e94:	4401                	li	s0,0
ffffffffc0200e96:	4481                	li	s1,0
ffffffffc0200e98:	a031                	j	ffffffffc0200ea4 <default_check+0x42>
ffffffffc0200e9a:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200e9e:	8b09                	andi	a4,a4,2
ffffffffc0200ea0:	2e070a63          	beqz	a4,ffffffffc0201194 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200ea4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ea8:	679c                	ld	a5,8(a5)
ffffffffc0200eaa:	2485                	addiw	s1,s1,1
ffffffffc0200eac:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200eae:	ff2796e3          	bne	a5,s2,ffffffffc0200e9a <default_check+0x38>
ffffffffc0200eb2:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200eb4:	05c010ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc0200eb8:	73351e63          	bne	a0,s3,ffffffffc02015f4 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ebc:	4505                	li	a0,1
ffffffffc0200ebe:	785000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200ec2:	8a2a                	mv	s4,a0
ffffffffc0200ec4:	46050863          	beqz	a0,ffffffffc0201334 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ec8:	4505                	li	a0,1
ffffffffc0200eca:	779000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200ece:	89aa                	mv	s3,a0
ffffffffc0200ed0:	74050263          	beqz	a0,ffffffffc0201614 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ed4:	4505                	li	a0,1
ffffffffc0200ed6:	76d000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200eda:	8aaa                	mv	s5,a0
ffffffffc0200edc:	4c050c63          	beqz	a0,ffffffffc02013b4 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ee0:	2d3a0a63          	beq	s4,s3,ffffffffc02011b4 <default_check+0x352>
ffffffffc0200ee4:	2caa0863          	beq	s4,a0,ffffffffc02011b4 <default_check+0x352>
ffffffffc0200ee8:	2ca98663          	beq	s3,a0,ffffffffc02011b4 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eec:	000a2783          	lw	a5,0(s4)
ffffffffc0200ef0:	2e079263          	bnez	a5,ffffffffc02011d4 <default_check+0x372>
ffffffffc0200ef4:	0009a783          	lw	a5,0(s3)
ffffffffc0200ef8:	2c079e63          	bnez	a5,ffffffffc02011d4 <default_check+0x372>
ffffffffc0200efc:	411c                	lw	a5,0(a0)
ffffffffc0200efe:	2c079b63          	bnez	a5,ffffffffc02011d4 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200f02:	000c8797          	auipc	a5,0xc8
ffffffffc0200f06:	31e78793          	addi	a5,a5,798 # ffffffffc02c9220 <pages>
ffffffffc0200f0a:	639c                	ld	a5,0(a5)
ffffffffc0200f0c:	0000b717          	auipc	a4,0xb
ffffffffc0200f10:	09470713          	addi	a4,a4,148 # ffffffffc020bfa0 <nbase>
ffffffffc0200f14:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f16:	000c8717          	auipc	a4,0xc8
ffffffffc0200f1a:	28a70713          	addi	a4,a4,650 # ffffffffc02c91a0 <npage>
ffffffffc0200f1e:	6314                	ld	a3,0(a4)
ffffffffc0200f20:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f24:	8719                	srai	a4,a4,0x6
ffffffffc0200f26:	9732                	add	a4,a4,a2
ffffffffc0200f28:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f2a:	0732                	slli	a4,a4,0xc
ffffffffc0200f2c:	2cd77463          	bleu	a3,a4,ffffffffc02011f4 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f30:	40f98733          	sub	a4,s3,a5
ffffffffc0200f34:	8719                	srai	a4,a4,0x6
ffffffffc0200f36:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f38:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f3a:	4ed77d63          	bleu	a3,a4,ffffffffc0201434 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f3e:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f42:	8799                	srai	a5,a5,0x6
ffffffffc0200f44:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f46:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f48:	34d7f663          	bleu	a3,a5,ffffffffc0201294 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f4c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f4e:	00093c03          	ld	s8,0(s2)
ffffffffc0200f52:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f56:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200f5a:	000c8797          	auipc	a5,0xc8
ffffffffc0200f5e:	2927bf23          	sd	s2,670(a5) # ffffffffc02c91f8 <free_area+0x8>
ffffffffc0200f62:	000c8797          	auipc	a5,0xc8
ffffffffc0200f66:	2927b723          	sd	s2,654(a5) # ffffffffc02c91f0 <free_area>
    nr_free = 0;
ffffffffc0200f6a:	000c8797          	auipc	a5,0xc8
ffffffffc0200f6e:	2807ab23          	sw	zero,662(a5) # ffffffffc02c9200 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f72:	6d1000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200f76:	2e051f63          	bnez	a0,ffffffffc0201274 <default_check+0x412>
    free_page(p0);
ffffffffc0200f7a:	4585                	li	a1,1
ffffffffc0200f7c:	8552                	mv	a0,s4
ffffffffc0200f7e:	74d000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p1);
ffffffffc0200f82:	4585                	li	a1,1
ffffffffc0200f84:	854e                	mv	a0,s3
ffffffffc0200f86:	745000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p2);
ffffffffc0200f8a:	4585                	li	a1,1
ffffffffc0200f8c:	8556                	mv	a0,s5
ffffffffc0200f8e:	73d000ef          	jal	ra,ffffffffc0201eca <free_pages>
    assert(nr_free == 3);
ffffffffc0200f92:	01092703          	lw	a4,16(s2)
ffffffffc0200f96:	478d                	li	a5,3
ffffffffc0200f98:	2af71e63          	bne	a4,a5,ffffffffc0201254 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f9c:	4505                	li	a0,1
ffffffffc0200f9e:	6a5000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fa2:	89aa                	mv	s3,a0
ffffffffc0200fa4:	28050863          	beqz	a0,ffffffffc0201234 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fa8:	4505                	li	a0,1
ffffffffc0200faa:	699000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fae:	8aaa                	mv	s5,a0
ffffffffc0200fb0:	3e050263          	beqz	a0,ffffffffc0201394 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fb4:	4505                	li	a0,1
ffffffffc0200fb6:	68d000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fba:	8a2a                	mv	s4,a0
ffffffffc0200fbc:	3a050c63          	beqz	a0,ffffffffc0201374 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200fc0:	4505                	li	a0,1
ffffffffc0200fc2:	681000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fc6:	38051763          	bnez	a0,ffffffffc0201354 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200fca:	4585                	li	a1,1
ffffffffc0200fcc:	854e                	mv	a0,s3
ffffffffc0200fce:	6fd000ef          	jal	ra,ffffffffc0201eca <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200fd2:	00893783          	ld	a5,8(s2)
ffffffffc0200fd6:	23278f63          	beq	a5,s2,ffffffffc0201214 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200fda:	4505                	li	a0,1
ffffffffc0200fdc:	667000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fe0:	32a99a63          	bne	s3,a0,ffffffffc0201314 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200fe4:	4505                	li	a0,1
ffffffffc0200fe6:	65d000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fea:	30051563          	bnez	a0,ffffffffc02012f4 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200fee:	01092783          	lw	a5,16(s2)
ffffffffc0200ff2:	2e079163          	bnez	a5,ffffffffc02012d4 <default_check+0x472>
    free_page(p);
ffffffffc0200ff6:	854e                	mv	a0,s3
ffffffffc0200ff8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200ffa:	000c8797          	auipc	a5,0xc8
ffffffffc0200ffe:	1f87bb23          	sd	s8,502(a5) # ffffffffc02c91f0 <free_area>
ffffffffc0201002:	000c8797          	auipc	a5,0xc8
ffffffffc0201006:	1f77bb23          	sd	s7,502(a5) # ffffffffc02c91f8 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020100a:	000c8797          	auipc	a5,0xc8
ffffffffc020100e:	1f67ab23          	sw	s6,502(a5) # ffffffffc02c9200 <free_area+0x10>
    free_page(p);
ffffffffc0201012:	6b9000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p1);
ffffffffc0201016:	4585                	li	a1,1
ffffffffc0201018:	8556                	mv	a0,s5
ffffffffc020101a:	6b1000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p2);
ffffffffc020101e:	4585                	li	a1,1
ffffffffc0201020:	8552                	mv	a0,s4
ffffffffc0201022:	6a9000ef          	jal	ra,ffffffffc0201eca <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201026:	4515                	li	a0,5
ffffffffc0201028:	61b000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020102c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020102e:	28050363          	beqz	a0,ffffffffc02012b4 <default_check+0x452>
ffffffffc0201032:	651c                	ld	a5,8(a0)
ffffffffc0201034:	8385                	srli	a5,a5,0x1
ffffffffc0201036:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201038:	54079e63          	bnez	a5,ffffffffc0201594 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020103c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020103e:	00093b03          	ld	s6,0(s2)
ffffffffc0201042:	00893a83          	ld	s5,8(s2)
ffffffffc0201046:	000c8797          	auipc	a5,0xc8
ffffffffc020104a:	1b27b523          	sd	s2,426(a5) # ffffffffc02c91f0 <free_area>
ffffffffc020104e:	000c8797          	auipc	a5,0xc8
ffffffffc0201052:	1b27b523          	sd	s2,426(a5) # ffffffffc02c91f8 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0201056:	5ed000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020105a:	50051d63          	bnez	a0,ffffffffc0201574 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020105e:	08098a13          	addi	s4,s3,128
ffffffffc0201062:	8552                	mv	a0,s4
ffffffffc0201064:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201066:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc020106a:	000c8797          	auipc	a5,0xc8
ffffffffc020106e:	1807ab23          	sw	zero,406(a5) # ffffffffc02c9200 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201072:	659000ef          	jal	ra,ffffffffc0201eca <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201076:	4511                	li	a0,4
ffffffffc0201078:	5cb000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020107c:	4c051c63          	bnez	a0,ffffffffc0201554 <default_check+0x6f2>
ffffffffc0201080:	0889b783          	ld	a5,136(s3)
ffffffffc0201084:	8385                	srli	a5,a5,0x1
ffffffffc0201086:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201088:	4a078663          	beqz	a5,ffffffffc0201534 <default_check+0x6d2>
ffffffffc020108c:	0909a703          	lw	a4,144(s3)
ffffffffc0201090:	478d                	li	a5,3
ffffffffc0201092:	4af71163          	bne	a4,a5,ffffffffc0201534 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201096:	450d                	li	a0,3
ffffffffc0201098:	5ab000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020109c:	8c2a                	mv	s8,a0
ffffffffc020109e:	46050b63          	beqz	a0,ffffffffc0201514 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc02010a2:	4505                	li	a0,1
ffffffffc02010a4:	59f000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc02010a8:	44051663          	bnez	a0,ffffffffc02014f4 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc02010ac:	438a1463          	bne	s4,s8,ffffffffc02014d4 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02010b0:	4585                	li	a1,1
ffffffffc02010b2:	854e                	mv	a0,s3
ffffffffc02010b4:	617000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_pages(p1, 3);
ffffffffc02010b8:	458d                	li	a1,3
ffffffffc02010ba:	8552                	mv	a0,s4
ffffffffc02010bc:	60f000ef          	jal	ra,ffffffffc0201eca <free_pages>
ffffffffc02010c0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02010c4:	04098c13          	addi	s8,s3,64
ffffffffc02010c8:	8385                	srli	a5,a5,0x1
ffffffffc02010ca:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010cc:	3e078463          	beqz	a5,ffffffffc02014b4 <default_check+0x652>
ffffffffc02010d0:	0109a703          	lw	a4,16(s3)
ffffffffc02010d4:	4785                	li	a5,1
ffffffffc02010d6:	3cf71f63          	bne	a4,a5,ffffffffc02014b4 <default_check+0x652>
ffffffffc02010da:	008a3783          	ld	a5,8(s4)
ffffffffc02010de:	8385                	srli	a5,a5,0x1
ffffffffc02010e0:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010e2:	3a078963          	beqz	a5,ffffffffc0201494 <default_check+0x632>
ffffffffc02010e6:	010a2703          	lw	a4,16(s4)
ffffffffc02010ea:	478d                	li	a5,3
ffffffffc02010ec:	3af71463          	bne	a4,a5,ffffffffc0201494 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010f0:	4505                	li	a0,1
ffffffffc02010f2:	551000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc02010f6:	36a99f63          	bne	s3,a0,ffffffffc0201474 <default_check+0x612>
    free_page(p0);
ffffffffc02010fa:	4585                	li	a1,1
ffffffffc02010fc:	5cf000ef          	jal	ra,ffffffffc0201eca <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201100:	4509                	li	a0,2
ffffffffc0201102:	541000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0201106:	34aa1763          	bne	s4,a0,ffffffffc0201454 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc020110a:	4589                	li	a1,2
ffffffffc020110c:	5bf000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p2);
ffffffffc0201110:	4585                	li	a1,1
ffffffffc0201112:	8562                	mv	a0,s8
ffffffffc0201114:	5b7000ef          	jal	ra,ffffffffc0201eca <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201118:	4515                	li	a0,5
ffffffffc020111a:	529000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020111e:	89aa                	mv	s3,a0
ffffffffc0201120:	48050a63          	beqz	a0,ffffffffc02015b4 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0201124:	4505                	li	a0,1
ffffffffc0201126:	51d000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020112a:	2e051563          	bnez	a0,ffffffffc0201414 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc020112e:	01092783          	lw	a5,16(s2)
ffffffffc0201132:	2c079163          	bnez	a5,ffffffffc02013f4 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201136:	4595                	li	a1,5
ffffffffc0201138:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020113a:	000c8797          	auipc	a5,0xc8
ffffffffc020113e:	0d77a323          	sw	s7,198(a5) # ffffffffc02c9200 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0201142:	000c8797          	auipc	a5,0xc8
ffffffffc0201146:	0b67b723          	sd	s6,174(a5) # ffffffffc02c91f0 <free_area>
ffffffffc020114a:	000c8797          	auipc	a5,0xc8
ffffffffc020114e:	0b57b723          	sd	s5,174(a5) # ffffffffc02c91f8 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0201152:	579000ef          	jal	ra,ffffffffc0201eca <free_pages>
    return listelm->next;
ffffffffc0201156:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020115a:	01278963          	beq	a5,s2,ffffffffc020116c <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020115e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201162:	679c                	ld	a5,8(a5)
ffffffffc0201164:	34fd                	addiw	s1,s1,-1
ffffffffc0201166:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201168:	ff279be3          	bne	a5,s2,ffffffffc020115e <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc020116c:	26049463          	bnez	s1,ffffffffc02013d4 <default_check+0x572>
    assert(total == 0);
ffffffffc0201170:	46041263          	bnez	s0,ffffffffc02015d4 <default_check+0x772>
}
ffffffffc0201174:	60a6                	ld	ra,72(sp)
ffffffffc0201176:	6406                	ld	s0,64(sp)
ffffffffc0201178:	74e2                	ld	s1,56(sp)
ffffffffc020117a:	7942                	ld	s2,48(sp)
ffffffffc020117c:	79a2                	ld	s3,40(sp)
ffffffffc020117e:	7a02                	ld	s4,32(sp)
ffffffffc0201180:	6ae2                	ld	s5,24(sp)
ffffffffc0201182:	6b42                	ld	s6,16(sp)
ffffffffc0201184:	6ba2                	ld	s7,8(sp)
ffffffffc0201186:	6c02                	ld	s8,0(sp)
ffffffffc0201188:	6161                	addi	sp,sp,80
ffffffffc020118a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020118c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020118e:	4401                	li	s0,0
ffffffffc0201190:	4481                	li	s1,0
ffffffffc0201192:	b30d                	j	ffffffffc0200eb4 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0201194:	00009697          	auipc	a3,0x9
ffffffffc0201198:	93c68693          	addi	a3,a3,-1732 # ffffffffc0209ad0 <commands+0x878>
ffffffffc020119c:	00008617          	auipc	a2,0x8
ffffffffc02011a0:	57c60613          	addi	a2,a2,1404 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02011a4:	0ef00593          	li	a1,239
ffffffffc02011a8:	00009517          	auipc	a0,0x9
ffffffffc02011ac:	93850513          	addi	a0,a0,-1736 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02011b0:	ad8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011b4:	00009697          	auipc	a3,0x9
ffffffffc02011b8:	9c468693          	addi	a3,a3,-1596 # ffffffffc0209b78 <commands+0x920>
ffffffffc02011bc:	00008617          	auipc	a2,0x8
ffffffffc02011c0:	55c60613          	addi	a2,a2,1372 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02011c4:	0bc00593          	li	a1,188
ffffffffc02011c8:	00009517          	auipc	a0,0x9
ffffffffc02011cc:	91850513          	addi	a0,a0,-1768 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02011d0:	ab8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011d4:	00009697          	auipc	a3,0x9
ffffffffc02011d8:	9cc68693          	addi	a3,a3,-1588 # ffffffffc0209ba0 <commands+0x948>
ffffffffc02011dc:	00008617          	auipc	a2,0x8
ffffffffc02011e0:	53c60613          	addi	a2,a2,1340 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02011e4:	0bd00593          	li	a1,189
ffffffffc02011e8:	00009517          	auipc	a0,0x9
ffffffffc02011ec:	8f850513          	addi	a0,a0,-1800 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02011f0:	a98ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02011f4:	00009697          	auipc	a3,0x9
ffffffffc02011f8:	9ec68693          	addi	a3,a3,-1556 # ffffffffc0209be0 <commands+0x988>
ffffffffc02011fc:	00008617          	auipc	a2,0x8
ffffffffc0201200:	51c60613          	addi	a2,a2,1308 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201204:	0bf00593          	li	a1,191
ffffffffc0201208:	00009517          	auipc	a0,0x9
ffffffffc020120c:	8d850513          	addi	a0,a0,-1832 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201210:	a78ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201214:	00009697          	auipc	a3,0x9
ffffffffc0201218:	a5468693          	addi	a3,a3,-1452 # ffffffffc0209c68 <commands+0xa10>
ffffffffc020121c:	00008617          	auipc	a2,0x8
ffffffffc0201220:	4fc60613          	addi	a2,a2,1276 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201224:	0d800593          	li	a1,216
ffffffffc0201228:	00009517          	auipc	a0,0x9
ffffffffc020122c:	8b850513          	addi	a0,a0,-1864 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201230:	a58ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201234:	00009697          	auipc	a3,0x9
ffffffffc0201238:	8e468693          	addi	a3,a3,-1820 # ffffffffc0209b18 <commands+0x8c0>
ffffffffc020123c:	00008617          	auipc	a2,0x8
ffffffffc0201240:	4dc60613          	addi	a2,a2,1244 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201244:	0d100593          	li	a1,209
ffffffffc0201248:	00009517          	auipc	a0,0x9
ffffffffc020124c:	89850513          	addi	a0,a0,-1896 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201250:	a38ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 3);
ffffffffc0201254:	00009697          	auipc	a3,0x9
ffffffffc0201258:	a0468693          	addi	a3,a3,-1532 # ffffffffc0209c58 <commands+0xa00>
ffffffffc020125c:	00008617          	auipc	a2,0x8
ffffffffc0201260:	4bc60613          	addi	a2,a2,1212 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201264:	0cf00593          	li	a1,207
ffffffffc0201268:	00009517          	auipc	a0,0x9
ffffffffc020126c:	87850513          	addi	a0,a0,-1928 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201270:	a18ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201274:	00009697          	auipc	a3,0x9
ffffffffc0201278:	9cc68693          	addi	a3,a3,-1588 # ffffffffc0209c40 <commands+0x9e8>
ffffffffc020127c:	00008617          	auipc	a2,0x8
ffffffffc0201280:	49c60613          	addi	a2,a2,1180 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201284:	0ca00593          	li	a1,202
ffffffffc0201288:	00009517          	auipc	a0,0x9
ffffffffc020128c:	85850513          	addi	a0,a0,-1960 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201290:	9f8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201294:	00009697          	auipc	a3,0x9
ffffffffc0201298:	98c68693          	addi	a3,a3,-1652 # ffffffffc0209c20 <commands+0x9c8>
ffffffffc020129c:	00008617          	auipc	a2,0x8
ffffffffc02012a0:	47c60613          	addi	a2,a2,1148 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02012a4:	0c100593          	li	a1,193
ffffffffc02012a8:	00009517          	auipc	a0,0x9
ffffffffc02012ac:	83850513          	addi	a0,a0,-1992 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02012b0:	9d8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 != NULL);
ffffffffc02012b4:	00009697          	auipc	a3,0x9
ffffffffc02012b8:	9fc68693          	addi	a3,a3,-1540 # ffffffffc0209cb0 <commands+0xa58>
ffffffffc02012bc:	00008617          	auipc	a2,0x8
ffffffffc02012c0:	45c60613          	addi	a2,a2,1116 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02012c4:	0f700593          	li	a1,247
ffffffffc02012c8:	00009517          	auipc	a0,0x9
ffffffffc02012cc:	81850513          	addi	a0,a0,-2024 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02012d0:	9b8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 0);
ffffffffc02012d4:	00009697          	auipc	a3,0x9
ffffffffc02012d8:	9cc68693          	addi	a3,a3,-1588 # ffffffffc0209ca0 <commands+0xa48>
ffffffffc02012dc:	00008617          	auipc	a2,0x8
ffffffffc02012e0:	43c60613          	addi	a2,a2,1084 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02012e4:	0de00593          	li	a1,222
ffffffffc02012e8:	00008517          	auipc	a0,0x8
ffffffffc02012ec:	7f850513          	addi	a0,a0,2040 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02012f0:	998ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012f4:	00009697          	auipc	a3,0x9
ffffffffc02012f8:	94c68693          	addi	a3,a3,-1716 # ffffffffc0209c40 <commands+0x9e8>
ffffffffc02012fc:	00008617          	auipc	a2,0x8
ffffffffc0201300:	41c60613          	addi	a2,a2,1052 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201304:	0dc00593          	li	a1,220
ffffffffc0201308:	00008517          	auipc	a0,0x8
ffffffffc020130c:	7d850513          	addi	a0,a0,2008 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201310:	978ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201314:	00009697          	auipc	a3,0x9
ffffffffc0201318:	96c68693          	addi	a3,a3,-1684 # ffffffffc0209c80 <commands+0xa28>
ffffffffc020131c:	00008617          	auipc	a2,0x8
ffffffffc0201320:	3fc60613          	addi	a2,a2,1020 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201324:	0db00593          	li	a1,219
ffffffffc0201328:	00008517          	auipc	a0,0x8
ffffffffc020132c:	7b850513          	addi	a0,a0,1976 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201330:	958ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201334:	00008697          	auipc	a3,0x8
ffffffffc0201338:	7e468693          	addi	a3,a3,2020 # ffffffffc0209b18 <commands+0x8c0>
ffffffffc020133c:	00008617          	auipc	a2,0x8
ffffffffc0201340:	3dc60613          	addi	a2,a2,988 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201344:	0b800593          	li	a1,184
ffffffffc0201348:	00008517          	auipc	a0,0x8
ffffffffc020134c:	79850513          	addi	a0,a0,1944 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201350:	938ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201354:	00009697          	auipc	a3,0x9
ffffffffc0201358:	8ec68693          	addi	a3,a3,-1812 # ffffffffc0209c40 <commands+0x9e8>
ffffffffc020135c:	00008617          	auipc	a2,0x8
ffffffffc0201360:	3bc60613          	addi	a2,a2,956 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201364:	0d500593          	li	a1,213
ffffffffc0201368:	00008517          	auipc	a0,0x8
ffffffffc020136c:	77850513          	addi	a0,a0,1912 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201370:	918ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201374:	00008697          	auipc	a3,0x8
ffffffffc0201378:	7e468693          	addi	a3,a3,2020 # ffffffffc0209b58 <commands+0x900>
ffffffffc020137c:	00008617          	auipc	a2,0x8
ffffffffc0201380:	39c60613          	addi	a2,a2,924 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201384:	0d300593          	li	a1,211
ffffffffc0201388:	00008517          	auipc	a0,0x8
ffffffffc020138c:	75850513          	addi	a0,a0,1880 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201390:	8f8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201394:	00008697          	auipc	a3,0x8
ffffffffc0201398:	7a468693          	addi	a3,a3,1956 # ffffffffc0209b38 <commands+0x8e0>
ffffffffc020139c:	00008617          	auipc	a2,0x8
ffffffffc02013a0:	37c60613          	addi	a2,a2,892 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02013a4:	0d200593          	li	a1,210
ffffffffc02013a8:	00008517          	auipc	a0,0x8
ffffffffc02013ac:	73850513          	addi	a0,a0,1848 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02013b0:	8d8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013b4:	00008697          	auipc	a3,0x8
ffffffffc02013b8:	7a468693          	addi	a3,a3,1956 # ffffffffc0209b58 <commands+0x900>
ffffffffc02013bc:	00008617          	auipc	a2,0x8
ffffffffc02013c0:	35c60613          	addi	a2,a2,860 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02013c4:	0ba00593          	li	a1,186
ffffffffc02013c8:	00008517          	auipc	a0,0x8
ffffffffc02013cc:	71850513          	addi	a0,a0,1816 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02013d0:	8b8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(count == 0);
ffffffffc02013d4:	00009697          	auipc	a3,0x9
ffffffffc02013d8:	a2c68693          	addi	a3,a3,-1492 # ffffffffc0209e00 <commands+0xba8>
ffffffffc02013dc:	00008617          	auipc	a2,0x8
ffffffffc02013e0:	33c60613          	addi	a2,a2,828 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02013e4:	12400593          	li	a1,292
ffffffffc02013e8:	00008517          	auipc	a0,0x8
ffffffffc02013ec:	6f850513          	addi	a0,a0,1784 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02013f0:	898ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 0);
ffffffffc02013f4:	00009697          	auipc	a3,0x9
ffffffffc02013f8:	8ac68693          	addi	a3,a3,-1876 # ffffffffc0209ca0 <commands+0xa48>
ffffffffc02013fc:	00008617          	auipc	a2,0x8
ffffffffc0201400:	31c60613          	addi	a2,a2,796 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201404:	11900593          	li	a1,281
ffffffffc0201408:	00008517          	auipc	a0,0x8
ffffffffc020140c:	6d850513          	addi	a0,a0,1752 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201410:	878ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201414:	00009697          	auipc	a3,0x9
ffffffffc0201418:	82c68693          	addi	a3,a3,-2004 # ffffffffc0209c40 <commands+0x9e8>
ffffffffc020141c:	00008617          	auipc	a2,0x8
ffffffffc0201420:	2fc60613          	addi	a2,a2,764 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201424:	11700593          	li	a1,279
ffffffffc0201428:	00008517          	auipc	a0,0x8
ffffffffc020142c:	6b850513          	addi	a0,a0,1720 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201430:	858ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201434:	00008697          	auipc	a3,0x8
ffffffffc0201438:	7cc68693          	addi	a3,a3,1996 # ffffffffc0209c00 <commands+0x9a8>
ffffffffc020143c:	00008617          	auipc	a2,0x8
ffffffffc0201440:	2dc60613          	addi	a2,a2,732 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201444:	0c000593          	li	a1,192
ffffffffc0201448:	00008517          	auipc	a0,0x8
ffffffffc020144c:	69850513          	addi	a0,a0,1688 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201450:	838ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201454:	00009697          	auipc	a3,0x9
ffffffffc0201458:	96c68693          	addi	a3,a3,-1684 # ffffffffc0209dc0 <commands+0xb68>
ffffffffc020145c:	00008617          	auipc	a2,0x8
ffffffffc0201460:	2bc60613          	addi	a2,a2,700 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201464:	11100593          	li	a1,273
ffffffffc0201468:	00008517          	auipc	a0,0x8
ffffffffc020146c:	67850513          	addi	a0,a0,1656 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201470:	818ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201474:	00009697          	auipc	a3,0x9
ffffffffc0201478:	92c68693          	addi	a3,a3,-1748 # ffffffffc0209da0 <commands+0xb48>
ffffffffc020147c:	00008617          	auipc	a2,0x8
ffffffffc0201480:	29c60613          	addi	a2,a2,668 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201484:	10f00593          	li	a1,271
ffffffffc0201488:	00008517          	auipc	a0,0x8
ffffffffc020148c:	65850513          	addi	a0,a0,1624 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201490:	ff9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201494:	00009697          	auipc	a3,0x9
ffffffffc0201498:	8e468693          	addi	a3,a3,-1820 # ffffffffc0209d78 <commands+0xb20>
ffffffffc020149c:	00008617          	auipc	a2,0x8
ffffffffc02014a0:	27c60613          	addi	a2,a2,636 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02014a4:	10d00593          	li	a1,269
ffffffffc02014a8:	00008517          	auipc	a0,0x8
ffffffffc02014ac:	63850513          	addi	a0,a0,1592 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02014b0:	fd9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014b4:	00009697          	auipc	a3,0x9
ffffffffc02014b8:	89c68693          	addi	a3,a3,-1892 # ffffffffc0209d50 <commands+0xaf8>
ffffffffc02014bc:	00008617          	auipc	a2,0x8
ffffffffc02014c0:	25c60613          	addi	a2,a2,604 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02014c4:	10c00593          	li	a1,268
ffffffffc02014c8:	00008517          	auipc	a0,0x8
ffffffffc02014cc:	61850513          	addi	a0,a0,1560 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02014d0:	fb9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014d4:	00009697          	auipc	a3,0x9
ffffffffc02014d8:	86c68693          	addi	a3,a3,-1940 # ffffffffc0209d40 <commands+0xae8>
ffffffffc02014dc:	00008617          	auipc	a2,0x8
ffffffffc02014e0:	23c60613          	addi	a2,a2,572 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02014e4:	10700593          	li	a1,263
ffffffffc02014e8:	00008517          	auipc	a0,0x8
ffffffffc02014ec:	5f850513          	addi	a0,a0,1528 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02014f0:	f99fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014f4:	00008697          	auipc	a3,0x8
ffffffffc02014f8:	74c68693          	addi	a3,a3,1868 # ffffffffc0209c40 <commands+0x9e8>
ffffffffc02014fc:	00008617          	auipc	a2,0x8
ffffffffc0201500:	21c60613          	addi	a2,a2,540 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201504:	10600593          	li	a1,262
ffffffffc0201508:	00008517          	auipc	a0,0x8
ffffffffc020150c:	5d850513          	addi	a0,a0,1496 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201510:	f79fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201514:	00009697          	auipc	a3,0x9
ffffffffc0201518:	80c68693          	addi	a3,a3,-2036 # ffffffffc0209d20 <commands+0xac8>
ffffffffc020151c:	00008617          	auipc	a2,0x8
ffffffffc0201520:	1fc60613          	addi	a2,a2,508 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201524:	10500593          	li	a1,261
ffffffffc0201528:	00008517          	auipc	a0,0x8
ffffffffc020152c:	5b850513          	addi	a0,a0,1464 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201530:	f59fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201534:	00008697          	auipc	a3,0x8
ffffffffc0201538:	7bc68693          	addi	a3,a3,1980 # ffffffffc0209cf0 <commands+0xa98>
ffffffffc020153c:	00008617          	auipc	a2,0x8
ffffffffc0201540:	1dc60613          	addi	a2,a2,476 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201544:	10400593          	li	a1,260
ffffffffc0201548:	00008517          	auipc	a0,0x8
ffffffffc020154c:	59850513          	addi	a0,a0,1432 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201550:	f39fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201554:	00008697          	auipc	a3,0x8
ffffffffc0201558:	78468693          	addi	a3,a3,1924 # ffffffffc0209cd8 <commands+0xa80>
ffffffffc020155c:	00008617          	auipc	a2,0x8
ffffffffc0201560:	1bc60613          	addi	a2,a2,444 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201564:	10300593          	li	a1,259
ffffffffc0201568:	00008517          	auipc	a0,0x8
ffffffffc020156c:	57850513          	addi	a0,a0,1400 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201570:	f19fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201574:	00008697          	auipc	a3,0x8
ffffffffc0201578:	6cc68693          	addi	a3,a3,1740 # ffffffffc0209c40 <commands+0x9e8>
ffffffffc020157c:	00008617          	auipc	a2,0x8
ffffffffc0201580:	19c60613          	addi	a2,a2,412 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201584:	0fd00593          	li	a1,253
ffffffffc0201588:	00008517          	auipc	a0,0x8
ffffffffc020158c:	55850513          	addi	a0,a0,1368 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201590:	ef9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201594:	00008697          	auipc	a3,0x8
ffffffffc0201598:	72c68693          	addi	a3,a3,1836 # ffffffffc0209cc0 <commands+0xa68>
ffffffffc020159c:	00008617          	auipc	a2,0x8
ffffffffc02015a0:	17c60613          	addi	a2,a2,380 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02015a4:	0f800593          	li	a1,248
ffffffffc02015a8:	00008517          	auipc	a0,0x8
ffffffffc02015ac:	53850513          	addi	a0,a0,1336 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02015b0:	ed9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015b4:	00009697          	auipc	a3,0x9
ffffffffc02015b8:	82c68693          	addi	a3,a3,-2004 # ffffffffc0209de0 <commands+0xb88>
ffffffffc02015bc:	00008617          	auipc	a2,0x8
ffffffffc02015c0:	15c60613          	addi	a2,a2,348 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02015c4:	11600593          	li	a1,278
ffffffffc02015c8:	00008517          	auipc	a0,0x8
ffffffffc02015cc:	51850513          	addi	a0,a0,1304 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02015d0:	eb9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(total == 0);
ffffffffc02015d4:	00009697          	auipc	a3,0x9
ffffffffc02015d8:	83c68693          	addi	a3,a3,-1988 # ffffffffc0209e10 <commands+0xbb8>
ffffffffc02015dc:	00008617          	auipc	a2,0x8
ffffffffc02015e0:	13c60613          	addi	a2,a2,316 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02015e4:	12500593          	li	a1,293
ffffffffc02015e8:	00008517          	auipc	a0,0x8
ffffffffc02015ec:	4f850513          	addi	a0,a0,1272 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02015f0:	e99fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(total == nr_free_pages());
ffffffffc02015f4:	00008697          	auipc	a3,0x8
ffffffffc02015f8:	50468693          	addi	a3,a3,1284 # ffffffffc0209af8 <commands+0x8a0>
ffffffffc02015fc:	00008617          	auipc	a2,0x8
ffffffffc0201600:	11c60613          	addi	a2,a2,284 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201604:	0f200593          	li	a1,242
ffffffffc0201608:	00008517          	auipc	a0,0x8
ffffffffc020160c:	4d850513          	addi	a0,a0,1240 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201610:	e79fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201614:	00008697          	auipc	a3,0x8
ffffffffc0201618:	52468693          	addi	a3,a3,1316 # ffffffffc0209b38 <commands+0x8e0>
ffffffffc020161c:	00008617          	auipc	a2,0x8
ffffffffc0201620:	0fc60613          	addi	a2,a2,252 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201624:	0b900593          	li	a1,185
ffffffffc0201628:	00008517          	auipc	a0,0x8
ffffffffc020162c:	4b850513          	addi	a0,a0,1208 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201630:	e59fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201634 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201634:	1141                	addi	sp,sp,-16
ffffffffc0201636:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201638:	16058e63          	beqz	a1,ffffffffc02017b4 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc020163c:	00659693          	slli	a3,a1,0x6
ffffffffc0201640:	96aa                	add	a3,a3,a0
ffffffffc0201642:	02d50d63          	beq	a0,a3,ffffffffc020167c <default_free_pages+0x48>
ffffffffc0201646:	651c                	ld	a5,8(a0)
ffffffffc0201648:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020164a:	14079563          	bnez	a5,ffffffffc0201794 <default_free_pages+0x160>
ffffffffc020164e:	651c                	ld	a5,8(a0)
ffffffffc0201650:	8385                	srli	a5,a5,0x1
ffffffffc0201652:	8b85                	andi	a5,a5,1
ffffffffc0201654:	14079063          	bnez	a5,ffffffffc0201794 <default_free_pages+0x160>
ffffffffc0201658:	87aa                	mv	a5,a0
ffffffffc020165a:	a809                	j	ffffffffc020166c <default_free_pages+0x38>
ffffffffc020165c:	6798                	ld	a4,8(a5)
ffffffffc020165e:	8b05                	andi	a4,a4,1
ffffffffc0201660:	12071a63          	bnez	a4,ffffffffc0201794 <default_free_pages+0x160>
ffffffffc0201664:	6798                	ld	a4,8(a5)
ffffffffc0201666:	8b09                	andi	a4,a4,2
ffffffffc0201668:	12071663          	bnez	a4,ffffffffc0201794 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc020166c:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201670:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201674:	04078793          	addi	a5,a5,64
ffffffffc0201678:	fed792e3          	bne	a5,a3,ffffffffc020165c <default_free_pages+0x28>
    base->property = n;
ffffffffc020167c:	2581                	sext.w	a1,a1
ffffffffc020167e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201680:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201684:	4789                	li	a5,2
ffffffffc0201686:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020168a:	000c8697          	auipc	a3,0xc8
ffffffffc020168e:	b6668693          	addi	a3,a3,-1178 # ffffffffc02c91f0 <free_area>
ffffffffc0201692:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201694:	669c                	ld	a5,8(a3)
ffffffffc0201696:	9db9                	addw	a1,a1,a4
ffffffffc0201698:	000c8717          	auipc	a4,0xc8
ffffffffc020169c:	b6b72423          	sw	a1,-1176(a4) # ffffffffc02c9200 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02016a0:	0cd78163          	beq	a5,a3,ffffffffc0201762 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02016a4:	fe878713          	addi	a4,a5,-24
ffffffffc02016a8:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02016aa:	4801                	li	a6,0
ffffffffc02016ac:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016b0:	00e56a63          	bltu	a0,a4,ffffffffc02016c4 <default_free_pages+0x90>
    return listelm->next;
ffffffffc02016b4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016b6:	04d70f63          	beq	a4,a3,ffffffffc0201714 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016ba:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016bc:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016c0:	fee57ae3          	bleu	a4,a0,ffffffffc02016b4 <default_free_pages+0x80>
ffffffffc02016c4:	00080663          	beqz	a6,ffffffffc02016d0 <default_free_pages+0x9c>
ffffffffc02016c8:	000c8817          	auipc	a6,0xc8
ffffffffc02016cc:	b2b83423          	sd	a1,-1240(a6) # ffffffffc02c91f0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016d0:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02016d2:	e390                	sd	a2,0(a5)
ffffffffc02016d4:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02016d6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016d8:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02016da:	06d58a63          	beq	a1,a3,ffffffffc020174e <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02016de:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02016e2:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02016e6:	02061793          	slli	a5,a2,0x20
ffffffffc02016ea:	83e9                	srli	a5,a5,0x1a
ffffffffc02016ec:	97ba                	add	a5,a5,a4
ffffffffc02016ee:	04f51b63          	bne	a0,a5,ffffffffc0201744 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc02016f2:	491c                	lw	a5,16(a0)
ffffffffc02016f4:	9e3d                	addw	a2,a2,a5
ffffffffc02016f6:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02016fa:	57f5                	li	a5,-3
ffffffffc02016fc:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201700:	01853803          	ld	a6,24(a0)
ffffffffc0201704:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0201706:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201708:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc020170c:	659c                	ld	a5,8(a1)
ffffffffc020170e:	01063023          	sd	a6,0(a2)
ffffffffc0201712:	a815                	j	ffffffffc0201746 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201714:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201716:	f114                	sd	a3,32(a0)
ffffffffc0201718:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020171a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020171c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020171e:	00d70563          	beq	a4,a3,ffffffffc0201728 <default_free_pages+0xf4>
ffffffffc0201722:	4805                	li	a6,1
ffffffffc0201724:	87ba                	mv	a5,a4
ffffffffc0201726:	bf59                	j	ffffffffc02016bc <default_free_pages+0x88>
ffffffffc0201728:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020172a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020172c:	00d78d63          	beq	a5,a3,ffffffffc0201746 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201730:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201734:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201738:	02061793          	slli	a5,a2,0x20
ffffffffc020173c:	83e9                	srli	a5,a5,0x1a
ffffffffc020173e:	97ba                	add	a5,a5,a4
ffffffffc0201740:	faf509e3          	beq	a0,a5,ffffffffc02016f2 <default_free_pages+0xbe>
ffffffffc0201744:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201746:	fe878713          	addi	a4,a5,-24
ffffffffc020174a:	00d78963          	beq	a5,a3,ffffffffc020175c <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc020174e:	4910                	lw	a2,16(a0)
ffffffffc0201750:	02061693          	slli	a3,a2,0x20
ffffffffc0201754:	82e9                	srli	a3,a3,0x1a
ffffffffc0201756:	96aa                	add	a3,a3,a0
ffffffffc0201758:	00d70e63          	beq	a4,a3,ffffffffc0201774 <default_free_pages+0x140>
}
ffffffffc020175c:	60a2                	ld	ra,8(sp)
ffffffffc020175e:	0141                	addi	sp,sp,16
ffffffffc0201760:	8082                	ret
ffffffffc0201762:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201764:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201768:	e398                	sd	a4,0(a5)
ffffffffc020176a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020176c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020176e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201770:	0141                	addi	sp,sp,16
ffffffffc0201772:	8082                	ret
            base->property += p->property;
ffffffffc0201774:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201778:	ff078693          	addi	a3,a5,-16
ffffffffc020177c:	9e39                	addw	a2,a2,a4
ffffffffc020177e:	c910                	sw	a2,16(a0)
ffffffffc0201780:	5775                	li	a4,-3
ffffffffc0201782:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201786:	6398                	ld	a4,0(a5)
ffffffffc0201788:	679c                	ld	a5,8(a5)
}
ffffffffc020178a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020178c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020178e:	e398                	sd	a4,0(a5)
ffffffffc0201790:	0141                	addi	sp,sp,16
ffffffffc0201792:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201794:	00008697          	auipc	a3,0x8
ffffffffc0201798:	68c68693          	addi	a3,a3,1676 # ffffffffc0209e20 <commands+0xbc8>
ffffffffc020179c:	00008617          	auipc	a2,0x8
ffffffffc02017a0:	f7c60613          	addi	a2,a2,-132 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02017a4:	08200593          	li	a1,130
ffffffffc02017a8:	00008517          	auipc	a0,0x8
ffffffffc02017ac:	33850513          	addi	a0,a0,824 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02017b0:	cd9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(n > 0);
ffffffffc02017b4:	00008697          	auipc	a3,0x8
ffffffffc02017b8:	69468693          	addi	a3,a3,1684 # ffffffffc0209e48 <commands+0xbf0>
ffffffffc02017bc:	00008617          	auipc	a2,0x8
ffffffffc02017c0:	f5c60613          	addi	a2,a2,-164 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02017c4:	07f00593          	li	a1,127
ffffffffc02017c8:	00008517          	auipc	a0,0x8
ffffffffc02017cc:	31850513          	addi	a0,a0,792 # ffffffffc0209ae0 <commands+0x888>
ffffffffc02017d0:	cb9fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02017d4 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017d4:	c959                	beqz	a0,ffffffffc020186a <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017d6:	000c8597          	auipc	a1,0xc8
ffffffffc02017da:	a1a58593          	addi	a1,a1,-1510 # ffffffffc02c91f0 <free_area>
ffffffffc02017de:	0105a803          	lw	a6,16(a1)
ffffffffc02017e2:	862a                	mv	a2,a0
ffffffffc02017e4:	02081793          	slli	a5,a6,0x20
ffffffffc02017e8:	9381                	srli	a5,a5,0x20
ffffffffc02017ea:	00a7ee63          	bltu	a5,a0,ffffffffc0201806 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02017ee:	87ae                	mv	a5,a1
ffffffffc02017f0:	a801                	j	ffffffffc0201800 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02017f2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02017f6:	02071693          	slli	a3,a4,0x20
ffffffffc02017fa:	9281                	srli	a3,a3,0x20
ffffffffc02017fc:	00c6f763          	bleu	a2,a3,ffffffffc020180a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201800:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201802:	feb798e3          	bne	a5,a1,ffffffffc02017f2 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201806:	4501                	li	a0,0
}
ffffffffc0201808:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020180a:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc020180e:	dd6d                	beqz	a0,ffffffffc0201808 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201810:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201814:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201818:	00060e1b          	sext.w	t3,a2
ffffffffc020181c:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201820:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201824:	02d67863          	bleu	a3,a2,ffffffffc0201854 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201828:	061a                	slli	a2,a2,0x6
ffffffffc020182a:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc020182c:	41c7073b          	subw	a4,a4,t3
ffffffffc0201830:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201832:	00860693          	addi	a3,a2,8
ffffffffc0201836:	4709                	li	a4,2
ffffffffc0201838:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc020183c:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201840:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201844:	0105a803          	lw	a6,16(a1)
ffffffffc0201848:	e314                	sd	a3,0(a4)
ffffffffc020184a:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc020184e:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201850:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201854:	41c8083b          	subw	a6,a6,t3
ffffffffc0201858:	000c8717          	auipc	a4,0xc8
ffffffffc020185c:	9b072423          	sw	a6,-1624(a4) # ffffffffc02c9200 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201860:	5775                	li	a4,-3
ffffffffc0201862:	17c1                	addi	a5,a5,-16
ffffffffc0201864:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201868:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020186a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020186c:	00008697          	auipc	a3,0x8
ffffffffc0201870:	5dc68693          	addi	a3,a3,1500 # ffffffffc0209e48 <commands+0xbf0>
ffffffffc0201874:	00008617          	auipc	a2,0x8
ffffffffc0201878:	ea460613          	addi	a2,a2,-348 # ffffffffc0209718 <commands+0x4c0>
ffffffffc020187c:	06100593          	li	a1,97
ffffffffc0201880:	00008517          	auipc	a0,0x8
ffffffffc0201884:	26050513          	addi	a0,a0,608 # ffffffffc0209ae0 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201888:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020188a:	bfffe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020188e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020188e:	1141                	addi	sp,sp,-16
ffffffffc0201890:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201892:	c1ed                	beqz	a1,ffffffffc0201974 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0201894:	00659693          	slli	a3,a1,0x6
ffffffffc0201898:	96aa                	add	a3,a3,a0
ffffffffc020189a:	02d50463          	beq	a0,a3,ffffffffc02018c2 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020189e:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02018a0:	87aa                	mv	a5,a0
ffffffffc02018a2:	8b05                	andi	a4,a4,1
ffffffffc02018a4:	e709                	bnez	a4,ffffffffc02018ae <default_init_memmap+0x20>
ffffffffc02018a6:	a07d                	j	ffffffffc0201954 <default_init_memmap+0xc6>
ffffffffc02018a8:	6798                	ld	a4,8(a5)
ffffffffc02018aa:	8b05                	andi	a4,a4,1
ffffffffc02018ac:	c745                	beqz	a4,ffffffffc0201954 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02018ae:	0007a823          	sw	zero,16(a5)
ffffffffc02018b2:	0007b423          	sd	zero,8(a5)
ffffffffc02018b6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02018ba:	04078793          	addi	a5,a5,64
ffffffffc02018be:	fed795e3          	bne	a5,a3,ffffffffc02018a8 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02018c2:	2581                	sext.w	a1,a1
ffffffffc02018c4:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018c6:	4789                	li	a5,2
ffffffffc02018c8:	00850713          	addi	a4,a0,8
ffffffffc02018cc:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018d0:	000c8697          	auipc	a3,0xc8
ffffffffc02018d4:	92068693          	addi	a3,a3,-1760 # ffffffffc02c91f0 <free_area>
ffffffffc02018d8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018da:	669c                	ld	a5,8(a3)
ffffffffc02018dc:	9db9                	addw	a1,a1,a4
ffffffffc02018de:	000c8717          	auipc	a4,0xc8
ffffffffc02018e2:	92b72123          	sw	a1,-1758(a4) # ffffffffc02c9200 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02018e6:	04d78a63          	beq	a5,a3,ffffffffc020193a <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc02018ea:	fe878713          	addi	a4,a5,-24
ffffffffc02018ee:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02018f0:	4801                	li	a6,0
ffffffffc02018f2:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02018f6:	00e56a63          	bltu	a0,a4,ffffffffc020190a <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc02018fa:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02018fc:	02d70563          	beq	a4,a3,ffffffffc0201926 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201900:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201902:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201906:	fee57ae3          	bleu	a4,a0,ffffffffc02018fa <default_init_memmap+0x6c>
ffffffffc020190a:	00080663          	beqz	a6,ffffffffc0201916 <default_init_memmap+0x88>
ffffffffc020190e:	000c8717          	auipc	a4,0xc8
ffffffffc0201912:	8eb73123          	sd	a1,-1822(a4) # ffffffffc02c91f0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201916:	6398                	ld	a4,0(a5)
}
ffffffffc0201918:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020191a:	e390                	sd	a2,0(a5)
ffffffffc020191c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020191e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201920:	ed18                	sd	a4,24(a0)
ffffffffc0201922:	0141                	addi	sp,sp,16
ffffffffc0201924:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201926:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201928:	f114                	sd	a3,32(a0)
ffffffffc020192a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020192c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020192e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201930:	00d70e63          	beq	a4,a3,ffffffffc020194c <default_init_memmap+0xbe>
ffffffffc0201934:	4805                	li	a6,1
ffffffffc0201936:	87ba                	mv	a5,a4
ffffffffc0201938:	b7e9                	j	ffffffffc0201902 <default_init_memmap+0x74>
}
ffffffffc020193a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020193c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201940:	e398                	sd	a4,0(a5)
ffffffffc0201942:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201944:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201946:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201948:	0141                	addi	sp,sp,16
ffffffffc020194a:	8082                	ret
ffffffffc020194c:	60a2                	ld	ra,8(sp)
ffffffffc020194e:	e290                	sd	a2,0(a3)
ffffffffc0201950:	0141                	addi	sp,sp,16
ffffffffc0201952:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201954:	00008697          	auipc	a3,0x8
ffffffffc0201958:	4fc68693          	addi	a3,a3,1276 # ffffffffc0209e50 <commands+0xbf8>
ffffffffc020195c:	00008617          	auipc	a2,0x8
ffffffffc0201960:	dbc60613          	addi	a2,a2,-580 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201964:	04800593          	li	a1,72
ffffffffc0201968:	00008517          	auipc	a0,0x8
ffffffffc020196c:	17850513          	addi	a0,a0,376 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201970:	b19fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(n > 0);
ffffffffc0201974:	00008697          	auipc	a3,0x8
ffffffffc0201978:	4d468693          	addi	a3,a3,1236 # ffffffffc0209e48 <commands+0xbf0>
ffffffffc020197c:	00008617          	auipc	a2,0x8
ffffffffc0201980:	d9c60613          	addi	a2,a2,-612 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201984:	04500593          	li	a1,69
ffffffffc0201988:	00008517          	auipc	a0,0x8
ffffffffc020198c:	15850513          	addi	a0,a0,344 # ffffffffc0209ae0 <commands+0x888>
ffffffffc0201990:	af9fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201994 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201994:	c125                	beqz	a0,ffffffffc02019f4 <slob_free+0x60>
		return;

	if (size)
ffffffffc0201996:	e1a5                	bnez	a1,ffffffffc02019f6 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201998:	100027f3          	csrr	a5,sstatus
ffffffffc020199c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020199e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019a0:	e3bd                	bnez	a5,ffffffffc0201a06 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019a2:	000bc797          	auipc	a5,0xbc
ffffffffc02019a6:	3a678793          	addi	a5,a5,934 # ffffffffc02bdd48 <slobfree>
ffffffffc02019aa:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019ac:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019ae:	00a7fa63          	bleu	a0,a5,ffffffffc02019c2 <slob_free+0x2e>
ffffffffc02019b2:	00e56c63          	bltu	a0,a4,ffffffffc02019ca <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019b6:	00e7fa63          	bleu	a4,a5,ffffffffc02019ca <slob_free+0x36>
    return 0;
ffffffffc02019ba:	87ba                	mv	a5,a4
ffffffffc02019bc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019be:	fea7eae3          	bltu	a5,a0,ffffffffc02019b2 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019c2:	fee7ece3          	bltu	a5,a4,ffffffffc02019ba <slob_free+0x26>
ffffffffc02019c6:	fee57ae3          	bleu	a4,a0,ffffffffc02019ba <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02019ca:	4110                	lw	a2,0(a0)
ffffffffc02019cc:	00461693          	slli	a3,a2,0x4
ffffffffc02019d0:	96aa                	add	a3,a3,a0
ffffffffc02019d2:	08d70b63          	beq	a4,a3,ffffffffc0201a68 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02019d6:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02019d8:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02019da:	00469713          	slli	a4,a3,0x4
ffffffffc02019de:	973e                	add	a4,a4,a5
ffffffffc02019e0:	08e50f63          	beq	a0,a4,ffffffffc0201a7e <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02019e4:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02019e6:	000bc717          	auipc	a4,0xbc
ffffffffc02019ea:	36f73123          	sd	a5,866(a4) # ffffffffc02bdd48 <slobfree>
    if (flag) {
ffffffffc02019ee:	c199                	beqz	a1,ffffffffc02019f4 <slob_free+0x60>
        intr_enable();
ffffffffc02019f0:	c5dfe06f          	j	ffffffffc020064c <intr_enable>
ffffffffc02019f4:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02019f6:	05bd                	addi	a1,a1,15
ffffffffc02019f8:	8191                	srli	a1,a1,0x4
ffffffffc02019fa:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019fc:	100027f3          	csrr	a5,sstatus
ffffffffc0201a00:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a02:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a04:	dfd9                	beqz	a5,ffffffffc02019a2 <slob_free+0xe>
{
ffffffffc0201a06:	1101                	addi	sp,sp,-32
ffffffffc0201a08:	e42a                	sd	a0,8(sp)
ffffffffc0201a0a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201a0c:	c47fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a10:	000bc797          	auipc	a5,0xbc
ffffffffc0201a14:	33878793          	addi	a5,a5,824 # ffffffffc02bdd48 <slobfree>
ffffffffc0201a18:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201a1a:	6522                	ld	a0,8(sp)
ffffffffc0201a1c:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a1e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a20:	00a7fa63          	bleu	a0,a5,ffffffffc0201a34 <slob_free+0xa0>
ffffffffc0201a24:	00e56c63          	bltu	a0,a4,ffffffffc0201a3c <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a28:	00e7fa63          	bleu	a4,a5,ffffffffc0201a3c <slob_free+0xa8>
    return 0;
ffffffffc0201a2c:	87ba                	mv	a5,a4
ffffffffc0201a2e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a30:	fea7eae3          	bltu	a5,a0,ffffffffc0201a24 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a34:	fee7ece3          	bltu	a5,a4,ffffffffc0201a2c <slob_free+0x98>
ffffffffc0201a38:	fee57ae3          	bleu	a4,a0,ffffffffc0201a2c <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a3c:	4110                	lw	a2,0(a0)
ffffffffc0201a3e:	00461693          	slli	a3,a2,0x4
ffffffffc0201a42:	96aa                	add	a3,a3,a0
ffffffffc0201a44:	04d70763          	beq	a4,a3,ffffffffc0201a92 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a48:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a4a:	4394                	lw	a3,0(a5)
ffffffffc0201a4c:	00469713          	slli	a4,a3,0x4
ffffffffc0201a50:	973e                	add	a4,a4,a5
ffffffffc0201a52:	04e50663          	beq	a0,a4,ffffffffc0201a9e <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a56:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201a58:	000bc717          	auipc	a4,0xbc
ffffffffc0201a5c:	2ef73823          	sd	a5,752(a4) # ffffffffc02bdd48 <slobfree>
    if (flag) {
ffffffffc0201a60:	e58d                	bnez	a1,ffffffffc0201a8a <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a62:	60e2                	ld	ra,24(sp)
ffffffffc0201a64:	6105                	addi	sp,sp,32
ffffffffc0201a66:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201a68:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a6a:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a6c:	9e35                	addw	a2,a2,a3
ffffffffc0201a6e:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201a70:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a72:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a74:	00469713          	slli	a4,a3,0x4
ffffffffc0201a78:	973e                	add	a4,a4,a5
ffffffffc0201a7a:	f6e515e3          	bne	a0,a4,ffffffffc02019e4 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201a7e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a80:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a82:	9eb9                	addw	a3,a3,a4
ffffffffc0201a84:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a86:	e790                	sd	a2,8(a5)
ffffffffc0201a88:	bfb9                	j	ffffffffc02019e6 <slob_free+0x52>
}
ffffffffc0201a8a:	60e2                	ld	ra,24(sp)
ffffffffc0201a8c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201a8e:	bbffe06f          	j	ffffffffc020064c <intr_enable>
		b->units += cur->next->units;
ffffffffc0201a92:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a94:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a96:	9e35                	addw	a2,a2,a3
ffffffffc0201a98:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201a9a:	e518                	sd	a4,8(a0)
ffffffffc0201a9c:	b77d                	j	ffffffffc0201a4a <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201a9e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201aa0:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201aa2:	9eb9                	addw	a3,a3,a4
ffffffffc0201aa4:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201aa6:	e790                	sd	a2,8(a5)
ffffffffc0201aa8:	bf45                	j	ffffffffc0201a58 <slob_free+0xc4>

ffffffffc0201aaa <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aaa:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201aac:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aae:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ab2:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ab4:	38e000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
  if(!page)
ffffffffc0201ab8:	c139                	beqz	a0,ffffffffc0201afe <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201aba:	000c7797          	auipc	a5,0xc7
ffffffffc0201abe:	76678793          	addi	a5,a5,1894 # ffffffffc02c9220 <pages>
ffffffffc0201ac2:	6394                	ld	a3,0(a5)
ffffffffc0201ac4:	0000a797          	auipc	a5,0xa
ffffffffc0201ac8:	4dc78793          	addi	a5,a5,1244 # ffffffffc020bfa0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201acc:	000c7717          	auipc	a4,0xc7
ffffffffc0201ad0:	6d470713          	addi	a4,a4,1748 # ffffffffc02c91a0 <npage>
    return page - pages + nbase;
ffffffffc0201ad4:	40d506b3          	sub	a3,a0,a3
ffffffffc0201ad8:	6388                	ld	a0,0(a5)
ffffffffc0201ada:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201adc:	57fd                	li	a5,-1
ffffffffc0201ade:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201ae0:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201ae2:	83b1                	srli	a5,a5,0xc
ffffffffc0201ae4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ae6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201ae8:	00e7ff63          	bleu	a4,a5,ffffffffc0201b06 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201aec:	000c7797          	auipc	a5,0xc7
ffffffffc0201af0:	72478793          	addi	a5,a5,1828 # ffffffffc02c9210 <va_pa_offset>
ffffffffc0201af4:	6388                	ld	a0,0(a5)
}
ffffffffc0201af6:	60a2                	ld	ra,8(sp)
ffffffffc0201af8:	9536                	add	a0,a0,a3
ffffffffc0201afa:	0141                	addi	sp,sp,16
ffffffffc0201afc:	8082                	ret
ffffffffc0201afe:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201b00:	4501                	li	a0,0
}
ffffffffc0201b02:	0141                	addi	sp,sp,16
ffffffffc0201b04:	8082                	ret
ffffffffc0201b06:	00008617          	auipc	a2,0x8
ffffffffc0201b0a:	3aa60613          	addi	a2,a2,938 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0201b0e:	06900593          	li	a1,105
ffffffffc0201b12:	00008517          	auipc	a0,0x8
ffffffffc0201b16:	3c650513          	addi	a0,a0,966 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0201b1a:	96ffe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201b1e <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b1e:	7179                	addi	sp,sp,-48
ffffffffc0201b20:	f406                	sd	ra,40(sp)
ffffffffc0201b22:	f022                	sd	s0,32(sp)
ffffffffc0201b24:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201b26:	01050713          	addi	a4,a0,16
ffffffffc0201b2a:	6785                	lui	a5,0x1
ffffffffc0201b2c:	0cf77b63          	bleu	a5,a4,ffffffffc0201c02 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b30:	00f50413          	addi	s0,a0,15
ffffffffc0201b34:	8011                	srli	s0,s0,0x4
ffffffffc0201b36:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b38:	10002673          	csrr	a2,sstatus
ffffffffc0201b3c:	8a09                	andi	a2,a2,2
ffffffffc0201b3e:	ea5d                	bnez	a2,ffffffffc0201bf4 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201b40:	000bc497          	auipc	s1,0xbc
ffffffffc0201b44:	20848493          	addi	s1,s1,520 # ffffffffc02bdd48 <slobfree>
ffffffffc0201b48:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b4a:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b4c:	4398                	lw	a4,0(a5)
ffffffffc0201b4e:	0a875763          	ble	s0,a4,ffffffffc0201bfc <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201b52:	00f68a63          	beq	a3,a5,ffffffffc0201b66 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b56:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b58:	4118                	lw	a4,0(a0)
ffffffffc0201b5a:	02875763          	ble	s0,a4,ffffffffc0201b88 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201b5e:	6094                	ld	a3,0(s1)
ffffffffc0201b60:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201b62:	fef69ae3          	bne	a3,a5,ffffffffc0201b56 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201b66:	ea39                	bnez	a2,ffffffffc0201bbc <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b68:	4501                	li	a0,0
ffffffffc0201b6a:	f41ff0ef          	jal	ra,ffffffffc0201aaa <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201b6e:	cd29                	beqz	a0,ffffffffc0201bc8 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b70:	6585                	lui	a1,0x1
ffffffffc0201b72:	e23ff0ef          	jal	ra,ffffffffc0201994 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b76:	10002673          	csrr	a2,sstatus
ffffffffc0201b7a:	8a09                	andi	a2,a2,2
ffffffffc0201b7c:	ea1d                	bnez	a2,ffffffffc0201bb2 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201b7e:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b80:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b82:	4118                	lw	a4,0(a0)
ffffffffc0201b84:	fc874de3          	blt	a4,s0,ffffffffc0201b5e <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201b88:	04e40663          	beq	s0,a4,ffffffffc0201bd4 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201b8c:	00441693          	slli	a3,s0,0x4
ffffffffc0201b90:	96aa                	add	a3,a3,a0
ffffffffc0201b92:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201b94:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201b96:	9f01                	subw	a4,a4,s0
ffffffffc0201b98:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201b9a:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201b9c:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201b9e:	000bc717          	auipc	a4,0xbc
ffffffffc0201ba2:	1af73523          	sd	a5,426(a4) # ffffffffc02bdd48 <slobfree>
    if (flag) {
ffffffffc0201ba6:	ee15                	bnez	a2,ffffffffc0201be2 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201ba8:	70a2                	ld	ra,40(sp)
ffffffffc0201baa:	7402                	ld	s0,32(sp)
ffffffffc0201bac:	64e2                	ld	s1,24(sp)
ffffffffc0201bae:	6145                	addi	sp,sp,48
ffffffffc0201bb0:	8082                	ret
        intr_disable();
ffffffffc0201bb2:	aa1fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201bb6:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201bb8:	609c                	ld	a5,0(s1)
ffffffffc0201bba:	b7d9                	j	ffffffffc0201b80 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201bbc:	a91fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201bc0:	4501                	li	a0,0
ffffffffc0201bc2:	ee9ff0ef          	jal	ra,ffffffffc0201aaa <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201bc6:	f54d                	bnez	a0,ffffffffc0201b70 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201bc8:	70a2                	ld	ra,40(sp)
ffffffffc0201bca:	7402                	ld	s0,32(sp)
ffffffffc0201bcc:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201bce:	4501                	li	a0,0
}
ffffffffc0201bd0:	6145                	addi	sp,sp,48
ffffffffc0201bd2:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201bd4:	6518                	ld	a4,8(a0)
ffffffffc0201bd6:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201bd8:	000bc717          	auipc	a4,0xbc
ffffffffc0201bdc:	16f73823          	sd	a5,368(a4) # ffffffffc02bdd48 <slobfree>
    if (flag) {
ffffffffc0201be0:	d661                	beqz	a2,ffffffffc0201ba8 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201be2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201be4:	a69fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc0201be8:	70a2                	ld	ra,40(sp)
ffffffffc0201bea:	7402                	ld	s0,32(sp)
ffffffffc0201bec:	6522                	ld	a0,8(sp)
ffffffffc0201bee:	64e2                	ld	s1,24(sp)
ffffffffc0201bf0:	6145                	addi	sp,sp,48
ffffffffc0201bf2:	8082                	ret
        intr_disable();
ffffffffc0201bf4:	a5ffe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201bf8:	4605                	li	a2,1
ffffffffc0201bfa:	b799                	j	ffffffffc0201b40 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201bfc:	853e                	mv	a0,a5
ffffffffc0201bfe:	87b6                	mv	a5,a3
ffffffffc0201c00:	b761                	j	ffffffffc0201b88 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201c02:	00008697          	auipc	a3,0x8
ffffffffc0201c06:	34e68693          	addi	a3,a3,846 # ffffffffc0209f50 <default_pmm_manager+0xf0>
ffffffffc0201c0a:	00008617          	auipc	a2,0x8
ffffffffc0201c0e:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0201c12:	06400593          	li	a1,100
ffffffffc0201c16:	00008517          	auipc	a0,0x8
ffffffffc0201c1a:	35a50513          	addi	a0,a0,858 # ffffffffc0209f70 <default_pmm_manager+0x110>
ffffffffc0201c1e:	86bfe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201c22 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c22:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c24:	00008517          	auipc	a0,0x8
ffffffffc0201c28:	36450513          	addi	a0,a0,868 # ffffffffc0209f88 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c2c:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c2e:	d64fe0ef          	jal	ra,ffffffffc0200192 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c32:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c34:	00008517          	auipc	a0,0x8
ffffffffc0201c38:	2fc50513          	addi	a0,a0,764 # ffffffffc0209f30 <default_pmm_manager+0xd0>
}
ffffffffc0201c3c:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c3e:	d54fe06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0201c42 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c42:	4501                	li	a0,0
ffffffffc0201c44:	8082                	ret

ffffffffc0201c46 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c46:	1101                	addi	sp,sp,-32
ffffffffc0201c48:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c4a:	6905                	lui	s2,0x1
{
ffffffffc0201c4c:	e822                	sd	s0,16(sp)
ffffffffc0201c4e:	ec06                	sd	ra,24(sp)
ffffffffc0201c50:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c52:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8901>
{
ffffffffc0201c56:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c58:	04a7fc63          	bleu	a0,a5,ffffffffc0201cb0 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c5c:	4561                	li	a0,24
ffffffffc0201c5e:	ec1ff0ef          	jal	ra,ffffffffc0201b1e <slob_alloc.isra.1.constprop.3>
ffffffffc0201c62:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c64:	cd21                	beqz	a0,ffffffffc0201cbc <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201c66:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c6a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c6c:	00f95763          	ble	a5,s2,ffffffffc0201c7a <kmalloc+0x34>
ffffffffc0201c70:	6705                	lui	a4,0x1
ffffffffc0201c72:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c74:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c76:	fef74ee3          	blt	a4,a5,ffffffffc0201c72 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c7a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c7c:	e2fff0ef          	jal	ra,ffffffffc0201aaa <__slob_get_free_pages.isra.0>
ffffffffc0201c80:	e488                	sd	a0,8(s1)
ffffffffc0201c82:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201c84:	c935                	beqz	a0,ffffffffc0201cf8 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c86:	100027f3          	csrr	a5,sstatus
ffffffffc0201c8a:	8b89                	andi	a5,a5,2
ffffffffc0201c8c:	e3a1                	bnez	a5,ffffffffc0201ccc <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201c8e:	000c7797          	auipc	a5,0xc7
ffffffffc0201c92:	50278793          	addi	a5,a5,1282 # ffffffffc02c9190 <bigblocks>
ffffffffc0201c96:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201c98:	000c7717          	auipc	a4,0xc7
ffffffffc0201c9c:	4e973c23          	sd	s1,1272(a4) # ffffffffc02c9190 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201ca0:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201ca2:	8522                	mv	a0,s0
ffffffffc0201ca4:	60e2                	ld	ra,24(sp)
ffffffffc0201ca6:	6442                	ld	s0,16(sp)
ffffffffc0201ca8:	64a2                	ld	s1,8(sp)
ffffffffc0201caa:	6902                	ld	s2,0(sp)
ffffffffc0201cac:	6105                	addi	sp,sp,32
ffffffffc0201cae:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201cb0:	0541                	addi	a0,a0,16
ffffffffc0201cb2:	e6dff0ef          	jal	ra,ffffffffc0201b1e <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201cb6:	01050413          	addi	s0,a0,16
ffffffffc0201cba:	f565                	bnez	a0,ffffffffc0201ca2 <kmalloc+0x5c>
ffffffffc0201cbc:	4401                	li	s0,0
}
ffffffffc0201cbe:	8522                	mv	a0,s0
ffffffffc0201cc0:	60e2                	ld	ra,24(sp)
ffffffffc0201cc2:	6442                	ld	s0,16(sp)
ffffffffc0201cc4:	64a2                	ld	s1,8(sp)
ffffffffc0201cc6:	6902                	ld	s2,0(sp)
ffffffffc0201cc8:	6105                	addi	sp,sp,32
ffffffffc0201cca:	8082                	ret
        intr_disable();
ffffffffc0201ccc:	987fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201cd0:	000c7797          	auipc	a5,0xc7
ffffffffc0201cd4:	4c078793          	addi	a5,a5,1216 # ffffffffc02c9190 <bigblocks>
ffffffffc0201cd8:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cda:	000c7717          	auipc	a4,0xc7
ffffffffc0201cde:	4a973b23          	sd	s1,1206(a4) # ffffffffc02c9190 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201ce2:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201ce4:	969fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201ce8:	6480                	ld	s0,8(s1)
}
ffffffffc0201cea:	60e2                	ld	ra,24(sp)
ffffffffc0201cec:	64a2                	ld	s1,8(sp)
ffffffffc0201cee:	8522                	mv	a0,s0
ffffffffc0201cf0:	6442                	ld	s0,16(sp)
ffffffffc0201cf2:	6902                	ld	s2,0(sp)
ffffffffc0201cf4:	6105                	addi	sp,sp,32
ffffffffc0201cf6:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201cf8:	45e1                	li	a1,24
ffffffffc0201cfa:	8526                	mv	a0,s1
ffffffffc0201cfc:	c99ff0ef          	jal	ra,ffffffffc0201994 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201d00:	b74d                	j	ffffffffc0201ca2 <kmalloc+0x5c>

ffffffffc0201d02 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201d02:	c175                	beqz	a0,ffffffffc0201de6 <kfree+0xe4>
{
ffffffffc0201d04:	1101                	addi	sp,sp,-32
ffffffffc0201d06:	e426                	sd	s1,8(sp)
ffffffffc0201d08:	ec06                	sd	ra,24(sp)
ffffffffc0201d0a:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201d0c:	03451793          	slli	a5,a0,0x34
ffffffffc0201d10:	84aa                	mv	s1,a0
ffffffffc0201d12:	eb8d                	bnez	a5,ffffffffc0201d44 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d14:	100027f3          	csrr	a5,sstatus
ffffffffc0201d18:	8b89                	andi	a5,a5,2
ffffffffc0201d1a:	efc9                	bnez	a5,ffffffffc0201db4 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d1c:	000c7797          	auipc	a5,0xc7
ffffffffc0201d20:	47478793          	addi	a5,a5,1140 # ffffffffc02c9190 <bigblocks>
ffffffffc0201d24:	6394                	ld	a3,0(a5)
ffffffffc0201d26:	ce99                	beqz	a3,ffffffffc0201d44 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201d28:	669c                	ld	a5,8(a3)
ffffffffc0201d2a:	6a80                	ld	s0,16(a3)
ffffffffc0201d2c:	0af50e63          	beq	a0,a5,ffffffffc0201de8 <kfree+0xe6>
    return 0;
ffffffffc0201d30:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d32:	c801                	beqz	s0,ffffffffc0201d42 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201d34:	6418                	ld	a4,8(s0)
ffffffffc0201d36:	681c                	ld	a5,16(s0)
ffffffffc0201d38:	00970f63          	beq	a4,s1,ffffffffc0201d56 <kfree+0x54>
ffffffffc0201d3c:	86a2                	mv	a3,s0
ffffffffc0201d3e:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d40:	f875                	bnez	s0,ffffffffc0201d34 <kfree+0x32>
    if (flag) {
ffffffffc0201d42:	e659                	bnez	a2,ffffffffc0201dd0 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d44:	6442                	ld	s0,16(sp)
ffffffffc0201d46:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d48:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d4c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d4e:	4581                	li	a1,0
}
ffffffffc0201d50:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d52:	c43ff06f          	j	ffffffffc0201994 <slob_free>
				*last = bb->next;
ffffffffc0201d56:	ea9c                	sd	a5,16(a3)
ffffffffc0201d58:	e641                	bnez	a2,ffffffffc0201de0 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201d5a:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d5e:	4018                	lw	a4,0(s0)
ffffffffc0201d60:	08f4ea63          	bltu	s1,a5,ffffffffc0201df4 <kfree+0xf2>
ffffffffc0201d64:	000c7797          	auipc	a5,0xc7
ffffffffc0201d68:	4ac78793          	addi	a5,a5,1196 # ffffffffc02c9210 <va_pa_offset>
ffffffffc0201d6c:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d6e:	000c7797          	auipc	a5,0xc7
ffffffffc0201d72:	43278793          	addi	a5,a5,1074 # ffffffffc02c91a0 <npage>
ffffffffc0201d76:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d78:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d7a:	80b1                	srli	s1,s1,0xc
ffffffffc0201d7c:	08f4f963          	bleu	a5,s1,ffffffffc0201e0e <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d80:	0000a797          	auipc	a5,0xa
ffffffffc0201d84:	22078793          	addi	a5,a5,544 # ffffffffc020bfa0 <nbase>
ffffffffc0201d88:	639c                	ld	a5,0(a5)
ffffffffc0201d8a:	000c7697          	auipc	a3,0xc7
ffffffffc0201d8e:	49668693          	addi	a3,a3,1174 # ffffffffc02c9220 <pages>
ffffffffc0201d92:	6288                	ld	a0,0(a3)
ffffffffc0201d94:	8c9d                	sub	s1,s1,a5
ffffffffc0201d96:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201d98:	4585                	li	a1,1
ffffffffc0201d9a:	9526                	add	a0,a0,s1
ffffffffc0201d9c:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201da0:	12a000ef          	jal	ra,ffffffffc0201eca <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201da4:	8522                	mv	a0,s0
}
ffffffffc0201da6:	6442                	ld	s0,16(sp)
ffffffffc0201da8:	60e2                	ld	ra,24(sp)
ffffffffc0201daa:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dac:	45e1                	li	a1,24
}
ffffffffc0201dae:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201db0:	be5ff06f          	j	ffffffffc0201994 <slob_free>
        intr_disable();
ffffffffc0201db4:	89ffe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201db8:	000c7797          	auipc	a5,0xc7
ffffffffc0201dbc:	3d878793          	addi	a5,a5,984 # ffffffffc02c9190 <bigblocks>
ffffffffc0201dc0:	6394                	ld	a3,0(a5)
ffffffffc0201dc2:	c699                	beqz	a3,ffffffffc0201dd0 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201dc4:	669c                	ld	a5,8(a3)
ffffffffc0201dc6:	6a80                	ld	s0,16(a3)
ffffffffc0201dc8:	00f48763          	beq	s1,a5,ffffffffc0201dd6 <kfree+0xd4>
        return 1;
ffffffffc0201dcc:	4605                	li	a2,1
ffffffffc0201dce:	b795                	j	ffffffffc0201d32 <kfree+0x30>
        intr_enable();
ffffffffc0201dd0:	87dfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201dd4:	bf85                	j	ffffffffc0201d44 <kfree+0x42>
				*last = bb->next;
ffffffffc0201dd6:	000c7797          	auipc	a5,0xc7
ffffffffc0201dda:	3a87bd23          	sd	s0,954(a5) # ffffffffc02c9190 <bigblocks>
ffffffffc0201dde:	8436                	mv	s0,a3
ffffffffc0201de0:	86dfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201de4:	bf9d                	j	ffffffffc0201d5a <kfree+0x58>
ffffffffc0201de6:	8082                	ret
ffffffffc0201de8:	000c7797          	auipc	a5,0xc7
ffffffffc0201dec:	3a87b423          	sd	s0,936(a5) # ffffffffc02c9190 <bigblocks>
ffffffffc0201df0:	8436                	mv	s0,a3
ffffffffc0201df2:	b7a5                	j	ffffffffc0201d5a <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201df4:	86a6                	mv	a3,s1
ffffffffc0201df6:	00008617          	auipc	a2,0x8
ffffffffc0201dfa:	0f260613          	addi	a2,a2,242 # ffffffffc0209ee8 <default_pmm_manager+0x88>
ffffffffc0201dfe:	06e00593          	li	a1,110
ffffffffc0201e02:	00008517          	auipc	a0,0x8
ffffffffc0201e06:	0d650513          	addi	a0,a0,214 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0201e0a:	e7efe0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201e0e:	00008617          	auipc	a2,0x8
ffffffffc0201e12:	10260613          	addi	a2,a2,258 # ffffffffc0209f10 <default_pmm_manager+0xb0>
ffffffffc0201e16:	06200593          	li	a1,98
ffffffffc0201e1a:	00008517          	auipc	a0,0x8
ffffffffc0201e1e:	0be50513          	addi	a0,a0,190 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0201e22:	e66fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201e26 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e26:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e28:	00008617          	auipc	a2,0x8
ffffffffc0201e2c:	0e860613          	addi	a2,a2,232 # ffffffffc0209f10 <default_pmm_manager+0xb0>
ffffffffc0201e30:	06200593          	li	a1,98
ffffffffc0201e34:	00008517          	auipc	a0,0x8
ffffffffc0201e38:	0a450513          	addi	a0,a0,164 # ffffffffc0209ed8 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e3c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e3e:	e4afe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201e42 <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n)
{
ffffffffc0201e42:	715d                	addi	sp,sp,-80
ffffffffc0201e44:	e0a2                	sd	s0,64(sp)
ffffffffc0201e46:	fc26                	sd	s1,56(sp)
ffffffffc0201e48:	f84a                	sd	s2,48(sp)
ffffffffc0201e4a:	f44e                	sd	s3,40(sp)
ffffffffc0201e4c:	f052                	sd	s4,32(sp)
ffffffffc0201e4e:	ec56                	sd	s5,24(sp)
ffffffffc0201e50:	e486                	sd	ra,72(sp)
ffffffffc0201e52:	842a                	mv	s0,a0
ffffffffc0201e54:	000c7497          	auipc	s1,0xc7
ffffffffc0201e58:	3b448493          	addi	s1,s1,948 # ffffffffc02c9208 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0)
ffffffffc0201e5c:	4985                	li	s3,1
ffffffffc0201e5e:	000c7a17          	auipc	s4,0xc7
ffffffffc0201e62:	352a0a13          	addi	s4,s4,850 # ffffffffc02c91b0 <swap_init_ok>
            break;

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e66:	0005091b          	sext.w	s2,a0
ffffffffc0201e6a:	000c7a97          	auipc	s5,0xc7
ffffffffc0201e6e:	496a8a93          	addi	s5,s5,1174 # ffffffffc02c9300 <check_mm_struct>
ffffffffc0201e72:	a00d                	j	ffffffffc0201e94 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e74:	609c                	ld	a5,0(s1)
ffffffffc0201e76:	6f9c                	ld	a5,24(a5)
ffffffffc0201e78:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e7a:	4601                	li	a2,0
ffffffffc0201e7c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0)
ffffffffc0201e7e:	ed0d                	bnez	a0,ffffffffc0201eb8 <alloc_pages+0x76>
ffffffffc0201e80:	0289ec63          	bltu	s3,s0,ffffffffc0201eb8 <alloc_pages+0x76>
ffffffffc0201e84:	000a2783          	lw	a5,0(s4)
ffffffffc0201e88:	2781                	sext.w	a5,a5
ffffffffc0201e8a:	c79d                	beqz	a5,ffffffffc0201eb8 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e8c:	000ab503          	ld	a0,0(s5)
ffffffffc0201e90:	48d010ef          	jal	ra,ffffffffc0203b1c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e94:	100027f3          	csrr	a5,sstatus
ffffffffc0201e98:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e9a:	8522                	mv	a0,s0
ffffffffc0201e9c:	dfe1                	beqz	a5,ffffffffc0201e74 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201e9e:	fb4fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201ea2:	609c                	ld	a5,0(s1)
ffffffffc0201ea4:	8522                	mv	a0,s0
ffffffffc0201ea6:	6f9c                	ld	a5,24(a5)
ffffffffc0201ea8:	9782                	jalr	a5
ffffffffc0201eaa:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201eac:	fa0fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201eb0:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201eb2:	4601                	li	a2,0
ffffffffc0201eb4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0)
ffffffffc0201eb6:	d569                	beqz	a0,ffffffffc0201e80 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201eb8:	60a6                	ld	ra,72(sp)
ffffffffc0201eba:	6406                	ld	s0,64(sp)
ffffffffc0201ebc:	74e2                	ld	s1,56(sp)
ffffffffc0201ebe:	7942                	ld	s2,48(sp)
ffffffffc0201ec0:	79a2                	ld	s3,40(sp)
ffffffffc0201ec2:	7a02                	ld	s4,32(sp)
ffffffffc0201ec4:	6ae2                	ld	s5,24(sp)
ffffffffc0201ec6:	6161                	addi	sp,sp,80
ffffffffc0201ec8:	8082                	ret

ffffffffc0201eca <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201eca:	100027f3          	csrr	a5,sstatus
ffffffffc0201ece:	8b89                	andi	a5,a5,2
ffffffffc0201ed0:	eb89                	bnez	a5,ffffffffc0201ee2 <free_pages+0x18>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201ed2:	000c7797          	auipc	a5,0xc7
ffffffffc0201ed6:	33678793          	addi	a5,a5,822 # ffffffffc02c9208 <pmm_manager>
ffffffffc0201eda:	639c                	ld	a5,0(a5)
ffffffffc0201edc:	0207b303          	ld	t1,32(a5)
ffffffffc0201ee0:	8302                	jr	t1
{
ffffffffc0201ee2:	1101                	addi	sp,sp,-32
ffffffffc0201ee4:	ec06                	sd	ra,24(sp)
ffffffffc0201ee6:	e822                	sd	s0,16(sp)
ffffffffc0201ee8:	e426                	sd	s1,8(sp)
ffffffffc0201eea:	842a                	mv	s0,a0
ffffffffc0201eec:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201eee:	f64fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201ef2:	000c7797          	auipc	a5,0xc7
ffffffffc0201ef6:	31678793          	addi	a5,a5,790 # ffffffffc02c9208 <pmm_manager>
ffffffffc0201efa:	639c                	ld	a5,0(a5)
ffffffffc0201efc:	85a6                	mv	a1,s1
ffffffffc0201efe:	8522                	mv	a0,s0
ffffffffc0201f00:	739c                	ld	a5,32(a5)
ffffffffc0201f02:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f04:	6442                	ld	s0,16(sp)
ffffffffc0201f06:	60e2                	ld	ra,24(sp)
ffffffffc0201f08:	64a2                	ld	s1,8(sp)
ffffffffc0201f0a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f0c:	f40fe06f          	j	ffffffffc020064c <intr_enable>

ffffffffc0201f10 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f10:	100027f3          	csrr	a5,sstatus
ffffffffc0201f14:	8b89                	andi	a5,a5,2
ffffffffc0201f16:	eb89                	bnez	a5,ffffffffc0201f28 <nr_free_pages+0x18>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f18:	000c7797          	auipc	a5,0xc7
ffffffffc0201f1c:	2f078793          	addi	a5,a5,752 # ffffffffc02c9208 <pmm_manager>
ffffffffc0201f20:	639c                	ld	a5,0(a5)
ffffffffc0201f22:	0287b303          	ld	t1,40(a5)
ffffffffc0201f26:	8302                	jr	t1
{
ffffffffc0201f28:	1141                	addi	sp,sp,-16
ffffffffc0201f2a:	e406                	sd	ra,8(sp)
ffffffffc0201f2c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f2e:	f24fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f32:	000c7797          	auipc	a5,0xc7
ffffffffc0201f36:	2d678793          	addi	a5,a5,726 # ffffffffc02c9208 <pmm_manager>
ffffffffc0201f3a:	639c                	ld	a5,0(a5)
ffffffffc0201f3c:	779c                	ld	a5,40(a5)
ffffffffc0201f3e:	9782                	jalr	a5
ffffffffc0201f40:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f42:	f0afe0ef          	jal	ra,ffffffffc020064c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f46:	8522                	mv	a0,s0
ffffffffc0201f48:	60a2                	ld	ra,8(sp)
ffffffffc0201f4a:	6402                	ld	s0,0(sp)
ffffffffc0201f4c:	0141                	addi	sp,sp,16
ffffffffc0201f4e:	8082                	ret

ffffffffc0201f50 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
ffffffffc0201f50:	7139                	addi	sp,sp,-64
ffffffffc0201f52:	f426                	sd	s1,40(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f54:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201f58:	1ff4f493          	andi	s1,s1,511
ffffffffc0201f5c:	048e                	slli	s1,s1,0x3
ffffffffc0201f5e:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V))
ffffffffc0201f60:	6094                	ld	a3,0(s1)
{
ffffffffc0201f62:	f04a                	sd	s2,32(sp)
ffffffffc0201f64:	ec4e                	sd	s3,24(sp)
ffffffffc0201f66:	e852                	sd	s4,16(sp)
ffffffffc0201f68:	fc06                	sd	ra,56(sp)
ffffffffc0201f6a:	f822                	sd	s0,48(sp)
ffffffffc0201f6c:	e456                	sd	s5,8(sp)
ffffffffc0201f6e:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201f70:	0016f793          	andi	a5,a3,1
{
ffffffffc0201f74:	892e                	mv	s2,a1
ffffffffc0201f76:	8a32                	mv	s4,a2
ffffffffc0201f78:	000c7997          	auipc	s3,0xc7
ffffffffc0201f7c:	22898993          	addi	s3,s3,552 # ffffffffc02c91a0 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201f80:	e7bd                	bnez	a5,ffffffffc0201fee <get_pte+0x9e>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201f82:	12060c63          	beqz	a2,ffffffffc02020ba <get_pte+0x16a>
ffffffffc0201f86:	4505                	li	a0,1
ffffffffc0201f88:	ebbff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0201f8c:	842a                	mv	s0,a0
ffffffffc0201f8e:	12050663          	beqz	a0,ffffffffc02020ba <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201f92:	000c7b17          	auipc	s6,0xc7
ffffffffc0201f96:	28eb0b13          	addi	s6,s6,654 # ffffffffc02c9220 <pages>
ffffffffc0201f9a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201f9e:	4785                	li	a5,1
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fa0:	000c7997          	auipc	s3,0xc7
ffffffffc0201fa4:	20098993          	addi	s3,s3,512 # ffffffffc02c91a0 <npage>
    return page - pages + nbase;
ffffffffc0201fa8:	40a40533          	sub	a0,s0,a0
ffffffffc0201fac:	00080ab7          	lui	s5,0x80
ffffffffc0201fb0:	8519                	srai	a0,a0,0x6
ffffffffc0201fb2:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201fb6:	c01c                	sw	a5,0(s0)
ffffffffc0201fb8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201fba:	9556                	add	a0,a0,s5
ffffffffc0201fbc:	83b1                	srli	a5,a5,0xc
ffffffffc0201fbe:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fc0:	0532                	slli	a0,a0,0xc
ffffffffc0201fc2:	14e7f363          	bleu	a4,a5,ffffffffc0202108 <get_pte+0x1b8>
ffffffffc0201fc6:	000c7797          	auipc	a5,0xc7
ffffffffc0201fca:	24a78793          	addi	a5,a5,586 # ffffffffc02c9210 <va_pa_offset>
ffffffffc0201fce:	639c                	ld	a5,0(a5)
ffffffffc0201fd0:	6605                	lui	a2,0x1
ffffffffc0201fd2:	4581                	li	a1,0
ffffffffc0201fd4:	953e                	add	a0,a0,a5
ffffffffc0201fd6:	122070ef          	jal	ra,ffffffffc02090f8 <memset>
    return page - pages + nbase;
ffffffffc0201fda:	000b3683          	ld	a3,0(s6)
ffffffffc0201fde:	40d406b3          	sub	a3,s0,a3
ffffffffc0201fe2:	8699                	srai	a3,a3,0x6
ffffffffc0201fe4:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fe6:	06aa                	slli	a3,a3,0xa
ffffffffc0201fe8:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201fec:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201fee:	77fd                	lui	a5,0xfffff
ffffffffc0201ff0:	068a                	slli	a3,a3,0x2
ffffffffc0201ff2:	0009b703          	ld	a4,0(s3)
ffffffffc0201ff6:	8efd                	and	a3,a3,a5
ffffffffc0201ff8:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201ffc:	0ce7f163          	bleu	a4,a5,ffffffffc02020be <get_pte+0x16e>
ffffffffc0202000:	000c7a97          	auipc	s5,0xc7
ffffffffc0202004:	210a8a93          	addi	s5,s5,528 # ffffffffc02c9210 <va_pa_offset>
ffffffffc0202008:	000ab403          	ld	s0,0(s5)
ffffffffc020200c:	01595793          	srli	a5,s2,0x15
ffffffffc0202010:	1ff7f793          	andi	a5,a5,511
ffffffffc0202014:	96a2                	add	a3,a3,s0
ffffffffc0202016:	00379413          	slli	s0,a5,0x3
ffffffffc020201a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc020201c:	6014                	ld	a3,0(s0)
ffffffffc020201e:	0016f793          	andi	a5,a3,1
ffffffffc0202022:	e3ad                	bnez	a5,ffffffffc0202084 <get_pte+0x134>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202024:	080a0b63          	beqz	s4,ffffffffc02020ba <get_pte+0x16a>
ffffffffc0202028:	4505                	li	a0,1
ffffffffc020202a:	e19ff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020202e:	84aa                	mv	s1,a0
ffffffffc0202030:	c549                	beqz	a0,ffffffffc02020ba <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0202032:	000c7b17          	auipc	s6,0xc7
ffffffffc0202036:	1eeb0b13          	addi	s6,s6,494 # ffffffffc02c9220 <pages>
ffffffffc020203a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc020203e:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0202040:	00080a37          	lui	s4,0x80
ffffffffc0202044:	40a48533          	sub	a0,s1,a0
ffffffffc0202048:	8519                	srai	a0,a0,0x6
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020204a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020204e:	c09c                	sw	a5,0(s1)
ffffffffc0202050:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0202052:	9552                	add	a0,a0,s4
ffffffffc0202054:	83b1                	srli	a5,a5,0xc
ffffffffc0202056:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202058:	0532                	slli	a0,a0,0xc
ffffffffc020205a:	08e7fa63          	bleu	a4,a5,ffffffffc02020ee <get_pte+0x19e>
ffffffffc020205e:	000ab783          	ld	a5,0(s5)
ffffffffc0202062:	6605                	lui	a2,0x1
ffffffffc0202064:	4581                	li	a1,0
ffffffffc0202066:	953e                	add	a0,a0,a5
ffffffffc0202068:	090070ef          	jal	ra,ffffffffc02090f8 <memset>
    return page - pages + nbase;
ffffffffc020206c:	000b3683          	ld	a3,0(s6)
ffffffffc0202070:	40d486b3          	sub	a3,s1,a3
ffffffffc0202074:	8699                	srai	a3,a3,0x6
ffffffffc0202076:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202078:	06aa                	slli	a3,a3,0xa
ffffffffc020207a:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020207e:	e014                	sd	a3,0(s0)
ffffffffc0202080:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202084:	068a                	slli	a3,a3,0x2
ffffffffc0202086:	757d                	lui	a0,0xfffff
ffffffffc0202088:	8ee9                	and	a3,a3,a0
ffffffffc020208a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020208e:	04e7f463          	bleu	a4,a5,ffffffffc02020d6 <get_pte+0x186>
ffffffffc0202092:	000ab503          	ld	a0,0(s5)
ffffffffc0202096:	00c95793          	srli	a5,s2,0xc
ffffffffc020209a:	1ff7f793          	andi	a5,a5,511
ffffffffc020209e:	96aa                	add	a3,a3,a0
ffffffffc02020a0:	00379513          	slli	a0,a5,0x3
ffffffffc02020a4:	9536                	add	a0,a0,a3
}
ffffffffc02020a6:	70e2                	ld	ra,56(sp)
ffffffffc02020a8:	7442                	ld	s0,48(sp)
ffffffffc02020aa:	74a2                	ld	s1,40(sp)
ffffffffc02020ac:	7902                	ld	s2,32(sp)
ffffffffc02020ae:	69e2                	ld	s3,24(sp)
ffffffffc02020b0:	6a42                	ld	s4,16(sp)
ffffffffc02020b2:	6aa2                	ld	s5,8(sp)
ffffffffc02020b4:	6b02                	ld	s6,0(sp)
ffffffffc02020b6:	6121                	addi	sp,sp,64
ffffffffc02020b8:	8082                	ret
            return NULL;
ffffffffc02020ba:	4501                	li	a0,0
ffffffffc02020bc:	b7ed                	j	ffffffffc02020a6 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020be:	00008617          	auipc	a2,0x8
ffffffffc02020c2:	df260613          	addi	a2,a2,-526 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc02020c6:	10f00593          	li	a1,271
ffffffffc02020ca:	00008517          	auipc	a0,0x8
ffffffffc02020ce:	f0650513          	addi	a0,a0,-250 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc02020d2:	bb6fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020d6:	00008617          	auipc	a2,0x8
ffffffffc02020da:	dda60613          	addi	a2,a2,-550 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc02020de:	11c00593          	li	a1,284
ffffffffc02020e2:	00008517          	auipc	a0,0x8
ffffffffc02020e6:	eee50513          	addi	a0,a0,-274 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc02020ea:	b9efe0ef          	jal	ra,ffffffffc0200488 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020ee:	86aa                	mv	a3,a0
ffffffffc02020f0:	00008617          	auipc	a2,0x8
ffffffffc02020f4:	dc060613          	addi	a2,a2,-576 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc02020f8:	11900593          	li	a1,281
ffffffffc02020fc:	00008517          	auipc	a0,0x8
ffffffffc0202100:	ed450513          	addi	a0,a0,-300 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202104:	b84fe0ef          	jal	ra,ffffffffc0200488 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202108:	86aa                	mv	a3,a0
ffffffffc020210a:	00008617          	auipc	a2,0x8
ffffffffc020210e:	da660613          	addi	a2,a2,-602 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0202112:	10b00593          	li	a1,267
ffffffffc0202116:	00008517          	auipc	a0,0x8
ffffffffc020211a:	eba50513          	addi	a0,a0,-326 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc020211e:	b6afe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0202122 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0202122:	1141                	addi	sp,sp,-16
ffffffffc0202124:	e022                	sd	s0,0(sp)
ffffffffc0202126:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202128:	4601                	li	a2,0
{
ffffffffc020212a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020212c:	e25ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
    if (ptep_store != NULL)
ffffffffc0202130:	c011                	beqz	s0,ffffffffc0202134 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202132:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202134:	c129                	beqz	a0,ffffffffc0202176 <get_page+0x54>
ffffffffc0202136:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202138:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020213a:	0017f713          	andi	a4,a5,1
ffffffffc020213e:	e709                	bnez	a4,ffffffffc0202148 <get_page+0x26>
}
ffffffffc0202140:	60a2                	ld	ra,8(sp)
ffffffffc0202142:	6402                	ld	s0,0(sp)
ffffffffc0202144:	0141                	addi	sp,sp,16
ffffffffc0202146:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202148:	000c7717          	auipc	a4,0xc7
ffffffffc020214c:	05870713          	addi	a4,a4,88 # ffffffffc02c91a0 <npage>
ffffffffc0202150:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202152:	078a                	slli	a5,a5,0x2
ffffffffc0202154:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202156:	02e7f563          	bleu	a4,a5,ffffffffc0202180 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020215a:	000c7717          	auipc	a4,0xc7
ffffffffc020215e:	0c670713          	addi	a4,a4,198 # ffffffffc02c9220 <pages>
ffffffffc0202162:	6308                	ld	a0,0(a4)
ffffffffc0202164:	60a2                	ld	ra,8(sp)
ffffffffc0202166:	6402                	ld	s0,0(sp)
ffffffffc0202168:	fff80737          	lui	a4,0xfff80
ffffffffc020216c:	97ba                	add	a5,a5,a4
ffffffffc020216e:	079a                	slli	a5,a5,0x6
ffffffffc0202170:	953e                	add	a0,a0,a5
ffffffffc0202172:	0141                	addi	sp,sp,16
ffffffffc0202174:	8082                	ret
ffffffffc0202176:	60a2                	ld	ra,8(sp)
ffffffffc0202178:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020217a:	4501                	li	a0,0
}
ffffffffc020217c:	0141                	addi	sp,sp,16
ffffffffc020217e:	8082                	ret
ffffffffc0202180:	ca7ff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>

ffffffffc0202184 <unmap_range>:
        tlb_invalidate(pgdir, la); //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0202184:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202186:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc020218a:	ec86                	sd	ra,88(sp)
ffffffffc020218c:	e8a2                	sd	s0,80(sp)
ffffffffc020218e:	e4a6                	sd	s1,72(sp)
ffffffffc0202190:	e0ca                	sd	s2,64(sp)
ffffffffc0202192:	fc4e                	sd	s3,56(sp)
ffffffffc0202194:	f852                	sd	s4,48(sp)
ffffffffc0202196:	f456                	sd	s5,40(sp)
ffffffffc0202198:	f05a                	sd	s6,32(sp)
ffffffffc020219a:	ec5e                	sd	s7,24(sp)
ffffffffc020219c:	e862                	sd	s8,16(sp)
ffffffffc020219e:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021a0:	03479713          	slli	a4,a5,0x34
ffffffffc02021a4:	eb71                	bnez	a4,ffffffffc0202278 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02021a6:	002007b7          	lui	a5,0x200
ffffffffc02021aa:	842e                	mv	s0,a1
ffffffffc02021ac:	0af5e663          	bltu	a1,a5,ffffffffc0202258 <unmap_range+0xd4>
ffffffffc02021b0:	8932                	mv	s2,a2
ffffffffc02021b2:	0ac5f363          	bleu	a2,a1,ffffffffc0202258 <unmap_range+0xd4>
ffffffffc02021b6:	4785                	li	a5,1
ffffffffc02021b8:	07fe                	slli	a5,a5,0x1f
ffffffffc02021ba:	08c7ef63          	bltu	a5,a2,ffffffffc0202258 <unmap_range+0xd4>
ffffffffc02021be:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02021c0:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02021c2:	000c7c97          	auipc	s9,0xc7
ffffffffc02021c6:	fdec8c93          	addi	s9,s9,-34 # ffffffffc02c91a0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021ca:	000c7c17          	auipc	s8,0xc7
ffffffffc02021ce:	056c0c13          	addi	s8,s8,86 # ffffffffc02c9220 <pages>
ffffffffc02021d2:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021d6:	00200b37          	lui	s6,0x200
ffffffffc02021da:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02021de:	4601                	li	a2,0
ffffffffc02021e0:	85a2                	mv	a1,s0
ffffffffc02021e2:	854e                	mv	a0,s3
ffffffffc02021e4:	d6dff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02021e8:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc02021ea:	cd21                	beqz	a0,ffffffffc0202242 <unmap_range+0xbe>
        if (*ptep != 0)
ffffffffc02021ec:	611c                	ld	a5,0(a0)
ffffffffc02021ee:	e38d                	bnez	a5,ffffffffc0202210 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02021f0:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02021f2:	ff2466e3          	bltu	s0,s2,ffffffffc02021de <unmap_range+0x5a>
}
ffffffffc02021f6:	60e6                	ld	ra,88(sp)
ffffffffc02021f8:	6446                	ld	s0,80(sp)
ffffffffc02021fa:	64a6                	ld	s1,72(sp)
ffffffffc02021fc:	6906                	ld	s2,64(sp)
ffffffffc02021fe:	79e2                	ld	s3,56(sp)
ffffffffc0202200:	7a42                	ld	s4,48(sp)
ffffffffc0202202:	7aa2                	ld	s5,40(sp)
ffffffffc0202204:	7b02                	ld	s6,32(sp)
ffffffffc0202206:	6be2                	ld	s7,24(sp)
ffffffffc0202208:	6c42                	ld	s8,16(sp)
ffffffffc020220a:	6ca2                	ld	s9,8(sp)
ffffffffc020220c:	6125                	addi	sp,sp,96
ffffffffc020220e:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0202210:	0017f713          	andi	a4,a5,1
ffffffffc0202214:	df71                	beqz	a4,ffffffffc02021f0 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0202216:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020221a:	078a                	slli	a5,a5,0x2
ffffffffc020221c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020221e:	06e7fd63          	bleu	a4,a5,ffffffffc0202298 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0202222:	000c3503          	ld	a0,0(s8)
ffffffffc0202226:	97de                	add	a5,a5,s7
ffffffffc0202228:	079a                	slli	a5,a5,0x6
ffffffffc020222a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020222c:	411c                	lw	a5,0(a0)
ffffffffc020222e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202232:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202234:	cf11                	beqz	a4,ffffffffc0202250 <unmap_range+0xcc>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202236:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020223a:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020223e:	9452                	add	s0,s0,s4
ffffffffc0202240:	bf4d                	j	ffffffffc02021f2 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202242:	945a                	add	s0,s0,s6
ffffffffc0202244:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202248:	d45d                	beqz	s0,ffffffffc02021f6 <unmap_range+0x72>
ffffffffc020224a:	f9246ae3          	bltu	s0,s2,ffffffffc02021de <unmap_range+0x5a>
ffffffffc020224e:	b765                	j	ffffffffc02021f6 <unmap_range+0x72>
            free_page(page);
ffffffffc0202250:	4585                	li	a1,1
ffffffffc0202252:	c79ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
ffffffffc0202256:	b7c5                	j	ffffffffc0202236 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0202258:	00008697          	auipc	a3,0x8
ffffffffc020225c:	32868693          	addi	a3,a3,808 # ffffffffc020a580 <default_pmm_manager+0x720>
ffffffffc0202260:	00007617          	auipc	a2,0x7
ffffffffc0202264:	4b860613          	addi	a2,a2,1208 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202268:	15b00593          	li	a1,347
ffffffffc020226c:	00008517          	auipc	a0,0x8
ffffffffc0202270:	d6450513          	addi	a0,a0,-668 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202274:	a14fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202278:	00008697          	auipc	a3,0x8
ffffffffc020227c:	2d868693          	addi	a3,a3,728 # ffffffffc020a550 <default_pmm_manager+0x6f0>
ffffffffc0202280:	00007617          	auipc	a2,0x7
ffffffffc0202284:	49860613          	addi	a2,a2,1176 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202288:	15a00593          	li	a1,346
ffffffffc020228c:	00008517          	auipc	a0,0x8
ffffffffc0202290:	d4450513          	addi	a0,a0,-700 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202294:	9f4fe0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202298:	b8fff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>

ffffffffc020229c <exit_range>:
{
ffffffffc020229c:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020229e:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc02022a2:	fc86                	sd	ra,120(sp)
ffffffffc02022a4:	f8a2                	sd	s0,112(sp)
ffffffffc02022a6:	f4a6                	sd	s1,104(sp)
ffffffffc02022a8:	f0ca                	sd	s2,96(sp)
ffffffffc02022aa:	ecce                	sd	s3,88(sp)
ffffffffc02022ac:	e8d2                	sd	s4,80(sp)
ffffffffc02022ae:	e4d6                	sd	s5,72(sp)
ffffffffc02022b0:	e0da                	sd	s6,64(sp)
ffffffffc02022b2:	fc5e                	sd	s7,56(sp)
ffffffffc02022b4:	f862                	sd	s8,48(sp)
ffffffffc02022b6:	f466                	sd	s9,40(sp)
ffffffffc02022b8:	f06a                	sd	s10,32(sp)
ffffffffc02022ba:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022bc:	03479713          	slli	a4,a5,0x34
ffffffffc02022c0:	1c071163          	bnez	a4,ffffffffc0202482 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02022c4:	002007b7          	lui	a5,0x200
ffffffffc02022c8:	20f5e563          	bltu	a1,a5,ffffffffc02024d2 <exit_range+0x236>
ffffffffc02022cc:	8b32                	mv	s6,a2
ffffffffc02022ce:	20c5f263          	bleu	a2,a1,ffffffffc02024d2 <exit_range+0x236>
ffffffffc02022d2:	4785                	li	a5,1
ffffffffc02022d4:	07fe                	slli	a5,a5,0x1f
ffffffffc02022d6:	1ec7ee63          	bltu	a5,a2,ffffffffc02024d2 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022da:	c00009b7          	lui	s3,0xc0000
ffffffffc02022de:	400007b7          	lui	a5,0x40000
ffffffffc02022e2:	0135f9b3          	and	s3,a1,s3
ffffffffc02022e6:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022e8:	c0000337          	lui	t1,0xc0000
ffffffffc02022ec:	00698933          	add	s2,s3,t1
ffffffffc02022f0:	01e95913          	srli	s2,s2,0x1e
ffffffffc02022f4:	1ff97913          	andi	s2,s2,511
ffffffffc02022f8:	8e2a                	mv	t3,a0
ffffffffc02022fa:	090e                	slli	s2,s2,0x3
ffffffffc02022fc:	9972                	add	s2,s2,t3
ffffffffc02022fe:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202302:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0202306:	5dfd                	li	s11,-1
        if (pde1 & PTE_V)
ffffffffc0202308:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020230c:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc020230e:	000c7d17          	auipc	s10,0xc7
ffffffffc0202312:	e92d0d13          	addi	s10,s10,-366 # ffffffffc02c91a0 <npage>
    return KADDR(page2pa(page));
ffffffffc0202316:	00cddd93          	srli	s11,s11,0xc
ffffffffc020231a:	000c7717          	auipc	a4,0xc7
ffffffffc020231e:	ef670713          	addi	a4,a4,-266 # ffffffffc02c9210 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0202322:	000c7e97          	auipc	t4,0xc7
ffffffffc0202326:	efee8e93          	addi	t4,t4,-258 # ffffffffc02c9220 <pages>
        if (pde1 & PTE_V)
ffffffffc020232a:	e79d                	bnez	a5,ffffffffc0202358 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc020232c:	12098963          	beqz	s3,ffffffffc020245e <exit_range+0x1c2>
ffffffffc0202330:	400007b7          	lui	a5,0x40000
ffffffffc0202334:	84ce                	mv	s1,s3
ffffffffc0202336:	97ce                	add	a5,a5,s3
ffffffffc0202338:	1369f363          	bleu	s6,s3,ffffffffc020245e <exit_range+0x1c2>
ffffffffc020233c:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020233e:	00698933          	add	s2,s3,t1
ffffffffc0202342:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202346:	1ff97913          	andi	s2,s2,511
ffffffffc020234a:	090e                	slli	s2,s2,0x3
ffffffffc020234c:	9972                	add	s2,s2,t3
ffffffffc020234e:	00093b83          	ld	s7,0(s2)
        if (pde1 & PTE_V)
ffffffffc0202352:	001bf793          	andi	a5,s7,1
ffffffffc0202356:	dbf9                	beqz	a5,ffffffffc020232c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202358:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020235c:	0b8a                	slli	s7,s7,0x2
ffffffffc020235e:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202362:	14fbfc63          	bleu	a5,s7,ffffffffc02024ba <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202366:	fff80ab7          	lui	s5,0xfff80
ffffffffc020236a:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc020236c:	000806b7          	lui	a3,0x80
ffffffffc0202370:	96d6                	add	a3,a3,s5
ffffffffc0202372:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0202376:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc020237a:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc020237c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020237e:	12f67263          	bleu	a5,a2,ffffffffc02024a2 <exit_range+0x206>
ffffffffc0202382:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0202386:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202388:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc020238c:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc020238e:	00080837          	lui	a6,0x80
ffffffffc0202392:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc0202394:	00200c37          	lui	s8,0x200
ffffffffc0202398:	a801                	j	ffffffffc02023a8 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc020239a:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc020239c:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc020239e:	c0d9                	beqz	s1,ffffffffc0202424 <exit_range+0x188>
ffffffffc02023a0:	0934f263          	bleu	s3,s1,ffffffffc0202424 <exit_range+0x188>
ffffffffc02023a4:	0d64fc63          	bleu	s6,s1,ffffffffc020247c <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02023a8:	0154d413          	srli	s0,s1,0x15
ffffffffc02023ac:	1ff47413          	andi	s0,s0,511
ffffffffc02023b0:	040e                	slli	s0,s0,0x3
ffffffffc02023b2:	9452                	add	s0,s0,s4
ffffffffc02023b4:	601c                	ld	a5,0(s0)
                if (pde0 & PTE_V)
ffffffffc02023b6:	0017f693          	andi	a3,a5,1
ffffffffc02023ba:	d2e5                	beqz	a3,ffffffffc020239a <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02023bc:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023c0:	00279513          	slli	a0,a5,0x2
ffffffffc02023c4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023c6:	0eb57a63          	bleu	a1,a0,ffffffffc02024ba <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ca:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02023cc:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02023d0:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02023d4:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023d6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023d8:	0cb7f563          	bleu	a1,a5,ffffffffc02024a2 <exit_range+0x206>
ffffffffc02023dc:	631c                	ld	a5,0(a4)
ffffffffc02023de:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02023e0:	015685b3          	add	a1,a3,s5
                        if (pt[i] & PTE_V)
ffffffffc02023e4:	629c                	ld	a5,0(a3)
ffffffffc02023e6:	8b85                	andi	a5,a5,1
ffffffffc02023e8:	fbd5                	bnez	a5,ffffffffc020239c <exit_range+0x100>
ffffffffc02023ea:	06a1                	addi	a3,a3,8
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02023ec:	fed59ce3          	bne	a1,a3,ffffffffc02023e4 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc02023f0:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc02023f4:	4585                	li	a1,1
ffffffffc02023f6:	e072                	sd	t3,0(sp)
ffffffffc02023f8:	953e                	add	a0,a0,a5
ffffffffc02023fa:	ad1ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
                d0start += PTSIZE;
ffffffffc02023fe:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202400:	00043023          	sd	zero,0(s0)
ffffffffc0202404:	000c7e97          	auipc	t4,0xc7
ffffffffc0202408:	e1ce8e93          	addi	t4,t4,-484 # ffffffffc02c9220 <pages>
ffffffffc020240c:	6e02                	ld	t3,0(sp)
ffffffffc020240e:	c0000337          	lui	t1,0xc0000
ffffffffc0202412:	fff808b7          	lui	a7,0xfff80
ffffffffc0202416:	00080837          	lui	a6,0x80
ffffffffc020241a:	000c7717          	auipc	a4,0xc7
ffffffffc020241e:	df670713          	addi	a4,a4,-522 # ffffffffc02c9210 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202422:	fcbd                	bnez	s1,ffffffffc02023a0 <exit_range+0x104>
            if (free_pd0)
ffffffffc0202424:	f00c84e3          	beqz	s9,ffffffffc020232c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202428:	000d3783          	ld	a5,0(s10)
ffffffffc020242c:	e072                	sd	t3,0(sp)
ffffffffc020242e:	08fbf663          	bleu	a5,s7,ffffffffc02024ba <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202432:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0202436:	67a2                	ld	a5,8(sp)
ffffffffc0202438:	4585                	li	a1,1
ffffffffc020243a:	953e                	add	a0,a0,a5
ffffffffc020243c:	a8fff0ef          	jal	ra,ffffffffc0201eca <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202440:	00093023          	sd	zero,0(s2)
ffffffffc0202444:	000c7717          	auipc	a4,0xc7
ffffffffc0202448:	dcc70713          	addi	a4,a4,-564 # ffffffffc02c9210 <va_pa_offset>
ffffffffc020244c:	c0000337          	lui	t1,0xc0000
ffffffffc0202450:	6e02                	ld	t3,0(sp)
ffffffffc0202452:	000c7e97          	auipc	t4,0xc7
ffffffffc0202456:	dcee8e93          	addi	t4,t4,-562 # ffffffffc02c9220 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc020245a:	ec099be3          	bnez	s3,ffffffffc0202330 <exit_range+0x94>
}
ffffffffc020245e:	70e6                	ld	ra,120(sp)
ffffffffc0202460:	7446                	ld	s0,112(sp)
ffffffffc0202462:	74a6                	ld	s1,104(sp)
ffffffffc0202464:	7906                	ld	s2,96(sp)
ffffffffc0202466:	69e6                	ld	s3,88(sp)
ffffffffc0202468:	6a46                	ld	s4,80(sp)
ffffffffc020246a:	6aa6                	ld	s5,72(sp)
ffffffffc020246c:	6b06                	ld	s6,64(sp)
ffffffffc020246e:	7be2                	ld	s7,56(sp)
ffffffffc0202470:	7c42                	ld	s8,48(sp)
ffffffffc0202472:	7ca2                	ld	s9,40(sp)
ffffffffc0202474:	7d02                	ld	s10,32(sp)
ffffffffc0202476:	6de2                	ld	s11,24(sp)
ffffffffc0202478:	6109                	addi	sp,sp,128
ffffffffc020247a:	8082                	ret
            if (free_pd0)
ffffffffc020247c:	ea0c8ae3          	beqz	s9,ffffffffc0202330 <exit_range+0x94>
ffffffffc0202480:	b765                	j	ffffffffc0202428 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202482:	00008697          	auipc	a3,0x8
ffffffffc0202486:	0ce68693          	addi	a3,a3,206 # ffffffffc020a550 <default_pmm_manager+0x6f0>
ffffffffc020248a:	00007617          	auipc	a2,0x7
ffffffffc020248e:	28e60613          	addi	a2,a2,654 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202492:	16f00593          	li	a1,367
ffffffffc0202496:	00008517          	auipc	a0,0x8
ffffffffc020249a:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc020249e:	febfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc02024a2:	00008617          	auipc	a2,0x8
ffffffffc02024a6:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc02024aa:	06900593          	li	a1,105
ffffffffc02024ae:	00008517          	auipc	a0,0x8
ffffffffc02024b2:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc02024b6:	fd3fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024ba:	00008617          	auipc	a2,0x8
ffffffffc02024be:	a5660613          	addi	a2,a2,-1450 # ffffffffc0209f10 <default_pmm_manager+0xb0>
ffffffffc02024c2:	06200593          	li	a1,98
ffffffffc02024c6:	00008517          	auipc	a0,0x8
ffffffffc02024ca:	a1250513          	addi	a0,a0,-1518 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc02024ce:	fbbfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024d2:	00008697          	auipc	a3,0x8
ffffffffc02024d6:	0ae68693          	addi	a3,a3,174 # ffffffffc020a580 <default_pmm_manager+0x720>
ffffffffc02024da:	00007617          	auipc	a2,0x7
ffffffffc02024de:	23e60613          	addi	a2,a2,574 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02024e2:	17000593          	li	a1,368
ffffffffc02024e6:	00008517          	auipc	a0,0x8
ffffffffc02024ea:	aea50513          	addi	a0,a0,-1302 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc02024ee:	f9bfd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02024f2 <page_remove>:
{
ffffffffc02024f2:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024f4:	4601                	li	a2,0
{
ffffffffc02024f6:	e426                	sd	s1,8(sp)
ffffffffc02024f8:	ec06                	sd	ra,24(sp)
ffffffffc02024fa:	e822                	sd	s0,16(sp)
ffffffffc02024fc:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024fe:	a53ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
    if (ptep != NULL)
ffffffffc0202502:	c511                	beqz	a0,ffffffffc020250e <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc0202504:	611c                	ld	a5,0(a0)
ffffffffc0202506:	842a                	mv	s0,a0
ffffffffc0202508:	0017f713          	andi	a4,a5,1
ffffffffc020250c:	e711                	bnez	a4,ffffffffc0202518 <page_remove+0x26>
}
ffffffffc020250e:	60e2                	ld	ra,24(sp)
ffffffffc0202510:	6442                	ld	s0,16(sp)
ffffffffc0202512:	64a2                	ld	s1,8(sp)
ffffffffc0202514:	6105                	addi	sp,sp,32
ffffffffc0202516:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202518:	000c7717          	auipc	a4,0xc7
ffffffffc020251c:	c8870713          	addi	a4,a4,-888 # ffffffffc02c91a0 <npage>
ffffffffc0202520:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202522:	078a                	slli	a5,a5,0x2
ffffffffc0202524:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202526:	02e7fe63          	bleu	a4,a5,ffffffffc0202562 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc020252a:	000c7717          	auipc	a4,0xc7
ffffffffc020252e:	cf670713          	addi	a4,a4,-778 # ffffffffc02c9220 <pages>
ffffffffc0202532:	6308                	ld	a0,0(a4)
ffffffffc0202534:	fff80737          	lui	a4,0xfff80
ffffffffc0202538:	97ba                	add	a5,a5,a4
ffffffffc020253a:	079a                	slli	a5,a5,0x6
ffffffffc020253c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020253e:	411c                	lw	a5,0(a0)
ffffffffc0202540:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202544:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202546:	cb11                	beqz	a4,ffffffffc020255a <page_remove+0x68>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202548:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020254c:	12048073          	sfence.vma	s1
}
ffffffffc0202550:	60e2                	ld	ra,24(sp)
ffffffffc0202552:	6442                	ld	s0,16(sp)
ffffffffc0202554:	64a2                	ld	s1,8(sp)
ffffffffc0202556:	6105                	addi	sp,sp,32
ffffffffc0202558:	8082                	ret
            free_page(page);
ffffffffc020255a:	4585                	li	a1,1
ffffffffc020255c:	96fff0ef          	jal	ra,ffffffffc0201eca <free_pages>
ffffffffc0202560:	b7e5                	j	ffffffffc0202548 <page_remove+0x56>
ffffffffc0202562:	8c5ff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>

ffffffffc0202566 <page_insert>:
{
ffffffffc0202566:	7179                	addi	sp,sp,-48
ffffffffc0202568:	e44e                	sd	s3,8(sp)
ffffffffc020256a:	89b2                	mv	s3,a2
ffffffffc020256c:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020256e:	4605                	li	a2,1
{
ffffffffc0202570:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202572:	85ce                	mv	a1,s3
{
ffffffffc0202574:	ec26                	sd	s1,24(sp)
ffffffffc0202576:	f406                	sd	ra,40(sp)
ffffffffc0202578:	e84a                	sd	s2,16(sp)
ffffffffc020257a:	e052                	sd	s4,0(sp)
ffffffffc020257c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020257e:	9d3ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
    if (ptep == NULL)
ffffffffc0202582:	cd49                	beqz	a0,ffffffffc020261c <page_insert+0xb6>
    page->ref += 1;
ffffffffc0202584:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc0202586:	611c                	ld	a5,0(a0)
ffffffffc0202588:	892a                	mv	s2,a0
ffffffffc020258a:	0016871b          	addiw	a4,a3,1
ffffffffc020258e:	c018                	sw	a4,0(s0)
ffffffffc0202590:	0017f713          	andi	a4,a5,1
ffffffffc0202594:	ef05                	bnez	a4,ffffffffc02025cc <page_insert+0x66>
ffffffffc0202596:	000c7797          	auipc	a5,0xc7
ffffffffc020259a:	c8a78793          	addi	a5,a5,-886 # ffffffffc02c9220 <pages>
ffffffffc020259e:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02025a0:	8c19                	sub	s0,s0,a4
ffffffffc02025a2:	000806b7          	lui	a3,0x80
ffffffffc02025a6:	8419                	srai	s0,s0,0x6
ffffffffc02025a8:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02025aa:	042a                	slli	s0,s0,0xa
ffffffffc02025ac:	8c45                	or	s0,s0,s1
ffffffffc02025ae:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02025b2:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025b6:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02025ba:	4501                	li	a0,0
}
ffffffffc02025bc:	70a2                	ld	ra,40(sp)
ffffffffc02025be:	7402                	ld	s0,32(sp)
ffffffffc02025c0:	64e2                	ld	s1,24(sp)
ffffffffc02025c2:	6942                	ld	s2,16(sp)
ffffffffc02025c4:	69a2                	ld	s3,8(sp)
ffffffffc02025c6:	6a02                	ld	s4,0(sp)
ffffffffc02025c8:	6145                	addi	sp,sp,48
ffffffffc02025ca:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02025cc:	000c7717          	auipc	a4,0xc7
ffffffffc02025d0:	bd470713          	addi	a4,a4,-1068 # ffffffffc02c91a0 <npage>
ffffffffc02025d4:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025d6:	078a                	slli	a5,a5,0x2
ffffffffc02025d8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025da:	04e7f363          	bleu	a4,a5,ffffffffc0202620 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02025de:	000c7a17          	auipc	s4,0xc7
ffffffffc02025e2:	c42a0a13          	addi	s4,s4,-958 # ffffffffc02c9220 <pages>
ffffffffc02025e6:	000a3703          	ld	a4,0(s4)
ffffffffc02025ea:	fff80537          	lui	a0,0xfff80
ffffffffc02025ee:	953e                	add	a0,a0,a5
ffffffffc02025f0:	051a                	slli	a0,a0,0x6
ffffffffc02025f2:	953a                	add	a0,a0,a4
        if (p == page)
ffffffffc02025f4:	00a40a63          	beq	s0,a0,ffffffffc0202608 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc02025f8:	411c                	lw	a5,0(a0)
ffffffffc02025fa:	fff7869b          	addiw	a3,a5,-1
ffffffffc02025fe:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0202600:	c691                	beqz	a3,ffffffffc020260c <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202602:	12098073          	sfence.vma	s3
ffffffffc0202606:	bf69                	j	ffffffffc02025a0 <page_insert+0x3a>
ffffffffc0202608:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020260a:	bf59                	j	ffffffffc02025a0 <page_insert+0x3a>
            free_page(page);
ffffffffc020260c:	4585                	li	a1,1
ffffffffc020260e:	8bdff0ef          	jal	ra,ffffffffc0201eca <free_pages>
ffffffffc0202612:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202616:	12098073          	sfence.vma	s3
ffffffffc020261a:	b759                	j	ffffffffc02025a0 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020261c:	5571                	li	a0,-4
ffffffffc020261e:	bf79                	j	ffffffffc02025bc <page_insert+0x56>
ffffffffc0202620:	807ff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>

ffffffffc0202624 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202624:	00008797          	auipc	a5,0x8
ffffffffc0202628:	83c78793          	addi	a5,a5,-1988 # ffffffffc0209e60 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020262c:	638c                	ld	a1,0(a5)
{
ffffffffc020262e:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202630:	00008517          	auipc	a0,0x8
ffffffffc0202634:	9c850513          	addi	a0,a0,-1592 # ffffffffc0209ff8 <default_pmm_manager+0x198>
{
ffffffffc0202638:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020263a:	000c7717          	auipc	a4,0xc7
ffffffffc020263e:	bcf73723          	sd	a5,-1074(a4) # ffffffffc02c9208 <pmm_manager>
{
ffffffffc0202642:	e0a2                	sd	s0,64(sp)
ffffffffc0202644:	fc26                	sd	s1,56(sp)
ffffffffc0202646:	f84a                	sd	s2,48(sp)
ffffffffc0202648:	f44e                	sd	s3,40(sp)
ffffffffc020264a:	f052                	sd	s4,32(sp)
ffffffffc020264c:	ec56                	sd	s5,24(sp)
ffffffffc020264e:	e85a                	sd	s6,16(sp)
ffffffffc0202650:	e45e                	sd	s7,8(sp)
ffffffffc0202652:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202654:	000c7417          	auipc	s0,0xc7
ffffffffc0202658:	bb440413          	addi	s0,s0,-1100 # ffffffffc02c9208 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020265c:	b37fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    pmm_manager->init();
ffffffffc0202660:	601c                	ld	a5,0(s0)
ffffffffc0202662:	000c7497          	auipc	s1,0xc7
ffffffffc0202666:	b3e48493          	addi	s1,s1,-1218 # ffffffffc02c91a0 <npage>
ffffffffc020266a:	000c7917          	auipc	s2,0xc7
ffffffffc020266e:	bb690913          	addi	s2,s2,-1098 # ffffffffc02c9220 <pages>
ffffffffc0202672:	679c                	ld	a5,8(a5)
ffffffffc0202674:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202676:	57f5                	li	a5,-3
ffffffffc0202678:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020267a:	00008517          	auipc	a0,0x8
ffffffffc020267e:	99650513          	addi	a0,a0,-1642 # ffffffffc020a010 <default_pmm_manager+0x1b0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202682:	000c7717          	auipc	a4,0xc7
ffffffffc0202686:	b8f73723          	sd	a5,-1138(a4) # ffffffffc02c9210 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020268a:	b09fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020268e:	46c5                	li	a3,17
ffffffffc0202690:	06ee                	slli	a3,a3,0x1b
ffffffffc0202692:	40100613          	li	a2,1025
ffffffffc0202696:	16fd                	addi	a3,a3,-1
ffffffffc0202698:	0656                	slli	a2,a2,0x15
ffffffffc020269a:	07e005b7          	lui	a1,0x7e00
ffffffffc020269e:	00008517          	auipc	a0,0x8
ffffffffc02026a2:	98a50513          	addi	a0,a0,-1654 # ffffffffc020a028 <default_pmm_manager+0x1c8>
ffffffffc02026a6:	aedfd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026aa:	777d                	lui	a4,0xfffff
ffffffffc02026ac:	000c8797          	auipc	a5,0xc8
ffffffffc02026b0:	c6b78793          	addi	a5,a5,-917 # ffffffffc02ca317 <end+0xfff>
ffffffffc02026b4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02026b6:	00088737          	lui	a4,0x88
ffffffffc02026ba:	000c7697          	auipc	a3,0xc7
ffffffffc02026be:	aee6b323          	sd	a4,-1306(a3) # ffffffffc02c91a0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026c2:	000c7717          	auipc	a4,0xc7
ffffffffc02026c6:	b4f73f23          	sd	a5,-1186(a4) # ffffffffc02c9220 <pages>
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026ca:	4701                	li	a4,0
ffffffffc02026cc:	4685                	li	a3,1
ffffffffc02026ce:	fff80837          	lui	a6,0xfff80
ffffffffc02026d2:	a019                	j	ffffffffc02026d8 <pmm_init+0xb4>
ffffffffc02026d4:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02026d8:	00671613          	slli	a2,a4,0x6
ffffffffc02026dc:	97b2                	add	a5,a5,a2
ffffffffc02026de:	07a1                	addi	a5,a5,8
ffffffffc02026e0:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026e4:	6090                	ld	a2,0(s1)
ffffffffc02026e6:	0705                	addi	a4,a4,1
ffffffffc02026e8:	010607b3          	add	a5,a2,a6
ffffffffc02026ec:	fef764e3          	bltu	a4,a5,ffffffffc02026d4 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026f0:	00093503          	ld	a0,0(s2)
ffffffffc02026f4:	fe0007b7          	lui	a5,0xfe000
ffffffffc02026f8:	00661693          	slli	a3,a2,0x6
ffffffffc02026fc:	97aa                	add	a5,a5,a0
ffffffffc02026fe:	96be                	add	a3,a3,a5
ffffffffc0202700:	c02007b7          	lui	a5,0xc0200
ffffffffc0202704:	7af6ed63          	bltu	a3,a5,ffffffffc0202ebe <pmm_init+0x89a>
ffffffffc0202708:	000c7997          	auipc	s3,0xc7
ffffffffc020270c:	b0898993          	addi	s3,s3,-1272 # ffffffffc02c9210 <va_pa_offset>
ffffffffc0202710:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end)
ffffffffc0202714:	47c5                	li	a5,17
ffffffffc0202716:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202718:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc020271a:	02f6f763          	bleu	a5,a3,ffffffffc0202748 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020271e:	6585                	lui	a1,0x1
ffffffffc0202720:	15fd                	addi	a1,a1,-1
ffffffffc0202722:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0202724:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202728:	48c77a63          	bleu	a2,a4,ffffffffc0202bbc <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc020272c:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020272e:	75fd                	lui	a1,0xfffff
ffffffffc0202730:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0202732:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0202734:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202736:	40d786b3          	sub	a3,a5,a3
ffffffffc020273a:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc020273c:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202740:	953a                	add	a0,a0,a4
ffffffffc0202742:	9602                	jalr	a2
ffffffffc0202744:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202748:	00008517          	auipc	a0,0x8
ffffffffc020274c:	90850513          	addi	a0,a0,-1784 # ffffffffc020a050 <default_pmm_manager+0x1f0>
ffffffffc0202750:	a43fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202754:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t *)boot_page_table_sv39;
ffffffffc0202756:	000c7417          	auipc	s0,0xc7
ffffffffc020275a:	a4240413          	addi	s0,s0,-1470 # ffffffffc02c9198 <boot_pgdir>
    pmm_manager->check();
ffffffffc020275e:	7b9c                	ld	a5,48(a5)
ffffffffc0202760:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202762:	00008517          	auipc	a0,0x8
ffffffffc0202766:	90650513          	addi	a0,a0,-1786 # ffffffffc020a068 <default_pmm_manager+0x208>
ffffffffc020276a:	a29fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    boot_pgdir = (pte_t *)boot_page_table_sv39;
ffffffffc020276e:	0000c697          	auipc	a3,0xc
ffffffffc0202772:	89268693          	addi	a3,a3,-1902 # ffffffffc020e000 <boot_page_table_sv39>
ffffffffc0202776:	000c7797          	auipc	a5,0xc7
ffffffffc020277a:	a2d7b123          	sd	a3,-1502(a5) # ffffffffc02c9198 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020277e:	c02007b7          	lui	a5,0xc0200
ffffffffc0202782:	10f6eae3          	bltu	a3,a5,ffffffffc0203096 <pmm_init+0xa72>
ffffffffc0202786:	0009b783          	ld	a5,0(s3)
ffffffffc020278a:	8e9d                	sub	a3,a3,a5
ffffffffc020278c:	000c7797          	auipc	a5,0xc7
ffffffffc0202790:	a8d7b623          	sd	a3,-1396(a5) # ffffffffc02c9218 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();
ffffffffc0202794:	f7cff0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202798:	6098                	ld	a4,0(s1)
ffffffffc020279a:	c80007b7          	lui	a5,0xc8000
ffffffffc020279e:	83b1                	srli	a5,a5,0xc
    nr_free_store = nr_free_pages();
ffffffffc02027a0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027a2:	0ce7eae3          	bltu	a5,a4,ffffffffc0203076 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02027a6:	6008                	ld	a0,0(s0)
ffffffffc02027a8:	44050463          	beqz	a0,ffffffffc0202bf0 <pmm_init+0x5cc>
ffffffffc02027ac:	6785                	lui	a5,0x1
ffffffffc02027ae:	17fd                	addi	a5,a5,-1
ffffffffc02027b0:	8fe9                	and	a5,a5,a0
ffffffffc02027b2:	2781                	sext.w	a5,a5
ffffffffc02027b4:	42079e63          	bnez	a5,ffffffffc0202bf0 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02027b8:	4601                	li	a2,0
ffffffffc02027ba:	4581                	li	a1,0
ffffffffc02027bc:	967ff0ef          	jal	ra,ffffffffc0202122 <get_page>
ffffffffc02027c0:	78051b63          	bnez	a0,ffffffffc0202f56 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02027c4:	4505                	li	a0,1
ffffffffc02027c6:	e7cff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc02027ca:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02027cc:	6008                	ld	a0,0(s0)
ffffffffc02027ce:	4681                	li	a3,0
ffffffffc02027d0:	4601                	li	a2,0
ffffffffc02027d2:	85d6                	mv	a1,s5
ffffffffc02027d4:	d93ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc02027d8:	7a051f63          	bnez	a0,ffffffffc0202f96 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02027dc:	6008                	ld	a0,0(s0)
ffffffffc02027de:	4601                	li	a2,0
ffffffffc02027e0:	4581                	li	a1,0
ffffffffc02027e2:	f6eff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02027e6:	78050863          	beqz	a0,ffffffffc0202f76 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc02027ea:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027ec:	0017f713          	andi	a4,a5,1
ffffffffc02027f0:	3e070463          	beqz	a4,ffffffffc0202bd8 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02027f4:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027f6:	078a                	slli	a5,a5,0x2
ffffffffc02027f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027fa:	3ce7f163          	bleu	a4,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02027fe:	00093683          	ld	a3,0(s2)
ffffffffc0202802:	fff80637          	lui	a2,0xfff80
ffffffffc0202806:	97b2                	add	a5,a5,a2
ffffffffc0202808:	079a                	slli	a5,a5,0x6
ffffffffc020280a:	97b6                	add	a5,a5,a3
ffffffffc020280c:	72fa9563          	bne	s5,a5,ffffffffc0202f36 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0202810:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x88f0>
ffffffffc0202814:	4785                	li	a5,1
ffffffffc0202816:	70fb9063          	bne	s7,a5,ffffffffc0202f16 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020281a:	6008                	ld	a0,0(s0)
ffffffffc020281c:	76fd                	lui	a3,0xfffff
ffffffffc020281e:	611c                	ld	a5,0(a0)
ffffffffc0202820:	078a                	slli	a5,a5,0x2
ffffffffc0202822:	8ff5                	and	a5,a5,a3
ffffffffc0202824:	00c7d613          	srli	a2,a5,0xc
ffffffffc0202828:	66e67e63          	bleu	a4,a2,ffffffffc0202ea4 <pmm_init+0x880>
ffffffffc020282c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202830:	97e2                	add	a5,a5,s8
ffffffffc0202832:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x88f0>
ffffffffc0202836:	0b0a                	slli	s6,s6,0x2
ffffffffc0202838:	00db7b33          	and	s6,s6,a3
ffffffffc020283c:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202840:	56e7f863          	bleu	a4,a5,ffffffffc0202db0 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202844:	4601                	li	a2,0
ffffffffc0202846:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202848:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020284a:	f06ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020284e:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202850:	55651063          	bne	a0,s6,ffffffffc0202d90 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0202854:	4505                	li	a0,1
ffffffffc0202856:	decff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020285a:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020285c:	6008                	ld	a0,0(s0)
ffffffffc020285e:	46d1                	li	a3,20
ffffffffc0202860:	6605                	lui	a2,0x1
ffffffffc0202862:	85da                	mv	a1,s6
ffffffffc0202864:	d03ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc0202868:	50051463          	bnez	a0,ffffffffc0202d70 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020286c:	6008                	ld	a0,0(s0)
ffffffffc020286e:	4601                	li	a2,0
ffffffffc0202870:	6585                	lui	a1,0x1
ffffffffc0202872:	edeff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0202876:	4c050d63          	beqz	a0,ffffffffc0202d50 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc020287a:	611c                	ld	a5,0(a0)
ffffffffc020287c:	0107f713          	andi	a4,a5,16
ffffffffc0202880:	4a070863          	beqz	a4,ffffffffc0202d30 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0202884:	8b91                	andi	a5,a5,4
ffffffffc0202886:	48078563          	beqz	a5,ffffffffc0202d10 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020288a:	6008                	ld	a0,0(s0)
ffffffffc020288c:	611c                	ld	a5,0(a0)
ffffffffc020288e:	8bc1                	andi	a5,a5,16
ffffffffc0202890:	46078063          	beqz	a5,ffffffffc0202cf0 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc0202894:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_matrix_out_size+0x1f45a8>
ffffffffc0202898:	43779c63          	bne	a5,s7,ffffffffc0202cd0 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020289c:	4681                	li	a3,0
ffffffffc020289e:	6605                	lui	a2,0x1
ffffffffc02028a0:	85d6                	mv	a1,s5
ffffffffc02028a2:	cc5ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc02028a6:	40051563          	bnez	a0,ffffffffc0202cb0 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc02028aa:	000aa703          	lw	a4,0(s5)
ffffffffc02028ae:	4789                	li	a5,2
ffffffffc02028b0:	3ef71063          	bne	a4,a5,ffffffffc0202c90 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02028b4:	000b2783          	lw	a5,0(s6)
ffffffffc02028b8:	3a079c63          	bnez	a5,ffffffffc0202c70 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02028bc:	6008                	ld	a0,0(s0)
ffffffffc02028be:	4601                	li	a2,0
ffffffffc02028c0:	6585                	lui	a1,0x1
ffffffffc02028c2:	e8eff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02028c6:	38050563          	beqz	a0,ffffffffc0202c50 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02028ca:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02028cc:	00177793          	andi	a5,a4,1
ffffffffc02028d0:	30078463          	beqz	a5,ffffffffc0202bd8 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02028d4:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028d6:	00271793          	slli	a5,a4,0x2
ffffffffc02028da:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028dc:	2ed7f063          	bleu	a3,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02028e0:	00093683          	ld	a3,0(s2)
ffffffffc02028e4:	fff80637          	lui	a2,0xfff80
ffffffffc02028e8:	97b2                	add	a5,a5,a2
ffffffffc02028ea:	079a                	slli	a5,a5,0x6
ffffffffc02028ec:	97b6                	add	a5,a5,a3
ffffffffc02028ee:	32fa9163          	bne	s5,a5,ffffffffc0202c10 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc02028f2:	8b41                	andi	a4,a4,16
ffffffffc02028f4:	70071163          	bnez	a4,ffffffffc0202ff6 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc02028f8:	6008                	ld	a0,0(s0)
ffffffffc02028fa:	4581                	li	a1,0
ffffffffc02028fc:	bf7ff0ef          	jal	ra,ffffffffc02024f2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202900:	000aa703          	lw	a4,0(s5)
ffffffffc0202904:	4785                	li	a5,1
ffffffffc0202906:	6cf71863          	bne	a4,a5,ffffffffc0202fd6 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc020290a:	000b2783          	lw	a5,0(s6)
ffffffffc020290e:	6a079463          	bnez	a5,ffffffffc0202fb6 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202912:	6008                	ld	a0,0(s0)
ffffffffc0202914:	6585                	lui	a1,0x1
ffffffffc0202916:	bddff0ef          	jal	ra,ffffffffc02024f2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020291a:	000aa783          	lw	a5,0(s5)
ffffffffc020291e:	50079363          	bnez	a5,ffffffffc0202e24 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0202922:	000b2783          	lw	a5,0(s6)
ffffffffc0202926:	4c079f63          	bnez	a5,ffffffffc0202e04 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020292a:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020292e:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202930:	000ab783          	ld	a5,0(s5)
ffffffffc0202934:	078a                	slli	a5,a5,0x2
ffffffffc0202936:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202938:	28c7f263          	bleu	a2,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020293c:	fff80737          	lui	a4,0xfff80
ffffffffc0202940:	00093503          	ld	a0,0(s2)
ffffffffc0202944:	97ba                	add	a5,a5,a4
ffffffffc0202946:	079a                	slli	a5,a5,0x6
ffffffffc0202948:	00f50733          	add	a4,a0,a5
ffffffffc020294c:	4314                	lw	a3,0(a4)
ffffffffc020294e:	4705                	li	a4,1
ffffffffc0202950:	48e69a63          	bne	a3,a4,ffffffffc0202de4 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0202954:	8799                	srai	a5,a5,0x6
ffffffffc0202956:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020295a:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc020295c:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020295e:	8331                	srli	a4,a4,0xc
ffffffffc0202960:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202962:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202964:	46c77363          	bleu	a2,a4,ffffffffc0202dca <pmm_init+0x7a6>

    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202968:	0009b683          	ld	a3,0(s3)
ffffffffc020296c:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020296e:	639c                	ld	a5,0(a5)
ffffffffc0202970:	078a                	slli	a5,a5,0x2
ffffffffc0202972:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202974:	24c7f463          	bleu	a2,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202978:	416787b3          	sub	a5,a5,s6
ffffffffc020297c:	079a                	slli	a5,a5,0x6
ffffffffc020297e:	953e                	add	a0,a0,a5
ffffffffc0202980:	4585                	li	a1,1
ffffffffc0202982:	d48ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202986:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc020298a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020298c:	078a                	slli	a5,a5,0x2
ffffffffc020298e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202990:	22e7f663          	bleu	a4,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202994:	00093503          	ld	a0,0(s2)
ffffffffc0202998:	416787b3          	sub	a5,a5,s6
ffffffffc020299c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020299e:	953e                	add	a0,a0,a5
ffffffffc02029a0:	4585                	li	a1,1
ffffffffc02029a2:	d28ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02029a6:	601c                	ld	a5,0(s0)
ffffffffc02029a8:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02029ac:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc02029b0:	d60ff0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc02029b4:	68aa1163          	bne	s4,a0,ffffffffc0203036 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02029b8:	00008517          	auipc	a0,0x8
ffffffffc02029bc:	9c850513          	addi	a0,a0,-1592 # ffffffffc020a380 <default_pmm_manager+0x520>
ffffffffc02029c0:	fd2fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
{
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();
ffffffffc02029c4:	d4cff0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02029c8:	6098                	ld	a4,0(s1)
ffffffffc02029ca:	c02007b7          	lui	a5,0xc0200
    nr_free_store = nr_free_pages();
ffffffffc02029ce:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02029d0:	00c71693          	slli	a3,a4,0xc
ffffffffc02029d4:	18d7f563          	bleu	a3,a5,ffffffffc0202b5e <pmm_init+0x53a>
    {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029d8:	83b1                	srli	a5,a5,0xc
ffffffffc02029da:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02029dc:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029e0:	1ae7f163          	bleu	a4,a5,ffffffffc0202b82 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029e4:	7bfd                	lui	s7,0xfffff
ffffffffc02029e6:	6b05                	lui	s6,0x1
ffffffffc02029e8:	a029                	j	ffffffffc02029f2 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029ea:	00cad713          	srli	a4,s5,0xc
ffffffffc02029ee:	18f77a63          	bleu	a5,a4,ffffffffc0202b82 <pmm_init+0x55e>
ffffffffc02029f2:	0009b583          	ld	a1,0(s3)
ffffffffc02029f6:	4601                	li	a2,0
ffffffffc02029f8:	95d6                	add	a1,a1,s5
ffffffffc02029fa:	d56ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02029fe:	16050263          	beqz	a0,ffffffffc0202b62 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a02:	611c                	ld	a5,0(a0)
ffffffffc0202a04:	078a                	slli	a5,a5,0x2
ffffffffc0202a06:	0177f7b3          	and	a5,a5,s7
ffffffffc0202a0a:	19579963          	bne	a5,s5,ffffffffc0202b9c <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a0e:	609c                	ld	a5,0(s1)
ffffffffc0202a10:	9ada                	add	s5,s5,s6
ffffffffc0202a12:	6008                	ld	a0,0(s0)
ffffffffc0202a14:	00c79713          	slli	a4,a5,0xc
ffffffffc0202a18:	fceae9e3          	bltu	s5,a4,ffffffffc02029ea <pmm_init+0x3c6>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc0202a1c:	611c                	ld	a5,0(a0)
ffffffffc0202a1e:	62079c63          	bnez	a5,ffffffffc0203056 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0202a22:	4505                	li	a0,1
ffffffffc0202a24:	c1eff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0202a28:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a2a:	6008                	ld	a0,0(s0)
ffffffffc0202a2c:	4699                	li	a3,6
ffffffffc0202a2e:	10000613          	li	a2,256
ffffffffc0202a32:	85d6                	mv	a1,s5
ffffffffc0202a34:	b33ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc0202a38:	1e051c63          	bnez	a0,ffffffffc0202c30 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202a3c:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202a40:	4785                	li	a5,1
ffffffffc0202a42:	44f71163          	bne	a4,a5,ffffffffc0202e84 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a46:	6008                	ld	a0,0(s0)
ffffffffc0202a48:	6b05                	lui	s6,0x1
ffffffffc0202a4a:	4699                	li	a3,6
ffffffffc0202a4c:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x87f0>
ffffffffc0202a50:	85d6                	mv	a1,s5
ffffffffc0202a52:	b15ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc0202a56:	40051763          	bnez	a0,ffffffffc0202e64 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202a5a:	000aa703          	lw	a4,0(s5)
ffffffffc0202a5e:	4789                	li	a5,2
ffffffffc0202a60:	3ef71263          	bne	a4,a5,ffffffffc0202e44 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a64:	00008597          	auipc	a1,0x8
ffffffffc0202a68:	a5458593          	addi	a1,a1,-1452 # ffffffffc020a4b8 <default_pmm_manager+0x658>
ffffffffc0202a6c:	10000513          	li	a0,256
ffffffffc0202a70:	62e060ef          	jal	ra,ffffffffc020909e <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a74:	100b0593          	addi	a1,s6,256
ffffffffc0202a78:	10000513          	li	a0,256
ffffffffc0202a7c:	634060ef          	jal	ra,ffffffffc02090b0 <strcmp>
ffffffffc0202a80:	44051b63          	bnez	a0,ffffffffc0202ed6 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202a84:	00093683          	ld	a3,0(s2)
ffffffffc0202a88:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202a8c:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202a8e:	40da86b3          	sub	a3,s5,a3
ffffffffc0202a92:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202a94:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202a96:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202a98:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202a9c:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202aa0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202aa2:	10f77f63          	bleu	a5,a4,ffffffffc0202bc0 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202aa6:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202aaa:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202aae:	96be                	add	a3,a3,a5
ffffffffc0202ab0:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd35de8>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ab4:	5a6060ef          	jal	ra,ffffffffc020905a <strlen>
ffffffffc0202ab8:	54051f63          	bnez	a0,ffffffffc0203016 <pmm_init+0x9f2>

    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202abc:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202ac0:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ac2:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd35ce8>
ffffffffc0202ac6:	068a                	slli	a3,a3,0x2
ffffffffc0202ac8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202aca:	0ef6f963          	bleu	a5,a3,ffffffffc0202bbc <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0202ace:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ad2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ad4:	0efb7663          	bleu	a5,s6,ffffffffc0202bc0 <pmm_init+0x59c>
ffffffffc0202ad8:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202adc:	4585                	li	a1,1
ffffffffc0202ade:	8556                	mv	a0,s5
ffffffffc0202ae0:	99b6                	add	s3,s3,a3
ffffffffc0202ae2:	be8ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ae6:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202aea:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202aec:	078a                	slli	a5,a5,0x2
ffffffffc0202aee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202af0:	0ce7f663          	bleu	a4,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202af4:	00093503          	ld	a0,0(s2)
ffffffffc0202af8:	fff809b7          	lui	s3,0xfff80
ffffffffc0202afc:	97ce                	add	a5,a5,s3
ffffffffc0202afe:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202b00:	953e                	add	a0,a0,a5
ffffffffc0202b02:	4585                	li	a1,1
ffffffffc0202b04:	bc6ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b08:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202b0c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b0e:	078a                	slli	a5,a5,0x2
ffffffffc0202b10:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b12:	0ae7f563          	bleu	a4,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b16:	00093503          	ld	a0,0(s2)
ffffffffc0202b1a:	97ce                	add	a5,a5,s3
ffffffffc0202b1c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202b1e:	953e                	add	a0,a0,a5
ffffffffc0202b20:	4585                	li	a1,1
ffffffffc0202b22:	ba8ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202b26:	601c                	ld	a5,0(s0)
ffffffffc0202b28:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202b2c:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202b30:	be0ff0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc0202b34:	3caa1163          	bne	s4,a0,ffffffffc0202ef6 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202b38:	00008517          	auipc	a0,0x8
ffffffffc0202b3c:	9f850513          	addi	a0,a0,-1544 # ffffffffc020a530 <default_pmm_manager+0x6d0>
ffffffffc0202b40:	e52fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0202b44:	6406                	ld	s0,64(sp)
ffffffffc0202b46:	60a6                	ld	ra,72(sp)
ffffffffc0202b48:	74e2                	ld	s1,56(sp)
ffffffffc0202b4a:	7942                	ld	s2,48(sp)
ffffffffc0202b4c:	79a2                	ld	s3,40(sp)
ffffffffc0202b4e:	7a02                	ld	s4,32(sp)
ffffffffc0202b50:	6ae2                	ld	s5,24(sp)
ffffffffc0202b52:	6b42                	ld	s6,16(sp)
ffffffffc0202b54:	6ba2                	ld	s7,8(sp)
ffffffffc0202b56:	6c02                	ld	s8,0(sp)
ffffffffc0202b58:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202b5a:	8c8ff06f          	j	ffffffffc0201c22 <kmalloc_init>
ffffffffc0202b5e:	6008                	ld	a0,0(s0)
ffffffffc0202b60:	bd75                	j	ffffffffc0202a1c <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b62:	00008697          	auipc	a3,0x8
ffffffffc0202b66:	83e68693          	addi	a3,a3,-1986 # ffffffffc020a3a0 <default_pmm_manager+0x540>
ffffffffc0202b6a:	00007617          	auipc	a2,0x7
ffffffffc0202b6e:	bae60613          	addi	a2,a2,-1106 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202b72:	29700593          	li	a1,663
ffffffffc0202b76:	00007517          	auipc	a0,0x7
ffffffffc0202b7a:	45a50513          	addi	a0,a0,1114 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202b7e:	90bfd0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202b82:	86d6                	mv	a3,s5
ffffffffc0202b84:	00007617          	auipc	a2,0x7
ffffffffc0202b88:	32c60613          	addi	a2,a2,812 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0202b8c:	29700593          	li	a1,663
ffffffffc0202b90:	00007517          	auipc	a0,0x7
ffffffffc0202b94:	44050513          	addi	a0,a0,1088 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202b98:	8f1fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b9c:	00008697          	auipc	a3,0x8
ffffffffc0202ba0:	84468693          	addi	a3,a3,-1980 # ffffffffc020a3e0 <default_pmm_manager+0x580>
ffffffffc0202ba4:	00007617          	auipc	a2,0x7
ffffffffc0202ba8:	b7460613          	addi	a2,a2,-1164 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202bac:	29800593          	li	a1,664
ffffffffc0202bb0:	00007517          	auipc	a0,0x7
ffffffffc0202bb4:	42050513          	addi	a0,a0,1056 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202bb8:	8d1fd0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202bbc:	a6aff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202bc0:	00007617          	auipc	a2,0x7
ffffffffc0202bc4:	2f060613          	addi	a2,a2,752 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0202bc8:	06900593          	li	a1,105
ffffffffc0202bcc:	00007517          	auipc	a0,0x7
ffffffffc0202bd0:	30c50513          	addi	a0,a0,780 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0202bd4:	8b5fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bd8:	00007617          	auipc	a2,0x7
ffffffffc0202bdc:	59060613          	addi	a2,a2,1424 # ffffffffc020a168 <default_pmm_manager+0x308>
ffffffffc0202be0:	07400593          	li	a1,116
ffffffffc0202be4:	00007517          	auipc	a0,0x7
ffffffffc0202be8:	2f450513          	addi	a0,a0,756 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0202bec:	89dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202bf0:	00007697          	auipc	a3,0x7
ffffffffc0202bf4:	4b868693          	addi	a3,a3,1208 # ffffffffc020a0a8 <default_pmm_manager+0x248>
ffffffffc0202bf8:	00007617          	auipc	a2,0x7
ffffffffc0202bfc:	b2060613          	addi	a2,a2,-1248 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202c00:	25900593          	li	a1,601
ffffffffc0202c04:	00007517          	auipc	a0,0x7
ffffffffc0202c08:	3cc50513          	addi	a0,a0,972 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202c0c:	87dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202c10:	00007697          	auipc	a3,0x7
ffffffffc0202c14:	58068693          	addi	a3,a3,1408 # ffffffffc020a190 <default_pmm_manager+0x330>
ffffffffc0202c18:	00007617          	auipc	a2,0x7
ffffffffc0202c1c:	b0060613          	addi	a2,a2,-1280 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202c20:	27500593          	li	a1,629
ffffffffc0202c24:	00007517          	auipc	a0,0x7
ffffffffc0202c28:	3ac50513          	addi	a0,a0,940 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202c2c:	85dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c30:	00007697          	auipc	a3,0x7
ffffffffc0202c34:	7e068693          	addi	a3,a3,2016 # ffffffffc020a410 <default_pmm_manager+0x5b0>
ffffffffc0202c38:	00007617          	auipc	a2,0x7
ffffffffc0202c3c:	ae060613          	addi	a2,a2,-1312 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202c40:	29f00593          	li	a1,671
ffffffffc0202c44:	00007517          	auipc	a0,0x7
ffffffffc0202c48:	38c50513          	addi	a0,a0,908 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202c4c:	83dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c50:	00007697          	auipc	a3,0x7
ffffffffc0202c54:	5d068693          	addi	a3,a3,1488 # ffffffffc020a220 <default_pmm_manager+0x3c0>
ffffffffc0202c58:	00007617          	auipc	a2,0x7
ffffffffc0202c5c:	ac060613          	addi	a2,a2,-1344 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202c60:	27400593          	li	a1,628
ffffffffc0202c64:	00007517          	auipc	a0,0x7
ffffffffc0202c68:	36c50513          	addi	a0,a0,876 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202c6c:	81dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202c70:	00007697          	auipc	a3,0x7
ffffffffc0202c74:	67868693          	addi	a3,a3,1656 # ffffffffc020a2e8 <default_pmm_manager+0x488>
ffffffffc0202c78:	00007617          	auipc	a2,0x7
ffffffffc0202c7c:	aa060613          	addi	a2,a2,-1376 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202c80:	27300593          	li	a1,627
ffffffffc0202c84:	00007517          	auipc	a0,0x7
ffffffffc0202c88:	34c50513          	addi	a0,a0,844 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202c8c:	ffcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202c90:	00007697          	auipc	a3,0x7
ffffffffc0202c94:	64068693          	addi	a3,a3,1600 # ffffffffc020a2d0 <default_pmm_manager+0x470>
ffffffffc0202c98:	00007617          	auipc	a2,0x7
ffffffffc0202c9c:	a8060613          	addi	a2,a2,-1408 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202ca0:	27200593          	li	a1,626
ffffffffc0202ca4:	00007517          	auipc	a0,0x7
ffffffffc0202ca8:	32c50513          	addi	a0,a0,812 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202cac:	fdcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202cb0:	00007697          	auipc	a3,0x7
ffffffffc0202cb4:	5f068693          	addi	a3,a3,1520 # ffffffffc020a2a0 <default_pmm_manager+0x440>
ffffffffc0202cb8:	00007617          	auipc	a2,0x7
ffffffffc0202cbc:	a6060613          	addi	a2,a2,-1440 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202cc0:	27100593          	li	a1,625
ffffffffc0202cc4:	00007517          	auipc	a0,0x7
ffffffffc0202cc8:	30c50513          	addi	a0,a0,780 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202ccc:	fbcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202cd0:	00007697          	auipc	a3,0x7
ffffffffc0202cd4:	5b868693          	addi	a3,a3,1464 # ffffffffc020a288 <default_pmm_manager+0x428>
ffffffffc0202cd8:	00007617          	auipc	a2,0x7
ffffffffc0202cdc:	a4060613          	addi	a2,a2,-1472 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202ce0:	26f00593          	li	a1,623
ffffffffc0202ce4:	00007517          	auipc	a0,0x7
ffffffffc0202ce8:	2ec50513          	addi	a0,a0,748 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202cec:	f9cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202cf0:	00007697          	auipc	a3,0x7
ffffffffc0202cf4:	58068693          	addi	a3,a3,1408 # ffffffffc020a270 <default_pmm_manager+0x410>
ffffffffc0202cf8:	00007617          	auipc	a2,0x7
ffffffffc0202cfc:	a2060613          	addi	a2,a2,-1504 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202d00:	26e00593          	li	a1,622
ffffffffc0202d04:	00007517          	auipc	a0,0x7
ffffffffc0202d08:	2cc50513          	addi	a0,a0,716 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202d0c:	f7cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202d10:	00007697          	auipc	a3,0x7
ffffffffc0202d14:	55068693          	addi	a3,a3,1360 # ffffffffc020a260 <default_pmm_manager+0x400>
ffffffffc0202d18:	00007617          	auipc	a2,0x7
ffffffffc0202d1c:	a0060613          	addi	a2,a2,-1536 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202d20:	26d00593          	li	a1,621
ffffffffc0202d24:	00007517          	auipc	a0,0x7
ffffffffc0202d28:	2ac50513          	addi	a0,a0,684 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202d2c:	f5cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202d30:	00007697          	auipc	a3,0x7
ffffffffc0202d34:	52068693          	addi	a3,a3,1312 # ffffffffc020a250 <default_pmm_manager+0x3f0>
ffffffffc0202d38:	00007617          	auipc	a2,0x7
ffffffffc0202d3c:	9e060613          	addi	a2,a2,-1568 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202d40:	26c00593          	li	a1,620
ffffffffc0202d44:	00007517          	auipc	a0,0x7
ffffffffc0202d48:	28c50513          	addi	a0,a0,652 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202d4c:	f3cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d50:	00007697          	auipc	a3,0x7
ffffffffc0202d54:	4d068693          	addi	a3,a3,1232 # ffffffffc020a220 <default_pmm_manager+0x3c0>
ffffffffc0202d58:	00007617          	auipc	a2,0x7
ffffffffc0202d5c:	9c060613          	addi	a2,a2,-1600 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202d60:	26b00593          	li	a1,619
ffffffffc0202d64:	00007517          	auipc	a0,0x7
ffffffffc0202d68:	26c50513          	addi	a0,a0,620 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202d6c:	f1cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d70:	00007697          	auipc	a3,0x7
ffffffffc0202d74:	47868693          	addi	a3,a3,1144 # ffffffffc020a1e8 <default_pmm_manager+0x388>
ffffffffc0202d78:	00007617          	auipc	a2,0x7
ffffffffc0202d7c:	9a060613          	addi	a2,a2,-1632 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202d80:	26a00593          	li	a1,618
ffffffffc0202d84:	00007517          	auipc	a0,0x7
ffffffffc0202d88:	24c50513          	addi	a0,a0,588 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202d8c:	efcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d90:	00007697          	auipc	a3,0x7
ffffffffc0202d94:	43068693          	addi	a3,a3,1072 # ffffffffc020a1c0 <default_pmm_manager+0x360>
ffffffffc0202d98:	00007617          	auipc	a2,0x7
ffffffffc0202d9c:	98060613          	addi	a2,a2,-1664 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202da0:	26700593          	li	a1,615
ffffffffc0202da4:	00007517          	auipc	a0,0x7
ffffffffc0202da8:	22c50513          	addi	a0,a0,556 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202dac:	edcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202db0:	86da                	mv	a3,s6
ffffffffc0202db2:	00007617          	auipc	a2,0x7
ffffffffc0202db6:	0fe60613          	addi	a2,a2,254 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0202dba:	26600593          	li	a1,614
ffffffffc0202dbe:	00007517          	auipc	a0,0x7
ffffffffc0202dc2:	21250513          	addi	a0,a0,530 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202dc6:	ec2fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202dca:	86be                	mv	a3,a5
ffffffffc0202dcc:	00007617          	auipc	a2,0x7
ffffffffc0202dd0:	0e460613          	addi	a2,a2,228 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0202dd4:	06900593          	li	a1,105
ffffffffc0202dd8:	00007517          	auipc	a0,0x7
ffffffffc0202ddc:	10050513          	addi	a0,a0,256 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0202de0:	ea8fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202de4:	00007697          	auipc	a3,0x7
ffffffffc0202de8:	54c68693          	addi	a3,a3,1356 # ffffffffc020a330 <default_pmm_manager+0x4d0>
ffffffffc0202dec:	00007617          	auipc	a2,0x7
ffffffffc0202df0:	92c60613          	addi	a2,a2,-1748 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202df4:	28000593          	li	a1,640
ffffffffc0202df8:	00007517          	auipc	a0,0x7
ffffffffc0202dfc:	1d850513          	addi	a0,a0,472 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202e00:	e88fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e04:	00007697          	auipc	a3,0x7
ffffffffc0202e08:	4e468693          	addi	a3,a3,1252 # ffffffffc020a2e8 <default_pmm_manager+0x488>
ffffffffc0202e0c:	00007617          	auipc	a2,0x7
ffffffffc0202e10:	90c60613          	addi	a2,a2,-1780 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202e14:	27e00593          	li	a1,638
ffffffffc0202e18:	00007517          	auipc	a0,0x7
ffffffffc0202e1c:	1b850513          	addi	a0,a0,440 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202e20:	e68fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e24:	00007697          	auipc	a3,0x7
ffffffffc0202e28:	4f468693          	addi	a3,a3,1268 # ffffffffc020a318 <default_pmm_manager+0x4b8>
ffffffffc0202e2c:	00007617          	auipc	a2,0x7
ffffffffc0202e30:	8ec60613          	addi	a2,a2,-1812 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202e34:	27d00593          	li	a1,637
ffffffffc0202e38:	00007517          	auipc	a0,0x7
ffffffffc0202e3c:	19850513          	addi	a0,a0,408 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202e40:	e48fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202e44:	00007697          	auipc	a3,0x7
ffffffffc0202e48:	65c68693          	addi	a3,a3,1628 # ffffffffc020a4a0 <default_pmm_manager+0x640>
ffffffffc0202e4c:	00007617          	auipc	a2,0x7
ffffffffc0202e50:	8cc60613          	addi	a2,a2,-1844 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202e54:	2a200593          	li	a1,674
ffffffffc0202e58:	00007517          	auipc	a0,0x7
ffffffffc0202e5c:	17850513          	addi	a0,a0,376 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202e60:	e28fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e64:	00007697          	auipc	a3,0x7
ffffffffc0202e68:	5fc68693          	addi	a3,a3,1532 # ffffffffc020a460 <default_pmm_manager+0x600>
ffffffffc0202e6c:	00007617          	auipc	a2,0x7
ffffffffc0202e70:	8ac60613          	addi	a2,a2,-1876 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202e74:	2a100593          	li	a1,673
ffffffffc0202e78:	00007517          	auipc	a0,0x7
ffffffffc0202e7c:	15850513          	addi	a0,a0,344 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202e80:	e08fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202e84:	00007697          	auipc	a3,0x7
ffffffffc0202e88:	5c468693          	addi	a3,a3,1476 # ffffffffc020a448 <default_pmm_manager+0x5e8>
ffffffffc0202e8c:	00007617          	auipc	a2,0x7
ffffffffc0202e90:	88c60613          	addi	a2,a2,-1908 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202e94:	2a000593          	li	a1,672
ffffffffc0202e98:	00007517          	auipc	a0,0x7
ffffffffc0202e9c:	13850513          	addi	a0,a0,312 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202ea0:	de8fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202ea4:	86be                	mv	a3,a5
ffffffffc0202ea6:	00007617          	auipc	a2,0x7
ffffffffc0202eaa:	00a60613          	addi	a2,a2,10 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0202eae:	26500593          	li	a1,613
ffffffffc0202eb2:	00007517          	auipc	a0,0x7
ffffffffc0202eb6:	11e50513          	addi	a0,a0,286 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202eba:	dcefd0ef          	jal	ra,ffffffffc0200488 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202ebe:	00007617          	auipc	a2,0x7
ffffffffc0202ec2:	02a60613          	addi	a2,a2,42 # ffffffffc0209ee8 <default_pmm_manager+0x88>
ffffffffc0202ec6:	08900593          	li	a1,137
ffffffffc0202eca:	00007517          	auipc	a0,0x7
ffffffffc0202ece:	10650513          	addi	a0,a0,262 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202ed2:	db6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202ed6:	00007697          	auipc	a3,0x7
ffffffffc0202eda:	5fa68693          	addi	a3,a3,1530 # ffffffffc020a4d0 <default_pmm_manager+0x670>
ffffffffc0202ede:	00007617          	auipc	a2,0x7
ffffffffc0202ee2:	83a60613          	addi	a2,a2,-1990 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202ee6:	2a600593          	li	a1,678
ffffffffc0202eea:	00007517          	auipc	a0,0x7
ffffffffc0202eee:	0e650513          	addi	a0,a0,230 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202ef2:	d96fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202ef6:	00007697          	auipc	a3,0x7
ffffffffc0202efa:	46268693          	addi	a3,a3,1122 # ffffffffc020a358 <default_pmm_manager+0x4f8>
ffffffffc0202efe:	00007617          	auipc	a2,0x7
ffffffffc0202f02:	81a60613          	addi	a2,a2,-2022 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202f06:	2b200593          	li	a1,690
ffffffffc0202f0a:	00007517          	auipc	a0,0x7
ffffffffc0202f0e:	0c650513          	addi	a0,a0,198 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202f12:	d76fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f16:	00007697          	auipc	a3,0x7
ffffffffc0202f1a:	29268693          	addi	a3,a3,658 # ffffffffc020a1a8 <default_pmm_manager+0x348>
ffffffffc0202f1e:	00006617          	auipc	a2,0x6
ffffffffc0202f22:	7fa60613          	addi	a2,a2,2042 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202f26:	26300593          	li	a1,611
ffffffffc0202f2a:	00007517          	auipc	a0,0x7
ffffffffc0202f2e:	0a650513          	addi	a0,a0,166 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202f32:	d56fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f36:	00007697          	auipc	a3,0x7
ffffffffc0202f3a:	25a68693          	addi	a3,a3,602 # ffffffffc020a190 <default_pmm_manager+0x330>
ffffffffc0202f3e:	00006617          	auipc	a2,0x6
ffffffffc0202f42:	7da60613          	addi	a2,a2,2010 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202f46:	26200593          	li	a1,610
ffffffffc0202f4a:	00007517          	auipc	a0,0x7
ffffffffc0202f4e:	08650513          	addi	a0,a0,134 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202f52:	d36fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f56:	00007697          	auipc	a3,0x7
ffffffffc0202f5a:	18a68693          	addi	a3,a3,394 # ffffffffc020a0e0 <default_pmm_manager+0x280>
ffffffffc0202f5e:	00006617          	auipc	a2,0x6
ffffffffc0202f62:	7ba60613          	addi	a2,a2,1978 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202f66:	25a00593          	li	a1,602
ffffffffc0202f6a:	00007517          	auipc	a0,0x7
ffffffffc0202f6e:	06650513          	addi	a0,a0,102 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202f72:	d16fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202f76:	00007697          	auipc	a3,0x7
ffffffffc0202f7a:	1c268693          	addi	a3,a3,450 # ffffffffc020a138 <default_pmm_manager+0x2d8>
ffffffffc0202f7e:	00006617          	auipc	a2,0x6
ffffffffc0202f82:	79a60613          	addi	a2,a2,1946 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202f86:	26100593          	li	a1,609
ffffffffc0202f8a:	00007517          	auipc	a0,0x7
ffffffffc0202f8e:	04650513          	addi	a0,a0,70 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202f92:	cf6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202f96:	00007697          	auipc	a3,0x7
ffffffffc0202f9a:	17268693          	addi	a3,a3,370 # ffffffffc020a108 <default_pmm_manager+0x2a8>
ffffffffc0202f9e:	00006617          	auipc	a2,0x6
ffffffffc0202fa2:	77a60613          	addi	a2,a2,1914 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202fa6:	25e00593          	li	a1,606
ffffffffc0202faa:	00007517          	auipc	a0,0x7
ffffffffc0202fae:	02650513          	addi	a0,a0,38 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202fb2:	cd6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fb6:	00007697          	auipc	a3,0x7
ffffffffc0202fba:	33268693          	addi	a3,a3,818 # ffffffffc020a2e8 <default_pmm_manager+0x488>
ffffffffc0202fbe:	00006617          	auipc	a2,0x6
ffffffffc0202fc2:	75a60613          	addi	a2,a2,1882 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202fc6:	27a00593          	li	a1,634
ffffffffc0202fca:	00007517          	auipc	a0,0x7
ffffffffc0202fce:	00650513          	addi	a0,a0,6 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202fd2:	cb6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202fd6:	00007697          	auipc	a3,0x7
ffffffffc0202fda:	1d268693          	addi	a3,a3,466 # ffffffffc020a1a8 <default_pmm_manager+0x348>
ffffffffc0202fde:	00006617          	auipc	a2,0x6
ffffffffc0202fe2:	73a60613          	addi	a2,a2,1850 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0202fe6:	27900593          	li	a1,633
ffffffffc0202fea:	00007517          	auipc	a0,0x7
ffffffffc0202fee:	fe650513          	addi	a0,a0,-26 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0202ff2:	c96fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202ff6:	00007697          	auipc	a3,0x7
ffffffffc0202ffa:	30a68693          	addi	a3,a3,778 # ffffffffc020a300 <default_pmm_manager+0x4a0>
ffffffffc0202ffe:	00006617          	auipc	a2,0x6
ffffffffc0203002:	71a60613          	addi	a2,a2,1818 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203006:	27600593          	li	a1,630
ffffffffc020300a:	00007517          	auipc	a0,0x7
ffffffffc020300e:	fc650513          	addi	a0,a0,-58 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0203012:	c76fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203016:	00007697          	auipc	a3,0x7
ffffffffc020301a:	4f268693          	addi	a3,a3,1266 # ffffffffc020a508 <default_pmm_manager+0x6a8>
ffffffffc020301e:	00006617          	auipc	a2,0x6
ffffffffc0203022:	6fa60613          	addi	a2,a2,1786 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203026:	2a900593          	li	a1,681
ffffffffc020302a:	00007517          	auipc	a0,0x7
ffffffffc020302e:	fa650513          	addi	a0,a0,-90 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0203032:	c56fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203036:	00007697          	auipc	a3,0x7
ffffffffc020303a:	32268693          	addi	a3,a3,802 # ffffffffc020a358 <default_pmm_manager+0x4f8>
ffffffffc020303e:	00006617          	auipc	a2,0x6
ffffffffc0203042:	6da60613          	addi	a2,a2,1754 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203046:	28800593          	li	a1,648
ffffffffc020304a:	00007517          	auipc	a0,0x7
ffffffffc020304e:	f8650513          	addi	a0,a0,-122 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0203052:	c36fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203056:	00007697          	auipc	a3,0x7
ffffffffc020305a:	3a268693          	addi	a3,a3,930 # ffffffffc020a3f8 <default_pmm_manager+0x598>
ffffffffc020305e:	00006617          	auipc	a2,0x6
ffffffffc0203062:	6ba60613          	addi	a2,a2,1722 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203066:	29b00593          	li	a1,667
ffffffffc020306a:	00007517          	auipc	a0,0x7
ffffffffc020306e:	f6650513          	addi	a0,a0,-154 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0203072:	c16fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203076:	00007697          	auipc	a3,0x7
ffffffffc020307a:	01268693          	addi	a3,a3,18 # ffffffffc020a088 <default_pmm_manager+0x228>
ffffffffc020307e:	00006617          	auipc	a2,0x6
ffffffffc0203082:	69a60613          	addi	a2,a2,1690 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203086:	25800593          	li	a1,600
ffffffffc020308a:	00007517          	auipc	a0,0x7
ffffffffc020308e:	f4650513          	addi	a0,a0,-186 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0203092:	bf6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203096:	00007617          	auipc	a2,0x7
ffffffffc020309a:	e5260613          	addi	a2,a2,-430 # ffffffffc0209ee8 <default_pmm_manager+0x88>
ffffffffc020309e:	0d100593          	li	a1,209
ffffffffc02030a2:	00007517          	auipc	a0,0x7
ffffffffc02030a6:	f2e50513          	addi	a0,a0,-210 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc02030aa:	bdefd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02030ae <copy_range>:
{
ffffffffc02030ae:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030b0:	00d667b3          	or	a5,a2,a3
{
ffffffffc02030b4:	f486                	sd	ra,104(sp)
ffffffffc02030b6:	f0a2                	sd	s0,96(sp)
ffffffffc02030b8:	eca6                	sd	s1,88(sp)
ffffffffc02030ba:	e8ca                	sd	s2,80(sp)
ffffffffc02030bc:	e4ce                	sd	s3,72(sp)
ffffffffc02030be:	e0d2                	sd	s4,64(sp)
ffffffffc02030c0:	fc56                	sd	s5,56(sp)
ffffffffc02030c2:	f85a                	sd	s6,48(sp)
ffffffffc02030c4:	f45e                	sd	s7,40(sp)
ffffffffc02030c6:	f062                	sd	s8,32(sp)
ffffffffc02030c8:	ec66                	sd	s9,24(sp)
ffffffffc02030ca:	e86a                	sd	s10,16(sp)
ffffffffc02030cc:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030ce:	03479713          	slli	a4,a5,0x34
ffffffffc02030d2:	1e071863          	bnez	a4,ffffffffc02032c2 <copy_range+0x214>
    assert(USER_ACCESS(start, end));
ffffffffc02030d6:	002007b7          	lui	a5,0x200
ffffffffc02030da:	8432                	mv	s0,a2
ffffffffc02030dc:	16f66b63          	bltu	a2,a5,ffffffffc0203252 <copy_range+0x1a4>
ffffffffc02030e0:	84b6                	mv	s1,a3
ffffffffc02030e2:	16d67863          	bleu	a3,a2,ffffffffc0203252 <copy_range+0x1a4>
ffffffffc02030e6:	4785                	li	a5,1
ffffffffc02030e8:	07fe                	slli	a5,a5,0x1f
ffffffffc02030ea:	16d7e463          	bltu	a5,a3,ffffffffc0203252 <copy_range+0x1a4>
ffffffffc02030ee:	5a7d                	li	s4,-1
ffffffffc02030f0:	8aaa                	mv	s5,a0
ffffffffc02030f2:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc02030f4:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc02030f6:	000c6c17          	auipc	s8,0xc6
ffffffffc02030fa:	0aac0c13          	addi	s8,s8,170 # ffffffffc02c91a0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02030fe:	000c6b97          	auipc	s7,0xc6
ffffffffc0203102:	122b8b93          	addi	s7,s7,290 # ffffffffc02c9220 <pages>
    return page - pages + nbase;
ffffffffc0203106:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020310a:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020310e:	4601                	li	a2,0
ffffffffc0203110:	85a2                	mv	a1,s0
ffffffffc0203112:	854a                	mv	a0,s2
ffffffffc0203114:	e3dfe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0203118:	8caa                	mv	s9,a0
        if (ptep == NULL)
ffffffffc020311a:	c17d                	beqz	a0,ffffffffc0203200 <copy_range+0x152>
        if (*ptep & PTE_V)
ffffffffc020311c:	611c                	ld	a5,0(a0)
ffffffffc020311e:	8b85                	andi	a5,a5,1
ffffffffc0203120:	e785                	bnez	a5,ffffffffc0203148 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc0203122:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0203124:	fe9465e3          	bltu	s0,s1,ffffffffc020310e <copy_range+0x60>
    return 0;
ffffffffc0203128:	4501                	li	a0,0
}
ffffffffc020312a:	70a6                	ld	ra,104(sp)
ffffffffc020312c:	7406                	ld	s0,96(sp)
ffffffffc020312e:	64e6                	ld	s1,88(sp)
ffffffffc0203130:	6946                	ld	s2,80(sp)
ffffffffc0203132:	69a6                	ld	s3,72(sp)
ffffffffc0203134:	6a06                	ld	s4,64(sp)
ffffffffc0203136:	7ae2                	ld	s5,56(sp)
ffffffffc0203138:	7b42                	ld	s6,48(sp)
ffffffffc020313a:	7ba2                	ld	s7,40(sp)
ffffffffc020313c:	7c02                	ld	s8,32(sp)
ffffffffc020313e:	6ce2                	ld	s9,24(sp)
ffffffffc0203140:	6d42                	ld	s10,16(sp)
ffffffffc0203142:	6da2                	ld	s11,8(sp)
ffffffffc0203144:	6165                	addi	sp,sp,112
ffffffffc0203146:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0203148:	4605                	li	a2,1
ffffffffc020314a:	85a2                	mv	a1,s0
ffffffffc020314c:	8556                	mv	a0,s5
ffffffffc020314e:	e03fe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0203152:	c169                	beqz	a0,ffffffffc0203214 <copy_range+0x166>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203154:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc0203158:	0017f713          	andi	a4,a5,1
ffffffffc020315c:	01f7fc93          	andi	s9,a5,31
ffffffffc0203160:	14070563          	beqz	a4,ffffffffc02032aa <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc0203164:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203168:	078a                	slli	a5,a5,0x2
ffffffffc020316a:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020316e:	12d77263          	bleu	a3,a4,ffffffffc0203292 <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc0203172:	000bb783          	ld	a5,0(s7)
ffffffffc0203176:	fff806b7          	lui	a3,0xfff80
ffffffffc020317a:	9736                	add	a4,a4,a3
ffffffffc020317c:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc020317e:	4505                	li	a0,1
ffffffffc0203180:	00e78db3          	add	s11,a5,a4
ffffffffc0203184:	cbffe0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0203188:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc020318a:	0a0d8463          	beqz	s11,ffffffffc0203232 <copy_range+0x184>
            assert(npage != NULL);
ffffffffc020318e:	c175                	beqz	a0,ffffffffc0203272 <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc0203190:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc0203194:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0203198:	40ed86b3          	sub	a3,s11,a4
ffffffffc020319c:	8699                	srai	a3,a3,0x6
ffffffffc020319e:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc02031a0:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc02031a4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031a6:	06c7fa63          	bleu	a2,a5,ffffffffc020321a <copy_range+0x16c>
    return page - pages + nbase;
ffffffffc02031aa:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc02031ae:	000c6717          	auipc	a4,0xc6
ffffffffc02031b2:	06270713          	addi	a4,a4,98 # ffffffffc02c9210 <va_pa_offset>
ffffffffc02031b6:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02031b8:	8799                	srai	a5,a5,0x6
ffffffffc02031ba:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02031bc:	0147f733          	and	a4,a5,s4
ffffffffc02031c0:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02031c4:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02031c6:	04c77963          	bleu	a2,a4,ffffffffc0203218 <copy_range+0x16a>
            memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc02031ca:	6605                	lui	a2,0x1
ffffffffc02031cc:	953e                	add	a0,a0,a5
ffffffffc02031ce:	73d050ef          	jal	ra,ffffffffc020910a <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02031d2:	86e6                	mv	a3,s9
ffffffffc02031d4:	8622                	mv	a2,s0
ffffffffc02031d6:	85ea                	mv	a1,s10
ffffffffc02031d8:	8556                	mv	a0,s5
ffffffffc02031da:	b8cff0ef          	jal	ra,ffffffffc0202566 <page_insert>
            assert(ret == 0);
ffffffffc02031de:	d131                	beqz	a0,ffffffffc0203122 <copy_range+0x74>
ffffffffc02031e0:	00007697          	auipc	a3,0x7
ffffffffc02031e4:	de068693          	addi	a3,a3,-544 # ffffffffc0209fc0 <default_pmm_manager+0x160>
ffffffffc02031e8:	00006617          	auipc	a2,0x6
ffffffffc02031ec:	53060613          	addi	a2,a2,1328 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02031f0:	1e800593          	li	a1,488
ffffffffc02031f4:	00007517          	auipc	a0,0x7
ffffffffc02031f8:	ddc50513          	addi	a0,a0,-548 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc02031fc:	a8cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203200:	002007b7          	lui	a5,0x200
ffffffffc0203204:	943e                	add	s0,s0,a5
ffffffffc0203206:	ffe007b7          	lui	a5,0xffe00
ffffffffc020320a:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc020320c:	dc11                	beqz	s0,ffffffffc0203128 <copy_range+0x7a>
ffffffffc020320e:	f09460e3          	bltu	s0,s1,ffffffffc020310e <copy_range+0x60>
ffffffffc0203212:	bf19                	j	ffffffffc0203128 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc0203214:	5571                	li	a0,-4
ffffffffc0203216:	bf11                	j	ffffffffc020312a <copy_range+0x7c>
ffffffffc0203218:	86be                	mv	a3,a5
ffffffffc020321a:	00007617          	auipc	a2,0x7
ffffffffc020321e:	c9660613          	addi	a2,a2,-874 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0203222:	06900593          	li	a1,105
ffffffffc0203226:	00007517          	auipc	a0,0x7
ffffffffc020322a:	cb250513          	addi	a0,a0,-846 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc020322e:	a5afd0ef          	jal	ra,ffffffffc0200488 <__panic>
            assert(page != NULL);
ffffffffc0203232:	00007697          	auipc	a3,0x7
ffffffffc0203236:	d6e68693          	addi	a3,a3,-658 # ffffffffc0209fa0 <default_pmm_manager+0x140>
ffffffffc020323a:	00006617          	auipc	a2,0x6
ffffffffc020323e:	4de60613          	addi	a2,a2,1246 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203242:	1ce00593          	li	a1,462
ffffffffc0203246:	00007517          	auipc	a0,0x7
ffffffffc020324a:	d8a50513          	addi	a0,a0,-630 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc020324e:	a3afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203252:	00007697          	auipc	a3,0x7
ffffffffc0203256:	32e68693          	addi	a3,a3,814 # ffffffffc020a580 <default_pmm_manager+0x720>
ffffffffc020325a:	00006617          	auipc	a2,0x6
ffffffffc020325e:	4be60613          	addi	a2,a2,1214 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203262:	1b600593          	li	a1,438
ffffffffc0203266:	00007517          	auipc	a0,0x7
ffffffffc020326a:	d6a50513          	addi	a0,a0,-662 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc020326e:	a1afd0ef          	jal	ra,ffffffffc0200488 <__panic>
            assert(npage != NULL);
ffffffffc0203272:	00007697          	auipc	a3,0x7
ffffffffc0203276:	d3e68693          	addi	a3,a3,-706 # ffffffffc0209fb0 <default_pmm_manager+0x150>
ffffffffc020327a:	00006617          	auipc	a2,0x6
ffffffffc020327e:	49e60613          	addi	a2,a2,1182 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203282:	1cf00593          	li	a1,463
ffffffffc0203286:	00007517          	auipc	a0,0x7
ffffffffc020328a:	d4a50513          	addi	a0,a0,-694 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc020328e:	9fafd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203292:	00007617          	auipc	a2,0x7
ffffffffc0203296:	c7e60613          	addi	a2,a2,-898 # ffffffffc0209f10 <default_pmm_manager+0xb0>
ffffffffc020329a:	06200593          	li	a1,98
ffffffffc020329e:	00007517          	auipc	a0,0x7
ffffffffc02032a2:	c3a50513          	addi	a0,a0,-966 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc02032a6:	9e2fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02032aa:	00007617          	auipc	a2,0x7
ffffffffc02032ae:	ebe60613          	addi	a2,a2,-322 # ffffffffc020a168 <default_pmm_manager+0x308>
ffffffffc02032b2:	07400593          	li	a1,116
ffffffffc02032b6:	00007517          	auipc	a0,0x7
ffffffffc02032ba:	c2250513          	addi	a0,a0,-990 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc02032be:	9cafd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032c2:	00007697          	auipc	a3,0x7
ffffffffc02032c6:	28e68693          	addi	a3,a3,654 # ffffffffc020a550 <default_pmm_manager+0x6f0>
ffffffffc02032ca:	00006617          	auipc	a2,0x6
ffffffffc02032ce:	44e60613          	addi	a2,a2,1102 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02032d2:	1b500593          	li	a1,437
ffffffffc02032d6:	00007517          	auipc	a0,0x7
ffffffffc02032da:	cfa50513          	addi	a0,a0,-774 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc02032de:	9aafd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02032e2 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02032e2:	12058073          	sfence.vma	a1
}
ffffffffc02032e6:	8082                	ret

ffffffffc02032e8 <pgdir_alloc_page>:
{
ffffffffc02032e8:	7179                	addi	sp,sp,-48
ffffffffc02032ea:	e84a                	sd	s2,16(sp)
ffffffffc02032ec:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02032ee:	4505                	li	a0,1
{
ffffffffc02032f0:	f022                	sd	s0,32(sp)
ffffffffc02032f2:	ec26                	sd	s1,24(sp)
ffffffffc02032f4:	e44e                	sd	s3,8(sp)
ffffffffc02032f6:	f406                	sd	ra,40(sp)
ffffffffc02032f8:	84ae                	mv	s1,a1
ffffffffc02032fa:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02032fc:	b47fe0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0203300:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0203302:	cd1d                	beqz	a0,ffffffffc0203340 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203304:	85aa                	mv	a1,a0
ffffffffc0203306:	86ce                	mv	a3,s3
ffffffffc0203308:	8626                	mv	a2,s1
ffffffffc020330a:	854a                	mv	a0,s2
ffffffffc020330c:	a5aff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc0203310:	e121                	bnez	a0,ffffffffc0203350 <pgdir_alloc_page+0x68>
        if (swap_init_ok)
ffffffffc0203312:	000c6797          	auipc	a5,0xc6
ffffffffc0203316:	e9e78793          	addi	a5,a5,-354 # ffffffffc02c91b0 <swap_init_ok>
ffffffffc020331a:	439c                	lw	a5,0(a5)
ffffffffc020331c:	2781                	sext.w	a5,a5
ffffffffc020331e:	c38d                	beqz	a5,ffffffffc0203340 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL)
ffffffffc0203320:	000c6797          	auipc	a5,0xc6
ffffffffc0203324:	fe078793          	addi	a5,a5,-32 # ffffffffc02c9300 <check_mm_struct>
ffffffffc0203328:	6388                	ld	a0,0(a5)
ffffffffc020332a:	c919                	beqz	a0,ffffffffc0203340 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc020332c:	4681                	li	a3,0
ffffffffc020332e:	8622                	mv	a2,s0
ffffffffc0203330:	85a6                	mv	a1,s1
ffffffffc0203332:	7da000ef          	jal	ra,ffffffffc0203b0c <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203336:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203338:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc020333a:	4785                	li	a5,1
ffffffffc020333c:	02f71063          	bne	a4,a5,ffffffffc020335c <pgdir_alloc_page+0x74>
}
ffffffffc0203340:	8522                	mv	a0,s0
ffffffffc0203342:	70a2                	ld	ra,40(sp)
ffffffffc0203344:	7402                	ld	s0,32(sp)
ffffffffc0203346:	64e2                	ld	s1,24(sp)
ffffffffc0203348:	6942                	ld	s2,16(sp)
ffffffffc020334a:	69a2                	ld	s3,8(sp)
ffffffffc020334c:	6145                	addi	sp,sp,48
ffffffffc020334e:	8082                	ret
            free_page(page);
ffffffffc0203350:	8522                	mv	a0,s0
ffffffffc0203352:	4585                	li	a1,1
ffffffffc0203354:	b77fe0ef          	jal	ra,ffffffffc0201eca <free_pages>
            return NULL;
ffffffffc0203358:	4401                	li	s0,0
ffffffffc020335a:	b7dd                	j	ffffffffc0203340 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc020335c:	00007697          	auipc	a3,0x7
ffffffffc0203360:	c8468693          	addi	a3,a3,-892 # ffffffffc0209fe0 <default_pmm_manager+0x180>
ffffffffc0203364:	00006617          	auipc	a2,0x6
ffffffffc0203368:	3b460613          	addi	a2,a2,948 # ffffffffc0209718 <commands+0x4c0>
ffffffffc020336c:	23500593          	li	a1,565
ffffffffc0203370:	00007517          	auipc	a0,0x7
ffffffffc0203374:	c6050513          	addi	a0,a0,-928 # ffffffffc0209fd0 <default_pmm_manager+0x170>
ffffffffc0203378:	910fd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020337c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020337c:	7135                	addi	sp,sp,-160
ffffffffc020337e:	ed06                	sd	ra,152(sp)
ffffffffc0203380:	e922                	sd	s0,144(sp)
ffffffffc0203382:	e526                	sd	s1,136(sp)
ffffffffc0203384:	e14a                	sd	s2,128(sp)
ffffffffc0203386:	fcce                	sd	s3,120(sp)
ffffffffc0203388:	f8d2                	sd	s4,112(sp)
ffffffffc020338a:	f4d6                	sd	s5,104(sp)
ffffffffc020338c:	f0da                	sd	s6,96(sp)
ffffffffc020338e:	ecde                	sd	s7,88(sp)
ffffffffc0203390:	e8e2                	sd	s8,80(sp)
ffffffffc0203392:	e4e6                	sd	s9,72(sp)
ffffffffc0203394:	e0ea                	sd	s10,64(sp)
ffffffffc0203396:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0203398:	77a010ef          	jal	ra,ffffffffc0204b12 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020339c:	000c6797          	auipc	a5,0xc6
ffffffffc02033a0:	f1478793          	addi	a5,a5,-236 # ffffffffc02c92b0 <max_swap_offset>
ffffffffc02033a4:	6394                	ld	a3,0(a5)
ffffffffc02033a6:	010007b7          	lui	a5,0x1000
ffffffffc02033aa:	17e1                	addi	a5,a5,-8
ffffffffc02033ac:	ff968713          	addi	a4,a3,-7
ffffffffc02033b0:	4ae7ee63          	bltu	a5,a4,ffffffffc020386c <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02033b4:	000bb797          	auipc	a5,0xbb
ffffffffc02033b8:	92478793          	addi	a5,a5,-1756 # ffffffffc02bdcd8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02033bc:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02033be:	000c6697          	auipc	a3,0xc6
ffffffffc02033c2:	def6b523          	sd	a5,-534(a3) # ffffffffc02c91a8 <sm>
     int r = sm->init();
ffffffffc02033c6:	9702                	jalr	a4
ffffffffc02033c8:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02033ca:	c10d                	beqz	a0,ffffffffc02033ec <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02033cc:	60ea                	ld	ra,152(sp)
ffffffffc02033ce:	644a                	ld	s0,144(sp)
ffffffffc02033d0:	8556                	mv	a0,s5
ffffffffc02033d2:	64aa                	ld	s1,136(sp)
ffffffffc02033d4:	690a                	ld	s2,128(sp)
ffffffffc02033d6:	79e6                	ld	s3,120(sp)
ffffffffc02033d8:	7a46                	ld	s4,112(sp)
ffffffffc02033da:	7aa6                	ld	s5,104(sp)
ffffffffc02033dc:	7b06                	ld	s6,96(sp)
ffffffffc02033de:	6be6                	ld	s7,88(sp)
ffffffffc02033e0:	6c46                	ld	s8,80(sp)
ffffffffc02033e2:	6ca6                	ld	s9,72(sp)
ffffffffc02033e4:	6d06                	ld	s10,64(sp)
ffffffffc02033e6:	7de2                	ld	s11,56(sp)
ffffffffc02033e8:	610d                	addi	sp,sp,160
ffffffffc02033ea:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02033ec:	000c6797          	auipc	a5,0xc6
ffffffffc02033f0:	dbc78793          	addi	a5,a5,-580 # ffffffffc02c91a8 <sm>
ffffffffc02033f4:	639c                	ld	a5,0(a5)
ffffffffc02033f6:	00007517          	auipc	a0,0x7
ffffffffc02033fa:	22250513          	addi	a0,a0,546 # ffffffffc020a618 <default_pmm_manager+0x7b8>
    return listelm->next;
ffffffffc02033fe:	000c6417          	auipc	s0,0xc6
ffffffffc0203402:	df240413          	addi	s0,s0,-526 # ffffffffc02c91f0 <free_area>
ffffffffc0203406:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203408:	4785                	li	a5,1
ffffffffc020340a:	000c6717          	auipc	a4,0xc6
ffffffffc020340e:	daf72323          	sw	a5,-602(a4) # ffffffffc02c91b0 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203412:	d81fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0203416:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203418:	36878e63          	beq	a5,s0,ffffffffc0203794 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020341c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203420:	8305                	srli	a4,a4,0x1
ffffffffc0203422:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203424:	36070c63          	beqz	a4,ffffffffc020379c <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203428:	4481                	li	s1,0
ffffffffc020342a:	4901                	li	s2,0
ffffffffc020342c:	a031                	j	ffffffffc0203438 <swap_init+0xbc>
ffffffffc020342e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203432:	8b09                	andi	a4,a4,2
ffffffffc0203434:	36070463          	beqz	a4,ffffffffc020379c <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0203438:	ff87a703          	lw	a4,-8(a5)
ffffffffc020343c:	679c                	ld	a5,8(a5)
ffffffffc020343e:	2905                	addiw	s2,s2,1
ffffffffc0203440:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203442:	fe8796e3          	bne	a5,s0,ffffffffc020342e <swap_init+0xb2>
ffffffffc0203446:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0203448:	ac9fe0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc020344c:	69351863          	bne	a0,s3,ffffffffc0203adc <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203450:	8626                	mv	a2,s1
ffffffffc0203452:	85ca                	mv	a1,s2
ffffffffc0203454:	00007517          	auipc	a0,0x7
ffffffffc0203458:	1dc50513          	addi	a0,a0,476 # ffffffffc020a630 <default_pmm_manager+0x7d0>
ffffffffc020345c:	d37fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203460:	457000ef          	jal	ra,ffffffffc02040b6 <mm_create>
ffffffffc0203464:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203466:	60050b63          	beqz	a0,ffffffffc0203a7c <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020346a:	000c6797          	auipc	a5,0xc6
ffffffffc020346e:	e9678793          	addi	a5,a5,-362 # ffffffffc02c9300 <check_mm_struct>
ffffffffc0203472:	639c                	ld	a5,0(a5)
ffffffffc0203474:	62079463          	bnez	a5,ffffffffc0203a9c <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203478:	000c6797          	auipc	a5,0xc6
ffffffffc020347c:	d2078793          	addi	a5,a5,-736 # ffffffffc02c9198 <boot_pgdir>
ffffffffc0203480:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0203484:	000c6797          	auipc	a5,0xc6
ffffffffc0203488:	e6a7be23          	sd	a0,-388(a5) # ffffffffc02c9300 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020348c:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_matrix_out_size+0x745a8>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203490:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203494:	4e079863          	bnez	a5,ffffffffc0203984 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203498:	6599                	lui	a1,0x6
ffffffffc020349a:	460d                	li	a2,3
ffffffffc020349c:	6505                	lui	a0,0x1
ffffffffc020349e:	465000ef          	jal	ra,ffffffffc0204102 <vma_create>
ffffffffc02034a2:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02034a4:	50050063          	beqz	a0,ffffffffc02039a4 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02034a8:	855e                	mv	a0,s7
ffffffffc02034aa:	4c5000ef          	jal	ra,ffffffffc020416e <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02034ae:	00007517          	auipc	a0,0x7
ffffffffc02034b2:	1f250513          	addi	a0,a0,498 # ffffffffc020a6a0 <default_pmm_manager+0x840>
ffffffffc02034b6:	cddfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02034ba:	018bb503          	ld	a0,24(s7)
ffffffffc02034be:	4605                	li	a2,1
ffffffffc02034c0:	6585                	lui	a1,0x1
ffffffffc02034c2:	a8ffe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02034c6:	4e050f63          	beqz	a0,ffffffffc02039c4 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034ca:	00007517          	auipc	a0,0x7
ffffffffc02034ce:	22650513          	addi	a0,a0,550 # ffffffffc020a6f0 <default_pmm_manager+0x890>
ffffffffc02034d2:	000c6997          	auipc	s3,0xc6
ffffffffc02034d6:	d5698993          	addi	s3,s3,-682 # ffffffffc02c9228 <check_rp>
ffffffffc02034da:	cb9fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034de:	000c6a17          	auipc	s4,0xc6
ffffffffc02034e2:	d6aa0a13          	addi	s4,s4,-662 # ffffffffc02c9248 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034e6:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02034e8:	4505                	li	a0,1
ffffffffc02034ea:	959fe0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc02034ee:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02034f2:	32050d63          	beqz	a0,ffffffffc020382c <swap_init+0x4b0>
ffffffffc02034f6:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02034f8:	8b89                	andi	a5,a5,2
ffffffffc02034fa:	30079963          	bnez	a5,ffffffffc020380c <swap_init+0x490>
ffffffffc02034fe:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203500:	ff4c14e3          	bne	s8,s4,ffffffffc02034e8 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203504:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203506:	000c6c17          	auipc	s8,0xc6
ffffffffc020350a:	d22c0c13          	addi	s8,s8,-734 # ffffffffc02c9228 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020350e:	ec3e                	sd	a5,24(sp)
ffffffffc0203510:	641c                	ld	a5,8(s0)
ffffffffc0203512:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203514:	481c                	lw	a5,16(s0)
ffffffffc0203516:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203518:	000c6797          	auipc	a5,0xc6
ffffffffc020351c:	ce87b023          	sd	s0,-800(a5) # ffffffffc02c91f8 <free_area+0x8>
ffffffffc0203520:	000c6797          	auipc	a5,0xc6
ffffffffc0203524:	cc87b823          	sd	s0,-816(a5) # ffffffffc02c91f0 <free_area>
     nr_free = 0;
ffffffffc0203528:	000c6797          	auipc	a5,0xc6
ffffffffc020352c:	cc07ac23          	sw	zero,-808(a5) # ffffffffc02c9200 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203530:	000c3503          	ld	a0,0(s8)
ffffffffc0203534:	4585                	li	a1,1
ffffffffc0203536:	0c21                	addi	s8,s8,8
ffffffffc0203538:	993fe0ef          	jal	ra,ffffffffc0201eca <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020353c:	ff4c1ae3          	bne	s8,s4,ffffffffc0203530 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203540:	01042c03          	lw	s8,16(s0)
ffffffffc0203544:	4791                	li	a5,4
ffffffffc0203546:	50fc1b63          	bne	s8,a5,ffffffffc0203a5c <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020354a:	00007517          	auipc	a0,0x7
ffffffffc020354e:	22e50513          	addi	a0,a0,558 # ffffffffc020a778 <default_pmm_manager+0x918>
ffffffffc0203552:	c41fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203556:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203558:	000c6797          	auipc	a5,0xc6
ffffffffc020355c:	c407ae23          	sw	zero,-932(a5) # ffffffffc02c91b4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203560:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0203562:	000c6797          	auipc	a5,0xc6
ffffffffc0203566:	c5278793          	addi	a5,a5,-942 # ffffffffc02c91b4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020356a:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x88f0>
     assert(pgfault_num==1);
ffffffffc020356e:	4398                	lw	a4,0(a5)
ffffffffc0203570:	4585                	li	a1,1
ffffffffc0203572:	2701                	sext.w	a4,a4
ffffffffc0203574:	38b71863          	bne	a4,a1,ffffffffc0203904 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203578:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020357c:	4394                	lw	a3,0(a5)
ffffffffc020357e:	2681                	sext.w	a3,a3
ffffffffc0203580:	3ae69263          	bne	a3,a4,ffffffffc0203924 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203584:	6689                	lui	a3,0x2
ffffffffc0203586:	462d                	li	a2,11
ffffffffc0203588:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x78f0>
     assert(pgfault_num==2);
ffffffffc020358c:	4398                	lw	a4,0(a5)
ffffffffc020358e:	4589                	li	a1,2
ffffffffc0203590:	2701                	sext.w	a4,a4
ffffffffc0203592:	2eb71963          	bne	a4,a1,ffffffffc0203884 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203596:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020359a:	4394                	lw	a3,0(a5)
ffffffffc020359c:	2681                	sext.w	a3,a3
ffffffffc020359e:	30e69363          	bne	a3,a4,ffffffffc02038a4 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02035a2:	668d                	lui	a3,0x3
ffffffffc02035a4:	4631                	li	a2,12
ffffffffc02035a6:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x68f0>
     assert(pgfault_num==3);
ffffffffc02035aa:	4398                	lw	a4,0(a5)
ffffffffc02035ac:	458d                	li	a1,3
ffffffffc02035ae:	2701                	sext.w	a4,a4
ffffffffc02035b0:	30b71a63          	bne	a4,a1,ffffffffc02038c4 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02035b4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02035b8:	4394                	lw	a3,0(a5)
ffffffffc02035ba:	2681                	sext.w	a3,a3
ffffffffc02035bc:	32e69463          	bne	a3,a4,ffffffffc02038e4 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035c0:	6691                	lui	a3,0x4
ffffffffc02035c2:	4635                	li	a2,13
ffffffffc02035c4:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x58f0>
     assert(pgfault_num==4);
ffffffffc02035c8:	4398                	lw	a4,0(a5)
ffffffffc02035ca:	2701                	sext.w	a4,a4
ffffffffc02035cc:	37871c63          	bne	a4,s8,ffffffffc0203944 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02035d0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02035d4:	439c                	lw	a5,0(a5)
ffffffffc02035d6:	2781                	sext.w	a5,a5
ffffffffc02035d8:	38e79663          	bne	a5,a4,ffffffffc0203964 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02035dc:	481c                	lw	a5,16(s0)
ffffffffc02035de:	40079363          	bnez	a5,ffffffffc02039e4 <swap_init+0x668>
ffffffffc02035e2:	000c6797          	auipc	a5,0xc6
ffffffffc02035e6:	c6678793          	addi	a5,a5,-922 # ffffffffc02c9248 <swap_in_seq_no>
ffffffffc02035ea:	000c6717          	auipc	a4,0xc6
ffffffffc02035ee:	c8670713          	addi	a4,a4,-890 # ffffffffc02c9270 <swap_out_seq_no>
ffffffffc02035f2:	000c6617          	auipc	a2,0xc6
ffffffffc02035f6:	c7e60613          	addi	a2,a2,-898 # ffffffffc02c9270 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02035fa:	56fd                	li	a3,-1
ffffffffc02035fc:	c394                	sw	a3,0(a5)
ffffffffc02035fe:	c314                	sw	a3,0(a4)
ffffffffc0203600:	0791                	addi	a5,a5,4
ffffffffc0203602:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203604:	fef61ce3          	bne	a2,a5,ffffffffc02035fc <swap_init+0x280>
ffffffffc0203608:	000c6697          	auipc	a3,0xc6
ffffffffc020360c:	cc868693          	addi	a3,a3,-824 # ffffffffc02c92d0 <check_ptep>
ffffffffc0203610:	000c6817          	auipc	a6,0xc6
ffffffffc0203614:	c1880813          	addi	a6,a6,-1000 # ffffffffc02c9228 <check_rp>
ffffffffc0203618:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc020361a:	000c6c97          	auipc	s9,0xc6
ffffffffc020361e:	b86c8c93          	addi	s9,s9,-1146 # ffffffffc02c91a0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203622:	00009d97          	auipc	s11,0x9
ffffffffc0203626:	97ed8d93          	addi	s11,s11,-1666 # ffffffffc020bfa0 <nbase>
ffffffffc020362a:	000c6c17          	auipc	s8,0xc6
ffffffffc020362e:	bf6c0c13          	addi	s8,s8,-1034 # ffffffffc02c9220 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203632:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203636:	4601                	li	a2,0
ffffffffc0203638:	85ea                	mv	a1,s10
ffffffffc020363a:	855a                	mv	a0,s6
ffffffffc020363c:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020363e:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203640:	911fe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0203644:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203646:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203648:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020364a:	20050163          	beqz	a0,ffffffffc020384c <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020364e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203650:	0017f613          	andi	a2,a5,1
ffffffffc0203654:	1a060063          	beqz	a2,ffffffffc02037f4 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203658:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020365c:	078a                	slli	a5,a5,0x2
ffffffffc020365e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203660:	14c7fe63          	bleu	a2,a5,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203664:	000db703          	ld	a4,0(s11)
ffffffffc0203668:	000c3603          	ld	a2,0(s8)
ffffffffc020366c:	00083583          	ld	a1,0(a6)
ffffffffc0203670:	8f99                	sub	a5,a5,a4
ffffffffc0203672:	079a                	slli	a5,a5,0x6
ffffffffc0203674:	e43a                	sd	a4,8(sp)
ffffffffc0203676:	97b2                	add	a5,a5,a2
ffffffffc0203678:	14f59e63          	bne	a1,a5,ffffffffc02037d4 <swap_init+0x458>
ffffffffc020367c:	6785                	lui	a5,0x1
ffffffffc020367e:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203680:	6795                	lui	a5,0x5
ffffffffc0203682:	06a1                	addi	a3,a3,8
ffffffffc0203684:	0821                	addi	a6,a6,8
ffffffffc0203686:	fafd16e3          	bne	s10,a5,ffffffffc0203632 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020368a:	00007517          	auipc	a0,0x7
ffffffffc020368e:	19650513          	addi	a0,a0,406 # ffffffffc020a820 <default_pmm_manager+0x9c0>
ffffffffc0203692:	b01fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    int ret = sm->check_swap();
ffffffffc0203696:	000c6797          	auipc	a5,0xc6
ffffffffc020369a:	b1278793          	addi	a5,a5,-1262 # ffffffffc02c91a8 <sm>
ffffffffc020369e:	639c                	ld	a5,0(a5)
ffffffffc02036a0:	7f9c                	ld	a5,56(a5)
ffffffffc02036a2:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02036a4:	40051c63          	bnez	a0,ffffffffc0203abc <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc02036a8:	77a2                	ld	a5,40(sp)
ffffffffc02036aa:	000c6717          	auipc	a4,0xc6
ffffffffc02036ae:	b4f72b23          	sw	a5,-1194(a4) # ffffffffc02c9200 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02036b2:	67e2                	ld	a5,24(sp)
ffffffffc02036b4:	000c6717          	auipc	a4,0xc6
ffffffffc02036b8:	b2f73e23          	sd	a5,-1220(a4) # ffffffffc02c91f0 <free_area>
ffffffffc02036bc:	7782                	ld	a5,32(sp)
ffffffffc02036be:	000c6717          	auipc	a4,0xc6
ffffffffc02036c2:	b2f73d23          	sd	a5,-1222(a4) # ffffffffc02c91f8 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02036c6:	0009b503          	ld	a0,0(s3)
ffffffffc02036ca:	4585                	li	a1,1
ffffffffc02036cc:	09a1                	addi	s3,s3,8
ffffffffc02036ce:	ffcfe0ef          	jal	ra,ffffffffc0201eca <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036d2:	ff499ae3          	bne	s3,s4,ffffffffc02036c6 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02036d6:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02036da:	855e                	mv	a0,s7
ffffffffc02036dc:	361000ef          	jal	ra,ffffffffc020423c <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02036e0:	000c6797          	auipc	a5,0xc6
ffffffffc02036e4:	ab878793          	addi	a5,a5,-1352 # ffffffffc02c9198 <boot_pgdir>
ffffffffc02036e8:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02036ea:	000c6697          	auipc	a3,0xc6
ffffffffc02036ee:	c006bb23          	sd	zero,-1002(a3) # ffffffffc02c9300 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02036f2:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036f6:	6394                	ld	a3,0(a5)
ffffffffc02036f8:	068a                	slli	a3,a3,0x2
ffffffffc02036fa:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036fc:	0ce6f063          	bleu	a4,a3,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203700:	67a2                	ld	a5,8(sp)
ffffffffc0203702:	000c3503          	ld	a0,0(s8)
ffffffffc0203706:	8e9d                	sub	a3,a3,a5
ffffffffc0203708:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc020370a:	8699                	srai	a3,a3,0x6
ffffffffc020370c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020370e:	57fd                	li	a5,-1
ffffffffc0203710:	83b1                	srli	a5,a5,0xc
ffffffffc0203712:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203714:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203716:	2ee7f763          	bleu	a4,a5,ffffffffc0203a04 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc020371a:	000c6797          	auipc	a5,0xc6
ffffffffc020371e:	af678793          	addi	a5,a5,-1290 # ffffffffc02c9210 <va_pa_offset>
ffffffffc0203722:	639c                	ld	a5,0(a5)
ffffffffc0203724:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203726:	629c                	ld	a5,0(a3)
ffffffffc0203728:	078a                	slli	a5,a5,0x2
ffffffffc020372a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020372c:	08e7f863          	bleu	a4,a5,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203730:	69a2                	ld	s3,8(sp)
ffffffffc0203732:	4585                	li	a1,1
ffffffffc0203734:	413787b3          	sub	a5,a5,s3
ffffffffc0203738:	079a                	slli	a5,a5,0x6
ffffffffc020373a:	953e                	add	a0,a0,a5
ffffffffc020373c:	f8efe0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203740:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203744:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203748:	078a                	slli	a5,a5,0x2
ffffffffc020374a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020374c:	06e7f863          	bleu	a4,a5,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203750:	000c3503          	ld	a0,0(s8)
ffffffffc0203754:	413787b3          	sub	a5,a5,s3
ffffffffc0203758:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020375a:	4585                	li	a1,1
ffffffffc020375c:	953e                	add	a0,a0,a5
ffffffffc020375e:	f6cfe0ef          	jal	ra,ffffffffc0201eca <free_pages>
     pgdir[0] = 0;
ffffffffc0203762:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203766:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020376a:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020376c:	00878963          	beq	a5,s0,ffffffffc020377e <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203770:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203774:	679c                	ld	a5,8(a5)
ffffffffc0203776:	397d                	addiw	s2,s2,-1
ffffffffc0203778:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020377a:	fe879be3          	bne	a5,s0,ffffffffc0203770 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc020377e:	28091f63          	bnez	s2,ffffffffc0203a1c <swap_init+0x6a0>
     assert(total==0);
ffffffffc0203782:	2a049d63          	bnez	s1,ffffffffc0203a3c <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203786:	00007517          	auipc	a0,0x7
ffffffffc020378a:	0ea50513          	addi	a0,a0,234 # ffffffffc020a870 <default_pmm_manager+0xa10>
ffffffffc020378e:	a05fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0203792:	b92d                	j	ffffffffc02033cc <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203794:	4481                	li	s1,0
ffffffffc0203796:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203798:	4981                	li	s3,0
ffffffffc020379a:	b17d                	j	ffffffffc0203448 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc020379c:	00006697          	auipc	a3,0x6
ffffffffc02037a0:	33468693          	addi	a3,a3,820 # ffffffffc0209ad0 <commands+0x878>
ffffffffc02037a4:	00006617          	auipc	a2,0x6
ffffffffc02037a8:	f7460613          	addi	a2,a2,-140 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02037ac:	0bc00593          	li	a1,188
ffffffffc02037b0:	00007517          	auipc	a0,0x7
ffffffffc02037b4:	e5850513          	addi	a0,a0,-424 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc02037b8:	cd1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02037bc:	00006617          	auipc	a2,0x6
ffffffffc02037c0:	75460613          	addi	a2,a2,1876 # ffffffffc0209f10 <default_pmm_manager+0xb0>
ffffffffc02037c4:	06200593          	li	a1,98
ffffffffc02037c8:	00006517          	auipc	a0,0x6
ffffffffc02037cc:	71050513          	addi	a0,a0,1808 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc02037d0:	cb9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02037d4:	00007697          	auipc	a3,0x7
ffffffffc02037d8:	02468693          	addi	a3,a3,36 # ffffffffc020a7f8 <default_pmm_manager+0x998>
ffffffffc02037dc:	00006617          	auipc	a2,0x6
ffffffffc02037e0:	f3c60613          	addi	a2,a2,-196 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02037e4:	0fc00593          	li	a1,252
ffffffffc02037e8:	00007517          	auipc	a0,0x7
ffffffffc02037ec:	e2050513          	addi	a0,a0,-480 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc02037f0:	c99fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02037f4:	00007617          	auipc	a2,0x7
ffffffffc02037f8:	97460613          	addi	a2,a2,-1676 # ffffffffc020a168 <default_pmm_manager+0x308>
ffffffffc02037fc:	07400593          	li	a1,116
ffffffffc0203800:	00006517          	auipc	a0,0x6
ffffffffc0203804:	6d850513          	addi	a0,a0,1752 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0203808:	c81fc0ef          	jal	ra,ffffffffc0200488 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020380c:	00007697          	auipc	a3,0x7
ffffffffc0203810:	f2468693          	addi	a3,a3,-220 # ffffffffc020a730 <default_pmm_manager+0x8d0>
ffffffffc0203814:	00006617          	auipc	a2,0x6
ffffffffc0203818:	f0460613          	addi	a2,a2,-252 # ffffffffc0209718 <commands+0x4c0>
ffffffffc020381c:	0dd00593          	li	a1,221
ffffffffc0203820:	00007517          	auipc	a0,0x7
ffffffffc0203824:	de850513          	addi	a0,a0,-536 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203828:	c61fc0ef          	jal	ra,ffffffffc0200488 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020382c:	00007697          	auipc	a3,0x7
ffffffffc0203830:	eec68693          	addi	a3,a3,-276 # ffffffffc020a718 <default_pmm_manager+0x8b8>
ffffffffc0203834:	00006617          	auipc	a2,0x6
ffffffffc0203838:	ee460613          	addi	a2,a2,-284 # ffffffffc0209718 <commands+0x4c0>
ffffffffc020383c:	0dc00593          	li	a1,220
ffffffffc0203840:	00007517          	auipc	a0,0x7
ffffffffc0203844:	dc850513          	addi	a0,a0,-568 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203848:	c41fc0ef          	jal	ra,ffffffffc0200488 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020384c:	00007697          	auipc	a3,0x7
ffffffffc0203850:	f9468693          	addi	a3,a3,-108 # ffffffffc020a7e0 <default_pmm_manager+0x980>
ffffffffc0203854:	00006617          	auipc	a2,0x6
ffffffffc0203858:	ec460613          	addi	a2,a2,-316 # ffffffffc0209718 <commands+0x4c0>
ffffffffc020385c:	0fb00593          	li	a1,251
ffffffffc0203860:	00007517          	auipc	a0,0x7
ffffffffc0203864:	da850513          	addi	a0,a0,-600 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203868:	c21fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020386c:	00007617          	auipc	a2,0x7
ffffffffc0203870:	d7c60613          	addi	a2,a2,-644 # ffffffffc020a5e8 <default_pmm_manager+0x788>
ffffffffc0203874:	02800593          	li	a1,40
ffffffffc0203878:	00007517          	auipc	a0,0x7
ffffffffc020387c:	d9050513          	addi	a0,a0,-624 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203880:	c09fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==2);
ffffffffc0203884:	00007697          	auipc	a3,0x7
ffffffffc0203888:	f2c68693          	addi	a3,a3,-212 # ffffffffc020a7b0 <default_pmm_manager+0x950>
ffffffffc020388c:	00006617          	auipc	a2,0x6
ffffffffc0203890:	e8c60613          	addi	a2,a2,-372 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203894:	09700593          	li	a1,151
ffffffffc0203898:	00007517          	auipc	a0,0x7
ffffffffc020389c:	d7050513          	addi	a0,a0,-656 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc02038a0:	be9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==2);
ffffffffc02038a4:	00007697          	auipc	a3,0x7
ffffffffc02038a8:	f0c68693          	addi	a3,a3,-244 # ffffffffc020a7b0 <default_pmm_manager+0x950>
ffffffffc02038ac:	00006617          	auipc	a2,0x6
ffffffffc02038b0:	e6c60613          	addi	a2,a2,-404 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02038b4:	09900593          	li	a1,153
ffffffffc02038b8:	00007517          	auipc	a0,0x7
ffffffffc02038bc:	d5050513          	addi	a0,a0,-688 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc02038c0:	bc9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==3);
ffffffffc02038c4:	00007697          	auipc	a3,0x7
ffffffffc02038c8:	efc68693          	addi	a3,a3,-260 # ffffffffc020a7c0 <default_pmm_manager+0x960>
ffffffffc02038cc:	00006617          	auipc	a2,0x6
ffffffffc02038d0:	e4c60613          	addi	a2,a2,-436 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02038d4:	09b00593          	li	a1,155
ffffffffc02038d8:	00007517          	auipc	a0,0x7
ffffffffc02038dc:	d3050513          	addi	a0,a0,-720 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc02038e0:	ba9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==3);
ffffffffc02038e4:	00007697          	auipc	a3,0x7
ffffffffc02038e8:	edc68693          	addi	a3,a3,-292 # ffffffffc020a7c0 <default_pmm_manager+0x960>
ffffffffc02038ec:	00006617          	auipc	a2,0x6
ffffffffc02038f0:	e2c60613          	addi	a2,a2,-468 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02038f4:	09d00593          	li	a1,157
ffffffffc02038f8:	00007517          	auipc	a0,0x7
ffffffffc02038fc:	d1050513          	addi	a0,a0,-752 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203900:	b89fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==1);
ffffffffc0203904:	00007697          	auipc	a3,0x7
ffffffffc0203908:	e9c68693          	addi	a3,a3,-356 # ffffffffc020a7a0 <default_pmm_manager+0x940>
ffffffffc020390c:	00006617          	auipc	a2,0x6
ffffffffc0203910:	e0c60613          	addi	a2,a2,-500 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203914:	09300593          	li	a1,147
ffffffffc0203918:	00007517          	auipc	a0,0x7
ffffffffc020391c:	cf050513          	addi	a0,a0,-784 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203920:	b69fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==1);
ffffffffc0203924:	00007697          	auipc	a3,0x7
ffffffffc0203928:	e7c68693          	addi	a3,a3,-388 # ffffffffc020a7a0 <default_pmm_manager+0x940>
ffffffffc020392c:	00006617          	auipc	a2,0x6
ffffffffc0203930:	dec60613          	addi	a2,a2,-532 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203934:	09500593          	li	a1,149
ffffffffc0203938:	00007517          	auipc	a0,0x7
ffffffffc020393c:	cd050513          	addi	a0,a0,-816 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203940:	b49fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==4);
ffffffffc0203944:	00007697          	auipc	a3,0x7
ffffffffc0203948:	e8c68693          	addi	a3,a3,-372 # ffffffffc020a7d0 <default_pmm_manager+0x970>
ffffffffc020394c:	00006617          	auipc	a2,0x6
ffffffffc0203950:	dcc60613          	addi	a2,a2,-564 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203954:	09f00593          	li	a1,159
ffffffffc0203958:	00007517          	auipc	a0,0x7
ffffffffc020395c:	cb050513          	addi	a0,a0,-848 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203960:	b29fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==4);
ffffffffc0203964:	00007697          	auipc	a3,0x7
ffffffffc0203968:	e6c68693          	addi	a3,a3,-404 # ffffffffc020a7d0 <default_pmm_manager+0x970>
ffffffffc020396c:	00006617          	auipc	a2,0x6
ffffffffc0203970:	dac60613          	addi	a2,a2,-596 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203974:	0a100593          	li	a1,161
ffffffffc0203978:	00007517          	auipc	a0,0x7
ffffffffc020397c:	c9050513          	addi	a0,a0,-880 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203980:	b09fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203984:	00007697          	auipc	a3,0x7
ffffffffc0203988:	cfc68693          	addi	a3,a3,-772 # ffffffffc020a680 <default_pmm_manager+0x820>
ffffffffc020398c:	00006617          	auipc	a2,0x6
ffffffffc0203990:	d8c60613          	addi	a2,a2,-628 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203994:	0cc00593          	li	a1,204
ffffffffc0203998:	00007517          	auipc	a0,0x7
ffffffffc020399c:	c7050513          	addi	a0,a0,-912 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc02039a0:	ae9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(vma != NULL);
ffffffffc02039a4:	00007697          	auipc	a3,0x7
ffffffffc02039a8:	cec68693          	addi	a3,a3,-788 # ffffffffc020a690 <default_pmm_manager+0x830>
ffffffffc02039ac:	00006617          	auipc	a2,0x6
ffffffffc02039b0:	d6c60613          	addi	a2,a2,-660 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02039b4:	0cf00593          	li	a1,207
ffffffffc02039b8:	00007517          	auipc	a0,0x7
ffffffffc02039bc:	c5050513          	addi	a0,a0,-944 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc02039c0:	ac9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02039c4:	00007697          	auipc	a3,0x7
ffffffffc02039c8:	d1468693          	addi	a3,a3,-748 # ffffffffc020a6d8 <default_pmm_manager+0x878>
ffffffffc02039cc:	00006617          	auipc	a2,0x6
ffffffffc02039d0:	d4c60613          	addi	a2,a2,-692 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02039d4:	0d700593          	li	a1,215
ffffffffc02039d8:	00007517          	auipc	a0,0x7
ffffffffc02039dc:	c3050513          	addi	a0,a0,-976 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc02039e0:	aa9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert( nr_free == 0);         
ffffffffc02039e4:	00006697          	auipc	a3,0x6
ffffffffc02039e8:	2bc68693          	addi	a3,a3,700 # ffffffffc0209ca0 <commands+0xa48>
ffffffffc02039ec:	00006617          	auipc	a2,0x6
ffffffffc02039f0:	d2c60613          	addi	a2,a2,-724 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02039f4:	0f300593          	li	a1,243
ffffffffc02039f8:	00007517          	auipc	a0,0x7
ffffffffc02039fc:	c1050513          	addi	a0,a0,-1008 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203a00:	a89fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203a04:	00006617          	auipc	a2,0x6
ffffffffc0203a08:	4ac60613          	addi	a2,a2,1196 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0203a0c:	06900593          	li	a1,105
ffffffffc0203a10:	00006517          	auipc	a0,0x6
ffffffffc0203a14:	4c850513          	addi	a0,a0,1224 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0203a18:	a71fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(count==0);
ffffffffc0203a1c:	00007697          	auipc	a3,0x7
ffffffffc0203a20:	e3468693          	addi	a3,a3,-460 # ffffffffc020a850 <default_pmm_manager+0x9f0>
ffffffffc0203a24:	00006617          	auipc	a2,0x6
ffffffffc0203a28:	cf460613          	addi	a2,a2,-780 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203a2c:	11d00593          	li	a1,285
ffffffffc0203a30:	00007517          	auipc	a0,0x7
ffffffffc0203a34:	bd850513          	addi	a0,a0,-1064 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203a38:	a51fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(total==0);
ffffffffc0203a3c:	00007697          	auipc	a3,0x7
ffffffffc0203a40:	e2468693          	addi	a3,a3,-476 # ffffffffc020a860 <default_pmm_manager+0xa00>
ffffffffc0203a44:	00006617          	auipc	a2,0x6
ffffffffc0203a48:	cd460613          	addi	a2,a2,-812 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203a4c:	11e00593          	li	a1,286
ffffffffc0203a50:	00007517          	auipc	a0,0x7
ffffffffc0203a54:	bb850513          	addi	a0,a0,-1096 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203a58:	a31fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a5c:	00007697          	auipc	a3,0x7
ffffffffc0203a60:	cf468693          	addi	a3,a3,-780 # ffffffffc020a750 <default_pmm_manager+0x8f0>
ffffffffc0203a64:	00006617          	auipc	a2,0x6
ffffffffc0203a68:	cb460613          	addi	a2,a2,-844 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203a6c:	0ea00593          	li	a1,234
ffffffffc0203a70:	00007517          	auipc	a0,0x7
ffffffffc0203a74:	b9850513          	addi	a0,a0,-1128 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203a78:	a11fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(mm != NULL);
ffffffffc0203a7c:	00007697          	auipc	a3,0x7
ffffffffc0203a80:	bdc68693          	addi	a3,a3,-1060 # ffffffffc020a658 <default_pmm_manager+0x7f8>
ffffffffc0203a84:	00006617          	auipc	a2,0x6
ffffffffc0203a88:	c9460613          	addi	a2,a2,-876 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203a8c:	0c400593          	li	a1,196
ffffffffc0203a90:	00007517          	auipc	a0,0x7
ffffffffc0203a94:	b7850513          	addi	a0,a0,-1160 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203a98:	9f1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203a9c:	00007697          	auipc	a3,0x7
ffffffffc0203aa0:	bcc68693          	addi	a3,a3,-1076 # ffffffffc020a668 <default_pmm_manager+0x808>
ffffffffc0203aa4:	00006617          	auipc	a2,0x6
ffffffffc0203aa8:	c7460613          	addi	a2,a2,-908 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203aac:	0c700593          	li	a1,199
ffffffffc0203ab0:	00007517          	auipc	a0,0x7
ffffffffc0203ab4:	b5850513          	addi	a0,a0,-1192 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203ab8:	9d1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(ret==0);
ffffffffc0203abc:	00007697          	auipc	a3,0x7
ffffffffc0203ac0:	d8c68693          	addi	a3,a3,-628 # ffffffffc020a848 <default_pmm_manager+0x9e8>
ffffffffc0203ac4:	00006617          	auipc	a2,0x6
ffffffffc0203ac8:	c5460613          	addi	a2,a2,-940 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203acc:	10200593          	li	a1,258
ffffffffc0203ad0:	00007517          	auipc	a0,0x7
ffffffffc0203ad4:	b3850513          	addi	a0,a0,-1224 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203ad8:	9b1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203adc:	00006697          	auipc	a3,0x6
ffffffffc0203ae0:	01c68693          	addi	a3,a3,28 # ffffffffc0209af8 <commands+0x8a0>
ffffffffc0203ae4:	00006617          	auipc	a2,0x6
ffffffffc0203ae8:	c3460613          	addi	a2,a2,-972 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203aec:	0bf00593          	li	a1,191
ffffffffc0203af0:	00007517          	auipc	a0,0x7
ffffffffc0203af4:	b1850513          	addi	a0,a0,-1256 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203af8:	991fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203afc <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203afc:	000c5797          	auipc	a5,0xc5
ffffffffc0203b00:	6ac78793          	addi	a5,a5,1708 # ffffffffc02c91a8 <sm>
ffffffffc0203b04:	639c                	ld	a5,0(a5)
ffffffffc0203b06:	0107b303          	ld	t1,16(a5)
ffffffffc0203b0a:	8302                	jr	t1

ffffffffc0203b0c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203b0c:	000c5797          	auipc	a5,0xc5
ffffffffc0203b10:	69c78793          	addi	a5,a5,1692 # ffffffffc02c91a8 <sm>
ffffffffc0203b14:	639c                	ld	a5,0(a5)
ffffffffc0203b16:	0207b303          	ld	t1,32(a5)
ffffffffc0203b1a:	8302                	jr	t1

ffffffffc0203b1c <swap_out>:
{
ffffffffc0203b1c:	711d                	addi	sp,sp,-96
ffffffffc0203b1e:	ec86                	sd	ra,88(sp)
ffffffffc0203b20:	e8a2                	sd	s0,80(sp)
ffffffffc0203b22:	e4a6                	sd	s1,72(sp)
ffffffffc0203b24:	e0ca                	sd	s2,64(sp)
ffffffffc0203b26:	fc4e                	sd	s3,56(sp)
ffffffffc0203b28:	f852                	sd	s4,48(sp)
ffffffffc0203b2a:	f456                	sd	s5,40(sp)
ffffffffc0203b2c:	f05a                	sd	s6,32(sp)
ffffffffc0203b2e:	ec5e                	sd	s7,24(sp)
ffffffffc0203b30:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203b32:	cde9                	beqz	a1,ffffffffc0203c0c <swap_out+0xf0>
ffffffffc0203b34:	8ab2                	mv	s5,a2
ffffffffc0203b36:	892a                	mv	s2,a0
ffffffffc0203b38:	8a2e                	mv	s4,a1
ffffffffc0203b3a:	4401                	li	s0,0
ffffffffc0203b3c:	000c5997          	auipc	s3,0xc5
ffffffffc0203b40:	66c98993          	addi	s3,s3,1644 # ffffffffc02c91a8 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b44:	00007b17          	auipc	s6,0x7
ffffffffc0203b48:	dacb0b13          	addi	s6,s6,-596 # ffffffffc020a8f0 <default_pmm_manager+0xa90>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b4c:	00007b97          	auipc	s7,0x7
ffffffffc0203b50:	d8cb8b93          	addi	s7,s7,-628 # ffffffffc020a8d8 <default_pmm_manager+0xa78>
ffffffffc0203b54:	a825                	j	ffffffffc0203b8c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b56:	67a2                	ld	a5,8(sp)
ffffffffc0203b58:	8626                	mv	a2,s1
ffffffffc0203b5a:	85a2                	mv	a1,s0
ffffffffc0203b5c:	7f94                	ld	a3,56(a5)
ffffffffc0203b5e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203b60:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b62:	82b1                	srli	a3,a3,0xc
ffffffffc0203b64:	0685                	addi	a3,a3,1
ffffffffc0203b66:	e2cfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b6a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203b6c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b6e:	7d1c                	ld	a5,56(a0)
ffffffffc0203b70:	83b1                	srli	a5,a5,0xc
ffffffffc0203b72:	0785                	addi	a5,a5,1
ffffffffc0203b74:	07a2                	slli	a5,a5,0x8
ffffffffc0203b76:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203b7a:	b50fe0ef          	jal	ra,ffffffffc0201eca <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203b7e:	01893503          	ld	a0,24(s2)
ffffffffc0203b82:	85a6                	mv	a1,s1
ffffffffc0203b84:	f5eff0ef          	jal	ra,ffffffffc02032e2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203b88:	048a0d63          	beq	s4,s0,ffffffffc0203be2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203b8c:	0009b783          	ld	a5,0(s3)
ffffffffc0203b90:	8656                	mv	a2,s5
ffffffffc0203b92:	002c                	addi	a1,sp,8
ffffffffc0203b94:	7b9c                	ld	a5,48(a5)
ffffffffc0203b96:	854a                	mv	a0,s2
ffffffffc0203b98:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203b9a:	e12d                	bnez	a0,ffffffffc0203bfc <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203b9c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b9e:	01893503          	ld	a0,24(s2)
ffffffffc0203ba2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203ba4:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203ba6:	85a6                	mv	a1,s1
ffffffffc0203ba8:	ba8fe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bac:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bae:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bb0:	8b85                	andi	a5,a5,1
ffffffffc0203bb2:	cfb9                	beqz	a5,ffffffffc0203c10 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203bb4:	65a2                	ld	a1,8(sp)
ffffffffc0203bb6:	7d9c                	ld	a5,56(a1)
ffffffffc0203bb8:	83b1                	srli	a5,a5,0xc
ffffffffc0203bba:	00178513          	addi	a0,a5,1
ffffffffc0203bbe:	0522                	slli	a0,a0,0x8
ffffffffc0203bc0:	022010ef          	jal	ra,ffffffffc0204be2 <swapfs_write>
ffffffffc0203bc4:	d949                	beqz	a0,ffffffffc0203b56 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203bc6:	855e                	mv	a0,s7
ffffffffc0203bc8:	dcafc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bcc:	0009b783          	ld	a5,0(s3)
ffffffffc0203bd0:	6622                	ld	a2,8(sp)
ffffffffc0203bd2:	4681                	li	a3,0
ffffffffc0203bd4:	739c                	ld	a5,32(a5)
ffffffffc0203bd6:	85a6                	mv	a1,s1
ffffffffc0203bd8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203bda:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bdc:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203bde:	fa8a17e3          	bne	s4,s0,ffffffffc0203b8c <swap_out+0x70>
}
ffffffffc0203be2:	8522                	mv	a0,s0
ffffffffc0203be4:	60e6                	ld	ra,88(sp)
ffffffffc0203be6:	6446                	ld	s0,80(sp)
ffffffffc0203be8:	64a6                	ld	s1,72(sp)
ffffffffc0203bea:	6906                	ld	s2,64(sp)
ffffffffc0203bec:	79e2                	ld	s3,56(sp)
ffffffffc0203bee:	7a42                	ld	s4,48(sp)
ffffffffc0203bf0:	7aa2                	ld	s5,40(sp)
ffffffffc0203bf2:	7b02                	ld	s6,32(sp)
ffffffffc0203bf4:	6be2                	ld	s7,24(sp)
ffffffffc0203bf6:	6c42                	ld	s8,16(sp)
ffffffffc0203bf8:	6125                	addi	sp,sp,96
ffffffffc0203bfa:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203bfc:	85a2                	mv	a1,s0
ffffffffc0203bfe:	00007517          	auipc	a0,0x7
ffffffffc0203c02:	c9250513          	addi	a0,a0,-878 # ffffffffc020a890 <default_pmm_manager+0xa30>
ffffffffc0203c06:	d8cfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                  break;
ffffffffc0203c0a:	bfe1                	j	ffffffffc0203be2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203c0c:	4401                	li	s0,0
ffffffffc0203c0e:	bfd1                	j	ffffffffc0203be2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c10:	00007697          	auipc	a3,0x7
ffffffffc0203c14:	cb068693          	addi	a3,a3,-848 # ffffffffc020a8c0 <default_pmm_manager+0xa60>
ffffffffc0203c18:	00006617          	auipc	a2,0x6
ffffffffc0203c1c:	b0060613          	addi	a2,a2,-1280 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203c20:	06800593          	li	a1,104
ffffffffc0203c24:	00007517          	auipc	a0,0x7
ffffffffc0203c28:	9e450513          	addi	a0,a0,-1564 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203c2c:	85dfc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203c30 <swap_in>:
{
ffffffffc0203c30:	7179                	addi	sp,sp,-48
ffffffffc0203c32:	e84a                	sd	s2,16(sp)
ffffffffc0203c34:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203c36:	4505                	li	a0,1
{
ffffffffc0203c38:	ec26                	sd	s1,24(sp)
ffffffffc0203c3a:	e44e                	sd	s3,8(sp)
ffffffffc0203c3c:	f406                	sd	ra,40(sp)
ffffffffc0203c3e:	f022                	sd	s0,32(sp)
ffffffffc0203c40:	84ae                	mv	s1,a1
ffffffffc0203c42:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203c44:	9fefe0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203c48:	c129                	beqz	a0,ffffffffc0203c8a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203c4a:	842a                	mv	s0,a0
ffffffffc0203c4c:	01893503          	ld	a0,24(s2)
ffffffffc0203c50:	4601                	li	a2,0
ffffffffc0203c52:	85a6                	mv	a1,s1
ffffffffc0203c54:	afcfe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0203c58:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203c5a:	6108                	ld	a0,0(a0)
ffffffffc0203c5c:	85a2                	mv	a1,s0
ffffffffc0203c5e:	6ed000ef          	jal	ra,ffffffffc0204b4a <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203c62:	00093583          	ld	a1,0(s2)
ffffffffc0203c66:	8626                	mv	a2,s1
ffffffffc0203c68:	00007517          	auipc	a0,0x7
ffffffffc0203c6c:	94050513          	addi	a0,a0,-1728 # ffffffffc020a5a8 <default_pmm_manager+0x748>
ffffffffc0203c70:	81a1                	srli	a1,a1,0x8
ffffffffc0203c72:	d20fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0203c76:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203c78:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203c7c:	7402                	ld	s0,32(sp)
ffffffffc0203c7e:	64e2                	ld	s1,24(sp)
ffffffffc0203c80:	6942                	ld	s2,16(sp)
ffffffffc0203c82:	69a2                	ld	s3,8(sp)
ffffffffc0203c84:	4501                	li	a0,0
ffffffffc0203c86:	6145                	addi	sp,sp,48
ffffffffc0203c88:	8082                	ret
     assert(result!=NULL);
ffffffffc0203c8a:	00007697          	auipc	a3,0x7
ffffffffc0203c8e:	90e68693          	addi	a3,a3,-1778 # ffffffffc020a598 <default_pmm_manager+0x738>
ffffffffc0203c92:	00006617          	auipc	a2,0x6
ffffffffc0203c96:	a8660613          	addi	a2,a2,-1402 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203c9a:	07e00593          	li	a1,126
ffffffffc0203c9e:	00007517          	auipc	a0,0x7
ffffffffc0203ca2:	96a50513          	addi	a0,a0,-1686 # ffffffffc020a608 <default_pmm_manager+0x7a8>
ffffffffc0203ca6:	fe2fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203caa <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203caa:	000c5797          	auipc	a5,0xc5
ffffffffc0203cae:	64678793          	addi	a5,a5,1606 # ffffffffc02c92f0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
ffffffffc0203cb2:	f51c                	sd	a5,40(a0)
ffffffffc0203cb4:	e79c                	sd	a5,8(a5)
ffffffffc0203cb6:	e39c                	sd	a5,0(a5)
    // cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
}
ffffffffc0203cb8:	4501                	li	a0,0
ffffffffc0203cba:	8082                	ret

ffffffffc0203cbc <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203cbc:	4501                	li	a0,0
ffffffffc0203cbe:	8082                	ret

ffffffffc0203cc0 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203cc0:	4501                	li	a0,0
ffffffffc0203cc2:	8082                	ret

ffffffffc0203cc4 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{
    return 0;
}
ffffffffc0203cc4:	4501                	li	a0,0
ffffffffc0203cc6:	8082                	ret

ffffffffc0203cc8 <_fifo_check_swap>:
{
ffffffffc0203cc8:	711d                	addi	sp,sp,-96
ffffffffc0203cca:	fc4e                	sd	s3,56(sp)
ffffffffc0203ccc:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cce:	00007517          	auipc	a0,0x7
ffffffffc0203cd2:	c6250513          	addi	a0,a0,-926 # ffffffffc020a930 <default_pmm_manager+0xad0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203cd6:	698d                	lui	s3,0x3
ffffffffc0203cd8:	4a31                	li	s4,12
{
ffffffffc0203cda:	e8a2                	sd	s0,80(sp)
ffffffffc0203cdc:	e4a6                	sd	s1,72(sp)
ffffffffc0203cde:	ec86                	sd	ra,88(sp)
ffffffffc0203ce0:	e0ca                	sd	s2,64(sp)
ffffffffc0203ce2:	f456                	sd	s5,40(sp)
ffffffffc0203ce4:	f05a                	sd	s6,32(sp)
ffffffffc0203ce6:	ec5e                	sd	s7,24(sp)
ffffffffc0203ce8:	e862                	sd	s8,16(sp)
ffffffffc0203cea:	e466                	sd	s9,8(sp)
    assert(pgfault_num == 4);
ffffffffc0203cec:	000c5417          	auipc	s0,0xc5
ffffffffc0203cf0:	4c840413          	addi	s0,s0,1224 # ffffffffc02c91b4 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cf4:	c9efc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203cf8:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x68f0>
    assert(pgfault_num == 4);
ffffffffc0203cfc:	4004                	lw	s1,0(s0)
ffffffffc0203cfe:	4791                	li	a5,4
ffffffffc0203d00:	2481                	sext.w	s1,s1
ffffffffc0203d02:	14f49963          	bne	s1,a5,ffffffffc0203e54 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d06:	00007517          	auipc	a0,0x7
ffffffffc0203d0a:	c8250513          	addi	a0,a0,-894 # ffffffffc020a988 <default_pmm_manager+0xb28>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d0e:	6a85                	lui	s5,0x1
ffffffffc0203d10:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d12:	c80fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d16:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x88f0>
    assert(pgfault_num == 4);
ffffffffc0203d1a:	00042903          	lw	s2,0(s0)
ffffffffc0203d1e:	2901                	sext.w	s2,s2
ffffffffc0203d20:	2a991a63          	bne	s2,s1,ffffffffc0203fd4 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d24:	00007517          	auipc	a0,0x7
ffffffffc0203d28:	c8c50513          	addi	a0,a0,-884 # ffffffffc020a9b0 <default_pmm_manager+0xb50>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d2c:	6b91                	lui	s7,0x4
ffffffffc0203d2e:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d30:	c62fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d34:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x58f0>
    assert(pgfault_num == 4);
ffffffffc0203d38:	4004                	lw	s1,0(s0)
ffffffffc0203d3a:	2481                	sext.w	s1,s1
ffffffffc0203d3c:	27249c63          	bne	s1,s2,ffffffffc0203fb4 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d40:	00007517          	auipc	a0,0x7
ffffffffc0203d44:	c9850513          	addi	a0,a0,-872 # ffffffffc020a9d8 <default_pmm_manager+0xb78>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d48:	6909                	lui	s2,0x2
ffffffffc0203d4a:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d4c:	c46fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d50:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x78f0>
    assert(pgfault_num == 4);
ffffffffc0203d54:	401c                	lw	a5,0(s0)
ffffffffc0203d56:	2781                	sext.w	a5,a5
ffffffffc0203d58:	22979e63          	bne	a5,s1,ffffffffc0203f94 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d5c:	00007517          	auipc	a0,0x7
ffffffffc0203d60:	ca450513          	addi	a0,a0,-860 # ffffffffc020aa00 <default_pmm_manager+0xba0>
ffffffffc0203d64:	c2efc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d68:	6795                	lui	a5,0x5
ffffffffc0203d6a:	4739                	li	a4,14
ffffffffc0203d6c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x48f0>
    assert(pgfault_num == 5);
ffffffffc0203d70:	4004                	lw	s1,0(s0)
ffffffffc0203d72:	4795                	li	a5,5
ffffffffc0203d74:	2481                	sext.w	s1,s1
ffffffffc0203d76:	1ef49f63          	bne	s1,a5,ffffffffc0203f74 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d7a:	00007517          	auipc	a0,0x7
ffffffffc0203d7e:	c5e50513          	addi	a0,a0,-930 # ffffffffc020a9d8 <default_pmm_manager+0xb78>
ffffffffc0203d82:	c10fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d86:	01990023          	sb	s9,0(s2)
    assert(pgfault_num == 5);
ffffffffc0203d8a:	401c                	lw	a5,0(s0)
ffffffffc0203d8c:	2781                	sext.w	a5,a5
ffffffffc0203d8e:	1c979363          	bne	a5,s1,ffffffffc0203f54 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d92:	00007517          	auipc	a0,0x7
ffffffffc0203d96:	bf650513          	addi	a0,a0,-1034 # ffffffffc020a988 <default_pmm_manager+0xb28>
ffffffffc0203d9a:	bf8fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d9e:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num == 6);
ffffffffc0203da2:	401c                	lw	a5,0(s0)
ffffffffc0203da4:	4719                	li	a4,6
ffffffffc0203da6:	2781                	sext.w	a5,a5
ffffffffc0203da8:	18e79663          	bne	a5,a4,ffffffffc0203f34 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dac:	00007517          	auipc	a0,0x7
ffffffffc0203db0:	c2c50513          	addi	a0,a0,-980 # ffffffffc020a9d8 <default_pmm_manager+0xb78>
ffffffffc0203db4:	bdefc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203db8:	01990023          	sb	s9,0(s2)
    assert(pgfault_num == 7);
ffffffffc0203dbc:	401c                	lw	a5,0(s0)
ffffffffc0203dbe:	471d                	li	a4,7
ffffffffc0203dc0:	2781                	sext.w	a5,a5
ffffffffc0203dc2:	14e79963          	bne	a5,a4,ffffffffc0203f14 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203dc6:	00007517          	auipc	a0,0x7
ffffffffc0203dca:	b6a50513          	addi	a0,a0,-1174 # ffffffffc020a930 <default_pmm_manager+0xad0>
ffffffffc0203dce:	bc4fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203dd2:	01498023          	sb	s4,0(s3)
    assert(pgfault_num == 8);
ffffffffc0203dd6:	401c                	lw	a5,0(s0)
ffffffffc0203dd8:	4721                	li	a4,8
ffffffffc0203dda:	2781                	sext.w	a5,a5
ffffffffc0203ddc:	10e79c63          	bne	a5,a4,ffffffffc0203ef4 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203de0:	00007517          	auipc	a0,0x7
ffffffffc0203de4:	bd050513          	addi	a0,a0,-1072 # ffffffffc020a9b0 <default_pmm_manager+0xb50>
ffffffffc0203de8:	baafc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203dec:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num == 9);
ffffffffc0203df0:	401c                	lw	a5,0(s0)
ffffffffc0203df2:	4725                	li	a4,9
ffffffffc0203df4:	2781                	sext.w	a5,a5
ffffffffc0203df6:	0ce79f63          	bne	a5,a4,ffffffffc0203ed4 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203dfa:	00007517          	auipc	a0,0x7
ffffffffc0203dfe:	c0650513          	addi	a0,a0,-1018 # ffffffffc020aa00 <default_pmm_manager+0xba0>
ffffffffc0203e02:	b90fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e06:	6795                	lui	a5,0x5
ffffffffc0203e08:	4739                	li	a4,14
ffffffffc0203e0a:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x48f0>
    assert(pgfault_num == 10);
ffffffffc0203e0e:	4004                	lw	s1,0(s0)
ffffffffc0203e10:	47a9                	li	a5,10
ffffffffc0203e12:	2481                	sext.w	s1,s1
ffffffffc0203e14:	0af49063          	bne	s1,a5,ffffffffc0203eb4 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e18:	00007517          	auipc	a0,0x7
ffffffffc0203e1c:	b7050513          	addi	a0,a0,-1168 # ffffffffc020a988 <default_pmm_manager+0xb28>
ffffffffc0203e20:	b72fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e24:	6785                	lui	a5,0x1
ffffffffc0203e26:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x88f0>
ffffffffc0203e2a:	06979563          	bne	a5,s1,ffffffffc0203e94 <_fifo_check_swap+0x1cc>
    assert(pgfault_num == 11);
ffffffffc0203e2e:	401c                	lw	a5,0(s0)
ffffffffc0203e30:	472d                	li	a4,11
ffffffffc0203e32:	2781                	sext.w	a5,a5
ffffffffc0203e34:	04e79063          	bne	a5,a4,ffffffffc0203e74 <_fifo_check_swap+0x1ac>
}
ffffffffc0203e38:	60e6                	ld	ra,88(sp)
ffffffffc0203e3a:	6446                	ld	s0,80(sp)
ffffffffc0203e3c:	64a6                	ld	s1,72(sp)
ffffffffc0203e3e:	6906                	ld	s2,64(sp)
ffffffffc0203e40:	79e2                	ld	s3,56(sp)
ffffffffc0203e42:	7a42                	ld	s4,48(sp)
ffffffffc0203e44:	7aa2                	ld	s5,40(sp)
ffffffffc0203e46:	7b02                	ld	s6,32(sp)
ffffffffc0203e48:	6be2                	ld	s7,24(sp)
ffffffffc0203e4a:	6c42                	ld	s8,16(sp)
ffffffffc0203e4c:	6ca2                	ld	s9,8(sp)
ffffffffc0203e4e:	4501                	li	a0,0
ffffffffc0203e50:	6125                	addi	sp,sp,96
ffffffffc0203e52:	8082                	ret
    assert(pgfault_num == 4);
ffffffffc0203e54:	00007697          	auipc	a3,0x7
ffffffffc0203e58:	b0468693          	addi	a3,a3,-1276 # ffffffffc020a958 <default_pmm_manager+0xaf8>
ffffffffc0203e5c:	00006617          	auipc	a2,0x6
ffffffffc0203e60:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203e64:	05200593          	li	a1,82
ffffffffc0203e68:	00007517          	auipc	a0,0x7
ffffffffc0203e6c:	b0850513          	addi	a0,a0,-1272 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0203e70:	e18fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num == 11);
ffffffffc0203e74:	00007697          	auipc	a3,0x7
ffffffffc0203e78:	c6c68693          	addi	a3,a3,-916 # ffffffffc020aae0 <default_pmm_manager+0xc80>
ffffffffc0203e7c:	00006617          	auipc	a2,0x6
ffffffffc0203e80:	89c60613          	addi	a2,a2,-1892 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203e84:	07400593          	li	a1,116
ffffffffc0203e88:	00007517          	auipc	a0,0x7
ffffffffc0203e8c:	ae850513          	addi	a0,a0,-1304 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0203e90:	df8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e94:	00007697          	auipc	a3,0x7
ffffffffc0203e98:	c2468693          	addi	a3,a3,-988 # ffffffffc020aab8 <default_pmm_manager+0xc58>
ffffffffc0203e9c:	00006617          	auipc	a2,0x6
ffffffffc0203ea0:	87c60613          	addi	a2,a2,-1924 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203ea4:	07200593          	li	a1,114
ffffffffc0203ea8:	00007517          	auipc	a0,0x7
ffffffffc0203eac:	ac850513          	addi	a0,a0,-1336 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0203eb0:	dd8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num == 10);
ffffffffc0203eb4:	00007697          	auipc	a3,0x7
ffffffffc0203eb8:	bec68693          	addi	a3,a3,-1044 # ffffffffc020aaa0 <default_pmm_manager+0xc40>
ffffffffc0203ebc:	00006617          	auipc	a2,0x6
ffffffffc0203ec0:	85c60613          	addi	a2,a2,-1956 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203ec4:	07000593          	li	a1,112
ffffffffc0203ec8:	00007517          	auipc	a0,0x7
ffffffffc0203ecc:	aa850513          	addi	a0,a0,-1368 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0203ed0:	db8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num == 9);
ffffffffc0203ed4:	00007697          	auipc	a3,0x7
ffffffffc0203ed8:	bb468693          	addi	a3,a3,-1100 # ffffffffc020aa88 <default_pmm_manager+0xc28>
ffffffffc0203edc:	00006617          	auipc	a2,0x6
ffffffffc0203ee0:	83c60613          	addi	a2,a2,-1988 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203ee4:	06d00593          	li	a1,109
ffffffffc0203ee8:	00007517          	auipc	a0,0x7
ffffffffc0203eec:	a8850513          	addi	a0,a0,-1400 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0203ef0:	d98fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num == 8);
ffffffffc0203ef4:	00007697          	auipc	a3,0x7
ffffffffc0203ef8:	b7c68693          	addi	a3,a3,-1156 # ffffffffc020aa70 <default_pmm_manager+0xc10>
ffffffffc0203efc:	00006617          	auipc	a2,0x6
ffffffffc0203f00:	81c60613          	addi	a2,a2,-2020 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203f04:	06a00593          	li	a1,106
ffffffffc0203f08:	00007517          	auipc	a0,0x7
ffffffffc0203f0c:	a6850513          	addi	a0,a0,-1432 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0203f10:	d78fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num == 7);
ffffffffc0203f14:	00007697          	auipc	a3,0x7
ffffffffc0203f18:	b4468693          	addi	a3,a3,-1212 # ffffffffc020aa58 <default_pmm_manager+0xbf8>
ffffffffc0203f1c:	00005617          	auipc	a2,0x5
ffffffffc0203f20:	7fc60613          	addi	a2,a2,2044 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203f24:	06700593          	li	a1,103
ffffffffc0203f28:	00007517          	auipc	a0,0x7
ffffffffc0203f2c:	a4850513          	addi	a0,a0,-1464 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0203f30:	d58fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num == 6);
ffffffffc0203f34:	00007697          	auipc	a3,0x7
ffffffffc0203f38:	b0c68693          	addi	a3,a3,-1268 # ffffffffc020aa40 <default_pmm_manager+0xbe0>
ffffffffc0203f3c:	00005617          	auipc	a2,0x5
ffffffffc0203f40:	7dc60613          	addi	a2,a2,2012 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203f44:	06400593          	li	a1,100
ffffffffc0203f48:	00007517          	auipc	a0,0x7
ffffffffc0203f4c:	a2850513          	addi	a0,a0,-1496 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0203f50:	d38fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num == 5);
ffffffffc0203f54:	00007697          	auipc	a3,0x7
ffffffffc0203f58:	ad468693          	addi	a3,a3,-1324 # ffffffffc020aa28 <default_pmm_manager+0xbc8>
ffffffffc0203f5c:	00005617          	auipc	a2,0x5
ffffffffc0203f60:	7bc60613          	addi	a2,a2,1980 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203f64:	06100593          	li	a1,97
ffffffffc0203f68:	00007517          	auipc	a0,0x7
ffffffffc0203f6c:	a0850513          	addi	a0,a0,-1528 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0203f70:	d18fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num == 5);
ffffffffc0203f74:	00007697          	auipc	a3,0x7
ffffffffc0203f78:	ab468693          	addi	a3,a3,-1356 # ffffffffc020aa28 <default_pmm_manager+0xbc8>
ffffffffc0203f7c:	00005617          	auipc	a2,0x5
ffffffffc0203f80:	79c60613          	addi	a2,a2,1948 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203f84:	05e00593          	li	a1,94
ffffffffc0203f88:	00007517          	auipc	a0,0x7
ffffffffc0203f8c:	9e850513          	addi	a0,a0,-1560 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0203f90:	cf8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num == 4);
ffffffffc0203f94:	00007697          	auipc	a3,0x7
ffffffffc0203f98:	9c468693          	addi	a3,a3,-1596 # ffffffffc020a958 <default_pmm_manager+0xaf8>
ffffffffc0203f9c:	00005617          	auipc	a2,0x5
ffffffffc0203fa0:	77c60613          	addi	a2,a2,1916 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203fa4:	05b00593          	li	a1,91
ffffffffc0203fa8:	00007517          	auipc	a0,0x7
ffffffffc0203fac:	9c850513          	addi	a0,a0,-1592 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0203fb0:	cd8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num == 4);
ffffffffc0203fb4:	00007697          	auipc	a3,0x7
ffffffffc0203fb8:	9a468693          	addi	a3,a3,-1628 # ffffffffc020a958 <default_pmm_manager+0xaf8>
ffffffffc0203fbc:	00005617          	auipc	a2,0x5
ffffffffc0203fc0:	75c60613          	addi	a2,a2,1884 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203fc4:	05800593          	li	a1,88
ffffffffc0203fc8:	00007517          	auipc	a0,0x7
ffffffffc0203fcc:	9a850513          	addi	a0,a0,-1624 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0203fd0:	cb8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num == 4);
ffffffffc0203fd4:	00007697          	auipc	a3,0x7
ffffffffc0203fd8:	98468693          	addi	a3,a3,-1660 # ffffffffc020a958 <default_pmm_manager+0xaf8>
ffffffffc0203fdc:	00005617          	auipc	a2,0x5
ffffffffc0203fe0:	73c60613          	addi	a2,a2,1852 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0203fe4:	05500593          	li	a1,85
ffffffffc0203fe8:	00007517          	auipc	a0,0x7
ffffffffc0203fec:	98850513          	addi	a0,a0,-1656 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0203ff0:	c98fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203ff4 <_fifo_swap_out_victim>:
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc0203ff4:	751c                	ld	a5,40(a0)
{
ffffffffc0203ff6:	1141                	addi	sp,sp,-16
ffffffffc0203ff8:	e406                	sd	ra,8(sp)
    assert(head != NULL);
ffffffffc0203ffa:	cf91                	beqz	a5,ffffffffc0204016 <_fifo_swap_out_victim+0x22>
    assert(in_tick == 0);
ffffffffc0203ffc:	ee0d                	bnez	a2,ffffffffc0204036 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203ffe:	679c                	ld	a5,8(a5)
}
ffffffffc0204000:	60a2                	ld	ra,8(sp)
ffffffffc0204002:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0204004:	6394                	ld	a3,0(a5)
ffffffffc0204006:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0204008:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc020400c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020400e:	e314                	sd	a3,0(a4)
ffffffffc0204010:	e19c                	sd	a5,0(a1)
}
ffffffffc0204012:	0141                	addi	sp,sp,16
ffffffffc0204014:	8082                	ret
    assert(head != NULL);
ffffffffc0204016:	00007697          	auipc	a3,0x7
ffffffffc020401a:	b0268693          	addi	a3,a3,-1278 # ffffffffc020ab18 <default_pmm_manager+0xcb8>
ffffffffc020401e:	00005617          	auipc	a2,0x5
ffffffffc0204022:	6fa60613          	addi	a2,a2,1786 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204026:	04100593          	li	a1,65
ffffffffc020402a:	00007517          	auipc	a0,0x7
ffffffffc020402e:	94650513          	addi	a0,a0,-1722 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0204032:	c56fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(in_tick == 0);
ffffffffc0204036:	00007697          	auipc	a3,0x7
ffffffffc020403a:	af268693          	addi	a3,a3,-1294 # ffffffffc020ab28 <default_pmm_manager+0xcc8>
ffffffffc020403e:	00005617          	auipc	a2,0x5
ffffffffc0204042:	6da60613          	addi	a2,a2,1754 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204046:	04200593          	li	a1,66
ffffffffc020404a:	00007517          	auipc	a0,0x7
ffffffffc020404e:	92650513          	addi	a0,a0,-1754 # ffffffffc020a970 <default_pmm_manager+0xb10>
ffffffffc0204052:	c36fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204056 <_fifo_map_swappable>:
    list_entry_t *entry = &(page->pra_page_link);
ffffffffc0204056:	02860713          	addi	a4,a2,40
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc020405a:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020405c:	cb09                	beqz	a4,ffffffffc020406e <_fifo_map_swappable+0x18>
ffffffffc020405e:	cb81                	beqz	a5,ffffffffc020406e <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204060:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204062:	e398                	sd	a4,0(a5)
}
ffffffffc0204064:	4501                	li	a0,0
ffffffffc0204066:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0204068:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020406a:	f614                	sd	a3,40(a2)
ffffffffc020406c:	8082                	ret
{
ffffffffc020406e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204070:	00007697          	auipc	a3,0x7
ffffffffc0204074:	a8868693          	addi	a3,a3,-1400 # ffffffffc020aaf8 <default_pmm_manager+0xc98>
ffffffffc0204078:	00005617          	auipc	a2,0x5
ffffffffc020407c:	6a060613          	addi	a2,a2,1696 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204080:	03200593          	li	a1,50
ffffffffc0204084:	00007517          	auipc	a0,0x7
ffffffffc0204088:	8ec50513          	addi	a0,a0,-1812 # ffffffffc020a970 <default_pmm_manager+0xb10>
{
ffffffffc020408c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020408e:	bfafc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204092 <check_vma_overlap.isra.0.part.1>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0204092:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0204094:	00007697          	auipc	a3,0x7
ffffffffc0204098:	abc68693          	addi	a3,a3,-1348 # ffffffffc020ab50 <default_pmm_manager+0xcf0>
ffffffffc020409c:	00005617          	auipc	a2,0x5
ffffffffc02040a0:	67c60613          	addi	a2,a2,1660 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02040a4:	07900593          	li	a1,121
ffffffffc02040a8:	00007517          	auipc	a0,0x7
ffffffffc02040ac:	ac850513          	addi	a0,a0,-1336 # ffffffffc020ab70 <default_pmm_manager+0xd10>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02040b0:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02040b2:	bd6fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02040b6 <mm_create>:
{
ffffffffc02040b6:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040b8:	04000513          	li	a0,64
{
ffffffffc02040bc:	e022                	sd	s0,0(sp)
ffffffffc02040be:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040c0:	b87fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc02040c4:	842a                	mv	s0,a0
    if (mm != NULL)
ffffffffc02040c6:	c515                	beqz	a0,ffffffffc02040f2 <mm_create+0x3c>
        if (swap_init_ok)
ffffffffc02040c8:	000c5797          	auipc	a5,0xc5
ffffffffc02040cc:	0e878793          	addi	a5,a5,232 # ffffffffc02c91b0 <swap_init_ok>
ffffffffc02040d0:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02040d2:	e408                	sd	a0,8(s0)
ffffffffc02040d4:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02040d6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02040da:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02040de:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc02040e2:	2781                	sext.w	a5,a5
ffffffffc02040e4:	ef81                	bnez	a5,ffffffffc02040fc <mm_create+0x46>
            mm->sm_priv = NULL;
ffffffffc02040e6:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02040ea:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02040ee:	02043c23          	sd	zero,56(s0)
}
ffffffffc02040f2:	8522                	mv	a0,s0
ffffffffc02040f4:	60a2                	ld	ra,8(sp)
ffffffffc02040f6:	6402                	ld	s0,0(sp)
ffffffffc02040f8:	0141                	addi	sp,sp,16
ffffffffc02040fa:	8082                	ret
            swap_init_mm(mm);
ffffffffc02040fc:	a01ff0ef          	jal	ra,ffffffffc0203afc <swap_init_mm>
ffffffffc0204100:	b7ed                	j	ffffffffc02040ea <mm_create+0x34>

ffffffffc0204102 <vma_create>:
{
ffffffffc0204102:	1101                	addi	sp,sp,-32
ffffffffc0204104:	e04a                	sd	s2,0(sp)
ffffffffc0204106:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204108:	03000513          	li	a0,48
{
ffffffffc020410c:	e822                	sd	s0,16(sp)
ffffffffc020410e:	e426                	sd	s1,8(sp)
ffffffffc0204110:	ec06                	sd	ra,24(sp)
ffffffffc0204112:	84ae                	mv	s1,a1
ffffffffc0204114:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204116:	b31fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
    if (vma != NULL)
ffffffffc020411a:	c509                	beqz	a0,ffffffffc0204124 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020411c:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204120:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204122:	cd00                	sw	s0,24(a0)
}
ffffffffc0204124:	60e2                	ld	ra,24(sp)
ffffffffc0204126:	6442                	ld	s0,16(sp)
ffffffffc0204128:	64a2                	ld	s1,8(sp)
ffffffffc020412a:	6902                	ld	s2,0(sp)
ffffffffc020412c:	6105                	addi	sp,sp,32
ffffffffc020412e:	8082                	ret

ffffffffc0204130 <find_vma>:
    if (mm != NULL)
ffffffffc0204130:	c51d                	beqz	a0,ffffffffc020415e <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0204132:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0204134:	c781                	beqz	a5,ffffffffc020413c <find_vma+0xc>
ffffffffc0204136:	6798                	ld	a4,8(a5)
ffffffffc0204138:	02e5f663          	bleu	a4,a1,ffffffffc0204164 <find_vma+0x34>
            list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020413c:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020413e:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0204140:	00f50f63          	beq	a0,a5,ffffffffc020415e <find_vma+0x2e>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0204144:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204148:	fee5ebe3          	bltu	a1,a4,ffffffffc020413e <find_vma+0xe>
ffffffffc020414c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204150:	fee5f7e3          	bleu	a4,a1,ffffffffc020413e <find_vma+0xe>
                vma = le2vma(le, list_link);
ffffffffc0204154:	1781                	addi	a5,a5,-32
        if (vma != NULL)
ffffffffc0204156:	c781                	beqz	a5,ffffffffc020415e <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0204158:	e91c                	sd	a5,16(a0)
}
ffffffffc020415a:	853e                	mv	a0,a5
ffffffffc020415c:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc020415e:	4781                	li	a5,0
}
ffffffffc0204160:	853e                	mv	a0,a5
ffffffffc0204162:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0204164:	6b98                	ld	a4,16(a5)
ffffffffc0204166:	fce5fbe3          	bleu	a4,a1,ffffffffc020413c <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020416a:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc020416c:	b7fd                	j	ffffffffc020415a <find_vma+0x2a>

ffffffffc020416e <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc020416e:	6590                	ld	a2,8(a1)
ffffffffc0204170:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x88e0>
{
ffffffffc0204174:	1141                	addi	sp,sp,-16
ffffffffc0204176:	e406                	sd	ra,8(sp)
ffffffffc0204178:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020417a:	01066863          	bltu	a2,a6,ffffffffc020418a <insert_vma_struct+0x1c>
ffffffffc020417e:	a8b9                	j	ffffffffc02041dc <insert_vma_struct+0x6e>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0204180:	fe87b683          	ld	a3,-24(a5)
ffffffffc0204184:	04d66763          	bltu	a2,a3,ffffffffc02041d2 <insert_vma_struct+0x64>
ffffffffc0204188:	873e                	mv	a4,a5
ffffffffc020418a:	671c                	ld	a5,8(a4)
    while ((le = list_next(le)) != list)
ffffffffc020418c:	fef51ae3          	bne	a0,a5,ffffffffc0204180 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc0204190:	02a70463          	beq	a4,a0,ffffffffc02041b8 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0204194:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204198:	fe873883          	ld	a7,-24(a4)
ffffffffc020419c:	08d8f063          	bleu	a3,a7,ffffffffc020421c <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041a0:	04d66e63          	bltu	a2,a3,ffffffffc02041fc <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc02041a4:	00f50a63          	beq	a0,a5,ffffffffc02041b8 <insert_vma_struct+0x4a>
ffffffffc02041a8:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041ac:	0506e863          	bltu	a3,a6,ffffffffc02041fc <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02041b0:	ff07b603          	ld	a2,-16(a5)
ffffffffc02041b4:	02c6f263          	bleu	a2,a3,ffffffffc02041d8 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc02041b8:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02041ba:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02041bc:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02041c0:	e390                	sd	a2,0(a5)
ffffffffc02041c2:	e710                	sd	a2,8(a4)
}
ffffffffc02041c4:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02041c6:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02041c8:	f198                	sd	a4,32(a1)
    mm->map_count++;
ffffffffc02041ca:	2685                	addiw	a3,a3,1
ffffffffc02041cc:	d114                	sw	a3,32(a0)
}
ffffffffc02041ce:	0141                	addi	sp,sp,16
ffffffffc02041d0:	8082                	ret
    if (le_prev != list)
ffffffffc02041d2:	fca711e3          	bne	a4,a0,ffffffffc0204194 <insert_vma_struct+0x26>
ffffffffc02041d6:	bfd9                	j	ffffffffc02041ac <insert_vma_struct+0x3e>
ffffffffc02041d8:	ebbff0ef          	jal	ra,ffffffffc0204092 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041dc:	00007697          	auipc	a3,0x7
ffffffffc02041e0:	a8468693          	addi	a3,a3,-1404 # ffffffffc020ac60 <default_pmm_manager+0xe00>
ffffffffc02041e4:	00005617          	auipc	a2,0x5
ffffffffc02041e8:	53460613          	addi	a2,a2,1332 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02041ec:	07f00593          	li	a1,127
ffffffffc02041f0:	00007517          	auipc	a0,0x7
ffffffffc02041f4:	98050513          	addi	a0,a0,-1664 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc02041f8:	a90fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041fc:	00007697          	auipc	a3,0x7
ffffffffc0204200:	aa468693          	addi	a3,a3,-1372 # ffffffffc020aca0 <default_pmm_manager+0xe40>
ffffffffc0204204:	00005617          	auipc	a2,0x5
ffffffffc0204208:	51460613          	addi	a2,a2,1300 # ffffffffc0209718 <commands+0x4c0>
ffffffffc020420c:	07800593          	li	a1,120
ffffffffc0204210:	00007517          	auipc	a0,0x7
ffffffffc0204214:	96050513          	addi	a0,a0,-1696 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc0204218:	a70fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020421c:	00007697          	auipc	a3,0x7
ffffffffc0204220:	a6468693          	addi	a3,a3,-1436 # ffffffffc020ac80 <default_pmm_manager+0xe20>
ffffffffc0204224:	00005617          	auipc	a2,0x5
ffffffffc0204228:	4f460613          	addi	a2,a2,1268 # ffffffffc0209718 <commands+0x4c0>
ffffffffc020422c:	07700593          	li	a1,119
ffffffffc0204230:	00007517          	auipc	a0,0x7
ffffffffc0204234:	94050513          	addi	a0,a0,-1728 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc0204238:	a50fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020423c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc020423c:	591c                	lw	a5,48(a0)
{
ffffffffc020423e:	1141                	addi	sp,sp,-16
ffffffffc0204240:	e406                	sd	ra,8(sp)
ffffffffc0204242:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204244:	e78d                	bnez	a5,ffffffffc020426e <mm_destroy+0x32>
ffffffffc0204246:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0204248:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc020424a:	00a40c63          	beq	s0,a0,ffffffffc0204262 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020424e:	6118                	ld	a4,0(a0)
ffffffffc0204250:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0204252:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204254:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204256:	e398                	sd	a4,0(a5)
ffffffffc0204258:	aabfd0ef          	jal	ra,ffffffffc0201d02 <kfree>
    return listelm->next;
ffffffffc020425c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc020425e:	fea418e3          	bne	s0,a0,ffffffffc020424e <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc0204262:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0204264:	6402                	ld	s0,0(sp)
ffffffffc0204266:	60a2                	ld	ra,8(sp)
ffffffffc0204268:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc020426a:	a99fd06f          	j	ffffffffc0201d02 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020426e:	00007697          	auipc	a3,0x7
ffffffffc0204272:	a5268693          	addi	a3,a3,-1454 # ffffffffc020acc0 <default_pmm_manager+0xe60>
ffffffffc0204276:	00005617          	auipc	a2,0x5
ffffffffc020427a:	4a260613          	addi	a2,a2,1186 # ffffffffc0209718 <commands+0x4c0>
ffffffffc020427e:	0a300593          	li	a1,163
ffffffffc0204282:	00007517          	auipc	a0,0x7
ffffffffc0204286:	8ee50513          	addi	a0,a0,-1810 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc020428a:	9fefc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020428e <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020428e:	6785                	lui	a5,0x1
{
ffffffffc0204290:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204292:	17fd                	addi	a5,a5,-1
ffffffffc0204294:	787d                	lui	a6,0xfffff
{
ffffffffc0204296:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204298:	00f60433          	add	s0,a2,a5
{
ffffffffc020429c:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020429e:	942e                	add	s0,s0,a1
{
ffffffffc02042a0:	fc06                	sd	ra,56(sp)
ffffffffc02042a2:	f04a                	sd	s2,32(sp)
ffffffffc02042a4:	ec4e                	sd	s3,24(sp)
ffffffffc02042a6:	e852                	sd	s4,16(sp)
ffffffffc02042a8:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042aa:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end))
ffffffffc02042ae:	002007b7          	lui	a5,0x200
ffffffffc02042b2:	01047433          	and	s0,s0,a6
ffffffffc02042b6:	06f4e363          	bltu	s1,a5,ffffffffc020431c <mm_map+0x8e>
ffffffffc02042ba:	0684f163          	bleu	s0,s1,ffffffffc020431c <mm_map+0x8e>
ffffffffc02042be:	4785                	li	a5,1
ffffffffc02042c0:	07fe                	slli	a5,a5,0x1f
ffffffffc02042c2:	0487ed63          	bltu	a5,s0,ffffffffc020431c <mm_map+0x8e>
ffffffffc02042c6:	89aa                	mv	s3,a0
ffffffffc02042c8:	8a3a                	mv	s4,a4
ffffffffc02042ca:	8ab6                	mv	s5,a3
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02042cc:	c931                	beqz	a0,ffffffffc0204320 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc02042ce:	85a6                	mv	a1,s1
ffffffffc02042d0:	e61ff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc02042d4:	c501                	beqz	a0,ffffffffc02042dc <mm_map+0x4e>
ffffffffc02042d6:	651c                	ld	a5,8(a0)
ffffffffc02042d8:	0487e263          	bltu	a5,s0,ffffffffc020431c <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042dc:	03000513          	li	a0,48
ffffffffc02042e0:	967fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc02042e4:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02042e6:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc02042e8:	02090163          	beqz	s2,ffffffffc020430a <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02042ec:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02042ee:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02042f2:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02042f6:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02042fa:	85ca                	mv	a1,s2
ffffffffc02042fc:	e73ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0204300:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc0204302:	000a0463          	beqz	s4,ffffffffc020430a <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0204306:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc020430a:	70e2                	ld	ra,56(sp)
ffffffffc020430c:	7442                	ld	s0,48(sp)
ffffffffc020430e:	74a2                	ld	s1,40(sp)
ffffffffc0204310:	7902                	ld	s2,32(sp)
ffffffffc0204312:	69e2                	ld	s3,24(sp)
ffffffffc0204314:	6a42                	ld	s4,16(sp)
ffffffffc0204316:	6aa2                	ld	s5,8(sp)
ffffffffc0204318:	6121                	addi	sp,sp,64
ffffffffc020431a:	8082                	ret
        return -E_INVAL;
ffffffffc020431c:	5575                	li	a0,-3
ffffffffc020431e:	b7f5                	j	ffffffffc020430a <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc0204320:	00006697          	auipc	a3,0x6
ffffffffc0204324:	33868693          	addi	a3,a3,824 # ffffffffc020a658 <default_pmm_manager+0x7f8>
ffffffffc0204328:	00005617          	auipc	a2,0x5
ffffffffc020432c:	3f060613          	addi	a2,a2,1008 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204330:	0b800593          	li	a1,184
ffffffffc0204334:	00007517          	auipc	a0,0x7
ffffffffc0204338:	83c50513          	addi	a0,a0,-1988 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc020433c:	94cfc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204340 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0204340:	7139                	addi	sp,sp,-64
ffffffffc0204342:	fc06                	sd	ra,56(sp)
ffffffffc0204344:	f822                	sd	s0,48(sp)
ffffffffc0204346:	f426                	sd	s1,40(sp)
ffffffffc0204348:	f04a                	sd	s2,32(sp)
ffffffffc020434a:	ec4e                	sd	s3,24(sp)
ffffffffc020434c:	e852                	sd	s4,16(sp)
ffffffffc020434e:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204350:	c535                	beqz	a0,ffffffffc02043bc <dup_mmap+0x7c>
ffffffffc0204352:	892a                	mv	s2,a0
ffffffffc0204354:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0204356:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0204358:	e59d                	bnez	a1,ffffffffc0204386 <dup_mmap+0x46>
ffffffffc020435a:	a08d                	j	ffffffffc02043bc <dup_mmap+0x7c>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc020435c:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc020435e:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_matrix_out_size+0x1f45b0>
        insert_vma_struct(to, nvma);
ffffffffc0204362:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0204364:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc0204368:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc020436c:	e03ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0204370:	ff043683          	ld	a3,-16(s0)
ffffffffc0204374:	fe843603          	ld	a2,-24(s0)
ffffffffc0204378:	6c8c                	ld	a1,24(s1)
ffffffffc020437a:	01893503          	ld	a0,24(s2)
ffffffffc020437e:	4701                	li	a4,0
ffffffffc0204380:	d2ffe0ef          	jal	ra,ffffffffc02030ae <copy_range>
ffffffffc0204384:	e105                	bnez	a0,ffffffffc02043a4 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc0204386:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0204388:	02848863          	beq	s1,s0,ffffffffc02043b8 <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020438c:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0204390:	fe843a83          	ld	s5,-24(s0)
ffffffffc0204394:	ff043a03          	ld	s4,-16(s0)
ffffffffc0204398:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020439c:	8abfd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc02043a0:	87aa                	mv	a5,a0
    if (vma != NULL)
ffffffffc02043a2:	fd4d                	bnez	a0,ffffffffc020435c <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02043a4:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02043a6:	70e2                	ld	ra,56(sp)
ffffffffc02043a8:	7442                	ld	s0,48(sp)
ffffffffc02043aa:	74a2                	ld	s1,40(sp)
ffffffffc02043ac:	7902                	ld	s2,32(sp)
ffffffffc02043ae:	69e2                	ld	s3,24(sp)
ffffffffc02043b0:	6a42                	ld	s4,16(sp)
ffffffffc02043b2:	6aa2                	ld	s5,8(sp)
ffffffffc02043b4:	6121                	addi	sp,sp,64
ffffffffc02043b6:	8082                	ret
    return 0;
ffffffffc02043b8:	4501                	li	a0,0
ffffffffc02043ba:	b7f5                	j	ffffffffc02043a6 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc02043bc:	00007697          	auipc	a3,0x7
ffffffffc02043c0:	86468693          	addi	a3,a3,-1948 # ffffffffc020ac20 <default_pmm_manager+0xdc0>
ffffffffc02043c4:	00005617          	auipc	a2,0x5
ffffffffc02043c8:	35460613          	addi	a2,a2,852 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02043cc:	0d400593          	li	a1,212
ffffffffc02043d0:	00006517          	auipc	a0,0x6
ffffffffc02043d4:	7a050513          	addi	a0,a0,1952 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc02043d8:	8b0fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02043dc <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc02043dc:	1101                	addi	sp,sp,-32
ffffffffc02043de:	ec06                	sd	ra,24(sp)
ffffffffc02043e0:	e822                	sd	s0,16(sp)
ffffffffc02043e2:	e426                	sd	s1,8(sp)
ffffffffc02043e4:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02043e6:	c531                	beqz	a0,ffffffffc0204432 <exit_mmap+0x56>
ffffffffc02043e8:	591c                	lw	a5,48(a0)
ffffffffc02043ea:	84aa                	mv	s1,a0
ffffffffc02043ec:	e3b9                	bnez	a5,ffffffffc0204432 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02043ee:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02043f0:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc02043f4:	02850663          	beq	a0,s0,ffffffffc0204420 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02043f8:	ff043603          	ld	a2,-16(s0)
ffffffffc02043fc:	fe843583          	ld	a1,-24(s0)
ffffffffc0204400:	854a                	mv	a0,s2
ffffffffc0204402:	d83fd0ef          	jal	ra,ffffffffc0202184 <unmap_range>
ffffffffc0204406:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0204408:	fe8498e3          	bne	s1,s0,ffffffffc02043f8 <exit_mmap+0x1c>
ffffffffc020440c:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc020440e:	00848c63          	beq	s1,s0,ffffffffc0204426 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204412:	ff043603          	ld	a2,-16(s0)
ffffffffc0204416:	fe843583          	ld	a1,-24(s0)
ffffffffc020441a:	854a                	mv	a0,s2
ffffffffc020441c:	e81fd0ef          	jal	ra,ffffffffc020229c <exit_range>
ffffffffc0204420:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0204422:	fe8498e3          	bne	s1,s0,ffffffffc0204412 <exit_mmap+0x36>
    }
}
ffffffffc0204426:	60e2                	ld	ra,24(sp)
ffffffffc0204428:	6442                	ld	s0,16(sp)
ffffffffc020442a:	64a2                	ld	s1,8(sp)
ffffffffc020442c:	6902                	ld	s2,0(sp)
ffffffffc020442e:	6105                	addi	sp,sp,32
ffffffffc0204430:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204432:	00007697          	auipc	a3,0x7
ffffffffc0204436:	80e68693          	addi	a3,a3,-2034 # ffffffffc020ac40 <default_pmm_manager+0xde0>
ffffffffc020443a:	00005617          	auipc	a2,0x5
ffffffffc020443e:	2de60613          	addi	a2,a2,734 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204442:	0ed00593          	li	a1,237
ffffffffc0204446:	00006517          	auipc	a0,0x6
ffffffffc020444a:	72a50513          	addi	a0,a0,1834 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc020444e:	83afc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204452 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0204452:	7139                	addi	sp,sp,-64
ffffffffc0204454:	f822                	sd	s0,48(sp)
ffffffffc0204456:	f426                	sd	s1,40(sp)
ffffffffc0204458:	fc06                	sd	ra,56(sp)
ffffffffc020445a:	f04a                	sd	s2,32(sp)
ffffffffc020445c:	ec4e                	sd	s3,24(sp)
ffffffffc020445e:	e852                	sd	s4,16(sp)
ffffffffc0204460:	e456                	sd	s5,8(sp)
static void
check_vma_struct(void)
{
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204462:	c55ff0ef          	jal	ra,ffffffffc02040b6 <mm_create>
    assert(mm != NULL);
ffffffffc0204466:	842a                	mv	s0,a0
ffffffffc0204468:	03200493          	li	s1,50
ffffffffc020446c:	e919                	bnez	a0,ffffffffc0204482 <vmm_init+0x30>
ffffffffc020446e:	a989                	j	ffffffffc02048c0 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0204470:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204472:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204474:	00052c23          	sw	zero,24(a0)
    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204478:	14ed                	addi	s1,s1,-5
ffffffffc020447a:	8522                	mv	a0,s0
ffffffffc020447c:	cf3ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0204480:	c88d                	beqz	s1,ffffffffc02044b2 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204482:	03000513          	li	a0,48
ffffffffc0204486:	fc0fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc020448a:	85aa                	mv	a1,a0
ffffffffc020448c:	00248793          	addi	a5,s1,2
    if (vma != NULL)
ffffffffc0204490:	f165                	bnez	a0,ffffffffc0204470 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0204492:	00006697          	auipc	a3,0x6
ffffffffc0204496:	1fe68693          	addi	a3,a3,510 # ffffffffc020a690 <default_pmm_manager+0x830>
ffffffffc020449a:	00005617          	auipc	a2,0x5
ffffffffc020449e:	27e60613          	addi	a2,a2,638 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02044a2:	13100593          	li	a1,305
ffffffffc02044a6:	00006517          	auipc	a0,0x6
ffffffffc02044aa:	6ca50513          	addi	a0,a0,1738 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc02044ae:	fdbfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    for (i = step1; i >= 1; i--)
ffffffffc02044b2:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc02044b6:	1f900913          	li	s2,505
ffffffffc02044ba:	a819                	j	ffffffffc02044d0 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02044bc:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02044be:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02044c0:	00052c23          	sw	zero,24(a0)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02044c4:	0495                	addi	s1,s1,5
ffffffffc02044c6:	8522                	mv	a0,s0
ffffffffc02044c8:	ca7ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02044cc:	03248a63          	beq	s1,s2,ffffffffc0204500 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044d0:	03000513          	li	a0,48
ffffffffc02044d4:	f72fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc02044d8:	85aa                	mv	a1,a0
ffffffffc02044da:	00248793          	addi	a5,s1,2
    if (vma != NULL)
ffffffffc02044de:	fd79                	bnez	a0,ffffffffc02044bc <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02044e0:	00006697          	auipc	a3,0x6
ffffffffc02044e4:	1b068693          	addi	a3,a3,432 # ffffffffc020a690 <default_pmm_manager+0x830>
ffffffffc02044e8:	00005617          	auipc	a2,0x5
ffffffffc02044ec:	23060613          	addi	a2,a2,560 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02044f0:	13800593          	li	a1,312
ffffffffc02044f4:	00006517          	auipc	a0,0x6
ffffffffc02044f8:	67c50513          	addi	a0,a0,1660 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc02044fc:	f8dfb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0204500:	6418                	ld	a4,8(s0)
ffffffffc0204502:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0204504:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0204508:	2ee40063          	beq	s0,a4,ffffffffc02047e8 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020450c:	fe873603          	ld	a2,-24(a4)
ffffffffc0204510:	ffe78693          	addi	a3,a5,-2
ffffffffc0204514:	24d61a63          	bne	a2,a3,ffffffffc0204768 <vmm_init+0x316>
ffffffffc0204518:	ff073683          	ld	a3,-16(a4)
ffffffffc020451c:	24f69663          	bne	a3,a5,ffffffffc0204768 <vmm_init+0x316>
ffffffffc0204520:	0795                	addi	a5,a5,5
ffffffffc0204522:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i++)
ffffffffc0204524:	feb792e3          	bne	a5,a1,ffffffffc0204508 <vmm_init+0xb6>
ffffffffc0204528:	491d                	li	s2,7
ffffffffc020452a:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc020452c:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204530:	85a6                	mv	a1,s1
ffffffffc0204532:	8522                	mv	a0,s0
ffffffffc0204534:	bfdff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc0204538:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020453a:	30050763          	beqz	a0,ffffffffc0204848 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc020453e:	00148593          	addi	a1,s1,1
ffffffffc0204542:	8522                	mv	a0,s0
ffffffffc0204544:	bedff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc0204548:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020454a:	2c050f63          	beqz	a0,ffffffffc0204828 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc020454e:	85ca                	mv	a1,s2
ffffffffc0204550:	8522                	mv	a0,s0
ffffffffc0204552:	bdfff0ef          	jal	ra,ffffffffc0204130 <find_vma>
        assert(vma3 == NULL);
ffffffffc0204556:	2a051963          	bnez	a0,ffffffffc0204808 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc020455a:	00348593          	addi	a1,s1,3
ffffffffc020455e:	8522                	mv	a0,s0
ffffffffc0204560:	bd1ff0ef          	jal	ra,ffffffffc0204130 <find_vma>
        assert(vma4 == NULL);
ffffffffc0204564:	32051263          	bnez	a0,ffffffffc0204888 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0204568:	00448593          	addi	a1,s1,4
ffffffffc020456c:	8522                	mv	a0,s0
ffffffffc020456e:	bc3ff0ef          	jal	ra,ffffffffc0204130 <find_vma>
        assert(vma5 == NULL);
ffffffffc0204572:	2e051b63          	bnez	a0,ffffffffc0204868 <vmm_init+0x416>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0204576:	008a3783          	ld	a5,8(s4)
ffffffffc020457a:	20979763          	bne	a5,s1,ffffffffc0204788 <vmm_init+0x336>
ffffffffc020457e:	010a3783          	ld	a5,16(s4)
ffffffffc0204582:	21279363          	bne	a5,s2,ffffffffc0204788 <vmm_init+0x336>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0204586:	0089b783          	ld	a5,8(s3)
ffffffffc020458a:	20979f63          	bne	a5,s1,ffffffffc02047a8 <vmm_init+0x356>
ffffffffc020458e:	0109b783          	ld	a5,16(s3)
ffffffffc0204592:	21279b63          	bne	a5,s2,ffffffffc02047a8 <vmm_init+0x356>
ffffffffc0204596:	0495                	addi	s1,s1,5
ffffffffc0204598:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc020459a:	f9549be3          	bne	s1,s5,ffffffffc0204530 <vmm_init+0xde>
ffffffffc020459e:	4491                	li	s1,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc02045a0:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc02045a2:	85a6                	mv	a1,s1
ffffffffc02045a4:	8522                	mv	a0,s0
ffffffffc02045a6:	b8bff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc02045aa:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL)
ffffffffc02045ae:	c90d                	beqz	a0,ffffffffc02045e0 <vmm_init+0x18e>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc02045b0:	6914                	ld	a3,16(a0)
ffffffffc02045b2:	6510                	ld	a2,8(a0)
ffffffffc02045b4:	00007517          	auipc	a0,0x7
ffffffffc02045b8:	82450513          	addi	a0,a0,-2012 # ffffffffc020add8 <default_pmm_manager+0xf78>
ffffffffc02045bc:	bd7fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02045c0:	00007697          	auipc	a3,0x7
ffffffffc02045c4:	84068693          	addi	a3,a3,-1984 # ffffffffc020ae00 <default_pmm_manager+0xfa0>
ffffffffc02045c8:	00005617          	auipc	a2,0x5
ffffffffc02045cc:	15060613          	addi	a2,a2,336 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02045d0:	15e00593          	li	a1,350
ffffffffc02045d4:	00006517          	auipc	a0,0x6
ffffffffc02045d8:	59c50513          	addi	a0,a0,1436 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc02045dc:	eadfb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc02045e0:	14fd                	addi	s1,s1,-1
    for (i = 4; i >= 0; i--)
ffffffffc02045e2:	fd2490e3          	bne	s1,s2,ffffffffc02045a2 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02045e6:	8522                	mv	a0,s0
ffffffffc02045e8:	c55ff0ef          	jal	ra,ffffffffc020423c <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02045ec:	00007517          	auipc	a0,0x7
ffffffffc02045f0:	82c50513          	addi	a0,a0,-2004 # ffffffffc020ae18 <default_pmm_manager+0xfb8>
ffffffffc02045f4:	b9ffb0ef          	jal	ra,ffffffffc0200192 <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void)
{
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02045f8:	919fd0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc02045fc:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02045fe:	ab9ff0ef          	jal	ra,ffffffffc02040b6 <mm_create>
ffffffffc0204602:	000c5797          	auipc	a5,0xc5
ffffffffc0204606:	cea7bf23          	sd	a0,-770(a5) # ffffffffc02c9300 <check_mm_struct>
ffffffffc020460a:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc020460c:	36050663          	beqz	a0,ffffffffc0204978 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204610:	000c5797          	auipc	a5,0xc5
ffffffffc0204614:	b8878793          	addi	a5,a5,-1144 # ffffffffc02c9198 <boot_pgdir>
ffffffffc0204618:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020461c:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204620:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204624:	2c079e63          	bnez	a5,ffffffffc0204900 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204628:	03000513          	li	a0,48
ffffffffc020462c:	e1afd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc0204630:	842a                	mv	s0,a0
    if (vma != NULL)
ffffffffc0204632:	18050b63          	beqz	a0,ffffffffc02047c8 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0204636:	002007b7          	lui	a5,0x200
ffffffffc020463a:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc020463c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020463e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204640:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204642:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0204644:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204648:	b27ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020464c:	10000593          	li	a1,256
ffffffffc0204650:	8526                	mv	a0,s1
ffffffffc0204652:	adfff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc0204656:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i++)
ffffffffc020465a:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020465e:	2ca41163          	bne	s0,a0,ffffffffc0204920 <vmm_init+0x4ce>
    {
        *(char *)(addr + i) = i;
ffffffffc0204662:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_matrix_out_size+0x1f45a8>
        sum += i;
ffffffffc0204666:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i++)
ffffffffc0204668:	fee79de3          	bne	a5,a4,ffffffffc0204662 <vmm_init+0x210>
        sum += i;
ffffffffc020466c:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i++)
ffffffffc020466e:	10000793          	li	a5,256
        sum += i;
ffffffffc0204672:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x859a>
    }
    for (i = 0; i < 100; i++)
ffffffffc0204676:	16400613          	li	a2,356
    {
        sum -= *(char *)(addr + i);
ffffffffc020467a:	0007c683          	lbu	a3,0(a5)
ffffffffc020467e:	0785                	addi	a5,a5,1
ffffffffc0204680:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i++)
ffffffffc0204682:	fec79ce3          	bne	a5,a2,ffffffffc020467a <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc0204686:	2c071963          	bnez	a4,ffffffffc0204958 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc020468a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020468e:	000c5a97          	auipc	s5,0xc5
ffffffffc0204692:	b12a8a93          	addi	s5,s5,-1262 # ffffffffc02c91a0 <npage>
ffffffffc0204696:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020469a:	078a                	slli	a5,a5,0x2
ffffffffc020469c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020469e:	20e7f563          	bleu	a4,a5,ffffffffc02048a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046a2:	00008697          	auipc	a3,0x8
ffffffffc02046a6:	8fe68693          	addi	a3,a3,-1794 # ffffffffc020bfa0 <nbase>
ffffffffc02046aa:	0006ba03          	ld	s4,0(a3)
ffffffffc02046ae:	414786b3          	sub	a3,a5,s4
ffffffffc02046b2:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02046b4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02046b6:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc02046b8:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02046ba:	83b1                	srli	a5,a5,0xc
ffffffffc02046bc:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02046be:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02046c0:	28e7f063          	bleu	a4,a5,ffffffffc0204940 <vmm_init+0x4ee>
ffffffffc02046c4:	000c5797          	auipc	a5,0xc5
ffffffffc02046c8:	b4c78793          	addi	a5,a5,-1204 # ffffffffc02c9210 <va_pa_offset>
ffffffffc02046cc:	6380                	ld	s0,0(a5)

    pde_t *pd1 = pgdir, *pd0 = page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02046ce:	4581                	li	a1,0
ffffffffc02046d0:	854a                	mv	a0,s2
ffffffffc02046d2:	9436                	add	s0,s0,a3
ffffffffc02046d4:	e1ffd0ef          	jal	ra,ffffffffc02024f2 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046d8:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02046da:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046de:	078a                	slli	a5,a5,0x2
ffffffffc02046e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046e2:	1ce7f363          	bleu	a4,a5,ffffffffc02048a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046e6:	000c5417          	auipc	s0,0xc5
ffffffffc02046ea:	b3a40413          	addi	s0,s0,-1222 # ffffffffc02c9220 <pages>
ffffffffc02046ee:	6008                	ld	a0,0(s0)
ffffffffc02046f0:	414787b3          	sub	a5,a5,s4
ffffffffc02046f4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02046f6:	953e                	add	a0,a0,a5
ffffffffc02046f8:	4585                	li	a1,1
ffffffffc02046fa:	fd0fd0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046fe:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204702:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204706:	078a                	slli	a5,a5,0x2
ffffffffc0204708:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020470a:	18e7ff63          	bleu	a4,a5,ffffffffc02048a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc020470e:	6008                	ld	a0,0(s0)
ffffffffc0204710:	414787b3          	sub	a5,a5,s4
ffffffffc0204714:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204716:	4585                	li	a1,1
ffffffffc0204718:	953e                	add	a0,a0,a5
ffffffffc020471a:	fb0fd0ef          	jal	ra,ffffffffc0201eca <free_pages>
    pgdir[0] = 0;
ffffffffc020471e:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0204722:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0204726:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc020472a:	8526                	mv	a0,s1
ffffffffc020472c:	b11ff0ef          	jal	ra,ffffffffc020423c <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204730:	000c5797          	auipc	a5,0xc5
ffffffffc0204734:	bc07b823          	sd	zero,-1072(a5) # ffffffffc02c9300 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204738:	fd8fd0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc020473c:	1aa99263          	bne	s3,a0,ffffffffc02048e0 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204740:	00006517          	auipc	a0,0x6
ffffffffc0204744:	76850513          	addi	a0,a0,1896 # ffffffffc020aea8 <default_pmm_manager+0x1048>
ffffffffc0204748:	a4bfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc020474c:	7442                	ld	s0,48(sp)
ffffffffc020474e:	70e2                	ld	ra,56(sp)
ffffffffc0204750:	74a2                	ld	s1,40(sp)
ffffffffc0204752:	7902                	ld	s2,32(sp)
ffffffffc0204754:	69e2                	ld	s3,24(sp)
ffffffffc0204756:	6a42                	ld	s4,16(sp)
ffffffffc0204758:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020475a:	00006517          	auipc	a0,0x6
ffffffffc020475e:	76e50513          	addi	a0,a0,1902 # ffffffffc020aec8 <default_pmm_manager+0x1068>
}
ffffffffc0204762:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204764:	a2ffb06f          	j	ffffffffc0200192 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204768:	00006697          	auipc	a3,0x6
ffffffffc020476c:	58868693          	addi	a3,a3,1416 # ffffffffc020acf0 <default_pmm_manager+0xe90>
ffffffffc0204770:	00005617          	auipc	a2,0x5
ffffffffc0204774:	fa860613          	addi	a2,a2,-88 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204778:	14200593          	li	a1,322
ffffffffc020477c:	00006517          	auipc	a0,0x6
ffffffffc0204780:	3f450513          	addi	a0,a0,1012 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc0204784:	d05fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0204788:	00006697          	auipc	a3,0x6
ffffffffc020478c:	5f068693          	addi	a3,a3,1520 # ffffffffc020ad78 <default_pmm_manager+0xf18>
ffffffffc0204790:	00005617          	auipc	a2,0x5
ffffffffc0204794:	f8860613          	addi	a2,a2,-120 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204798:	15300593          	li	a1,339
ffffffffc020479c:	00006517          	auipc	a0,0x6
ffffffffc02047a0:	3d450513          	addi	a0,a0,980 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc02047a4:	ce5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02047a8:	00006697          	auipc	a3,0x6
ffffffffc02047ac:	60068693          	addi	a3,a3,1536 # ffffffffc020ada8 <default_pmm_manager+0xf48>
ffffffffc02047b0:	00005617          	auipc	a2,0x5
ffffffffc02047b4:	f6860613          	addi	a2,a2,-152 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02047b8:	15400593          	li	a1,340
ffffffffc02047bc:	00006517          	auipc	a0,0x6
ffffffffc02047c0:	3b450513          	addi	a0,a0,948 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc02047c4:	cc5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(vma != NULL);
ffffffffc02047c8:	00006697          	auipc	a3,0x6
ffffffffc02047cc:	ec868693          	addi	a3,a3,-312 # ffffffffc020a690 <default_pmm_manager+0x830>
ffffffffc02047d0:	00005617          	auipc	a2,0x5
ffffffffc02047d4:	f4860613          	addi	a2,a2,-184 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02047d8:	17600593          	li	a1,374
ffffffffc02047dc:	00006517          	auipc	a0,0x6
ffffffffc02047e0:	39450513          	addi	a0,a0,916 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc02047e4:	ca5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02047e8:	00006697          	auipc	a3,0x6
ffffffffc02047ec:	4f068693          	addi	a3,a3,1264 # ffffffffc020acd8 <default_pmm_manager+0xe78>
ffffffffc02047f0:	00005617          	auipc	a2,0x5
ffffffffc02047f4:	f2860613          	addi	a2,a2,-216 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02047f8:	14000593          	li	a1,320
ffffffffc02047fc:	00006517          	auipc	a0,0x6
ffffffffc0204800:	37450513          	addi	a0,a0,884 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc0204804:	c85fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma3 == NULL);
ffffffffc0204808:	00006697          	auipc	a3,0x6
ffffffffc020480c:	54068693          	addi	a3,a3,1344 # ffffffffc020ad48 <default_pmm_manager+0xee8>
ffffffffc0204810:	00005617          	auipc	a2,0x5
ffffffffc0204814:	f0860613          	addi	a2,a2,-248 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204818:	14d00593          	li	a1,333
ffffffffc020481c:	00006517          	auipc	a0,0x6
ffffffffc0204820:	35450513          	addi	a0,a0,852 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc0204824:	c65fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma2 != NULL);
ffffffffc0204828:	00006697          	auipc	a3,0x6
ffffffffc020482c:	51068693          	addi	a3,a3,1296 # ffffffffc020ad38 <default_pmm_manager+0xed8>
ffffffffc0204830:	00005617          	auipc	a2,0x5
ffffffffc0204834:	ee860613          	addi	a2,a2,-280 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204838:	14b00593          	li	a1,331
ffffffffc020483c:	00006517          	auipc	a0,0x6
ffffffffc0204840:	33450513          	addi	a0,a0,820 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc0204844:	c45fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma1 != NULL);
ffffffffc0204848:	00006697          	auipc	a3,0x6
ffffffffc020484c:	4e068693          	addi	a3,a3,1248 # ffffffffc020ad28 <default_pmm_manager+0xec8>
ffffffffc0204850:	00005617          	auipc	a2,0x5
ffffffffc0204854:	ec860613          	addi	a2,a2,-312 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204858:	14900593          	li	a1,329
ffffffffc020485c:	00006517          	auipc	a0,0x6
ffffffffc0204860:	31450513          	addi	a0,a0,788 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc0204864:	c25fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma5 == NULL);
ffffffffc0204868:	00006697          	auipc	a3,0x6
ffffffffc020486c:	50068693          	addi	a3,a3,1280 # ffffffffc020ad68 <default_pmm_manager+0xf08>
ffffffffc0204870:	00005617          	auipc	a2,0x5
ffffffffc0204874:	ea860613          	addi	a2,a2,-344 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204878:	15100593          	li	a1,337
ffffffffc020487c:	00006517          	auipc	a0,0x6
ffffffffc0204880:	2f450513          	addi	a0,a0,756 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc0204884:	c05fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma4 == NULL);
ffffffffc0204888:	00006697          	auipc	a3,0x6
ffffffffc020488c:	4d068693          	addi	a3,a3,1232 # ffffffffc020ad58 <default_pmm_manager+0xef8>
ffffffffc0204890:	00005617          	auipc	a2,0x5
ffffffffc0204894:	e8860613          	addi	a2,a2,-376 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204898:	14f00593          	li	a1,335
ffffffffc020489c:	00006517          	auipc	a0,0x6
ffffffffc02048a0:	2d450513          	addi	a0,a0,724 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc02048a4:	be5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02048a8:	00005617          	auipc	a2,0x5
ffffffffc02048ac:	66860613          	addi	a2,a2,1640 # ffffffffc0209f10 <default_pmm_manager+0xb0>
ffffffffc02048b0:	06200593          	li	a1,98
ffffffffc02048b4:	00005517          	auipc	a0,0x5
ffffffffc02048b8:	62450513          	addi	a0,a0,1572 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc02048bc:	bcdfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(mm != NULL);
ffffffffc02048c0:	00006697          	auipc	a3,0x6
ffffffffc02048c4:	d9868693          	addi	a3,a3,-616 # ffffffffc020a658 <default_pmm_manager+0x7f8>
ffffffffc02048c8:	00005617          	auipc	a2,0x5
ffffffffc02048cc:	e5060613          	addi	a2,a2,-432 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02048d0:	12900593          	li	a1,297
ffffffffc02048d4:	00006517          	auipc	a0,0x6
ffffffffc02048d8:	29c50513          	addi	a0,a0,668 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc02048dc:	badfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02048e0:	00006697          	auipc	a3,0x6
ffffffffc02048e4:	5a068693          	addi	a3,a3,1440 # ffffffffc020ae80 <default_pmm_manager+0x1020>
ffffffffc02048e8:	00005617          	auipc	a2,0x5
ffffffffc02048ec:	e3060613          	addi	a2,a2,-464 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02048f0:	19600593          	li	a1,406
ffffffffc02048f4:	00006517          	auipc	a0,0x6
ffffffffc02048f8:	27c50513          	addi	a0,a0,636 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc02048fc:	b8dfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204900:	00006697          	auipc	a3,0x6
ffffffffc0204904:	d8068693          	addi	a3,a3,-640 # ffffffffc020a680 <default_pmm_manager+0x820>
ffffffffc0204908:	00005617          	auipc	a2,0x5
ffffffffc020490c:	e1060613          	addi	a2,a2,-496 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204910:	17300593          	li	a1,371
ffffffffc0204914:	00006517          	auipc	a0,0x6
ffffffffc0204918:	25c50513          	addi	a0,a0,604 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc020491c:	b6dfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204920:	00006697          	auipc	a3,0x6
ffffffffc0204924:	53068693          	addi	a3,a3,1328 # ffffffffc020ae50 <default_pmm_manager+0xff0>
ffffffffc0204928:	00005617          	auipc	a2,0x5
ffffffffc020492c:	df060613          	addi	a2,a2,-528 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204930:	17b00593          	li	a1,379
ffffffffc0204934:	00006517          	auipc	a0,0x6
ffffffffc0204938:	23c50513          	addi	a0,a0,572 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc020493c:	b4dfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204940:	00005617          	auipc	a2,0x5
ffffffffc0204944:	57060613          	addi	a2,a2,1392 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0204948:	06900593          	li	a1,105
ffffffffc020494c:	00005517          	auipc	a0,0x5
ffffffffc0204950:	58c50513          	addi	a0,a0,1420 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0204954:	b35fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(sum == 0);
ffffffffc0204958:	00006697          	auipc	a3,0x6
ffffffffc020495c:	51868693          	addi	a3,a3,1304 # ffffffffc020ae70 <default_pmm_manager+0x1010>
ffffffffc0204960:	00005617          	auipc	a2,0x5
ffffffffc0204964:	db860613          	addi	a2,a2,-584 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204968:	18900593          	li	a1,393
ffffffffc020496c:	00006517          	auipc	a0,0x6
ffffffffc0204970:	20450513          	addi	a0,a0,516 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc0204974:	b15fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204978:	00006697          	auipc	a3,0x6
ffffffffc020497c:	4c068693          	addi	a3,a3,1216 # ffffffffc020ae38 <default_pmm_manager+0xfd8>
ffffffffc0204980:	00005617          	auipc	a2,0x5
ffffffffc0204984:	d9860613          	addi	a2,a2,-616 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0204988:	16f00593          	li	a1,367
ffffffffc020498c:	00006517          	auipc	a0,0x6
ffffffffc0204990:	1e450513          	addi	a0,a0,484 # ffffffffc020ab70 <default_pmm_manager+0xd10>
ffffffffc0204994:	af5fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204998 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
ffffffffc0204998:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    // try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020499a:	85b2                	mv	a1,a2
{
ffffffffc020499c:	f022                	sd	s0,32(sp)
ffffffffc020499e:	ec26                	sd	s1,24(sp)
ffffffffc02049a0:	f406                	sd	ra,40(sp)
ffffffffc02049a2:	e84a                	sd	s2,16(sp)
ffffffffc02049a4:	8432                	mv	s0,a2
ffffffffc02049a6:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049a8:	f88ff0ef          	jal	ra,ffffffffc0204130 <find_vma>

    pgfault_num++;
ffffffffc02049ac:	000c5797          	auipc	a5,0xc5
ffffffffc02049b0:	80878793          	addi	a5,a5,-2040 # ffffffffc02c91b4 <pgfault_num>
ffffffffc02049b4:	439c                	lw	a5,0(a5)
ffffffffc02049b6:	2785                	addiw	a5,a5,1
ffffffffc02049b8:	000c4717          	auipc	a4,0xc4
ffffffffc02049bc:	7ef72e23          	sw	a5,2044(a4) # ffffffffc02c91b4 <pgfault_num>
    // If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr)
ffffffffc02049c0:	c551                	beqz	a0,ffffffffc0204a4c <do_pgfault+0xb4>
ffffffffc02049c2:	651c                	ld	a5,8(a0)
ffffffffc02049c4:	08f46463          	bltu	s0,a5,ffffffffc0204a4c <do_pgfault+0xb4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE)
ffffffffc02049c8:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02049ca:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE)
ffffffffc02049cc:	8b89                	andi	a5,a5,2
ffffffffc02049ce:	efb1                	bnez	a5,ffffffffc0204a2a <do_pgfault+0x92>
    {
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049d0:	767d                	lui	a2,0xfffff
     *   mm->pgdir : the PDT of these vma
     *
     */
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL)
ffffffffc02049d2:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049d4:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL)
ffffffffc02049d6:	85a2                	mv	a1,s0
ffffffffc02049d8:	4605                	li	a2,1
ffffffffc02049da:	d76fd0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02049de:	c941                	beqz	a0,ffffffffc0204a6e <do_pgfault+0xd6>
    {
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }

    if (*ptep == 0)
ffffffffc02049e0:	610c                	ld	a1,0(a0)
ffffffffc02049e2:	c5b1                	beqz	a1,ffffffffc0204a2e <do_pgfault+0x96>
         *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
         *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
         *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
         *    swap_map_swappable ： 设置页面可交换
         */
        if (swap_init_ok)
ffffffffc02049e4:	000c4797          	auipc	a5,0xc4
ffffffffc02049e8:	7cc78793          	addi	a5,a5,1996 # ffffffffc02c91b0 <swap_init_ok>
ffffffffc02049ec:	439c                	lw	a5,0(a5)
ffffffffc02049ee:	2781                	sext.w	a5,a5
ffffffffc02049f0:	c7bd                	beqz	a5,ffffffffc0204a5e <do_pgfault+0xc6>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }
            page_insert(mm->pgdir, page, addr, perm);
            swap_map_swappable(mm, addr, page, 1);*/
            swap_in(mm, addr, &page);
ffffffffc02049f2:	85a2                	mv	a1,s0
ffffffffc02049f4:	0030                	addi	a2,sp,8
ffffffffc02049f6:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02049f8:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc02049fa:	a36ff0ef          	jal	ra,ffffffffc0203c30 <swap_in>
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc02049fe:	65a2                	ld	a1,8(sp)
ffffffffc0204a00:	6c88                	ld	a0,24(s1)
ffffffffc0204a02:	86ca                	mv	a3,s2
ffffffffc0204a04:	8622                	mv	a2,s0
ffffffffc0204a06:	b61fd0ef          	jal	ra,ffffffffc0202566 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0204a0a:	6622                	ld	a2,8(sp)
ffffffffc0204a0c:	4685                	li	a3,1
ffffffffc0204a0e:	85a2                	mv	a1,s0
ffffffffc0204a10:	8526                	mv	a0,s1
ffffffffc0204a12:	8faff0ef          	jal	ra,ffffffffc0203b0c <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0204a16:	6722                	ld	a4,8(sp)
        {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
    }
    ret = 0;
ffffffffc0204a18:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0204a1a:	ff00                	sd	s0,56(a4)
failed:
    return ret;
}
ffffffffc0204a1c:	70a2                	ld	ra,40(sp)
ffffffffc0204a1e:	7402                	ld	s0,32(sp)
ffffffffc0204a20:	64e2                	ld	s1,24(sp)
ffffffffc0204a22:	6942                	ld	s2,16(sp)
ffffffffc0204a24:	853e                	mv	a0,a5
ffffffffc0204a26:	6145                	addi	sp,sp,48
ffffffffc0204a28:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204a2a:	495d                	li	s2,23
ffffffffc0204a2c:	b755                	j	ffffffffc02049d0 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
ffffffffc0204a2e:	6c88                	ld	a0,24(s1)
ffffffffc0204a30:	864a                	mv	a2,s2
ffffffffc0204a32:	85a2                	mv	a1,s0
ffffffffc0204a34:	8b5fe0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
    ret = 0;
ffffffffc0204a38:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
ffffffffc0204a3a:	f16d                	bnez	a0,ffffffffc0204a1c <do_pgfault+0x84>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204a3c:	00006517          	auipc	a0,0x6
ffffffffc0204a40:	19450513          	addi	a0,a0,404 # ffffffffc020abd0 <default_pmm_manager+0xd70>
ffffffffc0204a44:	f4efb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a48:	57f1                	li	a5,-4
            goto failed;
ffffffffc0204a4a:	bfc9                	j	ffffffffc0204a1c <do_pgfault+0x84>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204a4c:	85a2                	mv	a1,s0
ffffffffc0204a4e:	00006517          	auipc	a0,0x6
ffffffffc0204a52:	13250513          	addi	a0,a0,306 # ffffffffc020ab80 <default_pmm_manager+0xd20>
ffffffffc0204a56:	f3cfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204a5a:	57f5                	li	a5,-3
        goto failed;
ffffffffc0204a5c:	b7c1                	j	ffffffffc0204a1c <do_pgfault+0x84>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204a5e:	00006517          	auipc	a0,0x6
ffffffffc0204a62:	19a50513          	addi	a0,a0,410 # ffffffffc020abf8 <default_pmm_manager+0xd98>
ffffffffc0204a66:	f2cfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a6a:	57f1                	li	a5,-4
            goto failed;
ffffffffc0204a6c:	bf45                	j	ffffffffc0204a1c <do_pgfault+0x84>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204a6e:	00006517          	auipc	a0,0x6
ffffffffc0204a72:	14250513          	addi	a0,a0,322 # ffffffffc020abb0 <default_pmm_manager+0xd50>
ffffffffc0204a76:	f1cfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a7a:	57f1                	li	a5,-4
        goto failed;
ffffffffc0204a7c:	b745                	j	ffffffffc0204a1c <do_pgfault+0x84>

ffffffffc0204a7e <user_mem_check>:

bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0204a7e:	7179                	addi	sp,sp,-48
ffffffffc0204a80:	f022                	sd	s0,32(sp)
ffffffffc0204a82:	f406                	sd	ra,40(sp)
ffffffffc0204a84:	ec26                	sd	s1,24(sp)
ffffffffc0204a86:	e84a                	sd	s2,16(sp)
ffffffffc0204a88:	e44e                	sd	s3,8(sp)
ffffffffc0204a8a:	e052                	sd	s4,0(sp)
ffffffffc0204a8c:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0204a8e:	c135                	beqz	a0,ffffffffc0204af2 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0204a90:	002007b7          	lui	a5,0x200
ffffffffc0204a94:	04f5e663          	bltu	a1,a5,ffffffffc0204ae0 <user_mem_check+0x62>
ffffffffc0204a98:	00c584b3          	add	s1,a1,a2
ffffffffc0204a9c:	0495f263          	bleu	s1,a1,ffffffffc0204ae0 <user_mem_check+0x62>
ffffffffc0204aa0:	4785                	li	a5,1
ffffffffc0204aa2:	07fe                	slli	a5,a5,0x1f
ffffffffc0204aa4:	0297ee63          	bltu	a5,s1,ffffffffc0204ae0 <user_mem_check+0x62>
ffffffffc0204aa8:	892a                	mv	s2,a0
ffffffffc0204aaa:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0204aac:	6a05                	lui	s4,0x1
ffffffffc0204aae:	a821                	j	ffffffffc0204ac6 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0204ab0:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc0204ab4:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0204ab6:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0204ab8:	c685                	beqz	a3,ffffffffc0204ae0 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0204aba:	c399                	beqz	a5,ffffffffc0204ac0 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0204abc:	02e46263          	bltu	s0,a4,ffffffffc0204ae0 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204ac0:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0204ac2:	04947663          	bleu	s1,s0,ffffffffc0204b0e <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0204ac6:	85a2                	mv	a1,s0
ffffffffc0204ac8:	854a                	mv	a0,s2
ffffffffc0204aca:	e66ff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc0204ace:	c909                	beqz	a0,ffffffffc0204ae0 <user_mem_check+0x62>
ffffffffc0204ad0:	6518                	ld	a4,8(a0)
ffffffffc0204ad2:	00e46763          	bltu	s0,a4,ffffffffc0204ae0 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0204ad6:	4d1c                	lw	a5,24(a0)
ffffffffc0204ad8:	fc099ce3          	bnez	s3,ffffffffc0204ab0 <user_mem_check+0x32>
ffffffffc0204adc:	8b85                	andi	a5,a5,1
ffffffffc0204ade:	f3ed                	bnez	a5,ffffffffc0204ac0 <user_mem_check+0x42>
            return 0;
ffffffffc0204ae0:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204ae2:	70a2                	ld	ra,40(sp)
ffffffffc0204ae4:	7402                	ld	s0,32(sp)
ffffffffc0204ae6:	64e2                	ld	s1,24(sp)
ffffffffc0204ae8:	6942                	ld	s2,16(sp)
ffffffffc0204aea:	69a2                	ld	s3,8(sp)
ffffffffc0204aec:	6a02                	ld	s4,0(sp)
ffffffffc0204aee:	6145                	addi	sp,sp,48
ffffffffc0204af0:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204af2:	c02007b7          	lui	a5,0xc0200
ffffffffc0204af6:	4501                	li	a0,0
ffffffffc0204af8:	fef5e5e3          	bltu	a1,a5,ffffffffc0204ae2 <user_mem_check+0x64>
ffffffffc0204afc:	962e                	add	a2,a2,a1
ffffffffc0204afe:	fec5f2e3          	bleu	a2,a1,ffffffffc0204ae2 <user_mem_check+0x64>
ffffffffc0204b02:	c8000537          	lui	a0,0xc8000
ffffffffc0204b06:	0505                	addi	a0,a0,1
ffffffffc0204b08:	00a63533          	sltu	a0,a2,a0
ffffffffc0204b0c:	bfd9                	j	ffffffffc0204ae2 <user_mem_check+0x64>
        return 1;
ffffffffc0204b0e:	4505                	li	a0,1
ffffffffc0204b10:	bfc9                	j	ffffffffc0204ae2 <user_mem_check+0x64>

ffffffffc0204b12 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b12:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b14:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b16:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b18:	adffb0ef          	jal	ra,ffffffffc02005f6 <ide_device_valid>
ffffffffc0204b1c:	cd01                	beqz	a0,ffffffffc0204b34 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b1e:	4505                	li	a0,1
ffffffffc0204b20:	addfb0ef          	jal	ra,ffffffffc02005fc <ide_device_size>
}
ffffffffc0204b24:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b26:	810d                	srli	a0,a0,0x3
ffffffffc0204b28:	000c4797          	auipc	a5,0xc4
ffffffffc0204b2c:	78a7b423          	sd	a0,1928(a5) # ffffffffc02c92b0 <max_swap_offset>
}
ffffffffc0204b30:	0141                	addi	sp,sp,16
ffffffffc0204b32:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b34:	00006617          	auipc	a2,0x6
ffffffffc0204b38:	3ac60613          	addi	a2,a2,940 # ffffffffc020aee0 <default_pmm_manager+0x1080>
ffffffffc0204b3c:	45b5                	li	a1,13
ffffffffc0204b3e:	00006517          	auipc	a0,0x6
ffffffffc0204b42:	3c250513          	addi	a0,a0,962 # ffffffffc020af00 <default_pmm_manager+0x10a0>
ffffffffc0204b46:	943fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204b4a <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b4a:	1141                	addi	sp,sp,-16
ffffffffc0204b4c:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b4e:	00855793          	srli	a5,a0,0x8
ffffffffc0204b52:	cfb9                	beqz	a5,ffffffffc0204bb0 <swapfs_read+0x66>
ffffffffc0204b54:	000c4717          	auipc	a4,0xc4
ffffffffc0204b58:	75c70713          	addi	a4,a4,1884 # ffffffffc02c92b0 <max_swap_offset>
ffffffffc0204b5c:	6318                	ld	a4,0(a4)
ffffffffc0204b5e:	04e7f963          	bleu	a4,a5,ffffffffc0204bb0 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204b62:	000c4717          	auipc	a4,0xc4
ffffffffc0204b66:	6be70713          	addi	a4,a4,1726 # ffffffffc02c9220 <pages>
ffffffffc0204b6a:	6310                	ld	a2,0(a4)
ffffffffc0204b6c:	00007717          	auipc	a4,0x7
ffffffffc0204b70:	43470713          	addi	a4,a4,1076 # ffffffffc020bfa0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204b74:	000c4697          	auipc	a3,0xc4
ffffffffc0204b78:	62c68693          	addi	a3,a3,1580 # ffffffffc02c91a0 <npage>
    return page - pages + nbase;
ffffffffc0204b7c:	40c58633          	sub	a2,a1,a2
ffffffffc0204b80:	630c                	ld	a1,0(a4)
ffffffffc0204b82:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204b84:	577d                	li	a4,-1
ffffffffc0204b86:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204b88:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204b8a:	8331                	srli	a4,a4,0xc
ffffffffc0204b8c:	8f71                	and	a4,a4,a2
ffffffffc0204b8e:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b92:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204b94:	02d77a63          	bleu	a3,a4,ffffffffc0204bc8 <swapfs_read+0x7e>
ffffffffc0204b98:	000c4797          	auipc	a5,0xc4
ffffffffc0204b9c:	67878793          	addi	a5,a5,1656 # ffffffffc02c9210 <va_pa_offset>
ffffffffc0204ba0:	639c                	ld	a5,0(a5)
}
ffffffffc0204ba2:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ba4:	46a1                	li	a3,8
ffffffffc0204ba6:	963e                	add	a2,a2,a5
ffffffffc0204ba8:	4505                	li	a0,1
}
ffffffffc0204baa:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bac:	a57fb06f          	j	ffffffffc0200602 <ide_read_secs>
ffffffffc0204bb0:	86aa                	mv	a3,a0
ffffffffc0204bb2:	00006617          	auipc	a2,0x6
ffffffffc0204bb6:	36660613          	addi	a2,a2,870 # ffffffffc020af18 <default_pmm_manager+0x10b8>
ffffffffc0204bba:	45d1                	li	a1,20
ffffffffc0204bbc:	00006517          	auipc	a0,0x6
ffffffffc0204bc0:	34450513          	addi	a0,a0,836 # ffffffffc020af00 <default_pmm_manager+0x10a0>
ffffffffc0204bc4:	8c5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0204bc8:	86b2                	mv	a3,a2
ffffffffc0204bca:	06900593          	li	a1,105
ffffffffc0204bce:	00005617          	auipc	a2,0x5
ffffffffc0204bd2:	2e260613          	addi	a2,a2,738 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0204bd6:	00005517          	auipc	a0,0x5
ffffffffc0204bda:	30250513          	addi	a0,a0,770 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0204bde:	8abfb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204be2 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204be2:	1141                	addi	sp,sp,-16
ffffffffc0204be4:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204be6:	00855793          	srli	a5,a0,0x8
ffffffffc0204bea:	cfb9                	beqz	a5,ffffffffc0204c48 <swapfs_write+0x66>
ffffffffc0204bec:	000c4717          	auipc	a4,0xc4
ffffffffc0204bf0:	6c470713          	addi	a4,a4,1732 # ffffffffc02c92b0 <max_swap_offset>
ffffffffc0204bf4:	6318                	ld	a4,0(a4)
ffffffffc0204bf6:	04e7f963          	bleu	a4,a5,ffffffffc0204c48 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204bfa:	000c4717          	auipc	a4,0xc4
ffffffffc0204bfe:	62670713          	addi	a4,a4,1574 # ffffffffc02c9220 <pages>
ffffffffc0204c02:	6310                	ld	a2,0(a4)
ffffffffc0204c04:	00007717          	auipc	a4,0x7
ffffffffc0204c08:	39c70713          	addi	a4,a4,924 # ffffffffc020bfa0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204c0c:	000c4697          	auipc	a3,0xc4
ffffffffc0204c10:	59468693          	addi	a3,a3,1428 # ffffffffc02c91a0 <npage>
    return page - pages + nbase;
ffffffffc0204c14:	40c58633          	sub	a2,a1,a2
ffffffffc0204c18:	630c                	ld	a1,0(a4)
ffffffffc0204c1a:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204c1c:	577d                	li	a4,-1
ffffffffc0204c1e:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204c20:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c22:	8331                	srli	a4,a4,0xc
ffffffffc0204c24:	8f71                	and	a4,a4,a2
ffffffffc0204c26:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c2a:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c2c:	02d77a63          	bleu	a3,a4,ffffffffc0204c60 <swapfs_write+0x7e>
ffffffffc0204c30:	000c4797          	auipc	a5,0xc4
ffffffffc0204c34:	5e078793          	addi	a5,a5,1504 # ffffffffc02c9210 <va_pa_offset>
ffffffffc0204c38:	639c                	ld	a5,0(a5)
}
ffffffffc0204c3a:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c3c:	46a1                	li	a3,8
ffffffffc0204c3e:	963e                	add	a2,a2,a5
ffffffffc0204c40:	4505                	li	a0,1
}
ffffffffc0204c42:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c44:	9e3fb06f          	j	ffffffffc0200626 <ide_write_secs>
ffffffffc0204c48:	86aa                	mv	a3,a0
ffffffffc0204c4a:	00006617          	auipc	a2,0x6
ffffffffc0204c4e:	2ce60613          	addi	a2,a2,718 # ffffffffc020af18 <default_pmm_manager+0x10b8>
ffffffffc0204c52:	45e5                	li	a1,25
ffffffffc0204c54:	00006517          	auipc	a0,0x6
ffffffffc0204c58:	2ac50513          	addi	a0,a0,684 # ffffffffc020af00 <default_pmm_manager+0x10a0>
ffffffffc0204c5c:	82dfb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0204c60:	86b2                	mv	a3,a2
ffffffffc0204c62:	06900593          	li	a1,105
ffffffffc0204c66:	00005617          	auipc	a2,0x5
ffffffffc0204c6a:	24a60613          	addi	a2,a2,586 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0204c6e:	00005517          	auipc	a0,0x5
ffffffffc0204c72:	26a50513          	addi	a0,a0,618 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0204c76:	813fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204c7a <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204c7a:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204c7c:	9402                	jalr	s0

	jal do_exit
ffffffffc0204c7e:	756000ef          	jal	ra,ffffffffc02053d4 <do_exit>

ffffffffc0204c82 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0204c82:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204c84:	14800513          	li	a0,328
{
ffffffffc0204c88:	e022                	sd	s0,0(sp)
ffffffffc0204c8a:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204c8c:	fbbfc0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc0204c90:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0204c92:	cd3d                	beqz	a0,ffffffffc0204d10 <alloc_proc+0x8e>
         *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */
        // LAB4:EXERCISE1 YOUR CODE
        proc->state = PROC_UNINIT;
ffffffffc0204c94:	57fd                	li	a5,-1
ffffffffc0204c96:	1782                	slli	a5,a5,0x20
ffffffffc0204c98:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204c9a:	07000613          	li	a2,112
ffffffffc0204c9e:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204ca0:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204ca4:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204ca8:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204cac:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204cb0:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204cb4:	03050513          	addi	a0,a0,48
ffffffffc0204cb8:	440040ef          	jal	ra,ffffffffc02090f8 <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc0204cbc:	000c4797          	auipc	a5,0xc4
ffffffffc0204cc0:	55c78793          	addi	a5,a5,1372 # ffffffffc02c9218 <boot_cr3>
ffffffffc0204cc4:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc0204cc6:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0204cca:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204cce:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204cd0:	463d                	li	a2,15
ffffffffc0204cd2:	4581                	li	a1,0
ffffffffc0204cd4:	0b440513          	addi	a0,s0,180
ffffffffc0204cd8:	420040ef          	jal	ra,ffffffffc02090f8 <memset>
         *     skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
         *     uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process
         *     uint32_t lab6_priority;                     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t)
         */
        proc->rq = NULL;
        list_init(&(proc->run_link));
ffffffffc0204cdc:	11040793          	addi	a5,s0,272
        proc->wait_state = 0;
ffffffffc0204ce0:	0e042623          	sw	zero,236(s0)
        proc->cptr = NULL;
ffffffffc0204ce4:	0e043823          	sd	zero,240(s0)
        proc->yptr = NULL;
ffffffffc0204ce8:	0e043c23          	sd	zero,248(s0)
        proc->optr = NULL;
ffffffffc0204cec:	10043023          	sd	zero,256(s0)
        proc->rq = NULL;
ffffffffc0204cf0:	10043423          	sd	zero,264(s0)
    elm->prev = elm->next = elm;
ffffffffc0204cf4:	10f43c23          	sd	a5,280(s0)
ffffffffc0204cf8:	10f43823          	sd	a5,272(s0)
        proc->time_slice = 0;
ffffffffc0204cfc:	12042023          	sw	zero,288(s0)
        proc->lab6_run_pool.left = NULL;
        proc->lab6_run_pool.right = NULL;
        proc->lab6_run_pool.parent = NULL;
ffffffffc0204d00:	12043423          	sd	zero,296(s0)
        proc->lab6_run_pool.left = NULL;
ffffffffc0204d04:	12043823          	sd	zero,304(s0)
        proc->lab6_run_pool.right = NULL;
ffffffffc0204d08:	12043c23          	sd	zero,312(s0)
        proc->lab6_stride = 0;
ffffffffc0204d0c:	14043023          	sd	zero,320(s0)
        proc->lab6_priority = 0;
    }
    return proc;
}
ffffffffc0204d10:	8522                	mv	a0,s0
ffffffffc0204d12:	60a2                	ld	ra,8(sp)
ffffffffc0204d14:	6402                	ld	s0,0(sp)
ffffffffc0204d16:	0141                	addi	sp,sp,16
ffffffffc0204d18:	8082                	ret

ffffffffc0204d1a <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0204d1a:	000c4797          	auipc	a5,0xc4
ffffffffc0204d1e:	49e78793          	addi	a5,a5,1182 # ffffffffc02c91b8 <current>
ffffffffc0204d22:	639c                	ld	a5,0(a5)
ffffffffc0204d24:	73c8                	ld	a0,160(a5)
ffffffffc0204d26:	874fc06f          	j	ffffffffc0200d9a <forkrets>

ffffffffc0204d2a <user_main>:
// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d2a:	000c4797          	auipc	a5,0xc4
ffffffffc0204d2e:	48e78793          	addi	a5,a5,1166 # ffffffffc02c91b8 <current>
ffffffffc0204d32:	639c                	ld	a5,0(a5)
{
ffffffffc0204d34:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d36:	00006617          	auipc	a2,0x6
ffffffffc0204d3a:	60a60613          	addi	a2,a2,1546 # ffffffffc020b340 <default_pmm_manager+0x14e0>
ffffffffc0204d3e:	43cc                	lw	a1,4(a5)
ffffffffc0204d40:	00006517          	auipc	a0,0x6
ffffffffc0204d44:	61050513          	addi	a0,a0,1552 # ffffffffc020b350 <default_pmm_manager+0x14f0>
{
ffffffffc0204d48:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d4a:	c48fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0204d4e:	00006797          	auipc	a5,0x6
ffffffffc0204d52:	5f278793          	addi	a5,a5,1522 # ffffffffc020b340 <default_pmm_manager+0x14e0>
ffffffffc0204d56:	3fe06717          	auipc	a4,0x3fe06
ffffffffc0204d5a:	10270713          	addi	a4,a4,258 # ae58 <_binary_obj___user_priority_out_size>
ffffffffc0204d5e:	e43a                	sd	a4,8(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0204d60:	853e                	mv	a0,a5
ffffffffc0204d62:	0007b717          	auipc	a4,0x7b
ffffffffc0204d66:	03e70713          	addi	a4,a4,62 # ffffffffc027fda0 <_binary_obj___user_priority_out_start>
ffffffffc0204d6a:	f03a                	sd	a4,32(sp)
ffffffffc0204d6c:	f43e                	sd	a5,40(sp)
ffffffffc0204d6e:	e802                	sd	zero,16(sp)
ffffffffc0204d70:	2ea040ef          	jal	ra,ffffffffc020905a <strlen>
ffffffffc0204d74:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204d76:	4511                	li	a0,4
ffffffffc0204d78:	55a2                	lw	a1,40(sp)
ffffffffc0204d7a:	4662                	lw	a2,24(sp)
ffffffffc0204d7c:	5682                	lw	a3,32(sp)
ffffffffc0204d7e:	4722                	lw	a4,8(sp)
ffffffffc0204d80:	48a9                	li	a7,10
ffffffffc0204d82:	9002                	ebreak
ffffffffc0204d84:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204d86:	65c2                	ld	a1,16(sp)
ffffffffc0204d88:	00006517          	auipc	a0,0x6
ffffffffc0204d8c:	5f050513          	addi	a0,a0,1520 # ffffffffc020b378 <default_pmm_manager+0x1518>
ffffffffc0204d90:	c02fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
#else
    KERNEL_EXECVE(priority);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204d94:	00006617          	auipc	a2,0x6
ffffffffc0204d98:	5f460613          	addi	a2,a2,1524 # ffffffffc020b388 <default_pmm_manager+0x1528>
ffffffffc0204d9c:	3c100593          	li	a1,961
ffffffffc0204da0:	00006517          	auipc	a0,0x6
ffffffffc0204da4:	60850513          	addi	a0,a0,1544 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0204da8:	ee0fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204dac <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204dac:	6d14                	ld	a3,24(a0)
{
ffffffffc0204dae:	1141                	addi	sp,sp,-16
ffffffffc0204db0:	e406                	sd	ra,8(sp)
ffffffffc0204db2:	c02007b7          	lui	a5,0xc0200
ffffffffc0204db6:	04f6e263          	bltu	a3,a5,ffffffffc0204dfa <put_pgdir+0x4e>
ffffffffc0204dba:	000c4797          	auipc	a5,0xc4
ffffffffc0204dbe:	45678793          	addi	a5,a5,1110 # ffffffffc02c9210 <va_pa_offset>
ffffffffc0204dc2:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204dc4:	000c4797          	auipc	a5,0xc4
ffffffffc0204dc8:	3dc78793          	addi	a5,a5,988 # ffffffffc02c91a0 <npage>
ffffffffc0204dcc:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204dce:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204dd0:	82b1                	srli	a3,a3,0xc
ffffffffc0204dd2:	04f6f063          	bleu	a5,a3,ffffffffc0204e12 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204dd6:	00007797          	auipc	a5,0x7
ffffffffc0204dda:	1ca78793          	addi	a5,a5,458 # ffffffffc020bfa0 <nbase>
ffffffffc0204dde:	639c                	ld	a5,0(a5)
ffffffffc0204de0:	000c4717          	auipc	a4,0xc4
ffffffffc0204de4:	44070713          	addi	a4,a4,1088 # ffffffffc02c9220 <pages>
ffffffffc0204de8:	6308                	ld	a0,0(a4)
}
ffffffffc0204dea:	60a2                	ld	ra,8(sp)
ffffffffc0204dec:	8e9d                	sub	a3,a3,a5
ffffffffc0204dee:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204df0:	4585                	li	a1,1
ffffffffc0204df2:	9536                	add	a0,a0,a3
}
ffffffffc0204df4:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204df6:	8d4fd06f          	j	ffffffffc0201eca <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204dfa:	00005617          	auipc	a2,0x5
ffffffffc0204dfe:	0ee60613          	addi	a2,a2,238 # ffffffffc0209ee8 <default_pmm_manager+0x88>
ffffffffc0204e02:	06e00593          	li	a1,110
ffffffffc0204e06:	00005517          	auipc	a0,0x5
ffffffffc0204e0a:	0d250513          	addi	a0,a0,210 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0204e0e:	e7afb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e12:	00005617          	auipc	a2,0x5
ffffffffc0204e16:	0fe60613          	addi	a2,a2,254 # ffffffffc0209f10 <default_pmm_manager+0xb0>
ffffffffc0204e1a:	06200593          	li	a1,98
ffffffffc0204e1e:	00005517          	auipc	a0,0x5
ffffffffc0204e22:	0ba50513          	addi	a0,a0,186 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0204e26:	e62fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204e2a <setup_pgdir>:
{
ffffffffc0204e2a:	1101                	addi	sp,sp,-32
ffffffffc0204e2c:	e426                	sd	s1,8(sp)
ffffffffc0204e2e:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL)
ffffffffc0204e30:	4505                	li	a0,1
{
ffffffffc0204e32:	ec06                	sd	ra,24(sp)
ffffffffc0204e34:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL)
ffffffffc0204e36:	80cfd0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0204e3a:	c125                	beqz	a0,ffffffffc0204e9a <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204e3c:	000c4797          	auipc	a5,0xc4
ffffffffc0204e40:	3e478793          	addi	a5,a5,996 # ffffffffc02c9220 <pages>
ffffffffc0204e44:	6394                	ld	a3,0(a5)
ffffffffc0204e46:	00007797          	auipc	a5,0x7
ffffffffc0204e4a:	15a78793          	addi	a5,a5,346 # ffffffffc020bfa0 <nbase>
ffffffffc0204e4e:	6380                	ld	s0,0(a5)
ffffffffc0204e50:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e54:	000c4717          	auipc	a4,0xc4
ffffffffc0204e58:	34c70713          	addi	a4,a4,844 # ffffffffc02c91a0 <npage>
    return page - pages + nbase;
ffffffffc0204e5c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204e5e:	57fd                	li	a5,-1
ffffffffc0204e60:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204e62:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204e64:	83b1                	srli	a5,a5,0xc
ffffffffc0204e66:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e68:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e6a:	02e7fa63          	bleu	a4,a5,ffffffffc0204e9e <setup_pgdir+0x74>
ffffffffc0204e6e:	000c4797          	auipc	a5,0xc4
ffffffffc0204e72:	3a278793          	addi	a5,a5,930 # ffffffffc02c9210 <va_pa_offset>
ffffffffc0204e76:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204e78:	000c4797          	auipc	a5,0xc4
ffffffffc0204e7c:	32078793          	addi	a5,a5,800 # ffffffffc02c9198 <boot_pgdir>
ffffffffc0204e80:	638c                	ld	a1,0(a5)
ffffffffc0204e82:	9436                	add	s0,s0,a3
ffffffffc0204e84:	6605                	lui	a2,0x1
ffffffffc0204e86:	8522                	mv	a0,s0
ffffffffc0204e88:	282040ef          	jal	ra,ffffffffc020910a <memcpy>
    return 0;
ffffffffc0204e8c:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204e8e:	ec80                	sd	s0,24(s1)
}
ffffffffc0204e90:	60e2                	ld	ra,24(sp)
ffffffffc0204e92:	6442                	ld	s0,16(sp)
ffffffffc0204e94:	64a2                	ld	s1,8(sp)
ffffffffc0204e96:	6105                	addi	sp,sp,32
ffffffffc0204e98:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204e9a:	5571                	li	a0,-4
ffffffffc0204e9c:	bfd5                	j	ffffffffc0204e90 <setup_pgdir+0x66>
ffffffffc0204e9e:	00005617          	auipc	a2,0x5
ffffffffc0204ea2:	01260613          	addi	a2,a2,18 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0204ea6:	06900593          	li	a1,105
ffffffffc0204eaa:	00005517          	auipc	a0,0x5
ffffffffc0204eae:	02e50513          	addi	a0,a0,46 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0204eb2:	dd6fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204eb6 <set_proc_name>:
{
ffffffffc0204eb6:	1101                	addi	sp,sp,-32
ffffffffc0204eb8:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204eba:	0b450413          	addi	s0,a0,180
{
ffffffffc0204ebe:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ec0:	4641                	li	a2,16
{
ffffffffc0204ec2:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ec4:	8522                	mv	a0,s0
ffffffffc0204ec6:	4581                	li	a1,0
{
ffffffffc0204ec8:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204eca:	22e040ef          	jal	ra,ffffffffc02090f8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ece:	8522                	mv	a0,s0
}
ffffffffc0204ed0:	6442                	ld	s0,16(sp)
ffffffffc0204ed2:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ed4:	85a6                	mv	a1,s1
}
ffffffffc0204ed6:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ed8:	463d                	li	a2,15
}
ffffffffc0204eda:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204edc:	22e0406f          	j	ffffffffc020910a <memcpy>

ffffffffc0204ee0 <proc_run>:
{
ffffffffc0204ee0:	1101                	addi	sp,sp,-32
    if (proc != current)
ffffffffc0204ee2:	000c4797          	auipc	a5,0xc4
ffffffffc0204ee6:	2d678793          	addi	a5,a5,726 # ffffffffc02c91b8 <current>
{
ffffffffc0204eea:	e426                	sd	s1,8(sp)
    if (proc != current)
ffffffffc0204eec:	6384                	ld	s1,0(a5)
{
ffffffffc0204eee:	ec06                	sd	ra,24(sp)
ffffffffc0204ef0:	e822                	sd	s0,16(sp)
ffffffffc0204ef2:	e04a                	sd	s2,0(sp)
    if (proc != current)
ffffffffc0204ef4:	02a48b63          	beq	s1,a0,ffffffffc0204f2a <proc_run+0x4a>
ffffffffc0204ef8:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204efa:	100027f3          	csrr	a5,sstatus
ffffffffc0204efe:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f00:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f02:	e3a9                	bnez	a5,ffffffffc0204f44 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f04:	745c                	ld	a5,168(s0)
        current = proc;
ffffffffc0204f06:	000c4717          	auipc	a4,0xc4
ffffffffc0204f0a:	2a873923          	sd	s0,690(a4) # ffffffffc02c91b8 <current>
ffffffffc0204f0e:	577d                	li	a4,-1
ffffffffc0204f10:	177e                	slli	a4,a4,0x3f
ffffffffc0204f12:	83b1                	srli	a5,a5,0xc
ffffffffc0204f14:	8fd9                	or	a5,a5,a4
ffffffffc0204f16:	18079073          	csrw	satp,a5
        switch_to(&(prev->context), &(next->context));
ffffffffc0204f1a:	03040593          	addi	a1,s0,48
ffffffffc0204f1e:	03048513          	addi	a0,s1,48
ffffffffc0204f22:	00e010ef          	jal	ra,ffffffffc0205f30 <switch_to>
    if (flag) {
ffffffffc0204f26:	00091863          	bnez	s2,ffffffffc0204f36 <proc_run+0x56>
}
ffffffffc0204f2a:	60e2                	ld	ra,24(sp)
ffffffffc0204f2c:	6442                	ld	s0,16(sp)
ffffffffc0204f2e:	64a2                	ld	s1,8(sp)
ffffffffc0204f30:	6902                	ld	s2,0(sp)
ffffffffc0204f32:	6105                	addi	sp,sp,32
ffffffffc0204f34:	8082                	ret
ffffffffc0204f36:	6442                	ld	s0,16(sp)
ffffffffc0204f38:	60e2                	ld	ra,24(sp)
ffffffffc0204f3a:	64a2                	ld	s1,8(sp)
ffffffffc0204f3c:	6902                	ld	s2,0(sp)
ffffffffc0204f3e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204f40:	f0cfb06f          	j	ffffffffc020064c <intr_enable>
        intr_disable();
ffffffffc0204f44:	f0efb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0204f48:	4905                	li	s2,1
ffffffffc0204f4a:	bf6d                	j	ffffffffc0204f04 <proc_run+0x24>

ffffffffc0204f4c <find_proc>:
    if (0 < pid && pid < MAX_PID)
ffffffffc0204f4c:	0005071b          	sext.w	a4,a0
ffffffffc0204f50:	6789                	lui	a5,0x2
ffffffffc0204f52:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204f56:	17f9                	addi	a5,a5,-2
ffffffffc0204f58:	04d7e063          	bltu	a5,a3,ffffffffc0204f98 <find_proc+0x4c>
{
ffffffffc0204f5c:	1141                	addi	sp,sp,-16
ffffffffc0204f5e:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f60:	45a9                	li	a1,10
ffffffffc0204f62:	842a                	mv	s0,a0
ffffffffc0204f64:	853a                	mv	a0,a4
{
ffffffffc0204f66:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f68:	4e3030ef          	jal	ra,ffffffffc0208c4a <hash32>
ffffffffc0204f6c:	02051693          	slli	a3,a0,0x20
ffffffffc0204f70:	82f1                	srli	a3,a3,0x1c
ffffffffc0204f72:	000c0517          	auipc	a0,0xc0
ffffffffc0204f76:	1e650513          	addi	a0,a0,486 # ffffffffc02c5158 <hash_list>
ffffffffc0204f7a:	96aa                	add	a3,a3,a0
ffffffffc0204f7c:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204f7e:	a029                	j	ffffffffc0204f88 <find_proc+0x3c>
            if (proc->pid == pid)
ffffffffc0204f80:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x79c4>
ffffffffc0204f84:	00870c63          	beq	a4,s0,ffffffffc0204f9c <find_proc+0x50>
    return listelm->next;
ffffffffc0204f88:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204f8a:	fef69be3          	bne	a3,a5,ffffffffc0204f80 <find_proc+0x34>
}
ffffffffc0204f8e:	60a2                	ld	ra,8(sp)
ffffffffc0204f90:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204f92:	4501                	li	a0,0
}
ffffffffc0204f94:	0141                	addi	sp,sp,16
ffffffffc0204f96:	8082                	ret
    return NULL;
ffffffffc0204f98:	4501                	li	a0,0
}
ffffffffc0204f9a:	8082                	ret
ffffffffc0204f9c:	60a2                	ld	ra,8(sp)
ffffffffc0204f9e:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204fa0:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204fa4:	0141                	addi	sp,sp,16
ffffffffc0204fa6:	8082                	ret

ffffffffc0204fa8 <do_fork>:
{
ffffffffc0204fa8:	7159                	addi	sp,sp,-112
ffffffffc0204faa:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204fac:	000c4a17          	auipc	s4,0xc4
ffffffffc0204fb0:	224a0a13          	addi	s4,s4,548 # ffffffffc02c91d0 <nr_process>
ffffffffc0204fb4:	000a2703          	lw	a4,0(s4)
{
ffffffffc0204fb8:	f486                	sd	ra,104(sp)
ffffffffc0204fba:	f0a2                	sd	s0,96(sp)
ffffffffc0204fbc:	eca6                	sd	s1,88(sp)
ffffffffc0204fbe:	e8ca                	sd	s2,80(sp)
ffffffffc0204fc0:	e4ce                	sd	s3,72(sp)
ffffffffc0204fc2:	fc56                	sd	s5,56(sp)
ffffffffc0204fc4:	f85a                	sd	s6,48(sp)
ffffffffc0204fc6:	f45e                	sd	s7,40(sp)
ffffffffc0204fc8:	f062                	sd	s8,32(sp)
ffffffffc0204fca:	ec66                	sd	s9,24(sp)
ffffffffc0204fcc:	e86a                	sd	s10,16(sp)
ffffffffc0204fce:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204fd0:	6785                	lui	a5,0x1
ffffffffc0204fd2:	30f75a63          	ble	a5,a4,ffffffffc02052e6 <do_fork+0x33e>
ffffffffc0204fd6:	89aa                	mv	s3,a0
ffffffffc0204fd8:	892e                	mv	s2,a1
ffffffffc0204fda:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc0204fdc:	ca7ff0ef          	jal	ra,ffffffffc0204c82 <alloc_proc>
ffffffffc0204fe0:	842a                	mv	s0,a0
ffffffffc0204fe2:	2e050463          	beqz	a0,ffffffffc02052ca <do_fork+0x322>
    proc->parent = current;
ffffffffc0204fe6:	000c4c17          	auipc	s8,0xc4
ffffffffc0204fea:	1d2c0c13          	addi	s8,s8,466 # ffffffffc02c91b8 <current>
ffffffffc0204fee:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);
ffffffffc0204ff2:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8804>
    proc->parent = current;
ffffffffc0204ff6:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0204ff8:	30071563          	bnez	a4,ffffffffc0205302 <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204ffc:	4509                	li	a0,2
ffffffffc0204ffe:	e45fc0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
    if (page != NULL)
ffffffffc0205002:	2c050163          	beqz	a0,ffffffffc02052c4 <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc0205006:	000c4a97          	auipc	s5,0xc4
ffffffffc020500a:	21aa8a93          	addi	s5,s5,538 # ffffffffc02c9220 <pages>
ffffffffc020500e:	000ab683          	ld	a3,0(s5)
ffffffffc0205012:	00007b17          	auipc	s6,0x7
ffffffffc0205016:	f8eb0b13          	addi	s6,s6,-114 # ffffffffc020bfa0 <nbase>
ffffffffc020501a:	000b3783          	ld	a5,0(s6)
ffffffffc020501e:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0205022:	000c4b97          	auipc	s7,0xc4
ffffffffc0205026:	17eb8b93          	addi	s7,s7,382 # ffffffffc02c91a0 <npage>
    return page - pages + nbase;
ffffffffc020502a:	8699                	srai	a3,a3,0x6
ffffffffc020502c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020502e:	000bb703          	ld	a4,0(s7)
ffffffffc0205032:	57fd                	li	a5,-1
ffffffffc0205034:	83b1                	srli	a5,a5,0xc
ffffffffc0205036:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205038:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020503a:	2ae7f863          	bleu	a4,a5,ffffffffc02052ea <do_fork+0x342>
ffffffffc020503e:	000c4c97          	auipc	s9,0xc4
ffffffffc0205042:	1d2c8c93          	addi	s9,s9,466 # ffffffffc02c9210 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205046:	000c3703          	ld	a4,0(s8)
ffffffffc020504a:	000cb783          	ld	a5,0(s9)
ffffffffc020504e:	02873c03          	ld	s8,40(a4)
ffffffffc0205052:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205054:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc0205056:	020c0863          	beqz	s8,ffffffffc0205086 <do_fork+0xde>
    if (clone_flags & CLONE_VM)
ffffffffc020505a:	1009f993          	andi	s3,s3,256
ffffffffc020505e:	1e098163          	beqz	s3,ffffffffc0205240 <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205062:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205066:	018c3783          	ld	a5,24(s8)
ffffffffc020506a:	c02006b7          	lui	a3,0xc0200
ffffffffc020506e:	2705                	addiw	a4,a4,1
ffffffffc0205070:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc0205074:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205078:	2ad7e563          	bltu	a5,a3,ffffffffc0205322 <do_fork+0x37a>
ffffffffc020507c:	000cb703          	ld	a4,0(s9)
ffffffffc0205080:	6814                	ld	a3,16(s0)
ffffffffc0205082:	8f99                	sub	a5,a5,a4
ffffffffc0205084:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205086:	6789                	lui	a5,0x2
ffffffffc0205088:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7a10>
ffffffffc020508c:	96be                	add	a3,a3,a5
ffffffffc020508e:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0205090:	87b6                	mv	a5,a3
ffffffffc0205092:	12048813          	addi	a6,s1,288
ffffffffc0205096:	6088                	ld	a0,0(s1)
ffffffffc0205098:	648c                	ld	a1,8(s1)
ffffffffc020509a:	6890                	ld	a2,16(s1)
ffffffffc020509c:	6c98                	ld	a4,24(s1)
ffffffffc020509e:	e388                	sd	a0,0(a5)
ffffffffc02050a0:	e78c                	sd	a1,8(a5)
ffffffffc02050a2:	eb90                	sd	a2,16(a5)
ffffffffc02050a4:	ef98                	sd	a4,24(a5)
ffffffffc02050a6:	02048493          	addi	s1,s1,32
ffffffffc02050aa:	02078793          	addi	a5,a5,32
ffffffffc02050ae:	ff0494e3          	bne	s1,a6,ffffffffc0205096 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc02050b2:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02050b6:	12090e63          	beqz	s2,ffffffffc02051f2 <do_fork+0x24a>
ffffffffc02050ba:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050be:	00000797          	auipc	a5,0x0
ffffffffc02050c2:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204d1a <forkret>
ffffffffc02050c6:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02050c8:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050ca:	100027f3          	csrr	a5,sstatus
ffffffffc02050ce:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050d0:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050d2:	12079f63          	bnez	a5,ffffffffc0205210 <do_fork+0x268>
    if (++last_pid >= MAX_PID)
ffffffffc02050d6:	000b9797          	auipc	a5,0xb9
ffffffffc02050da:	c7a78793          	addi	a5,a5,-902 # ffffffffc02bdd50 <last_pid.1767>
ffffffffc02050de:	439c                	lw	a5,0(a5)
ffffffffc02050e0:	6709                	lui	a4,0x2
ffffffffc02050e2:	0017851b          	addiw	a0,a5,1
ffffffffc02050e6:	000b9697          	auipc	a3,0xb9
ffffffffc02050ea:	c6a6a523          	sw	a0,-918(a3) # ffffffffc02bdd50 <last_pid.1767>
ffffffffc02050ee:	14e55263          	ble	a4,a0,ffffffffc0205232 <do_fork+0x28a>
    if (last_pid >= next_safe)
ffffffffc02050f2:	000b9797          	auipc	a5,0xb9
ffffffffc02050f6:	c6278793          	addi	a5,a5,-926 # ffffffffc02bdd54 <next_safe.1766>
ffffffffc02050fa:	439c                	lw	a5,0(a5)
ffffffffc02050fc:	000c4497          	auipc	s1,0xc4
ffffffffc0205100:	20c48493          	addi	s1,s1,524 # ffffffffc02c9308 <proc_list>
ffffffffc0205104:	06f54063          	blt	a0,a5,ffffffffc0205164 <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc0205108:	6789                	lui	a5,0x2
ffffffffc020510a:	000b9717          	auipc	a4,0xb9
ffffffffc020510e:	c4f72523          	sw	a5,-950(a4) # ffffffffc02bdd54 <next_safe.1766>
ffffffffc0205112:	4581                	li	a1,0
ffffffffc0205114:	87aa                	mv	a5,a0
ffffffffc0205116:	000c4497          	auipc	s1,0xc4
ffffffffc020511a:	1f248493          	addi	s1,s1,498 # ffffffffc02c9308 <proc_list>
    repeat:
ffffffffc020511e:	6889                	lui	a7,0x2
ffffffffc0205120:	882e                	mv	a6,a1
ffffffffc0205122:	6609                	lui	a2,0x2
        le = list;
ffffffffc0205124:	000c4697          	auipc	a3,0xc4
ffffffffc0205128:	1e468693          	addi	a3,a3,484 # ffffffffc02c9308 <proc_list>
ffffffffc020512c:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list)
ffffffffc020512e:	00968f63          	beq	a3,s1,ffffffffc020514c <do_fork+0x1a4>
            if (proc->pid == last_pid)
ffffffffc0205132:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0205136:	0ae78963          	beq	a5,a4,ffffffffc02051e8 <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc020513a:	fee7d9e3          	ble	a4,a5,ffffffffc020512c <do_fork+0x184>
ffffffffc020513e:	fec757e3          	ble	a2,a4,ffffffffc020512c <do_fork+0x184>
ffffffffc0205142:	6694                	ld	a3,8(a3)
ffffffffc0205144:	863a                	mv	a2,a4
ffffffffc0205146:	4805                	li	a6,1
        while ((le = list_next(le)) != list)
ffffffffc0205148:	fe9695e3          	bne	a3,s1,ffffffffc0205132 <do_fork+0x18a>
ffffffffc020514c:	c591                	beqz	a1,ffffffffc0205158 <do_fork+0x1b0>
ffffffffc020514e:	000b9717          	auipc	a4,0xb9
ffffffffc0205152:	c0f72123          	sw	a5,-1022(a4) # ffffffffc02bdd50 <last_pid.1767>
ffffffffc0205156:	853e                	mv	a0,a5
ffffffffc0205158:	00080663          	beqz	a6,ffffffffc0205164 <do_fork+0x1bc>
ffffffffc020515c:	000b9797          	auipc	a5,0xb9
ffffffffc0205160:	bec7ac23          	sw	a2,-1032(a5) # ffffffffc02bdd54 <next_safe.1766>
    proc->pid = get_pid();
ffffffffc0205164:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205166:	45a9                	li	a1,10
ffffffffc0205168:	2501                	sext.w	a0,a0
ffffffffc020516a:	2e1030ef          	jal	ra,ffffffffc0208c4a <hash32>
ffffffffc020516e:	1502                	slli	a0,a0,0x20
ffffffffc0205170:	000c0797          	auipc	a5,0xc0
ffffffffc0205174:	fe878793          	addi	a5,a5,-24 # ffffffffc02c5158 <hash_list>
ffffffffc0205178:	8171                	srli	a0,a0,0x1c
ffffffffc020517a:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020517c:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020517e:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205180:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc0205184:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205186:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0205188:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020518a:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020518c:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0205190:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc0205192:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0205194:	e21c                	sd	a5,0(a2)
ffffffffc0205196:	000c4597          	auipc	a1,0xc4
ffffffffc020519a:	16f5bd23          	sd	a5,378(a1) # ffffffffc02c9310 <proc_list+0x8>
    elm->next = next;
ffffffffc020519e:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc02051a0:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc02051a2:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02051a6:	10e43023          	sd	a4,256(s0)
ffffffffc02051aa:	c311                	beqz	a4,ffffffffc02051ae <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc02051ac:	ff60                	sd	s0,248(a4)
    nr_process++;
ffffffffc02051ae:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc02051b2:	fae0                	sd	s0,240(a3)
    nr_process++;
ffffffffc02051b4:	2785                	addiw	a5,a5,1
ffffffffc02051b6:	000c4717          	auipc	a4,0xc4
ffffffffc02051ba:	00f72d23          	sw	a5,26(a4) # ffffffffc02c91d0 <nr_process>
    if (flag) {
ffffffffc02051be:	10091863          	bnez	s2,ffffffffc02052ce <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc02051c2:	8522                	mv	a0,s0
ffffffffc02051c4:	7fc030ef          	jal	ra,ffffffffc02089c0 <wakeup_proc>
    ret = proc->pid;
ffffffffc02051c8:	4048                	lw	a0,4(s0)
}
ffffffffc02051ca:	70a6                	ld	ra,104(sp)
ffffffffc02051cc:	7406                	ld	s0,96(sp)
ffffffffc02051ce:	64e6                	ld	s1,88(sp)
ffffffffc02051d0:	6946                	ld	s2,80(sp)
ffffffffc02051d2:	69a6                	ld	s3,72(sp)
ffffffffc02051d4:	6a06                	ld	s4,64(sp)
ffffffffc02051d6:	7ae2                	ld	s5,56(sp)
ffffffffc02051d8:	7b42                	ld	s6,48(sp)
ffffffffc02051da:	7ba2                	ld	s7,40(sp)
ffffffffc02051dc:	7c02                	ld	s8,32(sp)
ffffffffc02051de:	6ce2                	ld	s9,24(sp)
ffffffffc02051e0:	6d42                	ld	s10,16(sp)
ffffffffc02051e2:	6da2                	ld	s11,8(sp)
ffffffffc02051e4:	6165                	addi	sp,sp,112
ffffffffc02051e6:	8082                	ret
                if (++last_pid >= next_safe)
ffffffffc02051e8:	2785                	addiw	a5,a5,1
ffffffffc02051ea:	0ec7d563          	ble	a2,a5,ffffffffc02052d4 <do_fork+0x32c>
ffffffffc02051ee:	4585                	li	a1,1
ffffffffc02051f0:	bf35                	j	ffffffffc020512c <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02051f2:	8936                	mv	s2,a3
ffffffffc02051f4:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02051f8:	00000797          	auipc	a5,0x0
ffffffffc02051fc:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204d1a <forkret>
ffffffffc0205200:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205202:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205204:	100027f3          	csrr	a5,sstatus
ffffffffc0205208:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020520a:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020520c:	ec0785e3          	beqz	a5,ffffffffc02050d6 <do_fork+0x12e>
        intr_disable();
ffffffffc0205210:	c42fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
    if (++last_pid >= MAX_PID)
ffffffffc0205214:	000b9797          	auipc	a5,0xb9
ffffffffc0205218:	b3c78793          	addi	a5,a5,-1220 # ffffffffc02bdd50 <last_pid.1767>
ffffffffc020521c:	439c                	lw	a5,0(a5)
ffffffffc020521e:	6709                	lui	a4,0x2
        return 1;
ffffffffc0205220:	4905                	li	s2,1
ffffffffc0205222:	0017851b          	addiw	a0,a5,1
ffffffffc0205226:	000b9697          	auipc	a3,0xb9
ffffffffc020522a:	b2a6a523          	sw	a0,-1238(a3) # ffffffffc02bdd50 <last_pid.1767>
ffffffffc020522e:	ece542e3          	blt	a0,a4,ffffffffc02050f2 <do_fork+0x14a>
        last_pid = 1;
ffffffffc0205232:	4785                	li	a5,1
ffffffffc0205234:	000b9717          	auipc	a4,0xb9
ffffffffc0205238:	b0f72e23          	sw	a5,-1252(a4) # ffffffffc02bdd50 <last_pid.1767>
ffffffffc020523c:	4505                	li	a0,1
ffffffffc020523e:	b5e9                	j	ffffffffc0205108 <do_fork+0x160>
    if ((mm = mm_create()) == NULL)
ffffffffc0205240:	e77fe0ef          	jal	ra,ffffffffc02040b6 <mm_create>
ffffffffc0205244:	8d2a                	mv	s10,a0
ffffffffc0205246:	c539                	beqz	a0,ffffffffc0205294 <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0)
ffffffffc0205248:	be3ff0ef          	jal	ra,ffffffffc0204e2a <setup_pgdir>
ffffffffc020524c:	e949                	bnez	a0,ffffffffc02052de <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc020524e:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205252:	4785                	li	a5,1
ffffffffc0205254:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc0205258:	8b85                	andi	a5,a5,1
ffffffffc020525a:	4985                	li	s3,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020525c:	c799                	beqz	a5,ffffffffc020526a <do_fork+0x2c2>
        schedule();
ffffffffc020525e:	01d030ef          	jal	ra,ffffffffc0208a7a <schedule>
ffffffffc0205262:	413db7af          	amoor.d	a5,s3,(s11)
ffffffffc0205266:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc0205268:	fbfd                	bnez	a5,ffffffffc020525e <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc020526a:	85e2                	mv	a1,s8
ffffffffc020526c:	856a                	mv	a0,s10
ffffffffc020526e:	8d2ff0ef          	jal	ra,ffffffffc0204340 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205272:	57f9                	li	a5,-2
ffffffffc0205274:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc0205278:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc020527a:	c3e9                	beqz	a5,ffffffffc020533c <do_fork+0x394>
    if (ret != 0)
ffffffffc020527c:	8c6a                	mv	s8,s10
ffffffffc020527e:	de0502e3          	beqz	a0,ffffffffc0205062 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc0205282:	856a                	mv	a0,s10
ffffffffc0205284:	958ff0ef          	jal	ra,ffffffffc02043dc <exit_mmap>
    put_pgdir(mm);
ffffffffc0205288:	856a                	mv	a0,s10
ffffffffc020528a:	b23ff0ef          	jal	ra,ffffffffc0204dac <put_pgdir>
    mm_destroy(mm);
ffffffffc020528e:	856a                	mv	a0,s10
ffffffffc0205290:	fadfe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205294:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205296:	c02007b7          	lui	a5,0xc0200
ffffffffc020529a:	0cf6e963          	bltu	a3,a5,ffffffffc020536c <do_fork+0x3c4>
ffffffffc020529e:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc02052a2:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc02052a6:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02052aa:	83b1                	srli	a5,a5,0xc
ffffffffc02052ac:	0ae7f463          	bleu	a4,a5,ffffffffc0205354 <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc02052b0:	000b3703          	ld	a4,0(s6)
ffffffffc02052b4:	000ab503          	ld	a0,0(s5)
ffffffffc02052b8:	4589                	li	a1,2
ffffffffc02052ba:	8f99                	sub	a5,a5,a4
ffffffffc02052bc:	079a                	slli	a5,a5,0x6
ffffffffc02052be:	953e                	add	a0,a0,a5
ffffffffc02052c0:	c0bfc0ef          	jal	ra,ffffffffc0201eca <free_pages>
    kfree(proc);
ffffffffc02052c4:	8522                	mv	a0,s0
ffffffffc02052c6:	a3dfc0ef          	jal	ra,ffffffffc0201d02 <kfree>
    ret = -E_NO_MEM;
ffffffffc02052ca:	5571                	li	a0,-4
    return ret;
ffffffffc02052cc:	bdfd                	j	ffffffffc02051ca <do_fork+0x222>
        intr_enable();
ffffffffc02052ce:	b7efb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc02052d2:	bdc5                	j	ffffffffc02051c2 <do_fork+0x21a>
                    if (last_pid >= MAX_PID)
ffffffffc02052d4:	0117c363          	blt	a5,a7,ffffffffc02052da <do_fork+0x332>
                        last_pid = 1;
ffffffffc02052d8:	4785                	li	a5,1
                    goto repeat;
ffffffffc02052da:	4585                	li	a1,1
ffffffffc02052dc:	b591                	j	ffffffffc0205120 <do_fork+0x178>
    mm_destroy(mm);
ffffffffc02052de:	856a                	mv	a0,s10
ffffffffc02052e0:	f5dfe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
ffffffffc02052e4:	bf45                	j	ffffffffc0205294 <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc02052e6:	556d                	li	a0,-5
ffffffffc02052e8:	b5cd                	j	ffffffffc02051ca <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc02052ea:	00005617          	auipc	a2,0x5
ffffffffc02052ee:	bc660613          	addi	a2,a2,-1082 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc02052f2:	06900593          	li	a1,105
ffffffffc02052f6:	00005517          	auipc	a0,0x5
ffffffffc02052fa:	be250513          	addi	a0,a0,-1054 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc02052fe:	98afb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(current->wait_state == 0);
ffffffffc0205302:	00006697          	auipc	a3,0x6
ffffffffc0205306:	dfe68693          	addi	a3,a3,-514 # ffffffffc020b100 <default_pmm_manager+0x12a0>
ffffffffc020530a:	00004617          	auipc	a2,0x4
ffffffffc020530e:	40e60613          	addi	a2,a2,1038 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0205312:	1eb00593          	li	a1,491
ffffffffc0205316:	00006517          	auipc	a0,0x6
ffffffffc020531a:	09250513          	addi	a0,a0,146 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc020531e:	96afb0ef          	jal	ra,ffffffffc0200488 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205322:	86be                	mv	a3,a5
ffffffffc0205324:	00005617          	auipc	a2,0x5
ffffffffc0205328:	bc460613          	addi	a2,a2,-1084 # ffffffffc0209ee8 <default_pmm_manager+0x88>
ffffffffc020532c:	19b00593          	li	a1,411
ffffffffc0205330:	00006517          	auipc	a0,0x6
ffffffffc0205334:	07850513          	addi	a0,a0,120 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205338:	950fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("Unlock failed.\n");
ffffffffc020533c:	00006617          	auipc	a2,0x6
ffffffffc0205340:	de460613          	addi	a2,a2,-540 # ffffffffc020b120 <default_pmm_manager+0x12c0>
ffffffffc0205344:	03200593          	li	a1,50
ffffffffc0205348:	00006517          	auipc	a0,0x6
ffffffffc020534c:	de850513          	addi	a0,a0,-536 # ffffffffc020b130 <default_pmm_manager+0x12d0>
ffffffffc0205350:	938fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205354:	00005617          	auipc	a2,0x5
ffffffffc0205358:	bbc60613          	addi	a2,a2,-1092 # ffffffffc0209f10 <default_pmm_manager+0xb0>
ffffffffc020535c:	06200593          	li	a1,98
ffffffffc0205360:	00005517          	auipc	a0,0x5
ffffffffc0205364:	b7850513          	addi	a0,a0,-1160 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0205368:	920fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020536c:	00005617          	auipc	a2,0x5
ffffffffc0205370:	b7c60613          	addi	a2,a2,-1156 # ffffffffc0209ee8 <default_pmm_manager+0x88>
ffffffffc0205374:	06e00593          	li	a1,110
ffffffffc0205378:	00005517          	auipc	a0,0x5
ffffffffc020537c:	b6050513          	addi	a0,a0,-1184 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0205380:	908fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205384 <kernel_thread>:
{
ffffffffc0205384:	7129                	addi	sp,sp,-320
ffffffffc0205386:	fa22                	sd	s0,304(sp)
ffffffffc0205388:	f626                	sd	s1,296(sp)
ffffffffc020538a:	f24a                	sd	s2,288(sp)
ffffffffc020538c:	84ae                	mv	s1,a1
ffffffffc020538e:	892a                	mv	s2,a0
ffffffffc0205390:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205392:	4581                	li	a1,0
ffffffffc0205394:	12000613          	li	a2,288
ffffffffc0205398:	850a                	mv	a0,sp
{
ffffffffc020539a:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020539c:	55d030ef          	jal	ra,ffffffffc02090f8 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02053a0:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02053a2:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02053a4:	100027f3          	csrr	a5,sstatus
ffffffffc02053a8:	edd7f793          	andi	a5,a5,-291
ffffffffc02053ac:	1207e793          	ori	a5,a5,288
ffffffffc02053b0:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053b2:	860a                	mv	a2,sp
ffffffffc02053b4:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053b8:	00000797          	auipc	a5,0x0
ffffffffc02053bc:	8c278793          	addi	a5,a5,-1854 # ffffffffc0204c7a <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053c0:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053c2:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053c4:	be5ff0ef          	jal	ra,ffffffffc0204fa8 <do_fork>
}
ffffffffc02053c8:	70f2                	ld	ra,312(sp)
ffffffffc02053ca:	7452                	ld	s0,304(sp)
ffffffffc02053cc:	74b2                	ld	s1,296(sp)
ffffffffc02053ce:	7912                	ld	s2,288(sp)
ffffffffc02053d0:	6131                	addi	sp,sp,320
ffffffffc02053d2:	8082                	ret

ffffffffc02053d4 <do_exit>:
{
ffffffffc02053d4:	7179                	addi	sp,sp,-48
ffffffffc02053d6:	e84a                	sd	s2,16(sp)
    if (current == idleproc)
ffffffffc02053d8:	000c4717          	auipc	a4,0xc4
ffffffffc02053dc:	de870713          	addi	a4,a4,-536 # ffffffffc02c91c0 <idleproc>
ffffffffc02053e0:	000c4917          	auipc	s2,0xc4
ffffffffc02053e4:	dd890913          	addi	s2,s2,-552 # ffffffffc02c91b8 <current>
ffffffffc02053e8:	00093783          	ld	a5,0(s2)
ffffffffc02053ec:	6318                	ld	a4,0(a4)
{
ffffffffc02053ee:	f406                	sd	ra,40(sp)
ffffffffc02053f0:	f022                	sd	s0,32(sp)
ffffffffc02053f2:	ec26                	sd	s1,24(sp)
ffffffffc02053f4:	e44e                	sd	s3,8(sp)
ffffffffc02053f6:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc02053f8:	0ce78c63          	beq	a5,a4,ffffffffc02054d0 <do_exit+0xfc>
    if (current == initproc)
ffffffffc02053fc:	000c4417          	auipc	s0,0xc4
ffffffffc0205400:	dcc40413          	addi	s0,s0,-564 # ffffffffc02c91c8 <initproc>
ffffffffc0205404:	6018                	ld	a4,0(s0)
ffffffffc0205406:	0ee78b63          	beq	a5,a4,ffffffffc02054fc <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc020540a:	7784                	ld	s1,40(a5)
ffffffffc020540c:	89aa                	mv	s3,a0
    if (mm != NULL)
ffffffffc020540e:	c48d                	beqz	s1,ffffffffc0205438 <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc0205410:	000c4797          	auipc	a5,0xc4
ffffffffc0205414:	e0878793          	addi	a5,a5,-504 # ffffffffc02c9218 <boot_cr3>
ffffffffc0205418:	639c                	ld	a5,0(a5)
ffffffffc020541a:	577d                	li	a4,-1
ffffffffc020541c:	177e                	slli	a4,a4,0x3f
ffffffffc020541e:	83b1                	srli	a5,a5,0xc
ffffffffc0205420:	8fd9                	or	a5,a5,a4
ffffffffc0205422:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205426:	589c                	lw	a5,48(s1)
ffffffffc0205428:	fff7871b          	addiw	a4,a5,-1
ffffffffc020542c:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0)
ffffffffc020542e:	cf4d                	beqz	a4,ffffffffc02054e8 <do_exit+0x114>
        current->mm = NULL;
ffffffffc0205430:	00093783          	ld	a5,0(s2)
ffffffffc0205434:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205438:	00093783          	ld	a5,0(s2)
ffffffffc020543c:	470d                	li	a4,3
ffffffffc020543e:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205440:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205444:	100027f3          	csrr	a5,sstatus
ffffffffc0205448:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020544a:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020544c:	e7e1                	bnez	a5,ffffffffc0205514 <do_exit+0x140>
        proc = current->parent;
ffffffffc020544e:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD)
ffffffffc0205452:	800007b7          	lui	a5,0x80000
ffffffffc0205456:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205458:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc020545a:	0ec52703          	lw	a4,236(a0)
ffffffffc020545e:	0af70f63          	beq	a4,a5,ffffffffc020551c <do_exit+0x148>
ffffffffc0205462:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD)
ffffffffc0205466:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc020546a:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc020546c:	0985                	addi	s3,s3,1
        while (current->cptr != NULL)
ffffffffc020546e:	7afc                	ld	a5,240(a3)
ffffffffc0205470:	cb95                	beqz	a5,ffffffffc02054a4 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc0205472:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_matrix_out_size+0xffffffff7fff46a8>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0205476:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc0205478:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020547a:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020547c:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0205480:	10e7b023          	sd	a4,256(a5)
ffffffffc0205484:	c311                	beqz	a4,ffffffffc0205488 <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc0205486:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0205488:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020548a:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020548c:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020548e:	fe9710e3          	bne	a4,s1,ffffffffc020546e <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0205492:	0ec52783          	lw	a5,236(a0)
ffffffffc0205496:	fd379ce3          	bne	a5,s3,ffffffffc020546e <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020549a:	526030ef          	jal	ra,ffffffffc02089c0 <wakeup_proc>
ffffffffc020549e:	00093683          	ld	a3,0(s2)
ffffffffc02054a2:	b7f1                	j	ffffffffc020546e <do_exit+0x9a>
    if (flag) {
ffffffffc02054a4:	020a1363          	bnez	s4,ffffffffc02054ca <do_exit+0xf6>
    schedule();
ffffffffc02054a8:	5d2030ef          	jal	ra,ffffffffc0208a7a <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02054ac:	00093783          	ld	a5,0(s2)
ffffffffc02054b0:	00006617          	auipc	a2,0x6
ffffffffc02054b4:	c3060613          	addi	a2,a2,-976 # ffffffffc020b0e0 <default_pmm_manager+0x1280>
ffffffffc02054b8:	24900593          	li	a1,585
ffffffffc02054bc:	43d4                	lw	a3,4(a5)
ffffffffc02054be:	00006517          	auipc	a0,0x6
ffffffffc02054c2:	eea50513          	addi	a0,a0,-278 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc02054c6:	fc3fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        intr_enable();
ffffffffc02054ca:	982fb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc02054ce:	bfe9                	j	ffffffffc02054a8 <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc02054d0:	00006617          	auipc	a2,0x6
ffffffffc02054d4:	bf060613          	addi	a2,a2,-1040 # ffffffffc020b0c0 <default_pmm_manager+0x1260>
ffffffffc02054d8:	21500593          	li	a1,533
ffffffffc02054dc:	00006517          	auipc	a0,0x6
ffffffffc02054e0:	ecc50513          	addi	a0,a0,-308 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc02054e4:	fa5fa0ef          	jal	ra,ffffffffc0200488 <__panic>
            exit_mmap(mm);
ffffffffc02054e8:	8526                	mv	a0,s1
ffffffffc02054ea:	ef3fe0ef          	jal	ra,ffffffffc02043dc <exit_mmap>
            put_pgdir(mm);
ffffffffc02054ee:	8526                	mv	a0,s1
ffffffffc02054f0:	8bdff0ef          	jal	ra,ffffffffc0204dac <put_pgdir>
            mm_destroy(mm);
ffffffffc02054f4:	8526                	mv	a0,s1
ffffffffc02054f6:	d47fe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
ffffffffc02054fa:	bf1d                	j	ffffffffc0205430 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc02054fc:	00006617          	auipc	a2,0x6
ffffffffc0205500:	bd460613          	addi	a2,a2,-1068 # ffffffffc020b0d0 <default_pmm_manager+0x1270>
ffffffffc0205504:	21900593          	li	a1,537
ffffffffc0205508:	00006517          	auipc	a0,0x6
ffffffffc020550c:	ea050513          	addi	a0,a0,-352 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205510:	f79fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        intr_disable();
ffffffffc0205514:	93efb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0205518:	4a05                	li	s4,1
ffffffffc020551a:	bf15                	j	ffffffffc020544e <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc020551c:	4a4030ef          	jal	ra,ffffffffc02089c0 <wakeup_proc>
ffffffffc0205520:	b789                	j	ffffffffc0205462 <do_exit+0x8e>

ffffffffc0205522 <do_wait.part.1>:
int do_wait(int pid, int *code_store)
ffffffffc0205522:	7139                	addi	sp,sp,-64
ffffffffc0205524:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205526:	80000a37          	lui	s4,0x80000
int do_wait(int pid, int *code_store)
ffffffffc020552a:	f426                	sd	s1,40(sp)
ffffffffc020552c:	f04a                	sd	s2,32(sp)
ffffffffc020552e:	ec4e                	sd	s3,24(sp)
ffffffffc0205530:	e456                	sd	s5,8(sp)
ffffffffc0205532:	e05a                	sd	s6,0(sp)
ffffffffc0205534:	fc06                	sd	ra,56(sp)
ffffffffc0205536:	f822                	sd	s0,48(sp)
ffffffffc0205538:	89aa                	mv	s3,a0
ffffffffc020553a:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc020553c:	000c4917          	auipc	s2,0xc4
ffffffffc0205540:	c7c90913          	addi	s2,s2,-900 # ffffffffc02c91b8 <current>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0205544:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0205546:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc0205548:	2a05                	addiw	s4,s4,1
    if (pid != 0)
ffffffffc020554a:	02098f63          	beqz	s3,ffffffffc0205588 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc020554e:	854e                	mv	a0,s3
ffffffffc0205550:	9fdff0ef          	jal	ra,ffffffffc0204f4c <find_proc>
ffffffffc0205554:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current)
ffffffffc0205556:	12050063          	beqz	a0,ffffffffc0205676 <do_wait.part.1+0x154>
ffffffffc020555a:	00093703          	ld	a4,0(s2)
ffffffffc020555e:	711c                	ld	a5,32(a0)
ffffffffc0205560:	10e79b63          	bne	a5,a4,ffffffffc0205676 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0205564:	411c                	lw	a5,0(a0)
ffffffffc0205566:	02978c63          	beq	a5,s1,ffffffffc020559e <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc020556a:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc020556e:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205572:	508030ef          	jal	ra,ffffffffc0208a7a <schedule>
        if (current->flags & PF_EXITING)
ffffffffc0205576:	00093783          	ld	a5,0(s2)
ffffffffc020557a:	0b07a783          	lw	a5,176(a5)
ffffffffc020557e:	8b85                	andi	a5,a5,1
ffffffffc0205580:	d7e9                	beqz	a5,ffffffffc020554a <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc0205582:	555d                	li	a0,-9
ffffffffc0205584:	e51ff0ef          	jal	ra,ffffffffc02053d4 <do_exit>
        proc = current->cptr;
ffffffffc0205588:	00093703          	ld	a4,0(s2)
ffffffffc020558c:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr)
ffffffffc020558e:	e409                	bnez	s0,ffffffffc0205598 <do_wait.part.1+0x76>
ffffffffc0205590:	a0dd                	j	ffffffffc0205676 <do_wait.part.1+0x154>
ffffffffc0205592:	10043403          	ld	s0,256(s0)
ffffffffc0205596:	d871                	beqz	s0,ffffffffc020556a <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0205598:	401c                	lw	a5,0(s0)
ffffffffc020559a:	fe979ce3          	bne	a5,s1,ffffffffc0205592 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc)
ffffffffc020559e:	000c4797          	auipc	a5,0xc4
ffffffffc02055a2:	c2278793          	addi	a5,a5,-990 # ffffffffc02c91c0 <idleproc>
ffffffffc02055a6:	639c                	ld	a5,0(a5)
ffffffffc02055a8:	0c878d63          	beq	a5,s0,ffffffffc0205682 <do_wait.part.1+0x160>
ffffffffc02055ac:	000c4797          	auipc	a5,0xc4
ffffffffc02055b0:	c1c78793          	addi	a5,a5,-996 # ffffffffc02c91c8 <initproc>
ffffffffc02055b4:	639c                	ld	a5,0(a5)
ffffffffc02055b6:	0cf40663          	beq	s0,a5,ffffffffc0205682 <do_wait.part.1+0x160>
    if (code_store != NULL)
ffffffffc02055ba:	000b0663          	beqz	s6,ffffffffc02055c6 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc02055be:	0e842783          	lw	a5,232(s0)
ffffffffc02055c2:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055c6:	100027f3          	csrr	a5,sstatus
ffffffffc02055ca:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055cc:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055ce:	e7d5                	bnez	a5,ffffffffc020567a <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc02055d0:	6c70                	ld	a2,216(s0)
ffffffffc02055d2:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc02055d4:	10043703          	ld	a4,256(s0)
ffffffffc02055d8:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02055da:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055dc:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02055de:	6470                	ld	a2,200(s0)
ffffffffc02055e0:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02055e2:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055e4:	e290                	sd	a2,0(a3)
ffffffffc02055e6:	c319                	beqz	a4,ffffffffc02055ec <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc02055e8:	ff7c                	sd	a5,248(a4)
ffffffffc02055ea:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL)
ffffffffc02055ec:	c3d1                	beqz	a5,ffffffffc0205670 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc02055ee:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc02055f2:	000c4797          	auipc	a5,0xc4
ffffffffc02055f6:	bde78793          	addi	a5,a5,-1058 # ffffffffc02c91d0 <nr_process>
ffffffffc02055fa:	439c                	lw	a5,0(a5)
ffffffffc02055fc:	37fd                	addiw	a5,a5,-1
ffffffffc02055fe:	000c4717          	auipc	a4,0xc4
ffffffffc0205602:	bcf72923          	sw	a5,-1070(a4) # ffffffffc02c91d0 <nr_process>
    if (flag) {
ffffffffc0205606:	e1b5                	bnez	a1,ffffffffc020566a <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205608:	6814                	ld	a3,16(s0)
ffffffffc020560a:	c02007b7          	lui	a5,0xc0200
ffffffffc020560e:	0af6e263          	bltu	a3,a5,ffffffffc02056b2 <do_wait.part.1+0x190>
ffffffffc0205612:	000c4797          	auipc	a5,0xc4
ffffffffc0205616:	bfe78793          	addi	a5,a5,-1026 # ffffffffc02c9210 <va_pa_offset>
ffffffffc020561a:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020561c:	000c4797          	auipc	a5,0xc4
ffffffffc0205620:	b8478793          	addi	a5,a5,-1148 # ffffffffc02c91a0 <npage>
ffffffffc0205624:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205626:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205628:	82b1                	srli	a3,a3,0xc
ffffffffc020562a:	06f6f863          	bleu	a5,a3,ffffffffc020569a <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc020562e:	00007797          	auipc	a5,0x7
ffffffffc0205632:	97278793          	addi	a5,a5,-1678 # ffffffffc020bfa0 <nbase>
ffffffffc0205636:	639c                	ld	a5,0(a5)
ffffffffc0205638:	000c4717          	auipc	a4,0xc4
ffffffffc020563c:	be870713          	addi	a4,a4,-1048 # ffffffffc02c9220 <pages>
ffffffffc0205640:	6308                	ld	a0,0(a4)
ffffffffc0205642:	8e9d                	sub	a3,a3,a5
ffffffffc0205644:	069a                	slli	a3,a3,0x6
ffffffffc0205646:	9536                	add	a0,a0,a3
ffffffffc0205648:	4589                	li	a1,2
ffffffffc020564a:	881fc0ef          	jal	ra,ffffffffc0201eca <free_pages>
    kfree(proc);
ffffffffc020564e:	8522                	mv	a0,s0
ffffffffc0205650:	eb2fc0ef          	jal	ra,ffffffffc0201d02 <kfree>
    return 0;
ffffffffc0205654:	4501                	li	a0,0
}
ffffffffc0205656:	70e2                	ld	ra,56(sp)
ffffffffc0205658:	7442                	ld	s0,48(sp)
ffffffffc020565a:	74a2                	ld	s1,40(sp)
ffffffffc020565c:	7902                	ld	s2,32(sp)
ffffffffc020565e:	69e2                	ld	s3,24(sp)
ffffffffc0205660:	6a42                	ld	s4,16(sp)
ffffffffc0205662:	6aa2                	ld	s5,8(sp)
ffffffffc0205664:	6b02                	ld	s6,0(sp)
ffffffffc0205666:	6121                	addi	sp,sp,64
ffffffffc0205668:	8082                	ret
        intr_enable();
ffffffffc020566a:	fe3fa0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc020566e:	bf69                	j	ffffffffc0205608 <do_wait.part.1+0xe6>
        proc->parent->cptr = proc->optr;
ffffffffc0205670:	701c                	ld	a5,32(s0)
ffffffffc0205672:	fbf8                	sd	a4,240(a5)
ffffffffc0205674:	bfbd                	j	ffffffffc02055f2 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc0205676:	5579                	li	a0,-2
ffffffffc0205678:	bff9                	j	ffffffffc0205656 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc020567a:	fd9fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc020567e:	4585                	li	a1,1
ffffffffc0205680:	bf81                	j	ffffffffc02055d0 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc0205682:	00006617          	auipc	a2,0x6
ffffffffc0205686:	ac660613          	addi	a2,a2,-1338 # ffffffffc020b148 <default_pmm_manager+0x12e8>
ffffffffc020568a:	36a00593          	li	a1,874
ffffffffc020568e:	00006517          	auipc	a0,0x6
ffffffffc0205692:	d1a50513          	addi	a0,a0,-742 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205696:	df3fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020569a:	00005617          	auipc	a2,0x5
ffffffffc020569e:	87660613          	addi	a2,a2,-1930 # ffffffffc0209f10 <default_pmm_manager+0xb0>
ffffffffc02056a2:	06200593          	li	a1,98
ffffffffc02056a6:	00005517          	auipc	a0,0x5
ffffffffc02056aa:	83250513          	addi	a0,a0,-1998 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc02056ae:	ddbfa0ef          	jal	ra,ffffffffc0200488 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02056b2:	00005617          	auipc	a2,0x5
ffffffffc02056b6:	83660613          	addi	a2,a2,-1994 # ffffffffc0209ee8 <default_pmm_manager+0x88>
ffffffffc02056ba:	06e00593          	li	a1,110
ffffffffc02056be:	00005517          	auipc	a0,0x5
ffffffffc02056c2:	81a50513          	addi	a0,a0,-2022 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc02056c6:	dc3fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02056ca <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc02056ca:	1141                	addi	sp,sp,-16
ffffffffc02056cc:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02056ce:	843fc0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02056d2:	d70fc0ef          	jal	ra,ffffffffc0201c42 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02056d6:	4601                	li	a2,0
ffffffffc02056d8:	4581                	li	a1,0
ffffffffc02056da:	fffff517          	auipc	a0,0xfffff
ffffffffc02056de:	65050513          	addi	a0,a0,1616 # ffffffffc0204d2a <user_main>
ffffffffc02056e2:	ca3ff0ef          	jal	ra,ffffffffc0205384 <kernel_thread>
    if (pid <= 0)
ffffffffc02056e6:	00a04563          	bgtz	a0,ffffffffc02056f0 <init_main+0x26>
ffffffffc02056ea:	a841                	j	ffffffffc020577a <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc02056ec:	38e030ef          	jal	ra,ffffffffc0208a7a <schedule>
    if (code_store != NULL)
ffffffffc02056f0:	4581                	li	a1,0
ffffffffc02056f2:	4501                	li	a0,0
ffffffffc02056f4:	e2fff0ef          	jal	ra,ffffffffc0205522 <do_wait.part.1>
    while (do_wait(0, NULL) == 0)
ffffffffc02056f8:	d975                	beqz	a0,ffffffffc02056ec <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02056fa:	00006517          	auipc	a0,0x6
ffffffffc02056fe:	a8e50513          	addi	a0,a0,-1394 # ffffffffc020b188 <default_pmm_manager+0x1328>
ffffffffc0205702:	a91fa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205706:	000c4797          	auipc	a5,0xc4
ffffffffc020570a:	ac278793          	addi	a5,a5,-1342 # ffffffffc02c91c8 <initproc>
ffffffffc020570e:	639c                	ld	a5,0(a5)
ffffffffc0205710:	7bf8                	ld	a4,240(a5)
ffffffffc0205712:	e721                	bnez	a4,ffffffffc020575a <init_main+0x90>
ffffffffc0205714:	7ff8                	ld	a4,248(a5)
ffffffffc0205716:	e331                	bnez	a4,ffffffffc020575a <init_main+0x90>
ffffffffc0205718:	1007b703          	ld	a4,256(a5)
ffffffffc020571c:	ef1d                	bnez	a4,ffffffffc020575a <init_main+0x90>
    assert(nr_process == 2);
ffffffffc020571e:	000c4717          	auipc	a4,0xc4
ffffffffc0205722:	ab270713          	addi	a4,a4,-1358 # ffffffffc02c91d0 <nr_process>
ffffffffc0205726:	4314                	lw	a3,0(a4)
ffffffffc0205728:	4709                	li	a4,2
ffffffffc020572a:	0ae69463          	bne	a3,a4,ffffffffc02057d2 <init_main+0x108>
    return listelm->next;
ffffffffc020572e:	000c4697          	auipc	a3,0xc4
ffffffffc0205732:	bda68693          	addi	a3,a3,-1062 # ffffffffc02c9308 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205736:	6698                	ld	a4,8(a3)
ffffffffc0205738:	0c878793          	addi	a5,a5,200
ffffffffc020573c:	06f71b63          	bne	a4,a5,ffffffffc02057b2 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205740:	629c                	ld	a5,0(a3)
ffffffffc0205742:	04f71863          	bne	a4,a5,ffffffffc0205792 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc0205746:	00006517          	auipc	a0,0x6
ffffffffc020574a:	b2a50513          	addi	a0,a0,-1238 # ffffffffc020b270 <default_pmm_manager+0x1410>
ffffffffc020574e:	a45fa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    return 0;
}
ffffffffc0205752:	60a2                	ld	ra,8(sp)
ffffffffc0205754:	4501                	li	a0,0
ffffffffc0205756:	0141                	addi	sp,sp,16
ffffffffc0205758:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020575a:	00006697          	auipc	a3,0x6
ffffffffc020575e:	a5668693          	addi	a3,a3,-1450 # ffffffffc020b1b0 <default_pmm_manager+0x1350>
ffffffffc0205762:	00004617          	auipc	a2,0x4
ffffffffc0205766:	fb660613          	addi	a2,a2,-74 # ffffffffc0209718 <commands+0x4c0>
ffffffffc020576a:	3d700593          	li	a1,983
ffffffffc020576e:	00006517          	auipc	a0,0x6
ffffffffc0205772:	c3a50513          	addi	a0,a0,-966 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205776:	d13fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("create user_main failed.\n");
ffffffffc020577a:	00006617          	auipc	a2,0x6
ffffffffc020577e:	9ee60613          	addi	a2,a2,-1554 # ffffffffc020b168 <default_pmm_manager+0x1308>
ffffffffc0205782:	3ce00593          	li	a1,974
ffffffffc0205786:	00006517          	auipc	a0,0x6
ffffffffc020578a:	c2250513          	addi	a0,a0,-990 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc020578e:	cfbfa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205792:	00006697          	auipc	a3,0x6
ffffffffc0205796:	aae68693          	addi	a3,a3,-1362 # ffffffffc020b240 <default_pmm_manager+0x13e0>
ffffffffc020579a:	00004617          	auipc	a2,0x4
ffffffffc020579e:	f7e60613          	addi	a2,a2,-130 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02057a2:	3da00593          	li	a1,986
ffffffffc02057a6:	00006517          	auipc	a0,0x6
ffffffffc02057aa:	c0250513          	addi	a0,a0,-1022 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc02057ae:	cdbfa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057b2:	00006697          	auipc	a3,0x6
ffffffffc02057b6:	a5e68693          	addi	a3,a3,-1442 # ffffffffc020b210 <default_pmm_manager+0x13b0>
ffffffffc02057ba:	00004617          	auipc	a2,0x4
ffffffffc02057be:	f5e60613          	addi	a2,a2,-162 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02057c2:	3d900593          	li	a1,985
ffffffffc02057c6:	00006517          	auipc	a0,0x6
ffffffffc02057ca:	be250513          	addi	a0,a0,-1054 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc02057ce:	cbbfa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_process == 2);
ffffffffc02057d2:	00006697          	auipc	a3,0x6
ffffffffc02057d6:	a2e68693          	addi	a3,a3,-1490 # ffffffffc020b200 <default_pmm_manager+0x13a0>
ffffffffc02057da:	00004617          	auipc	a2,0x4
ffffffffc02057de:	f3e60613          	addi	a2,a2,-194 # ffffffffc0209718 <commands+0x4c0>
ffffffffc02057e2:	3d800593          	li	a1,984
ffffffffc02057e6:	00006517          	auipc	a0,0x6
ffffffffc02057ea:	bc250513          	addi	a0,a0,-1086 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc02057ee:	c9bfa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02057f2 <do_execve>:
{
ffffffffc02057f2:	7135                	addi	sp,sp,-160
ffffffffc02057f4:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02057f6:	000c4a17          	auipc	s4,0xc4
ffffffffc02057fa:	9c2a0a13          	addi	s4,s4,-1598 # ffffffffc02c91b8 <current>
ffffffffc02057fe:	000a3783          	ld	a5,0(s4)
{
ffffffffc0205802:	e14a                	sd	s2,128(sp)
ffffffffc0205804:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205806:	0287b903          	ld	s2,40(a5)
{
ffffffffc020580a:	fcce                	sd	s3,120(sp)
ffffffffc020580c:	f0da                	sd	s6,96(sp)
ffffffffc020580e:	89aa                	mv	s3,a0
ffffffffc0205810:	842e                	mv	s0,a1
ffffffffc0205812:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0205814:	4681                	li	a3,0
ffffffffc0205816:	862e                	mv	a2,a1
ffffffffc0205818:	85aa                	mv	a1,a0
ffffffffc020581a:	854a                	mv	a0,s2
{
ffffffffc020581c:	ed06                	sd	ra,152(sp)
ffffffffc020581e:	e526                	sd	s1,136(sp)
ffffffffc0205820:	f4d6                	sd	s5,104(sp)
ffffffffc0205822:	ecde                	sd	s7,88(sp)
ffffffffc0205824:	e8e2                	sd	s8,80(sp)
ffffffffc0205826:	e4e6                	sd	s9,72(sp)
ffffffffc0205828:	e0ea                	sd	s10,64(sp)
ffffffffc020582a:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc020582c:	a52ff0ef          	jal	ra,ffffffffc0204a7e <user_mem_check>
ffffffffc0205830:	40050663          	beqz	a0,ffffffffc0205c3c <do_execve+0x44a>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205834:	4641                	li	a2,16
ffffffffc0205836:	4581                	li	a1,0
ffffffffc0205838:	1008                	addi	a0,sp,32
ffffffffc020583a:	0bf030ef          	jal	ra,ffffffffc02090f8 <memset>
    memcpy(local_name, name, len);
ffffffffc020583e:	47bd                	li	a5,15
ffffffffc0205840:	8622                	mv	a2,s0
ffffffffc0205842:	0687ee63          	bltu	a5,s0,ffffffffc02058be <do_execve+0xcc>
ffffffffc0205846:	85ce                	mv	a1,s3
ffffffffc0205848:	1008                	addi	a0,sp,32
ffffffffc020584a:	0c1030ef          	jal	ra,ffffffffc020910a <memcpy>
    if (mm != NULL)
ffffffffc020584e:	06090f63          	beqz	s2,ffffffffc02058cc <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205852:	00005517          	auipc	a0,0x5
ffffffffc0205856:	e0650513          	addi	a0,a0,-506 # ffffffffc020a658 <default_pmm_manager+0x7f8>
ffffffffc020585a:	971fa0ef          	jal	ra,ffffffffc02001ca <cputs>
        lcr3(boot_cr3);
ffffffffc020585e:	000c4797          	auipc	a5,0xc4
ffffffffc0205862:	9ba78793          	addi	a5,a5,-1606 # ffffffffc02c9218 <boot_cr3>
ffffffffc0205866:	639c                	ld	a5,0(a5)
ffffffffc0205868:	577d                	li	a4,-1
ffffffffc020586a:	177e                	slli	a4,a4,0x3f
ffffffffc020586c:	83b1                	srli	a5,a5,0xc
ffffffffc020586e:	8fd9                	or	a5,a5,a4
ffffffffc0205870:	18079073          	csrw	satp,a5
ffffffffc0205874:	03092783          	lw	a5,48(s2)
ffffffffc0205878:	fff7871b          	addiw	a4,a5,-1
ffffffffc020587c:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0)
ffffffffc0205880:	28070d63          	beqz	a4,ffffffffc0205b1a <do_execve+0x328>
        current->mm = NULL;
ffffffffc0205884:	000a3783          	ld	a5,0(s4)
ffffffffc0205888:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc020588c:	82bfe0ef          	jal	ra,ffffffffc02040b6 <mm_create>
ffffffffc0205890:	892a                	mv	s2,a0
ffffffffc0205892:	c135                	beqz	a0,ffffffffc02058f6 <do_execve+0x104>
    if (setup_pgdir(mm) != 0)
ffffffffc0205894:	d96ff0ef          	jal	ra,ffffffffc0204e2a <setup_pgdir>
ffffffffc0205898:	e931                	bnez	a0,ffffffffc02058ec <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc020589a:	000b2703          	lw	a4,0(s6)
ffffffffc020589e:	464c47b7          	lui	a5,0x464c4
ffffffffc02058a2:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b8b27>
ffffffffc02058a6:	04f70a63          	beq	a4,a5,ffffffffc02058fa <do_execve+0x108>
    put_pgdir(mm);
ffffffffc02058aa:	854a                	mv	a0,s2
ffffffffc02058ac:	d00ff0ef          	jal	ra,ffffffffc0204dac <put_pgdir>
    mm_destroy(mm);
ffffffffc02058b0:	854a                	mv	a0,s2
ffffffffc02058b2:	98bfe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02058b6:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc02058b8:	854e                	mv	a0,s3
ffffffffc02058ba:	b1bff0ef          	jal	ra,ffffffffc02053d4 <do_exit>
    memcpy(local_name, name, len);
ffffffffc02058be:	463d                	li	a2,15
ffffffffc02058c0:	85ce                	mv	a1,s3
ffffffffc02058c2:	1008                	addi	a0,sp,32
ffffffffc02058c4:	047030ef          	jal	ra,ffffffffc020910a <memcpy>
    if (mm != NULL)
ffffffffc02058c8:	f80915e3          	bnez	s2,ffffffffc0205852 <do_execve+0x60>
    if (current->mm != NULL)
ffffffffc02058cc:	000a3783          	ld	a5,0(s4)
ffffffffc02058d0:	779c                	ld	a5,40(a5)
ffffffffc02058d2:	dfcd                	beqz	a5,ffffffffc020588c <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02058d4:	00005617          	auipc	a2,0x5
ffffffffc02058d8:	66460613          	addi	a2,a2,1636 # ffffffffc020af38 <default_pmm_manager+0x10d8>
ffffffffc02058dc:	25500593          	li	a1,597
ffffffffc02058e0:	00006517          	auipc	a0,0x6
ffffffffc02058e4:	ac850513          	addi	a0,a0,-1336 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc02058e8:	ba1fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    mm_destroy(mm);
ffffffffc02058ec:	854a                	mv	a0,s2
ffffffffc02058ee:	94ffe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc02058f2:	59f1                	li	s3,-4
ffffffffc02058f4:	b7d1                	j	ffffffffc02058b8 <do_execve+0xc6>
ffffffffc02058f6:	59f1                	li	s3,-4
ffffffffc02058f8:	b7c1                	j	ffffffffc02058b8 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02058fa:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02058fe:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205902:	00371793          	slli	a5,a4,0x3
ffffffffc0205906:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205908:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020590a:	078e                	slli	a5,a5,0x3
ffffffffc020590c:	97a2                	add	a5,a5,s0
ffffffffc020590e:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph++)
ffffffffc0205910:	02f47b63          	bleu	a5,s0,ffffffffc0205946 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc0205914:	5bfd                	li	s7,-1
ffffffffc0205916:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc020591a:	000c4d97          	auipc	s11,0xc4
ffffffffc020591e:	906d8d93          	addi	s11,s11,-1786 # ffffffffc02c9220 <pages>
ffffffffc0205922:	00006d17          	auipc	s10,0x6
ffffffffc0205926:	67ed0d13          	addi	s10,s10,1662 # ffffffffc020bfa0 <nbase>
    return KADDR(page2pa(page));
ffffffffc020592a:	e43e                	sd	a5,8(sp)
ffffffffc020592c:	000c4c97          	auipc	s9,0xc4
ffffffffc0205930:	874c8c93          	addi	s9,s9,-1932 # ffffffffc02c91a0 <npage>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0205934:	4018                	lw	a4,0(s0)
ffffffffc0205936:	4785                	li	a5,1
ffffffffc0205938:	0ef70f63          	beq	a4,a5,ffffffffc0205a36 <do_execve+0x244>
    for (; ph < ph_end; ph++)
ffffffffc020593c:	67e2                	ld	a5,24(sp)
ffffffffc020593e:	03840413          	addi	s0,s0,56
ffffffffc0205942:	fef469e3          	bltu	s0,a5,ffffffffc0205934 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0205946:	4701                	li	a4,0
ffffffffc0205948:	46ad                	li	a3,11
ffffffffc020594a:	00100637          	lui	a2,0x100
ffffffffc020594e:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205952:	854a                	mv	a0,s2
ffffffffc0205954:	93bfe0ef          	jal	ra,ffffffffc020428e <mm_map>
ffffffffc0205958:	89aa                	mv	s3,a0
ffffffffc020595a:	1a051663          	bnez	a0,ffffffffc0205b06 <do_execve+0x314>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc020595e:	01893503          	ld	a0,24(s2)
ffffffffc0205962:	467d                	li	a2,31
ffffffffc0205964:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205968:	981fd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc020596c:	36050463          	beqz	a0,ffffffffc0205cd4 <do_execve+0x4e2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205970:	01893503          	ld	a0,24(s2)
ffffffffc0205974:	467d                	li	a2,31
ffffffffc0205976:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc020597a:	96ffd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc020597e:	32050b63          	beqz	a0,ffffffffc0205cb4 <do_execve+0x4c2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205982:	01893503          	ld	a0,24(s2)
ffffffffc0205986:	467d                	li	a2,31
ffffffffc0205988:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc020598c:	95dfd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc0205990:	30050263          	beqz	a0,ffffffffc0205c94 <do_execve+0x4a2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205994:	01893503          	ld	a0,24(s2)
ffffffffc0205998:	467d                	li	a2,31
ffffffffc020599a:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc020599e:	94bfd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc02059a2:	2c050963          	beqz	a0,ffffffffc0205c74 <do_execve+0x482>
    mm->mm_count += 1;
ffffffffc02059a6:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc02059aa:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059ae:	01893683          	ld	a3,24(s2)
ffffffffc02059b2:	2785                	addiw	a5,a5,1
ffffffffc02059b4:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc02059b8:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_matrix_out_size+0xf45d0>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059bc:	c02007b7          	lui	a5,0xc0200
ffffffffc02059c0:	28f6ee63          	bltu	a3,a5,ffffffffc0205c5c <do_execve+0x46a>
ffffffffc02059c4:	000c4797          	auipc	a5,0xc4
ffffffffc02059c8:	84c78793          	addi	a5,a5,-1972 # ffffffffc02c9210 <va_pa_offset>
ffffffffc02059cc:	639c                	ld	a5,0(a5)
ffffffffc02059ce:	577d                	li	a4,-1
ffffffffc02059d0:	177e                	slli	a4,a4,0x3f
ffffffffc02059d2:	8e9d                	sub	a3,a3,a5
ffffffffc02059d4:	00c6d793          	srli	a5,a3,0xc
ffffffffc02059d8:	f654                	sd	a3,168(a2)
ffffffffc02059da:	8fd9                	or	a5,a5,a4
ffffffffc02059dc:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02059e0:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059e2:	4581                	li	a1,0
ffffffffc02059e4:	12000613          	li	a2,288
    uintptr_t sstatus = tf->status;
ffffffffc02059e8:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059ec:	8522                	mv	a0,s0
ffffffffc02059ee:	70a030ef          	jal	ra,ffffffffc02090f8 <memset>
    tf->epc = elf->e_entry;
ffffffffc02059f2:	018b3703          	ld	a4,24(s6)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc02059f6:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc02059fa:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc02059fc:	000a3503          	ld	a0,0(s4)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205a00:	0204e493          	ori	s1,s1,32
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a04:	07fe                	slli	a5,a5,0x1f
ffffffffc0205a06:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205a08:	10e43423          	sd	a4,264(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205a0c:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205a10:	100c                	addi	a1,sp,32
ffffffffc0205a12:	ca4ff0ef          	jal	ra,ffffffffc0204eb6 <set_proc_name>
}
ffffffffc0205a16:	60ea                	ld	ra,152(sp)
ffffffffc0205a18:	644a                	ld	s0,144(sp)
ffffffffc0205a1a:	854e                	mv	a0,s3
ffffffffc0205a1c:	64aa                	ld	s1,136(sp)
ffffffffc0205a1e:	690a                	ld	s2,128(sp)
ffffffffc0205a20:	79e6                	ld	s3,120(sp)
ffffffffc0205a22:	7a46                	ld	s4,112(sp)
ffffffffc0205a24:	7aa6                	ld	s5,104(sp)
ffffffffc0205a26:	7b06                	ld	s6,96(sp)
ffffffffc0205a28:	6be6                	ld	s7,88(sp)
ffffffffc0205a2a:	6c46                	ld	s8,80(sp)
ffffffffc0205a2c:	6ca6                	ld	s9,72(sp)
ffffffffc0205a2e:	6d06                	ld	s10,64(sp)
ffffffffc0205a30:	7de2                	ld	s11,56(sp)
ffffffffc0205a32:	610d                	addi	sp,sp,160
ffffffffc0205a34:	8082                	ret
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0205a36:	7410                	ld	a2,40(s0)
ffffffffc0205a38:	701c                	ld	a5,32(s0)
ffffffffc0205a3a:	20f66363          	bltu	a2,a5,ffffffffc0205c40 <do_execve+0x44e>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0205a3e:	405c                	lw	a5,4(s0)
            vm_flags |= VM_EXEC;
ffffffffc0205a40:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W)
ffffffffc0205a44:	0027f713          	andi	a4,a5,2
            vm_flags |= VM_EXEC;
ffffffffc0205a48:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W)
ffffffffc0205a4a:	0e071263          	bnez	a4,ffffffffc0205b2e <do_execve+0x33c>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a4e:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205a50:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a52:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205a54:	c789                	beqz	a5,ffffffffc0205a5e <do_execve+0x26c>
            perm |= PTE_R;
ffffffffc0205a56:	47cd                	li	a5,19
            vm_flags |= VM_READ;
ffffffffc0205a58:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc0205a5c:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE)
ffffffffc0205a5e:	0026f793          	andi	a5,a3,2
ffffffffc0205a62:	efe1                	bnez	a5,ffffffffc0205b3a <do_execve+0x348>
        if (vm_flags & VM_EXEC)
ffffffffc0205a64:	0046f793          	andi	a5,a3,4
ffffffffc0205a68:	c789                	beqz	a5,ffffffffc0205a72 <do_execve+0x280>
            perm |= PTE_X;
ffffffffc0205a6a:	6782                	ld	a5,0(sp)
ffffffffc0205a6c:	0087e793          	ori	a5,a5,8
ffffffffc0205a70:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0205a72:	680c                	ld	a1,16(s0)
ffffffffc0205a74:	4701                	li	a4,0
ffffffffc0205a76:	854a                	mv	a0,s2
ffffffffc0205a78:	817fe0ef          	jal	ra,ffffffffc020428e <mm_map>
ffffffffc0205a7c:	89aa                	mv	s3,a0
ffffffffc0205a7e:	e541                	bnez	a0,ffffffffc0205b06 <do_execve+0x314>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a80:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a84:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a88:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a8c:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a8e:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a90:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a92:	00fbfc33          	and	s8,s7,a5
        while (start < end)
ffffffffc0205a96:	053bef63          	bltu	s7,s3,ffffffffc0205af4 <do_execve+0x302>
ffffffffc0205a9a:	aa79                	j	ffffffffc0205c38 <do_execve+0x446>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205a9c:	6785                	lui	a5,0x1
ffffffffc0205a9e:	418b8533          	sub	a0,s7,s8
ffffffffc0205aa2:	9c3e                	add	s8,s8,a5
ffffffffc0205aa4:	417c0833          	sub	a6,s8,s7
            if (end < la)
ffffffffc0205aa8:	0189f463          	bleu	s8,s3,ffffffffc0205ab0 <do_execve+0x2be>
                size -= la - end;
ffffffffc0205aac:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205ab0:	000db683          	ld	a3,0(s11)
ffffffffc0205ab4:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205ab8:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205aba:	40d486b3          	sub	a3,s1,a3
ffffffffc0205abe:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205ac0:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205ac4:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205ac6:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205aca:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205acc:	16c5fc63          	bleu	a2,a1,ffffffffc0205c44 <do_execve+0x452>
ffffffffc0205ad0:	000c3797          	auipc	a5,0xc3
ffffffffc0205ad4:	74078793          	addi	a5,a5,1856 # ffffffffc02c9210 <va_pa_offset>
ffffffffc0205ad8:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205adc:	85d6                	mv	a1,s5
ffffffffc0205ade:	8642                	mv	a2,a6
ffffffffc0205ae0:	96c6                	add	a3,a3,a7
ffffffffc0205ae2:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205ae4:	9bc2                	add	s7,s7,a6
ffffffffc0205ae6:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205ae8:	622030ef          	jal	ra,ffffffffc020910a <memcpy>
            start += size, from += size;
ffffffffc0205aec:	6842                	ld	a6,16(sp)
ffffffffc0205aee:	9ac2                	add	s5,s5,a6
        while (start < end)
ffffffffc0205af0:	053bf863          	bleu	s3,s7,ffffffffc0205b40 <do_execve+0x34e>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0205af4:	01893503          	ld	a0,24(s2)
ffffffffc0205af8:	6602                	ld	a2,0(sp)
ffffffffc0205afa:	85e2                	mv	a1,s8
ffffffffc0205afc:	fecfd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc0205b00:	84aa                	mv	s1,a0
ffffffffc0205b02:	fd49                	bnez	a0,ffffffffc0205a9c <do_execve+0x2aa>
        ret = -E_NO_MEM;
ffffffffc0205b04:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205b06:	854a                	mv	a0,s2
ffffffffc0205b08:	8d5fe0ef          	jal	ra,ffffffffc02043dc <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b0c:	854a                	mv	a0,s2
ffffffffc0205b0e:	a9eff0ef          	jal	ra,ffffffffc0204dac <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b12:	854a                	mv	a0,s2
ffffffffc0205b14:	f28fe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
    return ret;
ffffffffc0205b18:	b345                	j	ffffffffc02058b8 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205b1a:	854a                	mv	a0,s2
ffffffffc0205b1c:	8c1fe0ef          	jal	ra,ffffffffc02043dc <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b20:	854a                	mv	a0,s2
ffffffffc0205b22:	a8aff0ef          	jal	ra,ffffffffc0204dac <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b26:	854a                	mv	a0,s2
ffffffffc0205b28:	f14fe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
ffffffffc0205b2c:	bba1                	j	ffffffffc0205884 <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0205b2e:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205b32:	8b91                	andi	a5,a5,4
            vm_flags |= VM_WRITE;
ffffffffc0205b34:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205b36:	f20790e3          	bnez	a5,ffffffffc0205a56 <do_execve+0x264>
            perm |= (PTE_W | PTE_R);
ffffffffc0205b3a:	47dd                	li	a5,23
ffffffffc0205b3c:	e03e                	sd	a5,0(sp)
ffffffffc0205b3e:	b71d                	j	ffffffffc0205a64 <do_execve+0x272>
ffffffffc0205b40:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b44:	7414                	ld	a3,40(s0)
ffffffffc0205b46:	99b6                	add	s3,s3,a3
        if (start < la)
ffffffffc0205b48:	098bf163          	bleu	s8,s7,ffffffffc0205bca <do_execve+0x3d8>
            if (start == end)
ffffffffc0205b4c:	df7988e3          	beq	s3,s7,ffffffffc020593c <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b50:	6505                	lui	a0,0x1
ffffffffc0205b52:	955e                	add	a0,a0,s7
ffffffffc0205b54:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205b58:	41798ab3          	sub	s5,s3,s7
            if (end < la)
ffffffffc0205b5c:	0d89fb63          	bleu	s8,s3,ffffffffc0205c32 <do_execve+0x440>
    return page - pages + nbase;
ffffffffc0205b60:	000db683          	ld	a3,0(s11)
ffffffffc0205b64:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b68:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b6a:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b6e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b70:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b74:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b76:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b7a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b7c:	0cc5f463          	bleu	a2,a1,ffffffffc0205c44 <do_execve+0x452>
ffffffffc0205b80:	000c3617          	auipc	a2,0xc3
ffffffffc0205b84:	69060613          	addi	a2,a2,1680 # ffffffffc02c9210 <va_pa_offset>
ffffffffc0205b88:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b8c:	4581                	li	a1,0
ffffffffc0205b8e:	8656                	mv	a2,s5
ffffffffc0205b90:	96c2                	add	a3,a3,a6
ffffffffc0205b92:	9536                	add	a0,a0,a3
ffffffffc0205b94:	564030ef          	jal	ra,ffffffffc02090f8 <memset>
            start += size;
ffffffffc0205b98:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205b9c:	0389f463          	bleu	s8,s3,ffffffffc0205bc4 <do_execve+0x3d2>
ffffffffc0205ba0:	d8e98ee3          	beq	s3,a4,ffffffffc020593c <do_execve+0x14a>
ffffffffc0205ba4:	00005697          	auipc	a3,0x5
ffffffffc0205ba8:	3bc68693          	addi	a3,a3,956 # ffffffffc020af60 <default_pmm_manager+0x1100>
ffffffffc0205bac:	00004617          	auipc	a2,0x4
ffffffffc0205bb0:	b6c60613          	addi	a2,a2,-1172 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0205bb4:	2be00593          	li	a1,702
ffffffffc0205bb8:	00005517          	auipc	a0,0x5
ffffffffc0205bbc:	7f050513          	addi	a0,a0,2032 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205bc0:	8c9fa0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0205bc4:	ff8710e3          	bne	a4,s8,ffffffffc0205ba4 <do_execve+0x3b2>
ffffffffc0205bc8:	8be2                	mv	s7,s8
ffffffffc0205bca:	000c3a97          	auipc	s5,0xc3
ffffffffc0205bce:	646a8a93          	addi	s5,s5,1606 # ffffffffc02c9210 <va_pa_offset>
        while (start < end)
ffffffffc0205bd2:	053be763          	bltu	s7,s3,ffffffffc0205c20 <do_execve+0x42e>
ffffffffc0205bd6:	b39d                	j	ffffffffc020593c <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205bd8:	6785                	lui	a5,0x1
ffffffffc0205bda:	418b8533          	sub	a0,s7,s8
ffffffffc0205bde:	9c3e                	add	s8,s8,a5
ffffffffc0205be0:	417c0633          	sub	a2,s8,s7
            if (end < la)
ffffffffc0205be4:	0189f463          	bleu	s8,s3,ffffffffc0205bec <do_execve+0x3fa>
                size -= la - end;
ffffffffc0205be8:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205bec:	000db683          	ld	a3,0(s11)
ffffffffc0205bf0:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205bf4:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205bf6:	40d486b3          	sub	a3,s1,a3
ffffffffc0205bfa:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205bfc:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c00:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205c02:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c06:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c08:	02b87e63          	bleu	a1,a6,ffffffffc0205c44 <do_execve+0x452>
ffffffffc0205c0c:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205c10:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c12:	4581                	li	a1,0
ffffffffc0205c14:	96c2                	add	a3,a3,a6
ffffffffc0205c16:	9536                	add	a0,a0,a3
ffffffffc0205c18:	4e0030ef          	jal	ra,ffffffffc02090f8 <memset>
        while (start < end)
ffffffffc0205c1c:	d33bf0e3          	bleu	s3,s7,ffffffffc020593c <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0205c20:	01893503          	ld	a0,24(s2)
ffffffffc0205c24:	6602                	ld	a2,0(sp)
ffffffffc0205c26:	85e2                	mv	a1,s8
ffffffffc0205c28:	ec0fd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc0205c2c:	84aa                	mv	s1,a0
ffffffffc0205c2e:	f54d                	bnez	a0,ffffffffc0205bd8 <do_execve+0x3e6>
ffffffffc0205c30:	bdd1                	j	ffffffffc0205b04 <do_execve+0x312>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c32:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205c36:	b72d                	j	ffffffffc0205b60 <do_execve+0x36e>
        while (start < end)
ffffffffc0205c38:	89de                	mv	s3,s7
ffffffffc0205c3a:	b729                	j	ffffffffc0205b44 <do_execve+0x352>
        return -E_INVAL;
ffffffffc0205c3c:	59f5                	li	s3,-3
ffffffffc0205c3e:	bbe1                	j	ffffffffc0205a16 <do_execve+0x224>
            ret = -E_INVAL_ELF;
ffffffffc0205c40:	59e1                	li	s3,-8
ffffffffc0205c42:	b5d1                	j	ffffffffc0205b06 <do_execve+0x314>
ffffffffc0205c44:	00004617          	auipc	a2,0x4
ffffffffc0205c48:	26c60613          	addi	a2,a2,620 # ffffffffc0209eb0 <default_pmm_manager+0x50>
ffffffffc0205c4c:	06900593          	li	a1,105
ffffffffc0205c50:	00004517          	auipc	a0,0x4
ffffffffc0205c54:	28850513          	addi	a0,a0,648 # ffffffffc0209ed8 <default_pmm_manager+0x78>
ffffffffc0205c58:	831fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c5c:	00004617          	auipc	a2,0x4
ffffffffc0205c60:	28c60613          	addi	a2,a2,652 # ffffffffc0209ee8 <default_pmm_manager+0x88>
ffffffffc0205c64:	2dd00593          	li	a1,733
ffffffffc0205c68:	00005517          	auipc	a0,0x5
ffffffffc0205c6c:	74050513          	addi	a0,a0,1856 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205c70:	819fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205c74:	00005697          	auipc	a3,0x5
ffffffffc0205c78:	40468693          	addi	a3,a3,1028 # ffffffffc020b078 <default_pmm_manager+0x1218>
ffffffffc0205c7c:	00004617          	auipc	a2,0x4
ffffffffc0205c80:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0205c84:	2d800593          	li	a1,728
ffffffffc0205c88:	00005517          	auipc	a0,0x5
ffffffffc0205c8c:	72050513          	addi	a0,a0,1824 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205c90:	ff8fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205c94:	00005697          	auipc	a3,0x5
ffffffffc0205c98:	39c68693          	addi	a3,a3,924 # ffffffffc020b030 <default_pmm_manager+0x11d0>
ffffffffc0205c9c:	00004617          	auipc	a2,0x4
ffffffffc0205ca0:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0205ca4:	2d700593          	li	a1,727
ffffffffc0205ca8:	00005517          	auipc	a0,0x5
ffffffffc0205cac:	70050513          	addi	a0,a0,1792 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205cb0:	fd8fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205cb4:	00005697          	auipc	a3,0x5
ffffffffc0205cb8:	33468693          	addi	a3,a3,820 # ffffffffc020afe8 <default_pmm_manager+0x1188>
ffffffffc0205cbc:	00004617          	auipc	a2,0x4
ffffffffc0205cc0:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0205cc4:	2d600593          	li	a1,726
ffffffffc0205cc8:	00005517          	auipc	a0,0x5
ffffffffc0205ccc:	6e050513          	addi	a0,a0,1760 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205cd0:	fb8fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0205cd4:	00005697          	auipc	a3,0x5
ffffffffc0205cd8:	2cc68693          	addi	a3,a3,716 # ffffffffc020afa0 <default_pmm_manager+0x1140>
ffffffffc0205cdc:	00004617          	auipc	a2,0x4
ffffffffc0205ce0:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0205ce4:	2d500593          	li	a1,725
ffffffffc0205ce8:	00005517          	auipc	a0,0x5
ffffffffc0205cec:	6c050513          	addi	a0,a0,1728 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205cf0:	f98fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205cf4 <do_yield>:
    current->need_resched = 1;
ffffffffc0205cf4:	000c3797          	auipc	a5,0xc3
ffffffffc0205cf8:	4c478793          	addi	a5,a5,1220 # ffffffffc02c91b8 <current>
ffffffffc0205cfc:	639c                	ld	a5,0(a5)
ffffffffc0205cfe:	4705                	li	a4,1
}
ffffffffc0205d00:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205d02:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d04:	8082                	ret

ffffffffc0205d06 <do_wait>:
{
ffffffffc0205d06:	1101                	addi	sp,sp,-32
ffffffffc0205d08:	e822                	sd	s0,16(sp)
ffffffffc0205d0a:	e426                	sd	s1,8(sp)
ffffffffc0205d0c:	ec06                	sd	ra,24(sp)
ffffffffc0205d0e:	842e                	mv	s0,a1
ffffffffc0205d10:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0205d12:	cd81                	beqz	a1,ffffffffc0205d2a <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205d14:	000c3797          	auipc	a5,0xc3
ffffffffc0205d18:	4a478793          	addi	a5,a5,1188 # ffffffffc02c91b8 <current>
ffffffffc0205d1c:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0205d1e:	4685                	li	a3,1
ffffffffc0205d20:	4611                	li	a2,4
ffffffffc0205d22:	7788                	ld	a0,40(a5)
ffffffffc0205d24:	d5bfe0ef          	jal	ra,ffffffffc0204a7e <user_mem_check>
ffffffffc0205d28:	c909                	beqz	a0,ffffffffc0205d3a <do_wait+0x34>
ffffffffc0205d2a:	85a2                	mv	a1,s0
}
ffffffffc0205d2c:	6442                	ld	s0,16(sp)
ffffffffc0205d2e:	60e2                	ld	ra,24(sp)
ffffffffc0205d30:	8526                	mv	a0,s1
ffffffffc0205d32:	64a2                	ld	s1,8(sp)
ffffffffc0205d34:	6105                	addi	sp,sp,32
ffffffffc0205d36:	fecff06f          	j	ffffffffc0205522 <do_wait.part.1>
ffffffffc0205d3a:	60e2                	ld	ra,24(sp)
ffffffffc0205d3c:	6442                	ld	s0,16(sp)
ffffffffc0205d3e:	64a2                	ld	s1,8(sp)
ffffffffc0205d40:	5575                	li	a0,-3
ffffffffc0205d42:	6105                	addi	sp,sp,32
ffffffffc0205d44:	8082                	ret

ffffffffc0205d46 <do_kill>:
{
ffffffffc0205d46:	1141                	addi	sp,sp,-16
ffffffffc0205d48:	e406                	sd	ra,8(sp)
ffffffffc0205d4a:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL)
ffffffffc0205d4c:	a00ff0ef          	jal	ra,ffffffffc0204f4c <find_proc>
ffffffffc0205d50:	cd0d                	beqz	a0,ffffffffc0205d8a <do_kill+0x44>
        if (!(proc->flags & PF_EXITING))
ffffffffc0205d52:	0b052703          	lw	a4,176(a0)
ffffffffc0205d56:	00177693          	andi	a3,a4,1
ffffffffc0205d5a:	e695                	bnez	a3,ffffffffc0205d86 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205d5c:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205d60:	00176713          	ori	a4,a4,1
ffffffffc0205d64:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205d68:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205d6a:	0006c763          	bltz	a3,ffffffffc0205d78 <do_kill+0x32>
}
ffffffffc0205d6e:	8522                	mv	a0,s0
ffffffffc0205d70:	60a2                	ld	ra,8(sp)
ffffffffc0205d72:	6402                	ld	s0,0(sp)
ffffffffc0205d74:	0141                	addi	sp,sp,16
ffffffffc0205d76:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205d78:	449020ef          	jal	ra,ffffffffc02089c0 <wakeup_proc>
}
ffffffffc0205d7c:	8522                	mv	a0,s0
ffffffffc0205d7e:	60a2                	ld	ra,8(sp)
ffffffffc0205d80:	6402                	ld	s0,0(sp)
ffffffffc0205d82:	0141                	addi	sp,sp,16
ffffffffc0205d84:	8082                	ret
        return -E_KILLED;
ffffffffc0205d86:	545d                	li	s0,-9
ffffffffc0205d88:	b7dd                	j	ffffffffc0205d6e <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205d8a:	5475                	li	s0,-3
ffffffffc0205d8c:	b7cd                	j	ffffffffc0205d6e <do_kill+0x28>

ffffffffc0205d8e <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205d8e:	000c3797          	auipc	a5,0xc3
ffffffffc0205d92:	57a78793          	addi	a5,a5,1402 # ffffffffc02c9308 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0205d96:	1101                	addi	sp,sp,-32
ffffffffc0205d98:	000c3717          	auipc	a4,0xc3
ffffffffc0205d9c:	56f73c23          	sd	a5,1400(a4) # ffffffffc02c9310 <proc_list+0x8>
ffffffffc0205da0:	000c3717          	auipc	a4,0xc3
ffffffffc0205da4:	56f73423          	sd	a5,1384(a4) # ffffffffc02c9308 <proc_list>
ffffffffc0205da8:	ec06                	sd	ra,24(sp)
ffffffffc0205daa:	e822                	sd	s0,16(sp)
ffffffffc0205dac:	e426                	sd	s1,8(sp)
ffffffffc0205dae:	000bf797          	auipc	a5,0xbf
ffffffffc0205db2:	3aa78793          	addi	a5,a5,938 # ffffffffc02c5158 <hash_list>
ffffffffc0205db6:	000c3717          	auipc	a4,0xc3
ffffffffc0205dba:	3a270713          	addi	a4,a4,930 # ffffffffc02c9158 <__rq>
ffffffffc0205dbe:	e79c                	sd	a5,8(a5)
ffffffffc0205dc0:	e39c                	sd	a5,0(a5)
ffffffffc0205dc2:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0205dc4:	fee79de3          	bne	a5,a4,ffffffffc0205dbe <proc_init+0x30>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0205dc8:	ebbfe0ef          	jal	ra,ffffffffc0204c82 <alloc_proc>
ffffffffc0205dcc:	000c3717          	auipc	a4,0xc3
ffffffffc0205dd0:	3ea73a23          	sd	a0,1012(a4) # ffffffffc02c91c0 <idleproc>
ffffffffc0205dd4:	000c3497          	auipc	s1,0xc3
ffffffffc0205dd8:	3ec48493          	addi	s1,s1,1004 # ffffffffc02c91c0 <idleproc>
ffffffffc0205ddc:	c559                	beqz	a0,ffffffffc0205e6a <proc_init+0xdc>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205dde:	4709                	li	a4,2
ffffffffc0205de0:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205de2:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205de4:	00006717          	auipc	a4,0x6
ffffffffc0205de8:	21c70713          	addi	a4,a4,540 # ffffffffc020c000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205dec:	00005597          	auipc	a1,0x5
ffffffffc0205df0:	4d458593          	addi	a1,a1,1236 # ffffffffc020b2c0 <default_pmm_manager+0x1460>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205df4:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205df6:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205df8:	8beff0ef          	jal	ra,ffffffffc0204eb6 <set_proc_name>
    nr_process++;
ffffffffc0205dfc:	000c3797          	auipc	a5,0xc3
ffffffffc0205e00:	3d478793          	addi	a5,a5,980 # ffffffffc02c91d0 <nr_process>
ffffffffc0205e04:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205e06:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e08:	4601                	li	a2,0
    nr_process++;
ffffffffc0205e0a:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e0c:	4581                	li	a1,0
ffffffffc0205e0e:	00000517          	auipc	a0,0x0
ffffffffc0205e12:	8bc50513          	addi	a0,a0,-1860 # ffffffffc02056ca <init_main>
    nr_process++;
ffffffffc0205e16:	000c3697          	auipc	a3,0xc3
ffffffffc0205e1a:	3af6ad23          	sw	a5,954(a3) # ffffffffc02c91d0 <nr_process>
    current = idleproc;
ffffffffc0205e1e:	000c3797          	auipc	a5,0xc3
ffffffffc0205e22:	38e7bd23          	sd	a4,922(a5) # ffffffffc02c91b8 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e26:	d5eff0ef          	jal	ra,ffffffffc0205384 <kernel_thread>
    if (pid <= 0)
ffffffffc0205e2a:	08a05c63          	blez	a0,ffffffffc0205ec2 <proc_init+0x134>
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e2e:	91eff0ef          	jal	ra,ffffffffc0204f4c <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205e32:	00005597          	auipc	a1,0x5
ffffffffc0205e36:	4b658593          	addi	a1,a1,1206 # ffffffffc020b2e8 <default_pmm_manager+0x1488>
    initproc = find_proc(pid);
ffffffffc0205e3a:	000c3797          	auipc	a5,0xc3
ffffffffc0205e3e:	38a7b723          	sd	a0,910(a5) # ffffffffc02c91c8 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205e42:	874ff0ef          	jal	ra,ffffffffc0204eb6 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e46:	609c                	ld	a5,0(s1)
ffffffffc0205e48:	cfa9                	beqz	a5,ffffffffc0205ea2 <proc_init+0x114>
ffffffffc0205e4a:	43dc                	lw	a5,4(a5)
ffffffffc0205e4c:	ebb9                	bnez	a5,ffffffffc0205ea2 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e4e:	000c3797          	auipc	a5,0xc3
ffffffffc0205e52:	37a78793          	addi	a5,a5,890 # ffffffffc02c91c8 <initproc>
ffffffffc0205e56:	639c                	ld	a5,0(a5)
ffffffffc0205e58:	c78d                	beqz	a5,ffffffffc0205e82 <proc_init+0xf4>
ffffffffc0205e5a:	43dc                	lw	a5,4(a5)
ffffffffc0205e5c:	02879363          	bne	a5,s0,ffffffffc0205e82 <proc_init+0xf4>
}
ffffffffc0205e60:	60e2                	ld	ra,24(sp)
ffffffffc0205e62:	6442                	ld	s0,16(sp)
ffffffffc0205e64:	64a2                	ld	s1,8(sp)
ffffffffc0205e66:	6105                	addi	sp,sp,32
ffffffffc0205e68:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205e6a:	00005617          	auipc	a2,0x5
ffffffffc0205e6e:	43e60613          	addi	a2,a2,1086 # ffffffffc020b2a8 <default_pmm_manager+0x1448>
ffffffffc0205e72:	3ee00593          	li	a1,1006
ffffffffc0205e76:	00005517          	auipc	a0,0x5
ffffffffc0205e7a:	53250513          	addi	a0,a0,1330 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205e7e:	e0afa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e82:	00005697          	auipc	a3,0x5
ffffffffc0205e86:	49668693          	addi	a3,a3,1174 # ffffffffc020b318 <default_pmm_manager+0x14b8>
ffffffffc0205e8a:	00004617          	auipc	a2,0x4
ffffffffc0205e8e:	88e60613          	addi	a2,a2,-1906 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0205e92:	40400593          	li	a1,1028
ffffffffc0205e96:	00005517          	auipc	a0,0x5
ffffffffc0205e9a:	51250513          	addi	a0,a0,1298 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205e9e:	deafa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ea2:	00005697          	auipc	a3,0x5
ffffffffc0205ea6:	44e68693          	addi	a3,a3,1102 # ffffffffc020b2f0 <default_pmm_manager+0x1490>
ffffffffc0205eaa:	00004617          	auipc	a2,0x4
ffffffffc0205eae:	86e60613          	addi	a2,a2,-1938 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0205eb2:	40300593          	li	a1,1027
ffffffffc0205eb6:	00005517          	auipc	a0,0x5
ffffffffc0205eba:	4f250513          	addi	a0,a0,1266 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205ebe:	dcafa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205ec2:	00005617          	auipc	a2,0x5
ffffffffc0205ec6:	40660613          	addi	a2,a2,1030 # ffffffffc020b2c8 <default_pmm_manager+0x1468>
ffffffffc0205eca:	3fd00593          	li	a1,1021
ffffffffc0205ece:	00005517          	auipc	a0,0x5
ffffffffc0205ed2:	4da50513          	addi	a0,a0,1242 # ffffffffc020b3a8 <default_pmm_manager+0x1548>
ffffffffc0205ed6:	db2fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205eda <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0205eda:	1141                	addi	sp,sp,-16
ffffffffc0205edc:	e022                	sd	s0,0(sp)
ffffffffc0205ede:	e406                	sd	ra,8(sp)
ffffffffc0205ee0:	000c3417          	auipc	s0,0xc3
ffffffffc0205ee4:	2d840413          	addi	s0,s0,728 # ffffffffc02c91b8 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0205ee8:	6018                	ld	a4,0(s0)
ffffffffc0205eea:	6f1c                	ld	a5,24(a4)
ffffffffc0205eec:	dffd                	beqz	a5,ffffffffc0205eea <cpu_idle+0x10>
        {
            schedule();
ffffffffc0205eee:	38d020ef          	jal	ra,ffffffffc0208a7a <schedule>
ffffffffc0205ef2:	bfdd                	j	ffffffffc0205ee8 <cpu_idle+0xe>

ffffffffc0205ef4 <lab6_set_priority>:
        }
    }
}
// FOR LAB6, set the process's priority (bigger value will get more CPU time)
void lab6_set_priority(uint32_t priority)
{
ffffffffc0205ef4:	1141                	addi	sp,sp,-16
ffffffffc0205ef6:	e022                	sd	s0,0(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205ef8:	85aa                	mv	a1,a0
{
ffffffffc0205efa:	842a                	mv	s0,a0
    cprintf("set priority to %d\n", priority);
ffffffffc0205efc:	00005517          	auipc	a0,0x5
ffffffffc0205f00:	39450513          	addi	a0,a0,916 # ffffffffc020b290 <default_pmm_manager+0x1430>
{
ffffffffc0205f04:	e406                	sd	ra,8(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205f06:	a8cfa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    if (priority == 0)
        current->lab6_priority = 1;
ffffffffc0205f0a:	000c3797          	auipc	a5,0xc3
ffffffffc0205f0e:	2ae78793          	addi	a5,a5,686 # ffffffffc02c91b8 <current>
ffffffffc0205f12:	639c                	ld	a5,0(a5)
    if (priority == 0)
ffffffffc0205f14:	e801                	bnez	s0,ffffffffc0205f24 <lab6_set_priority+0x30>
    else
        current->lab6_priority = priority;
}
ffffffffc0205f16:	60a2                	ld	ra,8(sp)
ffffffffc0205f18:	6402                	ld	s0,0(sp)
        current->lab6_priority = 1;
ffffffffc0205f1a:	4705                	li	a4,1
ffffffffc0205f1c:	14e7a223          	sw	a4,324(a5)
}
ffffffffc0205f20:	0141                	addi	sp,sp,16
ffffffffc0205f22:	8082                	ret
        current->lab6_priority = priority;
ffffffffc0205f24:	1487a223          	sw	s0,324(a5)
}
ffffffffc0205f28:	60a2                	ld	ra,8(sp)
ffffffffc0205f2a:	6402                	ld	s0,0(sp)
ffffffffc0205f2c:	0141                	addi	sp,sp,16
ffffffffc0205f2e:	8082                	ret

ffffffffc0205f30 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205f30:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205f34:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205f38:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205f3a:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205f3c:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205f40:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205f44:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205f48:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205f4c:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205f50:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205f54:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205f58:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205f5c:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205f60:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205f64:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205f68:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205f6c:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205f6e:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205f70:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205f74:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205f78:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205f7c:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205f80:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205f84:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205f88:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205f8c:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205f90:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205f94:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205f98:	8082                	ret

ffffffffc0205f9a <proc_stride_comp_f>:
static int
proc_stride_comp_f(void *a, void *b)
{
     struct proc_struct *p = le2proc(a, lab6_run_pool);
     struct proc_struct *q = le2proc(b, lab6_run_pool);
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0205f9a:	4d08                	lw	a0,24(a0)
ffffffffc0205f9c:	4d9c                	lw	a5,24(a1)
ffffffffc0205f9e:	9d1d                	subw	a0,a0,a5
     if (c > 0)
ffffffffc0205fa0:	00a04763          	bgtz	a0,ffffffffc0205fae <proc_stride_comp_f+0x14>
          return 1;
     else if (c == 0)
ffffffffc0205fa4:	00a03533          	snez	a0,a0
ffffffffc0205fa8:	40a0053b          	negw	a0,a0
ffffffffc0205fac:	8082                	ret
          return 1;
ffffffffc0205fae:	4505                	li	a0,1
          return 0;
     else
          return -1;
}
ffffffffc0205fb0:	8082                	ret

ffffffffc0205fb2 <stride_init>:
ffffffffc0205fb2:	e508                	sd	a0,8(a0)
ffffffffc0205fb4:	e108                	sd	a0,0(a0)
      * (1) init the ready process list: rq->run_list
      * (2) init the run pool: rq->lab6_run_pool
      * (3) set number of process: rq->proc_num to 0
      */
     list_init(&(rq->run_list));
     rq->lab6_run_pool = NULL;
ffffffffc0205fb6:	00053c23          	sd	zero,24(a0)
     rq->proc_num = 0;
ffffffffc0205fba:	00052823          	sw	zero,16(a0)
}
ffffffffc0205fbe:	8082                	ret

ffffffffc0205fc0 <stride_pick_next>:
             (1.1) If using skew_heap, we can use le2proc get the p from rq->lab6_run_pol
             (1.2) If using list, we have to search list to find the p with minimum stride value
      * (2) update p;s stride value: p->lab6_stride
      * (3) return p
      */
     if (rq->lab6_run_pool == NULL) 
ffffffffc0205fc0:	6d1c                	ld	a5,24(a0)
ffffffffc0205fc2:	c395                	beqz	a5,ffffffffc0205fe6 <stride_pick_next+0x26>
     {
          return NULL;   
     }
     struct proc_struct *p = le2proc(rq->lab6_run_pool, lab6_run_pool);
     if (p->lab6_priority == 0)
ffffffffc0205fc4:	4fd0                	lw	a2,28(a5)
     {
          p->lab6_stride += BIG_STRIDE;
ffffffffc0205fc6:	80000737          	lui	a4,0x80000
     struct proc_struct *p = le2proc(rq->lab6_run_pool, lab6_run_pool);
ffffffffc0205fca:	ed878513          	addi	a0,a5,-296
     if (p->lab6_priority == 0)
ffffffffc0205fce:	4f94                	lw	a3,24(a5)
          p->lab6_stride += BIG_STRIDE;
ffffffffc0205fd0:	fff74713          	not	a4,a4
     if (p->lab6_priority == 0)
ffffffffc0205fd4:	e601                	bnez	a2,ffffffffc0205fdc <stride_pick_next+0x1c>
     }          
     else 
     {
          p->lab6_stride += BIG_STRIDE / p->lab6_priority;
ffffffffc0205fd6:	9f35                	addw	a4,a4,a3
ffffffffc0205fd8:	cf98                	sw	a4,24(a5)
ffffffffc0205fda:	8082                	ret
ffffffffc0205fdc:	02c7573b          	divuw	a4,a4,a2
ffffffffc0205fe0:	9f35                	addw	a4,a4,a3
ffffffffc0205fe2:	cf98                	sw	a4,24(a5)
ffffffffc0205fe4:	8082                	ret
          return NULL;   
ffffffffc0205fe6:	4501                	li	a0,0
     }
     return p;
}
ffffffffc0205fe8:	8082                	ret

ffffffffc0205fea <stride_proc_tick>:
 */
static void
stride_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
     /* LAB6: YOUR CODE */
     if (proc->time_slice > 0) {
ffffffffc0205fea:	1205a783          	lw	a5,288(a1)
ffffffffc0205fee:	00f05563          	blez	a5,ffffffffc0205ff8 <stride_proc_tick+0xe>
          proc->time_slice --;
ffffffffc0205ff2:	37fd                	addiw	a5,a5,-1
ffffffffc0205ff4:	12f5a023          	sw	a5,288(a1)
     }
     if (proc->time_slice == 0) {
ffffffffc0205ff8:	e399                	bnez	a5,ffffffffc0205ffe <stride_proc_tick+0x14>
          proc->need_resched = 1;
ffffffffc0205ffa:	4785                	li	a5,1
ffffffffc0205ffc:	ed9c                	sd	a5,24(a1)
     }
}
ffffffffc0205ffe:	8082                	ret

ffffffffc0206000 <skew_heap_merge.constprop.2>:
{
     a->left = a->right = a->parent = NULL;
}

static inline skew_heap_entry_t *
skew_heap_merge(skew_heap_entry_t *a, skew_heap_entry_t *b,
ffffffffc0206000:	1101                	addi	sp,sp,-32
ffffffffc0206002:	e822                	sd	s0,16(sp)
ffffffffc0206004:	ec06                	sd	ra,24(sp)
ffffffffc0206006:	e426                	sd	s1,8(sp)
ffffffffc0206008:	e04a                	sd	s2,0(sp)
ffffffffc020600a:	842e                	mv	s0,a1
                compare_f comp)
{
     if (a == NULL) return b;
ffffffffc020600c:	c11d                	beqz	a0,ffffffffc0206032 <skew_heap_merge.constprop.2+0x32>
ffffffffc020600e:	84aa                	mv	s1,a0
     else if (b == NULL) return a;
ffffffffc0206010:	c1b9                	beqz	a1,ffffffffc0206056 <skew_heap_merge.constprop.2+0x56>
     
     skew_heap_entry_t *l, *r;
     if (comp(a, b) == -1)
ffffffffc0206012:	f89ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206016:	57fd                	li	a5,-1
ffffffffc0206018:	02f50463          	beq	a0,a5,ffffffffc0206040 <skew_heap_merge.constprop.2+0x40>
          return a;
     }
     else
     {
          r = b->left;
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020601c:	680c                	ld	a1,16(s0)
          r = b->left;
ffffffffc020601e:	00843903          	ld	s2,8(s0)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206022:	8526                	mv	a0,s1
ffffffffc0206024:	fddff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          
          b->left = l;
ffffffffc0206028:	e408                	sd	a0,8(s0)
          b->right = r;
ffffffffc020602a:	01243823          	sd	s2,16(s0)
          if (l) l->parent = b;
ffffffffc020602e:	c111                	beqz	a0,ffffffffc0206032 <skew_heap_merge.constprop.2+0x32>
ffffffffc0206030:	e100                	sd	s0,0(a0)
ffffffffc0206032:	8522                	mv	a0,s0

          return b;
     }
}
ffffffffc0206034:	60e2                	ld	ra,24(sp)
ffffffffc0206036:	6442                	ld	s0,16(sp)
ffffffffc0206038:	64a2                	ld	s1,8(sp)
ffffffffc020603a:	6902                	ld	s2,0(sp)
ffffffffc020603c:	6105                	addi	sp,sp,32
ffffffffc020603e:	8082                	ret
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206040:	6888                	ld	a0,16(s1)
          r = a->left;
ffffffffc0206042:	0084b903          	ld	s2,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206046:	85a2                	mv	a1,s0
ffffffffc0206048:	fb9ff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020604c:	e488                	sd	a0,8(s1)
          a->right = r;
ffffffffc020604e:	0124b823          	sd	s2,16(s1)
          if (l) l->parent = a;
ffffffffc0206052:	c111                	beqz	a0,ffffffffc0206056 <skew_heap_merge.constprop.2+0x56>
ffffffffc0206054:	e104                	sd	s1,0(a0)
}
ffffffffc0206056:	60e2                	ld	ra,24(sp)
ffffffffc0206058:	6442                	ld	s0,16(sp)
          if (l) l->parent = a;
ffffffffc020605a:	8526                	mv	a0,s1
}
ffffffffc020605c:	6902                	ld	s2,0(sp)
ffffffffc020605e:	64a2                	ld	s1,8(sp)
ffffffffc0206060:	6105                	addi	sp,sp,32
ffffffffc0206062:	8082                	ret

ffffffffc0206064 <stride_enqueue>:
{
ffffffffc0206064:	7119                	addi	sp,sp,-128
ffffffffc0206066:	ecce                	sd	s3,88(sp)
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc0206068:	01853983          	ld	s3,24(a0)
{
ffffffffc020606c:	f8a2                	sd	s0,112(sp)
ffffffffc020606e:	f4a6                	sd	s1,104(sp)
ffffffffc0206070:	f0ca                	sd	s2,96(sp)
ffffffffc0206072:	fc86                	sd	ra,120(sp)
ffffffffc0206074:	e8d2                	sd	s4,80(sp)
ffffffffc0206076:	e4d6                	sd	s5,72(sp)
ffffffffc0206078:	e0da                	sd	s6,64(sp)
ffffffffc020607a:	fc5e                	sd	s7,56(sp)
ffffffffc020607c:	f862                	sd	s8,48(sp)
ffffffffc020607e:	f466                	sd	s9,40(sp)
ffffffffc0206080:	f06a                	sd	s10,32(sp)
ffffffffc0206082:	ec6e                	sd	s11,24(sp)
     a->left = a->right = a->parent = NULL;
ffffffffc0206084:	1205b423          	sd	zero,296(a1)
ffffffffc0206088:	1205bc23          	sd	zero,312(a1)
ffffffffc020608c:	1205b823          	sd	zero,304(a1)
ffffffffc0206090:	84aa                	mv	s1,a0
ffffffffc0206092:	842e                	mv	s0,a1
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc0206094:	12858913          	addi	s2,a1,296
     if (a == NULL) return b;
ffffffffc0206098:	02098063          	beqz	s3,ffffffffc02060b8 <stride_enqueue+0x54>
     else if (b == NULL) return a;
ffffffffc020609c:	08090c63          	beqz	s2,ffffffffc0206134 <stride_enqueue+0xd0>
     if (comp(a, b) == -1)
ffffffffc02060a0:	85ca                	mv	a1,s2
ffffffffc02060a2:	854e                	mv	a0,s3
ffffffffc02060a4:	ef7ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02060a8:	57fd                	li	a5,-1
ffffffffc02060aa:	8a2a                	mv	s4,a0
ffffffffc02060ac:	04f50563          	beq	a0,a5,ffffffffc02060f6 <stride_enqueue+0x92>
          b->left = l;
ffffffffc02060b0:	13343823          	sd	s3,304(s0)
          if (l) l->parent = b;
ffffffffc02060b4:	0129b023          	sd	s2,0(s3) # ffffffff80000000 <_binary_obj___user_matrix_out_size+0xffffffff7fff45a8>
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc02060b8:	12042783          	lw	a5,288(s0)
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc02060bc:	0124bc23          	sd	s2,24(s1)
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc02060c0:	48d8                	lw	a4,20(s1)
ffffffffc02060c2:	e79d                	bnez	a5,ffffffffc02060f0 <stride_enqueue+0x8c>
          proc->time_slice = rq->max_time_slice;
ffffffffc02060c4:	12e42023          	sw	a4,288(s0)
     rq->proc_num ++;
ffffffffc02060c8:	489c                	lw	a5,16(s1)
}
ffffffffc02060ca:	70e6                	ld	ra,120(sp)
     proc->rq = rq;
ffffffffc02060cc:	10943423          	sd	s1,264(s0)
}
ffffffffc02060d0:	7446                	ld	s0,112(sp)
     rq->proc_num ++;
ffffffffc02060d2:	2785                	addiw	a5,a5,1
ffffffffc02060d4:	c89c                	sw	a5,16(s1)
}
ffffffffc02060d6:	7906                	ld	s2,96(sp)
ffffffffc02060d8:	74a6                	ld	s1,104(sp)
ffffffffc02060da:	69e6                	ld	s3,88(sp)
ffffffffc02060dc:	6a46                	ld	s4,80(sp)
ffffffffc02060de:	6aa6                	ld	s5,72(sp)
ffffffffc02060e0:	6b06                	ld	s6,64(sp)
ffffffffc02060e2:	7be2                	ld	s7,56(sp)
ffffffffc02060e4:	7c42                	ld	s8,48(sp)
ffffffffc02060e6:	7ca2                	ld	s9,40(sp)
ffffffffc02060e8:	7d02                	ld	s10,32(sp)
ffffffffc02060ea:	6de2                	ld	s11,24(sp)
ffffffffc02060ec:	6109                	addi	sp,sp,128
ffffffffc02060ee:	8082                	ret
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc02060f0:	fcf75ce3          	ble	a5,a4,ffffffffc02060c8 <stride_enqueue+0x64>
ffffffffc02060f4:	bfc1                	j	ffffffffc02060c4 <stride_enqueue+0x60>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02060f6:	0109ba83          	ld	s5,16(s3)
          r = a->left;
ffffffffc02060fa:	0089bb03          	ld	s6,8(s3)
     if (a == NULL) return b;
ffffffffc02060fe:	000a8d63          	beqz	s5,ffffffffc0206118 <stride_enqueue+0xb4>
     if (comp(a, b) == -1)
ffffffffc0206102:	85ca                	mv	a1,s2
ffffffffc0206104:	8556                	mv	a0,s5
ffffffffc0206106:	e95ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020610a:	8baa                	mv	s7,a0
ffffffffc020610c:	03450c63          	beq	a0,s4,ffffffffc0206144 <stride_enqueue+0xe0>
          b->left = l;
ffffffffc0206110:	13543823          	sd	s5,304(s0)
          if (l) l->parent = b;
ffffffffc0206114:	012ab023          	sd	s2,0(s5)
          a->left = l;
ffffffffc0206118:	0129b423          	sd	s2,8(s3)
          a->right = r;
ffffffffc020611c:	0169b823          	sd	s6,16(s3)
ffffffffc0206120:	12042783          	lw	a5,288(s0)
          if (l) l->parent = a;
ffffffffc0206124:	01393023          	sd	s3,0(s2)
ffffffffc0206128:	894e                	mv	s2,s3
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc020612a:	0124bc23          	sd	s2,24(s1)
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc020612e:	48d8                	lw	a4,20(s1)
ffffffffc0206130:	dbd1                	beqz	a5,ffffffffc02060c4 <stride_enqueue+0x60>
ffffffffc0206132:	bf7d                	j	ffffffffc02060f0 <stride_enqueue+0x8c>
ffffffffc0206134:	12042783          	lw	a5,288(s0)
     else if (b == NULL) return a;
ffffffffc0206138:	894e                	mv	s2,s3
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc020613a:	0124bc23          	sd	s2,24(s1)
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc020613e:	48d8                	lw	a4,20(s1)
ffffffffc0206140:	d3d1                	beqz	a5,ffffffffc02060c4 <stride_enqueue+0x60>
ffffffffc0206142:	b77d                	j	ffffffffc02060f0 <stride_enqueue+0x8c>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206144:	010aba03          	ld	s4,16(s5)
          r = a->left;
ffffffffc0206148:	008abc03          	ld	s8,8(s5)
     if (a == NULL) return b;
ffffffffc020614c:	000a0d63          	beqz	s4,ffffffffc0206166 <stride_enqueue+0x102>
     if (comp(a, b) == -1)
ffffffffc0206150:	85ca                	mv	a1,s2
ffffffffc0206152:	8552                	mv	a0,s4
ffffffffc0206154:	e47ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206158:	8caa                	mv	s9,a0
ffffffffc020615a:	01750e63          	beq	a0,s7,ffffffffc0206176 <stride_enqueue+0x112>
          b->left = l;
ffffffffc020615e:	13443823          	sd	s4,304(s0)
          if (l) l->parent = b;
ffffffffc0206162:	012a3023          	sd	s2,0(s4)
          a->left = l;
ffffffffc0206166:	012ab423          	sd	s2,8(s5)
          a->right = r;
ffffffffc020616a:	018ab823          	sd	s8,16(s5)
          if (l) l->parent = a;
ffffffffc020616e:	01593023          	sd	s5,0(s2)
ffffffffc0206172:	8956                	mv	s2,s5
ffffffffc0206174:	b755                	j	ffffffffc0206118 <stride_enqueue+0xb4>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206176:	010a3b83          	ld	s7,16(s4)
          r = a->left;
ffffffffc020617a:	008a3d03          	ld	s10,8(s4)
     if (a == NULL) return b;
ffffffffc020617e:	000b8c63          	beqz	s7,ffffffffc0206196 <stride_enqueue+0x132>
     if (comp(a, b) == -1)
ffffffffc0206182:	85ca                	mv	a1,s2
ffffffffc0206184:	855e                	mv	a0,s7
ffffffffc0206186:	e15ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020618a:	01950e63          	beq	a0,s9,ffffffffc02061a6 <stride_enqueue+0x142>
          b->left = l;
ffffffffc020618e:	13743823          	sd	s7,304(s0)
          if (l) l->parent = b;
ffffffffc0206192:	012bb023          	sd	s2,0(s7)
          a->left = l;
ffffffffc0206196:	012a3423          	sd	s2,8(s4)
          a->right = r;
ffffffffc020619a:	01aa3823          	sd	s10,16(s4)
          if (l) l->parent = a;
ffffffffc020619e:	01493023          	sd	s4,0(s2)
ffffffffc02061a2:	8952                	mv	s2,s4
ffffffffc02061a4:	b7c9                	j	ffffffffc0206166 <stride_enqueue+0x102>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02061a6:	010bbc83          	ld	s9,16(s7)
          r = a->left;
ffffffffc02061aa:	008bbd83          	ld	s11,8(s7)
     if (a == NULL) return b;
ffffffffc02061ae:	000c8d63          	beqz	s9,ffffffffc02061c8 <stride_enqueue+0x164>
     if (comp(a, b) == -1)
ffffffffc02061b2:	85ca                	mv	a1,s2
ffffffffc02061b4:	8566                	mv	a0,s9
ffffffffc02061b6:	de5ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02061ba:	57fd                	li	a5,-1
ffffffffc02061bc:	00f50e63          	beq	a0,a5,ffffffffc02061d8 <stride_enqueue+0x174>
          b->left = l;
ffffffffc02061c0:	13943823          	sd	s9,304(s0)
          if (l) l->parent = b;
ffffffffc02061c4:	012cb023          	sd	s2,0(s9)
          a->left = l;
ffffffffc02061c8:	012bb423          	sd	s2,8(s7)
          a->right = r;
ffffffffc02061cc:	01bbb823          	sd	s11,16(s7)
          if (l) l->parent = a;
ffffffffc02061d0:	01793023          	sd	s7,0(s2)
ffffffffc02061d4:	895e                	mv	s2,s7
ffffffffc02061d6:	b7c1                	j	ffffffffc0206196 <stride_enqueue+0x132>
          r = a->left;
ffffffffc02061d8:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02061dc:	010cb503          	ld	a0,16(s9)
ffffffffc02061e0:	85ca                	mv	a1,s2
          r = a->left;
ffffffffc02061e2:	e43e                	sd	a5,8(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02061e4:	e1dff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02061e8:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc02061ea:	00acb423          	sd	a0,8(s9)
          a->right = r;
ffffffffc02061ee:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02061f2:	c509                	beqz	a0,ffffffffc02061fc <stride_enqueue+0x198>
ffffffffc02061f4:	01953023          	sd	s9,0(a0)
ffffffffc02061f8:	8966                	mv	s2,s9
ffffffffc02061fa:	b7f9                	j	ffffffffc02061c8 <stride_enqueue+0x164>
ffffffffc02061fc:	8966                	mv	s2,s9
ffffffffc02061fe:	b7e9                	j	ffffffffc02061c8 <stride_enqueue+0x164>

ffffffffc0206200 <stride_dequeue>:
{
ffffffffc0206200:	7171                	addi	sp,sp,-176
ffffffffc0206202:	ed26                	sd	s1,152(sp)
static inline skew_heap_entry_t *
skew_heap_remove(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_entry_t *p   = b->parent;
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
ffffffffc0206204:	1305b483          	ld	s1,304(a1)
ffffffffc0206208:	f122                	sd	s0,160(sp)
ffffffffc020620a:	e94a                	sd	s2,144(sp)
ffffffffc020620c:	fcd6                	sd	s5,120(sp)
ffffffffc020620e:	f8da                	sd	s6,112(sp)
ffffffffc0206210:	e4ee                	sd	s11,72(sp)
ffffffffc0206212:	f506                	sd	ra,168(sp)
ffffffffc0206214:	e54e                	sd	s3,136(sp)
ffffffffc0206216:	e152                	sd	s4,128(sp)
ffffffffc0206218:	f4de                	sd	s7,104(sp)
ffffffffc020621a:	f0e2                	sd	s8,96(sp)
ffffffffc020621c:	ece6                	sd	s9,88(sp)
ffffffffc020621e:	e8ea                	sd	s10,80(sp)
ffffffffc0206220:	892e                	mv	s2,a1
ffffffffc0206222:	8aaa                	mv	s5,a0
     rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc0206224:	01853b03          	ld	s6,24(a0)
     skew_heap_entry_t *p   = b->parent;
ffffffffc0206228:	1285bd83          	ld	s11,296(a1)
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
ffffffffc020622c:	1385b403          	ld	s0,312(a1)
     if (a == NULL) return b;
ffffffffc0206230:	2c048363          	beqz	s1,ffffffffc02064f6 <stride_dequeue+0x2f6>
     else if (b == NULL) return a;
ffffffffc0206234:	3e040163          	beqz	s0,ffffffffc0206616 <stride_dequeue+0x416>
     if (comp(a, b) == -1)
ffffffffc0206238:	85a2                	mv	a1,s0
ffffffffc020623a:	8526                	mv	a0,s1
ffffffffc020623c:	d5fff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206240:	5a7d                	li	s4,-1
ffffffffc0206242:	89aa                	mv	s3,a0
ffffffffc0206244:	17450d63          	beq	a0,s4,ffffffffc02063be <stride_dequeue+0x1be>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206248:	01043983          	ld	s3,16(s0)
          r = b->left;
ffffffffc020624c:	00843b83          	ld	s7,8(s0)
     else if (b == NULL) return a;
ffffffffc0206250:	12098163          	beqz	s3,ffffffffc0206372 <stride_dequeue+0x172>
     if (comp(a, b) == -1)
ffffffffc0206254:	85ce                	mv	a1,s3
ffffffffc0206256:	8526                	mv	a0,s1
ffffffffc0206258:	d43ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020625c:	8caa                	mv	s9,a0
ffffffffc020625e:	2b450563          	beq	a0,s4,ffffffffc0206508 <stride_dequeue+0x308>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206262:	0109bd03          	ld	s10,16(s3)
          r = b->left;
ffffffffc0206266:	0089bc03          	ld	s8,8(s3)
     else if (b == NULL) return a;
ffffffffc020626a:	0e0d0d63          	beqz	s10,ffffffffc0206364 <stride_dequeue+0x164>
     if (comp(a, b) == -1)
ffffffffc020626e:	85ea                	mv	a1,s10
ffffffffc0206270:	8526                	mv	a0,s1
ffffffffc0206272:	d29ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206276:	8caa                	mv	s9,a0
ffffffffc0206278:	75450a63          	beq	a0,s4,ffffffffc02069cc <stride_dequeue+0x7cc>
          r = b->left;
ffffffffc020627c:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206280:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc0206284:	e43e                	sd	a5,8(sp)
     else if (b == NULL) return a;
ffffffffc0206286:	0c0c8763          	beqz	s9,ffffffffc0206354 <stride_dequeue+0x154>
     if (comp(a, b) == -1)
ffffffffc020628a:	85e6                	mv	a1,s9
ffffffffc020628c:	8526                	mv	a0,s1
ffffffffc020628e:	d0dff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206292:	69450063          	beq	a0,s4,ffffffffc0206912 <stride_dequeue+0x712>
          r = b->left;
ffffffffc0206296:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020629a:	010cba03          	ld	s4,16(s9)
          r = b->left;
ffffffffc020629e:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc02062a0:	0a0a0263          	beqz	s4,ffffffffc0206344 <stride_dequeue+0x144>
     if (comp(a, b) == -1)
ffffffffc02062a4:	85d2                	mv	a1,s4
ffffffffc02062a6:	8526                	mv	a0,s1
ffffffffc02062a8:	cf3ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02062ac:	58fd                	li	a7,-1
ffffffffc02062ae:	351503e3          	beq	a0,a7,ffffffffc0206df4 <stride_dequeue+0xbf4>
          r = b->left;
ffffffffc02062b2:	008a3703          	ld	a4,8(s4)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02062b6:	010a3783          	ld	a5,16(s4)
          r = b->left;
ffffffffc02062ba:	ec3a                	sd	a4,24(sp)
     else if (b == NULL) return a;
ffffffffc02062bc:	cfa5                	beqz	a5,ffffffffc0206334 <stride_dequeue+0x134>
     if (comp(a, b) == -1)
ffffffffc02062be:	85be                	mv	a1,a5
ffffffffc02062c0:	8526                	mv	a0,s1
ffffffffc02062c2:	f03e                	sd	a5,32(sp)
ffffffffc02062c4:	cd7ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02062c8:	58fd                	li	a7,-1
ffffffffc02062ca:	7782                	ld	a5,32(sp)
ffffffffc02062cc:	01151463          	bne	a0,a7,ffffffffc02062d4 <stride_dequeue+0xd4>
ffffffffc02062d0:	0580106f          	j	ffffffffc0207328 <stride_dequeue+0x1128>
          r = b->left;
ffffffffc02062d4:	6798                	ld	a4,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02062d6:	0107b303          	ld	t1,16(a5)
          r = b->left;
ffffffffc02062da:	f03a                	sd	a4,32(sp)
     else if (b == NULL) return a;
ffffffffc02062dc:	00031463          	bnez	t1,ffffffffc02062e4 <stride_dequeue+0xe4>
ffffffffc02062e0:	6a00106f          	j	ffffffffc0207980 <stride_dequeue+0x1780>
     if (comp(a, b) == -1)
ffffffffc02062e4:	859a                	mv	a1,t1
ffffffffc02062e6:	8526                	mv	a0,s1
ffffffffc02062e8:	f83e                	sd	a5,48(sp)
ffffffffc02062ea:	f41a                	sd	t1,40(sp)
ffffffffc02062ec:	cafff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02062f0:	58fd                	li	a7,-1
ffffffffc02062f2:	7322                	ld	t1,40(sp)
ffffffffc02062f4:	77c2                	ld	a5,48(sp)
ffffffffc02062f6:	01151463          	bne	a0,a7,ffffffffc02062fe <stride_dequeue+0xfe>
ffffffffc02062fa:	6620106f          	j	ffffffffc020795c <stride_dequeue+0x175c>
          r = b->left;
ffffffffc02062fe:	00833883          	ld	a7,8(t1) # ffffffffc0000008 <_binary_obj___user_matrix_out_size+0xffffffffbfff45b0>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206302:	01033583          	ld	a1,16(t1)
ffffffffc0206306:	8526                	mv	a0,s1
ffffffffc0206308:	fc3e                	sd	a5,56(sp)
          r = b->left;
ffffffffc020630a:	f81a                	sd	t1,48(sp)
ffffffffc020630c:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020630e:	cf3ff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206312:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206314:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206316:	77e2                	ld	a5,56(sp)
          b->left = l;
ffffffffc0206318:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc020631c:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206320:	c119                	beqz	a0,ffffffffc0206326 <stride_dequeue+0x126>
ffffffffc0206322:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc0206326:	7702                	ld	a4,32(sp)
          b->left = l;
ffffffffc0206328:	0067b423          	sd	t1,8(a5)
          if (l) l->parent = b;
ffffffffc020632c:	84be                	mv	s1,a5
          b->right = r;
ffffffffc020632e:	eb98                	sd	a4,16(a5)
          if (l) l->parent = b;
ffffffffc0206330:	00f33023          	sd	a5,0(t1)
          b->right = r;
ffffffffc0206334:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206336:	009a3423          	sd	s1,8(s4)
          b->right = r;
ffffffffc020633a:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = b;
ffffffffc020633e:	0144b023          	sd	s4,0(s1)
ffffffffc0206342:	84d2                	mv	s1,s4
          b->right = r;
ffffffffc0206344:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206346:	009cb423          	sd	s1,8(s9)
          b->right = r;
ffffffffc020634a:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc020634e:	0194b023          	sd	s9,0(s1)
ffffffffc0206352:	84e6                	mv	s1,s9
          b->right = r;
ffffffffc0206354:	67a2                	ld	a5,8(sp)
          b->left = l;
ffffffffc0206356:	009d3423          	sd	s1,8(s10)
          b->right = r;
ffffffffc020635a:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc020635e:	01a4b023          	sd	s10,0(s1)
ffffffffc0206362:	84ea                	mv	s1,s10
          b->left = l;
ffffffffc0206364:	0099b423          	sd	s1,8(s3)
          b->right = r;
ffffffffc0206368:	0189b823          	sd	s8,16(s3)
          if (l) l->parent = b;
ffffffffc020636c:	0134b023          	sd	s3,0(s1)
ffffffffc0206370:	84ce                	mv	s1,s3
          b->left = l;
ffffffffc0206372:	e404                	sd	s1,8(s0)
          b->right = r;
ffffffffc0206374:	01743823          	sd	s7,16(s0)
          if (l) l->parent = b;
ffffffffc0206378:	e080                	sd	s0,0(s1)
     if (rep) rep->parent = p;
ffffffffc020637a:	01b43023          	sd	s11,0(s0)
     
     if (p)
ffffffffc020637e:	180d8063          	beqz	s11,ffffffffc02064fe <stride_dequeue+0x2fe>
     {
          if (p->left == b)
ffffffffc0206382:	008db703          	ld	a4,8(s11)
ffffffffc0206386:	12890913          	addi	s2,s2,296
ffffffffc020638a:	17270c63          	beq	a4,s2,ffffffffc0206502 <stride_dequeue+0x302>
               p->left = rep;
          else p->right = rep;
ffffffffc020638e:	008db823          	sd	s0,16(s11)
     rq->proc_num --;
ffffffffc0206392:	010aa783          	lw	a5,16(s5)
}
ffffffffc0206396:	70aa                	ld	ra,168(sp)
ffffffffc0206398:	740a                	ld	s0,160(sp)
     rq->proc_num --;
ffffffffc020639a:	37fd                	addiw	a5,a5,-1
     rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc020639c:	016abc23          	sd	s6,24(s5)
     rq->proc_num --;
ffffffffc02063a0:	00faa823          	sw	a5,16(s5)
}
ffffffffc02063a4:	64ea                	ld	s1,152(sp)
ffffffffc02063a6:	694a                	ld	s2,144(sp)
ffffffffc02063a8:	69aa                	ld	s3,136(sp)
ffffffffc02063aa:	6a0a                	ld	s4,128(sp)
ffffffffc02063ac:	7ae6                	ld	s5,120(sp)
ffffffffc02063ae:	7b46                	ld	s6,112(sp)
ffffffffc02063b0:	7ba6                	ld	s7,104(sp)
ffffffffc02063b2:	7c06                	ld	s8,96(sp)
ffffffffc02063b4:	6ce6                	ld	s9,88(sp)
ffffffffc02063b6:	6d46                	ld	s10,80(sp)
ffffffffc02063b8:	6da6                	ld	s11,72(sp)
ffffffffc02063ba:	614d                	addi	sp,sp,176
ffffffffc02063bc:	8082                	ret
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02063be:	0104ba03          	ld	s4,16(s1)
          r = a->left;
ffffffffc02063c2:	0084bb83          	ld	s7,8(s1)
     if (a == NULL) return b;
ffffffffc02063c6:	120a0063          	beqz	s4,ffffffffc02064e6 <stride_dequeue+0x2e6>
     if (comp(a, b) == -1)
ffffffffc02063ca:	85a2                	mv	a1,s0
ffffffffc02063cc:	8552                	mv	a0,s4
ffffffffc02063ce:	bcdff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02063d2:	8caa                	mv	s9,a0
ffffffffc02063d4:	25350563          	beq	a0,s3,ffffffffc020661e <stride_dequeue+0x41e>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02063d8:	01043d03          	ld	s10,16(s0)
          r = b->left;
ffffffffc02063dc:	00843c03          	ld	s8,8(s0)
     else if (b == NULL) return a;
ffffffffc02063e0:	0e0d0d63          	beqz	s10,ffffffffc02064da <stride_dequeue+0x2da>
     if (comp(a, b) == -1)
ffffffffc02063e4:	85ea                	mv	a1,s10
ffffffffc02063e6:	8552                	mv	a0,s4
ffffffffc02063e8:	bb3ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02063ec:	8caa                	mv	s9,a0
ffffffffc02063ee:	35350063          	beq	a0,s3,ffffffffc020672e <stride_dequeue+0x52e>
          r = b->left;
ffffffffc02063f2:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02063f6:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc02063fa:	e43e                	sd	a5,8(sp)
     else if (b == NULL) return a;
ffffffffc02063fc:	0c0c8763          	beqz	s9,ffffffffc02064ca <stride_dequeue+0x2ca>
     if (comp(a, b) == -1)
ffffffffc0206400:	85e6                	mv	a1,s9
ffffffffc0206402:	8552                	mv	a0,s4
ffffffffc0206404:	b97ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206408:	79350c63          	beq	a0,s3,ffffffffc0206ba0 <stride_dequeue+0x9a0>
          r = b->left;
ffffffffc020640c:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206410:	010cb983          	ld	s3,16(s9)
          r = b->left;
ffffffffc0206414:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206416:	0a098263          	beqz	s3,ffffffffc02064ba <stride_dequeue+0x2ba>
     if (comp(a, b) == -1)
ffffffffc020641a:	85ce                	mv	a1,s3
ffffffffc020641c:	8552                	mv	a0,s4
ffffffffc020641e:	b7dff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206422:	58fd                	li	a7,-1
ffffffffc0206424:	4b1507e3          	beq	a0,a7,ffffffffc02070d2 <stride_dequeue+0xed2>
          r = b->left;
ffffffffc0206428:	0089b703          	ld	a4,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020642c:	0109b783          	ld	a5,16(s3)
          r = b->left;
ffffffffc0206430:	ec3a                	sd	a4,24(sp)
     else if (b == NULL) return a;
ffffffffc0206432:	cfa5                	beqz	a5,ffffffffc02064aa <stride_dequeue+0x2aa>
     if (comp(a, b) == -1)
ffffffffc0206434:	85be                	mv	a1,a5
ffffffffc0206436:	8552                	mv	a0,s4
ffffffffc0206438:	f03e                	sd	a5,32(sp)
ffffffffc020643a:	b61ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020643e:	58fd                	li	a7,-1
ffffffffc0206440:	7782                	ld	a5,32(sp)
ffffffffc0206442:	01151463          	bne	a0,a7,ffffffffc020644a <stride_dequeue+0x24a>
ffffffffc0206446:	40e0106f          	j	ffffffffc0207854 <stride_dequeue+0x1654>
          r = b->left;
ffffffffc020644a:	6798                	ld	a4,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020644c:	0107b303          	ld	t1,16(a5)
          r = b->left;
ffffffffc0206450:	f03a                	sd	a4,32(sp)
     else if (b == NULL) return a;
ffffffffc0206452:	00031463          	bnez	t1,ffffffffc020645a <stride_dequeue+0x25a>
ffffffffc0206456:	0bb0106f          	j	ffffffffc0207d10 <stride_dequeue+0x1b10>
     if (comp(a, b) == -1)
ffffffffc020645a:	859a                	mv	a1,t1
ffffffffc020645c:	8552                	mv	a0,s4
ffffffffc020645e:	f83e                	sd	a5,48(sp)
ffffffffc0206460:	f41a                	sd	t1,40(sp)
ffffffffc0206462:	b39ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206466:	58fd                	li	a7,-1
ffffffffc0206468:	7322                	ld	t1,40(sp)
ffffffffc020646a:	77c2                	ld	a5,48(sp)
ffffffffc020646c:	01151463          	bne	a0,a7,ffffffffc0206474 <stride_dequeue+0x274>
ffffffffc0206470:	2310106f          	j	ffffffffc0207ea0 <stride_dequeue+0x1ca0>
          r = b->left;
ffffffffc0206474:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206478:	01033583          	ld	a1,16(t1)
ffffffffc020647c:	8552                	mv	a0,s4
ffffffffc020647e:	fc3e                	sd	a5,56(sp)
          r = b->left;
ffffffffc0206480:	f81a                	sd	t1,48(sp)
ffffffffc0206482:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206484:	b7dff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206488:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc020648a:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc020648c:	77e2                	ld	a5,56(sp)
          b->left = l;
ffffffffc020648e:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206492:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206496:	c119                	beqz	a0,ffffffffc020649c <stride_dequeue+0x29c>
ffffffffc0206498:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc020649c:	7702                	ld	a4,32(sp)
          b->left = l;
ffffffffc020649e:	0067b423          	sd	t1,8(a5)
          if (l) l->parent = b;
ffffffffc02064a2:	8a3e                	mv	s4,a5
          b->right = r;
ffffffffc02064a4:	eb98                	sd	a4,16(a5)
          if (l) l->parent = b;
ffffffffc02064a6:	00f33023          	sd	a5,0(t1)
          b->right = r;
ffffffffc02064aa:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02064ac:	0149b423          	sd	s4,8(s3)
          b->right = r;
ffffffffc02064b0:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = b;
ffffffffc02064b4:	013a3023          	sd	s3,0(s4)
ffffffffc02064b8:	8a4e                	mv	s4,s3
          b->right = r;
ffffffffc02064ba:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc02064bc:	014cb423          	sd	s4,8(s9)
          b->right = r;
ffffffffc02064c0:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc02064c4:	019a3023          	sd	s9,0(s4)
ffffffffc02064c8:	8a66                	mv	s4,s9
          b->right = r;
ffffffffc02064ca:	67a2                	ld	a5,8(sp)
          b->left = l;
ffffffffc02064cc:	014d3423          	sd	s4,8(s10)
          b->right = r;
ffffffffc02064d0:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc02064d4:	01aa3023          	sd	s10,0(s4)
ffffffffc02064d8:	8a6a                	mv	s4,s10
          b->left = l;
ffffffffc02064da:	01443423          	sd	s4,8(s0)
          b->right = r;
ffffffffc02064de:	01843823          	sd	s8,16(s0)
          if (l) l->parent = b;
ffffffffc02064e2:	008a3023          	sd	s0,0(s4)
          a->left = l;
ffffffffc02064e6:	e480                	sd	s0,8(s1)
          a->right = r;
ffffffffc02064e8:	0174b823          	sd	s7,16(s1)
          if (l) l->parent = a;
ffffffffc02064ec:	e004                	sd	s1,0(s0)
ffffffffc02064ee:	8426                	mv	s0,s1
     if (rep) rep->parent = p;
ffffffffc02064f0:	01b43023          	sd	s11,0(s0)
ffffffffc02064f4:	b569                	j	ffffffffc020637e <stride_dequeue+0x17e>
ffffffffc02064f6:	e80412e3          	bnez	s0,ffffffffc020637a <stride_dequeue+0x17a>
     if (p)
ffffffffc02064fa:	e80d94e3          	bnez	s11,ffffffffc0206382 <stride_dequeue+0x182>
ffffffffc02064fe:	8b22                	mv	s6,s0
ffffffffc0206500:	bd49                	j	ffffffffc0206392 <stride_dequeue+0x192>
               p->left = rep;
ffffffffc0206502:	008db423          	sd	s0,8(s11)
ffffffffc0206506:	b571                	j	ffffffffc0206392 <stride_dequeue+0x192>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206508:	0104bc03          	ld	s8,16(s1)
          r = a->left;
ffffffffc020650c:	0084ba03          	ld	s4,8(s1)
     if (a == NULL) return b;
ffffffffc0206510:	0e0c0c63          	beqz	s8,ffffffffc0206608 <stride_dequeue+0x408>
     if (comp(a, b) == -1)
ffffffffc0206514:	85ce                	mv	a1,s3
ffffffffc0206516:	8562                	mv	a0,s8
ffffffffc0206518:	a83ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020651c:	8d2a                	mv	s10,a0
ffffffffc020651e:	31950263          	beq	a0,s9,ffffffffc0206822 <stride_dequeue+0x622>
          r = b->left;
ffffffffc0206522:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206526:	0109bd03          	ld	s10,16(s3)
          r = b->left;
ffffffffc020652a:	e43e                	sd	a5,8(sp)
     else if (b == NULL) return a;
ffffffffc020652c:	0c0d0763          	beqz	s10,ffffffffc02065fa <stride_dequeue+0x3fa>
     if (comp(a, b) == -1)
ffffffffc0206530:	85ea                	mv	a1,s10
ffffffffc0206532:	8562                	mv	a0,s8
ffffffffc0206534:	a67ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206538:	7f950c63          	beq	a0,s9,ffffffffc0206d30 <stride_dequeue+0xb30>
          r = b->left;
ffffffffc020653c:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206540:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc0206544:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206546:	0a0c8263          	beqz	s9,ffffffffc02065ea <stride_dequeue+0x3ea>
     if (comp(a, b) == -1)
ffffffffc020654a:	85e6                	mv	a1,s9
ffffffffc020654c:	8562                	mv	a0,s8
ffffffffc020654e:	a4dff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206552:	58fd                	li	a7,-1
ffffffffc0206554:	41150ae3          	beq	a0,a7,ffffffffc0207168 <stride_dequeue+0xf68>
          r = b->left;
ffffffffc0206558:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020655c:	010cb783          	ld	a5,16(s9)
          r = b->left;
ffffffffc0206560:	ec3a                	sd	a4,24(sp)
     else if (b == NULL) return a;
ffffffffc0206562:	cfa5                	beqz	a5,ffffffffc02065da <stride_dequeue+0x3da>
     if (comp(a, b) == -1)
ffffffffc0206564:	85be                	mv	a1,a5
ffffffffc0206566:	8562                	mv	a0,s8
ffffffffc0206568:	f03e                	sd	a5,32(sp)
ffffffffc020656a:	a31ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020656e:	58fd                	li	a7,-1
ffffffffc0206570:	7782                	ld	a5,32(sp)
ffffffffc0206572:	01151463          	bne	a0,a7,ffffffffc020657a <stride_dequeue+0x37a>
ffffffffc0206576:	3340106f          	j	ffffffffc02078aa <stride_dequeue+0x16aa>
          r = b->left;
ffffffffc020657a:	6798                	ld	a4,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020657c:	0107b303          	ld	t1,16(a5)
          r = b->left;
ffffffffc0206580:	f03a                	sd	a4,32(sp)
     else if (b == NULL) return a;
ffffffffc0206582:	00031463          	bnez	t1,ffffffffc020658a <stride_dequeue+0x38a>
ffffffffc0206586:	7900106f          	j	ffffffffc0207d16 <stride_dequeue+0x1b16>
     if (comp(a, b) == -1)
ffffffffc020658a:	859a                	mv	a1,t1
ffffffffc020658c:	8562                	mv	a0,s8
ffffffffc020658e:	f83e                	sd	a5,48(sp)
ffffffffc0206590:	f41a                	sd	t1,40(sp)
ffffffffc0206592:	a09ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206596:	58fd                	li	a7,-1
ffffffffc0206598:	7322                	ld	t1,40(sp)
ffffffffc020659a:	77c2                	ld	a5,48(sp)
ffffffffc020659c:	01151463          	bne	a0,a7,ffffffffc02065a4 <stride_dequeue+0x3a4>
ffffffffc02065a0:	12b0106f          	j	ffffffffc0207eca <stride_dequeue+0x1cca>
          r = b->left;
ffffffffc02065a4:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02065a8:	01033583          	ld	a1,16(t1)
ffffffffc02065ac:	8562                	mv	a0,s8
ffffffffc02065ae:	fc3e                	sd	a5,56(sp)
          r = b->left;
ffffffffc02065b0:	f81a                	sd	t1,48(sp)
ffffffffc02065b2:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02065b4:	a4dff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02065b8:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02065ba:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02065bc:	77e2                	ld	a5,56(sp)
          b->left = l;
ffffffffc02065be:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02065c2:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02065c6:	c119                	beqz	a0,ffffffffc02065cc <stride_dequeue+0x3cc>
ffffffffc02065c8:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc02065cc:	7702                	ld	a4,32(sp)
          b->left = l;
ffffffffc02065ce:	0067b423          	sd	t1,8(a5)
          if (l) l->parent = b;
ffffffffc02065d2:	8c3e                	mv	s8,a5
          b->right = r;
ffffffffc02065d4:	eb98                	sd	a4,16(a5)
          if (l) l->parent = b;
ffffffffc02065d6:	00f33023          	sd	a5,0(t1)
          b->right = r;
ffffffffc02065da:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02065dc:	018cb423          	sd	s8,8(s9)
          b->right = r;
ffffffffc02065e0:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc02065e4:	019c3023          	sd	s9,0(s8)
ffffffffc02065e8:	8c66                	mv	s8,s9
          b->right = r;
ffffffffc02065ea:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc02065ec:	018d3423          	sd	s8,8(s10)
          b->right = r;
ffffffffc02065f0:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc02065f4:	01ac3023          	sd	s10,0(s8)
ffffffffc02065f8:	8c6a                	mv	s8,s10
          b->right = r;
ffffffffc02065fa:	67a2                	ld	a5,8(sp)
          b->left = l;
ffffffffc02065fc:	0189b423          	sd	s8,8(s3)
          b->right = r;
ffffffffc0206600:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = b;
ffffffffc0206604:	013c3023          	sd	s3,0(s8)
          a->left = l;
ffffffffc0206608:	0134b423          	sd	s3,8(s1)
          a->right = r;
ffffffffc020660c:	0144b823          	sd	s4,16(s1)
          if (l) l->parent = a;
ffffffffc0206610:	0099b023          	sd	s1,0(s3)
ffffffffc0206614:	bbb9                	j	ffffffffc0206372 <stride_dequeue+0x172>
     else if (b == NULL) return a;
ffffffffc0206616:	8426                	mv	s0,s1
     if (rep) rep->parent = p;
ffffffffc0206618:	01b43023          	sd	s11,0(s0)
ffffffffc020661c:	b38d                	j	ffffffffc020637e <stride_dequeue+0x17e>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020661e:	010a3c03          	ld	s8,16(s4)
          r = a->left;
ffffffffc0206622:	008a3983          	ld	s3,8(s4)
     if (a == NULL) return b;
ffffffffc0206626:	0e0c0c63          	beqz	s8,ffffffffc020671e <stride_dequeue+0x51e>
     if (comp(a, b) == -1)
ffffffffc020662a:	85a2                	mv	a1,s0
ffffffffc020662c:	8562                	mv	a0,s8
ffffffffc020662e:	96dff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206632:	8d2a                	mv	s10,a0
ffffffffc0206634:	49950063          	beq	a0,s9,ffffffffc0206ab4 <stride_dequeue+0x8b4>
          r = b->left;
ffffffffc0206638:	641c                	ld	a5,8(s0)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020663a:	01043d03          	ld	s10,16(s0)
          r = b->left;
ffffffffc020663e:	e43e                	sd	a5,8(sp)
     else if (b == NULL) return a;
ffffffffc0206640:	0c0d0963          	beqz	s10,ffffffffc0206712 <stride_dequeue+0x512>
     if (comp(a, b) == -1)
ffffffffc0206644:	85ea                	mv	a1,s10
ffffffffc0206646:	8562                	mv	a0,s8
ffffffffc0206648:	953ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020664c:	1d9500e3          	beq	a0,s9,ffffffffc020700c <stride_dequeue+0xe0c>
          r = b->left;
ffffffffc0206650:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206654:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc0206658:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc020665a:	0a0c8463          	beqz	s9,ffffffffc0206702 <stride_dequeue+0x502>
     if (comp(a, b) == -1)
ffffffffc020665e:	85e6                	mv	a1,s9
ffffffffc0206660:	8562                	mv	a0,s8
ffffffffc0206662:	939ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206666:	58fd                	li	a7,-1
ffffffffc0206668:	631507e3          	beq	a0,a7,ffffffffc0207496 <stride_dequeue+0x1296>
          r = b->left;
ffffffffc020666c:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206670:	010cb783          	ld	a5,16(s9)
          r = b->left;
ffffffffc0206674:	ec3a                	sd	a4,24(sp)
     else if (b == NULL) return a;
ffffffffc0206676:	e399                	bnez	a5,ffffffffc020667c <stride_dequeue+0x47c>
ffffffffc0206678:	1230106f          	j	ffffffffc0207f9a <stride_dequeue+0x1d9a>
     if (comp(a, b) == -1)
ffffffffc020667c:	85be                	mv	a1,a5
ffffffffc020667e:	8562                	mv	a0,s8
ffffffffc0206680:	f03e                	sd	a5,32(sp)
ffffffffc0206682:	919ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206686:	58fd                	li	a7,-1
ffffffffc0206688:	7782                	ld	a5,32(sp)
ffffffffc020668a:	01151463          	bne	a0,a7,ffffffffc0206692 <stride_dequeue+0x492>
ffffffffc020668e:	6f20106f          	j	ffffffffc0207d80 <stride_dequeue+0x1b80>
          r = b->left;
ffffffffc0206692:	6798                	ld	a4,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206694:	0107b303          	ld	t1,16(a5)
          r = b->left;
ffffffffc0206698:	f03a                	sd	a4,32(sp)
     else if (b == NULL) return a;
ffffffffc020669a:	04030663          	beqz	t1,ffffffffc02066e6 <stride_dequeue+0x4e6>
     if (comp(a, b) == -1)
ffffffffc020669e:	859a                	mv	a1,t1
ffffffffc02066a0:	8562                	mv	a0,s8
ffffffffc02066a2:	f83e                	sd	a5,48(sp)
ffffffffc02066a4:	f41a                	sd	t1,40(sp)
ffffffffc02066a6:	8f5ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02066aa:	58fd                	li	a7,-1
ffffffffc02066ac:	7322                	ld	t1,40(sp)
ffffffffc02066ae:	77c2                	ld	a5,48(sp)
ffffffffc02066b0:	01151463          	bne	a0,a7,ffffffffc02066b8 <stride_dequeue+0x4b8>
ffffffffc02066b4:	4190106f          	j	ffffffffc02082cc <stride_dequeue+0x20cc>
          r = b->left;
ffffffffc02066b8:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02066bc:	01033583          	ld	a1,16(t1)
ffffffffc02066c0:	8562                	mv	a0,s8
ffffffffc02066c2:	fc3e                	sd	a5,56(sp)
          r = b->left;
ffffffffc02066c4:	f81a                	sd	t1,48(sp)
ffffffffc02066c6:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02066c8:	939ff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02066cc:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02066ce:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02066d0:	77e2                	ld	a5,56(sp)
          b->left = l;
ffffffffc02066d2:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02066d6:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02066da:	e119                	bnez	a0,ffffffffc02066e0 <stride_dequeue+0x4e0>
ffffffffc02066dc:	57b0106f          	j	ffffffffc0208456 <stride_dequeue+0x2256>
ffffffffc02066e0:	00653023          	sd	t1,0(a0)
ffffffffc02066e4:	8c1a                	mv	s8,t1
          b->right = r;
ffffffffc02066e6:	7702                	ld	a4,32(sp)
          b->left = l;
ffffffffc02066e8:	0187b423          	sd	s8,8(a5)
          b->right = r;
ffffffffc02066ec:	eb98                	sd	a4,16(a5)
          if (l) l->parent = b;
ffffffffc02066ee:	00fc3023          	sd	a5,0(s8)
          b->right = r;
ffffffffc02066f2:	6762                	ld	a4,24(sp)
          b->left = l;
ffffffffc02066f4:	00fcb423          	sd	a5,8(s9)
          if (l) l->parent = b;
ffffffffc02066f8:	8c66                	mv	s8,s9
          b->right = r;
ffffffffc02066fa:	00ecb823          	sd	a4,16(s9)
          if (l) l->parent = b;
ffffffffc02066fe:	0197b023          	sd	s9,0(a5)
          b->right = r;
ffffffffc0206702:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206704:	018d3423          	sd	s8,8(s10)
          b->right = r;
ffffffffc0206708:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc020670c:	01ac3023          	sd	s10,0(s8)
ffffffffc0206710:	8c6a                	mv	s8,s10
          b->right = r;
ffffffffc0206712:	67a2                	ld	a5,8(sp)
          b->left = l;
ffffffffc0206714:	01843423          	sd	s8,8(s0)
          b->right = r;
ffffffffc0206718:	e81c                	sd	a5,16(s0)
          if (l) l->parent = b;
ffffffffc020671a:	008c3023          	sd	s0,0(s8)
          a->left = l;
ffffffffc020671e:	008a3423          	sd	s0,8(s4)
          a->right = r;
ffffffffc0206722:	013a3823          	sd	s3,16(s4)
          if (l) l->parent = a;
ffffffffc0206726:	01443023          	sd	s4,0(s0)
ffffffffc020672a:	8452                	mv	s0,s4
ffffffffc020672c:	bb6d                	j	ffffffffc02064e6 <stride_dequeue+0x2e6>
          r = a->left;
ffffffffc020672e:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206732:	010a3983          	ld	s3,16(s4)
          r = a->left;
ffffffffc0206736:	e43e                	sd	a5,8(sp)
     if (a == NULL) return b;
ffffffffc0206738:	0c098d63          	beqz	s3,ffffffffc0206812 <stride_dequeue+0x612>
     if (comp(a, b) == -1)
ffffffffc020673c:	85ea                	mv	a1,s10
ffffffffc020673e:	854e                	mv	a0,s3
ffffffffc0206740:	85bff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206744:	73950e63          	beq	a0,s9,ffffffffc0206e80 <stride_dequeue+0xc80>
          r = b->left;
ffffffffc0206748:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020674c:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc0206750:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206752:	0a0c8963          	beqz	s9,ffffffffc0206804 <stride_dequeue+0x604>
     if (comp(a, b) == -1)
ffffffffc0206756:	85e6                	mv	a1,s9
ffffffffc0206758:	854e                	mv	a0,s3
ffffffffc020675a:	841ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020675e:	58fd                	li	a7,-1
ffffffffc0206760:	01151463          	bne	a0,a7,ffffffffc0206768 <stride_dequeue+0x568>
ffffffffc0206764:	7070006f          	j	ffffffffc020766a <stride_dequeue+0x146a>
          r = b->left;
ffffffffc0206768:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020676c:	010cb803          	ld	a6,16(s9)
          r = b->left;
ffffffffc0206770:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206772:	00081463          	bnez	a6,ffffffffc020677a <stride_dequeue+0x57a>
ffffffffc0206776:	02b0106f          	j	ffffffffc0207fa0 <stride_dequeue+0x1da0>
     if (comp(a, b) == -1)
ffffffffc020677a:	85c2                	mv	a1,a6
ffffffffc020677c:	854e                	mv	a0,s3
ffffffffc020677e:	f042                	sd	a6,32(sp)
ffffffffc0206780:	81bff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206784:	58fd                	li	a7,-1
ffffffffc0206786:	7802                	ld	a6,32(sp)
ffffffffc0206788:	01151463          	bne	a0,a7,ffffffffc0206790 <stride_dequeue+0x590>
ffffffffc020678c:	5260106f          	j	ffffffffc0207cb2 <stride_dequeue+0x1ab2>
          r = b->left;
ffffffffc0206790:	00883783          	ld	a5,8(a6) # fffffffffffff008 <end+0x3fd35cf0>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206794:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206798:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc020679a:	04030663          	beqz	t1,ffffffffc02067e6 <stride_dequeue+0x5e6>
     if (comp(a, b) == -1)
ffffffffc020679e:	859a                	mv	a1,t1
ffffffffc02067a0:	854e                	mv	a0,s3
ffffffffc02067a2:	f842                	sd	a6,48(sp)
ffffffffc02067a4:	f41a                	sd	t1,40(sp)
ffffffffc02067a6:	ff4ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02067aa:	58fd                	li	a7,-1
ffffffffc02067ac:	7322                	ld	t1,40(sp)
ffffffffc02067ae:	7842                	ld	a6,48(sp)
ffffffffc02067b0:	01151463          	bne	a0,a7,ffffffffc02067b8 <stride_dequeue+0x5b8>
ffffffffc02067b4:	0ab0106f          	j	ffffffffc020805e <stride_dequeue+0x1e5e>
          r = b->left;
ffffffffc02067b8:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02067bc:	01033583          	ld	a1,16(t1)
ffffffffc02067c0:	854e                	mv	a0,s3
ffffffffc02067c2:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc02067c4:	f81a                	sd	t1,48(sp)
ffffffffc02067c6:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02067c8:	839ff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02067cc:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02067ce:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02067d0:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc02067d2:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02067d6:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02067da:	e119                	bnez	a0,ffffffffc02067e0 <stride_dequeue+0x5e0>
ffffffffc02067dc:	4fb0106f          	j	ffffffffc02084d6 <stride_dequeue+0x22d6>
ffffffffc02067e0:	00653023          	sd	t1,0(a0)
ffffffffc02067e4:	899a                	mv	s3,t1
          b->right = r;
ffffffffc02067e6:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02067e8:	01383423          	sd	s3,8(a6)
          b->right = r;
ffffffffc02067ec:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc02067f0:	0109b023          	sd	a6,0(s3)
          b->right = r;
ffffffffc02067f4:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02067f6:	010cb423          	sd	a6,8(s9)
          if (l) l->parent = b;
ffffffffc02067fa:	89e6                	mv	s3,s9
          b->right = r;
ffffffffc02067fc:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0206800:	01983023          	sd	s9,0(a6)
          b->right = r;
ffffffffc0206804:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206806:	013d3423          	sd	s3,8(s10)
          b->right = r;
ffffffffc020680a:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc020680e:	01a9b023          	sd	s10,0(s3)
          a->right = r;
ffffffffc0206812:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc0206814:	01aa3423          	sd	s10,8(s4)
          a->right = r;
ffffffffc0206818:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc020681c:	014d3023          	sd	s4,0(s10)
ffffffffc0206820:	b96d                	j	ffffffffc02064da <stride_dequeue+0x2da>
          r = a->left;
ffffffffc0206822:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206826:	010c3c83          	ld	s9,16(s8)
          r = a->left;
ffffffffc020682a:	e43e                	sd	a5,8(sp)
     if (a == NULL) return b;
ffffffffc020682c:	0c0c8a63          	beqz	s9,ffffffffc0206900 <stride_dequeue+0x700>
     if (comp(a, b) == -1)
ffffffffc0206830:	85ce                	mv	a1,s3
ffffffffc0206832:	8566                	mv	a0,s9
ffffffffc0206834:	f66ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206838:	71a50763          	beq	a0,s10,ffffffffc0206f46 <stride_dequeue+0xd46>
          r = b->left;
ffffffffc020683c:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206840:	0109b603          	ld	a2,16(s3)
          r = b->left;
ffffffffc0206844:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206846:	c655                	beqz	a2,ffffffffc02068f2 <stride_dequeue+0x6f2>
     if (comp(a, b) == -1)
ffffffffc0206848:	85b2                	mv	a1,a2
ffffffffc020684a:	8566                	mv	a0,s9
ffffffffc020684c:	ec32                	sd	a2,24(sp)
ffffffffc020684e:	f4cff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206852:	58fd                	li	a7,-1
ffffffffc0206854:	6662                	ld	a2,24(sp)
ffffffffc0206856:	6b1506e3          	beq	a0,a7,ffffffffc0207702 <stride_dequeue+0x1502>
          r = b->left;
ffffffffc020685a:	661c                	ld	a5,8(a2)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020685c:	01063d03          	ld	s10,16(a2)
          r = b->left;
ffffffffc0206860:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206862:	000d1463          	bnez	s10,ffffffffc020686a <stride_dequeue+0x66a>
ffffffffc0206866:	7520106f          	j	ffffffffc0207fb8 <stride_dequeue+0x1db8>
     if (comp(a, b) == -1)
ffffffffc020686a:	85ea                	mv	a1,s10
ffffffffc020686c:	8566                	mv	a0,s9
ffffffffc020686e:	f032                	sd	a2,32(sp)
ffffffffc0206870:	f2aff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206874:	58fd                	li	a7,-1
ffffffffc0206876:	7602                	ld	a2,32(sp)
ffffffffc0206878:	01151463          	bne	a0,a7,ffffffffc0206880 <stride_dequeue+0x680>
ffffffffc020687c:	4a60106f          	j	ffffffffc0207d22 <stride_dequeue+0x1b22>
          r = b->left;
ffffffffc0206880:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206884:	010d3303          	ld	t1,16(s10)
          r = b->left;
ffffffffc0206888:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc020688a:	04030663          	beqz	t1,ffffffffc02068d6 <stride_dequeue+0x6d6>
     if (comp(a, b) == -1)
ffffffffc020688e:	859a                	mv	a1,t1
ffffffffc0206890:	8566                	mv	a0,s9
ffffffffc0206892:	f832                	sd	a2,48(sp)
ffffffffc0206894:	f41a                	sd	t1,40(sp)
ffffffffc0206896:	f04ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020689a:	58fd                	li	a7,-1
ffffffffc020689c:	7322                	ld	t1,40(sp)
ffffffffc020689e:	7642                	ld	a2,48(sp)
ffffffffc02068a0:	01151463          	bne	a0,a7,ffffffffc02068a8 <stride_dequeue+0x6a8>
ffffffffc02068a4:	2f70106f          	j	ffffffffc020839a <stride_dequeue+0x219a>
          r = b->left;
ffffffffc02068a8:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02068ac:	01033583          	ld	a1,16(t1)
ffffffffc02068b0:	8566                	mv	a0,s9
ffffffffc02068b2:	fc32                	sd	a2,56(sp)
          r = b->left;
ffffffffc02068b4:	f81a                	sd	t1,48(sp)
ffffffffc02068b6:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02068b8:	f48ff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02068bc:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02068be:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02068c0:	7662                	ld	a2,56(sp)
          b->left = l;
ffffffffc02068c2:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02068c6:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02068ca:	e119                	bnez	a0,ffffffffc02068d0 <stride_dequeue+0x6d0>
ffffffffc02068cc:	3590106f          	j	ffffffffc0208424 <stride_dequeue+0x2224>
ffffffffc02068d0:	00653023          	sd	t1,0(a0)
ffffffffc02068d4:	8c9a                	mv	s9,t1
          b->right = r;
ffffffffc02068d6:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02068d8:	019d3423          	sd	s9,8(s10)
          b->right = r;
ffffffffc02068dc:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc02068e0:	01acb023          	sd	s10,0(s9)
          b->right = r;
ffffffffc02068e4:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02068e6:	01a63423          	sd	s10,8(a2)
          if (l) l->parent = b;
ffffffffc02068ea:	8cb2                	mv	s9,a2
          b->right = r;
ffffffffc02068ec:	ea1c                	sd	a5,16(a2)
          if (l) l->parent = b;
ffffffffc02068ee:	00cd3023          	sd	a2,0(s10)
          b->right = r;
ffffffffc02068f2:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc02068f4:	0199b423          	sd	s9,8(s3)
          b->right = r;
ffffffffc02068f8:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = b;
ffffffffc02068fc:	013cb023          	sd	s3,0(s9)
          a->right = r;
ffffffffc0206900:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc0206902:	013c3423          	sd	s3,8(s8)
          a->right = r;
ffffffffc0206906:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc020690a:	0189b023          	sd	s8,0(s3)
ffffffffc020690e:	89e2                	mv	s3,s8
ffffffffc0206910:	b9e5                	j	ffffffffc0206608 <stride_dequeue+0x408>
          r = a->left;
ffffffffc0206912:	649c                	ld	a5,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206914:	0104ba03          	ld	s4,16(s1)
          r = a->left;
ffffffffc0206918:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc020691a:	0a0a0263          	beqz	s4,ffffffffc02069be <stride_dequeue+0x7be>
     if (comp(a, b) == -1)
ffffffffc020691e:	85e6                	mv	a1,s9
ffffffffc0206920:	8552                	mv	a0,s4
ffffffffc0206922:	e78ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206926:	58fd                	li	a7,-1
ffffffffc0206928:	171504e3          	beq	a0,a7,ffffffffc0207290 <stride_dequeue+0x1090>
          r = b->left;
ffffffffc020692c:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206930:	010cb803          	ld	a6,16(s9)
          r = b->left;
ffffffffc0206934:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206936:	06080d63          	beqz	a6,ffffffffc02069b0 <stride_dequeue+0x7b0>
     if (comp(a, b) == -1)
ffffffffc020693a:	85c2                	mv	a1,a6
ffffffffc020693c:	8552                	mv	a0,s4
ffffffffc020693e:	f042                	sd	a6,32(sp)
ffffffffc0206940:	e5aff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206944:	58fd                	li	a7,-1
ffffffffc0206946:	7802                	ld	a6,32(sp)
ffffffffc0206948:	6b1508e3          	beq	a0,a7,ffffffffc02077f8 <stride_dequeue+0x15f8>
          r = b->left;
ffffffffc020694c:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206950:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206954:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206956:	00031463          	bnez	t1,ffffffffc020695e <stride_dequeue+0x75e>
ffffffffc020695a:	4dc0106f          	j	ffffffffc0207e36 <stride_dequeue+0x1c36>
     if (comp(a, b) == -1)
ffffffffc020695e:	859a                	mv	a1,t1
ffffffffc0206960:	8552                	mv	a0,s4
ffffffffc0206962:	f842                	sd	a6,48(sp)
ffffffffc0206964:	f41a                	sd	t1,40(sp)
ffffffffc0206966:	e34ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020696a:	58fd                	li	a7,-1
ffffffffc020696c:	7322                	ld	t1,40(sp)
ffffffffc020696e:	7842                	ld	a6,48(sp)
ffffffffc0206970:	01151463          	bne	a0,a7,ffffffffc0206978 <stride_dequeue+0x778>
ffffffffc0206974:	5800106f          	j	ffffffffc0207ef4 <stride_dequeue+0x1cf4>
          r = b->left;
ffffffffc0206978:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020697c:	01033583          	ld	a1,16(t1)
ffffffffc0206980:	8552                	mv	a0,s4
ffffffffc0206982:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206984:	f81a                	sd	t1,48(sp)
ffffffffc0206986:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206988:	e78ff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc020698c:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc020698e:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206990:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206992:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206996:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc020699a:	c119                	beqz	a0,ffffffffc02069a0 <stride_dequeue+0x7a0>
ffffffffc020699c:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc02069a0:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02069a2:	00683423          	sd	t1,8(a6)
          if (l) l->parent = b;
ffffffffc02069a6:	8a42                	mv	s4,a6
          b->right = r;
ffffffffc02069a8:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc02069ac:	01033023          	sd	a6,0(t1)
          b->right = r;
ffffffffc02069b0:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02069b2:	014cb423          	sd	s4,8(s9)
          b->right = r;
ffffffffc02069b6:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc02069ba:	019a3023          	sd	s9,0(s4)
          a->right = r;
ffffffffc02069be:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc02069c0:	0194b423          	sd	s9,8(s1)
          a->right = r;
ffffffffc02069c4:	e89c                	sd	a5,16(s1)
          if (l) l->parent = a;
ffffffffc02069c6:	009cb023          	sd	s1,0(s9)
ffffffffc02069ca:	b269                	j	ffffffffc0206354 <stride_dequeue+0x154>
          r = a->left;
ffffffffc02069cc:	649c                	ld	a5,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02069ce:	0104ba03          	ld	s4,16(s1)
          r = a->left;
ffffffffc02069d2:	e43e                	sd	a5,8(sp)
     if (a == NULL) return b;
ffffffffc02069d4:	0c0a0963          	beqz	s4,ffffffffc0206aa6 <stride_dequeue+0x8a6>
     if (comp(a, b) == -1)
ffffffffc02069d8:	85ea                	mv	a1,s10
ffffffffc02069da:	8552                	mv	a0,s4
ffffffffc02069dc:	dbeff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02069e0:	29950463          	beq	a0,s9,ffffffffc0206c68 <stride_dequeue+0xa68>
          r = b->left;
ffffffffc02069e4:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02069e8:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc02069ec:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc02069ee:	0a0c8563          	beqz	s9,ffffffffc0206a98 <stride_dequeue+0x898>
     if (comp(a, b) == -1)
ffffffffc02069f2:	85e6                	mv	a1,s9
ffffffffc02069f4:	8552                	mv	a0,s4
ffffffffc02069f6:	da4ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02069fa:	58fd                	li	a7,-1
ffffffffc02069fc:	011501e3          	beq	a0,a7,ffffffffc02071fe <stride_dequeue+0xffe>
          r = b->left;
ffffffffc0206a00:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206a04:	010cb803          	ld	a6,16(s9)
          r = b->left;
ffffffffc0206a08:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206a0a:	06080f63          	beqz	a6,ffffffffc0206a88 <stride_dequeue+0x888>
     if (comp(a, b) == -1)
ffffffffc0206a0e:	85c2                	mv	a1,a6
ffffffffc0206a10:	8552                	mv	a0,s4
ffffffffc0206a12:	f042                	sd	a6,32(sp)
ffffffffc0206a14:	d86ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206a18:	58fd                	li	a7,-1
ffffffffc0206a1a:	7802                	ld	a6,32(sp)
ffffffffc0206a1c:	01151463          	bne	a0,a7,ffffffffc0206a24 <stride_dequeue+0x824>
ffffffffc0206a20:	6e10006f          	j	ffffffffc0207900 <stride_dequeue+0x1700>
          r = b->left;
ffffffffc0206a24:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206a28:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206a2c:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206a2e:	00031463          	bnez	t1,ffffffffc0206a36 <stride_dequeue+0x836>
ffffffffc0206a32:	40a0106f          	j	ffffffffc0207e3c <stride_dequeue+0x1c3c>
     if (comp(a, b) == -1)
ffffffffc0206a36:	859a                	mv	a1,t1
ffffffffc0206a38:	8552                	mv	a0,s4
ffffffffc0206a3a:	f842                	sd	a6,48(sp)
ffffffffc0206a3c:	f41a                	sd	t1,40(sp)
ffffffffc0206a3e:	d5cff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206a42:	58fd                	li	a7,-1
ffffffffc0206a44:	7322                	ld	t1,40(sp)
ffffffffc0206a46:	7842                	ld	a6,48(sp)
ffffffffc0206a48:	01151463          	bne	a0,a7,ffffffffc0206a50 <stride_dequeue+0x850>
ffffffffc0206a4c:	5240106f          	j	ffffffffc0207f70 <stride_dequeue+0x1d70>
          r = b->left;
ffffffffc0206a50:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206a54:	01033583          	ld	a1,16(t1)
ffffffffc0206a58:	8552                	mv	a0,s4
ffffffffc0206a5a:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206a5c:	f81a                	sd	t1,48(sp)
ffffffffc0206a5e:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206a60:	da0ff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206a64:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206a66:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206a68:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206a6a:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206a6e:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206a72:	c119                	beqz	a0,ffffffffc0206a78 <stride_dequeue+0x878>
ffffffffc0206a74:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc0206a78:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206a7a:	00683423          	sd	t1,8(a6)
          if (l) l->parent = b;
ffffffffc0206a7e:	8a42                	mv	s4,a6
          b->right = r;
ffffffffc0206a80:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206a84:	01033023          	sd	a6,0(t1)
          b->right = r;
ffffffffc0206a88:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206a8a:	014cb423          	sd	s4,8(s9)
          b->right = r;
ffffffffc0206a8e:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0206a92:	019a3023          	sd	s9,0(s4)
ffffffffc0206a96:	8a66                	mv	s4,s9
          b->right = r;
ffffffffc0206a98:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206a9a:	014d3423          	sd	s4,8(s10)
          b->right = r;
ffffffffc0206a9e:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206aa2:	01aa3023          	sd	s10,0(s4)
          a->right = r;
ffffffffc0206aa6:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc0206aa8:	01a4b423          	sd	s10,8(s1)
          a->right = r;
ffffffffc0206aac:	e89c                	sd	a5,16(s1)
          if (l) l->parent = a;
ffffffffc0206aae:	009d3023          	sd	s1,0(s10)
ffffffffc0206ab2:	b84d                	j	ffffffffc0206364 <stride_dequeue+0x164>
          r = a->left;
ffffffffc0206ab4:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206ab8:	010c3c83          	ld	s9,16(s8)
          r = a->left;
ffffffffc0206abc:	e43e                	sd	a5,8(sp)
     if (a == NULL) return b;
ffffffffc0206abe:	0c0c8863          	beqz	s9,ffffffffc0206b8e <stride_dequeue+0x98e>
     if (comp(a, b) == -1)
ffffffffc0206ac2:	85a2                	mv	a1,s0
ffffffffc0206ac4:	8566                	mv	a0,s9
ffffffffc0206ac6:	cd4ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206aca:	0ba506e3          	beq	a0,s10,ffffffffc0207376 <stride_dequeue+0x1176>
          r = b->left;
ffffffffc0206ace:	641c                	ld	a5,8(s0)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206ad0:	01043d03          	ld	s10,16(s0)
          r = b->left;
ffffffffc0206ad4:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206ad6:	000d1463          	bnez	s10,ffffffffc0206ade <stride_dequeue+0x8de>
ffffffffc0206ada:	2420106f          	j	ffffffffc0207d1c <stride_dequeue+0x1b1c>
     if (comp(a, b) == -1)
ffffffffc0206ade:	85ea                	mv	a1,s10
ffffffffc0206ae0:	8566                	mv	a0,s9
ffffffffc0206ae2:	cb8ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206ae6:	537d                	li	t1,-1
ffffffffc0206ae8:	00651463          	bne	a0,t1,ffffffffc0206af0 <stride_dequeue+0x8f0>
ffffffffc0206aec:	6ef0006f          	j	ffffffffc02079da <stride_dequeue+0x17da>
          r = b->left;
ffffffffc0206af0:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206af4:	010d3703          	ld	a4,16(s10)
          r = b->left;
ffffffffc0206af8:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206afa:	cf2d                	beqz	a4,ffffffffc0206b74 <stride_dequeue+0x974>
     if (comp(a, b) == -1)
ffffffffc0206afc:	85ba                	mv	a1,a4
ffffffffc0206afe:	8566                	mv	a0,s9
ffffffffc0206b00:	f03a                	sd	a4,32(sp)
ffffffffc0206b02:	c98ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206b06:	537d                	li	t1,-1
ffffffffc0206b08:	7702                	ld	a4,32(sp)
ffffffffc0206b0a:	00651463          	bne	a0,t1,ffffffffc0206b12 <stride_dequeue+0x912>
ffffffffc0206b0e:	69e0106f          	j	ffffffffc02081ac <stride_dequeue+0x1fac>
          r = b->left;
ffffffffc0206b12:	671c                	ld	a5,8(a4)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206b14:	01073883          	ld	a7,16(a4) # ffffffff80000010 <_binary_obj___user_matrix_out_size+0xffffffff7fff45b8>
          r = b->left;
ffffffffc0206b18:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206b1a:	04088663          	beqz	a7,ffffffffc0206b66 <stride_dequeue+0x966>
     if (comp(a, b) == -1)
ffffffffc0206b1e:	85c6                	mv	a1,a7
ffffffffc0206b20:	8566                	mv	a0,s9
ffffffffc0206b22:	f83a                	sd	a4,48(sp)
ffffffffc0206b24:	f446                	sd	a7,40(sp)
ffffffffc0206b26:	c74ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206b2a:	537d                	li	t1,-1
ffffffffc0206b2c:	78a2                	ld	a7,40(sp)
ffffffffc0206b2e:	7742                	ld	a4,48(sp)
ffffffffc0206b30:	00651463          	bne	a0,t1,ffffffffc0206b38 <stride_dequeue+0x938>
ffffffffc0206b34:	4010106f          	j	ffffffffc0208734 <stride_dequeue+0x2534>
          r = b->left;
ffffffffc0206b38:	0088b303          	ld	t1,8(a7) # 2008 <_binary_obj___user_faultread_out_size-0x78e8>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206b3c:	0108b583          	ld	a1,16(a7)
ffffffffc0206b40:	8566                	mv	a0,s9
ffffffffc0206b42:	fc3a                	sd	a4,56(sp)
          r = b->left;
ffffffffc0206b44:	f846                	sd	a7,48(sp)
ffffffffc0206b46:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206b48:	cb8ff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206b4c:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0206b4e:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc0206b50:	7762                	ld	a4,56(sp)
          b->left = l;
ffffffffc0206b52:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0206b56:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0206b5a:	e119                	bnez	a0,ffffffffc0206b60 <stride_dequeue+0x960>
ffffffffc0206b5c:	5510106f          	j	ffffffffc02088ac <stride_dequeue+0x26ac>
ffffffffc0206b60:	01153023          	sd	a7,0(a0)
ffffffffc0206b64:	8cc6                	mv	s9,a7
          b->right = r;
ffffffffc0206b66:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206b68:	01973423          	sd	s9,8(a4)
          b->right = r;
ffffffffc0206b6c:	eb1c                	sd	a5,16(a4)
          if (l) l->parent = b;
ffffffffc0206b6e:	00ecb023          	sd	a4,0(s9)
ffffffffc0206b72:	8cba                	mv	s9,a4
          b->right = r;
ffffffffc0206b74:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206b76:	019d3423          	sd	s9,8(s10)
          b->right = r;
ffffffffc0206b7a:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206b7e:	01acb023          	sd	s10,0(s9)
          b->right = r;
ffffffffc0206b82:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206b84:	01a43423          	sd	s10,8(s0)
          b->right = r;
ffffffffc0206b88:	e81c                	sd	a5,16(s0)
          if (l) l->parent = b;
ffffffffc0206b8a:	008d3023          	sd	s0,0(s10)
          a->right = r;
ffffffffc0206b8e:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc0206b90:	008c3423          	sd	s0,8(s8)
          a->right = r;
ffffffffc0206b94:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc0206b98:	01843023          	sd	s8,0(s0)
ffffffffc0206b9c:	8462                	mv	s0,s8
ffffffffc0206b9e:	b641                	j	ffffffffc020671e <stride_dequeue+0x51e>
          r = a->left;
ffffffffc0206ba0:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206ba4:	010a3983          	ld	s3,16(s4)
          r = a->left;
ffffffffc0206ba8:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206baa:	0a098663          	beqz	s3,ffffffffc0206c56 <stride_dequeue+0xa56>
     if (comp(a, b) == -1)
ffffffffc0206bae:	85e6                	mv	a1,s9
ffffffffc0206bb0:	854e                	mv	a0,s3
ffffffffc0206bb2:	be8ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206bb6:	58fd                	li	a7,-1
ffffffffc0206bb8:	21150ce3          	beq	a0,a7,ffffffffc02075d0 <stride_dequeue+0x13d0>
          r = b->left;
ffffffffc0206bbc:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206bc0:	010cb803          	ld	a6,16(s9)
          r = b->left;
ffffffffc0206bc4:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206bc6:	00081463          	bnez	a6,ffffffffc0206bce <stride_dequeue+0x9ce>
ffffffffc0206bca:	3dc0106f          	j	ffffffffc0207fa6 <stride_dequeue+0x1da6>
     if (comp(a, b) == -1)
ffffffffc0206bce:	85c2                	mv	a1,a6
ffffffffc0206bd0:	854e                	mv	a0,s3
ffffffffc0206bd2:	f042                	sd	a6,32(sp)
ffffffffc0206bd4:	bc6ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206bd8:	58fd                	li	a7,-1
ffffffffc0206bda:	7802                	ld	a6,32(sp)
ffffffffc0206bdc:	01151463          	bne	a0,a7,ffffffffc0206be4 <stride_dequeue+0x9e4>
ffffffffc0206be0:	7b90006f          	j	ffffffffc0207b98 <stride_dequeue+0x1998>
          r = b->left;
ffffffffc0206be4:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206be8:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206bec:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206bee:	04030663          	beqz	t1,ffffffffc0206c3a <stride_dequeue+0xa3a>
     if (comp(a, b) == -1)
ffffffffc0206bf2:	859a                	mv	a1,t1
ffffffffc0206bf4:	854e                	mv	a0,s3
ffffffffc0206bf6:	f842                	sd	a6,48(sp)
ffffffffc0206bf8:	f41a                	sd	t1,40(sp)
ffffffffc0206bfa:	ba0ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206bfe:	58fd                	li	a7,-1
ffffffffc0206c00:	7322                	ld	t1,40(sp)
ffffffffc0206c02:	7842                	ld	a6,48(sp)
ffffffffc0206c04:	01151463          	bne	a0,a7,ffffffffc0206c0c <stride_dequeue+0xa0c>
ffffffffc0206c08:	5cc0106f          	j	ffffffffc02081d4 <stride_dequeue+0x1fd4>
          r = b->left;
ffffffffc0206c0c:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206c10:	01033583          	ld	a1,16(t1)
ffffffffc0206c14:	854e                	mv	a0,s3
ffffffffc0206c16:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206c18:	f81a                	sd	t1,48(sp)
ffffffffc0206c1a:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206c1c:	be4ff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206c20:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206c22:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206c24:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206c26:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206c2a:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206c2e:	e119                	bnez	a0,ffffffffc0206c34 <stride_dequeue+0xa34>
ffffffffc0206c30:	7ee0106f          	j	ffffffffc020841e <stride_dequeue+0x221e>
ffffffffc0206c34:	00653023          	sd	t1,0(a0)
ffffffffc0206c38:	899a                	mv	s3,t1
          b->right = r;
ffffffffc0206c3a:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206c3c:	01383423          	sd	s3,8(a6)
          b->right = r;
ffffffffc0206c40:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206c44:	0109b023          	sd	a6,0(s3)
          b->right = r;
ffffffffc0206c48:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206c4a:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc0206c4e:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0206c52:	01983023          	sd	s9,0(a6)
          a->right = r;
ffffffffc0206c56:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0206c58:	019a3423          	sd	s9,8(s4)
          a->right = r;
ffffffffc0206c5c:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc0206c60:	014cb023          	sd	s4,0(s9)
ffffffffc0206c64:	867ff06f          	j	ffffffffc02064ca <stride_dequeue+0x2ca>
          r = a->left;
ffffffffc0206c68:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206c6c:	010a3c83          	ld	s9,16(s4)
          r = a->left;
ffffffffc0206c70:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206c72:	0a0c8663          	beqz	s9,ffffffffc0206d1e <stride_dequeue+0xb1e>
     if (comp(a, b) == -1)
ffffffffc0206c76:	85ea                	mv	a1,s10
ffffffffc0206c78:	8566                	mv	a0,s9
ffffffffc0206c7a:	b20ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206c7e:	58fd                	li	a7,-1
ffffffffc0206c80:	0b1509e3          	beq	a0,a7,ffffffffc0207532 <stride_dequeue+0x1332>
          r = b->left;
ffffffffc0206c84:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206c88:	010d3803          	ld	a6,16(s10)
          r = b->left;
ffffffffc0206c8c:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206c8e:	00081463          	bnez	a6,ffffffffc0206c96 <stride_dequeue+0xa96>
ffffffffc0206c92:	31a0106f          	j	ffffffffc0207fac <stride_dequeue+0x1dac>
     if (comp(a, b) == -1)
ffffffffc0206c96:	85c2                	mv	a1,a6
ffffffffc0206c98:	8566                	mv	a0,s9
ffffffffc0206c9a:	f042                	sd	a6,32(sp)
ffffffffc0206c9c:	afeff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206ca0:	58fd                	li	a7,-1
ffffffffc0206ca2:	7802                	ld	a6,32(sp)
ffffffffc0206ca4:	01151463          	bne	a0,a7,ffffffffc0206cac <stride_dequeue+0xaac>
ffffffffc0206ca8:	7ad0006f          	j	ffffffffc0207c54 <stride_dequeue+0x1a54>
          r = b->left;
ffffffffc0206cac:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206cb0:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206cb4:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206cb6:	04030663          	beqz	t1,ffffffffc0206d02 <stride_dequeue+0xb02>
     if (comp(a, b) == -1)
ffffffffc0206cba:	859a                	mv	a1,t1
ffffffffc0206cbc:	8566                	mv	a0,s9
ffffffffc0206cbe:	f842                	sd	a6,48(sp)
ffffffffc0206cc0:	f41a                	sd	t1,40(sp)
ffffffffc0206cc2:	ad8ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206cc6:	58fd                	li	a7,-1
ffffffffc0206cc8:	7322                	ld	t1,40(sp)
ffffffffc0206cca:	7842                	ld	a6,48(sp)
ffffffffc0206ccc:	01151463          	bne	a0,a7,ffffffffc0206cd4 <stride_dequeue+0xad4>
ffffffffc0206cd0:	4360106f          	j	ffffffffc0208106 <stride_dequeue+0x1f06>
          r = b->left;
ffffffffc0206cd4:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206cd8:	01033583          	ld	a1,16(t1)
ffffffffc0206cdc:	8566                	mv	a0,s9
ffffffffc0206cde:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206ce0:	f81a                	sd	t1,48(sp)
ffffffffc0206ce2:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206ce4:	b1cff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206ce8:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206cea:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206cec:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206cee:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206cf2:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206cf6:	e119                	bnez	a0,ffffffffc0206cfc <stride_dequeue+0xafc>
ffffffffc0206cf8:	7ea0106f          	j	ffffffffc02084e2 <stride_dequeue+0x22e2>
ffffffffc0206cfc:	00653023          	sd	t1,0(a0)
ffffffffc0206d00:	8c9a                	mv	s9,t1
          b->right = r;
ffffffffc0206d02:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206d04:	01983423          	sd	s9,8(a6)
          b->right = r;
ffffffffc0206d08:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206d0c:	010cb023          	sd	a6,0(s9)
          b->right = r;
ffffffffc0206d10:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206d12:	010d3423          	sd	a6,8(s10)
          b->right = r;
ffffffffc0206d16:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206d1a:	01a83023          	sd	s10,0(a6)
          a->right = r;
ffffffffc0206d1e:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0206d20:	01aa3423          	sd	s10,8(s4)
          a->right = r;
ffffffffc0206d24:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc0206d28:	014d3023          	sd	s4,0(s10)
ffffffffc0206d2c:	8d52                	mv	s10,s4
ffffffffc0206d2e:	bba5                	j	ffffffffc0206aa6 <stride_dequeue+0x8a6>
          r = a->left;
ffffffffc0206d30:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206d34:	010c3c83          	ld	s9,16(s8)
          r = a->left;
ffffffffc0206d38:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206d3a:	0a0c8463          	beqz	s9,ffffffffc0206de2 <stride_dequeue+0xbe2>
     if (comp(a, b) == -1)
ffffffffc0206d3e:	85ea                	mv	a1,s10
ffffffffc0206d40:	8566                	mv	a0,s9
ffffffffc0206d42:	a58ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206d46:	58fd                	li	a7,-1
ffffffffc0206d48:	6b150763          	beq	a0,a7,ffffffffc02073f6 <stride_dequeue+0x11f6>
          r = b->left;
ffffffffc0206d4c:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206d50:	010d3803          	ld	a6,16(s10)
          r = b->left;
ffffffffc0206d54:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206d56:	00081463          	bnez	a6,ffffffffc0206d5e <stride_dequeue+0xb5e>
ffffffffc0206d5a:	2580106f          	j	ffffffffc0207fb2 <stride_dequeue+0x1db2>
     if (comp(a, b) == -1)
ffffffffc0206d5e:	85c2                	mv	a1,a6
ffffffffc0206d60:	8566                	mv	a0,s9
ffffffffc0206d62:	f042                	sd	a6,32(sp)
ffffffffc0206d64:	a36ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206d68:	58fd                	li	a7,-1
ffffffffc0206d6a:	7802                	ld	a6,32(sp)
ffffffffc0206d6c:	571508e3          	beq	a0,a7,ffffffffc0207adc <stride_dequeue+0x18dc>
          r = b->left;
ffffffffc0206d70:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206d74:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206d78:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206d7a:	04030663          	beqz	t1,ffffffffc0206dc6 <stride_dequeue+0xbc6>
     if (comp(a, b) == -1)
ffffffffc0206d7e:	859a                	mv	a1,t1
ffffffffc0206d80:	8566                	mv	a0,s9
ffffffffc0206d82:	f842                	sd	a6,48(sp)
ffffffffc0206d84:	f41a                	sd	t1,40(sp)
ffffffffc0206d86:	a14ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206d8a:	58fd                	li	a7,-1
ffffffffc0206d8c:	7322                	ld	t1,40(sp)
ffffffffc0206d8e:	7842                	ld	a6,48(sp)
ffffffffc0206d90:	01151463          	bne	a0,a7,ffffffffc0206d98 <stride_dequeue+0xb98>
ffffffffc0206d94:	3ee0106f          	j	ffffffffc0208182 <stride_dequeue+0x1f82>
          r = b->left;
ffffffffc0206d98:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206d9c:	01033583          	ld	a1,16(t1)
ffffffffc0206da0:	8566                	mv	a0,s9
ffffffffc0206da2:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206da4:	f81a                	sd	t1,48(sp)
ffffffffc0206da6:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206da8:	a58ff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206dac:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206dae:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206db0:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206db2:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206db6:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206dba:	e119                	bnez	a0,ffffffffc0206dc0 <stride_dequeue+0xbc0>
ffffffffc0206dbc:	6ee0106f          	j	ffffffffc02084aa <stride_dequeue+0x22aa>
ffffffffc0206dc0:	00653023          	sd	t1,0(a0)
ffffffffc0206dc4:	8c9a                	mv	s9,t1
          b->right = r;
ffffffffc0206dc6:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206dc8:	01983423          	sd	s9,8(a6)
          b->right = r;
ffffffffc0206dcc:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206dd0:	010cb023          	sd	a6,0(s9)
          b->right = r;
ffffffffc0206dd4:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206dd6:	010d3423          	sd	a6,8(s10)
          b->right = r;
ffffffffc0206dda:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206dde:	01a83023          	sd	s10,0(a6)
          a->right = r;
ffffffffc0206de2:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0206de4:	01ac3423          	sd	s10,8(s8)
          a->right = r;
ffffffffc0206de8:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc0206dec:	018d3023          	sd	s8,0(s10)
ffffffffc0206df0:	80bff06f          	j	ffffffffc02065fa <stride_dequeue+0x3fa>
          r = a->left;
ffffffffc0206df4:	649c                	ld	a5,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206df6:	0104b883          	ld	a7,16(s1)
ffffffffc0206dfa:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0206dfc:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc0206dfe:	06088963          	beqz	a7,ffffffffc0206e70 <stride_dequeue+0xc70>
     if (comp(a, b) == -1)
ffffffffc0206e02:	8546                	mv	a0,a7
ffffffffc0206e04:	85d2                	mv	a1,s4
ffffffffc0206e06:	f446                	sd	a7,40(sp)
ffffffffc0206e08:	992ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206e0c:	7802                	ld	a6,32(sp)
ffffffffc0206e0e:	78a2                	ld	a7,40(sp)
ffffffffc0206e10:	190505e3          	beq	a0,a6,ffffffffc020779a <stride_dequeue+0x159a>
          r = b->left;
ffffffffc0206e14:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206e18:	010a3303          	ld	t1,16(s4)
ffffffffc0206e1c:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc0206e1e:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206e20:	4a030be3          	beqz	t1,ffffffffc0207ad6 <stride_dequeue+0x18d6>
     if (comp(a, b) == -1)
ffffffffc0206e24:	859a                	mv	a1,t1
ffffffffc0206e26:	8546                	mv	a0,a7
ffffffffc0206e28:	fc1a                	sd	t1,56(sp)
ffffffffc0206e2a:	f846                	sd	a7,48(sp)
ffffffffc0206e2c:	96eff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206e30:	7822                	ld	a6,40(sp)
ffffffffc0206e32:	78c2                	ld	a7,48(sp)
ffffffffc0206e34:	7362                	ld	t1,56(sp)
ffffffffc0206e36:	01051463          	bne	a0,a6,ffffffffc0206e3e <stride_dequeue+0xc3e>
ffffffffc0206e3a:	10c0106f          	j	ffffffffc0207f46 <stride_dequeue+0x1d46>
          r = b->left;
ffffffffc0206e3e:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206e42:	01033583          	ld	a1,16(t1)
ffffffffc0206e46:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0206e48:	f81a                	sd	t1,48(sp)
ffffffffc0206e4a:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206e4c:	9b4ff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206e50:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206e52:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc0206e54:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206e58:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc0206e5c:	c119                	beqz	a0,ffffffffc0206e62 <stride_dequeue+0xc62>
ffffffffc0206e5e:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc0206e62:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206e64:	006a3423          	sd	t1,8(s4)
          b->right = r;
ffffffffc0206e68:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = b;
ffffffffc0206e6c:	01433023          	sd	s4,0(t1)
          a->right = r;
ffffffffc0206e70:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0206e72:	0144b423          	sd	s4,8(s1)
          a->right = r;
ffffffffc0206e76:	e89c                	sd	a5,16(s1)
          if (l) l->parent = a;
ffffffffc0206e78:	009a3023          	sd	s1,0(s4)
ffffffffc0206e7c:	cc8ff06f          	j	ffffffffc0206344 <stride_dequeue+0x144>
          r = a->left;
ffffffffc0206e80:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206e84:	0109bc83          	ld	s9,16(s3)
          r = a->left;
ffffffffc0206e88:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206e8a:	0a0c8563          	beqz	s9,ffffffffc0206f34 <stride_dequeue+0xd34>
     if (comp(a, b) == -1)
ffffffffc0206e8e:	85ea                	mv	a1,s10
ffffffffc0206e90:	8566                	mv	a0,s9
ffffffffc0206e92:	908ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206e96:	537d                	li	t1,-1
ffffffffc0206e98:	2e6507e3          	beq	a0,t1,ffffffffc0207986 <stride_dequeue+0x1786>
          r = b->left;
ffffffffc0206e9c:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206ea0:	010d3803          	ld	a6,16(s10)
          r = b->left;
ffffffffc0206ea4:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206ea6:	08080063          	beqz	a6,ffffffffc0206f26 <stride_dequeue+0xd26>
     if (comp(a, b) == -1)
ffffffffc0206eaa:	85c2                	mv	a1,a6
ffffffffc0206eac:	8566                	mv	a0,s9
ffffffffc0206eae:	f042                	sd	a6,32(sp)
ffffffffc0206eb0:	8eaff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206eb4:	537d                	li	t1,-1
ffffffffc0206eb6:	7802                	ld	a6,32(sp)
ffffffffc0206eb8:	00651463          	bne	a0,t1,ffffffffc0206ec0 <stride_dequeue+0xcc0>
ffffffffc0206ebc:	29e0106f          	j	ffffffffc020815a <stride_dequeue+0x1f5a>
          r = b->left;
ffffffffc0206ec0:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206ec4:	01083883          	ld	a7,16(a6)
          r = b->left;
ffffffffc0206ec8:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206eca:	04088663          	beqz	a7,ffffffffc0206f16 <stride_dequeue+0xd16>
     if (comp(a, b) == -1)
ffffffffc0206ece:	85c6                	mv	a1,a7
ffffffffc0206ed0:	8566                	mv	a0,s9
ffffffffc0206ed2:	f842                	sd	a6,48(sp)
ffffffffc0206ed4:	f446                	sd	a7,40(sp)
ffffffffc0206ed6:	8c4ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206eda:	537d                	li	t1,-1
ffffffffc0206edc:	78a2                	ld	a7,40(sp)
ffffffffc0206ede:	7842                	ld	a6,48(sp)
ffffffffc0206ee0:	00651463          	bne	a0,t1,ffffffffc0206ee8 <stride_dequeue+0xce8>
ffffffffc0206ee4:	0270106f          	j	ffffffffc020870a <stride_dequeue+0x250a>
          r = b->left;
ffffffffc0206ee8:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206eec:	0108b583          	ld	a1,16(a7)
ffffffffc0206ef0:	8566                	mv	a0,s9
ffffffffc0206ef2:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206ef4:	f846                	sd	a7,48(sp)
ffffffffc0206ef6:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206ef8:	908ff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206efc:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0206efe:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc0206f00:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206f02:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0206f06:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0206f0a:	e119                	bnez	a0,ffffffffc0206f10 <stride_dequeue+0xd10>
ffffffffc0206f0c:	20d0106f          	j	ffffffffc0208918 <stride_dequeue+0x2718>
ffffffffc0206f10:	01153023          	sd	a7,0(a0)
ffffffffc0206f14:	8cc6                	mv	s9,a7
          b->right = r;
ffffffffc0206f16:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206f18:	01983423          	sd	s9,8(a6)
          b->right = r;
ffffffffc0206f1c:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206f20:	010cb023          	sd	a6,0(s9)
ffffffffc0206f24:	8cc2                	mv	s9,a6
          b->right = r;
ffffffffc0206f26:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206f28:	019d3423          	sd	s9,8(s10)
          b->right = r;
ffffffffc0206f2c:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206f30:	01acb023          	sd	s10,0(s9)
          a->right = r;
ffffffffc0206f34:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0206f36:	01a9b423          	sd	s10,8(s3)
          a->right = r;
ffffffffc0206f3a:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = a;
ffffffffc0206f3e:	013d3023          	sd	s3,0(s10)
ffffffffc0206f42:	8d4e                	mv	s10,s3
ffffffffc0206f44:	b0f9                	j	ffffffffc0206812 <stride_dequeue+0x612>
          r = a->left;
ffffffffc0206f46:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206f4a:	010cbd03          	ld	s10,16(s9)
          r = a->left;
ffffffffc0206f4e:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206f50:	0a0d0563          	beqz	s10,ffffffffc0206ffa <stride_dequeue+0xdfa>
     if (comp(a, b) == -1)
ffffffffc0206f54:	85ce                	mv	a1,s3
ffffffffc0206f56:	856a                	mv	a0,s10
ffffffffc0206f58:	842ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206f5c:	537d                	li	t1,-1
ffffffffc0206f5e:	2c6508e3          	beq	a0,t1,ffffffffc0207a2e <stride_dequeue+0x182e>
          r = b->left;
ffffffffc0206f62:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206f66:	0109b803          	ld	a6,16(s3)
          r = b->left;
ffffffffc0206f6a:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206f6c:	08080063          	beqz	a6,ffffffffc0206fec <stride_dequeue+0xdec>
     if (comp(a, b) == -1)
ffffffffc0206f70:	85c2                	mv	a1,a6
ffffffffc0206f72:	856a                	mv	a0,s10
ffffffffc0206f74:	f042                	sd	a6,32(sp)
ffffffffc0206f76:	824ff0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206f7a:	537d                	li	t1,-1
ffffffffc0206f7c:	7802                	ld	a6,32(sp)
ffffffffc0206f7e:	00651463          	bne	a0,t1,ffffffffc0206f86 <stride_dequeue+0xd86>
ffffffffc0206f82:	39c0106f          	j	ffffffffc020831e <stride_dequeue+0x211e>
          r = b->left;
ffffffffc0206f86:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206f8a:	01083883          	ld	a7,16(a6)
          r = b->left;
ffffffffc0206f8e:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206f90:	04088663          	beqz	a7,ffffffffc0206fdc <stride_dequeue+0xddc>
     if (comp(a, b) == -1)
ffffffffc0206f94:	85c6                	mv	a1,a7
ffffffffc0206f96:	856a                	mv	a0,s10
ffffffffc0206f98:	f842                	sd	a6,48(sp)
ffffffffc0206f9a:	f446                	sd	a7,40(sp)
ffffffffc0206f9c:	ffffe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0206fa0:	537d                	li	t1,-1
ffffffffc0206fa2:	78a2                	ld	a7,40(sp)
ffffffffc0206fa4:	7842                	ld	a6,48(sp)
ffffffffc0206fa6:	00651463          	bne	a0,t1,ffffffffc0206fae <stride_dequeue+0xdae>
ffffffffc0206faa:	6d60106f          	j	ffffffffc0208680 <stride_dequeue+0x2480>
          r = b->left;
ffffffffc0206fae:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206fb2:	0108b583          	ld	a1,16(a7)
ffffffffc0206fb6:	856a                	mv	a0,s10
ffffffffc0206fb8:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206fba:	f846                	sd	a7,48(sp)
ffffffffc0206fbc:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206fbe:	842ff0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206fc2:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0206fc4:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc0206fc6:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206fc8:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0206fcc:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0206fd0:	e119                	bnez	a0,ffffffffc0206fd6 <stride_dequeue+0xdd6>
ffffffffc0206fd2:	1170106f          	j	ffffffffc02088e8 <stride_dequeue+0x26e8>
ffffffffc0206fd6:	01153023          	sd	a7,0(a0)
ffffffffc0206fda:	8d46                	mv	s10,a7
          b->right = r;
ffffffffc0206fdc:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206fde:	01a83423          	sd	s10,8(a6)
          b->right = r;
ffffffffc0206fe2:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206fe6:	010d3023          	sd	a6,0(s10)
ffffffffc0206fea:	8d42                	mv	s10,a6
          b->right = r;
ffffffffc0206fec:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206fee:	01a9b423          	sd	s10,8(s3)
          b->right = r;
ffffffffc0206ff2:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = b;
ffffffffc0206ff6:	013d3023          	sd	s3,0(s10)
          a->right = r;
ffffffffc0206ffa:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0206ffc:	013cb423          	sd	s3,8(s9)
          a->right = r;
ffffffffc0207000:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207004:	0199b023          	sd	s9,0(s3)
ffffffffc0207008:	89e6                	mv	s3,s9
ffffffffc020700a:	b8dd                	j	ffffffffc0206900 <stride_dequeue+0x700>
          r = a->left;
ffffffffc020700c:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207010:	010c3c83          	ld	s9,16(s8)
          r = a->left;
ffffffffc0207014:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0207016:	0a0c8563          	beqz	s9,ffffffffc02070c0 <stride_dequeue+0xec0>
     if (comp(a, b) == -1)
ffffffffc020701a:	85ea                	mv	a1,s10
ffffffffc020701c:	8566                	mv	a0,s9
ffffffffc020701e:	f7dfe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207022:	537d                	li	t1,-1
ffffffffc0207024:	24650fe3          	beq	a0,t1,ffffffffc0207a82 <stride_dequeue+0x1882>
          r = b->left;
ffffffffc0207028:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020702c:	010d3803          	ld	a6,16(s10)
          r = b->left;
ffffffffc0207030:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0207032:	08080063          	beqz	a6,ffffffffc02070b2 <stride_dequeue+0xeb2>
     if (comp(a, b) == -1)
ffffffffc0207036:	85c2                	mv	a1,a6
ffffffffc0207038:	8566                	mv	a0,s9
ffffffffc020703a:	f042                	sd	a6,32(sp)
ffffffffc020703c:	f5ffe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207040:	537d                	li	t1,-1
ffffffffc0207042:	7802                	ld	a6,32(sp)
ffffffffc0207044:	00651463          	bne	a0,t1,ffffffffc020704c <stride_dequeue+0xe4c>
ffffffffc0207048:	2340106f          	j	ffffffffc020827c <stride_dequeue+0x207c>
          r = b->left;
ffffffffc020704c:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207050:	01083883          	ld	a7,16(a6)
          r = b->left;
ffffffffc0207054:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207056:	04088663          	beqz	a7,ffffffffc02070a2 <stride_dequeue+0xea2>
     if (comp(a, b) == -1)
ffffffffc020705a:	85c6                	mv	a1,a7
ffffffffc020705c:	8566                	mv	a0,s9
ffffffffc020705e:	f842                	sd	a6,48(sp)
ffffffffc0207060:	f446                	sd	a7,40(sp)
ffffffffc0207062:	f39fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207066:	537d                	li	t1,-1
ffffffffc0207068:	78a2                	ld	a7,40(sp)
ffffffffc020706a:	7842                	ld	a6,48(sp)
ffffffffc020706c:	00651463          	bne	a0,t1,ffffffffc0207074 <stride_dequeue+0xe74>
ffffffffc0207070:	5020106f          	j	ffffffffc0208572 <stride_dequeue+0x2372>
          r = b->left;
ffffffffc0207074:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207078:	0108b583          	ld	a1,16(a7)
ffffffffc020707c:	8566                	mv	a0,s9
ffffffffc020707e:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0207080:	f846                	sd	a7,48(sp)
ffffffffc0207082:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207084:	f7dfe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207088:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc020708a:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc020708c:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc020708e:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0207092:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0207096:	e119                	bnez	a0,ffffffffc020709c <stride_dequeue+0xe9c>
ffffffffc0207098:	02d0106f          	j	ffffffffc02088c4 <stride_dequeue+0x26c4>
ffffffffc020709c:	01153023          	sd	a7,0(a0)
ffffffffc02070a0:	8cc6                	mv	s9,a7
          b->right = r;
ffffffffc02070a2:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02070a4:	01983423          	sd	s9,8(a6)
          b->right = r;
ffffffffc02070a8:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc02070ac:	010cb023          	sd	a6,0(s9)
ffffffffc02070b0:	8cc2                	mv	s9,a6
          b->right = r;
ffffffffc02070b2:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02070b4:	019d3423          	sd	s9,8(s10)
          b->right = r;
ffffffffc02070b8:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc02070bc:	01acb023          	sd	s10,0(s9)
          a->right = r;
ffffffffc02070c0:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc02070c2:	01ac3423          	sd	s10,8(s8)
          a->right = r;
ffffffffc02070c6:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc02070ca:	018d3023          	sd	s8,0(s10)
ffffffffc02070ce:	e44ff06f          	j	ffffffffc0206712 <stride_dequeue+0x512>
          r = a->left;
ffffffffc02070d2:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02070d6:	010a3883          	ld	a7,16(s4)
ffffffffc02070da:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc02070dc:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc02070de:	06088c63          	beqz	a7,ffffffffc0207156 <stride_dequeue+0xf56>
     if (comp(a, b) == -1)
ffffffffc02070e2:	8546                	mv	a0,a7
ffffffffc02070e4:	85ce                	mv	a1,s3
ffffffffc02070e6:	f446                	sd	a7,40(sp)
ffffffffc02070e8:	eb3fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02070ec:	7802                	ld	a6,32(sp)
ffffffffc02070ee:	78a2                	ld	a7,40(sp)
ffffffffc02070f0:	4f0504e3          	beq	a0,a6,ffffffffc0207dd8 <stride_dequeue+0x1bd8>
          r = b->left;
ffffffffc02070f4:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02070f8:	0109b303          	ld	t1,16(s3)
ffffffffc02070fc:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc02070fe:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207100:	04030463          	beqz	t1,ffffffffc0207148 <stride_dequeue+0xf48>
     if (comp(a, b) == -1)
ffffffffc0207104:	859a                	mv	a1,t1
ffffffffc0207106:	8546                	mv	a0,a7
ffffffffc0207108:	fc1a                	sd	t1,56(sp)
ffffffffc020710a:	f846                	sd	a7,48(sp)
ffffffffc020710c:	e8ffe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207110:	7822                	ld	a6,40(sp)
ffffffffc0207112:	78c2                	ld	a7,48(sp)
ffffffffc0207114:	7362                	ld	t1,56(sp)
ffffffffc0207116:	01051463          	bne	a0,a6,ffffffffc020711e <stride_dequeue+0xf1e>
ffffffffc020711a:	22c0106f          	j	ffffffffc0208346 <stride_dequeue+0x2146>
          r = b->left;
ffffffffc020711e:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207122:	01033583          	ld	a1,16(t1)
ffffffffc0207126:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207128:	f81a                	sd	t1,48(sp)
ffffffffc020712a:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020712c:	ed5fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207130:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0207132:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc0207134:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0207138:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc020713c:	e119                	bnez	a0,ffffffffc0207142 <stride_dequeue+0xf42>
ffffffffc020713e:	2d40106f          	j	ffffffffc0208412 <stride_dequeue+0x2212>
ffffffffc0207142:	00653023          	sd	t1,0(a0)
ffffffffc0207146:	889a                	mv	a7,t1
          b->right = r;
ffffffffc0207148:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc020714a:	0119b423          	sd	a7,8(s3)
          b->right = r;
ffffffffc020714e:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = b;
ffffffffc0207152:	0138b023          	sd	s3,0(a7)
          a->right = r;
ffffffffc0207156:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207158:	013a3423          	sd	s3,8(s4)
          a->right = r;
ffffffffc020715c:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc0207160:	0149b023          	sd	s4,0(s3)
ffffffffc0207164:	b56ff06f          	j	ffffffffc02064ba <stride_dequeue+0x2ba>
          r = a->left;
ffffffffc0207168:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020716c:	010c3883          	ld	a7,16(s8)
ffffffffc0207170:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0207172:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc0207174:	06088c63          	beqz	a7,ffffffffc02071ec <stride_dequeue+0xfec>
     if (comp(a, b) == -1)
ffffffffc0207178:	8546                	mv	a0,a7
ffffffffc020717a:	85e6                	mv	a1,s9
ffffffffc020717c:	f446                	sd	a7,40(sp)
ffffffffc020717e:	e1dfe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207182:	7802                	ld	a6,32(sp)
ffffffffc0207184:	78a2                	ld	a7,40(sp)
ffffffffc0207186:	4b050ee3          	beq	a0,a6,ffffffffc0207e42 <stride_dequeue+0x1c42>
          r = b->left;
ffffffffc020718a:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020718e:	010cb303          	ld	t1,16(s9)
ffffffffc0207192:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc0207194:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207196:	04030463          	beqz	t1,ffffffffc02071de <stride_dequeue+0xfde>
     if (comp(a, b) == -1)
ffffffffc020719a:	859a                	mv	a1,t1
ffffffffc020719c:	8546                	mv	a0,a7
ffffffffc020719e:	fc1a                	sd	t1,56(sp)
ffffffffc02071a0:	f846                	sd	a7,48(sp)
ffffffffc02071a2:	df9fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02071a6:	7822                	ld	a6,40(sp)
ffffffffc02071a8:	78c2                	ld	a7,48(sp)
ffffffffc02071aa:	7362                	ld	t1,56(sp)
ffffffffc02071ac:	01051463          	bne	a0,a6,ffffffffc02071b4 <stride_dequeue+0xfb4>
ffffffffc02071b0:	1c00106f          	j	ffffffffc0208370 <stride_dequeue+0x2170>
          r = b->left;
ffffffffc02071b4:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02071b8:	01033583          	ld	a1,16(t1)
ffffffffc02071bc:	8546                	mv	a0,a7
          r = b->left;
ffffffffc02071be:	f81a                	sd	t1,48(sp)
ffffffffc02071c0:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02071c2:	e3ffe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02071c6:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02071c8:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc02071ca:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02071ce:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc02071d2:	e119                	bnez	a0,ffffffffc02071d8 <stride_dequeue+0xfd8>
ffffffffc02071d4:	2440106f          	j	ffffffffc0208418 <stride_dequeue+0x2218>
ffffffffc02071d8:	00653023          	sd	t1,0(a0)
ffffffffc02071dc:	889a                	mv	a7,t1
          b->right = r;
ffffffffc02071de:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02071e0:	011cb423          	sd	a7,8(s9)
          b->right = r;
ffffffffc02071e4:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc02071e8:	0198b023          	sd	s9,0(a7)
          a->right = r;
ffffffffc02071ec:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc02071ee:	019c3423          	sd	s9,8(s8)
          a->right = r;
ffffffffc02071f2:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc02071f6:	018cb023          	sd	s8,0(s9)
ffffffffc02071fa:	bf0ff06f          	j	ffffffffc02065ea <stride_dequeue+0x3ea>
          r = a->left;
ffffffffc02071fe:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207202:	010a3883          	ld	a7,16(s4)
ffffffffc0207206:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0207208:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc020720a:	06088a63          	beqz	a7,ffffffffc020727e <stride_dequeue+0x107e>
     if (comp(a, b) == -1)
ffffffffc020720e:	8546                	mv	a0,a7
ffffffffc0207210:	85e6                	mv	a1,s9
ffffffffc0207212:	f446                	sd	a7,40(sp)
ffffffffc0207214:	d87fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207218:	7802                	ld	a6,32(sp)
ffffffffc020721a:	78a2                	ld	a7,40(sp)
ffffffffc020721c:	1d050de3          	beq	a0,a6,ffffffffc0207bf6 <stride_dequeue+0x19f6>
          r = b->left;
ffffffffc0207220:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207224:	010cb303          	ld	t1,16(s9)
ffffffffc0207228:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc020722a:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc020722c:	04030263          	beqz	t1,ffffffffc0207270 <stride_dequeue+0x1070>
     if (comp(a, b) == -1)
ffffffffc0207230:	859a                	mv	a1,t1
ffffffffc0207232:	8546                	mv	a0,a7
ffffffffc0207234:	fc1a                	sd	t1,56(sp)
ffffffffc0207236:	f846                	sd	a7,48(sp)
ffffffffc0207238:	d63fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020723c:	7822                	ld	a6,40(sp)
ffffffffc020723e:	78c2                	ld	a7,48(sp)
ffffffffc0207240:	7362                	ld	t1,56(sp)
ffffffffc0207242:	5b0501e3          	beq	a0,a6,ffffffffc0207fe4 <stride_dequeue+0x1de4>
          r = b->left;
ffffffffc0207246:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020724a:	01033583          	ld	a1,16(t1)
ffffffffc020724e:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207250:	f81a                	sd	t1,48(sp)
ffffffffc0207252:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207254:	dadfe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207258:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc020725a:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc020725c:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0207260:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc0207264:	e119                	bnez	a0,ffffffffc020726a <stride_dequeue+0x106a>
ffffffffc0207266:	2760106f          	j	ffffffffc02084dc <stride_dequeue+0x22dc>
ffffffffc020726a:	00653023          	sd	t1,0(a0)
ffffffffc020726e:	889a                	mv	a7,t1
          b->right = r;
ffffffffc0207270:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207272:	011cb423          	sd	a7,8(s9)
          b->right = r;
ffffffffc0207276:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc020727a:	0198b023          	sd	s9,0(a7)
          a->right = r;
ffffffffc020727e:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207280:	019a3423          	sd	s9,8(s4)
          a->right = r;
ffffffffc0207284:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc0207288:	014cb023          	sd	s4,0(s9)
ffffffffc020728c:	80dff06f          	j	ffffffffc0206a98 <stride_dequeue+0x898>
          r = a->left;
ffffffffc0207290:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207294:	010a3883          	ld	a7,16(s4)
ffffffffc0207298:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc020729a:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc020729c:	06088c63          	beqz	a7,ffffffffc0207314 <stride_dequeue+0x1114>
     if (comp(a, b) == -1)
ffffffffc02072a0:	8546                	mv	a0,a7
ffffffffc02072a2:	85e6                	mv	a1,s9
ffffffffc02072a4:	f446                	sd	a7,40(sp)
ffffffffc02072a6:	cf5fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02072aa:	7802                	ld	a6,32(sp)
ffffffffc02072ac:	78a2                	ld	a7,40(sp)
ffffffffc02072ae:	090506e3          	beq	a0,a6,ffffffffc0207b3a <stride_dequeue+0x193a>
          r = b->left;
ffffffffc02072b2:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02072b6:	010cb303          	ld	t1,16(s9)
ffffffffc02072ba:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc02072bc:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02072be:	04030463          	beqz	t1,ffffffffc0207306 <stride_dequeue+0x1106>
     if (comp(a, b) == -1)
ffffffffc02072c2:	859a                	mv	a1,t1
ffffffffc02072c4:	8546                	mv	a0,a7
ffffffffc02072c6:	fc1a                	sd	t1,56(sp)
ffffffffc02072c8:	f846                	sd	a7,48(sp)
ffffffffc02072ca:	cd1fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02072ce:	7822                	ld	a6,40(sp)
ffffffffc02072d0:	78c2                	ld	a7,48(sp)
ffffffffc02072d2:	7362                	ld	t1,56(sp)
ffffffffc02072d4:	01051463          	bne	a0,a6,ffffffffc02072dc <stride_dequeue+0x10dc>
ffffffffc02072d8:	0ec0106f          	j	ffffffffc02083c4 <stride_dequeue+0x21c4>
          r = b->left;
ffffffffc02072dc:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02072e0:	01033583          	ld	a1,16(t1)
ffffffffc02072e4:	8546                	mv	a0,a7
          r = b->left;
ffffffffc02072e6:	f81a                	sd	t1,48(sp)
ffffffffc02072e8:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02072ea:	d17fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02072ee:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02072f0:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc02072f2:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02072f6:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc02072fa:	e119                	bnez	a0,ffffffffc0207300 <stride_dequeue+0x1100>
ffffffffc02072fc:	12e0106f          	j	ffffffffc020842a <stride_dequeue+0x222a>
ffffffffc0207300:	00653023          	sd	t1,0(a0)
ffffffffc0207304:	889a                	mv	a7,t1
          b->right = r;
ffffffffc0207306:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207308:	011cb423          	sd	a7,8(s9)
          b->right = r;
ffffffffc020730c:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0207310:	0198b023          	sd	s9,0(a7)
          a->right = r;
ffffffffc0207314:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207316:	019a3423          	sd	s9,8(s4)
          a->right = r;
ffffffffc020731a:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc020731e:	014cb023          	sd	s4,0(s9)
ffffffffc0207322:	8cd2                	mv	s9,s4
ffffffffc0207324:	e9aff06f          	j	ffffffffc02069be <stride_dequeue+0x7be>
          r = a->left;
ffffffffc0207328:	6498                	ld	a4,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020732a:	0104b883          	ld	a7,16(s1)
ffffffffc020732e:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207330:	f03a                	sd	a4,32(sp)
     if (a == NULL) return b;
ffffffffc0207332:	02088c63          	beqz	a7,ffffffffc020736a <stride_dequeue+0x116a>
     if (comp(a, b) == -1)
ffffffffc0207336:	85be                	mv	a1,a5
ffffffffc0207338:	8546                	mv	a0,a7
ffffffffc020733a:	fc3e                	sd	a5,56(sp)
ffffffffc020733c:	f846                	sd	a7,48(sp)
ffffffffc020733e:	c5dfe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207342:	7322                	ld	t1,40(sp)
ffffffffc0207344:	78c2                	ld	a7,48(sp)
ffffffffc0207346:	77e2                	ld	a5,56(sp)
ffffffffc0207348:	3c650ae3          	beq	a0,t1,ffffffffc0207f1c <stride_dequeue+0x1d1c>
          r = b->left;
ffffffffc020734c:	0087b303          	ld	t1,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207350:	6b8c                	ld	a1,16(a5)
ffffffffc0207352:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207354:	f83e                	sd	a5,48(sp)
ffffffffc0207356:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207358:	ca9fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc020735c:	77c2                	ld	a5,48(sp)
          b->right = r;
ffffffffc020735e:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207360:	e788                	sd	a0,8(a5)
          b->right = r;
ffffffffc0207362:	0067b823          	sd	t1,16(a5)
          if (l) l->parent = b;
ffffffffc0207366:	c111                	beqz	a0,ffffffffc020736a <stride_dequeue+0x116a>
ffffffffc0207368:	e11c                	sd	a5,0(a0)
          a->right = r;
ffffffffc020736a:	7702                	ld	a4,32(sp)
          a->left = l;
ffffffffc020736c:	e49c                	sd	a5,8(s1)
          a->right = r;
ffffffffc020736e:	e898                	sd	a4,16(s1)
          if (l) l->parent = a;
ffffffffc0207370:	e384                	sd	s1,0(a5)
ffffffffc0207372:	fc3fe06f          	j	ffffffffc0206334 <stride_dequeue+0x134>
          r = a->left;
ffffffffc0207376:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020737a:	010cbd03          	ld	s10,16(s9)
          r = a->left;
ffffffffc020737e:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0207380:	520d08e3          	beqz	s10,ffffffffc02080b0 <stride_dequeue+0x1eb0>
     if (comp(a, b) == -1)
ffffffffc0207384:	85a2                	mv	a1,s0
ffffffffc0207386:	856a                	mv	a0,s10
ffffffffc0207388:	c13fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020738c:	587d                	li	a6,-1
ffffffffc020738e:	430508e3          	beq	a0,a6,ffffffffc0207fbe <stride_dequeue+0x1dbe>
          r = b->left;
ffffffffc0207392:	641c                	ld	a5,8(s0)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207394:	6810                	ld	a2,16(s0)
          r = b->left;
ffffffffc0207396:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0207398:	ce15                	beqz	a2,ffffffffc02073d4 <stride_dequeue+0x11d4>
     if (comp(a, b) == -1)
ffffffffc020739a:	85b2                	mv	a1,a2
ffffffffc020739c:	856a                	mv	a0,s10
ffffffffc020739e:	f032                	sd	a2,32(sp)
ffffffffc02073a0:	bfbfe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02073a4:	587d                	li	a6,-1
ffffffffc02073a6:	7602                	ld	a2,32(sp)
ffffffffc02073a8:	01051463          	bne	a0,a6,ffffffffc02073b0 <stride_dequeue+0x11b0>
ffffffffc02073ac:	0b00106f          	j	ffffffffc020845c <stride_dequeue+0x225c>
          r = b->left;
ffffffffc02073b0:	00863803          	ld	a6,8(a2)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02073b4:	6a0c                	ld	a1,16(a2)
ffffffffc02073b6:	856a                	mv	a0,s10
          r = b->left;
ffffffffc02073b8:	f432                	sd	a2,40(sp)
ffffffffc02073ba:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02073bc:	c45fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02073c0:	7622                	ld	a2,40(sp)
          b->right = r;
ffffffffc02073c2:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc02073c4:	e608                	sd	a0,8(a2)
          b->right = r;
ffffffffc02073c6:	01063823          	sd	a6,16(a2)
          if (l) l->parent = b;
ffffffffc02073ca:	e119                	bnez	a0,ffffffffc02073d0 <stride_dequeue+0x11d0>
ffffffffc02073cc:	1a00106f          	j	ffffffffc020856c <stride_dequeue+0x236c>
ffffffffc02073d0:	e110                	sd	a2,0(a0)
ffffffffc02073d2:	8d32                	mv	s10,a2
          b->right = r;
ffffffffc02073d4:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02073d6:	01a43423          	sd	s10,8(s0)
          b->right = r;
ffffffffc02073da:	e81c                	sd	a5,16(s0)
          if (l) l->parent = b;
ffffffffc02073dc:	008d3023          	sd	s0,0(s10)
ffffffffc02073e0:	8d22                	mv	s10,s0
          a->right = r;
ffffffffc02073e2:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc02073e4:	01acb423          	sd	s10,8(s9)
          if (l) l->parent = a;
ffffffffc02073e8:	8466                	mv	s0,s9
          a->right = r;
ffffffffc02073ea:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02073ee:	019d3023          	sd	s9,0(s10)
ffffffffc02073f2:	f9cff06f          	j	ffffffffc0206b8e <stride_dequeue+0x98e>
          r = a->left;
ffffffffc02073f6:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02073fa:	010cb803          	ld	a6,16(s9)
ffffffffc02073fe:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0207400:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc0207402:	00081463          	bnez	a6,ffffffffc020740a <stride_dequeue+0x120a>
ffffffffc0207406:	7e90006f          	j	ffffffffc02083ee <stride_dequeue+0x21ee>
     if (comp(a, b) == -1)
ffffffffc020740a:	8542                	mv	a0,a6
ffffffffc020740c:	85ea                	mv	a1,s10
ffffffffc020740e:	f442                	sd	a6,40(sp)
ffffffffc0207410:	b8bfe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207414:	7302                	ld	t1,32(sp)
ffffffffc0207416:	7822                	ld	a6,40(sp)
ffffffffc0207418:	00651463          	bne	a0,t1,ffffffffc0207420 <stride_dequeue+0x1220>
ffffffffc020741c:	6db0006f          	j	ffffffffc02082f6 <stride_dequeue+0x20f6>
          r = b->left;
ffffffffc0207420:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207424:	010d3883          	ld	a7,16(s10)
ffffffffc0207428:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc020742a:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc020742c:	04088463          	beqz	a7,ffffffffc0207474 <stride_dequeue+0x1274>
     if (comp(a, b) == -1)
ffffffffc0207430:	85c6                	mv	a1,a7
ffffffffc0207432:	8542                	mv	a0,a6
ffffffffc0207434:	f846                	sd	a7,48(sp)
ffffffffc0207436:	f442                	sd	a6,40(sp)
ffffffffc0207438:	b63fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020743c:	7362                	ld	t1,56(sp)
ffffffffc020743e:	7822                	ld	a6,40(sp)
ffffffffc0207440:	78c2                	ld	a7,48(sp)
ffffffffc0207442:	00651463          	bne	a0,t1,ffffffffc020744a <stride_dequeue+0x124a>
ffffffffc0207446:	0ce0106f          	j	ffffffffc0208514 <stride_dequeue+0x2314>
          r = b->left;
ffffffffc020744a:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020744e:	0108b583          	ld	a1,16(a7)
ffffffffc0207452:	8542                	mv	a0,a6
          r = b->left;
ffffffffc0207454:	f846                	sd	a7,48(sp)
ffffffffc0207456:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207458:	ba9fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc020745c:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc020745e:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207460:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0207464:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0207468:	e119                	bnez	a0,ffffffffc020746e <stride_dequeue+0x126e>
ffffffffc020746a:	48a0106f          	j	ffffffffc02088f4 <stride_dequeue+0x26f4>
ffffffffc020746e:	01153023          	sd	a7,0(a0)
ffffffffc0207472:	8846                	mv	a6,a7
          b->right = r;
ffffffffc0207474:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207476:	010d3423          	sd	a6,8(s10)
          b->right = r;
ffffffffc020747a:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc020747e:	01a83023          	sd	s10,0(a6)
ffffffffc0207482:	886a                	mv	a6,s10
          a->right = r;
ffffffffc0207484:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207486:	010cb423          	sd	a6,8(s9)
          if (l) l->parent = a;
ffffffffc020748a:	8d66                	mv	s10,s9
          a->right = r;
ffffffffc020748c:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207490:	01983023          	sd	s9,0(a6)
ffffffffc0207494:	b2b9                	j	ffffffffc0206de2 <stride_dequeue+0xbe2>
          r = a->left;
ffffffffc0207496:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020749a:	010c3803          	ld	a6,16(s8)
ffffffffc020749e:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc02074a0:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc02074a2:	00081463          	bnez	a6,ffffffffc02074aa <stride_dequeue+0x12aa>
ffffffffc02074a6:	75b0006f          	j	ffffffffc0208400 <stride_dequeue+0x2200>
     if (comp(a, b) == -1)
ffffffffc02074aa:	8542                	mv	a0,a6
ffffffffc02074ac:	85e6                	mv	a1,s9
ffffffffc02074ae:	f442                	sd	a6,40(sp)
ffffffffc02074b0:	aebfe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02074b4:	7302                	ld	t1,32(sp)
ffffffffc02074b6:	7822                	ld	a6,40(sp)
ffffffffc02074b8:	426503e3          	beq	a0,t1,ffffffffc02080de <stride_dequeue+0x1ede>
          r = b->left;
ffffffffc02074bc:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02074c0:	010cb883          	ld	a7,16(s9)
ffffffffc02074c4:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc02074c6:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02074c8:	04088463          	beqz	a7,ffffffffc0207510 <stride_dequeue+0x1310>
     if (comp(a, b) == -1)
ffffffffc02074cc:	85c6                	mv	a1,a7
ffffffffc02074ce:	8542                	mv	a0,a6
ffffffffc02074d0:	f846                	sd	a7,48(sp)
ffffffffc02074d2:	f442                	sd	a6,40(sp)
ffffffffc02074d4:	ac7fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02074d8:	7362                	ld	t1,56(sp)
ffffffffc02074da:	7822                	ld	a6,40(sp)
ffffffffc02074dc:	78c2                	ld	a7,48(sp)
ffffffffc02074de:	00651463          	bne	a0,t1,ffffffffc02074e6 <stride_dequeue+0x12e6>
ffffffffc02074e2:	0ea0106f          	j	ffffffffc02085cc <stride_dequeue+0x23cc>
          r = b->left;
ffffffffc02074e6:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02074ea:	0108b583          	ld	a1,16(a7)
ffffffffc02074ee:	8542                	mv	a0,a6
          r = b->left;
ffffffffc02074f0:	f846                	sd	a7,48(sp)
ffffffffc02074f2:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02074f4:	b0dfe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02074f8:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc02074fa:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc02074fc:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0207500:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0207504:	e119                	bnez	a0,ffffffffc020750a <stride_dequeue+0x130a>
ffffffffc0207506:	3ca0106f          	j	ffffffffc02088d0 <stride_dequeue+0x26d0>
ffffffffc020750a:	01153023          	sd	a7,0(a0)
ffffffffc020750e:	8846                	mv	a6,a7
          b->right = r;
ffffffffc0207510:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207512:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc0207516:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc020751a:	01983023          	sd	s9,0(a6)
ffffffffc020751e:	8866                	mv	a6,s9
          a->right = r;
ffffffffc0207520:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207522:	010c3423          	sd	a6,8(s8)
          a->right = r;
ffffffffc0207526:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc020752a:	01883023          	sd	s8,0(a6)
ffffffffc020752e:	9d4ff06f          	j	ffffffffc0206702 <stride_dequeue+0x502>
          r = a->left;
ffffffffc0207532:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207536:	010cb803          	ld	a6,16(s9)
ffffffffc020753a:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc020753c:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc020753e:	00081463          	bnez	a6,ffffffffc0207546 <stride_dequeue+0x1346>
ffffffffc0207542:	6b30006f          	j	ffffffffc02083f4 <stride_dequeue+0x21f4>
     if (comp(a, b) == -1)
ffffffffc0207546:	8542                	mv	a0,a6
ffffffffc0207548:	85ea                	mv	a1,s10
ffffffffc020754a:	f442                	sd	a6,40(sp)
ffffffffc020754c:	a4ffe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207550:	7302                	ld	t1,32(sp)
ffffffffc0207552:	7822                	ld	a6,40(sp)
ffffffffc0207554:	546508e3          	beq	a0,t1,ffffffffc02082a4 <stride_dequeue+0x20a4>
          r = b->left;
ffffffffc0207558:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020755c:	010d3883          	ld	a7,16(s10)
ffffffffc0207560:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc0207562:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207564:	04088463          	beqz	a7,ffffffffc02075ac <stride_dequeue+0x13ac>
     if (comp(a, b) == -1)
ffffffffc0207568:	85c6                	mv	a1,a7
ffffffffc020756a:	8542                	mv	a0,a6
ffffffffc020756c:	f846                	sd	a7,48(sp)
ffffffffc020756e:	f442                	sd	a6,40(sp)
ffffffffc0207570:	a2bfe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207574:	7362                	ld	t1,56(sp)
ffffffffc0207576:	7822                	ld	a6,40(sp)
ffffffffc0207578:	78c2                	ld	a7,48(sp)
ffffffffc020757a:	00651463          	bne	a0,t1,ffffffffc0207582 <stride_dequeue+0x1382>
ffffffffc020757e:	1e00106f          	j	ffffffffc020875e <stride_dequeue+0x255e>
          r = b->left;
ffffffffc0207582:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207586:	0108b583          	ld	a1,16(a7)
ffffffffc020758a:	8542                	mv	a0,a6
          r = b->left;
ffffffffc020758c:	f846                	sd	a7,48(sp)
ffffffffc020758e:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207590:	a71fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207594:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207596:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207598:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc020759c:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc02075a0:	e119                	bnez	a0,ffffffffc02075a6 <stride_dequeue+0x13a6>
ffffffffc02075a2:	3100106f          	j	ffffffffc02088b2 <stride_dequeue+0x26b2>
ffffffffc02075a6:	01153023          	sd	a7,0(a0)
ffffffffc02075aa:	8846                	mv	a6,a7
          b->right = r;
ffffffffc02075ac:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02075ae:	010d3423          	sd	a6,8(s10)
          b->right = r;
ffffffffc02075b2:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc02075b6:	01a83023          	sd	s10,0(a6)
ffffffffc02075ba:	886a                	mv	a6,s10
          a->right = r;
ffffffffc02075bc:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc02075be:	010cb423          	sd	a6,8(s9)
          if (l) l->parent = a;
ffffffffc02075c2:	8d66                	mv	s10,s9
          a->right = r;
ffffffffc02075c4:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02075c8:	01983023          	sd	s9,0(a6)
ffffffffc02075cc:	f52ff06f          	j	ffffffffc0206d1e <stride_dequeue+0xb1e>
          r = a->left;
ffffffffc02075d0:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02075d4:	0109b803          	ld	a6,16(s3)
ffffffffc02075d8:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc02075da:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc02075dc:	620808e3          	beqz	a6,ffffffffc020840c <stride_dequeue+0x220c>
     if (comp(a, b) == -1)
ffffffffc02075e0:	8542                	mv	a0,a6
ffffffffc02075e2:	85e6                	mv	a1,s9
ffffffffc02075e4:	f442                	sd	a6,40(sp)
ffffffffc02075e6:	9b5fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02075ea:	7302                	ld	t1,32(sp)
ffffffffc02075ec:	7822                	ld	a6,40(sp)
ffffffffc02075ee:	28650de3          	beq	a0,t1,ffffffffc0208088 <stride_dequeue+0x1e88>
          r = b->left;
ffffffffc02075f2:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02075f6:	010cb883          	ld	a7,16(s9)
ffffffffc02075fa:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc02075fc:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02075fe:	04088463          	beqz	a7,ffffffffc0207646 <stride_dequeue+0x1446>
     if (comp(a, b) == -1)
ffffffffc0207602:	85c6                	mv	a1,a7
ffffffffc0207604:	8542                	mv	a0,a6
ffffffffc0207606:	f846                	sd	a7,48(sp)
ffffffffc0207608:	f442                	sd	a6,40(sp)
ffffffffc020760a:	991fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020760e:	7362                	ld	t1,56(sp)
ffffffffc0207610:	7822                	ld	a6,40(sp)
ffffffffc0207612:	78c2                	ld	a7,48(sp)
ffffffffc0207614:	00651463          	bne	a0,t1,ffffffffc020761c <stride_dequeue+0x141c>
ffffffffc0207618:	1cc0106f          	j	ffffffffc02087e4 <stride_dequeue+0x25e4>
          r = b->left;
ffffffffc020761c:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207620:	0108b583          	ld	a1,16(a7)
ffffffffc0207624:	8542                	mv	a0,a6
          r = b->left;
ffffffffc0207626:	f846                	sd	a7,48(sp)
ffffffffc0207628:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020762a:	9d7fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc020762e:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207630:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207632:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0207636:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc020763a:	e119                	bnez	a0,ffffffffc0207640 <stride_dequeue+0x1440>
ffffffffc020763c:	2580106f          	j	ffffffffc0208894 <stride_dequeue+0x2694>
ffffffffc0207640:	01153023          	sd	a7,0(a0)
ffffffffc0207644:	8846                	mv	a6,a7
          b->right = r;
ffffffffc0207646:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207648:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc020764c:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0207650:	01983023          	sd	s9,0(a6)
ffffffffc0207654:	8866                	mv	a6,s9
          a->right = r;
ffffffffc0207656:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207658:	0109b423          	sd	a6,8(s3)
          if (l) l->parent = a;
ffffffffc020765c:	8cce                	mv	s9,s3
          a->right = r;
ffffffffc020765e:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = a;
ffffffffc0207662:	01383023          	sd	s3,0(a6)
ffffffffc0207666:	df0ff06f          	j	ffffffffc0206c56 <stride_dequeue+0xa56>
          r = a->left;
ffffffffc020766a:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020766e:	0109b803          	ld	a6,16(s3)
ffffffffc0207672:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0207674:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc0207676:	580808e3          	beqz	a6,ffffffffc0208406 <stride_dequeue+0x2206>
     if (comp(a, b) == -1)
ffffffffc020767a:	8542                	mv	a0,a6
ffffffffc020767c:	85e6                	mv	a1,s9
ffffffffc020767e:	f442                	sd	a6,40(sp)
ffffffffc0207680:	91bfe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207684:	7302                	ld	t1,32(sp)
ffffffffc0207686:	7822                	ld	a6,40(sp)
ffffffffc0207688:	226507e3          	beq	a0,t1,ffffffffc02080b6 <stride_dequeue+0x1eb6>
          r = b->left;
ffffffffc020768c:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207690:	010cb883          	ld	a7,16(s9)
ffffffffc0207694:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc0207696:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207698:	04088463          	beqz	a7,ffffffffc02076e0 <stride_dequeue+0x14e0>
     if (comp(a, b) == -1)
ffffffffc020769c:	85c6                	mv	a1,a7
ffffffffc020769e:	8542                	mv	a0,a6
ffffffffc02076a0:	f846                	sd	a7,48(sp)
ffffffffc02076a2:	f442                	sd	a6,40(sp)
ffffffffc02076a4:	8f7fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02076a8:	7362                	ld	t1,56(sp)
ffffffffc02076aa:	7822                	ld	a6,40(sp)
ffffffffc02076ac:	78c2                	ld	a7,48(sp)
ffffffffc02076ae:	00651463          	bne	a0,t1,ffffffffc02076b6 <stride_dequeue+0x14b6>
ffffffffc02076b2:	0d80106f          	j	ffffffffc020878a <stride_dequeue+0x258a>
          r = b->left;
ffffffffc02076b6:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02076ba:	0108b583          	ld	a1,16(a7)
ffffffffc02076be:	8542                	mv	a0,a6
          r = b->left;
ffffffffc02076c0:	f846                	sd	a7,48(sp)
ffffffffc02076c2:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02076c4:	93dfe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02076c8:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc02076ca:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc02076cc:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc02076d0:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc02076d4:	e119                	bnez	a0,ffffffffc02076da <stride_dequeue+0x14da>
ffffffffc02076d6:	2060106f          	j	ffffffffc02088dc <stride_dequeue+0x26dc>
ffffffffc02076da:	01153023          	sd	a7,0(a0)
ffffffffc02076de:	8846                	mv	a6,a7
          b->right = r;
ffffffffc02076e0:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02076e2:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc02076e6:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc02076ea:	01983023          	sd	s9,0(a6)
ffffffffc02076ee:	8866                	mv	a6,s9
          a->right = r;
ffffffffc02076f0:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc02076f2:	0109b423          	sd	a6,8(s3)
          a->right = r;
ffffffffc02076f6:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = a;
ffffffffc02076fa:	01383023          	sd	s3,0(a6)
ffffffffc02076fe:	906ff06f          	j	ffffffffc0206804 <stride_dequeue+0x604>
          r = a->left;
ffffffffc0207702:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207706:	010cbd03          	ld	s10,16(s9)
ffffffffc020770a:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc020770c:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc020770e:	4e0d06e3          	beqz	s10,ffffffffc02083fa <stride_dequeue+0x21fa>
     if (comp(a, b) == -1)
ffffffffc0207712:	85b2                	mv	a1,a2
ffffffffc0207714:	856a                	mv	a0,s10
ffffffffc0207716:	f432                	sd	a2,40(sp)
ffffffffc0207718:	883fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020771c:	7302                	ld	t1,32(sp)
ffffffffc020771e:	7622                	ld	a2,40(sp)
ffffffffc0207720:	10650ce3          	beq	a0,t1,ffffffffc0208038 <stride_dequeue+0x1e38>
          r = b->left;
ffffffffc0207724:	661c                	ld	a5,8(a2)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207726:	01063883          	ld	a7,16(a2)
ffffffffc020772a:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc020772c:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc020772e:	04088663          	beqz	a7,ffffffffc020777a <stride_dequeue+0x157a>
     if (comp(a, b) == -1)
ffffffffc0207732:	85c6                	mv	a1,a7
ffffffffc0207734:	856a                	mv	a0,s10
ffffffffc0207736:	f832                	sd	a2,48(sp)
ffffffffc0207738:	f446                	sd	a7,40(sp)
ffffffffc020773a:	861fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020773e:	7362                	ld	t1,56(sp)
ffffffffc0207740:	78a2                	ld	a7,40(sp)
ffffffffc0207742:	7642                	ld	a2,48(sp)
ffffffffc0207744:	00651463          	bne	a0,t1,ffffffffc020774c <stride_dequeue+0x154c>
ffffffffc0207748:	0c80106f          	j	ffffffffc0208810 <stride_dequeue+0x2610>
          r = b->left;
ffffffffc020774c:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207750:	0108b583          	ld	a1,16(a7)
ffffffffc0207754:	856a                	mv	a0,s10
ffffffffc0207756:	fc32                	sd	a2,56(sp)
          r = b->left;
ffffffffc0207758:	f846                	sd	a7,48(sp)
ffffffffc020775a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020775c:	8a5fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207760:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207762:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc0207764:	7662                	ld	a2,56(sp)
          b->left = l;
ffffffffc0207766:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc020776a:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc020776e:	e119                	bnez	a0,ffffffffc0207774 <stride_dequeue+0x1574>
ffffffffc0207770:	1c00106f          	j	ffffffffc0208930 <stride_dequeue+0x2730>
ffffffffc0207774:	01153023          	sd	a7,0(a0)
ffffffffc0207778:	8d46                	mv	s10,a7
          b->right = r;
ffffffffc020777a:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc020777c:	01a63423          	sd	s10,8(a2)
          b->right = r;
ffffffffc0207780:	ea1c                	sd	a5,16(a2)
          if (l) l->parent = b;
ffffffffc0207782:	00cd3023          	sd	a2,0(s10)
ffffffffc0207786:	8d32                	mv	s10,a2
          a->right = r;
ffffffffc0207788:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc020778a:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc020778e:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207792:	019d3023          	sd	s9,0(s10)
ffffffffc0207796:	95cff06f          	j	ffffffffc02068f2 <stride_dequeue+0x6f2>
          r = a->left;
ffffffffc020779a:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020779e:	0108b803          	ld	a6,16(a7)
ffffffffc02077a2:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc02077a4:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc02077a6:	02080f63          	beqz	a6,ffffffffc02077e4 <stride_dequeue+0x15e4>
     if (comp(a, b) == -1)
ffffffffc02077aa:	8542                	mv	a0,a6
ffffffffc02077ac:	85d2                	mv	a1,s4
ffffffffc02077ae:	fc46                	sd	a7,56(sp)
ffffffffc02077b0:	f842                	sd	a6,48(sp)
ffffffffc02077b2:	fe8fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02077b6:	7322                	ld	t1,40(sp)
ffffffffc02077b8:	7842                	ld	a6,48(sp)
ffffffffc02077ba:	78e2                	ld	a7,56(sp)
ffffffffc02077bc:	046508e3          	beq	a0,t1,ffffffffc020800c <stride_dequeue+0x1e0c>
          r = b->left;
ffffffffc02077c0:	008a3303          	ld	t1,8(s4)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02077c4:	010a3583          	ld	a1,16(s4)
ffffffffc02077c8:	8542                	mv	a0,a6
ffffffffc02077ca:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc02077cc:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02077ce:	833fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc02077d2:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc02077d4:	00aa3423          	sd	a0,8(s4)
          if (l) l->parent = b;
ffffffffc02077d8:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc02077da:	006a3823          	sd	t1,16(s4)
          if (l) l->parent = b;
ffffffffc02077de:	c119                	beqz	a0,ffffffffc02077e4 <stride_dequeue+0x15e4>
ffffffffc02077e0:	01453023          	sd	s4,0(a0)
          a->right = r;
ffffffffc02077e4:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02077e6:	0148b423          	sd	s4,8(a7)
          a->right = r;
ffffffffc02077ea:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc02077ee:	011a3023          	sd	a7,0(s4)
ffffffffc02077f2:	8a46                	mv	s4,a7
ffffffffc02077f4:	e7cff06f          	j	ffffffffc0206e70 <stride_dequeue+0xc70>
          r = a->left;
ffffffffc02077f8:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02077fc:	010a3883          	ld	a7,16(s4)
ffffffffc0207800:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207802:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207804:	02088f63          	beqz	a7,ffffffffc0207842 <stride_dequeue+0x1642>
     if (comp(a, b) == -1)
ffffffffc0207808:	85c2                	mv	a1,a6
ffffffffc020780a:	8546                	mv	a0,a7
ffffffffc020780c:	fc42                	sd	a6,56(sp)
ffffffffc020780e:	f846                	sd	a7,48(sp)
ffffffffc0207810:	f8afe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207814:	7322                	ld	t1,40(sp)
ffffffffc0207816:	78c2                	ld	a7,48(sp)
ffffffffc0207818:	7862                	ld	a6,56(sp)
ffffffffc020781a:	22650ce3          	beq	a0,t1,ffffffffc0208252 <stride_dequeue+0x2052>
          r = b->left;
ffffffffc020781e:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207822:	01083583          	ld	a1,16(a6)
ffffffffc0207826:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207828:	f842                	sd	a6,48(sp)
ffffffffc020782a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020782c:	fd4fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207830:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207832:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207834:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207838:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc020783c:	c119                	beqz	a0,ffffffffc0207842 <stride_dequeue+0x1642>
ffffffffc020783e:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207842:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207844:	010a3423          	sd	a6,8(s4)
          a->right = r;
ffffffffc0207848:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc020784c:	01483023          	sd	s4,0(a6)
ffffffffc0207850:	960ff06f          	j	ffffffffc02069b0 <stride_dequeue+0x7b0>
          r = a->left;
ffffffffc0207854:	008a3703          	ld	a4,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207858:	010a3883          	ld	a7,16(s4)
ffffffffc020785c:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc020785e:	f03a                	sd	a4,32(sp)
     if (a == NULL) return b;
ffffffffc0207860:	02088c63          	beqz	a7,ffffffffc0207898 <stride_dequeue+0x1698>
     if (comp(a, b) == -1)
ffffffffc0207864:	85be                	mv	a1,a5
ffffffffc0207866:	8546                	mv	a0,a7
ffffffffc0207868:	fc3e                	sd	a5,56(sp)
ffffffffc020786a:	f846                	sd	a7,48(sp)
ffffffffc020786c:	f2efe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207870:	7322                	ld	t1,40(sp)
ffffffffc0207872:	78c2                	ld	a7,48(sp)
ffffffffc0207874:	77e2                	ld	a5,56(sp)
ffffffffc0207876:	1a6509e3          	beq	a0,t1,ffffffffc0208228 <stride_dequeue+0x2028>
          r = b->left;
ffffffffc020787a:	0087b303          	ld	t1,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020787e:	6b8c                	ld	a1,16(a5)
ffffffffc0207880:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207882:	f83e                	sd	a5,48(sp)
ffffffffc0207884:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207886:	f7afe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc020788a:	77c2                	ld	a5,48(sp)
          b->right = r;
ffffffffc020788c:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc020788e:	e788                	sd	a0,8(a5)
          b->right = r;
ffffffffc0207890:	0067b823          	sd	t1,16(a5)
          if (l) l->parent = b;
ffffffffc0207894:	c111                	beqz	a0,ffffffffc0207898 <stride_dequeue+0x1698>
ffffffffc0207896:	e11c                	sd	a5,0(a0)
          a->right = r;
ffffffffc0207898:	7702                	ld	a4,32(sp)
          a->left = l;
ffffffffc020789a:	00fa3423          	sd	a5,8(s4)
          a->right = r;
ffffffffc020789e:	00ea3823          	sd	a4,16(s4)
          if (l) l->parent = a;
ffffffffc02078a2:	0147b023          	sd	s4,0(a5)
ffffffffc02078a6:	c05fe06f          	j	ffffffffc02064aa <stride_dequeue+0x2aa>
          r = a->left;
ffffffffc02078aa:	008c3703          	ld	a4,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02078ae:	010c3883          	ld	a7,16(s8)
ffffffffc02078b2:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc02078b4:	f03a                	sd	a4,32(sp)
     if (a == NULL) return b;
ffffffffc02078b6:	02088c63          	beqz	a7,ffffffffc02078ee <stride_dequeue+0x16ee>
     if (comp(a, b) == -1)
ffffffffc02078ba:	85be                	mv	a1,a5
ffffffffc02078bc:	8546                	mv	a0,a7
ffffffffc02078be:	fc3e                	sd	a5,56(sp)
ffffffffc02078c0:	f846                	sd	a7,48(sp)
ffffffffc02078c2:	ed8fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02078c6:	7322                	ld	t1,40(sp)
ffffffffc02078c8:	78c2                	ld	a7,48(sp)
ffffffffc02078ca:	77e2                	ld	a5,56(sp)
ffffffffc02078cc:	126509e3          	beq	a0,t1,ffffffffc02081fe <stride_dequeue+0x1ffe>
          r = b->left;
ffffffffc02078d0:	0087b303          	ld	t1,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02078d4:	6b8c                	ld	a1,16(a5)
ffffffffc02078d6:	8546                	mv	a0,a7
          r = b->left;
ffffffffc02078d8:	f83e                	sd	a5,48(sp)
ffffffffc02078da:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02078dc:	f24fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02078e0:	77c2                	ld	a5,48(sp)
          b->right = r;
ffffffffc02078e2:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc02078e4:	e788                	sd	a0,8(a5)
          b->right = r;
ffffffffc02078e6:	0067b823          	sd	t1,16(a5)
          if (l) l->parent = b;
ffffffffc02078ea:	c111                	beqz	a0,ffffffffc02078ee <stride_dequeue+0x16ee>
ffffffffc02078ec:	e11c                	sd	a5,0(a0)
          a->right = r;
ffffffffc02078ee:	7702                	ld	a4,32(sp)
          a->left = l;
ffffffffc02078f0:	00fc3423          	sd	a5,8(s8)
          a->right = r;
ffffffffc02078f4:	00ec3823          	sd	a4,16(s8)
          if (l) l->parent = a;
ffffffffc02078f8:	0187b023          	sd	s8,0(a5)
ffffffffc02078fc:	cdffe06f          	j	ffffffffc02065da <stride_dequeue+0x3da>
          r = a->left;
ffffffffc0207900:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207904:	010a3883          	ld	a7,16(s4)
ffffffffc0207908:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc020790a:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc020790c:	02088f63          	beqz	a7,ffffffffc020794a <stride_dequeue+0x174a>
     if (comp(a, b) == -1)
ffffffffc0207910:	85c2                	mv	a1,a6
ffffffffc0207912:	8546                	mv	a0,a7
ffffffffc0207914:	fc42                	sd	a6,56(sp)
ffffffffc0207916:	f846                	sd	a7,48(sp)
ffffffffc0207918:	e82fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020791c:	7322                	ld	t1,40(sp)
ffffffffc020791e:	78c2                	ld	a7,48(sp)
ffffffffc0207920:	7862                	ld	a6,56(sp)
ffffffffc0207922:	006507e3          	beq	a0,t1,ffffffffc0208130 <stride_dequeue+0x1f30>
          r = b->left;
ffffffffc0207926:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020792a:	01083583          	ld	a1,16(a6)
ffffffffc020792e:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207930:	f842                	sd	a6,48(sp)
ffffffffc0207932:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207934:	eccfe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207938:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc020793a:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc020793c:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207940:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207944:	c119                	beqz	a0,ffffffffc020794a <stride_dequeue+0x174a>
ffffffffc0207946:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc020794a:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc020794c:	010a3423          	sd	a6,8(s4)
          a->right = r;
ffffffffc0207950:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc0207954:	01483023          	sd	s4,0(a6)
ffffffffc0207958:	930ff06f          	j	ffffffffc0206a88 <stride_dequeue+0x888>
          r = a->left;
ffffffffc020795c:	0084b883          	ld	a7,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207960:	6888                	ld	a0,16(s1)
ffffffffc0207962:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207964:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207966:	e9afe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020796a:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc020796c:	e488                	sd	a0,8(s1)
          if (l) l->parent = a;
ffffffffc020796e:	8326                	mv	t1,s1
          a->right = r;
ffffffffc0207970:	0114b823          	sd	a7,16(s1)
          if (l) l->parent = a;
ffffffffc0207974:	77c2                	ld	a5,48(sp)
ffffffffc0207976:	c119                	beqz	a0,ffffffffc020797c <stride_dequeue+0x177c>
ffffffffc0207978:	9abfe06f          	j	ffffffffc0206322 <stride_dequeue+0x122>
ffffffffc020797c:	9abfe06f          	j	ffffffffc0206326 <stride_dequeue+0x126>
     else if (b == NULL) return a;
ffffffffc0207980:	8326                	mv	t1,s1
ffffffffc0207982:	9a5fe06f          	j	ffffffffc0206326 <stride_dequeue+0x126>
          r = a->left;
ffffffffc0207986:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020798a:	010cb783          	ld	a5,16(s9)
ffffffffc020798e:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207990:	ec3a                	sd	a4,24(sp)
     if (a == NULL) return b;
ffffffffc0207992:	cb95                	beqz	a5,ffffffffc02079c6 <stride_dequeue+0x17c6>
     if (comp(a, b) == -1)
ffffffffc0207994:	853e                	mv	a0,a5
ffffffffc0207996:	85ea                	mv	a1,s10
ffffffffc0207998:	f03e                	sd	a5,32(sp)
ffffffffc020799a:	e00fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc020799e:	7822                	ld	a6,40(sp)
ffffffffc02079a0:	7782                	ld	a5,32(sp)
ffffffffc02079a2:	310507e3          	beq	a0,a6,ffffffffc02084b0 <stride_dequeue+0x22b0>
          r = b->left;
ffffffffc02079a6:	008d3803          	ld	a6,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02079aa:	010d3583          	ld	a1,16(s10)
ffffffffc02079ae:	853e                	mv	a0,a5
          r = b->left;
ffffffffc02079b0:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02079b2:	e4efe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc02079b6:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc02079b8:	00ad3423          	sd	a0,8(s10)
          b->right = r;
ffffffffc02079bc:	010d3823          	sd	a6,16(s10)
          if (l) l->parent = b;
ffffffffc02079c0:	c119                	beqz	a0,ffffffffc02079c6 <stride_dequeue+0x17c6>
ffffffffc02079c2:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc02079c6:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc02079c8:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc02079cc:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02079d0:	019d3023          	sd	s9,0(s10)
ffffffffc02079d4:	8d66                	mv	s10,s9
ffffffffc02079d6:	d5eff06f          	j	ffffffffc0206f34 <stride_dequeue+0xd34>
          r = a->left;
ffffffffc02079da:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02079de:	010cb783          	ld	a5,16(s9)
ffffffffc02079e2:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc02079e4:	ec3a                	sd	a4,24(sp)
     if (a == NULL) return b;
ffffffffc02079e6:	cb95                	beqz	a5,ffffffffc0207a1a <stride_dequeue+0x181a>
     if (comp(a, b) == -1)
ffffffffc02079e8:	853e                	mv	a0,a5
ffffffffc02079ea:	85ea                	mv	a1,s10
ffffffffc02079ec:	f03e                	sd	a5,32(sp)
ffffffffc02079ee:	dacfe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc02079f2:	7822                	ld	a6,40(sp)
ffffffffc02079f4:	7782                	ld	a5,32(sp)
ffffffffc02079f6:	23050de3          	beq	a0,a6,ffffffffc0208430 <stride_dequeue+0x2230>
          r = b->left;
ffffffffc02079fa:	008d3803          	ld	a6,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02079fe:	010d3583          	ld	a1,16(s10)
ffffffffc0207a02:	853e                	mv	a0,a5
          r = b->left;
ffffffffc0207a04:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207a06:	dfafe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207a0a:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc0207a0c:	00ad3423          	sd	a0,8(s10)
          b->right = r;
ffffffffc0207a10:	010d3823          	sd	a6,16(s10)
          if (l) l->parent = b;
ffffffffc0207a14:	c119                	beqz	a0,ffffffffc0207a1a <stride_dequeue+0x181a>
ffffffffc0207a16:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc0207a1a:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207a1c:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc0207a20:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207a24:	019d3023          	sd	s9,0(s10)
ffffffffc0207a28:	8d66                	mv	s10,s9
ffffffffc0207a2a:	958ff06f          	j	ffffffffc0206b82 <stride_dequeue+0x982>
          r = a->left;
ffffffffc0207a2e:	008d3703          	ld	a4,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207a32:	010d3783          	ld	a5,16(s10)
ffffffffc0207a36:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207a38:	ec3a                	sd	a4,24(sp)
     if (a == NULL) return b;
ffffffffc0207a3a:	cb95                	beqz	a5,ffffffffc0207a6e <stride_dequeue+0x186e>
     if (comp(a, b) == -1)
ffffffffc0207a3c:	853e                	mv	a0,a5
ffffffffc0207a3e:	85ce                	mv	a1,s3
ffffffffc0207a40:	f03e                	sd	a5,32(sp)
ffffffffc0207a42:	d58fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207a46:	7822                	ld	a6,40(sp)
ffffffffc0207a48:	7782                	ld	a5,32(sp)
ffffffffc0207a4a:	23050de3          	beq	a0,a6,ffffffffc0208484 <stride_dequeue+0x2284>
          r = b->left;
ffffffffc0207a4e:	0089b803          	ld	a6,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207a52:	0109b583          	ld	a1,16(s3)
ffffffffc0207a56:	853e                	mv	a0,a5
          r = b->left;
ffffffffc0207a58:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207a5a:	da6fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207a5e:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc0207a60:	00a9b423          	sd	a0,8(s3)
          b->right = r;
ffffffffc0207a64:	0109b823          	sd	a6,16(s3)
          if (l) l->parent = b;
ffffffffc0207a68:	c119                	beqz	a0,ffffffffc0207a6e <stride_dequeue+0x186e>
ffffffffc0207a6a:	01353023          	sd	s3,0(a0)
          a->right = r;
ffffffffc0207a6e:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207a70:	013d3423          	sd	s3,8(s10)
          a->right = r;
ffffffffc0207a74:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc0207a78:	01a9b023          	sd	s10,0(s3)
ffffffffc0207a7c:	89ea                	mv	s3,s10
ffffffffc0207a7e:	d7cff06f          	j	ffffffffc0206ffa <stride_dequeue+0xdfa>
          r = a->left;
ffffffffc0207a82:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207a86:	010cb783          	ld	a5,16(s9)
ffffffffc0207a8a:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207a8c:	ec3a                	sd	a4,24(sp)
     if (a == NULL) return b;
ffffffffc0207a8e:	cb95                	beqz	a5,ffffffffc0207ac2 <stride_dequeue+0x18c2>
     if (comp(a, b) == -1)
ffffffffc0207a90:	853e                	mv	a0,a5
ffffffffc0207a92:	85ea                	mv	a1,s10
ffffffffc0207a94:	f03e                	sd	a5,32(sp)
ffffffffc0207a96:	d04fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207a9a:	7822                	ld	a6,40(sp)
ffffffffc0207a9c:	7782                	ld	a5,32(sp)
ffffffffc0207a9e:	250505e3          	beq	a0,a6,ffffffffc02084e8 <stride_dequeue+0x22e8>
          r = b->left;
ffffffffc0207aa2:	008d3803          	ld	a6,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207aa6:	010d3583          	ld	a1,16(s10)
ffffffffc0207aaa:	853e                	mv	a0,a5
          r = b->left;
ffffffffc0207aac:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207aae:	d52fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207ab2:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc0207ab4:	00ad3423          	sd	a0,8(s10)
          b->right = r;
ffffffffc0207ab8:	010d3823          	sd	a6,16(s10)
          if (l) l->parent = b;
ffffffffc0207abc:	c119                	beqz	a0,ffffffffc0207ac2 <stride_dequeue+0x18c2>
ffffffffc0207abe:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc0207ac2:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207ac4:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc0207ac8:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207acc:	019d3023          	sd	s9,0(s10)
ffffffffc0207ad0:	8d66                	mv	s10,s9
ffffffffc0207ad2:	deeff06f          	j	ffffffffc02070c0 <stride_dequeue+0xec0>
ffffffffc0207ad6:	8346                	mv	t1,a7
ffffffffc0207ad8:	b8aff06f          	j	ffffffffc0206e62 <stride_dequeue+0xc62>
          r = a->left;
ffffffffc0207adc:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207ae0:	010cb883          	ld	a7,16(s9)
ffffffffc0207ae4:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207ae6:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207ae8:	02088f63          	beqz	a7,ffffffffc0207b26 <stride_dequeue+0x1926>
     if (comp(a, b) == -1)
ffffffffc0207aec:	85c2                	mv	a1,a6
ffffffffc0207aee:	8546                	mv	a0,a7
ffffffffc0207af0:	f842                	sd	a6,48(sp)
ffffffffc0207af2:	f446                	sd	a7,40(sp)
ffffffffc0207af4:	ca6fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207af8:	7362                	ld	t1,56(sp)
ffffffffc0207afa:	78a2                	ld	a7,40(sp)
ffffffffc0207afc:	7842                	ld	a6,48(sp)
ffffffffc0207afe:	326505e3          	beq	a0,t1,ffffffffc0208628 <stride_dequeue+0x2428>
          r = b->left;
ffffffffc0207b02:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207b06:	01083583          	ld	a1,16(a6)
ffffffffc0207b0a:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207b0c:	f842                	sd	a6,48(sp)
ffffffffc0207b0e:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207b10:	cf0fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207b14:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207b16:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207b18:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207b1c:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207b20:	c119                	beqz	a0,ffffffffc0207b26 <stride_dequeue+0x1926>
ffffffffc0207b22:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207b26:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207b28:	010cb423          	sd	a6,8(s9)
          a->right = r;
ffffffffc0207b2c:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207b30:	01983023          	sd	s9,0(a6)
ffffffffc0207b34:	8866                	mv	a6,s9
ffffffffc0207b36:	a9eff06f          	j	ffffffffc0206dd4 <stride_dequeue+0xbd4>
          r = a->left;
ffffffffc0207b3a:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207b3e:	0108b803          	ld	a6,16(a7)
ffffffffc0207b42:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207b44:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207b46:	02080f63          	beqz	a6,ffffffffc0207b84 <stride_dequeue+0x1984>
     if (comp(a, b) == -1)
ffffffffc0207b4a:	8542                	mv	a0,a6
ffffffffc0207b4c:	85e6                	mv	a1,s9
ffffffffc0207b4e:	f846                	sd	a7,48(sp)
ffffffffc0207b50:	f442                	sd	a6,40(sp)
ffffffffc0207b52:	c48fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207b56:	7362                	ld	t1,56(sp)
ffffffffc0207b58:	7822                	ld	a6,40(sp)
ffffffffc0207b5a:	78c2                	ld	a7,48(sp)
ffffffffc0207b5c:	44650de3          	beq	a0,t1,ffffffffc02087b6 <stride_dequeue+0x25b6>
          r = b->left;
ffffffffc0207b60:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207b64:	010cb583          	ld	a1,16(s9)
ffffffffc0207b68:	8542                	mv	a0,a6
ffffffffc0207b6a:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc0207b6c:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207b6e:	c92fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207b72:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207b74:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = b;
ffffffffc0207b78:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207b7a:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = b;
ffffffffc0207b7e:	c119                	beqz	a0,ffffffffc0207b84 <stride_dequeue+0x1984>
ffffffffc0207b80:	01953023          	sd	s9,0(a0)
          a->right = r;
ffffffffc0207b84:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207b86:	0198b423          	sd	s9,8(a7)
          a->right = r;
ffffffffc0207b8a:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc0207b8e:	011cb023          	sd	a7,0(s9)
ffffffffc0207b92:	8cc6                	mv	s9,a7
ffffffffc0207b94:	f80ff06f          	j	ffffffffc0207314 <stride_dequeue+0x1114>
          r = a->left;
ffffffffc0207b98:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207b9c:	0109b883          	ld	a7,16(s3)
ffffffffc0207ba0:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207ba2:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207ba4:	02088f63          	beqz	a7,ffffffffc0207be2 <stride_dequeue+0x19e2>
     if (comp(a, b) == -1)
ffffffffc0207ba8:	85c2                	mv	a1,a6
ffffffffc0207baa:	8546                	mv	a0,a7
ffffffffc0207bac:	f842                	sd	a6,48(sp)
ffffffffc0207bae:	f446                	sd	a7,40(sp)
ffffffffc0207bb0:	beafe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207bb4:	7362                	ld	t1,56(sp)
ffffffffc0207bb6:	78a2                	ld	a7,40(sp)
ffffffffc0207bb8:	7842                	ld	a6,48(sp)
ffffffffc0207bba:	486500e3          	beq	a0,t1,ffffffffc020883a <stride_dequeue+0x263a>
          r = b->left;
ffffffffc0207bbe:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207bc2:	01083583          	ld	a1,16(a6)
ffffffffc0207bc6:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207bc8:	f842                	sd	a6,48(sp)
ffffffffc0207bca:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207bcc:	c34fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207bd0:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207bd2:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207bd4:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207bd8:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207bdc:	c119                	beqz	a0,ffffffffc0207be2 <stride_dequeue+0x19e2>
ffffffffc0207bde:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207be2:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207be4:	0109b423          	sd	a6,8(s3)
          a->right = r;
ffffffffc0207be8:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = a;
ffffffffc0207bec:	01383023          	sd	s3,0(a6)
ffffffffc0207bf0:	884e                	mv	a6,s3
ffffffffc0207bf2:	856ff06f          	j	ffffffffc0206c48 <stride_dequeue+0xa48>
          r = a->left;
ffffffffc0207bf6:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207bfa:	0108b803          	ld	a6,16(a7)
ffffffffc0207bfe:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207c00:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207c02:	02080f63          	beqz	a6,ffffffffc0207c40 <stride_dequeue+0x1a40>
     if (comp(a, b) == -1)
ffffffffc0207c06:	8542                	mv	a0,a6
ffffffffc0207c08:	85e6                	mv	a1,s9
ffffffffc0207c0a:	f846                	sd	a7,48(sp)
ffffffffc0207c0c:	f442                	sd	a6,40(sp)
ffffffffc0207c0e:	b8cfe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207c12:	7362                	ld	t1,56(sp)
ffffffffc0207c14:	7822                	ld	a6,40(sp)
ffffffffc0207c16:	78c2                	ld	a7,48(sp)
ffffffffc0207c18:	1e6500e3          	beq	a0,t1,ffffffffc02085f8 <stride_dequeue+0x23f8>
          r = b->left;
ffffffffc0207c1c:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207c20:	010cb583          	ld	a1,16(s9)
ffffffffc0207c24:	8542                	mv	a0,a6
ffffffffc0207c26:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc0207c28:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207c2a:	bd6fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207c2e:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207c30:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = b;
ffffffffc0207c34:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207c36:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = b;
ffffffffc0207c3a:	c119                	beqz	a0,ffffffffc0207c40 <stride_dequeue+0x1a40>
ffffffffc0207c3c:	01953023          	sd	s9,0(a0)
          a->right = r;
ffffffffc0207c40:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207c42:	0198b423          	sd	s9,8(a7)
          a->right = r;
ffffffffc0207c46:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc0207c4a:	011cb023          	sd	a7,0(s9)
ffffffffc0207c4e:	8cc6                	mv	s9,a7
ffffffffc0207c50:	e2eff06f          	j	ffffffffc020727e <stride_dequeue+0x107e>
          r = a->left;
ffffffffc0207c54:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207c58:	010cb883          	ld	a7,16(s9)
ffffffffc0207c5c:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207c5e:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207c60:	02088f63          	beqz	a7,ffffffffc0207c9e <stride_dequeue+0x1a9e>
     if (comp(a, b) == -1)
ffffffffc0207c64:	85c2                	mv	a1,a6
ffffffffc0207c66:	8546                	mv	a0,a7
ffffffffc0207c68:	f842                	sd	a6,48(sp)
ffffffffc0207c6a:	f446                	sd	a7,40(sp)
ffffffffc0207c6c:	b2efe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207c70:	7362                	ld	t1,56(sp)
ffffffffc0207c72:	78a2                	ld	a7,40(sp)
ffffffffc0207c74:	7842                	ld	a6,48(sp)
ffffffffc0207c76:	3e6507e3          	beq	a0,t1,ffffffffc0208864 <stride_dequeue+0x2664>
          r = b->left;
ffffffffc0207c7a:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207c7e:	01083583          	ld	a1,16(a6)
ffffffffc0207c82:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207c84:	f842                	sd	a6,48(sp)
ffffffffc0207c86:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207c88:	b78fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207c8c:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207c8e:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207c90:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207c94:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207c98:	c119                	beqz	a0,ffffffffc0207c9e <stride_dequeue+0x1a9e>
ffffffffc0207c9a:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207c9e:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207ca0:	010cb423          	sd	a6,8(s9)
          a->right = r;
ffffffffc0207ca4:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207ca8:	01983023          	sd	s9,0(a6)
ffffffffc0207cac:	8866                	mv	a6,s9
ffffffffc0207cae:	862ff06f          	j	ffffffffc0206d10 <stride_dequeue+0xb10>
          r = a->left;
ffffffffc0207cb2:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207cb6:	0109b883          	ld	a7,16(s3)
ffffffffc0207cba:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207cbc:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207cbe:	02088f63          	beqz	a7,ffffffffc0207cfc <stride_dequeue+0x1afc>
     if (comp(a, b) == -1)
ffffffffc0207cc2:	85c2                	mv	a1,a6
ffffffffc0207cc4:	8546                	mv	a0,a7
ffffffffc0207cc6:	f842                	sd	a6,48(sp)
ffffffffc0207cc8:	f446                	sd	a7,40(sp)
ffffffffc0207cca:	ad0fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207cce:	7362                	ld	t1,56(sp)
ffffffffc0207cd0:	78a2                	ld	a7,40(sp)
ffffffffc0207cd2:	7842                	ld	a6,48(sp)
ffffffffc0207cd4:	186500e3          	beq	a0,t1,ffffffffc0208654 <stride_dequeue+0x2454>
          r = b->left;
ffffffffc0207cd8:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207cdc:	01083583          	ld	a1,16(a6)
ffffffffc0207ce0:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207ce2:	f842                	sd	a6,48(sp)
ffffffffc0207ce4:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207ce6:	b1afe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207cea:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207cec:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207cee:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207cf2:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207cf6:	c119                	beqz	a0,ffffffffc0207cfc <stride_dequeue+0x1afc>
ffffffffc0207cf8:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207cfc:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207cfe:	0109b423          	sd	a6,8(s3)
          a->right = r;
ffffffffc0207d02:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = a;
ffffffffc0207d06:	01383023          	sd	s3,0(a6)
ffffffffc0207d0a:	884e                	mv	a6,s3
ffffffffc0207d0c:	ae9fe06f          	j	ffffffffc02067f4 <stride_dequeue+0x5f4>
ffffffffc0207d10:	8352                	mv	t1,s4
ffffffffc0207d12:	f8afe06f          	j	ffffffffc020649c <stride_dequeue+0x29c>
ffffffffc0207d16:	8362                	mv	t1,s8
ffffffffc0207d18:	8b5fe06f          	j	ffffffffc02065cc <stride_dequeue+0x3cc>
     else if (b == NULL) return a;
ffffffffc0207d1c:	8d66                	mv	s10,s9
ffffffffc0207d1e:	e65fe06f          	j	ffffffffc0206b82 <stride_dequeue+0x982>
          r = a->left;
ffffffffc0207d22:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207d26:	010cb883          	ld	a7,16(s9)
ffffffffc0207d2a:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207d2c:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207d2e:	02088f63          	beqz	a7,ffffffffc0207d6c <stride_dequeue+0x1b6c>
     if (comp(a, b) == -1)
ffffffffc0207d32:	8546                	mv	a0,a7
ffffffffc0207d34:	85ea                	mv	a1,s10
ffffffffc0207d36:	f832                	sd	a2,48(sp)
ffffffffc0207d38:	f446                	sd	a7,40(sp)
ffffffffc0207d3a:	a60fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207d3e:	7362                	ld	t1,56(sp)
ffffffffc0207d40:	78a2                	ld	a7,40(sp)
ffffffffc0207d42:	7642                	ld	a2,48(sp)
ffffffffc0207d44:	04650ce3          	beq	a0,t1,ffffffffc020859c <stride_dequeue+0x239c>
          r = b->left;
ffffffffc0207d48:	008d3303          	ld	t1,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207d4c:	010d3583          	ld	a1,16(s10)
ffffffffc0207d50:	8546                	mv	a0,a7
ffffffffc0207d52:	f832                	sd	a2,48(sp)
          r = b->left;
ffffffffc0207d54:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207d56:	aaafe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207d5a:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207d5c:	00ad3423          	sd	a0,8(s10)
          if (l) l->parent = b;
ffffffffc0207d60:	7642                	ld	a2,48(sp)
          b->right = r;
ffffffffc0207d62:	006d3823          	sd	t1,16(s10)
          if (l) l->parent = b;
ffffffffc0207d66:	c119                	beqz	a0,ffffffffc0207d6c <stride_dequeue+0x1b6c>
ffffffffc0207d68:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc0207d6c:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207d6e:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc0207d72:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207d76:	019d3023          	sd	s9,0(s10)
ffffffffc0207d7a:	8d66                	mv	s10,s9
ffffffffc0207d7c:	b69fe06f          	j	ffffffffc02068e4 <stride_dequeue+0x6e4>
          r = a->left;
ffffffffc0207d80:	008c3703          	ld	a4,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207d84:	010c3883          	ld	a7,16(s8)
ffffffffc0207d88:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207d8a:	f03a                	sd	a4,32(sp)
     if (a == NULL) return b;
ffffffffc0207d8c:	02088c63          	beqz	a7,ffffffffc0207dc4 <stride_dequeue+0x1bc4>
     if (comp(a, b) == -1)
ffffffffc0207d90:	85be                	mv	a1,a5
ffffffffc0207d92:	8546                	mv	a0,a7
ffffffffc0207d94:	f83e                	sd	a5,48(sp)
ffffffffc0207d96:	f446                	sd	a7,40(sp)
ffffffffc0207d98:	a02fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207d9c:	7362                	ld	t1,56(sp)
ffffffffc0207d9e:	78a2                	ld	a7,40(sp)
ffffffffc0207da0:	77c2                	ld	a5,48(sp)
ffffffffc0207da2:	78650f63          	beq	a0,t1,ffffffffc0208540 <stride_dequeue+0x2340>
          r = b->left;
ffffffffc0207da6:	0087b303          	ld	t1,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207daa:	6b8c                	ld	a1,16(a5)
ffffffffc0207dac:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207dae:	f83e                	sd	a5,48(sp)
ffffffffc0207db0:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207db2:	a4efe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207db6:	77c2                	ld	a5,48(sp)
          b->right = r;
ffffffffc0207db8:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207dba:	e788                	sd	a0,8(a5)
          b->right = r;
ffffffffc0207dbc:	0067b823          	sd	t1,16(a5)
          if (l) l->parent = b;
ffffffffc0207dc0:	c111                	beqz	a0,ffffffffc0207dc4 <stride_dequeue+0x1bc4>
ffffffffc0207dc2:	e11c                	sd	a5,0(a0)
          a->right = r;
ffffffffc0207dc4:	7702                	ld	a4,32(sp)
          a->left = l;
ffffffffc0207dc6:	00fc3423          	sd	a5,8(s8)
          a->right = r;
ffffffffc0207dca:	00ec3823          	sd	a4,16(s8)
          if (l) l->parent = a;
ffffffffc0207dce:	0187b023          	sd	s8,0(a5)
ffffffffc0207dd2:	87e2                	mv	a5,s8
ffffffffc0207dd4:	91ffe06f          	j	ffffffffc02066f2 <stride_dequeue+0x4f2>
          r = a->left;
ffffffffc0207dd8:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207ddc:	0108b803          	ld	a6,16(a7)
ffffffffc0207de0:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207de2:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207de4:	02080f63          	beqz	a6,ffffffffc0207e22 <stride_dequeue+0x1c22>
     if (comp(a, b) == -1)
ffffffffc0207de8:	8542                	mv	a0,a6
ffffffffc0207dea:	85ce                	mv	a1,s3
ffffffffc0207dec:	f846                	sd	a7,48(sp)
ffffffffc0207dee:	f442                	sd	a6,40(sp)
ffffffffc0207df0:	9aafe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207df4:	7362                	ld	t1,56(sp)
ffffffffc0207df6:	7822                	ld	a6,40(sp)
ffffffffc0207df8:	78c2                	ld	a7,48(sp)
ffffffffc0207dfa:	0e6500e3          	beq	a0,t1,ffffffffc02086da <stride_dequeue+0x24da>
          r = b->left;
ffffffffc0207dfe:	0089b303          	ld	t1,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207e02:	0109b583          	ld	a1,16(s3)
ffffffffc0207e06:	8542                	mv	a0,a6
ffffffffc0207e08:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc0207e0a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207e0c:	9f4fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207e10:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207e12:	00a9b423          	sd	a0,8(s3)
          if (l) l->parent = b;
ffffffffc0207e16:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207e18:	0069b823          	sd	t1,16(s3)
          if (l) l->parent = b;
ffffffffc0207e1c:	c119                	beqz	a0,ffffffffc0207e22 <stride_dequeue+0x1c22>
ffffffffc0207e1e:	01353023          	sd	s3,0(a0)
          a->right = r;
ffffffffc0207e22:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207e24:	0138b423          	sd	s3,8(a7)
          a->right = r;
ffffffffc0207e28:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc0207e2c:	0119b023          	sd	a7,0(s3)
ffffffffc0207e30:	89c6                	mv	s3,a7
ffffffffc0207e32:	b24ff06f          	j	ffffffffc0207156 <stride_dequeue+0xf56>
ffffffffc0207e36:	8352                	mv	t1,s4
ffffffffc0207e38:	b69fe06f          	j	ffffffffc02069a0 <stride_dequeue+0x7a0>
ffffffffc0207e3c:	8352                	mv	t1,s4
ffffffffc0207e3e:	c3bfe06f          	j	ffffffffc0206a78 <stride_dequeue+0x878>
          r = a->left;
ffffffffc0207e42:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207e46:	0108b803          	ld	a6,16(a7)
ffffffffc0207e4a:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207e4c:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207e4e:	02080f63          	beqz	a6,ffffffffc0207e8c <stride_dequeue+0x1c8c>
     if (comp(a, b) == -1)
ffffffffc0207e52:	8542                	mv	a0,a6
ffffffffc0207e54:	85e6                	mv	a1,s9
ffffffffc0207e56:	f846                	sd	a7,48(sp)
ffffffffc0207e58:	f442                	sd	a6,40(sp)
ffffffffc0207e5a:	940fe0ef          	jal	ra,ffffffffc0205f9a <proc_stride_comp_f>
ffffffffc0207e5e:	7362                	ld	t1,56(sp)
ffffffffc0207e60:	7822                	ld	a6,40(sp)
ffffffffc0207e62:	78c2                	ld	a7,48(sp)
ffffffffc0207e64:	046503e3          	beq	a0,t1,ffffffffc02086aa <stride_dequeue+0x24aa>
          r = b->left;
ffffffffc0207e68:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207e6c:	010cb583          	ld	a1,16(s9)
ffffffffc0207e70:	8542                	mv	a0,a6
ffffffffc0207e72:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc0207e74:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207e76:	98afe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207e7a:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207e7c:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = b;
ffffffffc0207e80:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207e82:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = b;
ffffffffc0207e86:	c119                	beqz	a0,ffffffffc0207e8c <stride_dequeue+0x1c8c>
ffffffffc0207e88:	01953023          	sd	s9,0(a0)
          a->right = r;
ffffffffc0207e8c:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207e8e:	0198b423          	sd	s9,8(a7)
          a->right = r;
ffffffffc0207e92:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc0207e96:	011cb023          	sd	a7,0(s9)
ffffffffc0207e9a:	8cc6                	mv	s9,a7
ffffffffc0207e9c:	b50ff06f          	j	ffffffffc02071ec <stride_dequeue+0xfec>
          r = a->left;
ffffffffc0207ea0:	008a3883          	ld	a7,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207ea4:	010a3503          	ld	a0,16(s4)
ffffffffc0207ea8:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207eaa:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207eac:	954fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207eb0:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0207eb2:	00aa3423          	sd	a0,8(s4)
          if (l) l->parent = a;
ffffffffc0207eb6:	77c2                	ld	a5,48(sp)
          a->right = r;
ffffffffc0207eb8:	011a3823          	sd	a7,16(s4)
          if (l) l->parent = a;
ffffffffc0207ebc:	e4050ae3          	beqz	a0,ffffffffc0207d10 <stride_dequeue+0x1b10>
ffffffffc0207ec0:	01453023          	sd	s4,0(a0)
ffffffffc0207ec4:	8352                	mv	t1,s4
ffffffffc0207ec6:	dd6fe06f          	j	ffffffffc020649c <stride_dequeue+0x29c>
          r = a->left;
ffffffffc0207eca:	008c3883          	ld	a7,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207ece:	010c3503          	ld	a0,16(s8)
ffffffffc0207ed2:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207ed4:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207ed6:	92afe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207eda:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0207edc:	00ac3423          	sd	a0,8(s8)
          if (l) l->parent = a;
ffffffffc0207ee0:	77c2                	ld	a5,48(sp)
          a->right = r;
ffffffffc0207ee2:	011c3823          	sd	a7,16(s8)
          if (l) l->parent = a;
ffffffffc0207ee6:	e20508e3          	beqz	a0,ffffffffc0207d16 <stride_dequeue+0x1b16>
ffffffffc0207eea:	01853023          	sd	s8,0(a0)
ffffffffc0207eee:	8362                	mv	t1,s8
ffffffffc0207ef0:	edcfe06f          	j	ffffffffc02065cc <stride_dequeue+0x3cc>
          r = a->left;
ffffffffc0207ef4:	008a3883          	ld	a7,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207ef8:	010a3503          	ld	a0,16(s4)
ffffffffc0207efc:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207efe:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f00:	900fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207f04:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0207f06:	00aa3423          	sd	a0,8(s4)
          if (l) l->parent = a;
ffffffffc0207f0a:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0207f0c:	011a3823          	sd	a7,16(s4)
          if (l) l->parent = a;
ffffffffc0207f10:	d11d                	beqz	a0,ffffffffc0207e36 <stride_dequeue+0x1c36>
ffffffffc0207f12:	01453023          	sd	s4,0(a0)
ffffffffc0207f16:	8352                	mv	t1,s4
ffffffffc0207f18:	a89fe06f          	j	ffffffffc02069a0 <stride_dequeue+0x7a0>
          r = a->left;
ffffffffc0207f1c:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f20:	0108b503          	ld	a0,16(a7)
ffffffffc0207f24:	85be                	mv	a1,a5
          r = a->left;
ffffffffc0207f26:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f28:	8d8fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0207f2c:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0207f2e:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0207f30:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0207f34:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0207f38:	5c050b63          	beqz	a0,ffffffffc020850e <stride_dequeue+0x230e>
ffffffffc0207f3c:	01153023          	sd	a7,0(a0)
ffffffffc0207f40:	87c6                	mv	a5,a7
ffffffffc0207f42:	c28ff06f          	j	ffffffffc020736a <stride_dequeue+0x116a>
          r = a->left;
ffffffffc0207f46:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f4a:	0108b503          	ld	a0,16(a7)
ffffffffc0207f4e:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207f50:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f52:	8aefe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0207f56:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0207f58:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc0207f5a:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0207f5e:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc0207f62:	b6050ae3          	beqz	a0,ffffffffc0207ad6 <stride_dequeue+0x18d6>
ffffffffc0207f66:	01153023          	sd	a7,0(a0)
ffffffffc0207f6a:	8346                	mv	t1,a7
ffffffffc0207f6c:	ef7fe06f          	j	ffffffffc0206e62 <stride_dequeue+0xc62>
          r = a->left;
ffffffffc0207f70:	008a3883          	ld	a7,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f74:	010a3503          	ld	a0,16(s4)
ffffffffc0207f78:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207f7a:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f7c:	884fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207f80:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0207f82:	00aa3423          	sd	a0,8(s4)
          if (l) l->parent = a;
ffffffffc0207f86:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0207f88:	011a3823          	sd	a7,16(s4)
          if (l) l->parent = a;
ffffffffc0207f8c:	ea0508e3          	beqz	a0,ffffffffc0207e3c <stride_dequeue+0x1c3c>
ffffffffc0207f90:	01453023          	sd	s4,0(a0)
ffffffffc0207f94:	8352                	mv	t1,s4
ffffffffc0207f96:	ae3fe06f          	j	ffffffffc0206a78 <stride_dequeue+0x878>
     else if (b == NULL) return a;
ffffffffc0207f9a:	87e2                	mv	a5,s8
ffffffffc0207f9c:	f56fe06f          	j	ffffffffc02066f2 <stride_dequeue+0x4f2>
ffffffffc0207fa0:	884e                	mv	a6,s3
ffffffffc0207fa2:	853fe06f          	j	ffffffffc02067f4 <stride_dequeue+0x5f4>
ffffffffc0207fa6:	884e                	mv	a6,s3
ffffffffc0207fa8:	ca1fe06f          	j	ffffffffc0206c48 <stride_dequeue+0xa48>
ffffffffc0207fac:	8866                	mv	a6,s9
ffffffffc0207fae:	d63fe06f          	j	ffffffffc0206d10 <stride_dequeue+0xb10>
ffffffffc0207fb2:	8866                	mv	a6,s9
ffffffffc0207fb4:	e21fe06f          	j	ffffffffc0206dd4 <stride_dequeue+0xbd4>
ffffffffc0207fb8:	8d66                	mv	s10,s9
ffffffffc0207fba:	92bfe06f          	j	ffffffffc02068e4 <stride_dequeue+0x6e4>
          r = a->left;
ffffffffc0207fbe:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207fc2:	010d3503          	ld	a0,16(s10)
ffffffffc0207fc6:	85a2                	mv	a1,s0
          r = a->left;
ffffffffc0207fc8:	ec3e                	sd	a5,24(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207fca:	836fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207fce:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207fd0:	00ad3423          	sd	a0,8(s10)
          a->right = r;
ffffffffc0207fd4:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc0207fd8:	c0050563          	beqz	a0,ffffffffc02073e2 <stride_dequeue+0x11e2>
ffffffffc0207fdc:	01a53023          	sd	s10,0(a0)
ffffffffc0207fe0:	c02ff06f          	j	ffffffffc02073e2 <stride_dequeue+0x11e2>
          r = a->left;
ffffffffc0207fe4:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207fe8:	0108b503          	ld	a0,16(a7)
ffffffffc0207fec:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207fee:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207ff0:	810fe0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0207ff4:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0207ff6:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc0207ff8:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0207ffc:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc0208000:	a6050863          	beqz	a0,ffffffffc0207270 <stride_dequeue+0x1070>
ffffffffc0208004:	01153023          	sd	a7,0(a0)
ffffffffc0208008:	a68ff06f          	j	ffffffffc0207270 <stride_dequeue+0x1070>
          r = a->left;
ffffffffc020800c:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208010:	01083503          	ld	a0,16(a6)
ffffffffc0208014:	85d2                	mv	a1,s4
          r = a->left;
ffffffffc0208016:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208018:	fe9fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020801c:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020801e:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc0208020:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc0208022:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208026:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc020802a:	0a0500e3          	beqz	a0,ffffffffc02088ca <stride_dequeue+0x26ca>
ffffffffc020802e:	01053023          	sd	a6,0(a0)
ffffffffc0208032:	8a42                	mv	s4,a6
ffffffffc0208034:	fb0ff06f          	j	ffffffffc02077e4 <stride_dequeue+0x15e4>
          r = a->left;
ffffffffc0208038:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020803c:	010d3503          	ld	a0,16(s10)
ffffffffc0208040:	85b2                	mv	a1,a2
          r = a->left;
ffffffffc0208042:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208044:	fbdfd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208048:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc020804a:	00ad3423          	sd	a0,8(s10)
          a->right = r;
ffffffffc020804e:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc0208052:	f2050b63          	beqz	a0,ffffffffc0207788 <stride_dequeue+0x1588>
ffffffffc0208056:	01a53023          	sd	s10,0(a0)
ffffffffc020805a:	f2eff06f          	j	ffffffffc0207788 <stride_dequeue+0x1588>
          r = a->left;
ffffffffc020805e:	0089b883          	ld	a7,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208062:	0109b503          	ld	a0,16(s3)
ffffffffc0208066:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0208068:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020806a:	f97fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020806e:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0208070:	00a9b423          	sd	a0,8(s3)
          if (l) l->parent = a;
ffffffffc0208074:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208076:	0119b823          	sd	a7,16(s3)
          if (l) l->parent = a;
ffffffffc020807a:	e119                	bnez	a0,ffffffffc0208080 <stride_dequeue+0x1e80>
ffffffffc020807c:	f6afe06f          	j	ffffffffc02067e6 <stride_dequeue+0x5e6>
ffffffffc0208080:	01353023          	sd	s3,0(a0)
ffffffffc0208084:	f62fe06f          	j	ffffffffc02067e6 <stride_dequeue+0x5e6>
          r = a->left;
ffffffffc0208088:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020808c:	01083503          	ld	a0,16(a6)
ffffffffc0208090:	85e6                	mv	a1,s9
          r = a->left;
ffffffffc0208092:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208094:	f6dfd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208098:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc020809a:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc020809c:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02080a0:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc02080a4:	da050963          	beqz	a0,ffffffffc0207656 <stride_dequeue+0x1456>
ffffffffc02080a8:	01053023          	sd	a6,0(a0)
ffffffffc02080ac:	daaff06f          	j	ffffffffc0207656 <stride_dequeue+0x1456>
     if (a == NULL) return b;
ffffffffc02080b0:	8d22                	mv	s10,s0
ffffffffc02080b2:	b30ff06f          	j	ffffffffc02073e2 <stride_dequeue+0x11e2>
          r = a->left;
ffffffffc02080b6:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080ba:	01083503          	ld	a0,16(a6)
ffffffffc02080be:	85e6                	mv	a1,s9
          r = a->left;
ffffffffc02080c0:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080c2:	f3ffd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02080c6:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc02080c8:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02080ca:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02080ce:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc02080d2:	e0050f63          	beqz	a0,ffffffffc02076f0 <stride_dequeue+0x14f0>
ffffffffc02080d6:	01053023          	sd	a6,0(a0)
ffffffffc02080da:	e16ff06f          	j	ffffffffc02076f0 <stride_dequeue+0x14f0>
          r = a->left;
ffffffffc02080de:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080e2:	01083503          	ld	a0,16(a6)
ffffffffc02080e6:	85e6                	mv	a1,s9
          r = a->left;
ffffffffc02080e8:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080ea:	f17fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02080ee:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc02080f0:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02080f2:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02080f6:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc02080fa:	c2050363          	beqz	a0,ffffffffc0207520 <stride_dequeue+0x1320>
ffffffffc02080fe:	01053023          	sd	a6,0(a0)
ffffffffc0208102:	c1eff06f          	j	ffffffffc0207520 <stride_dequeue+0x1320>
          r = a->left;
ffffffffc0208106:	008cb883          	ld	a7,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020810a:	010cb503          	ld	a0,16(s9)
ffffffffc020810e:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0208110:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208112:	eeffd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208116:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0208118:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc020811c:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020811e:	011cb823          	sd	a7,16(s9)
          if (l) l->parent = a;
ffffffffc0208122:	e119                	bnez	a0,ffffffffc0208128 <stride_dequeue+0x1f28>
ffffffffc0208124:	bdffe06f          	j	ffffffffc0206d02 <stride_dequeue+0xb02>
ffffffffc0208128:	01953023          	sd	s9,0(a0)
ffffffffc020812c:	bd7fe06f          	j	ffffffffc0206d02 <stride_dequeue+0xb02>
          r = a->left;
ffffffffc0208130:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208134:	0108b503          	ld	a0,16(a7)
ffffffffc0208138:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc020813a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020813c:	ec5fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208140:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208142:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208144:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208148:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc020814c:	7c050c63          	beqz	a0,ffffffffc0208924 <stride_dequeue+0x2724>
ffffffffc0208150:	01153023          	sd	a7,0(a0)
ffffffffc0208154:	8846                	mv	a6,a7
ffffffffc0208156:	ff4ff06f          	j	ffffffffc020794a <stride_dequeue+0x174a>
          r = a->left;
ffffffffc020815a:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020815e:	010cb503          	ld	a0,16(s9)
ffffffffc0208162:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc0208164:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208166:	e9bfd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020816a:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc020816c:	00acb423          	sd	a0,8(s9)
          a->right = r;
ffffffffc0208170:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0208174:	e119                	bnez	a0,ffffffffc020817a <stride_dequeue+0x1f7a>
ffffffffc0208176:	db1fe06f          	j	ffffffffc0206f26 <stride_dequeue+0xd26>
ffffffffc020817a:	01953023          	sd	s9,0(a0)
ffffffffc020817e:	da9fe06f          	j	ffffffffc0206f26 <stride_dequeue+0xd26>
          r = a->left;
ffffffffc0208182:	008cb883          	ld	a7,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208186:	010cb503          	ld	a0,16(s9)
ffffffffc020818a:	859a                	mv	a1,t1
          r = a->left;
ffffffffc020818c:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020818e:	e73fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208192:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0208194:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc0208198:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020819a:	011cb823          	sd	a7,16(s9)
          if (l) l->parent = a;
ffffffffc020819e:	e119                	bnez	a0,ffffffffc02081a4 <stride_dequeue+0x1fa4>
ffffffffc02081a0:	c27fe06f          	j	ffffffffc0206dc6 <stride_dequeue+0xbc6>
ffffffffc02081a4:	01953023          	sd	s9,0(a0)
ffffffffc02081a8:	c1ffe06f          	j	ffffffffc0206dc6 <stride_dequeue+0xbc6>
          r = a->left;
ffffffffc02081ac:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081b0:	010cb503          	ld	a0,16(s9)
ffffffffc02081b4:	85ba                	mv	a1,a4
          r = a->left;
ffffffffc02081b6:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081b8:	e49fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02081bc:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02081be:	00acb423          	sd	a0,8(s9)
          a->right = r;
ffffffffc02081c2:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02081c6:	e119                	bnez	a0,ffffffffc02081cc <stride_dequeue+0x1fcc>
ffffffffc02081c8:	9adfe06f          	j	ffffffffc0206b74 <stride_dequeue+0x974>
ffffffffc02081cc:	01953023          	sd	s9,0(a0)
ffffffffc02081d0:	9a5fe06f          	j	ffffffffc0206b74 <stride_dequeue+0x974>
          r = a->left;
ffffffffc02081d4:	0089b883          	ld	a7,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081d8:	0109b503          	ld	a0,16(s3)
ffffffffc02081dc:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02081de:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081e0:	e21fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02081e4:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc02081e6:	00a9b423          	sd	a0,8(s3)
          if (l) l->parent = a;
ffffffffc02081ea:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02081ec:	0119b823          	sd	a7,16(s3)
          if (l) l->parent = a;
ffffffffc02081f0:	e119                	bnez	a0,ffffffffc02081f6 <stride_dequeue+0x1ff6>
ffffffffc02081f2:	a49fe06f          	j	ffffffffc0206c3a <stride_dequeue+0xa3a>
ffffffffc02081f6:	01353023          	sd	s3,0(a0)
ffffffffc02081fa:	a41fe06f          	j	ffffffffc0206c3a <stride_dequeue+0xa3a>
          r = a->left;
ffffffffc02081fe:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208202:	0108b503          	ld	a0,16(a7)
ffffffffc0208206:	85be                	mv	a1,a5
          r = a->left;
ffffffffc0208208:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020820a:	df7fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020820e:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208210:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208212:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208216:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc020821a:	6e050963          	beqz	a0,ffffffffc020890c <stride_dequeue+0x270c>
ffffffffc020821e:	01153023          	sd	a7,0(a0)
ffffffffc0208222:	87c6                	mv	a5,a7
ffffffffc0208224:	ecaff06f          	j	ffffffffc02078ee <stride_dequeue+0x16ee>
          r = a->left;
ffffffffc0208228:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020822c:	0108b503          	ld	a0,16(a7)
ffffffffc0208230:	85be                	mv	a1,a5
          r = a->left;
ffffffffc0208232:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208234:	dcdfd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208238:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc020823a:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020823c:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208240:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208244:	6a050b63          	beqz	a0,ffffffffc02088fa <stride_dequeue+0x26fa>
ffffffffc0208248:	01153023          	sd	a7,0(a0)
ffffffffc020824c:	87c6                	mv	a5,a7
ffffffffc020824e:	e4aff06f          	j	ffffffffc0207898 <stride_dequeue+0x1698>
          r = a->left;
ffffffffc0208252:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208256:	0108b503          	ld	a0,16(a7)
ffffffffc020825a:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc020825c:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020825e:	da3fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208262:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208264:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208266:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020826a:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc020826e:	68050963          	beqz	a0,ffffffffc0208900 <stride_dequeue+0x2700>
ffffffffc0208272:	01153023          	sd	a7,0(a0)
ffffffffc0208276:	8846                	mv	a6,a7
ffffffffc0208278:	dcaff06f          	j	ffffffffc0207842 <stride_dequeue+0x1642>
          r = a->left;
ffffffffc020827c:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208280:	010cb503          	ld	a0,16(s9)
ffffffffc0208284:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc0208286:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208288:	d79fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020828c:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc020828e:	00acb423          	sd	a0,8(s9)
          a->right = r;
ffffffffc0208292:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0208296:	e119                	bnez	a0,ffffffffc020829c <stride_dequeue+0x209c>
ffffffffc0208298:	e1bfe06f          	j	ffffffffc02070b2 <stride_dequeue+0xeb2>
ffffffffc020829c:	01953023          	sd	s9,0(a0)
ffffffffc02082a0:	e13fe06f          	j	ffffffffc02070b2 <stride_dequeue+0xeb2>
          r = a->left;
ffffffffc02082a4:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02082a8:	01083503          	ld	a0,16(a6)
ffffffffc02082ac:	85ea                	mv	a1,s10
          r = a->left;
ffffffffc02082ae:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02082b0:	d51fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02082b4:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc02082b6:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02082b8:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02082bc:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc02082c0:	ae050e63          	beqz	a0,ffffffffc02075bc <stride_dequeue+0x13bc>
ffffffffc02082c4:	01053023          	sd	a6,0(a0)
ffffffffc02082c8:	af4ff06f          	j	ffffffffc02075bc <stride_dequeue+0x13bc>
          r = a->left;
ffffffffc02082cc:	008c3883          	ld	a7,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02082d0:	010c3503          	ld	a0,16(s8)
ffffffffc02082d4:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02082d6:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02082d8:	d29fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02082dc:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc02082de:	00ac3423          	sd	a0,8(s8)
          if (l) l->parent = a;
ffffffffc02082e2:	77c2                	ld	a5,48(sp)
          a->right = r;
ffffffffc02082e4:	011c3823          	sd	a7,16(s8)
          if (l) l->parent = a;
ffffffffc02082e8:	e119                	bnez	a0,ffffffffc02082ee <stride_dequeue+0x20ee>
ffffffffc02082ea:	bfcfe06f          	j	ffffffffc02066e6 <stride_dequeue+0x4e6>
ffffffffc02082ee:	01853023          	sd	s8,0(a0)
ffffffffc02082f2:	bf4fe06f          	j	ffffffffc02066e6 <stride_dequeue+0x4e6>
          r = a->left;
ffffffffc02082f6:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02082fa:	01083503          	ld	a0,16(a6)
ffffffffc02082fe:	85ea                	mv	a1,s10
          r = a->left;
ffffffffc0208300:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208302:	cfffd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208306:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc0208308:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc020830a:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc020830e:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc0208312:	96050963          	beqz	a0,ffffffffc0207484 <stride_dequeue+0x1284>
ffffffffc0208316:	01053023          	sd	a6,0(a0)
ffffffffc020831a:	96aff06f          	j	ffffffffc0207484 <stride_dequeue+0x1284>
          r = a->left;
ffffffffc020831e:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208322:	010d3503          	ld	a0,16(s10)
ffffffffc0208326:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc0208328:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020832a:	cd7fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020832e:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0208330:	00ad3423          	sd	a0,8(s10)
          a->right = r;
ffffffffc0208334:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc0208338:	e119                	bnez	a0,ffffffffc020833e <stride_dequeue+0x213e>
ffffffffc020833a:	cb3fe06f          	j	ffffffffc0206fec <stride_dequeue+0xdec>
ffffffffc020833e:	01a53023          	sd	s10,0(a0)
ffffffffc0208342:	cabfe06f          	j	ffffffffc0206fec <stride_dequeue+0xdec>
          r = a->left;
ffffffffc0208346:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020834a:	0108b503          	ld	a0,16(a7)
ffffffffc020834e:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0208350:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208352:	caffd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208356:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208358:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc020835a:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020835e:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc0208362:	e119                	bnez	a0,ffffffffc0208368 <stride_dequeue+0x2168>
ffffffffc0208364:	de5fe06f          	j	ffffffffc0207148 <stride_dequeue+0xf48>
ffffffffc0208368:	01153023          	sd	a7,0(a0)
ffffffffc020836c:	dddfe06f          	j	ffffffffc0207148 <stride_dequeue+0xf48>
          r = a->left;
ffffffffc0208370:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208374:	0108b503          	ld	a0,16(a7)
ffffffffc0208378:	859a                	mv	a1,t1
          r = a->left;
ffffffffc020837a:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020837c:	c85fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208380:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208382:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc0208384:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208388:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc020838c:	e119                	bnez	a0,ffffffffc0208392 <stride_dequeue+0x2192>
ffffffffc020838e:	e51fe06f          	j	ffffffffc02071de <stride_dequeue+0xfde>
ffffffffc0208392:	01153023          	sd	a7,0(a0)
ffffffffc0208396:	e49fe06f          	j	ffffffffc02071de <stride_dequeue+0xfde>
          r = a->left;
ffffffffc020839a:	008cb883          	ld	a7,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020839e:	010cb503          	ld	a0,16(s9)
ffffffffc02083a2:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02083a4:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02083a6:	c5bfd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02083aa:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc02083ac:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc02083b0:	7642                	ld	a2,48(sp)
          a->right = r;
ffffffffc02083b2:	011cb823          	sd	a7,16(s9)
          if (l) l->parent = a;
ffffffffc02083b6:	e119                	bnez	a0,ffffffffc02083bc <stride_dequeue+0x21bc>
ffffffffc02083b8:	d1efe06f          	j	ffffffffc02068d6 <stride_dequeue+0x6d6>
ffffffffc02083bc:	01953023          	sd	s9,0(a0)
ffffffffc02083c0:	d16fe06f          	j	ffffffffc02068d6 <stride_dequeue+0x6d6>
          r = a->left;
ffffffffc02083c4:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02083c8:	0108b503          	ld	a0,16(a7)
ffffffffc02083cc:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02083ce:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02083d0:	c31fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02083d4:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc02083d6:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc02083d8:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc02083dc:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc02083e0:	e119                	bnez	a0,ffffffffc02083e6 <stride_dequeue+0x21e6>
ffffffffc02083e2:	f25fe06f          	j	ffffffffc0207306 <stride_dequeue+0x1106>
ffffffffc02083e6:	01153023          	sd	a7,0(a0)
ffffffffc02083ea:	f1dfe06f          	j	ffffffffc0207306 <stride_dequeue+0x1106>
     if (a == NULL) return b;
ffffffffc02083ee:	886a                	mv	a6,s10
ffffffffc02083f0:	894ff06f          	j	ffffffffc0207484 <stride_dequeue+0x1284>
ffffffffc02083f4:	886a                	mv	a6,s10
ffffffffc02083f6:	9c6ff06f          	j	ffffffffc02075bc <stride_dequeue+0x13bc>
ffffffffc02083fa:	8d32                	mv	s10,a2
ffffffffc02083fc:	b8cff06f          	j	ffffffffc0207788 <stride_dequeue+0x1588>
ffffffffc0208400:	8866                	mv	a6,s9
ffffffffc0208402:	91eff06f          	j	ffffffffc0207520 <stride_dequeue+0x1320>
ffffffffc0208406:	8866                	mv	a6,s9
ffffffffc0208408:	ae8ff06f          	j	ffffffffc02076f0 <stride_dequeue+0x14f0>
ffffffffc020840c:	8866                	mv	a6,s9
ffffffffc020840e:	a48ff06f          	j	ffffffffc0207656 <stride_dequeue+0x1456>
          if (l) l->parent = b;
ffffffffc0208412:	889a                	mv	a7,t1
ffffffffc0208414:	d35fe06f          	j	ffffffffc0207148 <stride_dequeue+0xf48>
ffffffffc0208418:	889a                	mv	a7,t1
ffffffffc020841a:	dc5fe06f          	j	ffffffffc02071de <stride_dequeue+0xfde>
ffffffffc020841e:	899a                	mv	s3,t1
ffffffffc0208420:	81bfe06f          	j	ffffffffc0206c3a <stride_dequeue+0xa3a>
ffffffffc0208424:	8c9a                	mv	s9,t1
ffffffffc0208426:	cb0fe06f          	j	ffffffffc02068d6 <stride_dequeue+0x6d6>
ffffffffc020842a:	889a                	mv	a7,t1
ffffffffc020842c:	edbfe06f          	j	ffffffffc0207306 <stride_dequeue+0x1106>
          r = a->left;
ffffffffc0208430:	0087b803          	ld	a6,8(a5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208434:	6b88                	ld	a0,16(a5)
ffffffffc0208436:	85ea                	mv	a1,s10
          r = a->left;
ffffffffc0208438:	f43e                	sd	a5,40(sp)
ffffffffc020843a:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020843c:	bc5fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208440:	77a2                	ld	a5,40(sp)
          a->right = r;
ffffffffc0208442:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc0208444:	e788                	sd	a0,8(a5)
          a->right = r;
ffffffffc0208446:	0107b823          	sd	a6,16(a5)
          if (l) l->parent = a;
ffffffffc020844a:	4c050463          	beqz	a0,ffffffffc0208912 <stride_dequeue+0x2712>
ffffffffc020844e:	e11c                	sd	a5,0(a0)
ffffffffc0208450:	8d3e                	mv	s10,a5
ffffffffc0208452:	dc8ff06f          	j	ffffffffc0207a1a <stride_dequeue+0x181a>
          if (l) l->parent = b;
ffffffffc0208456:	8c1a                	mv	s8,t1
ffffffffc0208458:	a8efe06f          	j	ffffffffc02066e6 <stride_dequeue+0x4e6>
          r = a->left;
ffffffffc020845c:	008d3803          	ld	a6,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208460:	010d3503          	ld	a0,16(s10)
ffffffffc0208464:	85b2                	mv	a1,a2
          r = a->left;
ffffffffc0208466:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208468:	b99fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020846c:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc020846e:	00ad3423          	sd	a0,8(s10)
          a->right = r;
ffffffffc0208472:	010d3823          	sd	a6,16(s10)
          if (l) l->parent = a;
ffffffffc0208476:	e119                	bnez	a0,ffffffffc020847c <stride_dequeue+0x227c>
ffffffffc0208478:	f5dfe06f          	j	ffffffffc02073d4 <stride_dequeue+0x11d4>
ffffffffc020847c:	01a53023          	sd	s10,0(a0)
ffffffffc0208480:	f55fe06f          	j	ffffffffc02073d4 <stride_dequeue+0x11d4>
          r = a->left;
ffffffffc0208484:	0087b803          	ld	a6,8(a5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208488:	6b88                	ld	a0,16(a5)
ffffffffc020848a:	85ce                	mv	a1,s3
          r = a->left;
ffffffffc020848c:	f43e                	sd	a5,40(sp)
ffffffffc020848e:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208490:	b71fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208494:	77a2                	ld	a5,40(sp)
          a->right = r;
ffffffffc0208496:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc0208498:	e788                	sd	a0,8(a5)
          a->right = r;
ffffffffc020849a:	0107b823          	sd	a6,16(a5)
          if (l) l->parent = a;
ffffffffc020849e:	3e050863          	beqz	a0,ffffffffc020888e <stride_dequeue+0x268e>
ffffffffc02084a2:	e11c                	sd	a5,0(a0)
ffffffffc02084a4:	89be                	mv	s3,a5
ffffffffc02084a6:	dc8ff06f          	j	ffffffffc0207a6e <stride_dequeue+0x186e>
          if (l) l->parent = b;
ffffffffc02084aa:	8c9a                	mv	s9,t1
ffffffffc02084ac:	91bfe06f          	j	ffffffffc0206dc6 <stride_dequeue+0xbc6>
          r = a->left;
ffffffffc02084b0:	0087b803          	ld	a6,8(a5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02084b4:	6b88                	ld	a0,16(a5)
ffffffffc02084b6:	85ea                	mv	a1,s10
          r = a->left;
ffffffffc02084b8:	f43e                	sd	a5,40(sp)
ffffffffc02084ba:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02084bc:	b45fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02084c0:	77a2                	ld	a5,40(sp)
          a->right = r;
ffffffffc02084c2:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc02084c4:	e788                	sd	a0,8(a5)
          a->right = r;
ffffffffc02084c6:	0107b823          	sd	a6,16(a5)
          if (l) l->parent = a;
ffffffffc02084ca:	40050c63          	beqz	a0,ffffffffc02088e2 <stride_dequeue+0x26e2>
ffffffffc02084ce:	e11c                	sd	a5,0(a0)
ffffffffc02084d0:	8d3e                	mv	s10,a5
ffffffffc02084d2:	cf4ff06f          	j	ffffffffc02079c6 <stride_dequeue+0x17c6>
          if (l) l->parent = b;
ffffffffc02084d6:	899a                	mv	s3,t1
ffffffffc02084d8:	b0efe06f          	j	ffffffffc02067e6 <stride_dequeue+0x5e6>
ffffffffc02084dc:	889a                	mv	a7,t1
ffffffffc02084de:	d93fe06f          	j	ffffffffc0207270 <stride_dequeue+0x1070>
ffffffffc02084e2:	8c9a                	mv	s9,t1
ffffffffc02084e4:	81ffe06f          	j	ffffffffc0206d02 <stride_dequeue+0xb02>
          r = a->left;
ffffffffc02084e8:	0087b803          	ld	a6,8(a5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02084ec:	6b88                	ld	a0,16(a5)
ffffffffc02084ee:	85ea                	mv	a1,s10
          r = a->left;
ffffffffc02084f0:	f43e                	sd	a5,40(sp)
ffffffffc02084f2:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02084f4:	b0dfd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02084f8:	77a2                	ld	a5,40(sp)
          a->right = r;
ffffffffc02084fa:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc02084fc:	e788                	sd	a0,8(a5)
          a->right = r;
ffffffffc02084fe:	0107b823          	sd	a6,16(a5)
          if (l) l->parent = a;
ffffffffc0208502:	42050463          	beqz	a0,ffffffffc020892a <stride_dequeue+0x272a>
ffffffffc0208506:	e11c                	sd	a5,0(a0)
ffffffffc0208508:	8d3e                	mv	s10,a5
ffffffffc020850a:	db8ff06f          	j	ffffffffc0207ac2 <stride_dequeue+0x18c2>
ffffffffc020850e:	87c6                	mv	a5,a7
ffffffffc0208510:	e5bfe06f          	j	ffffffffc020736a <stride_dequeue+0x116a>
          r = a->left;
ffffffffc0208514:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208518:	01083503          	ld	a0,16(a6)
ffffffffc020851c:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc020851e:	f842                	sd	a6,48(sp)
ffffffffc0208520:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208522:	adffd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208526:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208528:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020852a:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc020852e:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc0208532:	e119                	bnez	a0,ffffffffc0208538 <stride_dequeue+0x2338>
ffffffffc0208534:	f41fe06f          	j	ffffffffc0207474 <stride_dequeue+0x1274>
ffffffffc0208538:	01053023          	sd	a6,0(a0)
ffffffffc020853c:	f39fe06f          	j	ffffffffc0207474 <stride_dequeue+0x1274>
          r = a->left;
ffffffffc0208540:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208544:	0108b503          	ld	a0,16(a7)
ffffffffc0208548:	85be                	mv	a1,a5
          r = a->left;
ffffffffc020854a:	f846                	sd	a7,48(sp)
ffffffffc020854c:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020854e:	ab3fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208552:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208554:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208556:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020855a:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc020855e:	3a050463          	beqz	a0,ffffffffc0208906 <stride_dequeue+0x2706>
ffffffffc0208562:	01153023          	sd	a7,0(a0)
ffffffffc0208566:	87c6                	mv	a5,a7
ffffffffc0208568:	85dff06f          	j	ffffffffc0207dc4 <stride_dequeue+0x1bc4>
          if (l) l->parent = b;
ffffffffc020856c:	8d32                	mv	s10,a2
ffffffffc020856e:	e67fe06f          	j	ffffffffc02073d4 <stride_dequeue+0x11d4>
          r = a->left;
ffffffffc0208572:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208576:	010cb503          	ld	a0,16(s9)
ffffffffc020857a:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc020857c:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020857e:	a83fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208582:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208584:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc0208588:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020858a:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = a;
ffffffffc020858e:	e119                	bnez	a0,ffffffffc0208594 <stride_dequeue+0x2394>
ffffffffc0208590:	b13fe06f          	j	ffffffffc02070a2 <stride_dequeue+0xea2>
ffffffffc0208594:	01953023          	sd	s9,0(a0)
ffffffffc0208598:	b0bfe06f          	j	ffffffffc02070a2 <stride_dequeue+0xea2>
          r = a->left;
ffffffffc020859c:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02085a0:	0108b503          	ld	a0,16(a7)
ffffffffc02085a4:	85ea                	mv	a1,s10
ffffffffc02085a6:	fc32                	sd	a2,56(sp)
          r = a->left;
ffffffffc02085a8:	f846                	sd	a7,48(sp)
ffffffffc02085aa:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02085ac:	a55fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02085b0:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc02085b2:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc02085b4:	7662                	ld	a2,56(sp)
          a->left = l;
ffffffffc02085b6:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc02085ba:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc02085be:	30050c63          	beqz	a0,ffffffffc02088d6 <stride_dequeue+0x26d6>
ffffffffc02085c2:	01153023          	sd	a7,0(a0)
ffffffffc02085c6:	8d46                	mv	s10,a7
ffffffffc02085c8:	fa4ff06f          	j	ffffffffc0207d6c <stride_dequeue+0x1b6c>
          r = a->left;
ffffffffc02085cc:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02085d0:	01083503          	ld	a0,16(a6)
ffffffffc02085d4:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc02085d6:	f842                	sd	a6,48(sp)
ffffffffc02085d8:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02085da:	a27fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02085de:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02085e0:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02085e2:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02085e6:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc02085ea:	e119                	bnez	a0,ffffffffc02085f0 <stride_dequeue+0x23f0>
ffffffffc02085ec:	f25fe06f          	j	ffffffffc0207510 <stride_dequeue+0x1310>
ffffffffc02085f0:	01053023          	sd	a6,0(a0)
ffffffffc02085f4:	f1dfe06f          	j	ffffffffc0207510 <stride_dequeue+0x1310>
          r = a->left;
ffffffffc02085f8:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02085fc:	01083503          	ld	a0,16(a6)
ffffffffc0208600:	85e6                	mv	a1,s9
ffffffffc0208602:	fc46                	sd	a7,56(sp)
          r = a->left;
ffffffffc0208604:	f842                	sd	a6,48(sp)
ffffffffc0208606:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208608:	9f9fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020860c:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020860e:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc0208610:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc0208612:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208616:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc020861a:	28050f63          	beqz	a0,ffffffffc02088b8 <stride_dequeue+0x26b8>
ffffffffc020861e:	01053023          	sd	a6,0(a0)
ffffffffc0208622:	8cc2                	mv	s9,a6
ffffffffc0208624:	e1cff06f          	j	ffffffffc0207c40 <stride_dequeue+0x1a40>
          r = a->left;
ffffffffc0208628:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020862c:	0108b503          	ld	a0,16(a7)
ffffffffc0208630:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc0208632:	f846                	sd	a7,48(sp)
ffffffffc0208634:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208636:	9cbfd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020863a:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc020863c:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020863e:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208642:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208646:	26050c63          	beqz	a0,ffffffffc02088be <stride_dequeue+0x26be>
ffffffffc020864a:	01153023          	sd	a7,0(a0)
ffffffffc020864e:	8846                	mv	a6,a7
ffffffffc0208650:	cd6ff06f          	j	ffffffffc0207b26 <stride_dequeue+0x1926>
          r = a->left;
ffffffffc0208654:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208658:	0108b503          	ld	a0,16(a7)
ffffffffc020865c:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc020865e:	f846                	sd	a7,48(sp)
ffffffffc0208660:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208662:	99ffd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208666:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208668:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020866a:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020866e:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208672:	26050e63          	beqz	a0,ffffffffc02088ee <stride_dequeue+0x26ee>
ffffffffc0208676:	01153023          	sd	a7,0(a0)
ffffffffc020867a:	8846                	mv	a6,a7
ffffffffc020867c:	e80ff06f          	j	ffffffffc0207cfc <stride_dequeue+0x1afc>
          r = a->left;
ffffffffc0208680:	008d3303          	ld	t1,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208684:	010d3503          	ld	a0,16(s10)
ffffffffc0208688:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc020868a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020868c:	975fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208690:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208692:	00ad3423          	sd	a0,8(s10)
          if (l) l->parent = a;
ffffffffc0208696:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208698:	006d3823          	sd	t1,16(s10)
          if (l) l->parent = a;
ffffffffc020869c:	e119                	bnez	a0,ffffffffc02086a2 <stride_dequeue+0x24a2>
ffffffffc020869e:	93ffe06f          	j	ffffffffc0206fdc <stride_dequeue+0xddc>
ffffffffc02086a2:	01a53023          	sd	s10,0(a0)
ffffffffc02086a6:	937fe06f          	j	ffffffffc0206fdc <stride_dequeue+0xddc>
          r = a->left;
ffffffffc02086aa:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02086ae:	01083503          	ld	a0,16(a6)
ffffffffc02086b2:	85e6                	mv	a1,s9
ffffffffc02086b4:	fc46                	sd	a7,56(sp)
          r = a->left;
ffffffffc02086b6:	f842                	sd	a6,48(sp)
ffffffffc02086b8:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02086ba:	947fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02086be:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02086c0:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc02086c2:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc02086c4:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02086c8:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc02086cc:	1c050a63          	beqz	a0,ffffffffc02088a0 <stride_dequeue+0x26a0>
ffffffffc02086d0:	01053023          	sd	a6,0(a0)
ffffffffc02086d4:	8cc2                	mv	s9,a6
ffffffffc02086d6:	fb6ff06f          	j	ffffffffc0207e8c <stride_dequeue+0x1c8c>
          r = a->left;
ffffffffc02086da:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02086de:	01083503          	ld	a0,16(a6)
ffffffffc02086e2:	85ce                	mv	a1,s3
ffffffffc02086e4:	fc46                	sd	a7,56(sp)
          r = a->left;
ffffffffc02086e6:	f842                	sd	a6,48(sp)
ffffffffc02086e8:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02086ea:	917fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02086ee:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02086f0:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc02086f2:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc02086f4:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02086f8:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc02086fc:	22050163          	beqz	a0,ffffffffc020891e <stride_dequeue+0x271e>
ffffffffc0208700:	01053023          	sd	a6,0(a0)
ffffffffc0208704:	89c2                	mv	s3,a6
ffffffffc0208706:	f1cff06f          	j	ffffffffc0207e22 <stride_dequeue+0x1c22>
          r = a->left;
ffffffffc020870a:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020870e:	010cb503          	ld	a0,16(s9)
ffffffffc0208712:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc0208714:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208716:	8ebfd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020871a:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020871c:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc0208720:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208722:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = a;
ffffffffc0208726:	e119                	bnez	a0,ffffffffc020872c <stride_dequeue+0x252c>
ffffffffc0208728:	feefe06f          	j	ffffffffc0206f16 <stride_dequeue+0xd16>
ffffffffc020872c:	01953023          	sd	s9,0(a0)
ffffffffc0208730:	fe6fe06f          	j	ffffffffc0206f16 <stride_dequeue+0xd16>
          r = a->left;
ffffffffc0208734:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208738:	010cb503          	ld	a0,16(s9)
ffffffffc020873c:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc020873e:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208740:	8c1fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208744:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208746:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc020874a:	7742                	ld	a4,48(sp)
          a->right = r;
ffffffffc020874c:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = a;
ffffffffc0208750:	e119                	bnez	a0,ffffffffc0208756 <stride_dequeue+0x2556>
ffffffffc0208752:	c14fe06f          	j	ffffffffc0206b66 <stride_dequeue+0x966>
ffffffffc0208756:	01953023          	sd	s9,0(a0)
ffffffffc020875a:	c0cfe06f          	j	ffffffffc0206b66 <stride_dequeue+0x966>
          r = a->left;
ffffffffc020875e:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208762:	01083503          	ld	a0,16(a6)
ffffffffc0208766:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc0208768:	f842                	sd	a6,48(sp)
ffffffffc020876a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020876c:	895fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208770:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208772:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208774:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208778:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc020877c:	e119                	bnez	a0,ffffffffc0208782 <stride_dequeue+0x2582>
ffffffffc020877e:	e2ffe06f          	j	ffffffffc02075ac <stride_dequeue+0x13ac>
ffffffffc0208782:	01053023          	sd	a6,0(a0)
ffffffffc0208786:	e27fe06f          	j	ffffffffc02075ac <stride_dequeue+0x13ac>
          r = a->left;
ffffffffc020878a:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020878e:	01083503          	ld	a0,16(a6)
ffffffffc0208792:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc0208794:	f842                	sd	a6,48(sp)
ffffffffc0208796:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208798:	869fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020879c:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020879e:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02087a0:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02087a4:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc02087a8:	e119                	bnez	a0,ffffffffc02087ae <stride_dequeue+0x25ae>
ffffffffc02087aa:	f37fe06f          	j	ffffffffc02076e0 <stride_dequeue+0x14e0>
ffffffffc02087ae:	01053023          	sd	a6,0(a0)
ffffffffc02087b2:	f2ffe06f          	j	ffffffffc02076e0 <stride_dequeue+0x14e0>
          r = a->left;
ffffffffc02087b6:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02087ba:	01083503          	ld	a0,16(a6)
ffffffffc02087be:	85e6                	mv	a1,s9
ffffffffc02087c0:	fc46                	sd	a7,56(sp)
          r = a->left;
ffffffffc02087c2:	f842                	sd	a6,48(sp)
ffffffffc02087c4:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02087c6:	83bfd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02087ca:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02087cc:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc02087ce:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc02087d0:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02087d4:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc02087d8:	c169                	beqz	a0,ffffffffc020889a <stride_dequeue+0x269a>
ffffffffc02087da:	01053023          	sd	a6,0(a0)
ffffffffc02087de:	8cc2                	mv	s9,a6
ffffffffc02087e0:	ba4ff06f          	j	ffffffffc0207b84 <stride_dequeue+0x1984>
          r = a->left;
ffffffffc02087e4:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02087e8:	01083503          	ld	a0,16(a6)
ffffffffc02087ec:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc02087ee:	f842                	sd	a6,48(sp)
ffffffffc02087f0:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02087f2:	80ffd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02087f6:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02087f8:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02087fa:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02087fe:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc0208802:	e119                	bnez	a0,ffffffffc0208808 <stride_dequeue+0x2608>
ffffffffc0208804:	e43fe06f          	j	ffffffffc0207646 <stride_dequeue+0x1446>
ffffffffc0208808:	01053023          	sd	a6,0(a0)
ffffffffc020880c:	e3bfe06f          	j	ffffffffc0207646 <stride_dequeue+0x1446>
          r = a->left;
ffffffffc0208810:	008d3303          	ld	t1,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208814:	010d3503          	ld	a0,16(s10)
ffffffffc0208818:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc020881a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020881c:	fe4fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208820:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208822:	00ad3423          	sd	a0,8(s10)
          if (l) l->parent = a;
ffffffffc0208826:	7642                	ld	a2,48(sp)
          a->right = r;
ffffffffc0208828:	006d3823          	sd	t1,16(s10)
          if (l) l->parent = a;
ffffffffc020882c:	e119                	bnez	a0,ffffffffc0208832 <stride_dequeue+0x2632>
ffffffffc020882e:	f4dfe06f          	j	ffffffffc020777a <stride_dequeue+0x157a>
ffffffffc0208832:	01a53023          	sd	s10,0(a0)
ffffffffc0208836:	f45fe06f          	j	ffffffffc020777a <stride_dequeue+0x157a>
          r = a->left;
ffffffffc020883a:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020883e:	0108b503          	ld	a0,16(a7)
ffffffffc0208842:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc0208844:	f846                	sd	a7,48(sp)
ffffffffc0208846:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208848:	fb8fd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020884c:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc020884e:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208850:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208854:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208858:	cd79                	beqz	a0,ffffffffc0208936 <stride_dequeue+0x2736>
ffffffffc020885a:	01153023          	sd	a7,0(a0)
ffffffffc020885e:	8846                	mv	a6,a7
ffffffffc0208860:	b82ff06f          	j	ffffffffc0207be2 <stride_dequeue+0x19e2>
          r = a->left;
ffffffffc0208864:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208868:	0108b503          	ld	a0,16(a7)
ffffffffc020886c:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc020886e:	f846                	sd	a7,48(sp)
ffffffffc0208870:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208872:	f8efd0ef          	jal	ra,ffffffffc0206000 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208876:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208878:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020887a:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020887e:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208882:	c115                	beqz	a0,ffffffffc02088a6 <stride_dequeue+0x26a6>
ffffffffc0208884:	01153023          	sd	a7,0(a0)
ffffffffc0208888:	8846                	mv	a6,a7
ffffffffc020888a:	c14ff06f          	j	ffffffffc0207c9e <stride_dequeue+0x1a9e>
ffffffffc020888e:	89be                	mv	s3,a5
ffffffffc0208890:	9deff06f          	j	ffffffffc0207a6e <stride_dequeue+0x186e>
          if (l) l->parent = b;
ffffffffc0208894:	8846                	mv	a6,a7
ffffffffc0208896:	db1fe06f          	j	ffffffffc0207646 <stride_dequeue+0x1446>
          if (l) l->parent = a;
ffffffffc020889a:	8cc2                	mv	s9,a6
ffffffffc020889c:	ae8ff06f          	j	ffffffffc0207b84 <stride_dequeue+0x1984>
ffffffffc02088a0:	8cc2                	mv	s9,a6
ffffffffc02088a2:	deaff06f          	j	ffffffffc0207e8c <stride_dequeue+0x1c8c>
ffffffffc02088a6:	8846                	mv	a6,a7
ffffffffc02088a8:	bf6ff06f          	j	ffffffffc0207c9e <stride_dequeue+0x1a9e>
          if (l) l->parent = b;
ffffffffc02088ac:	8cc6                	mv	s9,a7
ffffffffc02088ae:	ab8fe06f          	j	ffffffffc0206b66 <stride_dequeue+0x966>
ffffffffc02088b2:	8846                	mv	a6,a7
ffffffffc02088b4:	cf9fe06f          	j	ffffffffc02075ac <stride_dequeue+0x13ac>
          if (l) l->parent = a;
ffffffffc02088b8:	8cc2                	mv	s9,a6
ffffffffc02088ba:	b86ff06f          	j	ffffffffc0207c40 <stride_dequeue+0x1a40>
ffffffffc02088be:	8846                	mv	a6,a7
ffffffffc02088c0:	a66ff06f          	j	ffffffffc0207b26 <stride_dequeue+0x1926>
          if (l) l->parent = b;
ffffffffc02088c4:	8cc6                	mv	s9,a7
ffffffffc02088c6:	fdcfe06f          	j	ffffffffc02070a2 <stride_dequeue+0xea2>
          if (l) l->parent = a;
ffffffffc02088ca:	8a42                	mv	s4,a6
ffffffffc02088cc:	f19fe06f          	j	ffffffffc02077e4 <stride_dequeue+0x15e4>
          if (l) l->parent = b;
ffffffffc02088d0:	8846                	mv	a6,a7
ffffffffc02088d2:	c3ffe06f          	j	ffffffffc0207510 <stride_dequeue+0x1310>
          if (l) l->parent = a;
ffffffffc02088d6:	8d46                	mv	s10,a7
ffffffffc02088d8:	c94ff06f          	j	ffffffffc0207d6c <stride_dequeue+0x1b6c>
          if (l) l->parent = b;
ffffffffc02088dc:	8846                	mv	a6,a7
ffffffffc02088de:	e03fe06f          	j	ffffffffc02076e0 <stride_dequeue+0x14e0>
          if (l) l->parent = a;
ffffffffc02088e2:	8d3e                	mv	s10,a5
ffffffffc02088e4:	8e2ff06f          	j	ffffffffc02079c6 <stride_dequeue+0x17c6>
          if (l) l->parent = b;
ffffffffc02088e8:	8d46                	mv	s10,a7
ffffffffc02088ea:	ef2fe06f          	j	ffffffffc0206fdc <stride_dequeue+0xddc>
          if (l) l->parent = a;
ffffffffc02088ee:	8846                	mv	a6,a7
ffffffffc02088f0:	c0cff06f          	j	ffffffffc0207cfc <stride_dequeue+0x1afc>
          if (l) l->parent = b;
ffffffffc02088f4:	8846                	mv	a6,a7
ffffffffc02088f6:	b7ffe06f          	j	ffffffffc0207474 <stride_dequeue+0x1274>
          if (l) l->parent = a;
ffffffffc02088fa:	87c6                	mv	a5,a7
ffffffffc02088fc:	f9dfe06f          	j	ffffffffc0207898 <stride_dequeue+0x1698>
ffffffffc0208900:	8846                	mv	a6,a7
ffffffffc0208902:	f41fe06f          	j	ffffffffc0207842 <stride_dequeue+0x1642>
ffffffffc0208906:	87c6                	mv	a5,a7
ffffffffc0208908:	cbcff06f          	j	ffffffffc0207dc4 <stride_dequeue+0x1bc4>
ffffffffc020890c:	87c6                	mv	a5,a7
ffffffffc020890e:	fe1fe06f          	j	ffffffffc02078ee <stride_dequeue+0x16ee>
ffffffffc0208912:	8d3e                	mv	s10,a5
ffffffffc0208914:	906ff06f          	j	ffffffffc0207a1a <stride_dequeue+0x181a>
          if (l) l->parent = b;
ffffffffc0208918:	8cc6                	mv	s9,a7
ffffffffc020891a:	dfcfe06f          	j	ffffffffc0206f16 <stride_dequeue+0xd16>
          if (l) l->parent = a;
ffffffffc020891e:	89c2                	mv	s3,a6
ffffffffc0208920:	d02ff06f          	j	ffffffffc0207e22 <stride_dequeue+0x1c22>
ffffffffc0208924:	8846                	mv	a6,a7
ffffffffc0208926:	824ff06f          	j	ffffffffc020794a <stride_dequeue+0x174a>
ffffffffc020892a:	8d3e                	mv	s10,a5
ffffffffc020892c:	996ff06f          	j	ffffffffc0207ac2 <stride_dequeue+0x18c2>
          if (l) l->parent = b;
ffffffffc0208930:	8d46                	mv	s10,a7
ffffffffc0208932:	e49fe06f          	j	ffffffffc020777a <stride_dequeue+0x157a>
          if (l) l->parent = a;
ffffffffc0208936:	8846                	mv	a6,a7
ffffffffc0208938:	aaaff06f          	j	ffffffffc0207be2 <stride_dequeue+0x19e2>

ffffffffc020893c <sched_class_proc_tick>:
    return sched_class->pick_next(rq);
}

void
sched_class_proc_tick(struct proc_struct *proc) {
    if (proc != idleproc) {
ffffffffc020893c:	000c1797          	auipc	a5,0xc1
ffffffffc0208940:	88478793          	addi	a5,a5,-1916 # ffffffffc02c91c0 <idleproc>
ffffffffc0208944:	639c                	ld	a5,0(a5)
sched_class_proc_tick(struct proc_struct *proc) {
ffffffffc0208946:	85aa                	mv	a1,a0
    if (proc != idleproc) {
ffffffffc0208948:	00a78f63          	beq	a5,a0,ffffffffc0208966 <sched_class_proc_tick+0x2a>
        sched_class->proc_tick(rq, proc);
ffffffffc020894c:	000c1797          	auipc	a5,0xc1
ffffffffc0208950:	89478793          	addi	a5,a5,-1900 # ffffffffc02c91e0 <sched_class>
ffffffffc0208954:	639c                	ld	a5,0(a5)
ffffffffc0208956:	000c1717          	auipc	a4,0xc1
ffffffffc020895a:	88270713          	addi	a4,a4,-1918 # ffffffffc02c91d8 <rq>
ffffffffc020895e:	6308                	ld	a0,0(a4)
ffffffffc0208960:	0287b303          	ld	t1,40(a5)
ffffffffc0208964:	8302                	jr	t1
    }
    else {
        proc->need_resched = 1;
ffffffffc0208966:	4705                	li	a4,1
ffffffffc0208968:	ef98                	sd	a4,24(a5)
    }
}
ffffffffc020896a:	8082                	ret

ffffffffc020896c <sched_init>:

static struct run_queue __rq;

void
sched_init(void) {
ffffffffc020896c:	1141                	addi	sp,sp,-16
    list_init(&timer_list);

    sched_class = &default_sched_class;
ffffffffc020896e:	000b5697          	auipc	a3,0xb5
ffffffffc0208972:	3aa68693          	addi	a3,a3,938 # ffffffffc02bdd18 <default_sched_class>
sched_init(void) {
ffffffffc0208976:	e022                	sd	s0,0(sp)
ffffffffc0208978:	e406                	sd	ra,8(sp)
ffffffffc020897a:	000c0797          	auipc	a5,0xc0
ffffffffc020897e:	7fe78793          	addi	a5,a5,2046 # ffffffffc02c9178 <timer_list>

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc0208982:	6690                	ld	a2,8(a3)
    rq = &__rq;
ffffffffc0208984:	000c0717          	auipc	a4,0xc0
ffffffffc0208988:	7d470713          	addi	a4,a4,2004 # ffffffffc02c9158 <__rq>
ffffffffc020898c:	e79c                	sd	a5,8(a5)
ffffffffc020898e:	e39c                	sd	a5,0(a5)
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc0208990:	4795                	li	a5,5
    sched_class = &default_sched_class;
ffffffffc0208992:	000c1417          	auipc	s0,0xc1
ffffffffc0208996:	84e40413          	addi	s0,s0,-1970 # ffffffffc02c91e0 <sched_class>
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc020899a:	cb5c                	sw	a5,20(a4)
    sched_class->init(rq);
ffffffffc020899c:	853a                	mv	a0,a4
    sched_class = &default_sched_class;
ffffffffc020899e:	e014                	sd	a3,0(s0)
    rq = &__rq;
ffffffffc02089a0:	000c1797          	auipc	a5,0xc1
ffffffffc02089a4:	82e7bc23          	sd	a4,-1992(a5) # ffffffffc02c91d8 <rq>
    sched_class->init(rq);
ffffffffc02089a8:	9602                	jalr	a2

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02089aa:	601c                	ld	a5,0(s0)
}
ffffffffc02089ac:	6402                	ld	s0,0(sp)
ffffffffc02089ae:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02089b0:	638c                	ld	a1,0(a5)
ffffffffc02089b2:	00003517          	auipc	a0,0x3
ffffffffc02089b6:	a2650513          	addi	a0,a0,-1498 # ffffffffc020b3d8 <default_pmm_manager+0x1578>
}
ffffffffc02089ba:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02089bc:	fd6f706f          	j	ffffffffc0200192 <cprintf>

ffffffffc02089c0 <wakeup_proc>:

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02089c0:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc02089c2:	1101                	addi	sp,sp,-32
ffffffffc02089c4:	ec06                	sd	ra,24(sp)
ffffffffc02089c6:	e822                	sd	s0,16(sp)
ffffffffc02089c8:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02089ca:	478d                	li	a5,3
ffffffffc02089cc:	08f70763          	beq	a4,a5,ffffffffc0208a5a <wakeup_proc+0x9a>
ffffffffc02089d0:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02089d2:	100027f3          	csrr	a5,sstatus
ffffffffc02089d6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02089d8:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02089da:	ebbd                	bnez	a5,ffffffffc0208a50 <wakeup_proc+0x90>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02089dc:	4789                	li	a5,2
ffffffffc02089de:	04f70c63          	beq	a4,a5,ffffffffc0208a36 <wakeup_proc+0x76>
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
            if (proc != current) {
ffffffffc02089e2:	000c0717          	auipc	a4,0xc0
ffffffffc02089e6:	7d670713          	addi	a4,a4,2006 # ffffffffc02c91b8 <current>
ffffffffc02089ea:	6318                	ld	a4,0(a4)
            proc->wait_state = 0;
ffffffffc02089ec:	0e042623          	sw	zero,236(s0)
            proc->state = PROC_RUNNABLE;
ffffffffc02089f0:	c01c                	sw	a5,0(s0)
            if (proc != current) {
ffffffffc02089f2:	02870663          	beq	a4,s0,ffffffffc0208a1e <wakeup_proc+0x5e>
    if (proc != idleproc) {
ffffffffc02089f6:	000c0797          	auipc	a5,0xc0
ffffffffc02089fa:	7ca78793          	addi	a5,a5,1994 # ffffffffc02c91c0 <idleproc>
ffffffffc02089fe:	639c                	ld	a5,0(a5)
ffffffffc0208a00:	00f40f63          	beq	s0,a5,ffffffffc0208a1e <wakeup_proc+0x5e>
        sched_class->enqueue(rq, proc);
ffffffffc0208a04:	000c0797          	auipc	a5,0xc0
ffffffffc0208a08:	7dc78793          	addi	a5,a5,2012 # ffffffffc02c91e0 <sched_class>
ffffffffc0208a0c:	639c                	ld	a5,0(a5)
ffffffffc0208a0e:	000c0717          	auipc	a4,0xc0
ffffffffc0208a12:	7ca70713          	addi	a4,a4,1994 # ffffffffc02c91d8 <rq>
ffffffffc0208a16:	6308                	ld	a0,0(a4)
ffffffffc0208a18:	6b9c                	ld	a5,16(a5)
ffffffffc0208a1a:	85a2                	mv	a1,s0
ffffffffc0208a1c:	9782                	jalr	a5
    if (flag) {
ffffffffc0208a1e:	e491                	bnez	s1,ffffffffc0208a2a <wakeup_proc+0x6a>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0208a20:	60e2                	ld	ra,24(sp)
ffffffffc0208a22:	6442                	ld	s0,16(sp)
ffffffffc0208a24:	64a2                	ld	s1,8(sp)
ffffffffc0208a26:	6105                	addi	sp,sp,32
ffffffffc0208a28:	8082                	ret
ffffffffc0208a2a:	6442                	ld	s0,16(sp)
ffffffffc0208a2c:	60e2                	ld	ra,24(sp)
ffffffffc0208a2e:	64a2                	ld	s1,8(sp)
ffffffffc0208a30:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0208a32:	c1bf706f          	j	ffffffffc020064c <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0208a36:	00003617          	auipc	a2,0x3
ffffffffc0208a3a:	9f260613          	addi	a2,a2,-1550 # ffffffffc020b428 <default_pmm_manager+0x15c8>
ffffffffc0208a3e:	04800593          	li	a1,72
ffffffffc0208a42:	00003517          	auipc	a0,0x3
ffffffffc0208a46:	9ce50513          	addi	a0,a0,-1586 # ffffffffc020b410 <default_pmm_manager+0x15b0>
ffffffffc0208a4a:	aabf70ef          	jal	ra,ffffffffc02004f4 <__warn>
ffffffffc0208a4e:	bfc1                	j	ffffffffc0208a1e <wakeup_proc+0x5e>
        intr_disable();
ffffffffc0208a50:	c03f70ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0208a54:	4018                	lw	a4,0(s0)
ffffffffc0208a56:	4485                	li	s1,1
ffffffffc0208a58:	b751                	j	ffffffffc02089dc <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0208a5a:	00003697          	auipc	a3,0x3
ffffffffc0208a5e:	99668693          	addi	a3,a3,-1642 # ffffffffc020b3f0 <default_pmm_manager+0x1590>
ffffffffc0208a62:	00001617          	auipc	a2,0x1
ffffffffc0208a66:	cb660613          	addi	a2,a2,-842 # ffffffffc0209718 <commands+0x4c0>
ffffffffc0208a6a:	03c00593          	li	a1,60
ffffffffc0208a6e:	00003517          	auipc	a0,0x3
ffffffffc0208a72:	9a250513          	addi	a0,a0,-1630 # ffffffffc020b410 <default_pmm_manager+0x15b0>
ffffffffc0208a76:	a13f70ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0208a7a <schedule>:

void
schedule(void) {
ffffffffc0208a7a:	7179                	addi	sp,sp,-48
ffffffffc0208a7c:	f406                	sd	ra,40(sp)
ffffffffc0208a7e:	f022                	sd	s0,32(sp)
ffffffffc0208a80:	ec26                	sd	s1,24(sp)
ffffffffc0208a82:	e84a                	sd	s2,16(sp)
ffffffffc0208a84:	e44e                	sd	s3,8(sp)
ffffffffc0208a86:	e052                	sd	s4,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0208a88:	100027f3          	csrr	a5,sstatus
ffffffffc0208a8c:	8b89                	andi	a5,a5,2
ffffffffc0208a8e:	4a01                	li	s4,0
ffffffffc0208a90:	e7d5                	bnez	a5,ffffffffc0208b3c <schedule+0xc2>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0208a92:	000c0497          	auipc	s1,0xc0
ffffffffc0208a96:	72648493          	addi	s1,s1,1830 # ffffffffc02c91b8 <current>
ffffffffc0208a9a:	608c                	ld	a1,0(s1)
ffffffffc0208a9c:	000c0997          	auipc	s3,0xc0
ffffffffc0208aa0:	74498993          	addi	s3,s3,1860 # ffffffffc02c91e0 <sched_class>
ffffffffc0208aa4:	000c0917          	auipc	s2,0xc0
ffffffffc0208aa8:	73490913          	addi	s2,s2,1844 # ffffffffc02c91d8 <rq>
        if (current->state == PROC_RUNNABLE) {
ffffffffc0208aac:	4194                	lw	a3,0(a1)
        current->need_resched = 0;
ffffffffc0208aae:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE) {
ffffffffc0208ab2:	4709                	li	a4,2
ffffffffc0208ab4:	0009b783          	ld	a5,0(s3)
ffffffffc0208ab8:	00093503          	ld	a0,0(s2)
ffffffffc0208abc:	04e68063          	beq	a3,a4,ffffffffc0208afc <schedule+0x82>
    return sched_class->pick_next(rq);
ffffffffc0208ac0:	739c                	ld	a5,32(a5)
ffffffffc0208ac2:	9782                	jalr	a5
ffffffffc0208ac4:	842a                	mv	s0,a0
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL) {
ffffffffc0208ac6:	cd21                	beqz	a0,ffffffffc0208b1e <schedule+0xa4>
    sched_class->dequeue(rq, proc);
ffffffffc0208ac8:	0009b783          	ld	a5,0(s3)
ffffffffc0208acc:	00093503          	ld	a0,0(s2)
ffffffffc0208ad0:	85a2                	mv	a1,s0
ffffffffc0208ad2:	6f9c                	ld	a5,24(a5)
ffffffffc0208ad4:	9782                	jalr	a5
            sched_class_dequeue(next);
        }
        if (next == NULL) {
            next = idleproc;
        }
        next->runs ++;
ffffffffc0208ad6:	441c                	lw	a5,8(s0)
        if (next != current) {
ffffffffc0208ad8:	6098                	ld	a4,0(s1)
        next->runs ++;
ffffffffc0208ada:	2785                	addiw	a5,a5,1
ffffffffc0208adc:	c41c                	sw	a5,8(s0)
        if (next != current) {
ffffffffc0208ade:	00870563          	beq	a4,s0,ffffffffc0208ae8 <schedule+0x6e>
            proc_run(next);
ffffffffc0208ae2:	8522                	mv	a0,s0
ffffffffc0208ae4:	bfcfc0ef          	jal	ra,ffffffffc0204ee0 <proc_run>
    if (flag) {
ffffffffc0208ae8:	040a1163          	bnez	s4,ffffffffc0208b2a <schedule+0xb0>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0208aec:	70a2                	ld	ra,40(sp)
ffffffffc0208aee:	7402                	ld	s0,32(sp)
ffffffffc0208af0:	64e2                	ld	s1,24(sp)
ffffffffc0208af2:	6942                	ld	s2,16(sp)
ffffffffc0208af4:	69a2                	ld	s3,8(sp)
ffffffffc0208af6:	6a02                	ld	s4,0(sp)
ffffffffc0208af8:	6145                	addi	sp,sp,48
ffffffffc0208afa:	8082                	ret
    if (proc != idleproc) {
ffffffffc0208afc:	000c0717          	auipc	a4,0xc0
ffffffffc0208b00:	6c470713          	addi	a4,a4,1732 # ffffffffc02c91c0 <idleproc>
ffffffffc0208b04:	6318                	ld	a4,0(a4)
ffffffffc0208b06:	fae58de3          	beq	a1,a4,ffffffffc0208ac0 <schedule+0x46>
        sched_class->enqueue(rq, proc);
ffffffffc0208b0a:	6b9c                	ld	a5,16(a5)
ffffffffc0208b0c:	9782                	jalr	a5
ffffffffc0208b0e:	0009b783          	ld	a5,0(s3)
ffffffffc0208b12:	00093503          	ld	a0,0(s2)
    return sched_class->pick_next(rq);
ffffffffc0208b16:	739c                	ld	a5,32(a5)
ffffffffc0208b18:	9782                	jalr	a5
ffffffffc0208b1a:	842a                	mv	s0,a0
        if ((next = sched_class_pick_next()) != NULL) {
ffffffffc0208b1c:	f555                	bnez	a0,ffffffffc0208ac8 <schedule+0x4e>
            next = idleproc;
ffffffffc0208b1e:	000c0797          	auipc	a5,0xc0
ffffffffc0208b22:	6a278793          	addi	a5,a5,1698 # ffffffffc02c91c0 <idleproc>
ffffffffc0208b26:	6380                	ld	s0,0(a5)
ffffffffc0208b28:	b77d                	j	ffffffffc0208ad6 <schedule+0x5c>
}
ffffffffc0208b2a:	7402                	ld	s0,32(sp)
ffffffffc0208b2c:	70a2                	ld	ra,40(sp)
ffffffffc0208b2e:	64e2                	ld	s1,24(sp)
ffffffffc0208b30:	6942                	ld	s2,16(sp)
ffffffffc0208b32:	69a2                	ld	s3,8(sp)
ffffffffc0208b34:	6a02                	ld	s4,0(sp)
ffffffffc0208b36:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0208b38:	b15f706f          	j	ffffffffc020064c <intr_enable>
        intr_disable();
ffffffffc0208b3c:	b17f70ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0208b40:	4a05                	li	s4,1
ffffffffc0208b42:	bf81                	j	ffffffffc0208a92 <schedule+0x18>

ffffffffc0208b44 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0208b44:	000c0797          	auipc	a5,0xc0
ffffffffc0208b48:	67478793          	addi	a5,a5,1652 # ffffffffc02c91b8 <current>
ffffffffc0208b4c:	639c                	ld	a5,0(a5)
}
ffffffffc0208b4e:	43c8                	lw	a0,4(a5)
ffffffffc0208b50:	8082                	ret

ffffffffc0208b52 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0208b52:	4501                	li	a0,0
ffffffffc0208b54:	8082                	ret

ffffffffc0208b56 <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc0208b56:	000c0797          	auipc	a5,0xc0
ffffffffc0208b5a:	69278793          	addi	a5,a5,1682 # ffffffffc02c91e8 <ticks>
ffffffffc0208b5e:	639c                	ld	a5,0(a5)
ffffffffc0208b60:	0027951b          	slliw	a0,a5,0x2
ffffffffc0208b64:	9d3d                	addw	a0,a0,a5
}
ffffffffc0208b66:	0015151b          	slliw	a0,a0,0x1
ffffffffc0208b6a:	8082                	ret

ffffffffc0208b6c <sys_lab6_set_priority>:
static int sys_lab6_set_priority(uint64_t arg[]){
    uint64_t priority = (uint64_t)arg[0];
    lab6_set_priority(priority);
ffffffffc0208b6c:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc0208b6e:	1141                	addi	sp,sp,-16
ffffffffc0208b70:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc0208b72:	b82fd0ef          	jal	ra,ffffffffc0205ef4 <lab6_set_priority>
    return 0;
}
ffffffffc0208b76:	60a2                	ld	ra,8(sp)
ffffffffc0208b78:	4501                	li	a0,0
ffffffffc0208b7a:	0141                	addi	sp,sp,16
ffffffffc0208b7c:	8082                	ret

ffffffffc0208b7e <sys_putc>:
    cputchar(c);
ffffffffc0208b7e:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0208b80:	1141                	addi	sp,sp,-16
ffffffffc0208b82:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0208b84:	e42f70ef          	jal	ra,ffffffffc02001c6 <cputchar>
}
ffffffffc0208b88:	60a2                	ld	ra,8(sp)
ffffffffc0208b8a:	4501                	li	a0,0
ffffffffc0208b8c:	0141                	addi	sp,sp,16
ffffffffc0208b8e:	8082                	ret

ffffffffc0208b90 <sys_kill>:
    return do_kill(pid);
ffffffffc0208b90:	4108                	lw	a0,0(a0)
ffffffffc0208b92:	9b4fd06f          	j	ffffffffc0205d46 <do_kill>

ffffffffc0208b96 <sys_yield>:
    return do_yield();
ffffffffc0208b96:	95efd06f          	j	ffffffffc0205cf4 <do_yield>

ffffffffc0208b9a <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0208b9a:	6d14                	ld	a3,24(a0)
ffffffffc0208b9c:	6910                	ld	a2,16(a0)
ffffffffc0208b9e:	650c                	ld	a1,8(a0)
ffffffffc0208ba0:	6108                	ld	a0,0(a0)
ffffffffc0208ba2:	c51fc06f          	j	ffffffffc02057f2 <do_execve>

ffffffffc0208ba6 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0208ba6:	650c                	ld	a1,8(a0)
ffffffffc0208ba8:	4108                	lw	a0,0(a0)
ffffffffc0208baa:	95cfd06f          	j	ffffffffc0205d06 <do_wait>

ffffffffc0208bae <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0208bae:	000c0797          	auipc	a5,0xc0
ffffffffc0208bb2:	60a78793          	addi	a5,a5,1546 # ffffffffc02c91b8 <current>
ffffffffc0208bb6:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0208bb8:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0208bba:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0208bbc:	6a0c                	ld	a1,16(a2)
ffffffffc0208bbe:	beafc06f          	j	ffffffffc0204fa8 <do_fork>

ffffffffc0208bc2 <sys_exit>:
    return do_exit(error_code);
ffffffffc0208bc2:	4108                	lw	a0,0(a0)
ffffffffc0208bc4:	811fc06f          	j	ffffffffc02053d4 <do_exit>

ffffffffc0208bc8 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0208bc8:	715d                	addi	sp,sp,-80
ffffffffc0208bca:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0208bcc:	000c0497          	auipc	s1,0xc0
ffffffffc0208bd0:	5ec48493          	addi	s1,s1,1516 # ffffffffc02c91b8 <current>
ffffffffc0208bd4:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0208bd6:	e0a2                	sd	s0,64(sp)
ffffffffc0208bd8:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0208bda:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0208bdc:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0208bde:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc0208be2:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0208be6:	0327ee63          	bltu	a5,s2,ffffffffc0208c22 <syscall+0x5a>
        if (syscalls[num] != NULL) {
ffffffffc0208bea:	00391713          	slli	a4,s2,0x3
ffffffffc0208bee:	00003797          	auipc	a5,0x3
ffffffffc0208bf2:	8a278793          	addi	a5,a5,-1886 # ffffffffc020b490 <syscalls>
ffffffffc0208bf6:	97ba                	add	a5,a5,a4
ffffffffc0208bf8:	639c                	ld	a5,0(a5)
ffffffffc0208bfa:	c785                	beqz	a5,ffffffffc0208c22 <syscall+0x5a>
            arg[0] = tf->gpr.a1;
ffffffffc0208bfc:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0208bfe:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0208c00:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0208c02:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0208c04:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0208c06:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0208c08:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0208c0a:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0208c0c:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0208c0e:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0208c10:	0028                	addi	a0,sp,8
ffffffffc0208c12:	9782                	jalr	a5
ffffffffc0208c14:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0208c16:	60a6                	ld	ra,72(sp)
ffffffffc0208c18:	6406                	ld	s0,64(sp)
ffffffffc0208c1a:	74e2                	ld	s1,56(sp)
ffffffffc0208c1c:	7942                	ld	s2,48(sp)
ffffffffc0208c1e:	6161                	addi	sp,sp,80
ffffffffc0208c20:	8082                	ret
    print_trapframe(tf);
ffffffffc0208c22:	8522                	mv	a0,s0
ffffffffc0208c24:	c1ff70ef          	jal	ra,ffffffffc0200842 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0208c28:	609c                	ld	a5,0(s1)
ffffffffc0208c2a:	86ca                	mv	a3,s2
ffffffffc0208c2c:	00003617          	auipc	a2,0x3
ffffffffc0208c30:	81c60613          	addi	a2,a2,-2020 # ffffffffc020b448 <default_pmm_manager+0x15e8>
ffffffffc0208c34:	43d8                	lw	a4,4(a5)
ffffffffc0208c36:	06d00593          	li	a1,109
ffffffffc0208c3a:	0b478793          	addi	a5,a5,180
ffffffffc0208c3e:	00003517          	auipc	a0,0x3
ffffffffc0208c42:	83a50513          	addi	a0,a0,-1990 # ffffffffc020b478 <default_pmm_manager+0x1618>
ffffffffc0208c46:	843f70ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0208c4a <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0208c4a:	9e3707b7          	lui	a5,0x9e370
ffffffffc0208c4e:	2785                	addiw	a5,a5,1
ffffffffc0208c50:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0208c54:	02000793          	li	a5,32
ffffffffc0208c58:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0208c5c:	00b5553b          	srlw	a0,a0,a1
ffffffffc0208c60:	8082                	ret

ffffffffc0208c62 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0208c62:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0208c66:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0208c68:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0208c6c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0208c6e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0208c72:	f022                	sd	s0,32(sp)
ffffffffc0208c74:	ec26                	sd	s1,24(sp)
ffffffffc0208c76:	e84a                	sd	s2,16(sp)
ffffffffc0208c78:	f406                	sd	ra,40(sp)
ffffffffc0208c7a:	e44e                	sd	s3,8(sp)
ffffffffc0208c7c:	84aa                	mv	s1,a0
ffffffffc0208c7e:	892e                	mv	s2,a1
ffffffffc0208c80:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0208c84:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0208c86:	03067e63          	bleu	a6,a2,ffffffffc0208cc2 <printnum+0x60>
ffffffffc0208c8a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0208c8c:	00805763          	blez	s0,ffffffffc0208c9a <printnum+0x38>
ffffffffc0208c90:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0208c92:	85ca                	mv	a1,s2
ffffffffc0208c94:	854e                	mv	a0,s3
ffffffffc0208c96:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0208c98:	fc65                	bnez	s0,ffffffffc0208c90 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0208c9a:	1a02                	slli	s4,s4,0x20
ffffffffc0208c9c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0208ca0:	00003797          	auipc	a5,0x3
ffffffffc0208ca4:	21078793          	addi	a5,a5,528 # ffffffffc020beb0 <error_string+0xc8>
ffffffffc0208ca8:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0208caa:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0208cac:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0208cb0:	70a2                	ld	ra,40(sp)
ffffffffc0208cb2:	69a2                	ld	s3,8(sp)
ffffffffc0208cb4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0208cb6:	85ca                	mv	a1,s2
ffffffffc0208cb8:	8326                	mv	t1,s1
}
ffffffffc0208cba:	6942                	ld	s2,16(sp)
ffffffffc0208cbc:	64e2                	ld	s1,24(sp)
ffffffffc0208cbe:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0208cc0:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0208cc2:	03065633          	divu	a2,a2,a6
ffffffffc0208cc6:	8722                	mv	a4,s0
ffffffffc0208cc8:	f9bff0ef          	jal	ra,ffffffffc0208c62 <printnum>
ffffffffc0208ccc:	b7f9                	j	ffffffffc0208c9a <printnum+0x38>

ffffffffc0208cce <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0208cce:	7119                	addi	sp,sp,-128
ffffffffc0208cd0:	f4a6                	sd	s1,104(sp)
ffffffffc0208cd2:	f0ca                	sd	s2,96(sp)
ffffffffc0208cd4:	e8d2                	sd	s4,80(sp)
ffffffffc0208cd6:	e4d6                	sd	s5,72(sp)
ffffffffc0208cd8:	e0da                	sd	s6,64(sp)
ffffffffc0208cda:	fc5e                	sd	s7,56(sp)
ffffffffc0208cdc:	f862                	sd	s8,48(sp)
ffffffffc0208cde:	f06a                	sd	s10,32(sp)
ffffffffc0208ce0:	fc86                	sd	ra,120(sp)
ffffffffc0208ce2:	f8a2                	sd	s0,112(sp)
ffffffffc0208ce4:	ecce                	sd	s3,88(sp)
ffffffffc0208ce6:	f466                	sd	s9,40(sp)
ffffffffc0208ce8:	ec6e                	sd	s11,24(sp)
ffffffffc0208cea:	892a                	mv	s2,a0
ffffffffc0208cec:	84ae                	mv	s1,a1
ffffffffc0208cee:	8d32                	mv	s10,a2
ffffffffc0208cf0:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0208cf2:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208cf4:	00003a17          	auipc	s4,0x3
ffffffffc0208cf8:	f9ca0a13          	addi	s4,s4,-100 # ffffffffc020bc90 <syscalls+0x800>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0208cfc:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0208d00:	00003c17          	auipc	s8,0x3
ffffffffc0208d04:	0e8c0c13          	addi	s8,s8,232 # ffffffffc020bde8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0208d08:	000d4503          	lbu	a0,0(s10)
ffffffffc0208d0c:	02500793          	li	a5,37
ffffffffc0208d10:	001d0413          	addi	s0,s10,1
ffffffffc0208d14:	00f50e63          	beq	a0,a5,ffffffffc0208d30 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0208d18:	c521                	beqz	a0,ffffffffc0208d60 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0208d1a:	02500993          	li	s3,37
ffffffffc0208d1e:	a011                	j	ffffffffc0208d22 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0208d20:	c121                	beqz	a0,ffffffffc0208d60 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0208d22:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0208d24:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0208d26:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0208d28:	fff44503          	lbu	a0,-1(s0)
ffffffffc0208d2c:	ff351ae3          	bne	a0,s3,ffffffffc0208d20 <vprintfmt+0x52>
ffffffffc0208d30:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0208d34:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0208d38:	4981                	li	s3,0
ffffffffc0208d3a:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0208d3c:	5cfd                	li	s9,-1
ffffffffc0208d3e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208d40:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0208d44:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208d46:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0208d4a:	0ff6f693          	andi	a3,a3,255
ffffffffc0208d4e:	00140d13          	addi	s10,s0,1
ffffffffc0208d52:	20d5e563          	bltu	a1,a3,ffffffffc0208f5c <vprintfmt+0x28e>
ffffffffc0208d56:	068a                	slli	a3,a3,0x2
ffffffffc0208d58:	96d2                	add	a3,a3,s4
ffffffffc0208d5a:	4294                	lw	a3,0(a3)
ffffffffc0208d5c:	96d2                	add	a3,a3,s4
ffffffffc0208d5e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0208d60:	70e6                	ld	ra,120(sp)
ffffffffc0208d62:	7446                	ld	s0,112(sp)
ffffffffc0208d64:	74a6                	ld	s1,104(sp)
ffffffffc0208d66:	7906                	ld	s2,96(sp)
ffffffffc0208d68:	69e6                	ld	s3,88(sp)
ffffffffc0208d6a:	6a46                	ld	s4,80(sp)
ffffffffc0208d6c:	6aa6                	ld	s5,72(sp)
ffffffffc0208d6e:	6b06                	ld	s6,64(sp)
ffffffffc0208d70:	7be2                	ld	s7,56(sp)
ffffffffc0208d72:	7c42                	ld	s8,48(sp)
ffffffffc0208d74:	7ca2                	ld	s9,40(sp)
ffffffffc0208d76:	7d02                	ld	s10,32(sp)
ffffffffc0208d78:	6de2                	ld	s11,24(sp)
ffffffffc0208d7a:	6109                	addi	sp,sp,128
ffffffffc0208d7c:	8082                	ret
    if (lflag >= 2) {
ffffffffc0208d7e:	4705                	li	a4,1
ffffffffc0208d80:	008a8593          	addi	a1,s5,8
ffffffffc0208d84:	01074463          	blt	a4,a6,ffffffffc0208d8c <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0208d88:	26080363          	beqz	a6,ffffffffc0208fee <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0208d8c:	000ab603          	ld	a2,0(s5)
ffffffffc0208d90:	46c1                	li	a3,16
ffffffffc0208d92:	8aae                	mv	s5,a1
ffffffffc0208d94:	a06d                	j	ffffffffc0208e3e <vprintfmt+0x170>
            goto reswitch;
ffffffffc0208d96:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0208d9a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208d9c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0208d9e:	b765                	j	ffffffffc0208d46 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0208da0:	000aa503          	lw	a0,0(s5)
ffffffffc0208da4:	85a6                	mv	a1,s1
ffffffffc0208da6:	0aa1                	addi	s5,s5,8
ffffffffc0208da8:	9902                	jalr	s2
            break;
ffffffffc0208daa:	bfb9                	j	ffffffffc0208d08 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0208dac:	4705                	li	a4,1
ffffffffc0208dae:	008a8993          	addi	s3,s5,8
ffffffffc0208db2:	01074463          	blt	a4,a6,ffffffffc0208dba <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0208db6:	22080463          	beqz	a6,ffffffffc0208fde <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0208dba:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0208dbe:	24044463          	bltz	s0,ffffffffc0209006 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0208dc2:	8622                	mv	a2,s0
ffffffffc0208dc4:	8ace                	mv	s5,s3
ffffffffc0208dc6:	46a9                	li	a3,10
ffffffffc0208dc8:	a89d                	j	ffffffffc0208e3e <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0208dca:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0208dce:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0208dd0:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0208dd2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0208dd6:	8fb5                	xor	a5,a5,a3
ffffffffc0208dd8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0208ddc:	1ad74363          	blt	a4,a3,ffffffffc0208f82 <vprintfmt+0x2b4>
ffffffffc0208de0:	00369793          	slli	a5,a3,0x3
ffffffffc0208de4:	97e2                	add	a5,a5,s8
ffffffffc0208de6:	639c                	ld	a5,0(a5)
ffffffffc0208de8:	18078d63          	beqz	a5,ffffffffc0208f82 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0208dec:	86be                	mv	a3,a5
ffffffffc0208dee:	00000617          	auipc	a2,0x0
ffffffffc0208df2:	36260613          	addi	a2,a2,866 # ffffffffc0209150 <etext+0x2e>
ffffffffc0208df6:	85a6                	mv	a1,s1
ffffffffc0208df8:	854a                	mv	a0,s2
ffffffffc0208dfa:	240000ef          	jal	ra,ffffffffc020903a <printfmt>
ffffffffc0208dfe:	b729                	j	ffffffffc0208d08 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0208e00:	00144603          	lbu	a2,1(s0)
ffffffffc0208e04:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208e06:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0208e08:	bf3d                	j	ffffffffc0208d46 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0208e0a:	4705                	li	a4,1
ffffffffc0208e0c:	008a8593          	addi	a1,s5,8
ffffffffc0208e10:	01074463          	blt	a4,a6,ffffffffc0208e18 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0208e14:	1e080263          	beqz	a6,ffffffffc0208ff8 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0208e18:	000ab603          	ld	a2,0(s5)
ffffffffc0208e1c:	46a1                	li	a3,8
ffffffffc0208e1e:	8aae                	mv	s5,a1
ffffffffc0208e20:	a839                	j	ffffffffc0208e3e <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0208e22:	03000513          	li	a0,48
ffffffffc0208e26:	85a6                	mv	a1,s1
ffffffffc0208e28:	e03e                	sd	a5,0(sp)
ffffffffc0208e2a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0208e2c:	85a6                	mv	a1,s1
ffffffffc0208e2e:	07800513          	li	a0,120
ffffffffc0208e32:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0208e34:	0aa1                	addi	s5,s5,8
ffffffffc0208e36:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0208e3a:	6782                	ld	a5,0(sp)
ffffffffc0208e3c:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0208e3e:	876e                	mv	a4,s11
ffffffffc0208e40:	85a6                	mv	a1,s1
ffffffffc0208e42:	854a                	mv	a0,s2
ffffffffc0208e44:	e1fff0ef          	jal	ra,ffffffffc0208c62 <printnum>
            break;
ffffffffc0208e48:	b5c1                	j	ffffffffc0208d08 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0208e4a:	000ab603          	ld	a2,0(s5)
ffffffffc0208e4e:	0aa1                	addi	s5,s5,8
ffffffffc0208e50:	1c060663          	beqz	a2,ffffffffc020901c <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0208e54:	00160413          	addi	s0,a2,1
ffffffffc0208e58:	17b05c63          	blez	s11,ffffffffc0208fd0 <vprintfmt+0x302>
ffffffffc0208e5c:	02d00593          	li	a1,45
ffffffffc0208e60:	14b79263          	bne	a5,a1,ffffffffc0208fa4 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0208e64:	00064783          	lbu	a5,0(a2)
ffffffffc0208e68:	0007851b          	sext.w	a0,a5
ffffffffc0208e6c:	c905                	beqz	a0,ffffffffc0208e9c <vprintfmt+0x1ce>
ffffffffc0208e6e:	000cc563          	bltz	s9,ffffffffc0208e78 <vprintfmt+0x1aa>
ffffffffc0208e72:	3cfd                	addiw	s9,s9,-1
ffffffffc0208e74:	036c8263          	beq	s9,s6,ffffffffc0208e98 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0208e78:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0208e7a:	18098463          	beqz	s3,ffffffffc0209002 <vprintfmt+0x334>
ffffffffc0208e7e:	3781                	addiw	a5,a5,-32
ffffffffc0208e80:	18fbf163          	bleu	a5,s7,ffffffffc0209002 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0208e84:	03f00513          	li	a0,63
ffffffffc0208e88:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0208e8a:	0405                	addi	s0,s0,1
ffffffffc0208e8c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0208e90:	3dfd                	addiw	s11,s11,-1
ffffffffc0208e92:	0007851b          	sext.w	a0,a5
ffffffffc0208e96:	fd61                	bnez	a0,ffffffffc0208e6e <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0208e98:	e7b058e3          	blez	s11,ffffffffc0208d08 <vprintfmt+0x3a>
ffffffffc0208e9c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0208e9e:	85a6                	mv	a1,s1
ffffffffc0208ea0:	02000513          	li	a0,32
ffffffffc0208ea4:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0208ea6:	e60d81e3          	beqz	s11,ffffffffc0208d08 <vprintfmt+0x3a>
ffffffffc0208eaa:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0208eac:	85a6                	mv	a1,s1
ffffffffc0208eae:	02000513          	li	a0,32
ffffffffc0208eb2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0208eb4:	fe0d94e3          	bnez	s11,ffffffffc0208e9c <vprintfmt+0x1ce>
ffffffffc0208eb8:	bd81                	j	ffffffffc0208d08 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0208eba:	4705                	li	a4,1
ffffffffc0208ebc:	008a8593          	addi	a1,s5,8
ffffffffc0208ec0:	01074463          	blt	a4,a6,ffffffffc0208ec8 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0208ec4:	12080063          	beqz	a6,ffffffffc0208fe4 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0208ec8:	000ab603          	ld	a2,0(s5)
ffffffffc0208ecc:	46a9                	li	a3,10
ffffffffc0208ece:	8aae                	mv	s5,a1
ffffffffc0208ed0:	b7bd                	j	ffffffffc0208e3e <vprintfmt+0x170>
ffffffffc0208ed2:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0208ed6:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208eda:	846a                	mv	s0,s10
ffffffffc0208edc:	b5ad                	j	ffffffffc0208d46 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0208ede:	85a6                	mv	a1,s1
ffffffffc0208ee0:	02500513          	li	a0,37
ffffffffc0208ee4:	9902                	jalr	s2
            break;
ffffffffc0208ee6:	b50d                	j	ffffffffc0208d08 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0208ee8:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0208eec:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0208ef0:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208ef2:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0208ef4:	e40dd9e3          	bgez	s11,ffffffffc0208d46 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0208ef8:	8de6                	mv	s11,s9
ffffffffc0208efa:	5cfd                	li	s9,-1
ffffffffc0208efc:	b5a9                	j	ffffffffc0208d46 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0208efe:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0208f02:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208f06:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0208f08:	bd3d                	j	ffffffffc0208d46 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0208f0a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0208f0e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208f12:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0208f14:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0208f18:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0208f1c:	fcd56ce3          	bltu	a0,a3,ffffffffc0208ef4 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0208f20:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0208f22:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0208f26:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0208f2a:	0196873b          	addw	a4,a3,s9
ffffffffc0208f2e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0208f32:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0208f36:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0208f3a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0208f3e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0208f42:	fcd57fe3          	bleu	a3,a0,ffffffffc0208f20 <vprintfmt+0x252>
ffffffffc0208f46:	b77d                	j	ffffffffc0208ef4 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0208f48:	fffdc693          	not	a3,s11
ffffffffc0208f4c:	96fd                	srai	a3,a3,0x3f
ffffffffc0208f4e:	00ddfdb3          	and	s11,s11,a3
ffffffffc0208f52:	00144603          	lbu	a2,1(s0)
ffffffffc0208f56:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208f58:	846a                	mv	s0,s10
ffffffffc0208f5a:	b3f5                	j	ffffffffc0208d46 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0208f5c:	85a6                	mv	a1,s1
ffffffffc0208f5e:	02500513          	li	a0,37
ffffffffc0208f62:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0208f64:	fff44703          	lbu	a4,-1(s0)
ffffffffc0208f68:	02500793          	li	a5,37
ffffffffc0208f6c:	8d22                	mv	s10,s0
ffffffffc0208f6e:	d8f70de3          	beq	a4,a5,ffffffffc0208d08 <vprintfmt+0x3a>
ffffffffc0208f72:	02500713          	li	a4,37
ffffffffc0208f76:	1d7d                	addi	s10,s10,-1
ffffffffc0208f78:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0208f7c:	fee79de3          	bne	a5,a4,ffffffffc0208f76 <vprintfmt+0x2a8>
ffffffffc0208f80:	b361                	j	ffffffffc0208d08 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0208f82:	00003617          	auipc	a2,0x3
ffffffffc0208f86:	00e60613          	addi	a2,a2,14 # ffffffffc020bf90 <error_string+0x1a8>
ffffffffc0208f8a:	85a6                	mv	a1,s1
ffffffffc0208f8c:	854a                	mv	a0,s2
ffffffffc0208f8e:	0ac000ef          	jal	ra,ffffffffc020903a <printfmt>
ffffffffc0208f92:	bb9d                	j	ffffffffc0208d08 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0208f94:	00003617          	auipc	a2,0x3
ffffffffc0208f98:	ff460613          	addi	a2,a2,-12 # ffffffffc020bf88 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0208f9c:	00003417          	auipc	s0,0x3
ffffffffc0208fa0:	fed40413          	addi	s0,s0,-19 # ffffffffc020bf89 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0208fa4:	8532                	mv	a0,a2
ffffffffc0208fa6:	85e6                	mv	a1,s9
ffffffffc0208fa8:	e032                	sd	a2,0(sp)
ffffffffc0208faa:	e43e                	sd	a5,8(sp)
ffffffffc0208fac:	0cc000ef          	jal	ra,ffffffffc0209078 <strnlen>
ffffffffc0208fb0:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0208fb4:	6602                	ld	a2,0(sp)
ffffffffc0208fb6:	01b05d63          	blez	s11,ffffffffc0208fd0 <vprintfmt+0x302>
ffffffffc0208fba:	67a2                	ld	a5,8(sp)
ffffffffc0208fbc:	2781                	sext.w	a5,a5
ffffffffc0208fbe:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0208fc0:	6522                	ld	a0,8(sp)
ffffffffc0208fc2:	85a6                	mv	a1,s1
ffffffffc0208fc4:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0208fc6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0208fc8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0208fca:	6602                	ld	a2,0(sp)
ffffffffc0208fcc:	fe0d9ae3          	bnez	s11,ffffffffc0208fc0 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0208fd0:	00064783          	lbu	a5,0(a2)
ffffffffc0208fd4:	0007851b          	sext.w	a0,a5
ffffffffc0208fd8:	e8051be3          	bnez	a0,ffffffffc0208e6e <vprintfmt+0x1a0>
ffffffffc0208fdc:	b335                	j	ffffffffc0208d08 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0208fde:	000aa403          	lw	s0,0(s5)
ffffffffc0208fe2:	bbf1                	j	ffffffffc0208dbe <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0208fe4:	000ae603          	lwu	a2,0(s5)
ffffffffc0208fe8:	46a9                	li	a3,10
ffffffffc0208fea:	8aae                	mv	s5,a1
ffffffffc0208fec:	bd89                	j	ffffffffc0208e3e <vprintfmt+0x170>
ffffffffc0208fee:	000ae603          	lwu	a2,0(s5)
ffffffffc0208ff2:	46c1                	li	a3,16
ffffffffc0208ff4:	8aae                	mv	s5,a1
ffffffffc0208ff6:	b5a1                	j	ffffffffc0208e3e <vprintfmt+0x170>
ffffffffc0208ff8:	000ae603          	lwu	a2,0(s5)
ffffffffc0208ffc:	46a1                	li	a3,8
ffffffffc0208ffe:	8aae                	mv	s5,a1
ffffffffc0209000:	bd3d                	j	ffffffffc0208e3e <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0209002:	9902                	jalr	s2
ffffffffc0209004:	b559                	j	ffffffffc0208e8a <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0209006:	85a6                	mv	a1,s1
ffffffffc0209008:	02d00513          	li	a0,45
ffffffffc020900c:	e03e                	sd	a5,0(sp)
ffffffffc020900e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0209010:	8ace                	mv	s5,s3
ffffffffc0209012:	40800633          	neg	a2,s0
ffffffffc0209016:	46a9                	li	a3,10
ffffffffc0209018:	6782                	ld	a5,0(sp)
ffffffffc020901a:	b515                	j	ffffffffc0208e3e <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020901c:	01b05663          	blez	s11,ffffffffc0209028 <vprintfmt+0x35a>
ffffffffc0209020:	02d00693          	li	a3,45
ffffffffc0209024:	f6d798e3          	bne	a5,a3,ffffffffc0208f94 <vprintfmt+0x2c6>
ffffffffc0209028:	00003417          	auipc	s0,0x3
ffffffffc020902c:	f6140413          	addi	s0,s0,-159 # ffffffffc020bf89 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0209030:	02800513          	li	a0,40
ffffffffc0209034:	02800793          	li	a5,40
ffffffffc0209038:	bd1d                	j	ffffffffc0208e6e <vprintfmt+0x1a0>

ffffffffc020903a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020903a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020903c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0209040:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0209042:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0209044:	ec06                	sd	ra,24(sp)
ffffffffc0209046:	f83a                	sd	a4,48(sp)
ffffffffc0209048:	fc3e                	sd	a5,56(sp)
ffffffffc020904a:	e0c2                	sd	a6,64(sp)
ffffffffc020904c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020904e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0209050:	c7fff0ef          	jal	ra,ffffffffc0208cce <vprintfmt>
}
ffffffffc0209054:	60e2                	ld	ra,24(sp)
ffffffffc0209056:	6161                	addi	sp,sp,80
ffffffffc0209058:	8082                	ret

ffffffffc020905a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020905a:	00054783          	lbu	a5,0(a0)
ffffffffc020905e:	cb91                	beqz	a5,ffffffffc0209072 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0209060:	4781                	li	a5,0
        cnt ++;
ffffffffc0209062:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0209064:	00f50733          	add	a4,a0,a5
ffffffffc0209068:	00074703          	lbu	a4,0(a4)
ffffffffc020906c:	fb7d                	bnez	a4,ffffffffc0209062 <strlen+0x8>
    }
    return cnt;
}
ffffffffc020906e:	853e                	mv	a0,a5
ffffffffc0209070:	8082                	ret
    size_t cnt = 0;
ffffffffc0209072:	4781                	li	a5,0
}
ffffffffc0209074:	853e                	mv	a0,a5
ffffffffc0209076:	8082                	ret

ffffffffc0209078 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0209078:	c185                	beqz	a1,ffffffffc0209098 <strnlen+0x20>
ffffffffc020907a:	00054783          	lbu	a5,0(a0)
ffffffffc020907e:	cf89                	beqz	a5,ffffffffc0209098 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0209080:	4781                	li	a5,0
ffffffffc0209082:	a021                	j	ffffffffc020908a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0209084:	00074703          	lbu	a4,0(a4)
ffffffffc0209088:	c711                	beqz	a4,ffffffffc0209094 <strnlen+0x1c>
        cnt ++;
ffffffffc020908a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020908c:	00f50733          	add	a4,a0,a5
ffffffffc0209090:	fef59ae3          	bne	a1,a5,ffffffffc0209084 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0209094:	853e                	mv	a0,a5
ffffffffc0209096:	8082                	ret
    size_t cnt = 0;
ffffffffc0209098:	4781                	li	a5,0
}
ffffffffc020909a:	853e                	mv	a0,a5
ffffffffc020909c:	8082                	ret

ffffffffc020909e <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020909e:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02090a0:	0585                	addi	a1,a1,1
ffffffffc02090a2:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02090a6:	0785                	addi	a5,a5,1
ffffffffc02090a8:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02090ac:	fb75                	bnez	a4,ffffffffc02090a0 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02090ae:	8082                	ret

ffffffffc02090b0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02090b0:	00054783          	lbu	a5,0(a0)
ffffffffc02090b4:	0005c703          	lbu	a4,0(a1)
ffffffffc02090b8:	cb91                	beqz	a5,ffffffffc02090cc <strcmp+0x1c>
ffffffffc02090ba:	00e79c63          	bne	a5,a4,ffffffffc02090d2 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02090be:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02090c0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02090c4:	0585                	addi	a1,a1,1
ffffffffc02090c6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02090ca:	fbe5                	bnez	a5,ffffffffc02090ba <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02090cc:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02090ce:	9d19                	subw	a0,a0,a4
ffffffffc02090d0:	8082                	ret
ffffffffc02090d2:	0007851b          	sext.w	a0,a5
ffffffffc02090d6:	9d19                	subw	a0,a0,a4
ffffffffc02090d8:	8082                	ret

ffffffffc02090da <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02090da:	00054783          	lbu	a5,0(a0)
ffffffffc02090de:	cb91                	beqz	a5,ffffffffc02090f2 <strchr+0x18>
        if (*s == c) {
ffffffffc02090e0:	00b79563          	bne	a5,a1,ffffffffc02090ea <strchr+0x10>
ffffffffc02090e4:	a809                	j	ffffffffc02090f6 <strchr+0x1c>
ffffffffc02090e6:	00b78763          	beq	a5,a1,ffffffffc02090f4 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02090ea:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02090ec:	00054783          	lbu	a5,0(a0)
ffffffffc02090f0:	fbfd                	bnez	a5,ffffffffc02090e6 <strchr+0xc>
    }
    return NULL;
ffffffffc02090f2:	4501                	li	a0,0
}
ffffffffc02090f4:	8082                	ret
ffffffffc02090f6:	8082                	ret

ffffffffc02090f8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02090f8:	ca01                	beqz	a2,ffffffffc0209108 <memset+0x10>
ffffffffc02090fa:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02090fc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02090fe:	0785                	addi	a5,a5,1
ffffffffc0209100:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0209104:	fec79de3          	bne	a5,a2,ffffffffc02090fe <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0209108:	8082                	ret

ffffffffc020910a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020910a:	ca19                	beqz	a2,ffffffffc0209120 <memcpy+0x16>
ffffffffc020910c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020910e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0209110:	0585                	addi	a1,a1,1
ffffffffc0209112:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0209116:	0785                	addi	a5,a5,1
ffffffffc0209118:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020911c:	fec59ae3          	bne	a1,a2,ffffffffc0209110 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0209120:	8082                	ret
