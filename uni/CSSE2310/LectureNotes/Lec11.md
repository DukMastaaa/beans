# Lecture 11

## HTTP
HTTP, or HyperText Transfer Protocol, is web protocol for sending "stuff" around on web. Runs on top of TCP. As an example, try `echo -e "GET / HTTP/1.1\n\n" | nc student.eait.uq.edu.au 80`, which gives something like
```
HTTP/1.1 400 Bad Request
Server: nginx/1.18.0
Date: Fri, 13 May 2022 02:26:18 GMT
Content-Type: text/html
Content-Length: 157
Connection: close
X-Frame-Options: SAMEORIGIN
X-Request-Id: 0922102v87dp73tjob9g

<html>
<head><title>400 Bad Request</title></head>
<body>
<center><h1>400 Bad Request</h1></center>
<hr><center>nginx/1.18.0</center>
</body>
</html>
```
We sent `GET / HTTP/1.1`:
- `GET` is a *method* that means "I want some resource"
- `/` is the name of the page. We're asking for the top level page
- `HTTP/1.1` is the version of the protocol we use
- Then a blank line.

We get:
- `HTTP/1.1 400 Bad Request`
    - Server is using the same protocol as us
    - Status code `400`
    - Status code meaning is `Bad Request`
- Headers which are `key: value` pairs
    - `Content-Type: text/html` tells us what kind of data is in the body
    - `Content-Length: 157` tells us how long the data is 
    - etc..
- Blank line, separatng headers from body
- Body, which in this case is HTML telling us bad request

When communicating with a web server, `HTTP/1.1` has one compulsory *request* header, which is `Host`. Now, `echo -e "GET / HTTP/1.1\nHost: student.eait.uq.edu.au\n\n" | nc student.eait.uq.edu.au 80` gives response
```
HTTP/1.1 301 Moved Permanently
. . .
Location: https://student.eait.uq.edu.au/
. . .
```
which tells us that we should use `https` instead of `http` (need encrypted channel).

HTTP standard requires `\r\n` as blank lines, not just `\n`. Some servers can handle `\n` only, but use `\r\n` just in case.

### Requests
General format is
```
METHOD /some/path HTTP/1.1\r\n
Header: value\r\n
...
\r\n
```
Some common methods are
- GET: asks for document specified by path
- HEAD: asks only for headers in server response, not data
- POST: give data to server, like a form
- PUT, DELETE, OPTIONS, TRACE, CONNECT

Some common headers are
- Content-Length: size of body, mandatory if body exists
- Host: virtual host to retrieve data from
- User-Agent: name and version of client, like browser
- Cookie
- Accept-Language: language that client will accept
- Connection: whether or not connection remains open after current transfer

### Responses
General format is
```
HTTP/1.1 STATUSCODE Explanation\r\n
Header: value\r\n
...
\r\n
Body (optional)
```
Some common status codes are:
- 1xx: info
- 2xx: success
    - 200: ok, data returned
    - 204: ok, but no data to return
- 3xx: redirection
    - 301: URL permanently moved
- 4xx: you (client) messed up
    - 401: no authorisation provided and is needed
    - 403: authorisation failed
    - 404: not found, address doesn't exist
    - 418: i'm a teapot
- 5xx: we (server) messed up

## IPv4 Addresses
IPv4 addresses are 32 bits, divided into a *network part* starting with the most significant bit, and the *host part*. Increasing the number of bits in the network part leaves less bits for host addresses, making the network smaller.

A network can be divided into subnetworks (subnets). A host can directly communicate with everything on the same subnet, and broadcasts will reach all hosts in a subnet. We use 'subnet' and 'network' interchangeably from now on.

Each subnet has 2 reserved addresses.
1. The *network address* has all host bits set to 0.
2. The *broadcast address* has all host bits set to 1.

To communicate, a host needs to know both its IP address and which subnet it belongs to. We can specify this in 2 ways.

### CIDR
CIDR (classless inter-domain routing) notation involves specifying the network part, then setting the host bits to 0 and indicating the number of network bits. For example,
- `130.102.0.0 / 16` says that there are 16 network bits.
- `130.102.12.0 / 24` gives subnet of all addresses starting with the first 24 bits.
- `130.102.12.0 / 23` specifies `130.102.0000110?.????????`. Only 23 bits are for network, so the subnet is (kind of) double the size.

Taking the 2 reserved addresses into account, `A.B.C.D / x` has $32 - x$ host bits and $2^{32 - x} - 2$ *usable* host addresses.

### Netmask
A netmask is a bit pattern that will map, under bitwise AND, any IP address to the corresponding *network* address. Netmasks must have all ones to the left and all zeros to the right. For example, `... / 24` is equivalent to the netmask `255.255.255.0`. `... / 20` is equivalent to `255.255.240.0`. Just use common sense to calculate from CIDR.

### Common Exercises
To check whether an IP address is part of a subnet, `&` it with the netmask and check that the network address from `&` and that of the subnet are equal.

To find the largest subnet that includes and excludes certain addresses, write out their binary representations and draw the line separating network and host at the bit where the addresses differ.

### Special Networks
From RFC 6890, addresses from the following networks shouldn't be used on public internet:
- `10.0.0.0/8`
- `172.16.0.0/12`
- `192.168.0.0/16`
    - see this in home wifi
- `169.254.0.0/16`
    - auto config when you can't get a real address
    - first and last 256 addresses within this subnet are reserved for future use
- `127.0.0.0/8`
    - these are loopback addresses
    - this includes localhost, `127.0.0.1`

## Routing
When sending a message, network needs to make a decision on whether to send directly to the destination or send to an intermediate machine. The first will only work if the destination is directly reachable at layer 2.

ARP (address resolution protocol) is a mechanism for turning IP addresses into MAC addresses. This isn't examinable, but try running `arp` on moss.

Here are the names of common network devices.
- Hubs: physical layer
    - all entering frames sent to all other ports
- Bridges: data-link layer
    - Connects 2 networks, learns addresses on both sides and forwards/filters all messages
- Switches: data-link layer
    - Multiport bridge
    - Frames only transmitted to devices that frame intends
- Routers: network layer
    - Connects networks together
    - Routes datagrams based on IP address

## Network Address Translation (NAT)
Since there aren't enough public IP addresses, we create private networks behind routers using the special network addresses described earlier. However, there needs to be a way that hosts within the private network connect to hosts on the public internet. If the router naively sends the request with the private address intact, the packet *may* arrive at the destination, but the destination can't reply (as sender is unreachable).

This is solved using network address translation (NAT). Suppose private host with IP X and port `sp` wants to send data to host IP Y port 80.
1. Router recieves packet from X and modifies source IP to be public IP and source port to be specifically chosen `np`
2. Y receives packet from router and replies to the public IP and `np` from router
3. Router receives packet from Y and sends the response back to X:`sp` based off the received `np`

This process shows that the router needs to maintain some sort of mapping between the port numbers it gives to the public internet and the private IP+ports within its network. This is processor- and memory-intensive as all pairs must be stored and checksums must be recalculated for every packet.
Also, how do external clients connect without a prior outbound packet? (ans: port forwarding)

## Internet Control Message Protocol (ICMP)
This is often used for more diagnostic requests. ICMP is based on IP and works on network layer. Errors are returned to source IP address.
Most common usage is `ping`:
1. Send message to device with ICMP echo request
2. It (hopefully) sends copy back, with ICMP echo response
3. Calculate travel time

In the IP datagram header, there is a time to live (TTL) field which gets decremented every time the packet passes through a router. The packet is *dropped* if TTL reaches 0, and a ICMP "Time Exceeded" message is sent back. Can use `traceroute www.google.com` to trace where packets go -- it sends out many packets with varying TTL, as there's no guarantee a packet will go the same path to destination.

## DNS
We would prefer to refer to addresses by names instead of the numbers. Originally, computers used to have a text file with every computer on the internet and their addresses, which would be updated when the internet changes. This is still used to an extent, found in `/etc/hosts` or `C:\Windows\System32\drivers\net\etc\hosts`.
Now, the internet uses a distributed phonebook called domain name service (DNS).
Each domain has at least 2 nameservers which know the name-to-address mapping for that domain, and only a much smaller collection of *root* nameservers need to be known by every computer that contain info for top level domains (TLDs).

For example, if we wanted to contact `source.eait.uq.edu.au`, computer knows a root nameserver for `.au`. `.au` knows `edu.au`, which knows `uq.edu.au` etc.

These queries are messages sent via UDP. Servers could operate in an iterative way, passing the location of the next nameserver back to the client at each step, but usually they are recursive, calling the next nameserver until finally the destination is found and returned.
`nslookup` and `dig` are useful utilities for queries.

DNS responses also have TTL, and nameservers can cache answers to reduce the load. DNS servers can also be used to balance loads by deliberately redirecting to another location -- content distribution networks (CDNs) do this by giving destinations close to the query source. Note that DNS domains are independent of networks, as nothing requires a domain to have a specific IP address.