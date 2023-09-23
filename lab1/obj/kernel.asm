
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
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	1a9000ef          	jal	ra,802009cc <memset>

    cons_init();  // init the console
    80200028:	14c000ef          	jal	ra,80200174 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	9b458593          	addi	a1,a1,-1612 # 802009e0 <etext+0x2>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	9cc50513          	addi	a0,a0,-1588 # 80200a00 <etext+0x22>
    8020003c:	030000ef          	jal	ra,8020006c <cprintf>

    print_kerninfo();
    80200040:	060000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	140000ef          	jal	ra,80200184 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0e8000ef          	jal	ra,80200130 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004c:	132000ef          	jal	ra,8020017e <intr_enable>
    
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
    8020005a:	11c000ef          	jal	ra,80200176 <cons_putc>
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
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end>
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
    80200094:	532000ef          	jal	ra,802005c6 <vprintfmt>
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
    802000a6:	96650513          	addi	a0,a0,-1690 # 80200a08 <etext+0x2a>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5c58593          	addi	a1,a1,-164 # 8020000c <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	97050513          	addi	a0,a0,-1680 # 80200a28 <etext+0x4a>
    802000c0:	fadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	91a58593          	addi	a1,a1,-1766 # 802009de <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	97c50513          	addi	a0,a0,-1668 # 80200a48 <etext+0x6a>
    802000d4:	f99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <edata>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	98850513          	addi	a0,a0,-1656 # 80200a68 <etext+0x8a>
    802000e8:	f85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	99450513          	addi	a0,a0,-1644 # 80200a88 <etext+0xaa>
    802000fc:	f71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
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
    80200126:	98650513          	addi	a0,a0,-1658 # 80200aa8 <etext+0xca>
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
    80200148:	027000ef          	jal	ra,8020096e <sbi_set_timer>
}
    8020014c:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014e:	00004797          	auipc	a5,0x4
    80200152:	ec07b923          	sd	zero,-302(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200156:	00001517          	auipc	a0,0x1
    8020015a:	98250513          	addi	a0,a0,-1662 # 80200ad8 <etext+0xfa>
}
    8020015e:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200160:	f0dff06f          	j	8020006c <cprintf>

0000000080200164 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200164:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200168:	67e1                	lui	a5,0x18
    8020016a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020016e:	953e                	add	a0,a0,a5
    80200170:	7fe0006f          	j	8020096e <sbi_set_timer>

0000000080200174 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200174:	8082                	ret

0000000080200176 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200176:	0ff57513          	andi	a0,a0,255
    8020017a:	7d80006f          	j	80200952 <sbi_console_putchar>

000000008020017e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020017e:	100167f3          	csrrsi	a5,sstatus,2
    80200182:	8082                	ret

0000000080200184 <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200184:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200188:	00000797          	auipc	a5,0x0
    8020018c:	31c78793          	addi	a5,a5,796 # 802004a4 <__alltraps>
    80200190:	10579073          	csrw	stvec,a5
}
    80200194:	8082                	ret

0000000080200196 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200196:	610c                	ld	a1,0(a0)
{
    80200198:	1141                	addi	sp,sp,-16
    8020019a:	e022                	sd	s0,0(sp)
    8020019c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019e:	00001517          	auipc	a0,0x1
    802001a2:	a3a50513          	addi	a0,a0,-1478 # 80200bd8 <etext+0x1fa>
{
    802001a6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a8:	ec5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ac:	640c                	ld	a1,8(s0)
    802001ae:	00001517          	auipc	a0,0x1
    802001b2:	a4250513          	addi	a0,a0,-1470 # 80200bf0 <etext+0x212>
    802001b6:	eb7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001ba:	680c                	ld	a1,16(s0)
    802001bc:	00001517          	auipc	a0,0x1
    802001c0:	a4c50513          	addi	a0,a0,-1460 # 80200c08 <etext+0x22a>
    802001c4:	ea9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c8:	6c0c                	ld	a1,24(s0)
    802001ca:	00001517          	auipc	a0,0x1
    802001ce:	a5650513          	addi	a0,a0,-1450 # 80200c20 <etext+0x242>
    802001d2:	e9bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d6:	700c                	ld	a1,32(s0)
    802001d8:	00001517          	auipc	a0,0x1
    802001dc:	a6050513          	addi	a0,a0,-1440 # 80200c38 <etext+0x25a>
    802001e0:	e8dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e4:	740c                	ld	a1,40(s0)
    802001e6:	00001517          	auipc	a0,0x1
    802001ea:	a6a50513          	addi	a0,a0,-1430 # 80200c50 <etext+0x272>
    802001ee:	e7fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f2:	780c                	ld	a1,48(s0)
    802001f4:	00001517          	auipc	a0,0x1
    802001f8:	a7450513          	addi	a0,a0,-1420 # 80200c68 <etext+0x28a>
    802001fc:	e71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200200:	7c0c                	ld	a1,56(s0)
    80200202:	00001517          	auipc	a0,0x1
    80200206:	a7e50513          	addi	a0,a0,-1410 # 80200c80 <etext+0x2a2>
    8020020a:	e63ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020e:	602c                	ld	a1,64(s0)
    80200210:	00001517          	auipc	a0,0x1
    80200214:	a8850513          	addi	a0,a0,-1400 # 80200c98 <etext+0x2ba>
    80200218:	e55ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020021c:	642c                	ld	a1,72(s0)
    8020021e:	00001517          	auipc	a0,0x1
    80200222:	a9250513          	addi	a0,a0,-1390 # 80200cb0 <etext+0x2d2>
    80200226:	e47ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022a:	682c                	ld	a1,80(s0)
    8020022c:	00001517          	auipc	a0,0x1
    80200230:	a9c50513          	addi	a0,a0,-1380 # 80200cc8 <etext+0x2ea>
    80200234:	e39ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200238:	6c2c                	ld	a1,88(s0)
    8020023a:	00001517          	auipc	a0,0x1
    8020023e:	aa650513          	addi	a0,a0,-1370 # 80200ce0 <etext+0x302>
    80200242:	e2bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200246:	702c                	ld	a1,96(s0)
    80200248:	00001517          	auipc	a0,0x1
    8020024c:	ab050513          	addi	a0,a0,-1360 # 80200cf8 <etext+0x31a>
    80200250:	e1dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200254:	742c                	ld	a1,104(s0)
    80200256:	00001517          	auipc	a0,0x1
    8020025a:	aba50513          	addi	a0,a0,-1350 # 80200d10 <etext+0x332>
    8020025e:	e0fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200262:	782c                	ld	a1,112(s0)
    80200264:	00001517          	auipc	a0,0x1
    80200268:	ac450513          	addi	a0,a0,-1340 # 80200d28 <etext+0x34a>
    8020026c:	e01ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200270:	7c2c                	ld	a1,120(s0)
    80200272:	00001517          	auipc	a0,0x1
    80200276:	ace50513          	addi	a0,a0,-1330 # 80200d40 <etext+0x362>
    8020027a:	df3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027e:	604c                	ld	a1,128(s0)
    80200280:	00001517          	auipc	a0,0x1
    80200284:	ad850513          	addi	a0,a0,-1320 # 80200d58 <etext+0x37a>
    80200288:	de5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020028c:	644c                	ld	a1,136(s0)
    8020028e:	00001517          	auipc	a0,0x1
    80200292:	ae250513          	addi	a0,a0,-1310 # 80200d70 <etext+0x392>
    80200296:	dd7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029a:	684c                	ld	a1,144(s0)
    8020029c:	00001517          	auipc	a0,0x1
    802002a0:	aec50513          	addi	a0,a0,-1300 # 80200d88 <etext+0x3aa>
    802002a4:	dc9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a8:	6c4c                	ld	a1,152(s0)
    802002aa:	00001517          	auipc	a0,0x1
    802002ae:	af650513          	addi	a0,a0,-1290 # 80200da0 <etext+0x3c2>
    802002b2:	dbbff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b6:	704c                	ld	a1,160(s0)
    802002b8:	00001517          	auipc	a0,0x1
    802002bc:	b0050513          	addi	a0,a0,-1280 # 80200db8 <etext+0x3da>
    802002c0:	dadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c4:	744c                	ld	a1,168(s0)
    802002c6:	00001517          	auipc	a0,0x1
    802002ca:	b0a50513          	addi	a0,a0,-1270 # 80200dd0 <etext+0x3f2>
    802002ce:	d9fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d2:	784c                	ld	a1,176(s0)
    802002d4:	00001517          	auipc	a0,0x1
    802002d8:	b1450513          	addi	a0,a0,-1260 # 80200de8 <etext+0x40a>
    802002dc:	d91ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e0:	7c4c                	ld	a1,184(s0)
    802002e2:	00001517          	auipc	a0,0x1
    802002e6:	b1e50513          	addi	a0,a0,-1250 # 80200e00 <etext+0x422>
    802002ea:	d83ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ee:	606c                	ld	a1,192(s0)
    802002f0:	00001517          	auipc	a0,0x1
    802002f4:	b2850513          	addi	a0,a0,-1240 # 80200e18 <etext+0x43a>
    802002f8:	d75ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002fc:	646c                	ld	a1,200(s0)
    802002fe:	00001517          	auipc	a0,0x1
    80200302:	b3250513          	addi	a0,a0,-1230 # 80200e30 <etext+0x452>
    80200306:	d67ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030a:	686c                	ld	a1,208(s0)
    8020030c:	00001517          	auipc	a0,0x1
    80200310:	b3c50513          	addi	a0,a0,-1220 # 80200e48 <etext+0x46a>
    80200314:	d59ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200318:	6c6c                	ld	a1,216(s0)
    8020031a:	00001517          	auipc	a0,0x1
    8020031e:	b4650513          	addi	a0,a0,-1210 # 80200e60 <etext+0x482>
    80200322:	d4bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200326:	706c                	ld	a1,224(s0)
    80200328:	00001517          	auipc	a0,0x1
    8020032c:	b5050513          	addi	a0,a0,-1200 # 80200e78 <etext+0x49a>
    80200330:	d3dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200334:	746c                	ld	a1,232(s0)
    80200336:	00001517          	auipc	a0,0x1
    8020033a:	b5a50513          	addi	a0,a0,-1190 # 80200e90 <etext+0x4b2>
    8020033e:	d2fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200342:	786c                	ld	a1,240(s0)
    80200344:	00001517          	auipc	a0,0x1
    80200348:	b6450513          	addi	a0,a0,-1180 # 80200ea8 <etext+0x4ca>
    8020034c:	d21ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	7c6c                	ld	a1,248(s0)
}
    80200352:	6402                	ld	s0,0(sp)
    80200354:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	00001517          	auipc	a0,0x1
    8020035a:	b6a50513          	addi	a0,a0,-1174 # 80200ec0 <etext+0x4e2>
}
    8020035e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200360:	d0dff06f          	j	8020006c <cprintf>

0000000080200364 <print_trapframe>:
{
    80200364:	1141                	addi	sp,sp,-16
    80200366:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200368:	85aa                	mv	a1,a0
{
    8020036a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020036c:	00001517          	auipc	a0,0x1
    80200370:	b6c50513          	addi	a0,a0,-1172 # 80200ed8 <etext+0x4fa>
{
    80200374:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200376:	cf7ff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    8020037a:	8522                	mv	a0,s0
    8020037c:	e1bff0ef          	jal	ra,80200196 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200380:	10043583          	ld	a1,256(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	b6c50513          	addi	a0,a0,-1172 # 80200ef0 <etext+0x512>
    8020038c:	ce1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200390:	10843583          	ld	a1,264(s0)
    80200394:	00001517          	auipc	a0,0x1
    80200398:	b7450513          	addi	a0,a0,-1164 # 80200f08 <etext+0x52a>
    8020039c:	cd1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a0:	11043583          	ld	a1,272(s0)
    802003a4:	00001517          	auipc	a0,0x1
    802003a8:	b7c50513          	addi	a0,a0,-1156 # 80200f20 <etext+0x542>
    802003ac:	cc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b0:	11843583          	ld	a1,280(s0)
}
    802003b4:	6402                	ld	s0,0(sp)
    802003b6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b8:	00001517          	auipc	a0,0x1
    802003bc:	b8050513          	addi	a0,a0,-1152 # 80200f38 <etext+0x55a>
}
    802003c0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c2:	cabff06f          	j	8020006c <cprintf>

00000000802003c6 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c6:	11853783          	ld	a5,280(a0)
    802003ca:	577d                	li	a4,-1
    802003cc:	8305                	srli	a4,a4,0x1
    802003ce:	8ff9                	and	a5,a5,a4
    switch (cause)
    802003d0:	472d                	li	a4,11
    802003d2:	08f76063          	bltu	a4,a5,80200452 <interrupt_handler+0x8c>
    802003d6:	00000717          	auipc	a4,0x0
    802003da:	71e70713          	addi	a4,a4,1822 # 80200af4 <etext+0x116>
    802003de:	078a                	slli	a5,a5,0x2
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	439c                	lw	a5,0(a5)
    802003e4:	97ba                	add	a5,a5,a4
    802003e6:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
    802003e8:	00000517          	auipc	a0,0x0
    802003ec:	7a050513          	addi	a0,a0,1952 # 80200b88 <etext+0x1aa>
    802003f0:	c7dff06f          	j	8020006c <cprintf>
        cprintf("Hypervisor software interrupt\n");
    802003f4:	00000517          	auipc	a0,0x0
    802003f8:	77450513          	addi	a0,a0,1908 # 80200b68 <etext+0x18a>
    802003fc:	c71ff06f          	j	8020006c <cprintf>
        cprintf("User software interrupt\n");
    80200400:	00000517          	auipc	a0,0x0
    80200404:	72850513          	addi	a0,a0,1832 # 80200b28 <etext+0x14a>
    80200408:	c65ff06f          	j	8020006c <cprintf>
        cprintf("Supervisor software interrupt\n");
    8020040c:	00000517          	auipc	a0,0x0
    80200410:	73c50513          	addi	a0,a0,1852 # 80200b48 <etext+0x16a>
    80200414:	c59ff06f          	j	8020006c <cprintf>
        break;
    case IRQ_U_EXT:
        cprintf("User software interrupt\n");
        break;
    case IRQ_S_EXT:
        cprintf("Supervisor external interrupt\n");
    80200418:	00000517          	auipc	a0,0x0
    8020041c:	7a050513          	addi	a0,a0,1952 # 80200bb8 <etext+0x1da>
    80200420:	c4dff06f          	j	8020006c <cprintf>
{
    80200424:	1141                	addi	sp,sp,-16
    80200426:	e406                	sd	ra,8(sp)
        clock_set_next_event();
    80200428:	d3dff0ef          	jal	ra,80200164 <clock_set_next_event>
        ticks++;
    8020042c:	00004717          	auipc	a4,0x4
    80200430:	bf470713          	addi	a4,a4,-1036 # 80204020 <ticks>
    80200434:	631c                	ld	a5,0(a4)
    80200436:	0785                	addi	a5,a5,1
    80200438:	00004697          	auipc	a3,0x4
    8020043c:	bef6b423          	sd	a5,-1048(a3) # 80204020 <ticks>
        if (ticks % TICK_NUM == 0)
    80200440:	631c                	ld	a5,0(a4)
    80200442:	06400713          	li	a4,100
    80200446:	02e7f7b3          	remu	a5,a5,a4
    8020044a:	c791                	beqz	a5,80200456 <interrupt_handler+0x90>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
    8020044c:	60a2                	ld	ra,8(sp)
    8020044e:	0141                	addi	sp,sp,16
    80200450:	8082                	ret
        print_trapframe(tf);
    80200452:	f13ff06f          	j	80200364 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200456:	06400593          	li	a1,100
    8020045a:	00000517          	auipc	a0,0x0
    8020045e:	74e50513          	addi	a0,a0,1870 # 80200ba8 <etext+0x1ca>
    80200462:	c0bff0ef          	jal	ra,8020006c <cprintf>
            num += 1;
    80200466:	00004717          	auipc	a4,0x4
    8020046a:	baa70713          	addi	a4,a4,-1110 # 80204010 <edata>
    8020046e:	631c                	ld	a5,0(a4)
            if (num == 10) 
    80200470:	46a9                	li	a3,10
            num += 1;
    80200472:	0785                	addi	a5,a5,1
    80200474:	00004617          	auipc	a2,0x4
    80200478:	b8f63e23          	sd	a5,-1124(a2) # 80204010 <edata>
            if (num == 10) 
    8020047c:	631c                	ld	a5,0(a4)
    8020047e:	fcd797e3          	bne	a5,a3,8020044c <interrupt_handler+0x86>
}
    80200482:	60a2                	ld	ra,8(sp)
    80200484:	0141                	addi	sp,sp,16
                sbi_shutdown();
    80200486:	5040006f          	j	8020098a <sbi_shutdown>

000000008020048a <trap>:
}

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf)
{
    if ((intptr_t)tf->cause < 0)
    8020048a:	11853783          	ld	a5,280(a0)
    8020048e:	0007c863          	bltz	a5,8020049e <trap+0x14>
    switch (tf->cause)
    80200492:	472d                	li	a4,11
    80200494:	00f76363          	bltu	a4,a5,8020049a <trap+0x10>
 * trap - handles or dispatches an exception/interrupt. if and when trap()
 * returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) { trap_dispatch(tf); }
    80200498:	8082                	ret
        print_trapframe(tf);
    8020049a:	ecbff06f          	j	80200364 <print_trapframe>
        interrupt_handler(tf);
    8020049e:	f29ff06f          	j	802003c6 <interrupt_handler>
	...

00000000802004a4 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    802004a4:	14011073          	csrw	sscratch,sp
    802004a8:	712d                	addi	sp,sp,-288
    802004aa:	e002                	sd	zero,0(sp)
    802004ac:	e406                	sd	ra,8(sp)
    802004ae:	ec0e                	sd	gp,24(sp)
    802004b0:	f012                	sd	tp,32(sp)
    802004b2:	f416                	sd	t0,40(sp)
    802004b4:	f81a                	sd	t1,48(sp)
    802004b6:	fc1e                	sd	t2,56(sp)
    802004b8:	e0a2                	sd	s0,64(sp)
    802004ba:	e4a6                	sd	s1,72(sp)
    802004bc:	e8aa                	sd	a0,80(sp)
    802004be:	ecae                	sd	a1,88(sp)
    802004c0:	f0b2                	sd	a2,96(sp)
    802004c2:	f4b6                	sd	a3,104(sp)
    802004c4:	f8ba                	sd	a4,112(sp)
    802004c6:	fcbe                	sd	a5,120(sp)
    802004c8:	e142                	sd	a6,128(sp)
    802004ca:	e546                	sd	a7,136(sp)
    802004cc:	e94a                	sd	s2,144(sp)
    802004ce:	ed4e                	sd	s3,152(sp)
    802004d0:	f152                	sd	s4,160(sp)
    802004d2:	f556                	sd	s5,168(sp)
    802004d4:	f95a                	sd	s6,176(sp)
    802004d6:	fd5e                	sd	s7,184(sp)
    802004d8:	e1e2                	sd	s8,192(sp)
    802004da:	e5e6                	sd	s9,200(sp)
    802004dc:	e9ea                	sd	s10,208(sp)
    802004de:	edee                	sd	s11,216(sp)
    802004e0:	f1f2                	sd	t3,224(sp)
    802004e2:	f5f6                	sd	t4,232(sp)
    802004e4:	f9fa                	sd	t5,240(sp)
    802004e6:	fdfe                	sd	t6,248(sp)
    802004e8:	14001473          	csrrw	s0,sscratch,zero
    802004ec:	100024f3          	csrr	s1,sstatus
    802004f0:	14102973          	csrr	s2,sepc
    802004f4:	143029f3          	csrr	s3,stval
    802004f8:	14202a73          	csrr	s4,scause
    802004fc:	e822                	sd	s0,16(sp)
    802004fe:	e226                	sd	s1,256(sp)
    80200500:	e64a                	sd	s2,264(sp)
    80200502:	ea4e                	sd	s3,272(sp)
    80200504:	ee52                	sd	s4,280(sp)

    move  a0, sp
    80200506:	850a                	mv	a0,sp
    jal trap
    80200508:	f83ff0ef          	jal	ra,8020048a <trap>

000000008020050c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    8020050c:	6492                	ld	s1,256(sp)
    8020050e:	6932                	ld	s2,264(sp)
    80200510:	10049073          	csrw	sstatus,s1
    80200514:	14191073          	csrw	sepc,s2
    80200518:	60a2                	ld	ra,8(sp)
    8020051a:	61e2                	ld	gp,24(sp)
    8020051c:	7202                	ld	tp,32(sp)
    8020051e:	72a2                	ld	t0,40(sp)
    80200520:	7342                	ld	t1,48(sp)
    80200522:	73e2                	ld	t2,56(sp)
    80200524:	6406                	ld	s0,64(sp)
    80200526:	64a6                	ld	s1,72(sp)
    80200528:	6546                	ld	a0,80(sp)
    8020052a:	65e6                	ld	a1,88(sp)
    8020052c:	7606                	ld	a2,96(sp)
    8020052e:	76a6                	ld	a3,104(sp)
    80200530:	7746                	ld	a4,112(sp)
    80200532:	77e6                	ld	a5,120(sp)
    80200534:	680a                	ld	a6,128(sp)
    80200536:	68aa                	ld	a7,136(sp)
    80200538:	694a                	ld	s2,144(sp)
    8020053a:	69ea                	ld	s3,152(sp)
    8020053c:	7a0a                	ld	s4,160(sp)
    8020053e:	7aaa                	ld	s5,168(sp)
    80200540:	7b4a                	ld	s6,176(sp)
    80200542:	7bea                	ld	s7,184(sp)
    80200544:	6c0e                	ld	s8,192(sp)
    80200546:	6cae                	ld	s9,200(sp)
    80200548:	6d4e                	ld	s10,208(sp)
    8020054a:	6dee                	ld	s11,216(sp)
    8020054c:	7e0e                	ld	t3,224(sp)
    8020054e:	7eae                	ld	t4,232(sp)
    80200550:	7f4e                	ld	t5,240(sp)
    80200552:	7fee                	ld	t6,248(sp)
    80200554:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    80200556:	10200073          	sret

000000008020055a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    8020055a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020055e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200560:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200564:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200566:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    8020056a:	f022                	sd	s0,32(sp)
    8020056c:	ec26                	sd	s1,24(sp)
    8020056e:	e84a                	sd	s2,16(sp)
    80200570:	f406                	sd	ra,40(sp)
    80200572:	e44e                	sd	s3,8(sp)
    80200574:	84aa                	mv	s1,a0
    80200576:	892e                	mv	s2,a1
    80200578:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    8020057c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    8020057e:	03067e63          	bleu	a6,a2,802005ba <printnum+0x60>
    80200582:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200584:	00805763          	blez	s0,80200592 <printnum+0x38>
    80200588:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020058a:	85ca                	mv	a1,s2
    8020058c:	854e                	mv	a0,s3
    8020058e:	9482                	jalr	s1
        while (-- width > 0)
    80200590:	fc65                	bnez	s0,80200588 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200592:	1a02                	slli	s4,s4,0x20
    80200594:	020a5a13          	srli	s4,s4,0x20
    80200598:	00001797          	auipc	a5,0x1
    8020059c:	b4878793          	addi	a5,a5,-1208 # 802010e0 <error_string+0x38>
    802005a0:	9a3e                	add	s4,s4,a5
}
    802005a2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005a4:	000a4503          	lbu	a0,0(s4)
}
    802005a8:	70a2                	ld	ra,40(sp)
    802005aa:	69a2                	ld	s3,8(sp)
    802005ac:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005ae:	85ca                	mv	a1,s2
    802005b0:	8326                	mv	t1,s1
}
    802005b2:	6942                	ld	s2,16(sp)
    802005b4:	64e2                	ld	s1,24(sp)
    802005b6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    802005b8:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    802005ba:	03065633          	divu	a2,a2,a6
    802005be:	8722                	mv	a4,s0
    802005c0:	f9bff0ef          	jal	ra,8020055a <printnum>
    802005c4:	b7f9                	j	80200592 <printnum+0x38>

00000000802005c6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802005c6:	7119                	addi	sp,sp,-128
    802005c8:	f4a6                	sd	s1,104(sp)
    802005ca:	f0ca                	sd	s2,96(sp)
    802005cc:	e8d2                	sd	s4,80(sp)
    802005ce:	e4d6                	sd	s5,72(sp)
    802005d0:	e0da                	sd	s6,64(sp)
    802005d2:	fc5e                	sd	s7,56(sp)
    802005d4:	f862                	sd	s8,48(sp)
    802005d6:	f06a                	sd	s10,32(sp)
    802005d8:	fc86                	sd	ra,120(sp)
    802005da:	f8a2                	sd	s0,112(sp)
    802005dc:	ecce                	sd	s3,88(sp)
    802005de:	f466                	sd	s9,40(sp)
    802005e0:	ec6e                	sd	s11,24(sp)
    802005e2:	892a                	mv	s2,a0
    802005e4:	84ae                	mv	s1,a1
    802005e6:	8d32                	mv	s10,a2
    802005e8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    802005ea:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    802005ec:	00001a17          	auipc	s4,0x1
    802005f0:	960a0a13          	addi	s4,s4,-1696 # 80200f4c <etext+0x56e>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    802005f4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802005f8:	00001c17          	auipc	s8,0x1
    802005fc:	ab0c0c13          	addi	s8,s8,-1360 # 802010a8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200600:	000d4503          	lbu	a0,0(s10)
    80200604:	02500793          	li	a5,37
    80200608:	001d0413          	addi	s0,s10,1
    8020060c:	00f50e63          	beq	a0,a5,80200628 <vprintfmt+0x62>
            if (ch == '\0') {
    80200610:	c521                	beqz	a0,80200658 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200612:	02500993          	li	s3,37
    80200616:	a011                	j	8020061a <vprintfmt+0x54>
            if (ch == '\0') {
    80200618:	c121                	beqz	a0,80200658 <vprintfmt+0x92>
            putch(ch, putdat);
    8020061a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020061c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    8020061e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200620:	fff44503          	lbu	a0,-1(s0)
    80200624:	ff351ae3          	bne	a0,s3,80200618 <vprintfmt+0x52>
    80200628:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    8020062c:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200630:	4981                	li	s3,0
    80200632:	4801                	li	a6,0
        width = precision = -1;
    80200634:	5cfd                	li	s9,-1
    80200636:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    80200638:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    8020063c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    8020063e:	fdd6069b          	addiw	a3,a2,-35
    80200642:	0ff6f693          	andi	a3,a3,255
    80200646:	00140d13          	addi	s10,s0,1
    8020064a:	20d5e563          	bltu	a1,a3,80200854 <vprintfmt+0x28e>
    8020064e:	068a                	slli	a3,a3,0x2
    80200650:	96d2                	add	a3,a3,s4
    80200652:	4294                	lw	a3,0(a3)
    80200654:	96d2                	add	a3,a3,s4
    80200656:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200658:	70e6                	ld	ra,120(sp)
    8020065a:	7446                	ld	s0,112(sp)
    8020065c:	74a6                	ld	s1,104(sp)
    8020065e:	7906                	ld	s2,96(sp)
    80200660:	69e6                	ld	s3,88(sp)
    80200662:	6a46                	ld	s4,80(sp)
    80200664:	6aa6                	ld	s5,72(sp)
    80200666:	6b06                	ld	s6,64(sp)
    80200668:	7be2                	ld	s7,56(sp)
    8020066a:	7c42                	ld	s8,48(sp)
    8020066c:	7ca2                	ld	s9,40(sp)
    8020066e:	7d02                	ld	s10,32(sp)
    80200670:	6de2                	ld	s11,24(sp)
    80200672:	6109                	addi	sp,sp,128
    80200674:	8082                	ret
    if (lflag >= 2) {
    80200676:	4705                	li	a4,1
    80200678:	008a8593          	addi	a1,s5,8
    8020067c:	01074463          	blt	a4,a6,80200684 <vprintfmt+0xbe>
    else if (lflag) {
    80200680:	26080363          	beqz	a6,802008e6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200684:	000ab603          	ld	a2,0(s5)
    80200688:	46c1                	li	a3,16
    8020068a:	8aae                	mv	s5,a1
    8020068c:	a06d                	j	80200736 <vprintfmt+0x170>
            goto reswitch;
    8020068e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200692:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200694:	846a                	mv	s0,s10
            goto reswitch;
    80200696:	b765                	j	8020063e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    80200698:	000aa503          	lw	a0,0(s5)
    8020069c:	85a6                	mv	a1,s1
    8020069e:	0aa1                	addi	s5,s5,8
    802006a0:	9902                	jalr	s2
            break;
    802006a2:	bfb9                	j	80200600 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802006a4:	4705                	li	a4,1
    802006a6:	008a8993          	addi	s3,s5,8
    802006aa:	01074463          	blt	a4,a6,802006b2 <vprintfmt+0xec>
    else if (lflag) {
    802006ae:	22080463          	beqz	a6,802008d6 <vprintfmt+0x310>
        return va_arg(*ap, long);
    802006b2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    802006b6:	24044463          	bltz	s0,802008fe <vprintfmt+0x338>
            num = getint(&ap, lflag);
    802006ba:	8622                	mv	a2,s0
    802006bc:	8ace                	mv	s5,s3
    802006be:	46a9                	li	a3,10
    802006c0:	a89d                	j	80200736 <vprintfmt+0x170>
            err = va_arg(ap, int);
    802006c2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006c6:	4719                	li	a4,6
            err = va_arg(ap, int);
    802006c8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    802006ca:	41f7d69b          	sraiw	a3,a5,0x1f
    802006ce:	8fb5                	xor	a5,a5,a3
    802006d0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006d4:	1ad74363          	blt	a4,a3,8020087a <vprintfmt+0x2b4>
    802006d8:	00369793          	slli	a5,a3,0x3
    802006dc:	97e2                	add	a5,a5,s8
    802006de:	639c                	ld	a5,0(a5)
    802006e0:	18078d63          	beqz	a5,8020087a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    802006e4:	86be                	mv	a3,a5
    802006e6:	00001617          	auipc	a2,0x1
    802006ea:	aaa60613          	addi	a2,a2,-1366 # 80201190 <error_string+0xe8>
    802006ee:	85a6                	mv	a1,s1
    802006f0:	854a                	mv	a0,s2
    802006f2:	240000ef          	jal	ra,80200932 <printfmt>
    802006f6:	b729                	j	80200600 <vprintfmt+0x3a>
            lflag ++;
    802006f8:	00144603          	lbu	a2,1(s0)
    802006fc:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    802006fe:	846a                	mv	s0,s10
            goto reswitch;
    80200700:	bf3d                	j	8020063e <vprintfmt+0x78>
    if (lflag >= 2) {
    80200702:	4705                	li	a4,1
    80200704:	008a8593          	addi	a1,s5,8
    80200708:	01074463          	blt	a4,a6,80200710 <vprintfmt+0x14a>
    else if (lflag) {
    8020070c:	1e080263          	beqz	a6,802008f0 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    80200710:	000ab603          	ld	a2,0(s5)
    80200714:	46a1                	li	a3,8
    80200716:	8aae                	mv	s5,a1
    80200718:	a839                	j	80200736 <vprintfmt+0x170>
            putch('0', putdat);
    8020071a:	03000513          	li	a0,48
    8020071e:	85a6                	mv	a1,s1
    80200720:	e03e                	sd	a5,0(sp)
    80200722:	9902                	jalr	s2
            putch('x', putdat);
    80200724:	85a6                	mv	a1,s1
    80200726:	07800513          	li	a0,120
    8020072a:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    8020072c:	0aa1                	addi	s5,s5,8
    8020072e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    80200732:	6782                	ld	a5,0(sp)
    80200734:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    80200736:	876e                	mv	a4,s11
    80200738:	85a6                	mv	a1,s1
    8020073a:	854a                	mv	a0,s2
    8020073c:	e1fff0ef          	jal	ra,8020055a <printnum>
            break;
    80200740:	b5c1                	j	80200600 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200742:	000ab603          	ld	a2,0(s5)
    80200746:	0aa1                	addi	s5,s5,8
    80200748:	1c060663          	beqz	a2,80200914 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    8020074c:	00160413          	addi	s0,a2,1
    80200750:	17b05c63          	blez	s11,802008c8 <vprintfmt+0x302>
    80200754:	02d00593          	li	a1,45
    80200758:	14b79263          	bne	a5,a1,8020089c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020075c:	00064783          	lbu	a5,0(a2)
    80200760:	0007851b          	sext.w	a0,a5
    80200764:	c905                	beqz	a0,80200794 <vprintfmt+0x1ce>
    80200766:	000cc563          	bltz	s9,80200770 <vprintfmt+0x1aa>
    8020076a:	3cfd                	addiw	s9,s9,-1
    8020076c:	036c8263          	beq	s9,s6,80200790 <vprintfmt+0x1ca>
                    putch('?', putdat);
    80200770:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200772:	18098463          	beqz	s3,802008fa <vprintfmt+0x334>
    80200776:	3781                	addiw	a5,a5,-32
    80200778:	18fbf163          	bleu	a5,s7,802008fa <vprintfmt+0x334>
                    putch('?', putdat);
    8020077c:	03f00513          	li	a0,63
    80200780:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200782:	0405                	addi	s0,s0,1
    80200784:	fff44783          	lbu	a5,-1(s0)
    80200788:	3dfd                	addiw	s11,s11,-1
    8020078a:	0007851b          	sext.w	a0,a5
    8020078e:	fd61                	bnez	a0,80200766 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200790:	e7b058e3          	blez	s11,80200600 <vprintfmt+0x3a>
    80200794:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200796:	85a6                	mv	a1,s1
    80200798:	02000513          	li	a0,32
    8020079c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020079e:	e60d81e3          	beqz	s11,80200600 <vprintfmt+0x3a>
    802007a2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802007a4:	85a6                	mv	a1,s1
    802007a6:	02000513          	li	a0,32
    802007aa:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007ac:	fe0d94e3          	bnez	s11,80200794 <vprintfmt+0x1ce>
    802007b0:	bd81                	j	80200600 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007b2:	4705                	li	a4,1
    802007b4:	008a8593          	addi	a1,s5,8
    802007b8:	01074463          	blt	a4,a6,802007c0 <vprintfmt+0x1fa>
    else if (lflag) {
    802007bc:	12080063          	beqz	a6,802008dc <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    802007c0:	000ab603          	ld	a2,0(s5)
    802007c4:	46a9                	li	a3,10
    802007c6:	8aae                	mv	s5,a1
    802007c8:	b7bd                	j	80200736 <vprintfmt+0x170>
    802007ca:	00144603          	lbu	a2,1(s0)
            padc = '-';
    802007ce:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    802007d2:	846a                	mv	s0,s10
    802007d4:	b5ad                	j	8020063e <vprintfmt+0x78>
            putch(ch, putdat);
    802007d6:	85a6                	mv	a1,s1
    802007d8:	02500513          	li	a0,37
    802007dc:	9902                	jalr	s2
            break;
    802007de:	b50d                	j	80200600 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    802007e0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    802007e4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    802007e8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    802007ea:	846a                	mv	s0,s10
            if (width < 0)
    802007ec:	e40dd9e3          	bgez	s11,8020063e <vprintfmt+0x78>
                width = precision, precision = -1;
    802007f0:	8de6                	mv	s11,s9
    802007f2:	5cfd                	li	s9,-1
    802007f4:	b5a9                	j	8020063e <vprintfmt+0x78>
            goto reswitch;
    802007f6:	00144603          	lbu	a2,1(s0)
            padc = '0';
    802007fa:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    802007fe:	846a                	mv	s0,s10
            goto reswitch;
    80200800:	bd3d                	j	8020063e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    80200802:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    80200806:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020080a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    8020080c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200810:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200814:	fcd56ce3          	bltu	a0,a3,802007ec <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    80200818:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020081a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    8020081e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    80200822:	0196873b          	addw	a4,a3,s9
    80200826:	0017171b          	slliw	a4,a4,0x1
    8020082a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    8020082e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    80200832:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    80200836:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    8020083a:	fcd57fe3          	bleu	a3,a0,80200818 <vprintfmt+0x252>
    8020083e:	b77d                	j	802007ec <vprintfmt+0x226>
            if (width < 0)
    80200840:	fffdc693          	not	a3,s11
    80200844:	96fd                	srai	a3,a3,0x3f
    80200846:	00ddfdb3          	and	s11,s11,a3
    8020084a:	00144603          	lbu	a2,1(s0)
    8020084e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    80200850:	846a                	mv	s0,s10
    80200852:	b3f5                	j	8020063e <vprintfmt+0x78>
            putch('%', putdat);
    80200854:	85a6                	mv	a1,s1
    80200856:	02500513          	li	a0,37
    8020085a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    8020085c:	fff44703          	lbu	a4,-1(s0)
    80200860:	02500793          	li	a5,37
    80200864:	8d22                	mv	s10,s0
    80200866:	d8f70de3          	beq	a4,a5,80200600 <vprintfmt+0x3a>
    8020086a:	02500713          	li	a4,37
    8020086e:	1d7d                	addi	s10,s10,-1
    80200870:	fffd4783          	lbu	a5,-1(s10)
    80200874:	fee79de3          	bne	a5,a4,8020086e <vprintfmt+0x2a8>
    80200878:	b361                	j	80200600 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020087a:	00001617          	auipc	a2,0x1
    8020087e:	90660613          	addi	a2,a2,-1786 # 80201180 <error_string+0xd8>
    80200882:	85a6                	mv	a1,s1
    80200884:	854a                	mv	a0,s2
    80200886:	0ac000ef          	jal	ra,80200932 <printfmt>
    8020088a:	bb9d                	j	80200600 <vprintfmt+0x3a>
                p = "(null)";
    8020088c:	00001617          	auipc	a2,0x1
    80200890:	8ec60613          	addi	a2,a2,-1812 # 80201178 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200894:	00001417          	auipc	s0,0x1
    80200898:	8e540413          	addi	s0,s0,-1819 # 80201179 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020089c:	8532                	mv	a0,a2
    8020089e:	85e6                	mv	a1,s9
    802008a0:	e032                	sd	a2,0(sp)
    802008a2:	e43e                	sd	a5,8(sp)
    802008a4:	102000ef          	jal	ra,802009a6 <strnlen>
    802008a8:	40ad8dbb          	subw	s11,s11,a0
    802008ac:	6602                	ld	a2,0(sp)
    802008ae:	01b05d63          	blez	s11,802008c8 <vprintfmt+0x302>
    802008b2:	67a2                	ld	a5,8(sp)
    802008b4:	2781                	sext.w	a5,a5
    802008b6:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    802008b8:	6522                	ld	a0,8(sp)
    802008ba:	85a6                	mv	a1,s1
    802008bc:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008be:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    802008c0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008c2:	6602                	ld	a2,0(sp)
    802008c4:	fe0d9ae3          	bnez	s11,802008b8 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008c8:	00064783          	lbu	a5,0(a2)
    802008cc:	0007851b          	sext.w	a0,a5
    802008d0:	e8051be3          	bnez	a0,80200766 <vprintfmt+0x1a0>
    802008d4:	b335                	j	80200600 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    802008d6:	000aa403          	lw	s0,0(s5)
    802008da:	bbf1                	j	802006b6 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    802008dc:	000ae603          	lwu	a2,0(s5)
    802008e0:	46a9                	li	a3,10
    802008e2:	8aae                	mv	s5,a1
    802008e4:	bd89                	j	80200736 <vprintfmt+0x170>
    802008e6:	000ae603          	lwu	a2,0(s5)
    802008ea:	46c1                	li	a3,16
    802008ec:	8aae                	mv	s5,a1
    802008ee:	b5a1                	j	80200736 <vprintfmt+0x170>
    802008f0:	000ae603          	lwu	a2,0(s5)
    802008f4:	46a1                	li	a3,8
    802008f6:	8aae                	mv	s5,a1
    802008f8:	bd3d                	j	80200736 <vprintfmt+0x170>
                    putch(ch, putdat);
    802008fa:	9902                	jalr	s2
    802008fc:	b559                	j	80200782 <vprintfmt+0x1bc>
                putch('-', putdat);
    802008fe:	85a6                	mv	a1,s1
    80200900:	02d00513          	li	a0,45
    80200904:	e03e                	sd	a5,0(sp)
    80200906:	9902                	jalr	s2
                num = -(long long)num;
    80200908:	8ace                	mv	s5,s3
    8020090a:	40800633          	neg	a2,s0
    8020090e:	46a9                	li	a3,10
    80200910:	6782                	ld	a5,0(sp)
    80200912:	b515                	j	80200736 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    80200914:	01b05663          	blez	s11,80200920 <vprintfmt+0x35a>
    80200918:	02d00693          	li	a3,45
    8020091c:	f6d798e3          	bne	a5,a3,8020088c <vprintfmt+0x2c6>
    80200920:	00001417          	auipc	s0,0x1
    80200924:	85940413          	addi	s0,s0,-1959 # 80201179 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200928:	02800513          	li	a0,40
    8020092c:	02800793          	li	a5,40
    80200930:	bd1d                	j	80200766 <vprintfmt+0x1a0>

0000000080200932 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200932:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200934:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200938:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020093a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020093c:	ec06                	sd	ra,24(sp)
    8020093e:	f83a                	sd	a4,48(sp)
    80200940:	fc3e                	sd	a5,56(sp)
    80200942:	e0c2                	sd	a6,64(sp)
    80200944:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200946:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200948:	c7fff0ef          	jal	ra,802005c6 <vprintfmt>
}
    8020094c:	60e2                	ld	ra,24(sp)
    8020094e:	6161                	addi	sp,sp,80
    80200950:	8082                	ret

0000000080200952 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    80200952:	00003797          	auipc	a5,0x3
    80200956:	6ae78793          	addi	a5,a5,1710 # 80204000 <bootstacktop>
    __asm__ volatile (
    8020095a:	6398                	ld	a4,0(a5)
    8020095c:	4781                	li	a5,0
    8020095e:	88ba                	mv	a7,a4
    80200960:	852a                	mv	a0,a0
    80200962:	85be                	mv	a1,a5
    80200964:	863e                	mv	a2,a5
    80200966:	00000073          	ecall
    8020096a:	87aa                	mv	a5,a0
}
    8020096c:	8082                	ret

000000008020096e <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    8020096e:	00003797          	auipc	a5,0x3
    80200972:	6aa78793          	addi	a5,a5,1706 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    80200976:	6398                	ld	a4,0(a5)
    80200978:	4781                	li	a5,0
    8020097a:	88ba                	mv	a7,a4
    8020097c:	852a                	mv	a0,a0
    8020097e:	85be                	mv	a1,a5
    80200980:	863e                	mv	a2,a5
    80200982:	00000073          	ecall
    80200986:	87aa                	mv	a5,a0
}
    80200988:	8082                	ret

000000008020098a <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    8020098a:	00003797          	auipc	a5,0x3
    8020098e:	67e78793          	addi	a5,a5,1662 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200992:	6398                	ld	a4,0(a5)
    80200994:	4781                	li	a5,0
    80200996:	88ba                	mv	a7,a4
    80200998:	853e                	mv	a0,a5
    8020099a:	85be                	mv	a1,a5
    8020099c:	863e                	mv	a2,a5
    8020099e:	00000073          	ecall
    802009a2:	87aa                	mv	a5,a0
    802009a4:	8082                	ret

00000000802009a6 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    802009a6:	c185                	beqz	a1,802009c6 <strnlen+0x20>
    802009a8:	00054783          	lbu	a5,0(a0)
    802009ac:	cf89                	beqz	a5,802009c6 <strnlen+0x20>
    size_t cnt = 0;
    802009ae:	4781                	li	a5,0
    802009b0:	a021                	j	802009b8 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    802009b2:	00074703          	lbu	a4,0(a4)
    802009b6:	c711                	beqz	a4,802009c2 <strnlen+0x1c>
        cnt ++;
    802009b8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802009ba:	00f50733          	add	a4,a0,a5
    802009be:	fef59ae3          	bne	a1,a5,802009b2 <strnlen+0xc>
    }
    return cnt;
}
    802009c2:	853e                	mv	a0,a5
    802009c4:	8082                	ret
    size_t cnt = 0;
    802009c6:	4781                	li	a5,0
}
    802009c8:	853e                	mv	a0,a5
    802009ca:	8082                	ret

00000000802009cc <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    802009cc:	ca01                	beqz	a2,802009dc <memset+0x10>
    802009ce:	962a                	add	a2,a2,a0
    char *p = s;
    802009d0:	87aa                	mv	a5,a0
        *p ++ = c;
    802009d2:	0785                	addi	a5,a5,1
    802009d4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802009d8:	fec79de3          	bne	a5,a2,802009d2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    802009dc:	8082                	ret
