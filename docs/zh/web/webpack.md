# 9. webpack:


这部分其实也挺抽象的,也没什么大用,vue里打包都是直接npm/yarn/pnpm build,实在不行可以跳过

打包工具,
- 把less.sass转成css
- ES6降级乘ES5
- 支持多种标准

安装:


!!! example 
    === "代码"
        ```bash
        npm i webpack webpack-cli --save-dev
        ```

还要在package.json的scripts里加上build:webpack

!!! example
    === "代码"
        ```json
        "scripts": {
            "build": "webpack"
        }
        ```

之后

!!! example
    === "代码"
        ```bash
        npm run build
        ```

和gradle一样建立环境,打包输出到dist文件夹

如果是vue,这些基本上都不用管,创建项目的时候会自动写好

## 9.1 修改webpack打包入口和出口
新建webpack.config.js

!!! example
    === "代码"
        ```javascript
        const path = require("path")

        module.exports = {
            entry: path.resolve(__dirname, "./src/login/index"),
            output: {
                path: path.resolve(__dirname, "dist"),
                filename: "./login/index.js",
            }
        }
        ```

## 9.2 webpack自动生成html

先装包

!!! example
    === "代码"
        ```bash
        npm i html-webpack-plugin --save-dev
        ```

在webpack.config.js里加入plugin属性

!!! info
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/example/webpack.config.js">examples/webpack/example/webpack.config.js</a> 的plugin里的htmlWebpack部分
## 9.3 打包css
加载器css-loader: 解析css代码

加载器style-loader: 插入到DOM中

!!! example
    === "代码"
        ```javascript
        module.exports = {
            module: {
                rules: [
                    {
                        test: /\.css$/i,
                        use: ["style-loader", "css-loader"]
                    }
                ]
            }
        }
        ```
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/example/webpack.config.js">examples/webpack/example/webpack.config.js</a> 的plugin里的rules部分

### 9.3.1 提取css
css可以被浏览器缓存,减少js文件体积

mini-css-extract-plugin: 提取css代码

这个和style-loader不能一起使用

和上面那个写在一起

#### 9.3.1.1 压缩css
上述方法提取的css没有被压缩,

需要插件:css-minimizer-webpack-plugin插件

需要

!!! example
    === "代码"
        ```javascript
        const CssMinimizerPlugin = require("css-minimizer-webpack-plugin")

        optimization: {
            minimizer: [
                // 在webpack@5中可以使用 ... 语法扩展现有的minimizer(即
                // terser-webpack-plugin插件),讲下一行的取消注释(保证JS代码还能被压缩)
                // `...`,
                new CssMinimizerPlugin(),
            ]
        }
        ```
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/example/webpack.config.js">examples/webpack/example/webpack.config.js</a> 的plugin里的optimization部分

## 9.4 打包less:

!!! example
    === "代码"
        ```javascript
        {
            test: /\.less$/i,
            use: [
                'style-loader',
                'css-loader',
                'less-loader',
            ],
        }
        ```
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/example/webpack.config.js">examples/webpack/example/webpack.config.js</a> 的plugin里的rules部分


## 9.5 打包图片:
webpack5自带内置资源模块(字体,图片等),不需要另加loader

!!! example
    === "代码"
        ```javascript
        {
            test: /\.{png|jpg|jpeg|gif}$/i,
            type: 'asset',
            generator: {
            filename:'assets/[hash][ext][query]'}
        }
        ```
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/example/webpack.config.js">examples/webpack/example/webpack.config.js</a> 的plugin里的rules部分

判断临界值默认为8kB

大于8kb会发送一个单独的文字并导出URL地址

小于8KB会导出一个data URI

## 9.6 Webpack搭建开发环境
用webpack-dev-server

启动web服务,自动检测代码变化,热更行到网页,更新是在内存里(速度快)

配置
!!! example
    === "代码1"
      ```javascript
      {
          devServer: {
              false; //不允许从目录提供静态文件
          }
      }
      ```
    === "代码2"

      ```javascript
      {
          devServer: {
              static:true; //允许从目录提供静态文件,默认是public文件
          }
      }
      ```
    === "代码3"

      ```javascript
      {
          devServer{
              static: ["assets"] // 文件夹的名字
          }
      }
      ```
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/03_Webpack_Study/webpack.config.js">examples/webpack/03_Webpack_Study/webpack.config.js 的plugin里的devServer部分

需要设定模式为开发模式
!!! example
    === "代码"
      ```javascript
      module.exports = {
          mode: "development"
      }
      ```

配置自定义命令:(可选)
!!! example
    === "代码"
        ```javascript
        "script": {
            "build": "webpack",
            "dev" : "webpack serve --open"
        }
        ```
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/03_Webpack_Study/package.json">examples/webpack/03_Webpack_Study/package.json</a>

这个会根据配置,打包相关的资源在内存里作为服务器的根目录,默认会以public作为根目录

可以写一个html用location.href自动跳转

## 9.7 打包优化:
|模式名称|模式名字|特点|场景|
|-|-|-|-|
|开发模式|development|调试代码,实时热替换|本地开发|
|开发模式|production|压缩代码,资源优化|打包上线|


设置方式1: 在webpack.config.js配置文件设置mdoe选项

设置方式2: 在package.json命令行设置mode参数

(注意:命令行的优先级大于配置文件)

## 9.8 打包模式的应用:
问题: 在开发模式下用style-loader更快,再生产模式下提取css代码
- 方案1: webpack.config.js配置导出函数,但是局限性大(只接受两种模式)
- 方案2: 家住cross-dev(跨平台通用)报名领,设置参数区分环境

先装包
!!! example
    === "代码"
        ```bash
        npm i cross-env --save-dev
        ```

配置自定义参数(参数会绑定到proces.env对象下)

!!! example
    === "代码"
        ```javascript
        "scripts": {
            "test": "echo \"Error: no test specified\" && exit 1",
            "build": "cross-env NODE_ENV=production webpack --mode=production",
            "dev": "cross-env NODE_ENV=development webpack serve --open --mode=development"
          },
        ```
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/03_Webpack_Study/package.json">examples/webpack/03_Webpack_Study/package.json</a>

webpack.config.js中区分不同环境使用不同配置

NODE_ENV中的模式和webpack的打包模式没有任何关系

这个值可以在node.js环境中通过process.env访问但是前端代码无法访问process.env.NODE_ENV



## 9.9 注入环境变量
新插件DefinePlugin

一个CLI工具,就是把DefinePlugin对象里的所有属性添加到命令后运行
!!! example
    === "webpack.config.js代码"
        ```javascript
        //webpack.config.js
        new webpack.DefinePlugin({
            'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV)
        })
        ```
    === "后续调用"

        ```javascript
        // 其他js
        process.env.NODE_ENV...
        ```
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/03_Webpack_Study/webpack.config.js">examples/webpack/03_Webpack_Study/webpack.config.js</a>的plugin部分

## 9.10 调错source map,

!!! example
    === "代码"
        ```javascript
        module.export = {
            devtool: "inline-source-map"
        }
        ```
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/03_Webpack_Study/webpack.config.js">examples/webpack/example/webpack.config.js</a> 的devtool

这个应该只在开发模式下生效,因为你肯定不希望其他人看到js代码

## 9.11 解析别名alias
解析别名

把相对路径在打包的时候改成绝对路径

!!! example
    === "代码"
        ```javascript
        // webpack.config.js
        const config = {
            resolve:{
                alias:{
                    "@": path.resolve(__dirname, "src")
                }
            }
        }
        ```
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/03_Webpack_Study/webpack.config.js">examples/webpack/03_Webpack_Study/webpack.config.js</a> 的resolve部分


## 9.12 使用CDN
把静态资源文件/第三方库放在CDN网络各个服务器中,

开发模式使用本地第三方库, 生产模式下使用CDN加载引入

- html下引用第三方库的CDN地址,在html中加入判断

```html
<% if(htmlwebpackPlugin.option.useCdn){%>
    <link href="cdn地址">
<%} %>
```

- 配置webpack.config.js的externals外部扩展选项防止某些import的包背打包

```javascript
{
    externals: {
        "axios": "axios"
        // 这里key是import .. from 语句后面的字符串
        // value
    }
}
```

例:
!!! example
    === "代码"
      ```javascript
      config.externels = {
          "bootstrap/dist/css/bootstrap.css": "bootstrap",
          // import "bootstrap/dist/css/bootstrap.min.css"
          "axios": "axios",
          // import axios from "axios"
      }
      ```

+

!!! example
    === "代码"
        ```javascript
        {
            plugins: [
                new HtmlWebpackPlugin({
                    useCdn: process.env.NODE_ENV === "production"
                })
            ]
        }
        ```

!!! info
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/03_Webpack_Study/webpack.config.js">examples/webpack/03_Webpack_Study/webpack.config.js</a>

然后可以添加useCdn变量

!!! example
    === "代码"
        ```javascript
        plugins: [
                new HtmlWebpackPlugin({
                    template: path.resolve(__dirname, "public/login.html"),
                    filename: path.resolve(__dirname, "dist/login/index.html"),
                    useCdn: process.env.NODE_ENV === "production"
                }),
            ]
        ```
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/03_Webpack_Study/webpack.config.js">examples/webpack/03_Webpack_Study/webpack.config.js</a> 的plugin

## 9.13 多页面打包:
- 单页面: 单个html文件, 切换DOM实现效果
- 多页面: 多个html文件, 切换页面实现业务逻辑

步骤:
- 准备源码(html,css,js)
- 下载form-serialize(应该是可选的)导入到核心代码中
- 配置webpack.config.js多入口(entry),和多页面的设置

例:
!!! example
    === "代码"
        ```javascript
        const config = {
            entry: {
                "模块名1": path.resolve(__dirname, "src/入口1.js"),
                "模块名2": path.resolve(__dirname, "src/入口2.js"),
            },
            output: {
                path: path.resolve(__dirname, "dist")
                filename: "/[name]/index.js"//这里的name会自动替换成模块名
            },
            plugins: [
                new HtmlWebpackPlugin({
                    template: "./public/页面2.html",
                    filename: "./路径/index.html",
                    chunks: ["模块名1"] // 对应上面的模块名
                }),
                new HtmlWebpackPlugin({
                    template: "./public/页面2.html",
                    filename: "./路径/index.html",
                    chunks: ["模块名1"] // 对应上面的模块名
                })
            ],
        
        }
        ```
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/03_Webpack_Study/webpack.config.js">examples/webpack/example/webpack.config.js</a>

## 9.14 splitChunks:分割公共代码:

!!! example
    === "代码"
        ```javascript
        const config = {
            optimization: {
                splitChunks: {
                    chunks: 'all', // 所有模块动态非动态移入的都分割分析
                    cacheGroups: { // 分隔组
                      commons: { // 抽取公共模块
                      minSize: 0, // 抽取的chunk最小大小字节
                      minChunks: 2, // 最小引用数
                      reuseExistingChunk: true, // 当前 chunk 包含已从主 bundle 中拆分出的模块，则它将被重用
                      name(module, chunks, cacheGroupKey) { // 分离出模块文件名
                          const allChunksNames = chunks.map((item) => item.name).join('~') // 模块名1~模块名2
                          return `./js/${allChunksNames}` // 输出到 dist 目录下位置
                  }
                }
              }
            }
          }
        }
        ```
    === "说明"
        这部分可以看<a href="https://github.com/everythingfades/html/blob/main/examples/webpack/03_Webpack_Study/webpack.config.js">examples/webpack/example/webpack.config.js</a> 的最后splitChunks部分