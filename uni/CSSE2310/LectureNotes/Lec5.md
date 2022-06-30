# Lecture 5

## Processes

A process is just an instance of a program in execution.
It can also be viewed as an abstraction of a computer -- processes have their own memory, can't access each other's memory or resources, and interact with the kernel via system calls.
This is done by separating resources so each process can have their own, memory into virtual memory, and CPU activity. When a CPU switches to kernel mode, registers are saved, so when it switches back, the process is none the wiser.

A process can be in one of these states:
1. Running: currently executing
2. Ready: process can run, but CPU doing something else
3. Blocking: process not ready because it's waiting for something, like reading from a file, or sleeping
4. Ended: process has exited/been terminated and needs to be cleaned up. But, it may have become a zombie. More on this later.

Every process has a unique process ID (PID), accessible by `pid_t getpid(void)`, and a parent process accessible by `pid_t getppid(void)`.
A process can have zero or more children.

All processes have a parent, creating a tree structure. `init` (sometimes now called `systemd`) with PID 1 is special -- it is the first userspace process created after the kernel finishes booting.
See `ps -f` or `ps -e` to list processes, and `pstree` to show a visual tree structure.
PID 0 is the kernel itself. `init` and `kthreadd` have the kernel as their parent.

## Creating new processes
`fork()` asks the kernel to create new processes. It's called from the parent process, but it creates another process and resumes execution after the call.
The *parent's* `fork()` return value is the PID of the child, or -1 if no child was created (sets errno).
The *child's* `fork()` return value is 0. The child is an **exact but distinct copy** of the parent. Stack and heap are copied, but opened files are the same.

```c
#include <stdio.h>
#include <unistd.h>

void foo(void) {
    int p = 5;
    if (fork()) {
        printf("parent:%i %i %p\n", getpid(), p, &p);
        fflush(stdout);
        p++;
    } else {
        printf("child:%i %i %p\n", getpid(), p, &p);
        fflush(stdout);
        p--;
    }
    printf("%d\n", p);
}
```
The kernel is free to execute instructions between processes in any order, as long as they are consistent and in order relative to each process.

```c
int main(void) {
    printf("1\n");
    fork();
    printf("2\n");
    fork();
    printf("3\n");
    return 0;
}
```
`stdout` is line-buffered so `\n` will cause it to flush. We don't need `fflush` here.
Running this without redirecting stdout to a file prints out
```
1
2
2
3
3
3
3
```
with the 1 then 2 guaranteed to be first but the rest can happen in any order. If stdout is redirected to a file, files are block-buffered so output is
```
1
2
3
1
2
3
1
2
3
1
2
3
```
If you need to be sure, flush explicitly.

## Fork Bombs
```c
for (int i = 0; i < 20; i++) {
    if (!fork()) {
        printf("beans\n");
    }
}
```
This is a fork bomb, as the child isn't killed at the end of the if statement so it creates more children.
The program will terminate eventually and is difficult to stop.
On moss, there are a limited number of simultaneous processes for one user (`ulimit -u`).
Using `kill` or `pkill` through the shell may not work since it needs to create another process.

## Ending a process
`exit()` is a system call which ends the *current process*.
The parameter to exit is the exit status (return value).
- Any open output streams are flushed.
- Exit hooks are executed. Not covered in this course, but you pass in a function pointer: `int atexit(void (*function)(void))`.
If this is not desirable (like if you didn't want them to be flushed) then see `_exit()`.

If a process crashes or receives a signal, `exit` doesn't happen and there is no exit status.

## Zombies
```c
int main(void) {
    printf("started %d\n", getpid());
    fflush(stdout);
    if (!fork()) {
        // child
        exit(123);
    }
    sleep(30);
    exit(0);
}
```
Here, after child exits, parent is still alive. If you run `ps -ef | grep <pid>` it shows the parent process, and the child with "defunct".

The kernel needs to keep a record to what happened to the child in case the parent asks. This information includes exit status, or signal that caused exit.
The child's memory and resourcs have been released but that part of the process still hangs around. The child is called a *zombie* in that state.

When a process' parent has asked about the cause of termination, that process will be *reaped* and the zombie is removed.
To reap, the parent process calls `wait()`. `wait()` blocks until either
- a current child process becomes or is a zombie
- the parent has no child processes (returns error)
```c
fork();
// ...
int status;
pid_t pid = wait(&status);
if (pid < 0) {
    fprintf(stderr, "couldn't wait\n");
    exit(1);
}
printf("processs %d gave back value %d\n", pid, status);
```
The `status` value isn't exactly the return status of the child, and needs to be decoded.
`WIFEXITED(status)` is true if the process exited normally, and `WEXITSTATUS(status)` gives the return code.
`WIFSIGNALED(status)` is true if the process was terminated by a signal, and `WTERMSIG(status)` gives the corresponding signal.
We can query other things from `wait` but that isn't relevant now.

Passing `NULL` to `wait` just makes it not give us the status back.

To query a specific child, use `pid_t waitpid(pid_t pid, int* wstatus, int options)`. Or, can use `W_NOHANG` so it doesn't block if nothing is ready.

If a process is alive, has zombie children and doesn't reap them, those zombeis will stay on the system. This could be an issue for long-running processes, just like memory leaks.

Note that only the direct parent of a child can reap it.

If the parent terminates and the child is still alive, the child gets *adopted* by `init` (its `ppid` is now 1). The child will still run.
To get rid of it, `killall -9 adopt` where `adopt` is program name. This is covered later.
`init` does `wait` and reap its children.

## Changing scripts
A process can change what script it's running via `int execl(char* path, char* arg0, char* arg1, ...)` where the last in the varargs must be a null pointer.
The shell actually does this and passes the command-line arguments to `execl`.
This replaces the old process image with a new one:
- old stack and heap are gone
- old instructions are gone
- resources on kernel side (e.g. files) are kept.
It returns `-1` if it fails. If it succeeded, it won't actually return at all, and will just resume program execution with the new program.

```c
// execl.c
if (argc < 3) {
    fprintf(stderr, "not enough args");
    return 1;
}
printf("pre-exec\n");
if (execl(argv[1], argv[1], argv[2], NULL) == -1) {
    printf("post-exec\n");
    perror("Running: ");
}
return 2;
```
If `execl` succeeded here, `post-exec` will never be printed since execution would shift over to the program whose path is given in `argv[1]`.

Invoking `execl /usr/bin/ls -a` will print out what `ls -a` would do in the shell. It prints to the terminal since the stdout file descriptor gets transferred over.

In **most cases**, the `path` and `arg0` arguments to `execl` are the same. You can lie about the name of a program through `arg0` though -- one common use is to make different programs with the same name and have behaviour dealt with by name.

To take the contents of the `PATH` variable into account, use `execlp`. This course will always use this over `execl`, so we can then do `./a.out ls -a`.

Also, instead of passing the strings through varargs, we can use `int execvp(char* path, char** argv)`.

```c
if (!fork()) {
    char* args[2];
    args[0] = "ls";
    args[1] = NULL;
    execvp("ls", args);
    perror("trying to run ls\n");
    exit(2);
}
wait(NULL);  // we don't care about status
printf("wait complete\n");
return 0;
```

To summarise, to run another program, we clone ourselves and replace the clone's memory with a new program.

## Signals
Signals are very simple messages from the kernel to a process. They only carry on/off information. If a previous signal hasn't been handled yet, additional signals of that type will be ignored.
(there's other types of signals that don't follow these definitions, but we won't use them)

The kernel can send signals on its own initiative, like segfault (SIGSEGV), writing to a destination that won't accept input (SIGPIPE), etc.
Also, another process can ask the kernel to send a signal, such as the shell `kill` command or `kill()` syscall.

Processes have signal handlers registered with the kernel, just like interrupt handlers from embedded. The kernel fakes a function call when a signal is delivered, just like exceptions.
If a program doesn't define a handler, the default will be used, which usually terminates a process.
So, `kill` is actually used to send signals to a process, but often it dies.

To see signals available on a system, use `kill -l`. In code, `#include <signal.h>` and use symbolic names like `SIGINT`.

To register a signal handler, we fill in a `sigaction` struct and pass it to the sigaction function (see `man sigaction`). Older functions exist and shouldn't be used.

```c
bool itHappened = false;  // global variable. allowed for signal handlers

// parameter is for if we handle multiple signals
void notice(int s) {
    itHappened = true;
}

int main(void) {

struct sigaction sa;
memset(&sa, 0, sizeof(sa));
sa.sa_handler = notice;
sa.sa_flags = SA_RESTART;
sigaction(SIGINT, &sa, 0);  // could fail. check man page to be defensive

while (true) {
    while (!itHappened) {
        usleep(500000);
    }
    printf("it happened\n");
    itHappened = false;
}
return 0;

}
```
This program uses a global variable. If not for signal handlers, the inner while loop would never terminate since within the scope of the loop, nothing would change the value.
Pressing ctrl+c (for SIGINT) will make the program print `it happened`.

SIGQUIT is ctrl+backslash.

`wait()` blocks until a child ends, which isn't useful if we want to do work while the child is running. Could use `result = waitpid(pid, &status, W_NOHANG)` to check status of a particular child (use `-1` as first argument to wait on any child), but if there's lots of children may need to check each one.
SIGCHLD sent to parent process when one child changes state. Use `sa.sa_flags = SA_RESTART | SA_NOCLDSTOP` to avoid it triggering when the child stops/resumes execution.

Signal handlers should be very light and shouldn't acquire locks (to be seen later).
`sigwait()` can make program sleep until a signal is received.