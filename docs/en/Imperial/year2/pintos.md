## Some notes:
the Imperial Task 0 was from official repo, the rest may be different from the original Stanford version
## project structure:
- src/device:
  - contains code to deal with supporting devices
  - timer.c in Task 0
- src/threads:
  - task 1,2,3
  - all thread related stuff
- src/userprog:
  - task 2,3
  - user programs, process loading and system calls
  - Pintos' page table implementation and exception handler
- src/vm:
  - task 3
  - virtually empty, create virtual memory here
- src/filesys:
  - filesystem implmentation
  - do not modify
- src/lib:
  - libs
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
##  Part B- The Alarm Clock
### testing:
- all test: ```make check```
- single test: ```make build/tests/device/${testname}.result```
