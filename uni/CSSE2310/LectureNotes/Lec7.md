# Lecture 7

## Threads

Multiprocessing with `fork`, `exec` etc is difficult as debugging multiple processes simultaneously is difficult, and pipes are limiting in that they are just a unidirectional stream of bytes. There is higher overhead working across processes due to context switching and pipe buffering. Shared memory can get around this, but threads are main solution.

Executing code requires
- process container (address space, open files, etc)
- code/instructions, sometimes called "text segment"
- global variables and constants
- heap
- stack
- cpu and registers

Using `fork` to get multiple workers only shares open files between the processes. Everything else is separate. So, different processes can work on tasks as they start off with same knowledge, but difficult to commmunicate across.

A thread is a worker in a process, so each process has at least one thread. There are different implementations across operating systems; we will use `pthread`. We want threads working in the same process to share information easily, including
- process
- code
- global variables/constants
- heap
but not stack, cpu or registers. Any thread running in a process can interact with a variable used by any other thread provided they have a pointer to it. The kernel checks memory per process so this isn't an issue.

2 main approaches to threads are
1. "native" or "kernel" threads where threads are known by the kernel. They can be scheduled and run independently (scheduling is out of scope). We use this.
2. "green" threads made from a user-space library, saving registers and modifying program counter to switch between activities. This appears as a single threaded process to the kernel, and doesn't actually use multiple cpu cores. Blocking IO brings problems. Python uses this.

### Blocking IO
Consider a program needing to interact with multiple `FILE*` or `fd`s. Doing something like
```c
while (!done) {
    read from A and process
    read from B and process
    read from C and process
}
```
isn't great, as data from B and C won't be processed until A has sent data. Using threads,
```c
... interact(FILE* src) {
    read from src and process
}
run interact(A) in thread
run interact(B) in thread
run interact(C) in thread
```
Now, each thread can block separately without affecting processing of the other files.

A non-threaded alternative is checking if the file is ready to read from before reading. But, the loop may run thousands of times before input arrives, termed "busy waiting". 

Event-driven programming is another approach, with something like
```c
while (!done) {
    sleep_until_input_available_on(A, B, C)
    process input
}
```
`man select` to see an example of a function like this. One call may suffice since most time is spent waiting, but this approach is more difficult to use since `fd`s are required (no `FILE*`), and it's harder to track the progress of multiple tasks, compared to threads having their own contexts.

### `pthread`
We use the POSIX-thread API `pthreads`, where implementations exist for most operating systems including Windows. From here, "thread" refers to `pthread` threads. Need `#include <pthread.h>`.

Unlike processes, threads have no parent-child relationships. Any thread can "join", or wait on, any other thread in the same process, but threads can't interact with threads from other processes.
Any thread calling `exit` will end *the whole process*, including other threads.
Calling `fork` will be discussed later.

When using threads and signals, best way is to create a thread that has the responsibility to deal with all signals. Otherwise, incoming signals (to the *process*) could be received by any thread.

Each thread is created to run a function, and from our perspective, the thread exits when the function returns. The function must have type
```c
void* foo(void*);
```
so the function can accept any parameter by casting from `void*`, and return anything to the thread that `join`s on it by casting to `void*`.

To compile with `pthreads`, `gcc` needs the `-pthread` flag for both compiling and linking. Don't link the `pthread` library directly as `gcc` needs to do special things when using threads.

To create a thread, use
```c
int pthread_create(pthread_t* thread,
        const pthread_attr_t* attr,
        void* (*start_routine)(void*),
        void* arg);
```
ID of thread is stored in first argument. Second argument will be ignored for now. Third argument is thread function, fourth are arguments. Return value indicates success; see `man pthread_create`.

As an example,
```c
void* hello(void* v) {
    char* s = (char*)v;
    printf("Hello %s\n", s);
    return 0;
}

int main(int argc, char** argv) {
    pthread_id tid;
    pthread_create(&tid, 0, hello, "Larry");
    pthread_create(&tid, 0, hello, "Curly");
    pthread_create(&tid, 0, hello, "Moe");
    sleep(2);
    return 0;
}
```
Here, there's no guaranteed order in which these threads will run; that's up to the kernel.

If we remove the `sleep()` in the above example, the following scenarios could occur on execution:
1. Not all threads execute. This is due to the main thread (we have 4 threads) exiting, killing all of the other threads in the process.
2. Messages get printed twice. This may be that threads are being killed after they've written data to a buffer but before they've registered that they've done so, i.e. leaving internal data structures in inconsistent states.

To mitigate this, rather than returning from the main thread, we can call `pthread_exit((void*)0);` to exit the current thread but not exit the whole process. This gives same behaviour to the `sleep()` version except the sleeping.

If we wanted our thread function to deal with `int`s instead of `char`s, we could `malloc` an int from the main thread, cast the `void*` to an `int*`, dereference the pointer then free it. Not `malloc`ing is a bad idea as that variable could be modified from the main thread. For example, this sometimes prints duplicate numbers as `val` has been modified before two threads got the chance to print.
```c
for (int i = 0; i < 5; i++) {
    int val = i;
    pthread_create(&tid, 0, hello, &val);
}
pthread_exit((void*)0);
```
Another reason why not using `malloc` is a bad idea is that we're passing a pointer to a thing on the *stack* of the main thread. If the main thread exits for some reason, the stack may be cleaned up and that address may be used for something else - can't be certain.

Instead of passing in an `int*`, we could *abuse* pointers by passing in a literal `int`, casting to/from `void*` and `int` (not `int*`). This is another bad idea, as the size of `void*` and `int` are system-dependent, and code may not be portable (narrowing conversion?).

To hold multiple parameters, define a struct to hold all the values then pass a pointer to that struct in. Same for returning multiple things. Could also add a wrapper function for convenience, like
```c
void do_things(char** items, char* s, int limits);
struct Params {
    char** items;
    char* s;
    int limits;
};
void* do_things_wrapper(void* v) {
    struct Params* p = (struct Params*)v;
    do_things(p->items, p->s, p->limits);
    free(v);
}
```

Here's an example using `pthread_join` to access the return value from another thread.
`do_cube` frees given pointer, mallocs another pointer with result of input cubed.
`alt_cube` modifies given pointer in place.
```c
pthread_t tid;
int* p = malloc(sizeof(int));
*p = 4;
pthread_create(&tid, 0, do_cube, p);
// Now we wait for the thread to finish
// We need somewhere to store the return value
void* res;
pthread_join(tid, &res);  // &res is void**
printf("Thread returned %d\n", *(int*)res);
// p got freed by do_cube, need a new allocation
p = malloc(sizeof(int));
*p = 4;
pthread_create(&tid, 0, alt_cube, p);
pthread_join(tid, NULL);  // don't care what it returns
printf("Thread clobbered p: %d\n", *(int*)p);
```
Note that `pthread_join` requires `void**` as thread function returns `void*`. pthread functions return error codes so should check and read man pages.

Zombie threads are basically threads which have finished execution but haven't been joined. `pthread_join` deals with this like `wait` for processes. `pthread_detach(tid)` tells the system to clean up that thread automatically, where we don't care about the return value. The second argument of `pthread_create` can be used to *start* a thread detached.

To deal with signals, see `man pthread_sigmask` and `man sigwait`.

Threads can be killed with `pthread_cancel(tid)`, but it's difficult to do safely. A better approach is to use a shared variable that the thread checks.

`pthread_t pthread_self(void)` returns the thread id of the current thread. This can be used for detaching yourself.

### Racing
Consider thread function which increments an `int*` given to it. In `main()`, we set up some threads (and store their thread ids in an array), and for each of the threads, we call that thread function and pass in a pointer to a local `int`, so all of those threads attempt to increment that `int`.
We will find many less increments than expected, due to the `++` operation not being atomic (a value needs to be read, addition needs to be done then value needs to be written). The threads will be interrupting each other during this process, and this is called a *race condition*.

Attempting to build a primitive lock via
```c
struct Lock {
    pthread_t who;
};

void take_lock(struct Lock* l) {
    while (l->who != 0);
    l->who = pthread_self();
}

void release_lock(struct Lock* l) {
    l->who = 0;
}
```
where we pass the lock also to the thread function and surround the increment with `take_lock()` and `release_lock()` doesn't fix the problem, as `l->who = pthread_self();` has the *same* race condition as earlier; after the lock is released, all of the threads race to set `l->who`, and the last thread to do so claims the lock.
This "lock" fails to do 2 desirable things:
1. Ensure mutual exclusion (mutex)
  - much simpler to do with hardware, but see Peterson's algorithm for a method with less hardware assistance
  - usually accessed via library calls
2. Avoid busy waiting

### Semaphores
A semaphore is an opaque type representing an integer value. Two atomic operations are defined:

- `sem_wait()`. If `value > 0` then `value--`. If `value == 0`, stop process until `value > 0`, then attempt to decrement.
- `sem_post()`. Increment `value`.

`sem_wait` can be thought of as grabbing a resource, whose count is given by `value`. `sem_post` can be thought of releasing it. Doesn't have to be 0/1.

If some threads are waiting on a semaphore and a `post` occurs, only one thread unblocks. Not necessarily all threads get a turn eventually -- this is called starvation, discussed later.

Semaphores initialised with `sem_init(sem_t* sem, int pshared, unsigned int value);` where `sem` is a declared semaphore, `value` is initial value, and `pshared` is 0 for semaphore sharing between threads and non-zero for sharing between processes. We care about `pshared == 0` in this course. `sem_destroy` cleans up. Always pass pointers to semaphores, never the semaphore itself.

Incrementing code example from before now works with semaphores. Since we're using it for mutual exclusion, `sem_init` to 1, `sem_wait`, then `sem_post` to release. Provided all paths into the *critical section* (accessing shared resource) require waiting and all paths out `post`, this ensures mutual exclusion.

When using semaphores for non-busy waiting, `sem_init` to 0, `sem_wait` until another thread calls `sem_post` to let the current thread know something happened. This is often used for producer/consumer tasks, and multiple consumer threads can `wait` on the same semaphore. However, for multiple threads, we need another mutex to control access the job queue, i.e. producer acquires lock to add to queue, releases the lock, and alert consumer; consumer on alert acquires lock to pop from queue, releases lock. 

We can use semaphores to limit the amount of threads active by considering the threads themselves as a resource, and having the threads `wait` when created and `post` when leave.

### Volatility
Compiler can choose to optimise things like
```c
total = 0;
total += *a;
total += *a;
total += *a;
total += *a;
```
In a single-threaded context (or if `a` points to something only the current thread can access), this is equivalent to `total = 4 * (*a)`. The compiler can optimise this out. However, if the value pointed to by `a` is changed by another thread, `total` isn't necessarily `4 * (*a)`, but the compiler won't know unless `a` is declared as volatile (`volatile int a;`).
Use `volatile` when a variable may be modified by one thread and read in another.

`volatile const` is legal, as `const` indicates we cannot modify the variable. `volatile const` is common for hardware registers where the hardware will modify but it's read-only to us. Note that local variables that aren't shared across threads aren't volatile.

### Thread-Safety
A function is *thread-safe* or *re-entrant* if multiple threads can have active calls to the function at the same time. For example, POSIX `rand()` is not re-entrant as it contains internal state (seed or something else), but `rand_r()` requires us to pass a pointer to store that seed, so it's thread-safe. Usually functions with `_r` indicate re-entrant.
`fprintf` and related actually are thread-safe -- man pages indicate.
`man 7 pthread` has a list of POSIX functions that are **not** thread-safe.

Consider thread `i` from 1..n writing value `xi` to `*p`. Clearly, there is a race condition where we don't know which thread writes last, but also, if `xi` is double a processor word (e.g. `long double`), one thread could actually write **half the bits** into `*p`... so it's not even guaranteed `*p` stores any of `xi`.

### Other Complications
*Deadlock* occurs when a group of threads need to access multiple resources, but the order that they access and wait leaves them perpetually waiting on everyone else. For example,
```c
// thread 1
wait(sem1);
wait(sem2);
// do something
post(sem1);
post(sem2);

// thread 2
wait(sem2);
wait(sem1);
// do something
wait(sem2);
wait(sem1);
```
Both threads never reach `// do something` as on the second line, they're waiting for each other to release the lock. In simple cases like this, we can solve the probelm by having all threads request resources in the same order, but this doesn't always work for harder cases.

*Livelock* is similar but the threads aren't blocking -- they still are releasing and acquiring, but they never actually acquire. It's like approaching someone in a hallway and both you and them keep moving from side to side trying to get past each other.

*Starvation* is when some of the threads never get their resources, possibly by some random acquire/release to deal with deadlock.

### Miscellaneous info on `pthreads`
Calling `fork()` in a multithreaded program only duplicates the thread which called `fork()`. Also, be careful of locks and the child inheriting data.

`sem_trywait` is non-blocking, so either locks immediately or throws error. `sem_timedwait()` puts time limit on how long the thread can wait. There are a few functions for creating semaphores in shared memory -- not used in this course.

`pthreads` also specifies `pthread_mutex_t` which only offers mutual exclusion, and can only be unlocked from the thread which locked it.
`pthread_condition_t` are condition variables for waiting until some condition holds -- each is linked to a mutex.

