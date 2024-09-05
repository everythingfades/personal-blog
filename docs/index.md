# 须知
## 简介:
本项目主要记录学习网页的相关笔记,会持续更新及修改

## 示例代码说明
本项目所有示例代码存在examples文件夹下,由于部分项目(vue,springboot)的项目无法在单个文件内展示,请自行安装环境并运行,在相应的地方会有示例文件路径

## 温馨提示:
### 1. jupyter notebook
jupyter notebook 自带python的%%html cell magic,但是由于jupyter notebook本身就是html网页,在其中配置css等会导致全局设置混乱,所以不推荐,如果必须在jupyter里运行可以自行查阅文档,每次更改css等设置的时候用完重置

### 2. wsl
不建议在wsl里运行vue,速度奇慢无比,而且由于不明原因,就算配置hot-reload的选项仍无法热更新,调试起来不方便

### 3.初始化vue
很多情况下环境出了问题都是没有

- npm install / npm i
- yarn install
- pnpm install
