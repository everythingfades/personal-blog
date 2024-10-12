# SED : Exercise 2 : Mock Objects - Work in Pairs
The central component is the Camera, it is responsible for responding to user actions from the 
camera controls, and co-ordinating the transfer of data from the sensor to the memory card when a 
photograph is taken. You should develop the Camera class in a test-driven style, adding one test at 
a time to CameraTest. Use JUnit and jMock to write your tests.

A Camera is required to have the following behaviours:

1. switching the camera on powers up the sensor
2. switching the camera off powers down the sensor
3. pressing the shutter when the power is off does nothing
4. pressing the shutter with the power on copies data from the sensor to the memory card, Writing data to the memory card can take a few seconds
5. if data is currently being written, switching the camera off does not power down the sensor
6. and then, once writing the data has completed, the camera powers down the sensor

**We shouldn’t change Sensor and MemoryCard components**

**The Camera should implement the WriteListenser interface** (basically it need to override the writeComplete)

## Questions to Consider:
**What is the default power state of a new Camera**

- power off? data empty?

**Is there any duplication in your tests? Could it be factored out?**

**Are your test focused and to the point**

**UML Sequence Diagram**

## JMock
following TDD, we first write the test, just to test how JMock works.

```Java
@Test
  public void JMockWorks() {
    final TestJMock subscriber = context.mock(TestJMock.class);
    // we mock a testJMock class because subscriber is an interface
    Publisher publisher = new Publisher();
    // this publisher is a class, no need to mock
    publisher.add(subscriber);
    
    final String message = "message";
    
    // expectations
    // this is a async function and does not execute immediately
    // rather, until we call context.assertIsSatisfied
    // this will be fully evaluated
    context.checking(new Expectations() {{
        oneOf (subscriber).receive(message);
    }});

    // execute
    // when publisher publishs, all the subscribers receive
    publisher.publish(message);
    context.assertIsSatisfied();
  }
```

then we write the code

we want the publisher's publish to call all the subscribers' recieve

```Java
package ic.doc.camera;

import java.util.LinkedList;
import java.util.List;

public class Publisher {
  private List<Subscriber> subscribers;

  public Publisher(){
    this.subscribers = new LinkedList<>();
  }

  public void add(Subscriber subscriber) {
    this.subscribers.add(subscriber);
  }

  public void publish(String message) {
    for (Subscriber sub : this.subscribers) {
      sub.receive(message);
    }
  }
}

```

```Java
package ic.doc.camera;

public interface TestJMock {
  public void receive(String message);
}

```

after refactoring, TestJMock -> Subscriber

## things we need to implement

actually they are written in the codebase

**Camera**
- public void pressShutter()
- public void powerOn()
- public void powerOff()
- constructor

also note to follow all the requirements, they are pretty straightforward, so no interpretation

and actually, though not mention directly

- a camera include a sensor, so a memeber field
- a camera is able to write data so a MemoryCard and also a WriteListener

the **Camera** class should be as follows

```Java
public class Camera implements WriteListener{

  private Sensor sensor;
  private MemoryCard memoryCard;

  public void pressShutter() {
    // when the power is off, this does nothing
    // otherwise copies data from the sensor 
    // to the memory card
  }

  public void powerOn() {
    // power up the sensor
  }

  public void powerOff() {
    // powers down the sensor
    // but if data is being written, do nothing
    // when data finishes writing, powerOff
  }

  @Override
  public void writeComplete() {
    // implments the writeComplete method
  }
}
```

consider the member variables we need to add
- we need to check the power: private bool power
- we need to check whether the data is being written, but I think the writeComplete does it

## tests:
for simplicity, we add this as global variables to the test class

```Java
@Rule
public JUnitRuleMockery context = new JUnitRuleMockery();
// this defines the context we are in

final Sensor sensor = context.mock(Sensor.class);
final MemoryCard memoryCard = context.mock(MemoryCard.class);
```
### constructor:
#### canConstuctWithSensorAndMemoryCard
following the lecture, we should not add *getSensor* and *getMemoryCard* methods

so we will just do this, since powering on the camera should at least power up the *sensor*, the *memoryCard* does not need to power Up

```Java
@Test
public void canConstuctWithSensorAndMemoryCard() {
  context.checking(new Expectations() {{
    exactly(1).of(sensor).powerUp();
    // we need to sensor to be powered up
    // at it should not be called multiple times
  }});

  // memoryCard does not need powering Up
  Camera camera = new Camera(sensor, memoryCard);
  context.assertIsSatisfied();
}
```

we do this to pass the test

```Java
  public Camera(Sensor sensor, MemoryCard memoryCard) {
    this.sensor = sensor;
    this.memoryCard = memoryCard;
    this.power = false;
  }
```

tests passed, nothing needs refactoring

### pressShutter():
pressing Shutter requires a default power settings

minimal code:

```Java
private boolean power
public void powerOn() {
  // power up the sensor
  
  // a simple implementation
  power = true;
}

public void powerOff() {
  // powers down the sensor
  // but if data is being written, do nothing
  // when data finishes writing, powerOff

  // a simple implementation
  power = false;
}
```
#### canDoNothingWhenPressingShutterAtPowerOff
the test should check if pressing shutter when power off does no operations of the *memoryCard* and the *sensor*

we write the test

```Java
@Test
public void canDoNothingWhenPressingShutterAtPowerOff(){

  context.checking(new Expectations() {{
    never(sensor).readData();
    // this is the only methods in sensor 
    // besides the powers
    // the camera should not call this in the test
  }});

  context.checking(new Expectations() {{
    never(memoryCard).write(with(any(byte[].class)));
    // this is the only methods in memoryCard
    // the camera should not call this in the test
  }});

  Camera camera = new Camera(sensor, memoryCard);
  camera.powerOff();
  // make sure the power is off

  camera.pressShutter();
  context.assertIsSatisfied();
}
```

we implement

```Java
public void pressShutter() {
  // when the power is off, this does nothing
  // otherwise copies data from the sensor 
  // to the memory card

  if (power) {
    return;
    // to be fixed, this is when the power is on
  }
  else {
    // we should do nothing
    return;
  }
}
```

tests passed, nothing need refactoring

#### canCopyDataToMemoryCardWhenPressingShutterAtPowerOn
this require the *camera* to call the *readData* method when the power is on

the call the *write* method of the *memoryCard*

so we write

```Java
@Test
public void canCopyDataToMemoryCardWhenPressingShutterAtPowerOn() {
  context.checking(new Expectations() {{
    exactly(1).of(sensor).readData();
  }});

  context.checking(new Expectations() {{
    exactly(1).of(memoryCard).write(with(any(byte[].class)));
  }});

  Camera camera = new Camera(sensor, memoryCard);

  camera.powerOn();

  camera.pressShutter();
  context.assertIsSatisfied();
}
```

```Java
public void pressShutter() {
  // when the power is off, this does nothing
  // otherwise copies data from the sensor 
  // to the memory card

  if (power) {
    byte data[] = sensor.readData();
    
    memoryCard.write(data);
  }
  else {
    // we should do nothing
    return;
  }
}
```

test passed

refactoring

it looks nicer if

```Java
public void pressShutter() {
  // when the power is off, this does nothing
  // otherwise copies data from the sensor 
  // to the memory card

  if (power) {
    byte data[] = sensor.readData();
    
    memoryCard.write(data);
  }
  // we should do nothing if the power is off
  return;
}
```

### writeComplete()
#### canWriteCompleteAtDefault
so if nothing is done, it should *writeComplete* with true at default

there should be a *public something status* to indicate the status, the status should be accessed by other(I dont think this can be achieve with private and no other getters)

we do 

```Java
public enum Status {
  READY,
  BUSY,
  ERROR
}

////////

private Status status;
```

then *writeComplete* just sets the *status* to Ready

actually I think this should only be used in *pressShutter*


#### canWriteCompleteAfterPressingShutterAtPowerOff

```Java
@Test
public void canWriteCompleteAfterPressingShutterAtPowerOff() {

  // these two lines put the printed stuff into outContent
  // since expectations only work on mock objects, we check the output
  ByteArrayOutputStream outContent = new ByteArrayOutputStream();
  System.setOut(new PrintStream(outContent));

  String expectedContent = "write complete\n";


  context.checking(new Expectations() {{
    exactly(0).of(sensor).readData();
  }});

  context.checking(new Expectations() {{
    exactly(0).of(memoryCard).write(with(any(byte[].class)));
  }});

  Camera camera = new Camera(sensor, memoryCard);
  
  camera.powerOff();

  camera.pressShutter();
  context.assertIsSatisfied();
  // Do the actual assertion.
  // assertThat uses the ==, but we need to do .equals for strings
  assertEquals(expectedContent, outContent.toString());
}
```

we do 

```Java
@Override
public void writeComplete() {
  // implments the writeComplete method
  status = Status.READY;
  System.out.print("write complete\n");
}
```

also add *writeComplete();* into *pressShutter()*

refactor? I dont think we need to do that

### powerOn()
#### switchingTheCameraOnPowersUpTheSensor

```Java
@Test
public void switchingTheCameraOnPowersUpTheSensor() {

  // Turn on the camera and check whether there's a call
  // to power up the sensor
  context.checking(new Expectations() {{
    exactly(1).of(sensor).powerUp();
  }});

  Camera camera = new Camera(sensor, memoryCard);
  camera.powerOn();
  context.assertIsSatisfied();
}
```

implementation:

```Java
public void powerOn() {
  // power up the sensor
  sensor.powerUp();
  // a simple implementation
  power = true;
}
```

no refactoring needed

### powerOff()
#### canPowerOffandWaits

```Java
@Test
public void canPowerOffandWaits() {
  Camera camera = new Camera(sensor, memoryCard);

  context.checking(new Expectations() {{
    exactly(1).of(sensor).powerDown();
  }});

  camera.powerOff();

  context.assertIsSatisfied();
  
}
```

implementation:

```Java
public void powerOff() {
  // powers down the sensor
  // but if data is being written, do nothing
  // when data finishes writing, powerOff
  while (status != Status.READY) {
    // wait until the status is ready
    continue;
  }
  sensor.powerDown();
  // a simple implementation
  power = false;
}
```

we are unable to set the waiting without altering the MemoryCard, so this is best we could do

