# DDNetCheck

iOS手机网络状态检测，该工具已适配[DDKitSwift](https://github.com/DamonHu/DDKitSwift)。

## 功能介绍

网络请求时，可能会因为手机设备或者网站故障导致请求失败，该工具可以检测手机设备的网络状况、网站访问状况和ping值、访问苹果官网测试等多个维度判断是用户设备问题，还是服务器问题。

### 用户设备状态检测

检测网络wifi/蜂窝网络，ipv4/ipv6访问，DNS解析问题，代理/VPN的配置，是否开启低数据模式。

### 网站检测

模拟访问网站，发起ping请求测试网速

### 参考网站测试

模拟访问apple.com、baidu.com、aliyun.com等多个网站，测试手机是否可以正常请求。

## 使用

### CocoaPods

```
pod 'DDNetCheck'
```

### 开启测试

```
let tool = DDNetCheck()
tool.showVC(url: "https://www.yechan.cn")
```

### 关闭

```
tool.hideVC()
```

## 其他

如果你需要自己控制VC，可以使用`DDNetCheckVC`，例如

```
let vc = DDNetCheckVC(url: "https://www.yechan.cn")
vc.modalPresentationStyle = .fullScreen
self.present(vc, animated: true)
```
