# Lecture 6

Assignment 3: 'literal interpretation' of technical detail in lectures.
57/65 for median functionality in Assignment 1.

In forks, child is perfect clone. Child gets 0 and parent gets pid of new child.
`exec` replaces the current process with a new program, waking up in main.

Unix abstracts things that don't seem to be files with file interface.
For example, `/proc/cpuinfo` is a 'virtual file' which tells us details of the CPU.
This isn't a text document; when an application attempts to open it, the kernel
fakes the file. IO devices have file handles that are stored in `/dev`.

To treat something as a file, the kernel needs to know how to
- open and close
- read and write (bytes only)
- seek, so move around in the file

Some calls may return errors, like trying to seek in `stdin`.

From Lecture 3, `FILE*`s aren't *file descriptors*.
At a lower level than stdio, Unix systems use *integers* to represent open files.
Internally this is just an index in a lookup table maintained by the kernel.
When the kernel is asked to open a file, it gives back a file descriptor.
When a program wants to interact with a file, it gives the kernel the integer.

```c
// fd.c
int fd = open("fd.c", O_RDONLY);
if (fd < 0) {
    perror("Opening");
    return 1;
}
char buff;
while (read(fd, &buff, 1) == 1) {  // not efficient
    printf("%c", buff);
}
close(fd);
return 0;
```
Above call works and prints out its own source code, but issues one
system call per character. System calls are expensive because of context
switching, so we can just allocate more space per call.
```c
// fd2.c
// ...
char buff[20];
ssize_t got;
while ((got=read(fd, &buff, 20)) > 0) {
    for (int i = 0; i < got; i++) {
        printf("%c", buff[i]);
    }
}
// ...
```
Note that the for loop goes up to `got` not `20`.
`ssize_t` is important here, since `read` can return a *signed* value whereas
`size_t` is unsigned.

> Why use file descriptors when you can use FILE*s instead?

Some of the stuff below can only be done with file descriptors -- this
is at kernel-level rather than through a convenient interface.

> Just like `strlen` gives length of strings, is there a function that gives length
> of files so we can just allocate a buffer of that size?

There is as we'll see later, but probably not best idea to allocate 1GB buffer...

```c
// write.c
int fd = open("output", O_WRONLY | O_CREAT, S_IRWXU | S_IRGRP);
if (fd < 0) {
    // ...
}
char buff[20];
for (int i = 0; i < 20; i++) {
    sprintf(buff, "Line %d\n", i+1);
    if (write(fd, buff, strlen(buff)) < 0) {
        perror("Writing");
    }
}
```
Here, `write` returns the number of characters successfully written.
This output should be the same as the length of the string we wrote..
Also, here, we **don't want a null-terminator character in the file**!

> How is EOF getting put in to the file in this example?
EOF isn't a magical character. It's a state where there's nothing left in the file to read,
so by closing the file we've told the system that there's no more bytes.

Note that after a fork, the parent and child have the *same file descriptors*. So if
parent seeks through a file, the child will see that change in offset.
However, if parent and child open independently after the fork, they have different
file descriptors and thus view the opened file separately.

System calls act as *scheduling points*; race conditions caused by shared file descriptor
can branch then.

`dup2(fd1, fd2)` throws away the file descriptor `fd2`, and when any operations get done
on `fd2`, alias that to `fd1`. To get it back, we can call `dup()` first which literally
just duplicates it, then restore it after.
`STDIN_FILENO`, `STDOUT_FILENO` etc are just 0, 1, 2.

```c
int fd=open("listing", O_WRONLY | O_CREAT | O_TRUNC, S_IRWXU);
printf("%i\n",fd);
dup2(fd, 1);
close(fd);
execlp("ls", "ls", "-l", NULL);
```

Redirection **changes the underlying file** for std-whatever, and points it to something else.

## Pipes
How does `ls -l | sort -r` work? stdout of `ls` somehow connected to stdin of `sort`.
It isn't the same as `(ls > tempfile &); (sort -r < tempfile)` as this assumes the current
directory has read/write perms, and `sort` could hit EOF before `ls` finishes writing.
We want something that doesn't use files on disk.

Consider pipe between process A and process B. Each has a file descriptor, A can write in, B can read out.
We'd like the following functionality to happen:
1. If process B reads but process A hasn't sent anything yet, process B will block until there is something in the pipe.
2. If process B reads but process A will never send anything again and the buffer is empty, process B will get end of file.
3. If process A writes but B is busy doing other things and not reading from the buffer, process A will block until the pipe is no longer full.
4. If process A writes but process B will never receive anything again, process A will receive the signal SIGPIPE.

Note that the receiving process must actively read to get data from the pipe. Two pipes can't be stuck end-to-end; need a process in the middle.

File descriptors are just numbers, and don't have meaning outside one process's context. Passing a file descriptor to another process won't mean anything to it.

`int pipe(int fd[2])` gets passed in an array to 2 file descriptors. A successful call **fills in** this array, where `fd[0]` is the read end and `fd[1]` is the write end. 

Let's say pipe from processes A->B. The usual pattern is:
1. A calls `pipe()` and holds both ends of the new pipe.
2. A `fork`s to make process B. Now, B also holds both ends of the pipe.
3. A closes its `fd[0]`, read end.
4. B closes its `fd[1]`, write end.
5. Done! Now, A can write into its `fd[1]` (write end), and B reads from its `fd[0]` (read end).

For bidirectional communication, A needs to make 2 pipes before forking.

```c
int fd[2];
if (pipe(fd)) {
    perror("Pipe:")
}
for (int i = 0; i < 30; i++) {
    dprintf(fd[1], "Line %i\n", i);
}

// very important! otherwise, read will block as write end still open
close(fd[1]);

int got;
char buffer[40];
while ((got = read(fd[0], buffer, 40)) > 0) {
    for (int i = 0; i < got; i++) {
        fputc(buffer[i], stdout);
    }
}
close(fd[2]);
```

Generally, should handle `SIGPIPE` in some way if you're using pipes. Otherwise it will terminate program.

To convert from file descriptors to `FILE*`, use `FILE* fdopen(int fd, const char* mode)`.
Use `int fileno(FILE* stream)` to get back the file descriptor.
When `fclose()` is called, the underlying file descriptor is also closed.