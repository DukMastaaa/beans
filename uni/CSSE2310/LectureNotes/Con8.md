# Contact 8

## More on Makefiles
`$@` is file name of target, `$<` is name of first prereq, `$?` is names of prereqs newer than target and `$^` is names of all prereqs.

Non-file targets (targets w/o file dependencies) will always be built if you run `make` with its name, but file targets will only be built if the target doesn't exist or if there are dependencies newer than the target.
Default target is first in file which can be changed with `.DEFAULT_GOAL := defaulttarget`. Phony targets have no associated output file, like `all`, and are specified as dependencies of `.PHONY` like `.PHONY: all`.

`=` is lazy evaluation, recursively expanding at time of use. `:=` is immediate evaluation. `+=` appends new value to previous definition. Access variables with `$(BEANS)`, and targets can modify them.

`CC` and `CFLAGS` can be set to specify the default C compiler and its flags. This can be used with implicit rules -- `make` knows how to build `.o` from `.c`, and executables from `.o`/`.c`. So, we can simplify the Makefile by only listing `.o` dependencies, and set `CC`, `CFLAGS` and `LDFLAGS` (linking):
```makefile
CC=gcc
CFLAGS= -Wall -pedantic -std=gnu99
OBJS=hw.o hw2.o
PROG=hello
.PHONY: all clean
.DEFAULT_GOAL := all
all: $(PROG)
$(PROG): $(OBJS)
$(CC) $(CFLAGS) $(OBJS) -o $(PROG)
clean:
rm $(PROG) $(OBJS)
```

## Modularity Basics
Can use multiple source files to make code more modular. Functions and other objects are *declared* in a `.h` header file, and `#include`d in a `.c` source file.
As `#include` copy-pastes the content of the header file into the current translation unit (source), *header guards* are necessary to avoid multiple declarations or definitions.
```c
#ifndef UNIQUE_NAME
#define UNIQUE_NAME
// stuff goes here
#endif
```

Function pointers can be used to dispatch functionality at *runtime*, usually used for reducing duplication/changing functionality depending on user input. Linker modularity involves having multiple source files with functions adhering to the same signature but with different implementations, where the linker is instructed to choose a specific version at *compile-time*. This is used to build multiple programs that have subtly different functionality.
