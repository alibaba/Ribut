# 可视化调试架构

可视化调试架构是阿里巴巴优酷技术团队研发的一套端到端的研发提效解决方案，除了客户端SDK之外，还提供了配套了Mac和Windows版本的RibutApp，支持网络抓包、网络Mock、沙盒浏览，自定义插件扩展，RibutApp的目标是通过工具化手段，切实帮助广大研发同学解决日常痛点问题

# 可视化调试功能演示
![可视化架构演示](https://user-images.githubusercontent.com/5511525/158571609-1ad1402f-3655-416c-8371-51f6f491d470.gif)
# 功能简介

1. 网络抓包：拥有PC端可视化界面展示、无需配置代理，零操作成本抓包。   

2. 网络Mock：便捷Mock工具，在PC可视化界面操作，一键Mock，易操作。    

3. 沙盒目录浏览：一键查看沙盒目录，可以把沙盒目录的数据快速导入到电脑上。      

4. 动态配置能力：易扩展，业务可根据自身业务，快速接入Ribut，在PC端展示自己的业务数据

# 文档
[可视化调试架构接入文档](https://www.yuque.com/u729598/ly5793)


# 安装App工具

1. 找到RibutApp目录
2. Mac找到Ribut-3.0.0-mac.z01文件解压安装，Windows找到Ribut-3.0.0-windows.z01文件解压安装



# 接入

## 版本要求

iOS 9.0及以上

Android 7.0版本及以上

## 接入

#### iOS

> ```objective-c
> pod  'AliRibutSDK'  
> ```
>
> 推荐更新使用最新版本Ribut，现最新版本：1.0.4.2。

#### Android

>```java
>implementation project(':RibutSDK')
>```
>
>推荐直接使用源码依赖

## Get Started

#### 建立连接

* Ribut通过扫码建立连接，必须依赖扫码库

* 通过解析扫码内容，获取Ribut的iP和端口号建立链路

  * 扫码内容：ribut://ribut?url=ws%3A%2F%2F30.77.74.203%3A5622，ribut做了ip端口号encode 

* 发送通知建立连接

  * 字典数据结构：url不需要decode，内部会自动decode，直接作为通知参数即可
  * params = {"url":"ws%3A%2F%2F30.77.74.203%3A5622"}

* 建立连接代码

  * iOS	

    ```objective-c
     [[NSNotificationCenter defaultCenter] postNotificationName:AliRibutConnectNotification object:nil userInfo:params];
    ```

  - Android 

    ```java
    //建立连接
    AliRibutManager.getInstance().connectWithUrl(url, MainActivity.this);
    ```

    

​	更多参见Demo工程。

## 运行Demo

#### iOS

clone后在工程目录'pod update'，完成后即可打开demo workspace运行。

#### Android 

clone后用AndroidStudio导入RibutAndroidDemo可运行

# 作者

微笑、棋纬

# 许可证

AliRibutSDK is a Tool developed by Alibaba and licensed under the Apache License (Version 2.0) This product contains various third-party components under other open source licenses.
