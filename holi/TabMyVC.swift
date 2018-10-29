//
//  TabMyVC.swift
//  holi
//
//  Created by jasoncheng on 2018/10/20.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//

import UIKit
class TabMyVC : TabBaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        let str = "https://3.bp.blogspot.com/-pXexAMWSgEc/WDaBLUc8cgI/AAAAAAALb6E/qMs4keiXs_onvllx8CvldhO4BuB_76X-wCLcB/s1600/AS000834_00.gif?time=Sat%20Aug%2025%202018%2013:58:23%20GMT+0800%20(台北標準時間)#sg_-LKjeG8LH8fEFe_Eqy97"
        let index = str.firstIndex(of: "#")
        print("===============>\(str.firstIndex(of: "#"))")
        print("===============>\(str.firstIndex(of: Character("#")))")
        print("===============>\(str.substring(to: index!))")
        print(str.components(separatedBy: "#"))
    }
}
