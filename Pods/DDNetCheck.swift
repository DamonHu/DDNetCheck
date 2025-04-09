//
//  DDNetCheck.swift
//  DDNetCheck
//
//  Created by Damon on 2025/4/5.
//

import UIKit
import Network
import DDPingTools

//设备检测
public enum DDNetCheckType: CaseIterable {
    case isNotConstrained  //是否在低数据模式或者省电或节省流量的受限模式
    case dns            //DNS状态
    case wifi           //是否是wifi类型
    case cellular       //是否是蜂窝网络
    case notProxy          //代理
    case notVPN            //vpn
    case ipv4           //是否支持ipv4
    case ipv6           //是否支持ipv6
}

//网站监测
public enum NetworkStatus {
    case success
    case noConnection
    case timeout
    case dnsError
    case sslError
    case serverError(Int)
    case unknownError
}

public extension NetworkStatus {
    func reason() -> String {
        switch self {
        case .success:
            return "Success".ZXLocaleString
        case .noConnection:
            return "Device Not Connected to Network".ZXLocaleString
        case .timeout:
            return "Request Timed Out".ZXLocaleString
        case .dnsError:
            return "DNS Resolution Error".ZXLocaleString
        case .sslError:
            return "SSL Certificate Error".ZXLocaleString
        case .serverError(let int):
            return "Abnormal Server Response".ZXLocaleString + ",code: \(int)"
        case .unknownError:
            return "Unknown Server Error".ZXLocaleString
        }
    }
}

open class DDNetCheck: NSObject {
    private var monitor: NWPathMonitor?
    private var pingTools: [DDPingTools] = []
    private var mNetCheckVC: DDNetCheckVC?
    
    public static let shared = DDNetCheck()
}

extension DDNetCheck {
    public func checkPlatform(completion:  @escaping (DDNetCheckType, Bool) -> Void) {
        //VPN监测
        completion(.notVPN, !self.isVPNActive())
        //设备信息
        monitor?.cancel()
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { path in
            if path.status == .satisfied {
                if path.supportsDNS {
                    completion(.dns, true)
                } else {
                    completion(.dns, false)
                }
                //网络类型
                if path.usesInterfaceType(.wifi) {
                    completion(.wifi, true)
                } else {
                    completion(.wifi, false)
                }
                if path.usesInterfaceType(.cellular) {
                    completion(.cellular, true)
                } else {
                    completion(.cellular, false)
                }
                if path.usesInterfaceType(.other) {
                    completion(.notProxy, false)
                } else {
                    completion(.notProxy, true)
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
                if #available(iOS 13.0, *) {
                    if path.isConstrained {
                        completion(.isNotConstrained, false)
                    } else {
                        completion(.isNotConstrained, true)
                    }
                } else {
                    completion(.isNotConstrained, true)
                }
            } else {
                for type in DDNetCheckType.allCases {
                    completion(type, false)
                }
            }
        }
        monitor?.start(queue: DispatchQueue.global(qos: .background))
    }
    
    ///服务器状态
    func checkServer(url: URL?, timeout: TimeInterval = 10, completion: @escaping (NetworkStatus) -> Void) {
        guard let url = url else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error as? URLError {
                switch error.code {
                case .notConnectedToInternet:
                    completion(.noConnection)
                case .timedOut:
                    completion(.timeout)
                case .cannotFindHost, .dnsLookupFailed:
                    completion(.dnsError)
                case .secureConnectionFailed, .serverCertificateUntrusted,
                        .serverCertificateHasBadDate, .serverCertificateHasUnknownRoot:
                    completion(.sslError)
                default:
                    completion(.unknownError)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.unknownError)
                return
            }
            
            if httpResponse.statusCode == 200 {
                completion(.success)
            } else {
                completion(.serverError(httpResponse.statusCode))
            }
        }
        
        task.resume()
    }
    
    ///服务器速度
    public func ping(url: String, complete: @escaping PingComplete) {
        let pingTool = DDPingTools(url: URL(string: url))
        pingTool.showNetworkActivityIndicator = .none
        pingTool.debugLog = false
        pingTool.start(pingType: .any, interval: .millisecond(5000), complete: { response, error in
            complete(response, error)
        })
        self.pingTools.append(pingTool)
    }
    
    public func stop() {
        monitor?.cancel()
        for pingTool in self.pingTools {
            pingTool.stop()
        }
        self.pingTools.removeAll()
    }
    
    public func showVC(url: String) {
        self.mNetCheckVC = DDNetCheckVC(url: url)
        let vc = self.mNetCheckVC!
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        navigationVC.navigationBar.barTintColor = UIColor.white
        //set title
        let view = UIView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = NSAttributedString(string: "Net check".ZXLocaleString, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 18, weight: .medium), NSAttributedString.Key.foregroundColor:UIColor.black])
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        vc.navigationItem.titleView = view
        //navigationBar
        let button = UIButton(frame: .init(x: 0, y: 0, width: 25, height: 25))
        button.setImage(UIImageHDBoundle(named: "log_icon_close"), for: .normal)
        button.addTarget(self, action: #selector(_closeBarItemClick), for: .touchUpInside)
        NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25).isActive = true
        NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25).isActive = true
        let leftbarItem = UIBarButtonItem(customView: button)
        vc.navigationItem.leftBarButtonItems = [leftbarItem]
        
        self.getCurrentVC()?.present(navigationVC, animated: true)
    }
    
    public func hideVC() {
        guard let vc = self.mNetCheckVC else { return }
        
        if let nav = vc.navigationController {
            nav.dismiss(animated: true)
        } else {
            vc.dismiss(animated: true)
        }
    }
}

private extension DDNetCheck {
    /// 判断当前是否处于 VPN 连接状态
    func isVPNActive() -> Bool {
        guard let cfDict = CFNetworkCopySystemProxySettings(),
              let nsDict = cfDict.takeRetainedValue() as? [String: Any],
              let scopes = nsDict["__SCOPED__"] as? [String: Any] else {
            return false
        }
        for key in scopes.keys {
            if key.starts(with: "tap") || key.starts(with: "tun") ||
                key.starts(with: "ppp") || key.starts(with: "ipsec") ||
                key.starts(with: "utun") {
                return true
            }
        }
        return false
    }
    
    @objc func _closeBarItemClick() {
        self.hideVC()
    }
    
    ///获取当前的normalwindow
    func getCurrentNormalWindow() -> UIWindow? {
        var window:UIWindow? = UIApplication.shared.keyWindow
        if #available(iOS 13.0, *) {
            for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as? Set<UIWindowScene>)!) {
                if windowScene.activationState == .foregroundActive {
                    window = windowScene.windows.first
                    for tmpWin in windowScene.windows {
                        if tmpWin.windowLevel == .normal {
                            window = tmpWin
                            break
                        }
                    }
                    break
                }
            }
        }
        if window == nil || window?.windowLevel != UIWindow.Level.normal {
            for tmpWin in UIApplication.shared.windows {
                if tmpWin.windowLevel == UIWindow.Level.normal {
                    window = tmpWin
                    break
                }
            }
        }
        return window
    }
    
    ///获取当前显示的vc
    func getCurrentVC(ignoreChildren: Bool = true) -> UIViewController? {
        let currentWindow = self.getCurrentNormalWindow()
        guard let window = currentWindow else { return nil }
        var vc: UIViewController?
        let frontView = window.subviews.first
        if let nextResponder = frontView?.next {
            if nextResponder is UIViewController {
                vc = nextResponder as? UIViewController
            } else {
                vc = window.rootViewController
            }
        } else {
            vc = window.rootViewController
        }
        
        while (vc is UINavigationController) || (vc is UITabBarController) {
            if vc is UITabBarController {
                let tabBarController = vc as! UITabBarController
                vc = tabBarController.selectedViewController
            } else if vc is UINavigationController {
                let navigationController = vc as! UINavigationController
                vc = navigationController.visibleViewController
            }
        }

        if !ignoreChildren, let children = vc?.children, children.count > 0 {
            return children.last
        }
        return vc
    }
}
