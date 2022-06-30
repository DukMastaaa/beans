# Lecture 4

## Operating system basics

OSes provide abstractions of the hardware to the application through
generic interfaces such as files, network and memory. Program doesn't need
to know which type of disk is used / how the computer is connected to the internet.

Also, OS does multitasking so multiple users/processes can use resources at the same time.
Such resources include CPU, memory, hardware etc, and are managed via policies (see `nice`
for an example).

Portability is the degree that some code can be built and run for different systems.
POSIX (portable operating system interface) defines common interfaces for Unix-like OSes,
so well-written Linux code is portable across a wide range of CPU architectures and
OS distributions.

Linux architecture, from highest to lowest level:
- User space
    - user applications
    - `glibc`
- Kernel space
    - system call interface
    - kernel
    - architecture-dependent kernel code
- Hardware

### CPU privilege levels
Most CPU architectures define at least 2 privilege levels:
1. User mode, unprivileged
    - can do normal CPU instructions
    - can't access hardware directly or disable interrupts
    - all memory accesses are controlled and protected by memory management unit (MMU)
2. Kernel mode, privileged
    - everything user mode can do
    - modify CPU state like interrupts and MMU configuration
    - access anywhere in memory or IO address space
    - this is what "rootkits" do

The `root` user is in user mode, but has special priviliges at the kernel level.
It can load device drivers, etc., so it can still modify kernel state.

For hardware virtualisation (i.e. hypervisor), the kernel isn't the lowest level -- kernel
sits on top of hypervisor.

We can get into kernel mode in these ways:
1. system calls
    - deliberately triggered via special opcodes
    - visible since user program asked for it (usually presented as a function call)
2. exceptions
    - result from program actions (e.g. floating point exception, memory error)
    - visible since user code wakes up in an exception handler
    - different concept from exceptions in a language
3. interrupts
    - like csse2010
    - triggered by hardware to the CPU
    - not directly visible to user programs

## Shells
Shells are unprivileged programs which are interfaces between users and the kernel.
They provide scripting capabilities, and actually don't have to be text-based.
In this course, we assume we're using `bash` but there are many other shells with lots of history.

When a shell starts up, it reads startup files e.g. `~/.bashrc` and `/etc/bashrc`.
It then reads commands from stdin or from a script file. Text files to be run as scripts need to have `rx` perms.

Just like in other languages, some commands are built into the shell, like `cd`, `alias`, `type`, `which`.
Other commands are executables, like `ls`, `gcc`, `vim`. Use `type` to tell if something is a builtin,
and use `which` to find where an external command is located.

Variables are always strings, but some commands can interpret strings as numbers. They're either local (shell) variables,
with scope of the current process and not passed to children, or environment variables passed to children.
Shell variables can be promoted to environment-level via `export`.

Variables don't need to be declared, just use `BEANS=123`. Don't put spacing around operators.
Use `$` to get the value of a variable, like `$PATH`, or with braces to be explicit, like `${PATH}`.
Here are some important variables.
- `PATH`: directories to search for commands
- `LD_LIBRARY_PATH`: directories to search for DLLs
- `UID`: current user's id
- `USER`: login name
- `HOME`: path to user's home directory
- `$?`: exit status of most recent command
- `$#`: `argc - 1` of a shell script
- `$0`: `argv[0]`, and same for `$n` giving `argv[n]` for integer `n`

For filenames, `*` stands for 0 or more characters, and `?` stands for exactly one unknown character.
This is called globbing; the shell attempts to expand these *before* calling a program, so be careful.
`#` is a comment, `&` runs a command in background, and `;` runs commands in sequence.

Command substitution can be done with backticks \`cmd\` or `$(cmd)`.
Can redirect stdin with `<`, stdout with `>` and stderr with `2>`.
`cmd1 | cmd2` is pipe, so stdout of `cmd1` goes to stdin of `cmd2`.

This may be useful: `find . -name '*.c' | xargs wc -l` finds all `.c` files under this directory recursively
and counts number of lines.