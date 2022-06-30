# Lecture 2

## `main`

`main` function signature either `int main(void);` or `int main(int argc, char** argv);` (equivalently, `int main(int argc, char* argv[]);`).
- `argc` gives number of strings in array
- `argv[0]` is the name of program being run
- everything else in `argv` are command-line arguments passed

`printf` prints a null pointer as `(null)`.

If you go past `argc`, you get `null` then command-line environment variables.

## Pointers
A pointer is a value which is the memory address where another thing can be found. Its type is determined by the type of the thing it points to, like `int*` or `char*`.

Use the `*` unary operator to dereference a pointer, and the `&` unary operator to get the address of a variable, like
```c
int x = 123;
int* p = &x;  // p points to x
*p = 456;  // set the value pointed to by p to 456. same as x = 456.
int y = *p;  // set y to the value pointed to by p. same as int y = x.
```

## Strings

Strings are represented as arrays of characters, and well-formed strings are terminated by a null byte `'\0'`. Not all `char` arrays hold well-formed strings.
An empty string is thus just `{'\0'}`.

- `char* strcpy(char* dest, const char* src)` copies characters from `src` to `dest` including `'\0'`, and stops at `'\0'`. It returns `dest`.
- `size_t strlen(const char* str)` gets the length of `str` i.e. number of chars before `'\0'`.
- `char* strdup(const char* s)` returns a copy of `s` allocated with `malloc`.
- `char* strcat(char* dest, const char* src)` appends `src` to `dest` and overwrites dest's `'\0'`. It does not check if `dest` has enough space to store the new string.

Note that since arrays devolve into pointers when passed to functions, the following do different things:
```c
char str[7];
size_t length = sizeof(str) / sizeof(char);
// length == 7

char* str;  // points to first element of string with length 7
size_t length = sizeof(str) / sizeof(char);
// length == sizeof(char*) / sizeof(char) == 8 / 1 = 8
```

The `%s` specifier for `printf` and related takes in a `char*`, and all characters until the `'\0'` get printed out.

Unless managed well, having a fixed-length buffer to store strings in will lead to buffer overflow. `malloc` and `realloc` can get around this.

Note `int* x, y, z;` only declares `x` to be a pointer. `y` and `z` are just `int`s.

## `typedef`

Use `typedef`s to alias a type: `typedef full_type alias;`. You can also typedef a struct, which brings the name of the struct into the global namespace. For example,
```c
typedef struct {
    char* buf;
    int len;
} String1;
```
instead of just
```c
struct String2 {
    char* buf;
    int len;
};
```
`String1` can be referred to directly by name, but `String2` needs to be addressed by `struct String2`.

Reference the name of the struct within the member definitions as follows:
```c
typedef struct Node1 {
    int value;
    struct Node1* next;
} Node;
```
`struct Node1` is the actual name of the struct, and we need to use it within the body since `Node` hasn't been defined yet. Outside we can just use `Node`.

## Subversion

Subversion (SVN) is a version control system where you can store history of project as a series of commits. SVN is centralised, so a repository is located via a URL:
```
https://source.eait.uq.edu.au/svn/csse2310-sem1-s???????
```
This can be viewed in an internet browser via
```
https://source.eait.uq.edu.au/viewvc/csse2310-sem1-s???????
```
Working copies are stored locally, and states can be committed back to the repository.

- `svn checkout URL working_dir` is like `git clone URL working_dir`.
- `svn add filename` tells SVN to track changes to `filename`.
- `svn mv oldname newname` renames/moves a file
- `svn rm filename` removes the file locally and deletes it for future revisions
- `svn status` shows `M` for modified, `A` for untracked to be added, `D` for files to be removed, `?` for anything else (executables, untracked etc)
- `svn diff` shows lines changed since the last commit or another commit
- `svn commit` commits and asks for a log message. 
    - Alternatively, specify this via `svn commit -m "message"`
    - Commit specific files with `svn commit f1 f2 f3`
- `svn log filename` shows history of commit messages for `filename` 
- `svn revert filename` reverts `filename` to the last commit (irreversible)
- `svn update` is essentially `git pull`, and can lead to conflicts.
Revisions are specified with `-r#` like `-r17`.

Best practices for revision control include:
1. Commits should compile and run correctly
2. Commits should be granular, representing small changes.
These allow bisecting commits to find bugs.
3. Commit messages should be meaningful (this is assessed)
    - Describe *what* and *why* rather than *how*
    - What effect will change make?
    - Active voice, present tense (complete "if applied, this commit will ...")

## Makefiles

Makefiles automate building of the program. The program `make` understands dependencies between files and avoids recomplation of sections that have not changed. `make` looks for a file named `Makefile` or `makefile` in current directory.

Makefiles are made up of a set of rules, consisting of
- a *target*, the file to be generated/action to be carried out
- *prerequisites* or *dependencies*, which are files that exist or other actions. A rule without a prerequisite will always run.
- *recipes*, listing how to build the target once prerequisites are satisfied.

```makefile
all: tictactoe
tictactoe: tictactoe.c tictactoe.h
	gcc -Wall -pedantic -std=gnu99 -o $@ $<

clean:
	rm tictactoe
```
`$@` gives the name of the target and `$<` gives the name of the first prerequisite.
Indentation is done by ***tab characters***, not by spaces.

Implicitly, you can define
```makefile
CFLAGS=-Wall -pedantic -std=gnu99
CC=gcc
```
which allows you to just type `make test.c` and have it build. We'll cover this later.