# SED : Exercise 1 : Test Driven Development - Work in Pairs

The Recently Used List

This is a list of items such as recently dialled numbers on your phone, or recently opened files in an application on your computer.
1. The list should be empty when initialised.
2. We should be able to add things to the list. 
3. We should be able to retrieve items from the list.
4. The most recent item should be first in the list. 
5. Items in the list are unique, so duplicate insertions should be moved rather than added.

## so basicially we should do 
- first, according to 1., we should not add anything to the list during init, (need function init)
- second, according to 2., need function add, but currently not sure whether this should be generic
- third, according to 3., we need to retrieve from list, possibly pass in a index argument, so retrieve()
- fourth, according to 4., everytime we call retrieve, we need to put it at the front
- fifth, item are unique, so we either init a set, or do the checking each time


## possible data structure we can use are
- linkedList(time-intensive when retrieving, time-efficient when storing, space-efficient)
- hashset(pass, this is unordered)
- hashmap(not so suitable, since it is a list, but can be, order -> item)

so currently decided to use linked list


## thing we have to take care of 
- since we need to make sure everything is unique, we need to check whether the element is comparable

so two possible realization:

- to let the user pass in a comparator for the given class
- to let the user only pass in Java comparable
- to let the user only pass in a certain type

we need to add (the space in < T> prevents it from being a html tag, at least in the editor)

- public < T extends Comparable<T>> RecentlyUsedList()
- public < T> RecentlyUsedList(Comparator< T> comparator)

##  Rules of Test-Driven Development
- Start by writing a test (1 test).
- Fill in enough code just to make it compile.
- Run all the tests, watch your test fail (red bar).
- Make the simplest possible change to your code that will make the test pass.
- Run all the tests and watch them pass (green bar).
- Consider refactoring.
- Commit your changes to version control.
- Repeat.

## coding - the experience
summarize the functions

- public < T extends Comparable<T>> RecentlyUsedList()
- public < T> RecentlyUsedList(Comparator< T> comparator)
- public <T> T retrieve(int index)

other methods may be added for simplicity

- public void add(T item)
- public void remove(int index)


### following the TDD:

#### test1 empty initialization
we first write a test to check init 

```Java
@Test
public void testInit() {
  RecentlyUsedList<String> list = new RecentlyUsedList<>();
  assertThat("List is null", list.getList().size() == 0);
  System.out.println("testInit passed");
}
```

we then write the constructor

```Java
public RecentlyUsedList(){
  // this should init a empty linkedlist
  list = new LinkedList<T>();
  // the comparator is set to null
  comparator = null;
}
```

this passes, move to refactoring, pass

#### test2

we want to add a comparator to the constructor

so we write the test

```Java
@Test
  public void testInitWithComparator() {
    RecentlyUsedList<String> list = new RecentlyUsedList<>(
      new Comparator<String>() {
        public int compare(String s1, String s2){
          // lets just imitate the regular comparator
          return s1.compareTo(s2);
        }
      }
    );
    // I know this is ugly, but it is simpler, comparator is an interface
    assertThat("List is null", list.getList().size() == 0);
    // there should be a method to get the list, since it should be private
    
    // since the initialized list should be empty, so we simply check the size of the list by whatever method
    // with size() or length or whatever

    assertThat("comparator is not null", list.getComparator() != null);
    // first we need to check if the comparator is not null
    assertThat("comparator works well", list.getComparator().compare("PintOS","PaintOS") != 0);
    // then we need to check if the comparator is working well
    // nightmare from C: changed to random stuff because no malloc
    System.out.println("testInit passed");
  }
```

then we try to write the code

```Java
public RecentlyUsedList(Comparator<T> comparator){
  list = new LinkedList<T>();
  this.comparator = comparator;
}
```

test failed

Hey, you forget to write the getComparator method

```Java
public Comparator<T> getComparator(){
  return comparator;
}
```

test passed, went on for refactoring

so now all the init stuff are good to go


