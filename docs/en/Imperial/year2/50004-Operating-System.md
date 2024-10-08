# pre-recorded lecture 1 intro
## Computer Architectur Overview
![slide2](../../../assets/Imperial/50004/lecture1-slide2.png)

so the primary purpose of the operating system is to provide abstractions of clean interface to the applications

it should also control all the hardwar that connects to the computer

So OS need to 
## Manage Resources
OS must make efficient use of the limit avalible resource
- this includes time, space, money, etc..

OS have to share the resource among multiple users
- schedules access and offers a fair allocation
- prevent interference between users

The managed resources include
- Processors(mainly CPU stuff)
- Memory(caches, RAM, etc.)
- I/O devices
- Internal devices(clocks timer, interrupt controllers)
- Persistent storages(disks, SSDs, DVDs, tapes, etc..)

## Provide clean Interfaces

OS hides complexity of lower levels from higher levels and provide a clean interface

example:

![slide7](../../../assets/Imperial/50004/lecture1-slide7.png)


## Sharing
OS must share data, programs and hardware
- OS use time multiplexing and space multiplexing for this(more later)

OS must offer resource allocation
- fair use of memory, CPU time, disk space
- simultaneous access to resuorce(Disks, RAM, network, GPU)
- mutual exclusion for some resources(guarantee that risky operations are protected)
- OS must protect against(accidental or malicious) corruption

## Concurrency
OS must support several simultaneous parallel activities
- multi users and programs must run in parallel

OS may switch activities at arbitrary times
- guarantee fairness and prompt replies

OS must ensure safe concurrency
- must offer primitives to sychronise actions
- protect user/process interference(Each program wants to have its own space)

## Non-determiniism
Because it is concurrent, results from events occur in an unpredictable order

## Storing Data
Persistent storage
- easy access to files
- access controls: protect the files so only authorised people can alter the file
- protest against failures
- manage storage devices

## OS functionality
- SImplified I/O (access disk, or remote file server or DVDs)
- Virtual memory(larger than physical memeory and partition)
- File systems(persistent storages)
- Program interaction and communication
- Network communication(sending/receiving data on network)
- Security(preventing program accessing unauthorised resuorce)
- UI
- other(Administration, managment, accounting)

## OS need to support different hardware