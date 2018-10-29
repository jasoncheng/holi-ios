//
//  TabBaseVC.swift
//  holi
//
//  Created by jasoncheng on 2018/10/20.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//

import UIKit
import Firebase

class TabBaseVC : UIViewController {
    
    var fullScreenSize: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fullScreenSize = UIScreen.main.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "HOLI"
    }
}
