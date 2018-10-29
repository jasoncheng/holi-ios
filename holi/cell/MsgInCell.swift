//
//  MsgInCell.swift
//  holi
//
//  Created by jasoncheng on 2018/10/27.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//
import UIKit
import PromiseKit

class MsgInCell: MsgCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func doLayout() {
        doLayoutUserBox()
        if type == .TEXT {
            doLayoutBubbleText()
        } else if type == .STICKER {
            doLayoutSticker()
        } else if type == .PHOTO {
            doLayoutPhoto()
        }
        doLayoutMessageTime()
        doLayoutRead()
        super.doLayout()
    }
    
    var userInfoBox: UIStackView = {
        var ele = UIStackView()
        ele.axis = .horizontal
        ele.spacing = 3.0
        return ele
    }()
    
    func doLayoutUserBox() {
        if userRoomName == nil || msg?.hideUserInfo ?? false {
            return
        }
        
        username.text = userRoomName
        let label = "\(userRoomName!.getCharAtIndex(0))"
        avatar.setImageForName(label, backgroundColor: nil, circular: true, textAttributes: nil)
        avatar.circle(borderColor: UIColor.red, strokeWidth: 2)
        if userRoomAvatar != nil {
            self.loadAvatar()
        } else {
            firstly {
                Helper.getUser((msg?.user)!)
            }.done { user in
                if let avatar = user.avatar?.url {
                    self.userRoomAvatar = avatar
                    self.loadAvatar()
                }
            }.catch { error in
                    print("Error \(error)")
            }
        }
        
        addSubview(avatar)
        addSubview(username)
        avatar.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 30, height: 30, enableInsets: false)
        username.anchor(top: topAnchor, left: avatar.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        username.centerYAnchor.constraint(equalTo: avatar.centerYAnchor).isActive = true
        
    }
    
    private func loadAvatar(){
        print("------> load avatar \(String(describing: userRoomAvatar))")
        let url = URL(string: userRoomAvatar!)
        avatar.sd_setImage(with: url, completed: nil)
        avatar.circle(borderColor: UIColor.red, strokeWidth: 2)
    }
}
