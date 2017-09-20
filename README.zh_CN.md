# Perfect INI File Parser

<p align="center">
    <a href="http://perfect.org/get-involved.html" target="_blank">
        <img src="http://perfect.org/assets/github/perfect_github_2_0_0.jpg" alt="Get Involed with Perfect!" width="854" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/PerfectlySoft/Perfect" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_1_Star.jpg" alt="Star Perfect On Github" />
    </a>  
    <a href="http://stackoverflow.com/questions/tagged/perfect" target="_blank">
        <img src="http://www.perfect.org/github/perfect_gh_button_2_SO.jpg" alt="Stack Overflow" />
    </a>  
    <a href="https://twitter.com/perfectlysoft" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_3_twit.jpg" alt="Follow Perfect on Twitter" />
    </a>  
    <a href="http://perfect.ly" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_4_slack.jpg" alt="Join the Perfect Slack" />
    </a>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat" alt="Swift 4.0">
        <img src="https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat" alt="Swift 3.1">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms OS X | Linux">
    </a>
    <a href="http://perfect.org/licensing.html" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License Apache">
    </a>
    <a href="http://twitter.com/PerfectlySoft" target="_blank">
        <img src="https://img.shields.io/badge/Twitter-@PerfectlySoft-blue.svg?style=flat" alt="PerfectlySoft Twitter">
    </a>
    <a href="http://perfect.ly" target="_blank">
        <img src="http://perfect.ly/badge.svg" alt="Slack Status">
    </a>
</p>

本项目是一个简单的[INI文件](http://baike.baidu.com/item/ini文件)解析器。

本项目采用Swift 3.1 工具链中的SPM软件包管理器编译，是[Perfect](https://github.com/PerfectlySoft/Perfect) 项目的一部分，但也可以作为独立模块使用。

## 快速上手

配置 Package.swift 文件：

如果使用 Swift 3.1:

``` swift
.Package(url: "https://github.com/PerfectlySoft/Perfect-INIParser.git", majorVersion: 1)
```

如果使用 Swift 4.0:

``` swift
.package(url: "https://github.com/PerfectlySoft/Perfect-INIParser.git", from: "1.0.0")

...

.target( name: "YourProjectName",
	dependencies: ["INIParser"]),
	
``` 

导入函数库：

``` swift
import INIParser
```

加载文件并解析为`INIParser` 对象：

``` swift
let ini = try INIParser("/path/to/somefile.ini")
```

这样就可以读取具体的变量了。

### 分节变量：

对于多数常规分节变量来说，可以使用该对象的`sections`属性进行读取，比如对于某节内容下的变量：

```
[GroupA]
myVariable = myValue
```

此时使用语句 `let v = ini.sections["[GroupA]"]?["myVariable"]` 可以得到字符串值 `"myValue"`.

### 无章节变量

但对于某些INI文件中不存在具体的分节，而是把所有变量都放在了一起，比如：

```
freeVar1 = 1
```

此时，调用匿名章节属性 `anonymousSection`即可获取变量值：

```
let v = ini.anonymousSection["freeVar1"]
```

## 问题报告、内容贡献和客户支持

我们目前正在过渡到使用JIRA来处理所有源代码资源合并申请、修复漏洞以及其它有关问题。因此，GitHub 的“issues”问题报告功能已经被禁用了。

如果您发现了问题，或者希望为改进本文提供意见和建议，[请在这里指出](http://jira.perfect.org:8080/servicedesk/customer/portal/1).

在您开始之前，请参阅[目前待解决的问题清单](http://jira.perfect.org:8080/projects/ISS/issues).


## 更多信息
关于本项目更多内容，请参考[perfect.org](http://perfect.org).


## 扫一扫 Perfect 官网微信号
<p align=center><img src="https://raw.githubusercontent.com/PerfectExamples/Perfect-Cloudinary-ImageUploader-Demo/master/qr.png"></p>