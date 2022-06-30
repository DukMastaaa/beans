# Contact 10

## Secure and Defensive Programming
Historically, software development has been feature-oriented, and to some extent still is (e.g. IoT devices), and there is always pressure to get the software written (low quality if it must be) to deliver the product. "Customers pay for features, not for security".
However, people are now realising it is more expensive to deal with the fallout of some exploit on vulnerable software. Now, there are laws which require companies with sufficiently large data breaches to disclose this information to the users.

There are many guidelines for secure programming by design, kind of like a functional style guide for code. One option is the [software engineering institute CERT C coding standard](https://resources.sei.cmu.edu/downloads/secure-coding/assets/sei-cert-c-coding-standard-2016-v01.pdf). An example of the opposite is [MITRE common weaknesses enumeration](https://cwe.mitre.org/), listing out common weaknesses and what you can do to fix them.

### Buffer Overflow
See [here](https://www.thegeekstuff.com/2013/06/buffer-overflow/) for code. Essentially, `gets` is used which writes everything it reads from stdin into the given buffer. We declare fixed-length buffer and a `bool` flag on whether we've authenticated properly, setting the flag when `strcmp` returns 0.
This works for inputs less than the size of the buffer, but if we give it more than the length, `gets` may keep writing into the stack and overwrite the `bool` variable we declared which could live adjacent to the buffer memory. Depending on how we've checked the condition, this could make it appear that the check is correct but actually the flag got overwritten.

`gets` is deprecated (`__attribute_deprecated__` attribute) and `gcc` warns you if you use it, but it still exists in C standard library due to backward compatibility.

To protect against this, don't use `gets`. Consider using functions like `strncmp`/`strncpy` instead of `strcmp`/`strcpy`, where you specify the maximum amount of characters that can be accessed.
Also, compilers' `-fstack-protector` inserts a special pattern in the stack surrounding variables, and adds code to check whether that pattern is stiill intact after reads/writes.

## Stack Sniffing
Even when a function is called from `main()`, `main`'s stack frame and the new function's stack frame are still adjacent in stack memory -- just the stack pointer has moved down to point to the new function's frame. If not written well, that function can get access to the stack frame of `main`, called stack sniffing.

As an example, `printf("%x %x %s\n", int1, int2, str)` uses C magic to walk the stack, interpreting the copies of `int1`, `int2` and `str` according to the format specifiers. However, if we just do `printf("%x %x %s\n")` with no additional arguments, `printf` will interpret whatever it finds on the stack (e.g. for `%s`, it'll interpret the next 4 bytes as a pointer, dereference and print chars until `'\0'`).

Also, even for `printf(buf)`, if `buf` contains `%` characters then `printf` will treat `buf` as a format string -- now, user input can sniff the stack. There are some really exploitable format specifiers:
- `%x` and `%lx` prints things in hex
- `%N$s` prints the Nth argument as a string
- `%n` writes the number of characters outputted *to the nth positional argument*

Basically can do `"%p %p %p %p %p %p ..."` to get stuff on the stack, then `%8$s` to print out a secret string...
