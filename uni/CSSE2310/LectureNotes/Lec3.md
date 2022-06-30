# Lecture 3

## Multidimensional Arrays

Consier `M`*`N` array.
Can do statically:
```c
int arr[M][N];
```
but this can't be resized. Alternatively, can try array of arrays:
```c
int** arr = malloc(sizeof(int*) * M);
for (int i = 0; i < M; i++) {
    arr[i] = malloc(sizeof(int) * N);
}

arr[i][j];  // lookup

for (int i = 0; i < M; i++) {
    free(arr[i]);
}
free(arr);
```
This doesn't lay elements out contiguously, though, and subarrays aren't necessarily of length `N` (although we've constructed them that way).

Could also allocate single `M`\*`N` block and simulate first dimension with pointers that point to specific locations within that `M`\*`N` block. This could possibly increase performance with array accessing, since the whole block could fit in cache instead of disconnected blocks for each row?

## Files

Unix philosophy: "everything is a file".

Type for files in C is `FILE*` defined in `stdio.h`, treated as an opaque type (only interact with them through pointers, don't interact with internals since library deals with it).
Use `fopen()` to get a `FILE*`, and close it with `fclose()` when you're finished. Don't `free` a `FILE*`; not your responsibility.
`stdin`, `stdout`, `stderr` are special `FILE*` variables that are always available.

Poor man's `cp`:
```c
#include <stdio.h>

int main(int argc, char** argv) {
    if (argc != 3) {
        return 1;
    }
    FILE* in = fopen(argv[1], "r");
    FILE* out = fopen(argv[2], "w");
    do {
        int c = fgetc(in);  // gets 1 character from in
        if (c != EOF) {
            fputc(c, out);
        }
    } while (!feof(in));
    fclose(out);
    fclose(in);
    return 0;
}
```
`feof` checks for eof...

Note that this checks EOF twice. Not strictly necessary:
```c
#include <stdio.h>

int main(int argc, char** argv) {
    // ...
    FILE* in = fopen(argv[1], "r");
    FILE* out = fopen(argv[2], "w");
    while (c = fgetc(in), c != EOF) {
        fputc(c, out);
    }
    fclose(out);
    fclose(in);
    // ...
}
```
This uses comma operator, which evaluates first statement, discards return value then evaluates second statement.
Usually used when first statement has side effect we're interested in, such as `c = fgetc(in)`.

`fopen` returns `NULL` if it can't open the file. It will set `errno` variable to indicate the problem, accessed by `#include <errno.h>`. `perror()` gives informative error message, like "No such file or directory", "Permission denied" etc.

## `scanf` and friends

`fscanf` extracts stuff, with similar format specifiers as `fprintf`. Pass pointers to values.
Note that scanf doesn't care about whitespace, including newlines. It will return the number of things it matched.

fscanf makes error handling difficult, though. Consider using `sscanf` operating on strings instead, in conjunction with `fgets` to get one line at a time.

## Buffered output

`watch -n seconds command` runs `command` every `seconds` sec, and display the output on the screen.

File buffers aren't flushed until `fclose` is called. Flush manually with `fflush(FILE*)`.
Some files are line-buffered, so any newline causes a flush. This includes `stdout`. Files on disk
usually aren't. `stderr` flushes all characters immediately (unbuffered).

Redirecting stdout/stderr to a file makes the buffering behaviour revert to fully buffered, since the output file is fully buffered.

There is a system limit on how many files a process can have open at one time. If program exists normally (returning from `main()`, call `exit()`), all open files will be closed. If it exists abnormally, they will still be closed but not flushed.

## Macros

Macros and things that start with `#` are preprocessor directives. Be careful with macros and `()`.



