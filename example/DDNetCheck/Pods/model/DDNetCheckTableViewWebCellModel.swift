//
//  DDNetCheckTableViewWebCellModel.swift
//  DDNetCheck
//
//  Created by Damon on 2025/4/5.
//

import UIKit

class DDNetCheckTableViewWebCellModel: DDNetCheckTableViewCellModel {
    var title: String
    var image: UIImage?
    
    init(title: String = "", image: UIImage? = nil) {
        self.title = title
        self.image = image
    }
    
    override func getTitle() -> String {
        return title
    }
    
    override func getImage() -> UIImage? {
        return image
    }
}
