//
//  MsgInCell.swift
//  holi
//
//  Created by jasoncheng on 2018/10/27.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//
import UIKit
class MsgInCell: MsgCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func doLayout() {
    }
}
