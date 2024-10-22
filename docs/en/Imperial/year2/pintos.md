---
level: pintos
---

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
 sema_down(&waiter.semaphore);// wait, the threa is blocked at this time
 lock_acquire(lock);// get the lock back again
}
```

## debugging
### printf:
basic feature, just print out whatevr you want to check

- note that this cannot be used in schedule(), this is because printf causes the current thread to be blocked while the thread should not be
- and some of the tests that would match the output will fail

### ASSERT:
remember to use 
```C
#include <debug.h>
```

before you use this

basically the same, you assert something is true and edit the conditions

but notice that ASSERT mallocs, so if the mallocing fails, the program PANICs

### backtraces:
pintos offer the backrace command,

if a garbled backtrace occurs, then it means the thread stack is corrupted

### gdb:
just gdb

notice that pintos runs qemu, a virtual machine

so if you enter the program with gdb, you would see qemu code

first do ```pintos --gdb -- -q run alarm-single```

then open up a new terminal in src/devices/build

and run ```pintos-gdb kernel.o```

then run ```debug pintos``` in gdb

and then the rest is the same as gdb
# Task 0
##  Part A- Codebase Preview
### Part 1 Which Git command should you run to retrieve a copy of your individual repository for PintOS Task 0 in your local directory? (Hint: be specific to this task and think about ease of use.)

- cd somewhere
- git clone https://gitlab.doc.ic.ac.uk/lab2425_autumn/pintos_task0_hg1523.git

### Part 2 Why is using the strcpy() function to copy strings usually a bad idea?
(Hint: be sure to clearly identify the problem.)

- there is not length parameter in strcpy, so for example, if I am try to copy 7 chars from "Hello", it may copy "Hello" and two addition mysterious chars

###  Part 3: If test src/tests/devices/alarm-multiple fails, where would you find its output and result logs?
Provide both paths and filenames.
(Hint: you might want to run this test and find out.)

- the output: build/tests/devices/alarm-single.output
- the result log: build/tests/devices/alarm-single.result

### Part 4: In PintOS, a thread is characterized by a struct and an execution stack.

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

pintos create a magic component in the thread to detect overflow. Normally the magic number is set to a random value and if something overflows. It exceeds it original size and start affecting the magic value. So to check overflow, we simply assert if the magic value remains the same. If not, overflow, otherwise maybe yes or does not matter.

### Part 5: Explain how thread scheduling in PintOS currently works in roughly 300 words. Include the chain of execution of function calls.(Hint: we expect you to at least mention which functions participate in a context switch, how they interact, how and when the thread state is modified and the role of interrupts.)

(This need fix)
  The scheduler it self first get the current thread and the next thread from the ready_list using running_thread() and next_thread_to_run(), if we need a switch or the next thread to run is different, we call switch_threads() to switch the thread. 

  The switch_threads() function would first store the state of the caller to %ebx, %ebp, %esi, %edi with pushl. Then we move the current stack pointer to the old thread's stack. This is the moment where the state of the old thread is modified. After this, we do a similar operation to the current state to restore the stack pointer. The final returned value is the caller's state in the altered context. 

  After this, we set the current thread runningm and if the previous thread is dying, null or is the initial thread, we destroy the previous thread.

  These functions should execution is interruption is not enabled. As if we are interrupting, we set the inte_level, block the whatever is running in the CPU until the interruption flag sti is set again in intr_enable. Interruption makes sure that if something went wrong, we would not continue executing running threads in a wrong context.

### Part 6: In PintOS, what is the default length (in ticks and in seconds) of a scheduler time slice? (Hint: read the Task 0 documentation carefully.)

the default length of a scheduler time slice is 4 ticks

line 54 src\threads\thread.c

```C
/* Scheduling. */
#define TIME_SLICE 4/* # of timer ticks to give each thread. */
```
or 100Hz, 0.01s

line 7 src\devices\timer.h

```C
/* Number of timer interrupts per second. */
#define TIMER_FREQ 100
```

###  Part 7: In PintOS, how would you print an unsigned 64 bit int? (Consider that you are working with C99).Don’t forget to state any inclusions needed by your code

As shown in lectures, use the PRIu64

```C
  printf(">>>> Now sleping thread %s for %"PRIu64" ticks value", thread_current()->name, ticks);

```

### Part 8: Explain the property of reproducibility and how the lack of reproducibility will affect debugging

the property of reproducibility illustrate that no matter what time you execute the program, if the parameter are the same, the output should be correspondingly consistent

If the program lacks reproducibility, you might find trouble determining what value it should be in the process and thus unable to identify potential errors

### Part 9:  In PintOS, locks are implemented on top of semaphores.
#### (a) How do the functions in the API of locks relate to those of semaphores?

the locks utilizes semaphormes

```C
struct lock 
  {
    struct thread *holder;      /* Thread holding lock (for debugging). */
    struct semaphore semaphore; /* Binary semaphore controlling access. */
  };
```

so for example, the lock_release utilizes the sema_up function

```C
void
lock_release (struct lock *lock) 
{
  ASSERT (lock != NULL);
  ASSERT (lock_held_by_current_thread (lock));

  lock->holder = NULL;
  sema_up (&lock->semaphore);
}
```

it just do some assertions, set the holder to null and sema_up
#### (b) What extra property do locks have that semaphores do not?

the holder, the pointer to the thread that is controlling this lock

###  Part 10: Define what is meant by a race-condition. Why is the test if(x \!= null) insufficient to prevent a segmentation fault from occurring on an attempted access to a structure through pointer x? (Hint: you should assume that the pointer variable is correctly typed, that the structure was successfully initialised earlier in the program and that there are other threads running in parallel.)

The race-condition is when two threads in parallel tries to alter the same resource at the same time. The uncertainty in the order the thread access the resource may cause chaos

Therefore, even if x != null, there is a possibility that everything is initialized properly, but say x is 1 at first, and should be x = 1 when thread A executes, but then a fast thread B alters x to 2 before A could even react.

##  Part B- The Alarm Clock
### testing:
- all test: ```make check```
- single test: ```make build/tests/device/${testname}.result```

### coding - the experience

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

because we need to wait for a certain number of ticks, so we try to find the place where ticks is calculated

in thread.c, there is this thread_tick function

one possible solution is to add a remaining_sleeping_time in the thread struct, which is decremented by 1 every time

then if it is zero, we unblock it, or use a semaphore, condition, whatever

so we add a new int64_t variable to the struct thread

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
    uint32_t sleep_ticks;               /* sleep for some ticks, 0 at default */
// mycode ends

    /* Owned by thread.c. */
    unsigned magic;                     /* Detects stack overflow. */
  };
```

so we simply have to check sleep_ticks

then we decrement sleep_ticks and unblock when it turns to 0

ticks is controlled by timer_interrupt or thread_tick

so we have to check everytime timer_interrupt or thread_tick is called

At first I wanted to maintain a list

by then I found this thread_foreach that does the iteration for me

so I simply call

```C
// mycode starts
/* Check every threads whether they should be awaked. */
void check_sleep_time(struct thread *t, void *aux UNUSED) {
  // the aux parameter is unused, it is just for the thread_foreach function

  // if the thread is being blocked or time to wake up, unblock it
  if (t -> status == THREAD_BLOCKED && t -> sleep_ticks> 0) {

    // obviously we have to decrement the time here or else it blocks forever
    t -> sleep_ticks --; 
    if (t -> sleep_ticks == 0){ 
      // I know the curved brackets are not needed, but throwing it away usually cause confusion

      // if block time up, unblock
      thread_unblock(t);
    }
  }
}
// mycode ends

```

and 

```C
void
thread_tick (void) 
{
  struct thread *t = thread_current ();

  /* Update statistics. */
  if (t == idle_thread)
    idle_ticks++;
#ifdef USERPROG
  else if (t->pagedir != NULL)
    user_ticks++;
#endif
  else
    kernel_ticks++;

  /* Enforce preemption. */
  if (++thread_ticks >= TIME_SLICE)
    intr_yield_on_return ();
// mycode starts
  thread_foreach(check_sleep_time,NULL);
// mycode ends
}
```

but then the test timeouts, I am not certain why

but putting the code in timer_interrupt fixed the issue, perhaps I have added something mysterious add later deleted it

and of course, forgetting to remove 

```C
printf("sleeping thread %s", thread_current() -> name);
```

which is an example in lectures, failed some test that relied on output

then the alarm_zero and alarm_negative timeouts

since we do not check the ticks, if it is negative, it decrements to $-\infty$

so add

```C
if (ticks <= 0){
  // when timer_sleep is passed in a negative or 0 ticks
  // sleep for 0 ticks is doing nothing
  // while negative ticks are invalid
  return;
}
```

at this time, the only error is in no_busy_wait, 

```
Kernel PANIC at ../../devices/timer.c:99 in timer_sleep(): assertion `intr_get_level () == INTR_ON' failed.
```

intr_get_level does some assembly thing

```C
enum intr_level
intr_get_level (void) 
{
  uint32_t flags;

  /* Push the flags register on the processor stack, then pop the
     value off the stack into `flags'.  See [IA32-v2b] "PUSHF"
     and "POP" and [IA32-v3a] 5.8.1 "Masking Maskable Hardware
     Interrupts". */
  asm volatile ("pushfl; popl %0" : "=g" (flags));

  return flags & FLAG_IF ? INTR_ON : INTR_OFF;
}
```

asm volatile store something to the flags variable, not knowing which

the test_alarm_no_busy_wait calls an extra time_sleep before the thread to yield the CPU, I guess this is where the error occurs, so go gdb

no, the error is in line 108, the second timer_sleep

I have no idea currently, I am temporarily commenting it out in timer_sleep

**As suggested on Edstem, block and unblock should be protected and not directly used**

simple change, we add a sema in the threads

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
    uint32_t sleep_ticks;               /* sleep for some ticks, 0 at default */
    struct semaphore * sleep_sema;      /* semaphore for sleeping */
// mycode ends

    /* Owned by thread.c. */
    unsigned magic;                     /* Detects stack overflow. */
  };
```

we initialize the sema and call sema_down every_time we try to make the thread sleep

```C
void
timer_sleep (int64_t ticks) 
{
  // int64_t start = timer_ticks ();
  if (ticks <= 0){
    // when timer_sleep is passed in a negative or 0 ticks
    // sleep for 0 ticks is doing nothing
    // while negative ticks are invalid
    return;
  }
  ASSERT (intr_get_level () == INTR_ON);
  enum intr_level old_level = intr_disable();
  // printf("sleeping thread %s", thread_current() -> name);
  // this printf fails the test
// mycode start
  struct thread * cur = thread_current();
  cur -> sleep_ticks = ticks;
  struct semaphore sema;
  cur -> sleep_sema = &sema;
  sema_init (&sema, 0);
  intr_set_level(old_level);
  sema_down(&sema);
// mycode ends
  // while (timer_elapsed (start) < ticks) 
  //   thread_yield ();
}
```

the check it every timeslice(tick?) to sema_up

```C
// mycode starts
/* Check every threads whether they should be awaked. */
void check_sleep_time(struct thread *t, void *aux UNUSED) {
  // the aux parameter is unused, it is just for the thread_foreach function

  // if the thread is being blocked or time to wake up, unblock it
  if (t -> status == THREAD_BLOCKED && t -> sleep_ticks> 0) {

    // obviously we have to decrement the time here or else it blocks forever
    t -> sleep_ticks --; 
    if (t -> sleep_ticks == 0){ 
      // I know the curved brackets are not needed, but throwing it away usually cause confusion

      // if block time up, unblock
      sema_up(t -> sleep_sema);
    }
  }
}
// mycode ends
```

the intr_level stuff still persists, comment the line out and we are all fixed, but I'll return to that when I know what to do

okay, it is the bug mentioned in edstem, changed two lines and no error, so all done
### code analysis

After the completion, let's looking into the code for a detailed analysis

basically it executes the init.c in the threads folder

it does a whole bunch of init

first, bss, read the cmd args, init the whole program as a thread,

init the memory etc.

so basically the program is a idle thread?

the idle thread is put on the ready list by thread_start() and it will be scheduled initially then never appears in the ready list

if the ready_list is empty, then next_thread_to_run() returnts the idle thread

the main stuff happens when the run_actions is called, the main function process the cli args

if run keyword is detected in run_actions() in init.c, then run_task function is called

if the user program is defined, then we do the normal setup, else we run the tests

the run_test function is in src/tests/threads/tests.h but since it is extern, it is actually in src/tests/devices/tests.h for pintos_task0_hg1523

then it assigns which task to run in the folder and executes the task



# Task 1: scheduling

make pintos more amendable for multi-threading

## position
- all work should be done under src/threads
- compilation should occur under src/threads
- new files should be added to src/Makefile.build

## Testing:
- all tests: make check
- single tests: make build/tests/threads/<test-name>.result

**some tests take much longer to run thean others**

**Autotesting may take 30 mins**

## pintos init:
Initial thread:
- Initial thread is in src/threads/inti.c is started by the pintos boot (line 93 thread_init)
- Initial thread starts the threading sub-system and “promotes” itself to a standard Pintos thread in thread_init()
- Initial thread then initialises other subsystems (e.g. malloc, timer)
- Initial thread then parses Pintos command-line arguments
- Initial thread then starts other threads, via thread_create()


test are running by in the init.c

```C
/* Runs the task specified in ARGV[1]. */
static void
run_task (char **argv)
{
  const char *task = argv[1];
  
  printf ("Executing '%s':\n", task);
#ifdef USERPROG
  process_wait (process_execute (task));
#else
  run_test (task);
#endif
  printf ("Execution of '%s' complete.\n", task);
}
```

**The initial thread is not created by thread_create()**

**You may need to add initialisation code for any elements you add to struct thread to thread_init() as well**

## requirements:
### Priority scheduling

requirements:
- Rewrite scheduler to take thread priorities into account
- Allow processes to modify and query their priority

we always want the ready thread with the highest priority should run

if:
- a new thread is created
- a thread is unblocked
- a thread is woken from timer_sleep

some thread may have higher priority, the current thread should yield to it as soon as possible

**sleeping thread should not be woken early, regardless of priority**

allow modification to the priority, implement

- void thread_sets_priority(int new) sets the thread’s priority to new
 int thread
 get
 set
 priority(int new
 priority)
 priority, if valid
 priority(void)
 returns the current thread’s (effective) priority



## Priority donation (for locks)
- Improve performance for high-priority threads

prevent priority inversion by allowing high-priority threads to donate their priority to other threads holding contended resources

priority inversion may occur when some thread of lowerer priority is using the resource, holding the lock while some other thread with higher priority is spawned

- Multiple threads may donate to a single thread
- A thread can only donate to one thread (which holds the resource)
- The donation is revoked when the resource is freed
- Donations may nest (e.g. A donates to B and B donates to C)

**block threads may have their priorities modified**

effective priority
- A thread's effective priority is always the highest of its base priority and al its Donations

proiority update
- THe priority updated by thread_sets_priority(int new_priority) should laways be the thread's base priority

priority query
- the priority returned from  thread_get_priority(void) should always be the threads's effective priority



## BSD-style scheduler
- Alternative scheduler implementation based on allocated CPU time
- Requires implementing some fixed-point maths routines

its another ides of preventing priority inversion using feedback scheduling

- Measure the CPU usage of each thread every tick
- Decay the CPU usage for all threads once per second
- Calculate the system load average once per second
- Update the priority of threads every 4th tick
- Always run the thread with highest priority

**do not do #ifdefs to disable the scheduler**

### FPU(Floating point unit)
simulate real arithmetic without access to a FPU

Correctness:
- Abstract out the actual arithmetic to make the test easier
- small differences in implementation (round down / round up, etc,) can have differences in output, read the spec carefully

Effciency:
- This code will be run many times a second, being optimal is essential
- Functions vs. macros may give different performance characteristics

see section B.6

## suggested order of the implementation
- choose the best task 0 implementation

- Initial thread_get_priority() & thread_set_priority()
- Prioritised unblocking on synchronisation primitives (semaphores,locks and conditions)

- Priority scheduling

- Priority donation(suggested hardest)
- Final thread_get_priority() & thread_set_priority

- Fixed-point maths routines
- BSD-style scheduler

## my task in group: priority scheduling
### spec doc:
- When a thread is added to the ready list that has a higher priority than the currently running thread, the current thread should immediately yield the processor to the new thread. 
-  Similarly, when threads are waiting for a lock, semaphore, or condition variable, the highest priority waiting thread should be awakened first.
- In both the priority scheduler and the advanced scheduler you will write later, the running thread should be that with the highest priority.

### solution?:
we always want the thread with the highest priority to be the first or at a fixed position, a one obvious solution is the sort the list,

sorting the list everything is painful and time-consuming, it will be better if we could init the list sorted, like insertion sort, but we need to take care of conditions that a priority changes

lets first don't care about priority change

if we want the list to be created as a sorted list, we would want to use *insert_sort* or *list_insert_ordered*

originally the ready_list or the all_list(the only two lists) is created with *list_push_back* in *thread_yield*, *init_thread*, and *thread_unblock*

so we change these

watch the params of *list_insert_ordered*

it take three params, 
```C
void
list_insert_ordered (struct list *list, struct list_elem *elem,
                     list_less_func *less, void *aux)
{
  struct list_elem *e;

  ASSERT (list != NULL);
  ASSERT (elem != NULL);
  ASSERT (less != NULL);

  for (e = list_begin (list); e != list_end (list); e = list_next (e))
    if (less (elem, e, aux))
      break;
  return list_insert (e, elem);
}
```

then see what is required for less

```C
less(elem, e, aux)
```

following *thread_foreach*, we can assume the aux is another auxillary variable, possibly not used

the *list* variable should be *&ready_list* and the *elem* should be the list_elem to insert, obviously

the less compares the priority,

we could imagine the less should first get the threads of the two elems by *list_entry* and get the priority then compare

```C
// mycode starts part1

/* 
  compares the priority from list elems
  returns ture if the priority of e1 is less than e2
  the name is for consistency with the list.c functions
  but I don't think we should alter the core lib
*/
bool list_less_priority(struct list_elem * e1,
    struct list_elem *e2, void * aux UNUSED)
{
  struct thread *threadOfE1 = list_entry(e1, struct thread, elem);
  struct thread *threadOfE2 = list_entry(e2, struct thread, elem);
  return (threadOfE1 -> priority) < (threadOfE2 -> priority);
}
// mycode ends
```

we get

```
../../lib/kernel/list.h:173:27: note: expected ‘_Bool (*)(const struct list_elem *, const struct list_elem *, void *)’ but argument is of type ‘_Bool (*)(struct list_elem *, struct list_elem *, void *)’
```

so we add two const(const is like java final, the stuff inside the function cannot alter it)

fail, the output was from 30 -> 21, we get the opposite, it should be > in list_less_priority

so I am decieved by the name in list_insert_ordered, the param is less, bu t nonono,

so then we have the first half done

then, when the priority changes, that should be after set_priority

from the previous work, we notice that every time tick, ready_list and all_list is sorted by priority, even if priority change

so all we need to do is block(yield) the current thread, and the scheduler would automatically choose the one with the highest priority

see the comment in the test priority-change

```C
/* Verifies that lowering a thread's priority so that it is no
   longer the highest-priority thread in the system causes it to
   yield immediately. */
```

so we simply add thread_yield to the thread_set_priority

then we get

```
  (priority-change) begin
  (priority-change) Creating a high-priority thread 2.
- (priority-change) Thread 2 now lowering priority.
  (priority-change) Thread 2 should have just lowered its priority.
+ (priority-change) Thread 2 now lowering priority.
  (priority-change) Thread 2 exiting.
  (priority-change) Thread 2 should have just exited.
  (priority-change) end
```

we check the test

```C
void
test_priority_change (void) 
{
  /* This test does not work with the MLFQS. */
  ASSERT (!thread_mlfqs);

  msg ("Creating a high-priority thread 2.");
  thread_create ("thread 2", PRI_DEFAULT + 1, changing_thread, NULL);
  msg ("Thread 2 should have just lowered its priority.");
  thread_set_priority (PRI_DEFAULT - 2);
  msg ("Thread 2 should have just exited.");
}

static void
changing_thread (void *aux UNUSED) 
{
  msg ("Thread 2 now lowering priority.");
  thread_set_priority (PRI_DEFAULT - 1);
  msg ("Thread 2 exiting.");
}

```

so the thread_create should be executing a bit later

this is because the priority queue may have changed when the thread creates

so we basically just add *thread_yield* in *thread_create*

```C
tid_t
thread_create (const char *name, int priority,
               thread_func *function, void *aux) 
{
  struct thread *t;
  struct kernel_thread_frame *kf;
  struct switch_entry_frame *ef;
  struct switch_threads_frame *sf;
  tid_t tid;
  enum intr_level old_level;

  ASSERT (function != NULL);

  /* Allocate thread. */
  t = palloc_get_page (PAL_ZERO);
  if (t == NULL)
    return TID_ERROR;

  /* Initialize thread. */
  init_thread (t, name, priority);
  tid = t->tid = allocate_tid ();

  /* Prepare thread for first run by initializing its stack.
     Do this atomically so intermediate values for the 'stack' 
     member cannot be observed. */
  old_level = intr_disable ();

  /* Stack frame for kernel_thread(). */
  kf = alloc_frame (t, sizeof *kf);
  kf->eip = NULL;
  kf->function = function;
  kf->aux = aux;

  /* Stack frame for switch_entry(). */
  ef = alloc_frame (t, sizeof *ef);
  ef->eip = (void (*) (void)) kernel_thread;

  /* Stack frame for switch_threads(). */
  sf = alloc_frame (t, sizeof *sf);
  sf->eip = switch_entry;
  sf->ebp = 0;

  intr_set_level (old_level);

  /* Add to run queue. */
  thread_unblock (t);

// mycode starts task1
  // so basically, there is a possiblity that the priority here is the current highest priority
  // the we need to yield the CPU
  if (thread_get_priority()  < priority) {
    // thread_get_priority gets the priority of the current thread
    thread_yield();
  }
// mycode ends
  return tid;
}
```

## other tasks
### task1: init thread_get_priority and thread_set_priority
these are implement in the in codebase

```C
void
thread_set_priority (int new_priority) 
{
  thread_current ()->priority = new_priority;
// mycode starts task1
  thread_yield();
// mycode ends
}
```

```C
/* Returns the current thread's priority. */
int
thread_get_priority (void) 
{
  return thread_current ()->priority;
}
```

### task2: Prioritized unblocking on synchronisation primitives

actually I think this is included in task3, since no matter which tick we are at, ready_list and all_list is always sorted by priority, semas call thread unblock and do the removal from ready_list, locks come from semas, conditionals are similar.

### task3: done

### task4 & 5:
priority donation

so first, we need to figure out which thread waits for which

and record the donations(possibly in an array of structs)

so if we are implementing this for locks, we should do

if the thread is holding the lock, we record this thread

get the current thread at everytick, if no donations happen during this lock, we add a donation

then after the lock, we restore the donation

so basically what we are altering is just a list of donations that belong to each thread itself

when we later call thread_get_priority, we iterate through the list of donations and get the final priority

this way we do not have to do anything to the thread_set_priority as by default it changes the priority member field, but donations only happen in the list

### task6:FPU
so we have two sets of variable
- integers: priority, nice, ready_threads
- real_numbers: recent_cpu load_avg

pintos does not support floating-point arithmetic

treat the rightmost bits of an integer as representing a fraction

so if 32bit int, the lowest 14 can be fractions, so we get $\frac{x}{2^{14}}$, so 17 bit for the numerator, 1 for sign, the rest for denominator

- $f = 2^q$ where p,q are in fixed-point format, p+q = 31, f = 1 << q
- integer n to fixed-point $n * f$
- fixed-point x to integer(round towards zero) $x / f$
- convert x to integer(round to nearest) $\begin{cases}\begin{array}{c}\frac{(x + \frac{f}{2})}{f} & x\ge 0\\\frac{(x - \frac{f}{2})}{f} & x\le 0\end{array}\end{cases}$
- add fixed-point x and fixed-point y: $x+y$
- subtract fixed-point y from fixed-point x: $x-y$
- add fixed-point and integer n: $x + n * f$
- subtract integer n from fixed-point x: $x - n * f$
- multiply fixed point x by fixed-point y: $((int64_t)x) * y / f$
- multiply fixed point x by integer n : $x * n$
- divide fixed-point x by fixed-point y: $((int64_t)x) * f / y$
- divide fixed-point x by integer n: $x / n$

so then, following the instructions, we do

```C
//
// Created by zhizh on 08/10/2024.
//

#ifndef FIXED_POINT_H
#define FIXED_POINT_H

/* Fixed-Point Real Arithmetic */
#include <stdint.h>

/* We designate lowest 14 bits as fractional bits */
// altered by hongleigu, restore if needed
#define q 14 // this should be the digits of the fractions
#define F (1 << q);
// altering end
typedef int fp; /* type alias fixed point number */

/* n is an integer */
/* Convert n to fixed point */
inline fp int_to_fp(int n) {
  return n * F;
}

///* Convert float to fixed point */
//inline fp float_to_fp(float n) {
//  return n * F;
//}
//
///* Convert fixed point to float */
//inline float fp_to_float(fp n) {
//  return ((float) n) / F;
//}

/* Convert x to integer (rounding toward zero) */
inline int fp_to_int_round_to_zero(fp x) {
  return x / F;
}

/* Convert x to integer (rounding to nearest) */
inline int fp_to_int_round_to_nearest(fp x) {
  return (x >= 0) ? (x + F / 2) / F : (x - F / 2) / F;
}

/* Add x and y where x and y are fixed-point */
inline fp add_fps(fp x, fp y) {
  return x + y;
}

/* Subtract y from x where y and x are fixed-point */
inline fp sub_fps(fp x, fp y) {
  return x - y;
}

/* Add x and n where x is fixed-point and n is integer */
inline fp add_fp_int(fp x, int n) {
  return x + n * F;
}

/* Subtract n from x where n is integer and x is fixed-point */
inline fp sub_fp_int(fp x, int n) {
  return x - n * F;
}

/* Multiply x by y where x and y are fixed-point */
inline fp mul_fps(fp x, fp y) {
  return ((int64_t) x) * y / F;
}

/* Multiply x by n where x is fixed-pont and n is integer */
inline fp mul_fp_int(fp x, int n) {
  return x * n;
}

/* Divide x by y where x and y are fixed-point */
inline fp div_fps(fp x, fp y) {
  return ((int64_t) x) * F / y;
}

/* Divide x by n where x is fixed-point and n is integer */
inline fp div_fp_int(fp x, int n) {
  return x / n;
}

#endif //FIXED_POINT_H

```

this is not hard actually, just cumbersome

### task7:BSD scheduler

so it just do one thing

- priority argument to *thread_create*, *thread_get/set_priority* should be ignored

so basically we should ignore these and update all the recent_cpu and load_avg stuff inorder to pass the mlfqs tests(maybe TDD, we can see the sample result for mlfqs-recent-1)

first of all, all these must be done under mlfqs environment, so we do an if statement before that

the recent_cpu need to be updated every physical second, so thats ticks * TIMER_FREQ, where TIMER_FREQ is set to 100 by default

we alter the thread_tick function(actually the timer_interrupt will also do, they are basically the same)

```C
void
thread_tick (void) 
{
  struct thread *t = thread_current();
  /* Update statistics. */
  /* adding BSD scheduler related code */
  /* Each time a timer interrupt occurs,
	recent_cpu is incremented by 1 for the running thread only,
	unless the idle thread is running.
  */
  if (t == idle_thread)
    idle_ticks++;
  else {
#ifdef USERPROG
  if (t->pagedir != NULL)
    user_ticks++;
  else
#endif
    kernel_ticks++;

    t -> recent_cpu = add_fp_int(t->recent_cpu, 1);
  	}
    /* Once per second after system boot, load_avg is updated according to the formual */
    /* Once per second the value of recent_cpu is recalcualted for every thread,
	 whether running, ready, or blocked using the formula
   */
// mycode starts task1 subtask6&7 hongleigu
  if (thread_mlfqs) {
    if (timer_ticks() % TIMER_FREQ == 0) {
      thread_mlfqs_update_recent_cpu_and_load_avg(t);
      // thread_foreach(update_recent_cpu, NULL);
    } else if (timer_ticks() % TIME_SLICE == 0){
      // the spec says do it as necessary
      // lets just do every time slice
      thread_mlfqs_update_priority(t);
    }
  }
//
  /* Enforce preemption. */
  if (++thread_ticks >= TIME_SLICE)
    intr_yield_on_return ();
}
```

we also do the addition to recent_cpu first

the addition update_priority happens when the threads need to update priority with

$\text{priority} = \text{PRI_MAX} - (\text{recent_cpu} /4) - (nice * 2)$

so from this we can infer that whenever recent_cpu and nice change, we should update the priority, also, we should do the updating every time slice just in case the testing program changes priority at some time but we did not update

that is the reason of the stuff in the else statement

but notice these two functions are yet to implement

we will do recent_cpu and load_avg first

load_avg is simple


$\text{load_avg} = \frac{59}{60}*\text{load_avg} + \frac{1}{60}*\text{ready_threads}$

just get the length of the list, do multiplication and done

but recent_cpu does nasty things

$\text{rencent_cpu} = \frac{2*\text{load_avg}}{2*\text{load_avg} + 1} * \text{recent_cpu} + nice$

the nice is nasty

you can do $\text{recent_cpu} = (1-\frac{1}{2*\text{load_avg}}\text{recent_cpu} + nice$

but we will fix to the spec

so we have

```C
void
thread_mlfqs_update_recent_cpu_and_load_avg(struct thread* t)
{
  int ready_threads = list_size(&ready_list);
  if (t != idle_thread) ready_threads++;
  /* formula: load_avg =  (59/60)*load_avg + (1/60)*ready_threads; */
  load_avg = add_fps(mul_fps(c1, load_avg), mul_fp_int(c2, ready_threads));

  struct list_elem *x;
  for (x = list_begin(&all_list); x != list_end(&all_list); x = list_next(x)) {
    struct thread *t = list_entry(x, struct thread, allelem);
    /* Except DYING, the other status are running, ready, and blocked */
    if (t->status != THREAD_DYING) {
      /* number used in the calculation for recent cpu*/
      fp u = mul_fp_int(load_avg, 2);
      fp x = div_fps(u, add_fp_int(u, 1));
      fp y = mul_fps(x, t->recent_cpu);
      t->recent_cpu = add_fp_int(y, t->nice); /* Effciency here may be improved?! */
    }
  }
}
```

what a pity we cannot use the thread_foreach because this is about allelem, not elem

so then we update the priority

```C
// mycode ends

// mycode starts: task1 subtask6&7 hongleigu
/* Update priority. */
void
thread_mlfqs_update_priority (struct thread* t)
{
  if (t == idle_thread)
    return;

  ASSERT (thread_mlfqs);
  ASSERT (t != idle_thread);

  t->priority = fp_to_int_round_to_nearest(sub_fp_int(sub_fps(int_to_fp(PRI_MAX), div_fp_int(t->recent_cpu, 4)), 2 * t->nice));
  // 
  t->priority = t->priority < PRI_MIN ? PRI_MIN : t->priority;
  t->priority = t->priority > PRI_MAX ? PRI_MAX : t->priority;
}
```

the last two line is just because I am afraid the priority went beyound the scope (PRI_MIN to PRI_MAX)

so we do the clipping

the mlfqs tests so then pass, this part done
