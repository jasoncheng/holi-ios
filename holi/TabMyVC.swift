//
//  TabMyVC.swift
//  holi
//
//  Created by jasoncheng on 2018/10/20.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//

import UIKit
import Cache
class TabMyVC : TabBaseVC {
    var user: User?
    let storage = MemoryStorage<User>(config: Helper.memoryCacheUserCfg)
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
