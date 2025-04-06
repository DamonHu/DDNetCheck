//
//  DDNetCheckTableViewCellModel.swift
//  DDNetCheck
//
//  Created by Damon on 2025/4/5.
//

import UIKit

class DDNetCheckTableViewCellModel {
    var status: CheckStatus = .checking
    
    func getImage() -> UIImage? {
        return nil
    }
    
    func getTitle() -> String {
        return ""
    }
}

