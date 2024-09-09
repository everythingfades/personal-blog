# 6. API BOM
## 6.1 BOM:
Browser Object Model

浏览期内部最主要的元素就是window,window下又有这么几个东西

$\text{window}\begin{cases}
\text{navigator}\\
\text{location}\\
\text{document}\\
\text{history}\\
\text{screen}
\end{cases}$

document, alert(), console.log()等都是window的属性,基本BOM的属性和方法都是window的

在window对象下的属性和方法调用的时候可以省略window

## 6.2 定时器-延时函数:
!!! example
    === "代码"
        ```javascript
        setTimeout(回调函数, 等待的毫秒数)
        ```
    === "效果"
        请自行查看[examples/js_involved/html/setTimeout.html]

是一次性的


清除延时函数:

!!! example
    === "代码"
        ```javascript
        let timer = setTimeout(回调函数, 等待的毫秒数)
        clearTimeout(timer)
        ```

- 延时器需要等待所以后面的代码先执行
- 每次调用演示器都会产生一个新的延时器

## 6.3 js执行机制:
事件循环

单线程,于是有了同步和异步
- 异步任务:
  - 普通事件: click resize
  - 资源加载: load error
  - 定时器: setInterval, setTimeout
- 同步任务:
  - 基本上就是其他
  
 
先执行同步任务,然后异步任务排队,然后执行完所有同步任务之后执行队列里的异步任务,等时间到了放入执行栈里执行,不断循环


## 6.4 各种对象
### 6.4.1 location 对象:
location本身是个对象,可以获取一些属性

- href: 当前网页的url,可以用于跳转页面,只需要更改href就可以跳转页面
- search: post方法穿的参数,但是是字符串格式,获取问号后面的东西
- hash: 同上,但是是井号后面的东西
- reload(): 刷新页面

### 6.4.2 navigator 对象:
获取浏览器相关信息:

- userAgent: 获取当前浏览器,可以判断是否是手机端页面


### 6.4.3 history对象:
一般来说就是

- forward() 前进
- back() 后退
- go(1) 1为前进,-1为后退

## 6.5 本地储存:

就是把数据直接存进浏览器,这样更改网页内容的时候,本地数据不会被改动

### 6.5.1 localStorage:
永久性的把数据存储进浏览器中

可以多窗口共享:

#### 6.5.1.1 存储:
!!! example
    === "代码"
        ```javascript
        localStorage.setItem(key,value)
        ```
只能存字符串,如果存其他复杂数据类型则无法直接使用, 需要把字符串存成对象的字符串(JSON.stringify())


可以用JSON.parse()从字符串转换成Json,

#### 6.5.1.2 获取:
!!! example
    === "代码"
        ```javascript
        localStorage.getItem(key)
        ```

### 6.5.2sessionStorage:
生命周期为关闭浏览器窗口

在同一个页面下数据可以共享

以键值对的形式存储使用

用法和localStorage基本相同



[examples/js_involved/html/setTimeout.html]: https://github.com/everythingfades/html/blob/main/examples/js_involved/html/setTimeout.html
