
# 4. JS进阶
## 4.1 作用域:
### 4.1.1 局部作用域:
#### 4.1.1.1 函数作用域:

在函数内生命的变量只能在函数内部被访问

- 函数的参数也是函数的局部变量
- 不同函数内声明的变量无法互相访问

!!! example
    === "代码"

        ```javascript
        function foo(){
            const a = 1
        }
        function fooz(){
            // 这里访问不到 foo里的a
            const b = a + 1
        }
        foo()
        fooz()
        ```
    === "输出"
        报错

#### 4.1.1.2 块作用域:
在js中使用{}包裹的代码称为代码块,代码块内部声明的变量外部有可能无法被访问

- let const 会产生作用域, var不会
- 不同代码块之间的变量无法互相访问

经典实例: for循环
### 4.1.2 全局作用域:
.js文件以及< script>标签内部会产生全局作用域

### 4.1.3 作用域链:
变量查找机制

- 优先查找当前作用域的变量
- 入股偶查不到会逐级往上找

## 4.2 垃圾回收:

应该和java一样,不用就回收:

内存:

- 内存分配: 声明变量函数对象的时候会自动分配内存
- 内存使用: 读写内存
- 内存回收: 使用完被垃圾回收期自动回收

说明:

- 全局变量一般不会回收
- 局部变量的值不用了会自动回收


内存泄露: 程序中的内存无法回收等

- 栈: 操作系统自动分配, 基本数据类型
- 堆: 存复杂类型,程序员或垃圾回收机制回收

### 4.2.1 引用计数法:

- 跟踪记录变量使用次数
- 引用一次就++
- 减少引用就--
- 引用次数为0, 释放内存


### 4.2.2 标记计数法:

- 计算无法到达的对象
- 从根部定期扫描内存中的对象,如果到达不了则回收

## 4.3 闭包:
内层函数+外层函数的变量

实现数据私用,回忆一下作用域就懂了

!!! example
    === "代码"
        ```javascript
        function outer(){
            const a = 1
            function fn(){
                console.log(a)
            }
            return fn
        }
        outer()
        ```
    === "输出"
        函数fn

## 4.4 变量提升:

仅存在于var变量, let和const没有

把所有var声明的变量提升到当前作用域的最前面,只提升声明,不提升赋值,这样在之前访问变量的时候会是undefined,这样不会出现一下情况:

一般来说python玩家不太会有这个问题

同理函数提升就是把函数声明提升到当前作用域的最前面,如果是直接声明函数不会出错,但是函数表达式必须先声明后赋值否则报错

!!! example
    === "代码"
        ```python
        console.log(str + "world")
        var str = "hello "
        ```
    === "输出"
        undefinedworld
    

## 4.5 函数参数:
### 4.5.1 动态参数

但是javascript直接不写就行

相当于函数默认是这个样子:

```java
public static void main(String[] args){
}
```

!!! example
    === "代码"
        ```javascript
        function getSum(){
            console.log(arguments) // 这个arguments是动态参数,只存在域函数内部
        }
        getSum(1,2,3,4,5,6)
        ```
    === "输出"
        [Arguments] { '0': 1, '1': 2, '2': 3, '3': 4, '4': 5, '5': 6 }
    

### 4.5.2 剩余参数:
可以将不定数量的参数表示为一个数组

python的**kwargs等

这个是实参上面,那个只是形参

!!! example
    === "代码"
        ```python
        function getSum(a,b,...other){
            console.log(other)
        }
        getSum(1,2,3,4,5,6,7,8,9,0,[1,2,3])
        ```
    === "输出"
        [ 3, 4, 5, 6, 7, 8, 9, 0, [ 1, 2, 3 ] ]
    

## 4.6 展开运算符:

...数组 进行展开

好处在Max等必须要输入元素而不是数组的时候

## 4.7 箭头函数:

一般是在函数表达式的时候用

只有一个形参的时候可以省略小括号

如果只有一行代码,可以直接写到一行上,不需要写return,也不需要写大括号

箭头函数可以直接返回一个对象

### 4.7.1 参数:
箭头函数没有arguments动态参数,但是有剩余参数..args


### 4.7.2 this:
箭头函数没有自己的this,调用this会返回作用域的上一层


!!! example
    === "代码"
      ```javascript
      const fn = function(){
          console.log(1)
      }
      const f = () => {
          console.log(1)
      }
      const a = (...arr) => {
          console.log(arr)
          console.log(this)
      }

      a(1,2,3,4)
      ```
    === "输出"
        [ 1, 2, 3, 4 ]
        (下面是各种jupyter的配置之类的)

### 4.7.3 对象方法的箭头函数:


!!! example
    === "代码"
        ```javascript
        const obj = {
            name: "ifjeijf",
            sayHi: ()=>{
                console.log(this)
                const i = 10
                const count = () => {
                    console.log(this)
                }
                count()
            }
        }
        // obj的sayHi没有this,会返回上一层(obj)的this
        obj.sayHi()
        // window调用obj的sayHi方法,返回window而不是obj
        // jupyter里的window比较奇怪

        //count里没有this,找上一层的sayHi,但是sayHi也没有this.接着找,最后找到window
        ```
    === "输出"
        (jupyter window)

        10

## 4.8 解构赋值:
### 4.8.1 数组:
示例1
!!! example
    === "代码"
      ```javascript
      const arr = [1,2,3]
      const [a,b,c] = arr
      console.log(a)
      console.log(b)
      console.log(c)
      ```
    === "输出"
        1
        2
        3
        
示例2
!!! example
    === "代码"
        ```javascript
        let a = 1
        let b = 2; //这里必须有分号, 如果没有编译器会把下一行代码混淆到这一行,
                  //就是解构之前哪一行必须要分号
        [b,a] = [a,b]
        console.log(a)
        console.log(b)
        ```
    === "输出"
        2
        1
    

示例3
!!! example
    === "代码"
      ```javascript
      // 同时
      const [a,b,c,d] = [1,2,3]

      console.log(a)
      console.log(b)
      console.log(c)
      console.log(d)
      ```
    === "输出"
        1
        2
        3
        undefined
    
示例4
!!! example
    === "代码"

        ```javascript
        // 为了防止这种情况,可以设置默认值
        const [a = 10, b = 20, c = 30, d = 40] = [1,2,3]

        console.log(a)
        console.log(b)
        console.log(c)
        console.log(d)
        ```
    === "输出"
        1
        2
        3
        40
    
示例5
!!! example
    === "代码"
        ```javascript
        // 支持多维数组
        const [a = 10, b = 20, c = 30, d = 40] = [1,2,[3,4]]

        console.log(a)
        console.log(b)
        console.log(c)
        console.log(d)
        ```
    === "输出"
        1
        2
        [ 3, 4 ]
        40
    

### 4.8.2 对象:

示例1
!!! example
    === "代码"
        ```javascript
        const {name, age} = {
            name : "a",
            age: 12
        }
        console.log(name)
        console.log(age)
        ```
    === "输出"
        a
        12
    
示例2
!!! example
    === "代码"
        ```javascript
        // 属性名必须完全对应,
        // 不要和外面有冲突,不然会报错
        const uname = 10
        const {uname, age} = {
            // 这里相当于两个const赋值语句
            name : "a",
            age: 12
        }
        console.log(name)
        console.log(age)
        ```

    === "输出"
        a
        12
示例3
!!! example
    === "代码"
        ```javascript
        const {name: uname, age} = {
            name : "a",
            age: 12
        }
        console.log(uname)
        console.log(age)
        ```
    === "输出"
        a
        12
    

示例4
!!! example
    === "代码"
        ```javascript
        // 数组对象解构:
        const pig = [{
            "name":"aaa",
            "age": 16
        }]
        const [{name, age}] = pig
        console.log(name)
        console.log(age)
        ```
    === "输出"
        aaa
        16
    

示例5
!!! example
    === "代码"
        ```javascript
        const pig = {
            name: "aaa",
            family: {
                mother: "mother",
                father: "father",
                sister: "sister"
            },
            age: 6
        }
        const {name, family:{mother, father, sister}} = pig
        console.log(name)
        console.log(mother)
        console.log(father)
        console.log(sister)
        ```
    === "输出"
        aaa
        mother
        father
        sister
    

示例6
!!! example
    === "代码"
        ```javascript
        // 也可以在函数传参的时候解构
        const pig = {
            name: "aaa",
            family: {
                mother: "mother",
                father: "father",
                sister: "sister"
            },
            age: 6
        }
        function f({name, family:{mother, father, sister}}){
            console.log(name)
            console.log(mother)
            console.log(father)
            console.log(sister)
        }
        f(pig)
        ```
    === "输出"
        aaa
        mother
        father
        sister
    

## 4.9 一些函数:
.map() .forEach(), kotlin的老熟人了,用法也差不多

map
!!! example
    === "代码"
        ```javascript
        const a = [1,2,3].map(b=>b+1)
        console.log(a)
        ```
    === "输出"
        [ 2, 3, 4 ]
    

foreach对于对象不起作用

!!! example
    === "代码"
    ```javascrip
    const pig = {
        name: "aaa",
        family: {
            mother: "mother",
            father: "father",
            sister: "sister"
        },
        age: 6
    }

    ```
    === "输出"

    TypeError: pig is not iterable

但是可以这样
!!! example
    === "代码"
        ```javascript
        for (i of Object.entries(pig)){
            console.log(i)
        }
        ```
    === "输出"
        [ 'name', 'aaa' ]
        [ 'family', { mother: 'mother', father: 'father', sister: 'sister' } ]
        [ 'age', 6 ]
    

## 4.10 对象:
### 4.10.1 创建对象三种方式
#### 4.10.1.1 直接创建

!!! example "代码"
    ```javascript
    const obj = {
        "name": "aaa"
    }
    ```

#### 4.10.1.2 new Object(系统默认构造函数)

!!! example
    === "代码"
        ```javascript
        const obj1 = new Object()
        obj1.name = "aaa"
        console.log(obj1)
        ```
    === "输出"
        { nam2: 'aaa' }
    

#### 4.10.1.3 自定义构造函数:
约定: 

- 函数名称首字母大写
- 只能用new操作

说明:

- 构造函数内没有参数的时候可以省略括号
- 构造函数内部无需return,return返回值无效
- 系统内置的Object和Date也是构造函数

!!! example
    === "代码"
        ```javascript
        function Pig(name){
            this.name = name
        }
        obj2 = new Pig("aaa")
        console.log(obj2)
        ```
    === "输出"
        Pig { name: 'aaa' }

### 4.10.2 成员:
#### 4.10.2.1 实例成员:
通过构造函数创建的对象是实例对象.实例对象中的属性和方法称为实例成员

- 为构造函数传入参数,结构相同但对象不同,(和java一样,new就是一个全新的地址不同的对象)
- 创建的对象彼此独立,互不影响

#### 4.10.2.2 静态成员:
构造函数的属性和方法称为静态成员,就想象有个看不到的java static关键字

只能通过构造函数调用

!!! example 
    === "代码"
        ```python
        Pig.eyes = 2
        Pig.legs = 4
        Pig.sayHi = function(){
            console.log(this)
        }
        console.log(Pig.eyes)
        Pig.sayHi()
        console.log(eyes)
        ```
    === "输出"
        2
        [Function: Pig] { eyes: 2, legs: 4, sayHi: [Function] }


### 4.10.3 包装类型

#### 4.10.3.1 基本包装类型:
字符串, 数值, boolean, undefined, null

字符串比较特殊:

一般来说只有对象才有属性方法,但是可以调用string.length

在js底层自动包装乘复杂数据类型, 相当于java的int数据类型被自动变成Integer类

!!! example
    === "代码"
        ```javascript
        const str = new String("aaa")
        const string = "aaa"
        ```
    === "输出"
        只是新建两个字符串,没有输出


#### 4.10.3.2 内置构造函数:
引用类型:

- Object. Array, RegExp, Date......

包装类型:

- String, Number, Boolean......

### 4.10.4 内置构造函数:
#### 4.10.4.1 Object:
##### 4.10.4.1.1 静态方法 Object.keys() 
python的字典.keys()
##### 4.10.4.1.2 静态方法 Object.values()
python的字典.values()
##### 4.10.4.1.3 静态方法 Object.entries()
python的字典.entries()

只以entries为例,其余同理

!!! example
    === "代码"
      ```python
      const o = {name:"aaa",val: 12}
      Object.entries(o)[0][1]
      ```
    === "输出"

    'aaa'



##### 4.10.4.1.4静态方法 Object.assign()
对象拷贝

!!! example
    === "代码"
        ```javascript
        const o = {name:"aaa",val: 12}
        const oo = {age: 111}
        Object.assign(oo,o)
        console.log(oo)
        ```
    === "输出"
        { age: 111, name: 'aaa', val: 12 }
    

#### 4.10.4.2 Array:
可以new Array,也可以直接写数组

##### 4.10.4.2.1 forEach:
!!! example
    === "代码"
        ```javascript
        const a = [1,2,3,4]
        a.forEach((it) => {console.log(it)})
        ```
    === "输出"
        1
        2
        3
        4
##### 4.10.4.2.2 map:
!!! example
    === "代码"
        ```javascript
        const a = [1,2,3,4]
        const b = a.map(it=> it+1)
        console.log(b)
        ```
    === "输出"
        [2,3,4,5]
##### 4.10.4.2.3 filter:
!!! example
    === "代码"
        ```javascript
        const a = [1,2,3,4]
        const b = a.filter(it=> it % 2 == 0)
        console.log(b)
        ```
    === "输出"
        [2,4]
##### 4.10.4.2.4 reduce:
!!! example
    === "代码"

        ```javascript:
        const a = [1,2,3,4]
        const b = a.reduce((prev, curr) => prev + curr, 0)
        console.log(b)
        // arr.reduce(function(上一次的值,当前值){},初始值)
        ```
    === "输出"
        10 (10 = 0+1+2+3+4)



以下程序等价

!!! example
    === "javascript"
        const a = [1,2,3,4]
        const b = a.reduce((prev, curr) => prev + curr, 0)
        console.log(b)
    === "haskell"
        ```haskell
        -- haskell
        add::Int -> Int -> Int
        add a b = a + b
        foldr add 0 [1,2,3,4]
        ```
    === "python"
        ```python
        function add(a,b){
            return a + b
        }
        print([1,2,3,4,5].reduce(add, 0))
        ```
    === "输出"
        15



##### 4.10.4.2.5 join
和python的join差不多,但是反过来

!!! example
    === "javascript"
        ```javascript
        [1,2,3,4,5].join(",,,,,")
        ```
    === "python"
        ```python
        # python
        console.log((",,,,,").join(["1","2","3","4","5"]))
        ```
    === "输出
        '1,,,,,2,,,,,3,,,,,4,,,,,5'

##### 4.10.4.2.6 find
寻找第一个满足条件的元素,找不到返回undefined
!!! example
    === "代码"
        ```python
        // javascript
        console.log([1,2,3,4,5].find((it) => it % 6 == 0) == undefined)
        ```
    === "输出"
        true



##### 4.10.4.2.7 every
判断是否所有元素都满足条件

!!! example
    === "代码"
        ```javascript
        // javascript
        console.log([1,2,3,4,5].every((it) => it % 2 == 0))
        ```
    === "输出"

        false



##### 4.10.4.2.8 some
判断是否有元素满足条件
!!! example
    === "代码"
        ```javascript
        console.log([1,2,3,4,5].some((it) => it % 2 == 0))
        ```
    === "输出"
        true



##### 4.10.4.2.9 concat
拼接两个数组,会返回一个全新对象

!!! example
    === "代码"
        ```javascript
        console.log([1,2,3,4].concat([5,6,7]))
        ```
    === "输出"
        [1,2,3,4,5,6,7]

##### 4.10.4.2.10 sort
排序
!!! example
    === "代码"
        ```javascript
        console.log([4,2,3,1].sort())
        ```
    === "输出"
        [ 1, 2, 3, 4 ]

##### 4.10.4.2.11 reverse
翻转

!!! example
    === "代码"
        ```python
        // javascript
        console.log([1,2,3,4,5].reverse())
        ```
    === "输出"
        [ 5, 4, 3, 2, 1 ]

##### 4.10.4.2.12 findIndex

!!! example
    === "代码"
        ```javascript
        console.log([1,2,3,4,5].findIndex((it) => it== 2))
        ```
    === "输出"
        1
#### 4.10.4.3 String

##### 4.10.4.3.1 length

!!! example
    === "代码"
        ```python
        //javascript
        console.log("hello".length)
        ```
    === "输出"
        5



##### 4.10.4.3.2 split

!!! example
    === "代码"
        ```python
        //javascript
        console.log("hello".split("l"))
        ```
    === "输出"
        [ 'he', '', 'o' ]



##### 4.10.4.3.3 substring
获取从这个索引开始的子串,也可以
!!! example
    === "代码"
        ```javascript
        console.log("hello".substring(3))
        console.log("hello".substring(3,4))
        ```
    === "输出"
        'lo'
        'l'



##### 4.10.4.3.4 startsWith
判断字符串是否以这个子串开头

!!! example
    === "代码"
        ```javascript
        console.log("hello".startsWith("he"))
        ```
    === "输出"

        true



##### 4.10.4.3.5 includes
判断字符串是否包含这个子串

!!! example
    === "代码"
        ```javascript
        console.log("hello".includes("ll"))
        ```
    === "输出"
        true



##### 4.10.4.3.6 toUpperCase
全部转大写

!!! example
    === "代码"
      ```python
      //javascript
      console.log("hello".toUpperCase())
      ```

    === "输出"
        'HELLO'



##### 4.10.4.3.7 toLowerCase
全部转小写

!!! example
    === "代码"
        ```javascript
        console.log("HEllO".toLowerCase())
        ```
    === "输出"
        'hello'



##### 4.10.4.3.8 indexOf

!!! example
    === "代码"
        ```javascript
        console.log("Hello".indexOf("l"))
        ```
    === "输出"
        2



!!! example
    === "代码"
        ```javascript
        //javascript
        console.log("He111111o".indexOf("111"))
        ```
    === "输出"
        2



##### 4.10.4.3.9 replace

!!! example
    === "代码"
        ```javascript
        "Hello".replace("l","a")
        ```
    === "输出"
        'Healo'


用上正则

!!! example
    === "代码"
        ```javascript
        "He199o".replace(/[0-9]+/,"a")
        ```
    === "输出"
        'Heao'



##### 4.10.4.3.10 match

!!! example
    === "代码"

        ```javascript

        "Hello".match("l")

        ```
    === "输出"

        [ 'l', index: 2, input: 'Hello', groups: undefined ]



    
### 4.10.5 oop:
#### 4.10.5.1 构造函数:
通过构造函数实现封装
#### 4.10.5.2 原型:
构造函数通过圆形分配的函数所有该对象公用,可以节省内存

prototype是js对象的一个属性.只想另一个对象

这个对象可以挂载函数

原型对象里的this和构造函数里的this都指向实例化的对象

!!! example
    === "代码"
        ```javascript
        function Star(uname, age){
            this.uname = uname
            this.age = age
        }
        Star.prototype.sing = function(){
            console.log("sing")
        }
        const a = new Star("a",12)
        const b = new Star("b",13)
        console.log(a.sing == b.sing)
        // 方法公用
        ```
    === "输出"
        true
    

!!! example
    === "代码"
        ```python
        Array.prototype.sum = function(){
            return this.reduce((prev, item) => prev + item, 0)
        }
        const a = new Array(1,2,3)
        a.sum()
        ```
    === "输出"
        6



#### 4.10.5.3 constructor:
是个prototype的属性,指向原型对象的构造函数

!!! example
    === "代码"
        ```javascript
        function Star(){
        }
        console.log(Star.prototype.constructor)
        ```
    === "输出"
        [Function: Star]
    

!!! example
    === "代码"
        ```javascript
        console.log(Star.prototype.constructor)
        console.log("----------------------------")
        Star.prototype = {
            sing: function(){
                console.log("唱歌")
            },
            dance: function(){
                console.log("跳舞")
            }
        }

        console.log(Star.prototype.constructor)
        // 在赋值之后constructor消失
        ```
    === "输出"
        [Function: Star]
        ----------------------------
        [Function: Object]
    
同理

!!! example
    === "代码"
        ```python
        // 所以这样:
        console.log(Star.prototype.constructor)
        console.log("----------------------------")
        Star.prototype = {
            constructor: Star,
            sing: function(){
                console.log("唱歌")
            },
            dance: function(){
                console.log("跳舞")
            }
        }

        console.log(Star.prototype.constructor)
        // 再赋值之后constructor消失
        ```
    === "输出"
        [Function: Star]
        ----------------------------
        [Function: Star]
    

#### 4.10.5.4 对象原型__proto__
是js的非标准属性

[[Prototype]]和__proto__是一个意思

只读不改,

指向构造函数的原型对象,对象原型和原型对象在值上是一个东西

!!! example
    === "代码"
        ```javascript
        function Star(){
        }
        const a = new Star()
        console.log(a.__proto__.constructor)
        ```
    === "输出"
        [Function: Star]
    

#### 4.10.5.5 原型继承

!!! example
    === "代码"
        ```python
        function Human(){
            this.sense = 5
            this.head = 1
        }
        function Women(){
            this.sense = 6
        }
        function Men(){
        }
        Women.prototype = Human
        Women.prototype.constructor = Women
        Men.prototype = Human
        Men.prototype.constructor = Men
        const w = new Women()
        const m = new Men()
        console.log(w.sense)
        console.log(m.sense)
        ```
    === "输出"
        6
        undefined

!!! example
    === "代码"
        ```python
        function Human(){
            this.sense = 5
            this.head = 1
        }
        function Women(){
            this.sense = 6
        }
        function Men(){
        }
        Women.prototype = new Human()
        Women.prototype.constructor = Women
        Men.prototype = new Human()
        Men.prototype.constructor = Men
        const w = new Women()
        const m = new Men()
        console.log(w.sense)
        console.log(m.sense)
        // 这里两个对象是两个不同的对象
        ```
    === "输出"
        6
        5

#### 4.10.5.6 原型链:
相当于不断地继承关系

!!! example
    === "代码"
        ```javascript
        function Human(){
            
        }
        const a = new Human()
        console.log(Human.prototype.constructor)
        console.log(Human.prototype.__proto__.constructor)
        ```
    === "输出"
        [Function: Human]
        [Function: Object]
    

只要是对象就有__proto__指向原型对象

只要是原型对象就有consturctor

继承关系为所有->Object->null

访问一个对象的属性的时候首先查找自身,然后差上一层原型,一直查到Object为止,__proto__为null

可以使用instanceof判断prototype属性是否出现在摸个原形链上




## 4.11 深浅拷贝
这样只是设置了一个指针

!!! example
    === "代码"
        ```python
        const obj = {
            name: "aaa",
            age: 20
        }
        const o = obj
        o.age = 29
        console.log(obj.age)
        ```
    === "输出"
        29
    

### 4.11.1 浅拷贝
新建 一个对象,对于引用对象还是存一个指针,但是非引用对象正常

- Object.assign()
- {..obj}
- Array.prototype.concat()
- [..arr]




!!! example
    === "代码"
    ```javascript
    const obj = {
        name: "aaa",
        age: 20,
        family: {
        a: "a",
        b:"b"
        }
    }
    const o = {...obj}
    o.age=12
    console.log(obj)
    console.log(o)
    ```
    === "输出"
    { name: 'aaa', age: 20, family: { a: 'a', b: 'b' } }
    { name: 'aaa', age: 12, family: { a: 'a', b: 'b' } }
    

嵌套类的浅拷贝
!!! example
    === "代码"
        ```python
        const obj = {
            name: "aaa",
            age: 20,
            family: {
            a: "a",
            b:"b"
        }
        }
        const o = {...obj}
        o.family.a = "aksk"
        console.log(obj)
        console.log(o)
        ```
    === "输出"
        { name: 'aaa', age: 20, family: { a: 'aksk', b: 'b' } }
        { name: 'aaa', age: 20, family: { a: 'aksk', b: 'b' } }
    

### 4.11.2 深拷贝:
#### 4.11.2.1 递归

手搓
!!! example
    === "代码"
        ```python
        function deepcopy(o, obj){
            
            for (let k in Object.entries(obj)){
                if (obj[k] instanceof Array){
                    // 数组instanceof Object == true
                    
                    o[k] = []
                    deepcopy(o[k], obj[k])
                } else if (obj[k] instanceof Object){
                    o[k] = {}
                    deepcopy(o[k], obj[k])
                } else {
                    o[k] = obj[k]
                }
            }
        }
        ```
    

#### 4.11.2.2 lodash/cloneDeep
直接import lodash

<script src="
https://cdn.jsdelivr.net/npm/lodash@4.17.21/lodash.min.js
"></script>(建议cdn)

!!! example
    === "代码"
        ```javascript
            var objects = [{ 'a': 1 }, { 'b': 2 }];

            var deep = _.cloneDeep(objects);
            console.log(deep[0] === objects[0]);
        ```
    === "输出"
        true

#### 4.11.2.3 JSON.stringify
就是把json转成字符串

!!! example
    === "代码"
        ```python
        const obj = {
            name: "aaa",
            age: 20,
            family: {
            a: "a",
            b:"b"
        }
        }
        const o = JSON.parse(JSON.stringify(obj))
        // 里面那层是json-> str,然后parse: str -> json
        o.family.a = "aksk"
        console.log(obj)
        console.log(o)
        ```
    === "输出"
        { name: 'aaa', age: 20, family: { a: 'a', b: 'b' } }
        { name: 'aaa', age: 20, family: { a: 'aksk', b: 'b' } }
    

## 4.12 异常:
### 4.12.1 throw
和java一样, throw new Error()
### 4.12.2 try/catch
### 4.12.3 debugger:
带要调试的代码框里写debugger,然后在f12里调试

## 4.13 this:
!!! info
    === "说明"
        请自行查看<a href="https://github.com/everythingfades/html/blob/main/examples/js_involved/html/this.html">examples/js_involved/html/this.html</a>
### 4.13.1 普通函数:
谁调用指向谁

#### 4.13.1.1 箭头函数:
不存在this,获取最近可用作用域的this


#### 4.13.1.2 改变this:
!!! info
    === "说明"
        请自行查看<a href="https://github.com/everythingfades/html/blob/main/examples/js_involved/html/modifythis.html">examples/js_involved/html/modifythis.html</a>
##### 4.13.1.2.1 call()

```
fun.call(thisArg, arg1, arg2.....)
```
thisArg就是fun函数在运行的时候指定的this值

args1,2,3是正常fun的参数

返回值就是fun的返回值
##### 4.13.1.2.2 apply()


```
fun.apply(thisArgs,[argsArray])
```


相当于

```
fun.call(thisArgs, ...[argsArray])
```
##### 4.13.1.2.3 bind()
不会调用函数,但是可以改变this指向

```
fun.bind(thisArg, arg1, arg2.....)
```

## 4.14 防抖:
单位时间内频繁触发时间只执行最后一次, 回城,被打断重新来
### 4.14.1 lodash
```
_.debounce(fun, [wait = 0], [option = ])
```

### 4.14.2 手写:
!!! info
    === "说明"
        请自行查看<a href="https://github.com/everythingfades/html/blob/main/examples/js_involved/html/debounce.html">examples/js_involved/html/debounce.html

## 4.15 节流:
单位时间内,频繁出发时间,只执行一次,就是设置技能cd
!!! info
    === "说明"
        请自行查看<a href="https://github.com/everythingfades/html/blob/main/examples/js_involved/html/throttle.html">examples/js_involved/html/throttle.html
### 4.15.1 lodash
!!! info
    === "说明"
        请自行查看<a href="https://github.com/everythingfades/html/blob/main/examples/js_involved/html/lodash.html">examples/js_involved/html/lodash.html</a>
```
_.throttle(fun, [wait = 0], [option=])
```