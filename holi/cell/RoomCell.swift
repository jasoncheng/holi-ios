//
//  RoomCell.swift
//  holi
//
//  Created by jasoncheng on 2018/10/22.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//

import UIKit
import InitialsImageView
import MarqueeLabel

class RoomCell: UITableViewCell {
    var roomStateStr = NSLocalizedString("RoomState", comment: "")
    var room: Room? {
        didSet {
            
            var avatarLabel = "-"
            if let room_title = room?.name {
                roomName.text = room_title
                avatarLabel = "\(room_title.getCharAtIndex(0))"
            }
            setAvatar(avatarLabel, avatar_url:nil)
            
            // room status ( total user, online user)
            let state = Helper.getRoomState(room: room!)
            roomState.text = String(format: roomStateStr, "\(state[0])" , "\(state[1])")
            
            // room introduce icon
            if room?.introduce == nil || room?.introduce?.isEmpty ?? true {
                willRemoveSubview(roomInfoBT)
            }
            
            // private chat room
            if let _ = room?.privateMode {
            }
            
            // user cannot speak
            if let _ = room?.mute {
            }
            
            // user cannot join
            if let _ = room?.rejectAll {
            }
            
            // room is boradcasting
            if let _ = room?.publishTTL {
            }
            
            // room is require password for join
            if let _ = room?.requirePS {
            }
            
            // room avatar
            guard let avatarUrl = Optional.some(Helper.getRoomAvatar(room: room!)) else {
                return
            }
            
            if avatarUrl.isEmpty {
                return
            }
            
            print("\(String(describing: room?.name)) - \(avatarUrl)")
            setAvatar(avatarLabel, avatar_url:avatarUrl)
        }
    }
    
    func setAvatar(_ room_firstname:String, avatar_url:String?="") {
        if avatar_url != nil && !avatar_url!.isEmpty {
            let url = URL(string: avatar_url!)
            roomAvatar.sd_setImage(with: url, completed: nil)
        } else {
            roomAvatar.setImageForName(room_firstname, backgroundColor: nil, circular: true, textAttributes: nil)
        }
        roomAvatar.circle(borderColor: UIColor.red, strokeWidth: 2)
    }
    
    private let roomName: UILabel = {
        let bl = MarqueeLabel.init(frame: CGRect(), duration: 14.0, fadeLength: 10.0)
        bl.textColor = .black
        bl.font = UIFont.boldSystemFont(ofSize: 16)
        return bl
    }()
    
    private let roomState: UILabel = {
        let ele = UILabel()
        ele.textColor = .black
        ele.font = UIFont.systemFont(ofSize: 16)
        ele.textAlignment = .left
        ele.numberOfLines = 0
        return ele
    }()
    
    private let roomAvatar: UIImageView = {
        let ele = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
        return ele
    }()
    
    private let roomInfoBT: UIImageView = {
        let img = UIImage(named: "icons/info_18")
        let ele = UIImageView(image: img)
        return ele
    }()
    
    private let stGroup: UIStackView = {
        let ele = UIStackView(arrangedSubviews: [])
        ele.distribution = .equalSpacing
        ele.axis = .horizontal
        ele.spacing = 5
        return ele
    }()
    
    func getInfoButton() -> UIImageView {
        return roomInfoBT
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(roomAvatar)
        addSubview(roomInfoBT)
        addSubview(roomName)
        addSubview(roomState)
        
        roomAvatar.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 60, height: 0, enableInsets: false)
        
        roomInfoBT.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 20, paddingRight: 10, width: 40, height: 40, enableInsets: false)
        
        roomName.anchor(top: topAnchor, left: roomAvatar.rightAnchor, bottom: nil, right: roomInfoBT.leftAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width, height: 0, enableInsets: false)
        
        roomState.anchor(top: roomName.bottomAnchor, left: roomAvatar.rightAnchor, bottom: nil, right: roomInfoBT.leftAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width, height: 0, enableInsets: false)
    }
}
