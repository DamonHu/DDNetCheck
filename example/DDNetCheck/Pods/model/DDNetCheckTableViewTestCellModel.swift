//
//  DDNetCheckTableViewTestCellModel.swift
//  DDNetCheck
//
//  Created by Damon on 2025/4/5.
//

import UIKit

class DDNetCheckTableViewTestCellModel: DDNetCheckTableViewCellModel {
    var testWeb: TestWeb = .apple
    
    override func getImage() -> UIImage? {
        return UIImageHDBoundle(named: "appleServerConnected")
    }
    
    override func getTitle() -> String {
        switch self.testWeb {
        case .apple:
            return "apple.com"
        case .amazon:
            return "amazon.com"
        case .baidu:
            return "baidu.com"
        case .aliyun:
            return "aliyun.com"
        }
    }
}
