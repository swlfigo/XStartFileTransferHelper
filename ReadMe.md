# XStartFileTransferHelper

项目 SDK 素材资源文件快速部署 MacOS 下的工具

#### Pure Swift 4.0 


![](http://okslxr2o0.bkt.clouddn.com/15314899403570.jpg)


工具可快速将新的素材文件复制到每个 app 项目文件素材文件夹中

# 使用方法:

1. 新素材文件夹中填写**整理后新的素材文件**文件夹,**按锁定路径**后,以后每次打开软件默认这个位置，不需要重新数据,下面锁定路径也是相同道理

2. SDK 的素材根目录 , 如 

```shell
xxxx/Resourse/ 各个app文件夹 / app文件夹中素材文件
``` 

**xxxx/Resourse/** 则为 SDK 素材根目录

3. 子目录, 如需要复制到

```shell
xxxx/Resourse/ 各个app文件夹 / app文件夹中素材文件夹 / 例如复制到这里
```
那么, 子目录就写 `xxx` 即可，如果有更深的目录只需要 `xxx/deeper folder / more deeper folder` 如此推类

