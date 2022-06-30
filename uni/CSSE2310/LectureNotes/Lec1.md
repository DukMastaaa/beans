# Lecture 1

Assignments:

1. C strings, files
2. Debugging (gdb)
3. Multiple processes, pipes
4. Network client and server

Code needs to compile on `gcc`, `moss.labs.eait.uq.edu.au`

Email: csse2310@uq.edu.au

## C Program

First C program:

```c
int main(int argc, char** argv) {
    return 0;
}
```

`0` return code is standard for OK

`$?` in bash gives the exit code of the command that just ran.

`file` in bash tells you what kind of file you're looking at.

`!gcc` in bash runs `gcc` with the previous arguments...?

Some compiler options:

* `-std=c99`,`-std=gnu99` at least is required for asmts
* `-g` debug info
* `-Wall` this is a lie
* `-O2` optimise
* `-Werror` make all warnings fata

`man` has different sections for each command to manage namespaces. Run `man man` to see them. Specify section with `-s`, so `man -s 3 printf`. Find all functions with given name using `-k`.

## Arrays

Array size must be specified when creating it (unless you let compiler deduce), and size is part of the type so `int a[3]` and `int a[4]` have different types.

```c
int a[] = {1, 3, 5};  // deduce size
```

Strings are null-terminated (`'\0'`) arrays of characters. The following are equivalent:

```c
char str[6] = "hello";
char str[] = {'h', 'e', 'l', 'l', 'o', '\0'};
```

`""` literals have implied null character.
