//
//  MsgOutCell.swift
//  holi
//
//  Created by jasoncheng on 2018/10/27.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//
import UIKit
class MsgOutCell: MsgCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func doLayout() {
        if type == .TEXT {
            doLayoutBubbleText()
            doLayoutMessageTime()
            doLayoutRead()
        } else if type == .STICKER {
            doLayoutSticker()
            doLayoutMessageTime()
            doLayoutRead()
        }
        super.doLayout()
    }
}
