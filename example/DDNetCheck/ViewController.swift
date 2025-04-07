//
//  ViewController.swift
//  DDNetCheck
//
//  Created by Damon on 2025/4/3.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.start()
        }
    }

    func start() {
        let vc = DDNetCheckVC(url: "https://www.yechan.cn")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        
        
    }

}

