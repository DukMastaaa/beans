# Lecture 12

## Abstraction and Virtualisation of Memory
Ideally, we'd like the following things for program memory:
1. Protection: processes should not interfere with others
2. Sharing: when we do want them to communicate, redundancy is avoided (e.g. unmodified parts of `fork()`ed children, and universal usage of `libc.so`) 
3. Optimisation: only load things when required
4. Varying overall allocation: want to be flexible as to how much memory is needed at once
5. Secondary storage to store "idle" memory when physical memory is full

Try `cd /proc/self; less maps`, giving a view of all the memory maps that are present for the current process (bash). There are address ranges on the left, permission bits (like those of files), and at the very bottom there is the stack (which grows dynamically as your program needs). The addresses listed here span a range much wider than the actual physical RAM.

There are two types of addresses.
1. Virtual/logical addresses are used by CPU when running user processes, like pointers or instruction fetches.
2. Physical addresses correspond to actual locations in physical RAM.

Hardware support via a memory management unit (MMU) allows dynamic translation without the program, and ideally the kernel, being aware of it. In the following diagram, devices are things like GPUs which usually use memory-mapped IO. Control registers of the device are mapped into special memory addresses. User-space programs are prohibited from touching devices -- the kernel mediates access, so if we want to draw something on screen via GPU, that has to go through a kernel driver that then talks to device through MMU.

<img src="images/MMU.png" style="zoom: 50%;" />

## Pages and Frames
The virtual address space is divided into equal sized pieces called *pages*. The physical address space is divided into *frames* of the same size. Both sizes are powers of 2 so addresses can be easily split. For example, for page size of 4096 ($2^{12}$) in a 32-bit address space, the upper $32 - 12 = 20$ bits of an address is considered the *page/frame number* and the remaining 12 give the *offset* into that page. `page_num = virt_addr // page_size` and `offset = virt_addr % page_size`.

Kernel maintains a data structure called a *page table* for each process, which is basically a map from pages to frames. There does not need to be any relationship between virtual and physical layout -- even contiguous virtual addresses (critical for large arrays spanning multiple pages) don't require contiguous physical frames. Mapping is also sparse -- not every virtual address is mapped to a physical address.  However, addresses *within* pages/frames are always contiguous, and as they are the same size, offsets do not need to be changed.

### Translation Lookaside Buffer (TLB)
Page tables are stored in memory. Suppose we have 32bit virtual addresses and 4kiB page size with page table entries (PTE) 4 bytes large. To map the entire address space, one page table would need $2^{20}$ entries, giving 4MiB table per process. This is very wasteful. In reality, the kernel only maps the pages that are required, as they are required.

If we need to look up frames in the page table, we need 2 lookups (1 for page table, 1 for page) to access an address. This is optimised by a hardware component in MMU called the translation lookaside buffer (TLB), which has expensive associative (or content-addressable) memory that acts like a cache for PTEs. 
Below is a simplified representation. The hardware only goes to an actual memory-based table if there is a TLB miss, and updates the table with the newly found pair according to some strategy (lru, lfu, etc, see COMP3301). Some architectures can make the TLB walk the tables itself, but simpler ones just raise exceptions so the kernel does it.

<img src="images/TLB.png" style="zoom: 50%;" />

### Page Faults
A *page fault* occurs when there is no frame corresponding to a given page. Here are some possible causes.
- The page is legal for that process, but it hasn't loaded yet or there's memory pressure so the page has been moved to disk and stored in a pagefile/swapfile (when this occurs a note will be left in the page table)
    - Here, the kernel needs to suspend the process until it can get the frame into RAM and find a frame to put it in
    - If there is memory pressure, usually another process' pages will get swapped out, called thrashing
- The page access is not legal for that process, e.g. null/garbage pointer dereference, writing to read-only page, insn fetch from non-executable page
    - Kernel probably should inform the process and kill it, but there are exceptions (see below with `fork()`).
    - Note that these legal/illegal decisions are made at the page level, not address level. So, if page 0 and other low-numbered pages are marked as invalid, the hardware ensures dereferencing NULL will give segfault.

Note that when `fork()` is called, the kernel gives the child a copy of the parent's page table. As this would lead to programs both writing into shared memory, the kernel also marks both page tables as read-only (so reading from shared memory ok), but if either process tries to write, a page fault is triggered, and the kernel recognises this is shared, so it *copies only the page that was accessed* and makes that copy writable. This allows only the accessed memory to be duplicated.

Sometimes shared pages/memory is deliberate -- the kernel would map the same frame into multiple page tables.

### Multi-Level Tables
As discussed earlier, 4kiB pages and 32bit address space gives 4MiB per page table. We can split page numbers into two for example, and have `Dict[top_half_of_page_num, Dict[bottom_half_of_page_num, frame_num]]` instead of `Dict[page_num, frame_num]`. This does make things slower as it adds another level of indirection, but uses much less memory, as a lot of the entries at the second level will be empty.

<img src="images/pagetables.png" style="zoom: 50%;" />

This can be extended to any number of levels. Note that PTEs must be large enough to uniquely identify a page/frame, and additional space is used to store things like permission flags. In exam questions, full PTE size will be specified in bytes so we don't need to worry about calculating this.

Also, page and PTE size define PTE field size (the size of each chunk in the address that get mapped to a page table), except for a tricky case. For example, given 4KiB pages and 4 byte PTEs, $4096 / 4 = 1024 = 2^{10}$ PTEs per page, so in the virtual address, each group of 10 bits before the offset gets mapped in a page table. This assumes that each page table is exactly one page in size.
However, what if there are bits left over? For example, with a 4 level page table, 64-bit virtual addresses, 8 byte PTE, and 8KiB frames ($2^{13}$), each page can hold $2^{13} / 8 = 1024 = 2^{10}$ PTEs, so each PTE field in the VA is 10 bits. $10 + 10 + 10 + 10$ (4 levels) plus 13 for offset only adds up to 53, leaving 11 bits remaining.
What to do with those 11 bits is architecture-dependent. Some will ignore, some will set to all zero, but in this course we assume that the first level table is *resized* to account for them, so the levels are $21 + 10 + 10 + 10$ plus 13 offset.

## Memory Layout
Linux memory layout looks something like this. From highest value to 0,
- kernel memory
- (some space to ensure stack virtually contiguous)
- top of stack
- bottom of stack
- ... (memory-mapped content goes here)
- top of heap
- bottom of heap
- other data
- text segment (instructions)
- forbidden
- forbidden (now we're near address 0)

Nowadays, 32bit virtual addresses actually make things quite crowded. There's more room in a 64bit address space, motivating the move to 64-bit architectures (but note that not necessarily $2^{64}$ bytes of memory need to be installed -- this is virtual).

If the kernel has ASLR (address space layout randomisation) enabled, it will slightly randomly vary the locations of stack and heap for every process, making it a bit more difficult for an attacker to do stack sniffing attacks (and the like).

Kernel only cares about where the *top* of the heap is. If heap needs more space, the `sbrk` system call will allocate more valid pages to the process. `malloc` is a userspace function which does this (and other tricky things like `mmap`).

`/proc/pid/mem` is a virtual file representing a process' entire virtual memory space and has `rw` permissions for the user that created the process. This means that you can directly modify the memory maps for your own processes!
As an example, write two programs. The first dynamically allocates a string `str` and does `printf("%s [%p] (%i)\n", f, f, getpid())` in an infinite loop. The second recevies a `pid`, address and string from the command line, calls `fopen` on `"/proc/%i/mem` where `%i` is the `pid`, `fseek`s to the given address (option `SEEK_SET`) and `fwrite`s the string to the file. This *changes* the string that process 1 is printing out!!
Of course, this is a "cheap" way to get around the process independence, but is a valid method and there are some uses.

## Calculations
$2^{10}$ B = 1kiB, $2^{20}$ B = 1MiB, $2^{30}$ B = 1GiB.`