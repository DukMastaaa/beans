# Contact 9 + Lecture 10

## Sockets
A *socket* is a communication endpoint. In UNIX, it's associated with a file descriptor -- we can do file IO on most sockets. The main distinction between file IO and socket IO is how we "open" the socket. There are many types of sockets, but we just focus on Internet sockets. Within this group,
- stream sockets (TCP)
    - full-duplex (bidirectional) byte streams
    - reliable, connected
- datagram sockets (UDP)
    - unreliable, connectionless
    - limited-size messages
- raw sockets
    - direct access to network layer; see `raw(7)` man page

Here are some socket primitives.
- `socket()`
    - create new communication endpoint
- `bind()`
    - attach local address to socket
- `listen()`
    - indicate willingness to accept connections
- `accept()`
    - block and wait for connection attempt to arrive
- `connect()`
    - attempts to estabilish a connection
- `send()`/`write()`/`recv()`/`read()`
    - send/receive over connection (UDP). can use FILE* as well
    - `send()`/`recv()` have more options. This course will just use `write()`/`read()`.
- `sendto()`/`recvfrom()`
    - send datagram (UDP). we need message and dest. addr.
- `close()`
    - destroy socket, reclaim resources, release connection
- `shutdown()`
    - close down one/both sides of connection

Typically, the server does these things:
1. Create socket with `socket()`
2. Bind to address/port with `bind()`
3. Specify willingness to accept connections with `listen()`
4. Loop
    1. Block waiting for a connection with `accept()` which returns a new socket. Original socket continues to listen
    2. Deal with request (multithreaded?)
    3. Communicate with client with `write()`/`read()`
    4. Close connection wtih `close()`

Typically, the client does these things:
1. Create socket with `socket()`
2. Connect to server given address/port with `connect()`
3. Communicate with server with `write()`/`read()`
4. Close connection with `close()`

Clients don't usually call `bind()` as they don't care about the outgoing port.

For datagram (UDP) applications (not relevant for asmt 4), receiver does
1. `socket()`
2. `bind()`
3. No connection, so just `recvfrom()` and `sendto()`
4. `close()`

The sender does
1. `socket()`
2. `sendto()`
3. `close()`

## IP Addresses in C
32-bit IP addresses stored in `struct ip_addr`. On Linux,
```c
typedef uint32_t in_addr_t;
struct ip_addr {
    in_addr_t s_addr;
};
```
They are stored in network byte order, i.e. big-endian. Linux on x86 uses little-endian. The functions `htonl`, `htons`, `ntohl`, `ntohs` convert long/short to/from network byte order, which is system-independent. Use `s` functions for ports.

To convert to/from string representation, use `int inet_aton(const char* cp, struct in_addr* inp);` and `char* inet_ntoa(struct in_addr in);`. The latter returns pointer to statically-allocated space and is not thread-safe, so can use `inet_ntop`/`inet_atop` instead.

We can also construct these manually in host representation. For example, with `216.254.125.70`,
```c
uint32_t hostAddress = (216 << 24) | (254 << 16) | (125 << 8) | 70;
struct in_addr a;
a.s_addr = htonl(hostAddress);
```

## Sockets in C
```c
int fd;
if ((fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    perror("socket creation failed");
    exit(1);
}
```
Here, `AF_INET` indicates IPv4, `SOCK_STREAM` indicates reliable byte stream connection, and the third argument is the specific protocol (0 default).
`socket` returns -1 if fails.

For addresses, since C did not have `void*` when this was implemented, we have a generic socket address struct.
```c
struct sockaddr {
    unsigned short sa_family;  // protocol family
    char sa_data[14];  // address data
};
```
Then, for Internet-specific socket addresses, we must cast `struct sockaddr_in*` to `struct sockaddr*` for `connect()`, `bind()` and `accept()`, where
```c
struct sockaddr_in {
    unsigned short sin_family;  // address family (AF_INET for us)
    unsigned short sin_port;  // port num in network byte order
    struct in_addr sin_addr;  // IP addr in network byte order
    unsigned char sin_zero[8];  // padding to sizeof(struct sockaddr)
};
```

## netcat
To test client/server functionality, can use netcat. To start a server, `nc -4 -l 43210` to use IPv4 on port 43210. To connect to server, `nc -4 localhost 43210`. Ports are machine-wide so need to pick a number no-one else is using. `localhost` is defined on most systems to give *an* IP address of the current machine ('an' because machines can have multiple names and IPs). It's usually `127.0.0.1` for IPv4.

## Example Client Code
Note that if we want to use `fdopen()` and `FILE*` instead of handling sockets directly, we should `dup` the file descriptor and have one open for reading, one for writing (as sockets are bidirectional).

`getaddrinfo` turns IP address/service name into something C programs can use. It returns `struct addrinfo**`, which is a linked list of `struct addrinfo` (as there can be multiple addresses referring to same socket, like IPv4 or IPv6)

## Multi-Programming for Servers
`accept()` is blocking. To work on a connection and wait for new connections, we need extra workers. The following approaches are common.

### Multi-Processing
Here, the server creates a child process to handle communication. 
- Parent must close client socket after fork, otherwise 1 reference to fd exists after client exits
- Client must close listening socket after fork
- Parents must reap dead children
    - Don't want zombies
    - `accept` interrupted on SIGCHLD unless SA_RESTART is used for sigaction or it's ignored completely

This approach is relatively simple but it's difficult to share data between processes (need some shared memory thing or pipes..)

### Multi-Threading
Using multiple threads instead of processes for concurrent connections makes it easier to share data (just pass pointer to data and secure with mutexes), but can be difficult to debug sometimes.

### IO Multiplexing
The `select()` syscall can wait on multiple fds at once, and basically multiplex responses from clients based on their fd. This approach requires only 1 process and 1 thread, but is definitely more complex to code as you need to manage a set of fds and keep track of connections just from that set.