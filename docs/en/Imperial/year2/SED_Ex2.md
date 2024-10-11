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
following TDD, we first write the test

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

also note to follow all the requirements, they are pretty straightforward, so no interpretation

and actually, though not mention directly

- a camera include a sensor, so a memeber field
- a camera is able to write data so a MemoryCard and also a WriteListener

the **Camera** class should be as follows

```Java
public class Camera {

  private Sensor sensor;
  private MemoryCard memoryCard;
  private WriteListener writeListener;

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
}
```