//
//  DDNetCheckTableViewPlatformCellModel.swift
//  DDNetCheck
//
//  Created by Damon on 2025/4/5.
//

import UIKit

class DDNetCheckTableViewPlatformCellModel: DDNetCheckTableViewCellModel {
    var checkType: DDNetCheckType = .wifi
    
    override func getImage() -> UIImage? {
        switch self.checkType {
        case .wifi:
            return UIImageHDBoundle(named: "wifi")
        case .cellular:
            return UIImageHDBoundle(named: "cellular")
        case .dns:
            return UIImageHDBoundle(named: "dns")
        case .ipv4:
            return UIImageHDBoundle(named: "ipv4")
        case .ipv6:
            return UIImageHDBoundle(named: "ipv6")
        case .isConstrained:
            return UIImageHDBoundle(named: "isConstrained")
        case .proxy:
            return UIImageHDBoundle(named: "proxy")
        case .vpn:
            return UIImageHDBoundle(named: "vpn")
        }
    }
    
    override func getTitle() -> String {
        switch self.checkType {
        case .wifi:
            return "Device is connected via Wi-Fi".ZXLocaleString
        case .cellular:
            return "Device is connected via cellular data".ZXLocaleString
        case .dns:
            return "Device DNS service is functioning properly".ZXLocaleString
        case .ipv4:
            return "Device supports IPv4 access".ZXLocaleString
        case .ipv6:
            return "Device supports IPv6 access".ZXLocaleString
        case .isConstrained:
            return "Device is in a restricted mode such as Low Data Mode".ZXLocaleString
        case .proxy:
            return "Device is using a proxy".ZXLocaleString
        case .vpn:
            return "Device is using a VPN".ZXLocaleString
        }
    }
}
