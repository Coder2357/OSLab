# 2112555王天宇-2110533江岩旭-lab8

## 练习1: 完成读文件操作的实现（需要编码）
首先了解打开文件的处理流程，然后参考本实验后续的文件读写操作的过程分析，填写在 kern/fs/sfs/sfs_inode.c中 的sfs_io_nolock()函数，实现读文件中数据的代码。

### 处理流程：

通用文件系统访问接口层：

这一层为应用程序提供了标准的文件操作接口，比如 open、read、write、close 等系统调用。这些系统调用将用户空间的请求传递到文件系统内核。

文件系统抽象层：

这一层为文件系统提供了一组统一的接口，使得内核的其他部分（比如系统调用的实现）可以统一地与下层的具体文件系统进行交互。此外，这一层还负责管理文件系统的挂载点、路径名解析等。

Simple FS (SFS) 文件系统层：

作为一种具体的文件系统实现，SFS 实现了文件系统抽象层下定义的接口。SFS 侧重于提供一个简单且易于理解的文件系统实现，它使用索引节点(inode)来表示文件，并管理数据块(block)以存储文件数据和元数据。在 uCore 中，这一层将高级的文件操作转换成对磁盘块的读写请求。

外设接口层：
这一层屏蔽了对不同硬件设备细节的直接操作，向上提供了一个通用的设备访问接口。底层则是各种具体的设备驱动，如磁盘、串口、网络接口等，这些驱动直接与硬件交互，执行具体的 I/O 操作。

简单地说，如果一个应用程序想要打开一个文件，它通过通用文件系统访问接口层的系统调用进入文件系统。文件系统抽象层接着将调用传递到相应的 SFS。SFS 进行必要的操作，如对文件元数据的访问和更新，并可能涉及读写数据块。实际的磁盘操作由外设接口层协调完成。

### 文件打开：

ucore从用户空间接收open调用，找到文件的inode信息，并关联到一个file结构变量。这个file结构将用来管理后续的文件操作如读、写等。

通用文件访问接口层的处理流程

1.	用户空间的请求：应用程序调用open()系统调用，进入内核态。

2.	内核态处理：执行sysfile_open函数，负责处理系统调用逻辑。

```c
// kern/fs/sysfile.c
/* sysfile_open - open file */
int sysfile_open(const char *__path, uint32_t open_flags) {
    int ret;
    char *path;
    if ((ret = copy_path(&path, __path)) != 0) {
        return ret;
    }
    ret = file_open(path, open_flags);
    kfree(path);
    return ret;
}
```

3.	参数拷贝和转换：将用户空间的路径字符串__path拷贝到内核空间中的path。

4.	调用VFS接口：调用file_open函数，该函数再调用vfs_open，进入文件系统抽象层的处理流程。vfs_open函数需要完成两件事情：通过vfs_lookup找到path对应文件的inode；调用vop_open函数打开文件。

文件系统抽象层的处理流程

1.	分配file结构：分配一个空闲的file结构用于表示打开的文件。

2.	路径查找：调用vfs_open函数，进一步通过vfs_lookup函数查找文件路径path对应的inode节点。

o	获取设备inode：首先获取根目录对应的inode节点。

o	查找目录中的文件：通过调用vop_lookup函数查找具体文件。

3.	VFS操作转发：各种以vop开头的操作通过函数指针转发到具体文件系统的操作。

SFS文件系统层的处理流程

1.	调用sfs_lookup：vop_lookup = sfs_lookup 。根据文件系统中的多级目录查找逻辑，路径名逐一分解到最终文件。

2.	单次查找：调用sfs_lookup_once查找根目录“/”下文件sfs_filetest1所对应的inode节点。

3.	目录项匹配：sfs_lookup_once通过sfs_dirent_search_nolock查找匹配的目录项。

4.	构建内存inode：从磁盘加载inode信息，创建SFS内存inode节点。


```c
/*
 * sfs_lookup - Parse path relative to the passed directory
 *              DIR, and hand back the inode for the file it
 *              refers to.
 */
static int
sfs_lookup(struct inode *node, char *path, struct inode **node_store) {
    struct sfs_fs *sfs = fsop_info(vop_fs(node), sfs);
    assert(*path != '\0' && *path != '/');
    vop_ref_inc(node);
    struct sfs_inode *sin = vop_info(node, sfs_inode);
    if (sin->din->type != SFS_TYPE_DIR) {
        vop_ref_dec(node);
        return -E_NOTDIR;
    }
    struct inode *subnode;
    int ret = sfs_lookup_once(sfs, sin, path, &subnode, NULL);

    vop_ref_dec(node);
    if (ret != 0) {
        return ret;
    }
    *node_store = subnode;
    return 0;
}
```
sfs_lookup有三个参数：node，path，node_store。其中node是根目录“/”所对应的inode节点；path是文件sfs_filetest1的绝对路径/sfs_filetest1，而node_store是经过查找获得的sfs_filetest1所对应的inode节点。

sfs_lookup函数以“/”为分割符，从左至右逐一分解path获得各个子目录和最终文件对应的inode节点。在本例中是调用sfs_lookup_once查找以根目录下的文件sfs_filetest1所对应的inode节点。当无法分解path后，就意味着找到了sfs_filetest1对应的inode节点，就可顺利返回了。
```c
/*
 * sfs_lookup_once - find inode corresponding the file name in DIR's sin inode 
 * @sfs:        sfs file system
 * @sin:        DIR sfs inode in memory
 * @name:       the file name in DIR
 * @node_store: the inode corresponding the file name in DIR
 * @slot:       the logical index of file entry
 */
static int
sfs_lookup_once(struct sfs_fs *sfs, struct sfs_inode *sin, const char *name, struct inode **node_store, int *slot) {
    int ret;
    uint32_t ino;
    lock_sin(sin);
    {   // find the NO. of disk block and logical index of file entry
        ret = sfs_dirent_search_nolock(sfs, sin, name, &ino, slot, NULL);
    }
    unlock_sin(sin);
    if (ret == 0) {
        // load the content of inode with the the NO. of disk block
        ret = sfs_load_inode(sfs, node_store, ino);
    }
    return ret;
}
```
### 读文件：

用户无需关心底层的文件系统逻辑，只需要知道文件描述符 fd，以及期望读取的数据和长度。

用户态到内核态的转换

1.	用户程序调用 read(fd, data, len)。

2.	进入系统调用层，转换至内核态。

```c
int
read(int fd, void *base, size_t len) {
    return sys_read(fd, base, len);
}
```
通用文件访问接口层的处理流程

1.	sys_read 获取参数并校验。

2.	sysfile_read 进一步处理参数和调用文件操作接口。

到了内核态以后，通过中断处理例程，会调用到sys_read内核函数，并进一步调用sysfile_read内核函数，进入到文件系统抽象层处理流程完成进一步读文件的操作。

```c
static int
sys_read(uint64_t arg[]) {
    int fd = (int)arg[0];
    void *base = (void *)arg[1];
    size_t len = (size_t)arg[2];
    return sysfile_read(fd, base, len);
}
```

文件系统抽象层的处理流程

1.	分配缓冲区。

2.	循环读取文件内容到缓冲区。

3.	file_read 调用，将文件内容读取到缓冲区中。

```c
int
sysfile_read(int fd, void *base, size_t len) {
    struct mm_struct *mm = current->mm;
    if (len == 0) {
        return 0;
    }
    if (!file_testfd(fd, 1, 0)) {
        return -E_INVAL;
    }
    void *buffer;
    if ((buffer = kmalloc(IOBUF_SIZE)) == NULL) {
        return -E_NO_MEM;
    }

    int ret = 0;
    size_t copied = 0, alen;
    while (len != 0) {
        if ((alen = IOBUF_SIZE) > len) {
            alen = len;
        }
        ret = file_read(fd, buffer, alen, &alen);
        if (alen != 0) {
            lock_mm(mm);
            {
                if (copy_to_user(mm, base, buffer, alen)) {
                    assert(len >= alen);
                    base += alen, len -= alen, copied += alen;
                }
                else if (ret == 0) {
                    ret = -E_INVAL;
                }
            }
            unlock_mm(mm);
        }
        if (ret != 0 || alen == 0) {
            goto out;
        }
    }

out:
    kfree(buffer);
    if (copied != 0) {
        return copied;
    }
    return ret;
}
```
```c
// read file
int
file_read(int fd, void *base, size_t len, size_t *copied_store) {
    /*
    fd是文件描述符，base是缓存的基地址，len是要读取的长度，copied_store存放实际读取的长度
    */
    int ret;
    struct file *file;
    *copied_store = 0;
    if ((ret = fd2file(fd, &file)) != 0) {//调用fd2file函数找到对应的file结构，并检查是否可读
        return ret;
    }
    if (!file->readable) {
        return -E_INVAL;
    }
    fd_array_acquire(file);//增加file的引用计数

    struct iobuf __iob, *iob = iobuf_init(&__iob, base, len, file->pos);//初始化iobuf结构
    ret = vop_read(file->node, iob);//将文件内容读到iob中,其实是调用sfs_read函数
    size_t copied = iobuf_used(iob);//实际读取的长度
    if (file->status == FD_OPENED) {
        file->pos += copied;
    }
    *copied_store = copied;//将实际读取的长度存放到copied_store中
    fd_array_release(file);//减少file的引用计数
    return ret;
}
```
具体文件系统层的处理流程

1.	sfs_read 调用，进一步封装对 sfs_io 的调用。

2.	sfs_io 调用，实现了对文件的实际读取操作。

3.	sfs_io_nolock 进行不同部分（起始非对齐部分、中间对齐部分、可能的末尾非对齐部分）的读取。

4.	将数据从磁盘块加载到内存。

SFS文件系统层 sfs_read->sfs_io->sfs_io_nolock sfs_read函数调用sfs_io函数。它有三个参数，node是对应文件的inode，iob是缓存，write表示是读还是写的布尔值（0表示读，1表示写），这里是0。sfs_io函数先找到inode对应sfs和sin，然后调用sfs_io_nolock函数进行读取文件操作，最后调用iobuf_skip函数调整iobuf的指针。
```c
static int
sfs_read(struct inode *node, struct iobuf *iob) {
    return sfs_io(node, iob, 0);
}

static inline int
sfs_io(struct inode *node, struct iobuf *iob, bool write) {
    struct sfs_fs *sfs = fsop_info(vop_fs(node), sfs);
    struct sfs_inode *sin = vop_info(node, sfs_inode);
    int ret;
    lock_sin(sin);
    {
        size_t alen = iob->io_resid;
        ret = sfs_io_nolock(sfs, sin, iob->io_base, iob->io_offset, &alen, write);
        // 如果当前缓冲区中存在尚未读取/写入的数据
        // 则跳过该部分数据，写入/读取至该块数据的下一个地址处
        if (alen != 0) {
            iobuf_skip(iob, alen);
        }
    }
    unlock_sin(sin);
    return ret;
}
```
sfs_io_nolock函数主要实现的就是对设备上基础块数据的读取与写入。从参数角度来看就是从偏移位置offset到offset+长度length读取/写入文件内容，磁盘块<-->缓冲区（内存中）的功能，这也是我们本个练习要填写的函数，下面来具体说一说：

在进行读取/写入前，我们需要先将数据与基础块对齐。 

但一旦将数据对齐后会存在一个问题：

待操作数据的前一小部分有可能在最前的一个基础块的末尾位置

待操作数据的后一小部分有可能在最后的一个基础块的起始位置

因此我们需要单独处理上述两个特殊情况，其他对齐的块相对好集中处理。
```c
// 如果偏移量与块大小的余数不为0，说明不是从块的起始位置开始，从偏移量到第一个块的末尾读取/写入一些内容
   if ((blkoff = offset % SFS_BLKSIZE) != 0) {
        // 计算操作的大小，如果有多个块，则操作的大小为块大小减去偏移量，否则为结束位置减去偏移量
        size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);
        // 加载块号对应的索引节点
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        // 执行缓冲区操作
        if ((ret = sfs_buf_op(sfs, buf, size, ino, blkoff)) != 0) {
            goto out;
        }

        // 更新已处理的长度和缓冲区的位置
        alen += size;
        buf += size;

        // 如果没有其他块，结束操作
        if (nblks == 0) {
            goto out;
        }

        // 更新块号和剩余块数
        blkno++;
        nblks--;
    }

    // 读取/写入对齐的块
    if (nblks > 0) {
        // 加载块号对应的索引节点
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        // 执行块操作
        if ((ret = sfs_block_op(sfs, buf, ino, nblks)) != 0) {
            goto out;
        }

        // 更新已处理的长度、缓冲区的位置、块号和剩余块数
        alen += nblks * SFS_BLKSIZE;
        buf += nblks * SFS_BLKSIZE;
        blkno += nblks;
        nblks -= nblks;
    }

    // 如果结束位置与块大小的余数不为0，说明最后一个块不完整
    if ((size = endpos % SFS_BLKSIZE) != 0) {
        // 加载块号对应的索引节点
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        // 执行缓冲区操作
        if ((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0) {
            goto out;
        }
        // 更新已处理的长度
        alen += size;
    }
```
这里面用到了三个关键的函数。首先是sfs_bmap_load_nolock函数，得到blkno对应的inode编号。其次是函数里面定义的sfs_buf_op = sfs_rbuf和 sfs_block_op = sfs_rblock，这里就是读取数据的作用。 前者调用的是sfs_rblock->sfs_rwblock->sfs_rwblock_nolock，后者是sfs_rbuf-> sfs_rwblock_nolock，这就进入了文件系统I/O设备接口。

## 练习2: 完成基于文件系统的执行程序机制的实现（需要编码）

改写proc.c中的load_icode函数和其他相关函数，实现基于文件系统的执行程序机制。执行：make qemu。如果能看看到sh用户程序的执行界面，则基本成功了。如果在sh用户界面上可以执行”ls”,”hello”等其他放置在sfs文件系统中的其他执行程序，则可以认为本实验基本成功。

实验8和实验5中load_icode（）函数代码最大不同的地方在于读取EFL文件的方式，实验5中是通过获取ELF在内存中的位置，根据ELF的格式进行解析，而在实验8中则是通过ELF文件的文件描述符调用load_icode_read（）函数来进行解析程序
```c
assert(argc >= 0 && argc <= EXEC_MAX_ARG_NUM);
    // 检查当前进程的内存管理单元是否为空
    if (current->mm != NULL) {
        panic("load_icode: current->mm must be empty.\n");
    }

    // 创建一个新的内存管理单元
    struct mm_struct *mm;
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    // 设置页目录
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }

    // 读取 ELF 文件头
    struct elfhdr __elf, *elf = &__elf;
    if ((ret = load_icode_read(fd, elf, sizeof(struct elfhdr), 0)) != 0) {
        goto bad_elf_cleanup_pgdir;
    }

    // 检查 ELF 文件的魔数是否正确
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }

    // 遍历 ELF 文件的程序头
    struct proghdr __ph, *ph = &__ph;
    uint32_t vm_flags, perm, phnum;
    for (phnum = 0; phnum < elf->e_phnum; phnum ++) {
        // 读取程序头
        off_t phoff = elf->e_phoff + sizeof(struct proghdr) * phnum;
        if ((ret = load_icode_read(fd, ph, sizeof(struct proghdr), phoff)) != 0) {
            goto bad_cleanup_mmap;
        }
        // 如果程序头的类型不是 PT_LOAD，跳过
        if (ph->p_type != ELF_PT_LOAD) {
            continue ;
        }
        // 检查文件大小和内存大小是否合法
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        // 设置虚拟内存的权限
        vm_flags = 0, perm = PTE_U | PTE_V;
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        if (vm_flags & VM_READ) perm |= PTE_R;
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
        if (vm_flags & VM_EXEC) perm |= PTE_X;
        // 映射虚拟内存
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
        }
        // 读取程序段到内存中
        // ...

    // 映射用户栈
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    // 分配用户栈的页
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
    
    // 设置当前进程的内存管理单元和页目录
    mm_count_inc(mm);
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir));

    // 设置进程的入口点
    struct trapframe *tf = current->tf;
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));
    tf->gpr.sp = stacktop;
    tf->epc = elf->e_entry;
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
    ret = 0;
out:
    return ret;
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
```


## 扩展练习 Challenge1：完成基于“UNIX的PIPE机制”的设计方案

如果要在ucore里加入UNIX的管道（Pipe)机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个(或多个）具体的C语言struct定义。在网络上查找相关的Linux资料和实现，请在实验报告中给出设计实现”UNIX的PIPE机制“的概要设方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）

在UNIX系统中，管道是一个单向的数据通道，可以在两个进程之间传递数据。管道需要两个文件描述符，一个用于读端，另一个用于写端。

```c
#define PIPE_BUFFER_SIZE 4096 

// 管道缓冲区结构
struct pipe_buffer {
    char buf[PIPE_BUFFER_SIZE]; // 管道中的数据缓冲
    int read_pos;               // 下一个读取数据的位置
    int write_pos;              // 下一个写入数据的位置
    int data_count;             // 缓冲区中的数据数量
    // 可能还需要同步互斥的机制，如锁
    semaphore_t read_semaphore; // 读操作的信号量
    semaphore_t write_semaphore;// 写操作的信号量
};

// 管道结构
struct pipe {
    struct pipe_buffer* buffer; // 关联的管道缓冲区
    bool is_readable;           // 是否可读
    bool is_writable;           // 是否可写
};
```
在这里，我们定义了pipe_buffer结构来表示管道内部的缓冲区，并且使用了读写位置和数据数量计数器来管理读写操作。为了处理同步互斥问题，使用了信号量（semaphore）来控制对管道的并发访问。

接口定义
```c
// 创建管道的接口，成功时返回0，并通过参数设置两个文件描述符
int pipe_create(int filedes[2]);

// 从管道中读取数据，返回实际读取的数据字节数
int pipe_read(int fd, void *buf, size_t count);

// 向管道写入数据，返回实际写入的数据字节数
int pipe_write(int fd, const void *buf, size_t count);

// 销毁管道，释放资源
int pipe_destroy(struct pipe *p);

```
管道的实现必须保证只有当有数据可读时，读操作才能进行，只有当管道未满时，写操作才能进行。

可以为管道实现两个信号量：

read_semaphore：表示管道中可供读取的数据的数量。初始值为0。

write_semaphore：表示管道中可供写入的空闲空间的数量。初始值为管道缓冲区的大小。

每当进行写操作时，如果管道已满（即没有足够的可写入空间），pipe_write 等待 write_semaphore。每成功写入数据后，write_semaphore 减少，而 read_semaphore 增加，因为可读取的数据增多了。

类似地，在读操作中，如果管道为空，pipe_read 等待 read_semaphore。每成功读取数据后，read_semaphore 减少，而 write_semaphore 增加，因为可写入的空间增多了。

## 扩展练习 Challenge2：完成基于“UNIX的软连接和硬连接机制”的设计方案

如果要在ucore里加入UNIX的软连接和硬连接机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个(或多个）具体的C语言struct定义。在网络上查找相关的Linux资料和实现，请在实验报告中给出设计实现”UNIX的软连接和硬连接机制“的概要设方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）
```c

// 文件元数据结构
struct inode {
    uint32_t i_number;  // inode编号
    uint32_t i_mode;    // 文件类型和权限模式
    uint32_t i_links_count; // 硬链接计数
    uint32_t i_size;    // 文件大小（对于常规文件）或路径长度（对于软链接）
    uint32_t i_blocks;  // 文件所占的数据块数
    uint32_t i_block[...]; // 数据指针数组，包含了文件数据或软链接的地址
    // ... 还可能包含其他元数据，比如时间戳、所有者、权限等
};

// 文件系统结构，存储了文件系统中所有的inodes
struct fs_struct {
    struct inode *inodes[...]; // 文件系统的inode数组
    // ... 其他文件系统相关信息
};
```
这里我们定义了一个基本的inode结构。这个结构可以用于普通文件、目录、软链接等文件类型的节点。硬链接与其它文件共用一个inode节点，而软链接则有独立的inode，里面存储的是原文件的路径。

接口定义
```c
// 创建硬链接的接口
int link(const char *oldpath, const char *newpath);

// 创建软连接的接口
int symlink(const char *target, const char *linkpath);

// 读取软连接的接口
ssize_t readlink(const char *pathname, char *buf, size_t bufsiz);

// 删除文件的接口，对于硬链接和软链接也有影响
int unlink(const char *pathname);
```
当删除一个文件时，如果所有硬链接都没了，文件数据才会被删除。软链接则类似快捷方式，删除软链接不会影响原文件。

同步互斥问题的处理：
对inode结构使用锁机制，当一个进程需要修改inode时（例如创建或删除硬链接，修改文件数据），其他进程应当等待直到这个操作完成。
当创建或读取软链接时，应确保目标文件的路径不会在操作过程中被修改或删除。
