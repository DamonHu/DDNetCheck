//
//  DDNetCheck.swift
//  DDNetCheck
//
//  Created by Damon on 2025/4/5.
//

import UIKit
import Network
import DDPingTools

public enum DDNetCheckType: CaseIterable {
    case notAvailable       //未联网
    case wifi           //是否是wifi类型
    case dns            //DNS状态
    case ipv4           //是否支持ipv4
    case ipv6           //是否支持ipv6
    case isConstrained  //是否在低数据模式或者省电或节省流量的受限模式
    case isConnected    //是否可以链接
    case appleServerConnected    //苹果服务器响应
    case ping           //ping速度
    case appleServerPing    //苹果服务器响应
}

open class DDNetCheck: NSObject {
    private var monitor: NWPathMonitor?
    private var url: String
    private var pingTools: DDPingTools?
    private var applePingTools: DDPingTools?
    
    public init(url: String) {
        self.url = url
        self.pingTools = DDPingTools(url: URL(string: url))
        self.pingTools?.showNetworkActivityIndicator = .none
        self.pingTools?.debugLog = false
        self.applePingTools = DDPingTools(url: URL(string: "https://www.apple.com"))
        self.applePingTools?.showNetworkActivityIndicator = .none
        self.applePingTools?.debugLog = false
        super.init()
    }
}

extension DDNetCheck {
    public func checkNetStatus(completion:  @escaping (DDNetCheckType, Bool) -> Void) {
        self.stop()
        
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("✅ 设备连接了网络")
                if path.supportsDNS {
                    print("✅ DNS 解析正常")
                    completion(.dns, true)
                } else {
                    print("❌ DNS 解析失败")
                    completion(.dns, false)
                }

                if path.isExpensive {
                    print("⚠️ 当前使用蜂窝数据或热点")
                } else {
                    print("✅ 使用 Wi-Fi 或有线网络")
                }
                //网络类型
                if path.usesInterfaceType(.wifi) {
                    print("⚠️ 当前使用wifi")
                    completion(.wifi, true)
                } else if path.usesInterfaceType(.cellular) {
                    print("⚠️ 当前使用蜂窝数据")
                    completion(.wifi, false)
                }
                //IPV4
                if path.supportsIPv4 {
                    completion(.ipv4, true)
                } else {
                    completion(.ipv4, false)
                }
                if path.supportsIPv6 {
                    completion(.ipv6, true)
                } else {
                    completion(.ipv6, false)
                }
                //是否受限
                if path.isConstrained {
                    completion(.isConstrained, true)
                } else {
                    completion(.isConstrained, false)
                }
                
                // 额外测试是否能访问外网
                self._checkInternetConnection(url: self.url) { isConnected in
                    completion(.isConnected, isConnected)
                }
                self._checkInternetConnection(url: "https://www.apple.com") { isConnected in
                    completion(.appleServerConnected, isConnected)
                }
            } else {
                print("❌ 设备未连接网络")
                completion(.notAvailable, false)
            }
        }
        monitor?.start(queue: DispatchQueue.global(qos: .background))
    }
    
    public func ping(complete: @escaping (DDNetCheckType, DDPingResponse?, Error?) -> Void) {
        self.pingTools?.start(pingType: .any, interval: .millisecond(5000), complete: { response, error in
            complete(.ping, response, error)
        })
        
        self.applePingTools?.start(pingType:.any, interval: .millisecond(5000), complete: { response, error in
            complete(.appleServerPing, response, error)
        })
    }
    
    public func stop() {
        monitor?.cancel()
        self.pingTools?.stop()
        self.applePingTools?.stop()
    }
}

private extension DDNetCheck {
    func _checkInternetConnection(url: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: url) else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
}
