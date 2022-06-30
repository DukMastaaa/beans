# Lecture 9

## Network Definitions
Sometimes, software is developed in layers making each part of a whole system more manageable, allowing lower levels to be replaced without disrupting the whole program, and many other benefits. A connected set of layers is called a stack. For example, C stdio with `FILE*` streams acting as an unstructed sequence of bytes is a layer on top of OS/device. 

In communications, a *protocol* is a set of rules governing an exchange of data between two entities (how to send out and interpret what you receive). An *entity* is an active element in each layer, which can be software (library code/process) or hardware (IC). *Peer entities* are entities on the same layer but on different machines.

A *service* (or *interface*) has operations available *between* layers. A *protocol* operates on peer entities *within* the same layer. Protocols are often standardised but interfaces don't have to be. Services can be
- connection-oriented
    - like a telephone system
    - the user estabilishes connection, uses then releases
- connectionless
    - like the postal service
    - the user specifies full destination address for each message sent
- reliable
    - service provider makes "best effort" attempt to communicate, like retransmitting
- unreliable

<img src="images/layers.png" style="zoom: 50%;" />

Note that no data is actually passed between peer entities -- everything goes through some physical medium eventually, but by abstracting with layers we can ignore that.

To work with lower layers, a message may need to be encoded (like light pulses over fibre optic), or have extra information added containing to/from. This extra information usually is removed at the other end, and may be the only part of the message that level understands. We use an envelope as an analogy, where each layer unwraps the envelope, reads some data, then sends the contents to the next destination. In reality, these are streams of bytes with *headers*/*footers* on them.

<img src="images/envelopes.png" style="zoom: 50%;" />

## TCP/IP Stack
An *internet* is an interconnected set of networks. The global *Internet* is an example of an internet (note capitalisation). On the Internet, the TCP/IP protocol family is used, with
- IP (Internet Protocol)
    - basic addressing scheme, unreliable delivery of packets, host to host
- UDP (User Datagram Protocol)
    - uses IP for process to process
- TCP (Transmission Control Protocol)
    - uses IP for reliable byte streams from process to process

We now describe TCP/IP stack.

### Layer 1: Physical
This is medium which signals travel through, like wire, fibre/optic, air etc.

### Layer 2: (Data-)Link
This transfers data between 2 nodes on a network segment (link) across the physical layer. Peers can transmit directly via messages, needing addressing information. Timing information may be important to resolve collisions. 
Examples include Ethernet frames and WiFi. Addresses include MAC (medium access control) addresses -- Ethernet MAC addresses are 48 bits.

### Layer 3: Network
Messages are exchanged with any other host on the *i*nternet. This uses IP, where messages are IP datagrams. IPv4 addresses are 32 bits, usually written as 4 decimal numbers each between 0 and 255 incl. IPv8 are 128 bits.

Datagrams are sent via link layer. Messages may travel through multiple devices before they reach destination. Network layer needs to know "what direction" to pass message on -- beyond scope of this course, but see "routing protocols".

### Layer 4: Transport
Messages are exchanged with a process on the host on the internet. Either UDP or TCP is used, and messages are sent via the network layer.
Transport addresses are ports, 16-bit integers. These stay constant unlike process IDs which aren't guaranteed to be the same across executions.
- 80 for web servers
- 22 for SSH
- 443 for SSL
- ports below 1024 are restricted on unix systems -- need `sudo`
- port 0 
- high-numbered ports are *ephemeral* (short-lived) and often used by clients in a client-server connection (since nothing else will try to contact the client). 

see `/etc/services` for port numbers and associated service names.

### Layer 5: Application
Everything else, like web servers and clients communicating via HTTP, ssh servers and clients, games etc. Messages are sent via the transport layer, with addresses like URL, URI.

### Addresses
- Application-specific: differentiate between resources (like URL)
- Port: differentiate between processes on one computer
- IP: which computer is the process on?
- MAC: which device is this message to?

Both IP and MAC are used due to historical reasons. IP addresses are hierarchical, and ethernet MAC is "unique" but not hierarchical. MAC is used in broadcast networks (like wifi) instead of point-to-point networks, to differentiate between devices *within* the network. IP is used to identify a network as a whole. Both addresses identify interfaces, not the devices.

### IP in detail
<img src="images/ipheader.png" style="zoom: 50%;" />

- connectionless
- unreliable
- datagrams/packets contain
    - header
        - 20 byte fixed part
            - protocol
                - 8-bit number
                - TCP = 6, UDP = 17
                - needed so we know what entity to send packet on to
                - see `/etc/protocols`
            - address
                - 32 bits, two addresses
                - destination
                    - used to send packet
                - source
                    - dest. can choose whether to receive and who to reply to
        - 0-40 byte optional part
    - body -- just treated as data

Dotted decimal notation, where each 4 bytes written in decimal separated by `.`. Some addresses have special meanings, covered in Lec11.md.

Addresses could come from internal configuration (hard-wire) or from externally -- see DHCP where the device asks what address should be used.

### UDP in detail
- messages have maximum size
- no guarantee of delivery or acknowledgement
- used for streaming, games, congested networks, or when doing many small operations
- header 8 bytes, 2 bytes each for
    - source port
    - destination port
    - datagram length (incl. header)
    - checksum
- UDP datagrams must fit in IP, so max UDP size limited by max IP size
    - max UDP payload = max IP - 20 (ip header) - 8 (udp header)
    - this can be system-dependent, but usually max IP = 64k bytes

### TCP in detail
- connection-oriented
- making connection requires message to travel there and back
- closing connection is polite (timeout as fallback)
- connections are bi-directional
- point-to-point, not multicast/broadcast
- each machine has TCP transport entity, either user process or part of kernel
- sender
    - accepts byte streams from local processes (no message boundaries)
    - breaks data into pieces < max IP (in reality, lower)
    - sends each piece as IP datagram
    - time-out and retransmit if no acknowledgement
- receiver
    - (TCP entity) receives IP datagrams with TCP data
    - sends acknowledgement receipt
    - reassembles data in proper sequence
- header
    - 20 bytes
    - 16bit source and destination port numbers
    - sequence number and acknowledgements
- segments with no data are valid
- connection identified by
    - source IP
    - source port
    - destination IP
    - destination port

## Client-Server Model
Most network applications are based on client-server model, with one server and many clients. Server manages some resource and provides a service by manipulating that resource for clients.

<img src="images/client-server.png" style="zoom: 50%;" />

The *server* is a process that waits for requests from clients. A *client*  is a process that submits requests to a server. Note that they are processes, not machines (sometimes people use the words to refer to the machine that the process is running on), and a process can be both a server and a client for different connections. The distinction applies to single connections.
Once a connection has been estabilished, there is no difference between what clients and servers can do.

