## Some notes:
the Imperial Task 0 was from official repo, the rest may be different from the original Stanford version
## project structure:
- src/device:

$\qquad$ contains code to deal with supporting devices

$\qquad$ timer.c in Task 0

- src/threads:

$\qquad$ task 1,2,3

$\qquad$ all thread related stuff

- src/userprog:

$\qquad$ task 2,3

$\qquad$ user programs, process loading and system calls

$\qquad$ Pintos' page table implementation and exception handler

- src/vm:

$\qquad$ task 3

$\qquad$ virtually empty, create virtual memory here

- src/filesys:

$\qquad$ filesystem implmentation

$\qquad$ do not modify

- src/lib:

$\qquad$ libs
## set up:
- clone: git clone https://gitlab.doc.ic.ac.uk/lab2425_autumn/pintos_task0_hg1523.git
- compile pintos utilities: make in <repo>/src/utils
- configure PATH
  - current PATH session: PATH=$PATH:<repo>/src/utils
  - global(maybe): export PATH=$PATH:<repo>/src/utils in .bashrc or .profile
  - global(wsl): configure PATH in settings
- run all pintos tests: make check or make grade in <repo>/src/devices
- run single pintos test: make build/tests/devices/<test>.result
- check output: vim build/tests/devices/alarm-single.output
- backtrace: backtrace < stack calls >
## synchronization:
- pintos is mukti-threaded
- incomplete threads may affect the safety of the whole system
- concurrent threads are often non-deterministic
### basic terminology:
- thread: An excution context: all the information of the CPU to be able to execute a stream of instructions, should include all the registers and the program counter, etc.
- atomicity: A unitary action that is asssentially indivisible, irreducible and takes effect in one step(for example, x++ would first read the value of x, increment and reassign, it is not atomic)
- race condition: two threads accessing the data at the same time
- Deadlock: two thread sharing the same resource prevent each other to access the resources
## interrupt:
To disrupt the normal flow of the execution to nontify the CPU something

- internal interrupt(errors): this originate from the CPU and can not be ignored
- external interrupt: orginate outside the SPU can be postponed

Interrupt Handler: A kernel routine that processes a particular interrupt signal with exclusive access to the CPU
### diabling interrupts:
- prevents the CPU from responding to external interrupts, at this time all the operations are effectively atomic
- synchronize data between the kernel threads and the handler
```C
enum inter_level old_level; /* INTR_ON or INTER_OFF */
/* critical section */
// set the level back
intr_set_back(old_level);
```

this is not a general purpose concurrency solution, should only be used if no other sync approch will work

## semaphores:
```C
 struct semaphore {
 unsigned value;  /* A non-negative value.*/
 struct list waiters; /* A List of waiting threads. */
 };
```

The value is modified by two atomic operations:
- sema_down(struct semaphore *)- aka P or wait():waits until value becomes positive, then decrements it, can be find in src/thread/synch.c: 61
- sema_up (struct semaphore *)- aka V or signal():increments value and wakes up one waiting thread, can be find in src/thread/synch.c: 109

can possibly be used for task 0
### usage:
```C
 unsigned x = 0;
 struct semaphore example;
 sema_init(&example, x);

```
```C
Thread A:
 f();
  sema_up (&example);
 /* signal() */
Thread B:
 /* wait() */
 sema_down (& example);
 g();
```

this means that B has to excute after A

if you change the init of x to be 1, then that is mutual exclusion

```C
 unsigned x = 1;
 struct semaphore example;
 sema_init(&example, x);
```
```C
Thread A:
 sema_down(&example);
 x = x + 1;
 sema_up(&example);
Thread B:
 sema_down(& example);
 x = x + 1;
 sema_up(&example);
```

## Locks:
can be considered as a special type of semaphores

```C
struct lock {
 struct thread *holder;
 /* Thread holding lock */
 struct semaphore semaphore; /* A binary semaphore */
};
```

the semaphore value is set to one, that mutual exclusion

In pintos, the locks are not recursive, so if lock acquired, it is wrong to acquire the lock before releasing it

So we have this:

```C
 /* Before we had: sema_init(&example, 1)*/
 struct lock example;
 lock_init(&example);
```

```C
Thread A:
 lock_acquire(&example);
 x = x + 1;
 lock_release(&example);
Thread B:
 lock_acquire(& example);
 x = x + 1;
 lock_release(&example);
```

the lock does not lock the varible x or the thread, it is a contract
## Monitor:
- shared data variables, accessed only by its internal precedures
- monitor lock, ensuring that only on thread is in the monitor
- conditional variables, allow the thread to wait for a condition in the monitor

```C
 int count = 0;
 /* Shared global variable */
 struct condition C; /* Condition variable */
 cond_init(&C);
 struct lock L;
 lock_init(&L);
 /* Monitor lock */
```
```C
Thread A:
 lock_acquire(&L);
 while(count != 10)
   cond_wait(&C, &L);
 lock_release(&L);
Thread B:
 lock_acquire(&L);
 count++;
 if (count == 10)
 cond_signal(&C, &L);
 lock_release(&L);
```

waiting on a condition:

```C
struct condition { struct list waiters; };

struct semaphore_elem {
 struct list_elem elem;
 struct semaphore semaphore;
};

void cond_wait(struct condition *cond, struct lock *lock) {
 struct semaphore_elem waiter;
 sema_init(&waiter.semaphore, 0); // for sychronization
 list_push_back(&cond->waiters, &waiter.elem);
 // push the elem to the waiters list
 lock_release(lock); // release the lock
 sema_down(&waiter.semaphore);// wait
 lock_acquire(lock);
}
```

# Task 0
##  Part A- Codebase Preview
### Part 1
Which Git command should youma run to retrieve a copy of your individual repository for PintOS Task 0 in your local directory?
(Hint: be specific to this task and think about ease of use.)

- cd somewhere
- git clone https://gitlab.doc.ic.ac.uk/lab2425_autumn/pintos_task0_hg1523.git

### Part 2
Why is using the strcpy() function to copy strings usually a bad idea?
(Hint: be sure to clearly identify the problem.)

- there is not length parameter in strcpy, so for example, if I am try to copy 7 chars from "Hello", it may copy "Hello" and two addition mysterious chars

###  Part 3: 
If test src/tests/devices/alarm-multiple fails, where would you find its output and result logs?
Provide both paths and filenames.
(Hint: you might want to run this test and find out.)

- the output: build/tests/devices/alarm-single.output
- the result log: build/tests/devices/alarm-single.result

### Part 4:
In PintOS, a thread is characterized by a struct and an execution stack.

(
the thread struct looks like this:

```C
struct thread
  {
    /* Owned by thread.c. */
    tid_t tid;                          /* Thread identifier. */
    enum thread_status status;          /* Thread state. */
    char name[16];                      /* Name (for debugging purposes). */
    uint8_t *stack;                     /* Saved stack pointer. */
    int priority;                       /* Priority. */
    struct list_elem allelem;           /* List element for all threads list. */

    /* Shared between thread.c and synch.c. */
    struct list_elem elem;              /* List element. */

#ifdef USERPROG
    /* Owned by userprog/process.c. */
    uint32_t *pagedir;                  /* Page directory. */
#endif

    /* Owned by thread.c. */
    unsigned magic;                     /* Detects stack overflow. */
  };
```
)

#### (a) What are the limitations on the size of these data structures?
so we have the struct as shown above and a execution stack, there are some potential problems related to it
1. the stack it self consists of pointers, as a result, we have no information about what is inside the stack, for example, whether it is a char or a long
2. the thread dont not prevent other thread from altering what should be private, but I am currently not so sure how to fix this
3. if memory size is a concern, we may cut the name field as tid should be sufficient to identify the threads
#### (b) Explain how this relates to stack overflow and how PintOS identifies if a stack overflow has occurred.


##  Part B- The Alarm Clock
### testing:
- all test: ```make check```
- single test: ```make build/tests/device/${testname}.result```

### coding - the experience
#### 02/10/2024

check the timer function

```C
/* Sleeps for approximately TICKS timer ticks.  Interrupts must
   be turned on. */
void
timer_sleep (int64_t ticks) 
{
  int64_t start = timer_ticks (); // to get the time tick at the start
  printf(">>>> Now sleping thread %s for %"PRIu64" ticks value", thread_current()->name, ticks);
  ASSERT (intr_get_level () == INTR_ON);
  // make sure the thread is not blocked, INTR_ON is one of the enum
  while (timer_elapsed (start) < ticks) 
  // while threads should sleep, yield
    thread_yield ();
}

```


then check thread_yield

```C
void
thread_yield (void) 
{
  struct thread *cur = thread_current ();
  // get current thread
  enum intr_level old_level;
  // define the level
  ASSERT (!intr_context ());
  // make sure we are interrupting

  old_level = intr_disable ();
  // get the interruption disabled flag and stop the cpu thread
  if (cur != idle_thread) 
  // the idle_thread is a static struct thread
    list_push_back (&ready_list, &cur->elem);
    // if not idle then it should be in the ready list
  cur->status = THREAD_READY;
  // change the status back to ready
  schedule ();
  // schedule the thread
  intr_set_level (old_level);
  // interrupt with level
}
```

so the idea is to block all threads at the beginning of timer_sleep and then wait enough time, then unblock all

```C
/* Sleeps for approximately TICKS timer ticks.  Interrupts must
   be turned on. */
void
timer_sleep (int64_t ticks) 
{
  int64_t start = timer_ticks (); // to get the time tick at the start
  printf(">>>> Now sleping thread %s for %"PRIu64" ticks value", thread_current()->name, ticks);
  ASSERT (intr_get_level () == INTR_ON);
  // make sure the thread is not blocked, INTR_ON is one of the enum
  // while (timer_elapsed (start) < ticks) 
  // // while threads should sleep, yield
  //   thread_yield ();
  // attempt 1: 
  //   since the original solution is to wait enough time
  //   then we simply stop the current thread at the beginning
  //   wait enough time and then unblock
  thread_block ();
  while (timer_elapsed (start) < ticks) {
    // it is expected to do exactly nothing
    continue;
  }
  thread_unblock ();
}
```

thread_unblock needs a argument

this makes all the tests failed

Kernel panic in run: PANIC at ../../threads/thread.c:236 in thread_block(): assertion `intr_get_level () == INTR_OFF' failed.

so in line 236, intr_get_level give INTR_ON in thread_block()

after changing

then it seems like a dead cycle

giving this idea up, although plausible



new Idea: change the thread struct

```C
struct thread
  {
    /* Owned by thread.c. */
    tid_t tid;                          /* Thread identifier. */
    enum thread_status status;          /* Thread state. */
    char name[16];                      /* Name (for debugging purposes). */
    uint8_t *stack;                     /* Saved stack pointer. */
    int priority;                       /* Priority. */
    struct list_elem allelem;           /* List element for all threads list. */

    /* Shared between thread.c and synch.c. */
    struct list_elem elem;              /* List element. */

#ifdef USERPROG
    /* Owned by userprog/process.c. */
    uint32_t *pagedir;                  /* Page directory. */
#endif

// mycode starts
   // remaining_sleeping_time indicates the remaining time
   // this sleeping thread can sleep
   int remaining_sleeping_time;
// mycode ends

    /* Owned by thread.c. */
    unsigned magic;                     /* Detects stack overflow. */
  };

```

### analyze the program first
the pintos main program is in src\threads\init.c

