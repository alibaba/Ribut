# Visual Debug Arch

The visual debugging architecture is an end-to-end R&D efficiency improvement solution developed by the Alibaba Youku technical team. In addition to the client SDK, it also provides RibutApp with Mac and Windows versions to support network packet capture, network Mock, sandbox Box browsing, custom plug-in extensions, RibutApp's goal is to help R&D students solve daily pain points through tool-based means

# Function introduction

1. Network packet capture: It has a PC-side visual interface display, no need to configure an agent, and zero operation cost to capture packets.   
2. Network Mock: A convenient Mock tool, operated on the Mac visual interface, one-click Mock, easy to operate.    
3. Sandbox directory browsing: View the sandbox directory with one click, and you can quickly import the data of the sandbox directory to the computer.   
4. Dynamic configuration capability: easy to expand, the business can quickly access Ribut according to its own business, and display its own business data on the PC side

# access

## Version requirements

iOS 9.0 and above 

Android version 7.0 and above

## import dependencies

#### iOS

> ```objective-c
> pod  'AliRibutSDK'   
> ```
>
> It is recommended to update the latest version of Ribut, now the latest version: 1.0.4.2.

#### Android

>```java
>implementation project(':RibutSDK')
>```
>
>It is recommended to use source code dependencies directly

## Get Started

#### establish connection

* Ribut establishes a connection by scanning the code and must rely on the scanning code library

* Obtain Ribut's IP and port number to establish a link by parsing the scanned code

  * Scan code content：ribut://ribut?url=ws%3A%2F%2F30.77.74.203%3A5622，ribut做了ip端口号encode 

* Send notification to establish connection

  * Dictionary data structure: url does not need to be decoded, it will be automatically decoded internally, and it can be directly used as a notification parameter
  * params = {"url":"ws%3A%2F%2F30.77.74.203%3A5622"}

* connection code

  * iOS	

    ```objective-c
     [[NSNotificationCenter defaultCenter] postNotificationName:AliRibutConnectNotification object:nil userInfo:params];
    ```

  - Android 

    ```java
    AliRibutManager.getInstance().connectWithUrl(url, MainActivity.this);
    ```

    

​	For more information, see the Demo project.

## Run Demo

#### iOS

After clone, go to the project directory 'pod update', and then open the demo workspace to run.

#### Android 

After clone, import RibutAndroidDemo with AndroidStudio to run

# author

微笑、棋纬

# license

AliRibutSDK is a Tool developed by Alibaba and licensed under the Apache License (Version 2.0) This product contains various third-party components under other open source licenses.

