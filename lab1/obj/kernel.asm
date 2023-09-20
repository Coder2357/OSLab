
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	ffc50513          	addi	a0,a0,-4 # 80204008 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	00460613          	addi	a2,a2,4 # 80204018 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	11d000ef          	jal	ra,80200940 <memset>

    cons_init();  // init the console
    80200028:	13c000ef          	jal	ra,80200164 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	92c58593          	addi	a1,a1,-1748 # 80200958 <etext+0x6>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	94450513          	addi	a0,a0,-1724 # 80200978 <etext+0x26>
    8020003c:	030000ef          	jal	ra,8020006c <cprintf>

    print_kerninfo();
    80200040:	060000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	130000ef          	jal	ra,80200174 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0e8000ef          	jal	ra,80200130 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004c:	122000ef          	jal	ra,8020016e <intr_enable>
    
    while (1)
        ;
    80200050:	a001                	j	80200050 <kern_init+0x44>

0000000080200052 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200052:	1141                	addi	sp,sp,-16
    80200054:	e022                	sd	s0,0(sp)
    80200056:	e406                	sd	ra,8(sp)
    80200058:	842e                	mv	s0,a1
    cons_putc(c);
    8020005a:	10c000ef          	jal	ra,80200166 <cons_putc>
    (*cnt)++;
    8020005e:	401c                	lw	a5,0(s0)
}
    80200060:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200062:	2785                	addiw	a5,a5,1
    80200064:	c01c                	sw	a5,0(s0)
}
    80200066:	6402                	ld	s0,0(sp)
    80200068:	0141                	addi	sp,sp,16
    8020006a:	8082                	ret

000000008020006c <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end+0x10>
int cprintf(const char *fmt, ...) {
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	862a                	mv	a2,a0
    8020007a:	004c                	addi	a1,sp,4
    8020007c:	00000517          	auipc	a0,0x0
    80200080:	fd650513          	addi	a0,a0,-42 # 80200052 <cputch>
    80200084:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	4c2000ef          	jal	ra,80200556 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	8de50513          	addi	a0,a0,-1826 # 80200980 <etext+0x2e>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5c58593          	addi	a1,a1,-164 # 8020000c <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	8e850513          	addi	a0,a0,-1816 # 802009a0 <etext+0x4e>
    802000c0:	fadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	88e58593          	addi	a1,a1,-1906 # 80200952 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	8f450513          	addi	a0,a0,-1804 # 802009c0 <etext+0x6e>
    802000d4:	f99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3058593          	addi	a1,a1,-208 # 80204008 <edata>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	90050513          	addi	a0,a0,-1792 # 802009e0 <etext+0x8e>
    802000e8:	f85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f2c58593          	addi	a1,a1,-212 # 80204018 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	90c50513          	addi	a0,a0,-1780 # 80200a00 <etext+0xae>
    802000fc:	f71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	31758593          	addi	a1,a1,791 # 80204417 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0478793          	addi	a5,a5,-252 # 8020000c <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	8fe50513          	addi	a0,a0,-1794 # 80200a20 <etext+0xce>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	f41ff06f          	j	8020006c <cprintf>

0000000080200130 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200130:	1141                	addi	sp,sp,-16
    80200132:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200134:	02000793          	li	a5,32
    80200138:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013c:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200140:	67e1                	lui	a5,0x18
    80200142:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200146:	953e                	add	a0,a0,a5
    80200148:	7b6000ef          	jal	ra,802008fe <sbi_set_timer>
}
    8020014c:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014e:	00004797          	auipc	a5,0x4
    80200152:	ec07b123          	sd	zero,-318(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200156:	00001517          	auipc	a0,0x1
    8020015a:	8fa50513          	addi	a0,a0,-1798 # 80200a50 <etext+0xfe>
}
    8020015e:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200160:	f0dff06f          	j	8020006c <cprintf>

0000000080200164 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200164:	8082                	ret

0000000080200166 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200166:	0ff57513          	andi	a0,a0,255
    8020016a:	7780006f          	j	802008e2 <sbi_console_putchar>

000000008020016e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020016e:	100167f3          	csrrsi	a5,sstatus,2
    80200172:	8082                	ret

0000000080200174 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200174:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200178:	00000797          	auipc	a5,0x0
    8020017c:	2bc78793          	addi	a5,a5,700 # 80200434 <__alltraps>
    80200180:	10579073          	csrw	stvec,a5
}
    80200184:	8082                	ret

0000000080200186 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200186:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200188:	1141                	addi	sp,sp,-16
    8020018a:	e022                	sd	s0,0(sp)
    8020018c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020018e:	00001517          	auipc	a0,0x1
    80200192:	9b250513          	addi	a0,a0,-1614 # 80200b40 <etext+0x1ee>
void print_regs(struct pushregs *gpr) {
    80200196:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200198:	ed5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    8020019c:	640c                	ld	a1,8(s0)
    8020019e:	00001517          	auipc	a0,0x1
    802001a2:	9ba50513          	addi	a0,a0,-1606 # 80200b58 <etext+0x206>
    802001a6:	ec7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001aa:	680c                	ld	a1,16(s0)
    802001ac:	00001517          	auipc	a0,0x1
    802001b0:	9c450513          	addi	a0,a0,-1596 # 80200b70 <etext+0x21e>
    802001b4:	eb9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001b8:	6c0c                	ld	a1,24(s0)
    802001ba:	00001517          	auipc	a0,0x1
    802001be:	9ce50513          	addi	a0,a0,-1586 # 80200b88 <etext+0x236>
    802001c2:	eabff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001c6:	700c                	ld	a1,32(s0)
    802001c8:	00001517          	auipc	a0,0x1
    802001cc:	9d850513          	addi	a0,a0,-1576 # 80200ba0 <etext+0x24e>
    802001d0:	e9dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001d4:	740c                	ld	a1,40(s0)
    802001d6:	00001517          	auipc	a0,0x1
    802001da:	9e250513          	addi	a0,a0,-1566 # 80200bb8 <etext+0x266>
    802001de:	e8fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001e2:	780c                	ld	a1,48(s0)
    802001e4:	00001517          	auipc	a0,0x1
    802001e8:	9ec50513          	addi	a0,a0,-1556 # 80200bd0 <etext+0x27e>
    802001ec:	e81ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001f0:	7c0c                	ld	a1,56(s0)
    802001f2:	00001517          	auipc	a0,0x1
    802001f6:	9f650513          	addi	a0,a0,-1546 # 80200be8 <etext+0x296>
    802001fa:	e73ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    802001fe:	602c                	ld	a1,64(s0)
    80200200:	00001517          	auipc	a0,0x1
    80200204:	a0050513          	addi	a0,a0,-1536 # 80200c00 <etext+0x2ae>
    80200208:	e65ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020020c:	642c                	ld	a1,72(s0)
    8020020e:	00001517          	auipc	a0,0x1
    80200212:	a0a50513          	addi	a0,a0,-1526 # 80200c18 <etext+0x2c6>
    80200216:	e57ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020021a:	682c                	ld	a1,80(s0)
    8020021c:	00001517          	auipc	a0,0x1
    80200220:	a1450513          	addi	a0,a0,-1516 # 80200c30 <etext+0x2de>
    80200224:	e49ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200228:	6c2c                	ld	a1,88(s0)
    8020022a:	00001517          	auipc	a0,0x1
    8020022e:	a1e50513          	addi	a0,a0,-1506 # 80200c48 <etext+0x2f6>
    80200232:	e3bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200236:	702c                	ld	a1,96(s0)
    80200238:	00001517          	auipc	a0,0x1
    8020023c:	a2850513          	addi	a0,a0,-1496 # 80200c60 <etext+0x30e>
    80200240:	e2dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200244:	742c                	ld	a1,104(s0)
    80200246:	00001517          	auipc	a0,0x1
    8020024a:	a3250513          	addi	a0,a0,-1486 # 80200c78 <etext+0x326>
    8020024e:	e1fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200252:	782c                	ld	a1,112(s0)
    80200254:	00001517          	auipc	a0,0x1
    80200258:	a3c50513          	addi	a0,a0,-1476 # 80200c90 <etext+0x33e>
    8020025c:	e11ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200260:	7c2c                	ld	a1,120(s0)
    80200262:	00001517          	auipc	a0,0x1
    80200266:	a4650513          	addi	a0,a0,-1466 # 80200ca8 <etext+0x356>
    8020026a:	e03ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020026e:	604c                	ld	a1,128(s0)
    80200270:	00001517          	auipc	a0,0x1
    80200274:	a5050513          	addi	a0,a0,-1456 # 80200cc0 <etext+0x36e>
    80200278:	df5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020027c:	644c                	ld	a1,136(s0)
    8020027e:	00001517          	auipc	a0,0x1
    80200282:	a5a50513          	addi	a0,a0,-1446 # 80200cd8 <etext+0x386>
    80200286:	de7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020028a:	684c                	ld	a1,144(s0)
    8020028c:	00001517          	auipc	a0,0x1
    80200290:	a6450513          	addi	a0,a0,-1436 # 80200cf0 <etext+0x39e>
    80200294:	dd9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    80200298:	6c4c                	ld	a1,152(s0)
    8020029a:	00001517          	auipc	a0,0x1
    8020029e:	a6e50513          	addi	a0,a0,-1426 # 80200d08 <etext+0x3b6>
    802002a2:	dcbff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002a6:	704c                	ld	a1,160(s0)
    802002a8:	00001517          	auipc	a0,0x1
    802002ac:	a7850513          	addi	a0,a0,-1416 # 80200d20 <etext+0x3ce>
    802002b0:	dbdff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002b4:	744c                	ld	a1,168(s0)
    802002b6:	00001517          	auipc	a0,0x1
    802002ba:	a8250513          	addi	a0,a0,-1406 # 80200d38 <etext+0x3e6>
    802002be:	dafff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002c2:	784c                	ld	a1,176(s0)
    802002c4:	00001517          	auipc	a0,0x1
    802002c8:	a8c50513          	addi	a0,a0,-1396 # 80200d50 <etext+0x3fe>
    802002cc:	da1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002d0:	7c4c                	ld	a1,184(s0)
    802002d2:	00001517          	auipc	a0,0x1
    802002d6:	a9650513          	addi	a0,a0,-1386 # 80200d68 <etext+0x416>
    802002da:	d93ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002de:	606c                	ld	a1,192(s0)
    802002e0:	00001517          	auipc	a0,0x1
    802002e4:	aa050513          	addi	a0,a0,-1376 # 80200d80 <etext+0x42e>
    802002e8:	d85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002ec:	646c                	ld	a1,200(s0)
    802002ee:	00001517          	auipc	a0,0x1
    802002f2:	aaa50513          	addi	a0,a0,-1366 # 80200d98 <etext+0x446>
    802002f6:	d77ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    802002fa:	686c                	ld	a1,208(s0)
    802002fc:	00001517          	auipc	a0,0x1
    80200300:	ab450513          	addi	a0,a0,-1356 # 80200db0 <etext+0x45e>
    80200304:	d69ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200308:	6c6c                	ld	a1,216(s0)
    8020030a:	00001517          	auipc	a0,0x1
    8020030e:	abe50513          	addi	a0,a0,-1346 # 80200dc8 <etext+0x476>
    80200312:	d5bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200316:	706c                	ld	a1,224(s0)
    80200318:	00001517          	auipc	a0,0x1
    8020031c:	ac850513          	addi	a0,a0,-1336 # 80200de0 <etext+0x48e>
    80200320:	d4dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200324:	746c                	ld	a1,232(s0)
    80200326:	00001517          	auipc	a0,0x1
    8020032a:	ad250513          	addi	a0,a0,-1326 # 80200df8 <etext+0x4a6>
    8020032e:	d3fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200332:	786c                	ld	a1,240(s0)
    80200334:	00001517          	auipc	a0,0x1
    80200338:	adc50513          	addi	a0,a0,-1316 # 80200e10 <etext+0x4be>
    8020033c:	d31ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200340:	7c6c                	ld	a1,248(s0)
}
    80200342:	6402                	ld	s0,0(sp)
    80200344:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200346:	00001517          	auipc	a0,0x1
    8020034a:	ae250513          	addi	a0,a0,-1310 # 80200e28 <etext+0x4d6>
}
    8020034e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	d1dff06f          	j	8020006c <cprintf>

0000000080200354 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200354:	1141                	addi	sp,sp,-16
    80200356:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200358:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020035a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020035c:	00001517          	auipc	a0,0x1
    80200360:	ae450513          	addi	a0,a0,-1308 # 80200e40 <etext+0x4ee>
void print_trapframe(struct trapframe *tf) {
    80200364:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200366:	d07ff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    8020036a:	8522                	mv	a0,s0
    8020036c:	e1bff0ef          	jal	ra,80200186 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200370:	10043583          	ld	a1,256(s0)
    80200374:	00001517          	auipc	a0,0x1
    80200378:	ae450513          	addi	a0,a0,-1308 # 80200e58 <etext+0x506>
    8020037c:	cf1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200380:	10843583          	ld	a1,264(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	aec50513          	addi	a0,a0,-1300 # 80200e70 <etext+0x51e>
    8020038c:	ce1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    80200390:	11043583          	ld	a1,272(s0)
    80200394:	00001517          	auipc	a0,0x1
    80200398:	af450513          	addi	a0,a0,-1292 # 80200e88 <etext+0x536>
    8020039c:	cd1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a0:	11843583          	ld	a1,280(s0)
}
    802003a4:	6402                	ld	s0,0(sp)
    802003a6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a8:	00001517          	auipc	a0,0x1
    802003ac:	af850513          	addi	a0,a0,-1288 # 80200ea0 <etext+0x54e>
}
    802003b0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b2:	cbbff06f          	j	8020006c <cprintf>

00000000802003b6 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003b6:	11853783          	ld	a5,280(a0)
    802003ba:	577d                	li	a4,-1
    802003bc:	8305                	srli	a4,a4,0x1
    802003be:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003c0:	472d                	li	a4,11
    802003c2:	04f76a63          	bltu	a4,a5,80200416 <interrupt_handler+0x60>
    802003c6:	00000717          	auipc	a4,0x0
    802003ca:	6a670713          	addi	a4,a4,1702 # 80200a6c <etext+0x11a>
    802003ce:	078a                	slli	a5,a5,0x2
    802003d0:	97ba                	add	a5,a5,a4
    802003d2:	439c                	lw	a5,0(a5)
    802003d4:	97ba                	add	a5,a5,a4
    802003d6:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003d8:	00000517          	auipc	a0,0x0
    802003dc:	72850513          	addi	a0,a0,1832 # 80200b00 <etext+0x1ae>
    802003e0:	c8dff06f          	j	8020006c <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e4:	00000517          	auipc	a0,0x0
    802003e8:	6fc50513          	addi	a0,a0,1788 # 80200ae0 <etext+0x18e>
    802003ec:	c81ff06f          	j	8020006c <cprintf>
            cprintf("User software interrupt\n");
    802003f0:	00000517          	auipc	a0,0x0
    802003f4:	6b050513          	addi	a0,a0,1712 # 80200aa0 <etext+0x14e>
    802003f8:	c75ff06f          	j	8020006c <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fc:	00000517          	auipc	a0,0x0
    80200400:	6c450513          	addi	a0,a0,1732 # 80200ac0 <etext+0x16e>
    80200404:	c69ff06f          	j	8020006c <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200408:	00000517          	auipc	a0,0x0
    8020040c:	71850513          	addi	a0,a0,1816 # 80200b20 <etext+0x1ce>
    80200410:	c5dff06f          	j	8020006c <cprintf>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200414:	8082                	ret
            print_trapframe(tf);
    80200416:	f3fff06f          	j	80200354 <print_trapframe>

000000008020041a <trap>:
    }
}

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    8020041a:	11853783          	ld	a5,280(a0)
    8020041e:	0007c863          	bltz	a5,8020042e <trap+0x14>
    switch (tf->cause) {
    80200422:	472d                	li	a4,11
    80200424:	00f76363          	bltu	a4,a5,8020042a <trap+0x10>
 * trap - handles or dispatches an exception/interrupt. if and when trap()
 * returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) { trap_dispatch(tf); }
    80200428:	8082                	ret
            print_trapframe(tf);
    8020042a:	f2bff06f          	j	80200354 <print_trapframe>
        interrupt_handler(tf);
    8020042e:	f89ff06f          	j	802003b6 <interrupt_handler>
	...

0000000080200434 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200434:	14011073          	csrw	sscratch,sp
    80200438:	712d                	addi	sp,sp,-288
    8020043a:	e002                	sd	zero,0(sp)
    8020043c:	e406                	sd	ra,8(sp)
    8020043e:	ec0e                	sd	gp,24(sp)
    80200440:	f012                	sd	tp,32(sp)
    80200442:	f416                	sd	t0,40(sp)
    80200444:	f81a                	sd	t1,48(sp)
    80200446:	fc1e                	sd	t2,56(sp)
    80200448:	e0a2                	sd	s0,64(sp)
    8020044a:	e4a6                	sd	s1,72(sp)
    8020044c:	e8aa                	sd	a0,80(sp)
    8020044e:	ecae                	sd	a1,88(sp)
    80200450:	f0b2                	sd	a2,96(sp)
    80200452:	f4b6                	sd	a3,104(sp)
    80200454:	f8ba                	sd	a4,112(sp)
    80200456:	fcbe                	sd	a5,120(sp)
    80200458:	e142                	sd	a6,128(sp)
    8020045a:	e546                	sd	a7,136(sp)
    8020045c:	e94a                	sd	s2,144(sp)
    8020045e:	ed4e                	sd	s3,152(sp)
    80200460:	f152                	sd	s4,160(sp)
    80200462:	f556                	sd	s5,168(sp)
    80200464:	f95a                	sd	s6,176(sp)
    80200466:	fd5e                	sd	s7,184(sp)
    80200468:	e1e2                	sd	s8,192(sp)
    8020046a:	e5e6                	sd	s9,200(sp)
    8020046c:	e9ea                	sd	s10,208(sp)
    8020046e:	edee                	sd	s11,216(sp)
    80200470:	f1f2                	sd	t3,224(sp)
    80200472:	f5f6                	sd	t4,232(sp)
    80200474:	f9fa                	sd	t5,240(sp)
    80200476:	fdfe                	sd	t6,248(sp)
    80200478:	14001473          	csrrw	s0,sscratch,zero
    8020047c:	100024f3          	csrr	s1,sstatus
    80200480:	14102973          	csrr	s2,sepc
    80200484:	143029f3          	csrr	s3,stval
    80200488:	14202a73          	csrr	s4,scause
    8020048c:	e822                	sd	s0,16(sp)
    8020048e:	e226                	sd	s1,256(sp)
    80200490:	e64a                	sd	s2,264(sp)
    80200492:	ea4e                	sd	s3,272(sp)
    80200494:	ee52                	sd	s4,280(sp)

    move  a0, sp
    80200496:	850a                	mv	a0,sp
    jal trap
    80200498:	f83ff0ef          	jal	ra,8020041a <trap>

000000008020049c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    8020049c:	6492                	ld	s1,256(sp)
    8020049e:	6932                	ld	s2,264(sp)
    802004a0:	10049073          	csrw	sstatus,s1
    802004a4:	14191073          	csrw	sepc,s2
    802004a8:	60a2                	ld	ra,8(sp)
    802004aa:	61e2                	ld	gp,24(sp)
    802004ac:	7202                	ld	tp,32(sp)
    802004ae:	72a2                	ld	t0,40(sp)
    802004b0:	7342                	ld	t1,48(sp)
    802004b2:	73e2                	ld	t2,56(sp)
    802004b4:	6406                	ld	s0,64(sp)
    802004b6:	64a6                	ld	s1,72(sp)
    802004b8:	6546                	ld	a0,80(sp)
    802004ba:	65e6                	ld	a1,88(sp)
    802004bc:	7606                	ld	a2,96(sp)
    802004be:	76a6                	ld	a3,104(sp)
    802004c0:	7746                	ld	a4,112(sp)
    802004c2:	77e6                	ld	a5,120(sp)
    802004c4:	680a                	ld	a6,128(sp)
    802004c6:	68aa                	ld	a7,136(sp)
    802004c8:	694a                	ld	s2,144(sp)
    802004ca:	69ea                	ld	s3,152(sp)
    802004cc:	7a0a                	ld	s4,160(sp)
    802004ce:	7aaa                	ld	s5,168(sp)
    802004d0:	7b4a                	ld	s6,176(sp)
    802004d2:	7bea                	ld	s7,184(sp)
    802004d4:	6c0e                	ld	s8,192(sp)
    802004d6:	6cae                	ld	s9,200(sp)
    802004d8:	6d4e                	ld	s10,208(sp)
    802004da:	6dee                	ld	s11,216(sp)
    802004dc:	7e0e                	ld	t3,224(sp)
    802004de:	7eae                	ld	t4,232(sp)
    802004e0:	7f4e                	ld	t5,240(sp)
    802004e2:	7fee                	ld	t6,248(sp)
    802004e4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802004e6:	10200073          	sret

00000000802004ea <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802004ea:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802004ee:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802004f0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802004f4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802004f6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802004fa:	f022                	sd	s0,32(sp)
    802004fc:	ec26                	sd	s1,24(sp)
    802004fe:	e84a                	sd	s2,16(sp)
    80200500:	f406                	sd	ra,40(sp)
    80200502:	e44e                	sd	s3,8(sp)
    80200504:	84aa                	mv	s1,a0
    80200506:	892e                	mv	s2,a1
    80200508:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    8020050c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    8020050e:	03067e63          	bleu	a6,a2,8020054a <printnum+0x60>
    80200512:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200514:	00805763          	blez	s0,80200522 <printnum+0x38>
    80200518:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020051a:	85ca                	mv	a1,s2
    8020051c:	854e                	mv	a0,s3
    8020051e:	9482                	jalr	s1
        while (-- width > 0)
    80200520:	fc65                	bnez	s0,80200518 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200522:	1a02                	slli	s4,s4,0x20
    80200524:	020a5a13          	srli	s4,s4,0x20
    80200528:	00001797          	auipc	a5,0x1
    8020052c:	b2078793          	addi	a5,a5,-1248 # 80201048 <error_string+0x38>
    80200530:	9a3e                	add	s4,s4,a5
}
    80200532:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200534:	000a4503          	lbu	a0,0(s4)
}
    80200538:	70a2                	ld	ra,40(sp)
    8020053a:	69a2                	ld	s3,8(sp)
    8020053c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020053e:	85ca                	mv	a1,s2
    80200540:	8326                	mv	t1,s1
}
    80200542:	6942                	ld	s2,16(sp)
    80200544:	64e2                	ld	s1,24(sp)
    80200546:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200548:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    8020054a:	03065633          	divu	a2,a2,a6
    8020054e:	8722                	mv	a4,s0
    80200550:	f9bff0ef          	jal	ra,802004ea <printnum>
    80200554:	b7f9                	j	80200522 <printnum+0x38>

0000000080200556 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200556:	7119                	addi	sp,sp,-128
    80200558:	f4a6                	sd	s1,104(sp)
    8020055a:	f0ca                	sd	s2,96(sp)
    8020055c:	e8d2                	sd	s4,80(sp)
    8020055e:	e4d6                	sd	s5,72(sp)
    80200560:	e0da                	sd	s6,64(sp)
    80200562:	fc5e                	sd	s7,56(sp)
    80200564:	f862                	sd	s8,48(sp)
    80200566:	f06a                	sd	s10,32(sp)
    80200568:	fc86                	sd	ra,120(sp)
    8020056a:	f8a2                	sd	s0,112(sp)
    8020056c:	ecce                	sd	s3,88(sp)
    8020056e:	f466                	sd	s9,40(sp)
    80200570:	ec6e                	sd	s11,24(sp)
    80200572:	892a                	mv	s2,a0
    80200574:	84ae                	mv	s1,a1
    80200576:	8d32                	mv	s10,a2
    80200578:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020057a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    8020057c:	00001a17          	auipc	s4,0x1
    80200580:	938a0a13          	addi	s4,s4,-1736 # 80200eb4 <etext+0x562>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200584:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200588:	00001c17          	auipc	s8,0x1
    8020058c:	a88c0c13          	addi	s8,s8,-1400 # 80201010 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200590:	000d4503          	lbu	a0,0(s10)
    80200594:	02500793          	li	a5,37
    80200598:	001d0413          	addi	s0,s10,1
    8020059c:	00f50e63          	beq	a0,a5,802005b8 <vprintfmt+0x62>
            if (ch == '\0') {
    802005a0:	c521                	beqz	a0,802005e8 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005a2:	02500993          	li	s3,37
    802005a6:	a011                	j	802005aa <vprintfmt+0x54>
            if (ch == '\0') {
    802005a8:	c121                	beqz	a0,802005e8 <vprintfmt+0x92>
            putch(ch, putdat);
    802005aa:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005ac:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802005ae:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005b0:	fff44503          	lbu	a0,-1(s0)
    802005b4:	ff351ae3          	bne	a0,s3,802005a8 <vprintfmt+0x52>
    802005b8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802005bc:	02000793          	li	a5,32
        lflag = altflag = 0;
    802005c0:	4981                	li	s3,0
    802005c2:	4801                	li	a6,0
        width = precision = -1;
    802005c4:	5cfd                	li	s9,-1
    802005c6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802005c8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    802005cc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    802005ce:	fdd6069b          	addiw	a3,a2,-35
    802005d2:	0ff6f693          	andi	a3,a3,255
    802005d6:	00140d13          	addi	s10,s0,1
    802005da:	20d5e563          	bltu	a1,a3,802007e4 <vprintfmt+0x28e>
    802005de:	068a                	slli	a3,a3,0x2
    802005e0:	96d2                	add	a3,a3,s4
    802005e2:	4294                	lw	a3,0(a3)
    802005e4:	96d2                	add	a3,a3,s4
    802005e6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802005e8:	70e6                	ld	ra,120(sp)
    802005ea:	7446                	ld	s0,112(sp)
    802005ec:	74a6                	ld	s1,104(sp)
    802005ee:	7906                	ld	s2,96(sp)
    802005f0:	69e6                	ld	s3,88(sp)
    802005f2:	6a46                	ld	s4,80(sp)
    802005f4:	6aa6                	ld	s5,72(sp)
    802005f6:	6b06                	ld	s6,64(sp)
    802005f8:	7be2                	ld	s7,56(sp)
    802005fa:	7c42                	ld	s8,48(sp)
    802005fc:	7ca2                	ld	s9,40(sp)
    802005fe:	7d02                	ld	s10,32(sp)
    80200600:	6de2                	ld	s11,24(sp)
    80200602:	6109                	addi	sp,sp,128
    80200604:	8082                	ret
    if (lflag >= 2) {
    80200606:	4705                	li	a4,1
    80200608:	008a8593          	addi	a1,s5,8
    8020060c:	01074463          	blt	a4,a6,80200614 <vprintfmt+0xbe>
    else if (lflag) {
    80200610:	26080363          	beqz	a6,80200876 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200614:	000ab603          	ld	a2,0(s5)
    80200618:	46c1                	li	a3,16
    8020061a:	8aae                	mv	s5,a1
    8020061c:	a06d                	j	802006c6 <vprintfmt+0x170>
            goto reswitch;
    8020061e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200622:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200624:	846a                	mv	s0,s10
            goto reswitch;
    80200626:	b765                	j	802005ce <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    80200628:	000aa503          	lw	a0,0(s5)
    8020062c:	85a6                	mv	a1,s1
    8020062e:	0aa1                	addi	s5,s5,8
    80200630:	9902                	jalr	s2
            break;
    80200632:	bfb9                	j	80200590 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200634:	4705                	li	a4,1
    80200636:	008a8993          	addi	s3,s5,8
    8020063a:	01074463          	blt	a4,a6,80200642 <vprintfmt+0xec>
    else if (lflag) {
    8020063e:	22080463          	beqz	a6,80200866 <vprintfmt+0x310>
        return va_arg(*ap, long);
    80200642:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    80200646:	24044463          	bltz	s0,8020088e <vprintfmt+0x338>
            num = getint(&ap, lflag);
    8020064a:	8622                	mv	a2,s0
    8020064c:	8ace                	mv	s5,s3
    8020064e:	46a9                	li	a3,10
    80200650:	a89d                	j	802006c6 <vprintfmt+0x170>
            err = va_arg(ap, int);
    80200652:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200656:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200658:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020065a:	41f7d69b          	sraiw	a3,a5,0x1f
    8020065e:	8fb5                	xor	a5,a5,a3
    80200660:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200664:	1ad74363          	blt	a4,a3,8020080a <vprintfmt+0x2b4>
    80200668:	00369793          	slli	a5,a3,0x3
    8020066c:	97e2                	add	a5,a5,s8
    8020066e:	639c                	ld	a5,0(a5)
    80200670:	18078d63          	beqz	a5,8020080a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    80200674:	86be                	mv	a3,a5
    80200676:	00001617          	auipc	a2,0x1
    8020067a:	a8260613          	addi	a2,a2,-1406 # 802010f8 <error_string+0xe8>
    8020067e:	85a6                	mv	a1,s1
    80200680:	854a                	mv	a0,s2
    80200682:	240000ef          	jal	ra,802008c2 <printfmt>
    80200686:	b729                	j	80200590 <vprintfmt+0x3a>
            lflag ++;
    80200688:	00144603          	lbu	a2,1(s0)
    8020068c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020068e:	846a                	mv	s0,s10
            goto reswitch;
    80200690:	bf3d                	j	802005ce <vprintfmt+0x78>
    if (lflag >= 2) {
    80200692:	4705                	li	a4,1
    80200694:	008a8593          	addi	a1,s5,8
    80200698:	01074463          	blt	a4,a6,802006a0 <vprintfmt+0x14a>
    else if (lflag) {
    8020069c:	1e080263          	beqz	a6,80200880 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    802006a0:	000ab603          	ld	a2,0(s5)
    802006a4:	46a1                	li	a3,8
    802006a6:	8aae                	mv	s5,a1
    802006a8:	a839                	j	802006c6 <vprintfmt+0x170>
            putch('0', putdat);
    802006aa:	03000513          	li	a0,48
    802006ae:	85a6                	mv	a1,s1
    802006b0:	e03e                	sd	a5,0(sp)
    802006b2:	9902                	jalr	s2
            putch('x', putdat);
    802006b4:	85a6                	mv	a1,s1
    802006b6:	07800513          	li	a0,120
    802006ba:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802006bc:	0aa1                	addi	s5,s5,8
    802006be:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802006c2:	6782                	ld	a5,0(sp)
    802006c4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802006c6:	876e                	mv	a4,s11
    802006c8:	85a6                	mv	a1,s1
    802006ca:	854a                	mv	a0,s2
    802006cc:	e1fff0ef          	jal	ra,802004ea <printnum>
            break;
    802006d0:	b5c1                	j	80200590 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802006d2:	000ab603          	ld	a2,0(s5)
    802006d6:	0aa1                	addi	s5,s5,8
    802006d8:	1c060663          	beqz	a2,802008a4 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    802006dc:	00160413          	addi	s0,a2,1
    802006e0:	17b05c63          	blez	s11,80200858 <vprintfmt+0x302>
    802006e4:	02d00593          	li	a1,45
    802006e8:	14b79263          	bne	a5,a1,8020082c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802006ec:	00064783          	lbu	a5,0(a2)
    802006f0:	0007851b          	sext.w	a0,a5
    802006f4:	c905                	beqz	a0,80200724 <vprintfmt+0x1ce>
    802006f6:	000cc563          	bltz	s9,80200700 <vprintfmt+0x1aa>
    802006fa:	3cfd                	addiw	s9,s9,-1
    802006fc:	036c8263          	beq	s9,s6,80200720 <vprintfmt+0x1ca>
                    putch('?', putdat);
    80200700:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200702:	18098463          	beqz	s3,8020088a <vprintfmt+0x334>
    80200706:	3781                	addiw	a5,a5,-32
    80200708:	18fbf163          	bleu	a5,s7,8020088a <vprintfmt+0x334>
                    putch('?', putdat);
    8020070c:	03f00513          	li	a0,63
    80200710:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200712:	0405                	addi	s0,s0,1
    80200714:	fff44783          	lbu	a5,-1(s0)
    80200718:	3dfd                	addiw	s11,s11,-1
    8020071a:	0007851b          	sext.w	a0,a5
    8020071e:	fd61                	bnez	a0,802006f6 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200720:	e7b058e3          	blez	s11,80200590 <vprintfmt+0x3a>
    80200724:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200726:	85a6                	mv	a1,s1
    80200728:	02000513          	li	a0,32
    8020072c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020072e:	e60d81e3          	beqz	s11,80200590 <vprintfmt+0x3a>
    80200732:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200734:	85a6                	mv	a1,s1
    80200736:	02000513          	li	a0,32
    8020073a:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020073c:	fe0d94e3          	bnez	s11,80200724 <vprintfmt+0x1ce>
    80200740:	bd81                	j	80200590 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200742:	4705                	li	a4,1
    80200744:	008a8593          	addi	a1,s5,8
    80200748:	01074463          	blt	a4,a6,80200750 <vprintfmt+0x1fa>
    else if (lflag) {
    8020074c:	12080063          	beqz	a6,8020086c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    80200750:	000ab603          	ld	a2,0(s5)
    80200754:	46a9                	li	a3,10
    80200756:	8aae                	mv	s5,a1
    80200758:	b7bd                	j	802006c6 <vprintfmt+0x170>
    8020075a:	00144603          	lbu	a2,1(s0)
            padc = '-';
    8020075e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    80200762:	846a                	mv	s0,s10
    80200764:	b5ad                	j	802005ce <vprintfmt+0x78>
            putch(ch, putdat);
    80200766:	85a6                	mv	a1,s1
    80200768:	02500513          	li	a0,37
    8020076c:	9902                	jalr	s2
            break;
    8020076e:	b50d                	j	80200590 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    80200770:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    80200774:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200778:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020077a:	846a                	mv	s0,s10
            if (width < 0)
    8020077c:	e40dd9e3          	bgez	s11,802005ce <vprintfmt+0x78>
                width = precision, precision = -1;
    80200780:	8de6                	mv	s11,s9
    80200782:	5cfd                	li	s9,-1
    80200784:	b5a9                	j	802005ce <vprintfmt+0x78>
            goto reswitch;
    80200786:	00144603          	lbu	a2,1(s0)
            padc = '0';
    8020078a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    8020078e:	846a                	mv	s0,s10
            goto reswitch;
    80200790:	bd3d                	j	802005ce <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    80200792:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    80200796:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020079a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    8020079c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802007a0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802007a4:	fcd56ce3          	bltu	a0,a3,8020077c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    802007a8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802007aa:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802007ae:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802007b2:	0196873b          	addw	a4,a3,s9
    802007b6:	0017171b          	slliw	a4,a4,0x1
    802007ba:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802007be:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802007c2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802007c6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802007ca:	fcd57fe3          	bleu	a3,a0,802007a8 <vprintfmt+0x252>
    802007ce:	b77d                	j	8020077c <vprintfmt+0x226>
            if (width < 0)
    802007d0:	fffdc693          	not	a3,s11
    802007d4:	96fd                	srai	a3,a3,0x3f
    802007d6:	00ddfdb3          	and	s11,s11,a3
    802007da:	00144603          	lbu	a2,1(s0)
    802007de:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802007e0:	846a                	mv	s0,s10
    802007e2:	b3f5                	j	802005ce <vprintfmt+0x78>
            putch('%', putdat);
    802007e4:	85a6                	mv	a1,s1
    802007e6:	02500513          	li	a0,37
    802007ea:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802007ec:	fff44703          	lbu	a4,-1(s0)
    802007f0:	02500793          	li	a5,37
    802007f4:	8d22                	mv	s10,s0
    802007f6:	d8f70de3          	beq	a4,a5,80200590 <vprintfmt+0x3a>
    802007fa:	02500713          	li	a4,37
    802007fe:	1d7d                	addi	s10,s10,-1
    80200800:	fffd4783          	lbu	a5,-1(s10)
    80200804:	fee79de3          	bne	a5,a4,802007fe <vprintfmt+0x2a8>
    80200808:	b361                	j	80200590 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020080a:	00001617          	auipc	a2,0x1
    8020080e:	8de60613          	addi	a2,a2,-1826 # 802010e8 <error_string+0xd8>
    80200812:	85a6                	mv	a1,s1
    80200814:	854a                	mv	a0,s2
    80200816:	0ac000ef          	jal	ra,802008c2 <printfmt>
    8020081a:	bb9d                	j	80200590 <vprintfmt+0x3a>
                p = "(null)";
    8020081c:	00001617          	auipc	a2,0x1
    80200820:	8c460613          	addi	a2,a2,-1852 # 802010e0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200824:	00001417          	auipc	s0,0x1
    80200828:	8bd40413          	addi	s0,s0,-1859 # 802010e1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020082c:	8532                	mv	a0,a2
    8020082e:	85e6                	mv	a1,s9
    80200830:	e032                	sd	a2,0(sp)
    80200832:	e43e                	sd	a5,8(sp)
    80200834:	0e6000ef          	jal	ra,8020091a <strnlen>
    80200838:	40ad8dbb          	subw	s11,s11,a0
    8020083c:	6602                	ld	a2,0(sp)
    8020083e:	01b05d63          	blez	s11,80200858 <vprintfmt+0x302>
    80200842:	67a2                	ld	a5,8(sp)
    80200844:	2781                	sext.w	a5,a5
    80200846:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200848:	6522                	ld	a0,8(sp)
    8020084a:	85a6                	mv	a1,s1
    8020084c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020084e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200850:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200852:	6602                	ld	a2,0(sp)
    80200854:	fe0d9ae3          	bnez	s11,80200848 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200858:	00064783          	lbu	a5,0(a2)
    8020085c:	0007851b          	sext.w	a0,a5
    80200860:	e8051be3          	bnez	a0,802006f6 <vprintfmt+0x1a0>
    80200864:	b335                	j	80200590 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    80200866:	000aa403          	lw	s0,0(s5)
    8020086a:	bbf1                	j	80200646 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    8020086c:	000ae603          	lwu	a2,0(s5)
    80200870:	46a9                	li	a3,10
    80200872:	8aae                	mv	s5,a1
    80200874:	bd89                	j	802006c6 <vprintfmt+0x170>
    80200876:	000ae603          	lwu	a2,0(s5)
    8020087a:	46c1                	li	a3,16
    8020087c:	8aae                	mv	s5,a1
    8020087e:	b5a1                	j	802006c6 <vprintfmt+0x170>
    80200880:	000ae603          	lwu	a2,0(s5)
    80200884:	46a1                	li	a3,8
    80200886:	8aae                	mv	s5,a1
    80200888:	bd3d                	j	802006c6 <vprintfmt+0x170>
                    putch(ch, putdat);
    8020088a:	9902                	jalr	s2
    8020088c:	b559                	j	80200712 <vprintfmt+0x1bc>
                putch('-', putdat);
    8020088e:	85a6                	mv	a1,s1
    80200890:	02d00513          	li	a0,45
    80200894:	e03e                	sd	a5,0(sp)
    80200896:	9902                	jalr	s2
                num = -(long long)num;
    80200898:	8ace                	mv	s5,s3
    8020089a:	40800633          	neg	a2,s0
    8020089e:	46a9                	li	a3,10
    802008a0:	6782                	ld	a5,0(sp)
    802008a2:	b515                	j	802006c6 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    802008a4:	01b05663          	blez	s11,802008b0 <vprintfmt+0x35a>
    802008a8:	02d00693          	li	a3,45
    802008ac:	f6d798e3          	bne	a5,a3,8020081c <vprintfmt+0x2c6>
    802008b0:	00001417          	auipc	s0,0x1
    802008b4:	83140413          	addi	s0,s0,-1999 # 802010e1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008b8:	02800513          	li	a0,40
    802008bc:	02800793          	li	a5,40
    802008c0:	bd1d                	j	802006f6 <vprintfmt+0x1a0>

00000000802008c2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802008c2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802008c4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802008c8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802008ca:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802008cc:	ec06                	sd	ra,24(sp)
    802008ce:	f83a                	sd	a4,48(sp)
    802008d0:	fc3e                	sd	a5,56(sp)
    802008d2:	e0c2                	sd	a6,64(sp)
    802008d4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802008d6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802008d8:	c7fff0ef          	jal	ra,80200556 <vprintfmt>
}
    802008dc:	60e2                	ld	ra,24(sp)
    802008de:	6161                	addi	sp,sp,80
    802008e0:	8082                	ret

00000000802008e2 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802008e2:	00003797          	auipc	a5,0x3
    802008e6:	71e78793          	addi	a5,a5,1822 # 80204000 <bootstacktop>
    __asm__ volatile (
    802008ea:	6398                	ld	a4,0(a5)
    802008ec:	4781                	li	a5,0
    802008ee:	88ba                	mv	a7,a4
    802008f0:	852a                	mv	a0,a0
    802008f2:	85be                	mv	a1,a5
    802008f4:	863e                	mv	a2,a5
    802008f6:	00000073          	ecall
    802008fa:	87aa                	mv	a5,a0
}
    802008fc:	8082                	ret

00000000802008fe <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    802008fe:	00003797          	auipc	a5,0x3
    80200902:	70a78793          	addi	a5,a5,1802 # 80204008 <edata>
    __asm__ volatile (
    80200906:	6398                	ld	a4,0(a5)
    80200908:	4781                	li	a5,0
    8020090a:	88ba                	mv	a7,a4
    8020090c:	852a                	mv	a0,a0
    8020090e:	85be                	mv	a1,a5
    80200910:	863e                	mv	a2,a5
    80200912:	00000073          	ecall
    80200916:	87aa                	mv	a5,a0
}
    80200918:	8082                	ret

000000008020091a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    8020091a:	c185                	beqz	a1,8020093a <strnlen+0x20>
    8020091c:	00054783          	lbu	a5,0(a0)
    80200920:	cf89                	beqz	a5,8020093a <strnlen+0x20>
    size_t cnt = 0;
    80200922:	4781                	li	a5,0
    80200924:	a021                	j	8020092c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200926:	00074703          	lbu	a4,0(a4)
    8020092a:	c711                	beqz	a4,80200936 <strnlen+0x1c>
        cnt ++;
    8020092c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    8020092e:	00f50733          	add	a4,a0,a5
    80200932:	fef59ae3          	bne	a1,a5,80200926 <strnlen+0xc>
    }
    return cnt;
}
    80200936:	853e                	mv	a0,a5
    80200938:	8082                	ret
    size_t cnt = 0;
    8020093a:	4781                	li	a5,0
}
    8020093c:	853e                	mv	a0,a5
    8020093e:	8082                	ret

0000000080200940 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200940:	ca01                	beqz	a2,80200950 <memset+0x10>
    80200942:	962a                	add	a2,a2,a0
    char *p = s;
    80200944:	87aa                	mv	a5,a0
        *p ++ = c;
    80200946:	0785                	addi	a5,a5,1
    80200948:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    8020094c:	fec79de3          	bne	a5,a2,80200946 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200950:	8082                	ret
