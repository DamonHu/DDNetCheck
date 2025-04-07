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
        case .isNotConstrained:
            return UIImageHDBoundle(named: "isConstrained")
        case .notProxy:
            return UIImageHDBoundle(named: "proxy")
        case .notVPN:
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
            return "Device is accessing via IPv4".ZXLocaleString
        case .ipv6:
            return "Device is accessing via IPv6".ZXLocaleString
        case .isNotConstrained:
            return "Device is not restricted (Low Data Mode)".ZXLocaleString
        case .notProxy:
            return "Device is not using a proxy".ZXLocaleString
        case .notVPN:
            return "Device is not using a VPN".ZXLocaleString
        }
    }
}
