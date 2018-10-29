//
//  MsgCell.swift
//  holi
//
//  Created by jasoncheng on 2018/10/27.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//

import UIKit
import FirebaseAuth

class MsgCell: UITableViewCell {
    
    var type: MsgType? = .TEXT
    var incoming: Bool?
    
    enum MsgType:Int {
        case TEXT
        case STICKER
        case PHOTO
        case AUDIO
        case ANNOUNCEMENT
    }
    
    var msg: Msg? {
        didSet {
            
            // message type
            if msg?.sticker != nil {
                type = .STICKER
            } else if msg?.announcement != nil {
                type = .ANNOUNCEMENT
            } else if msg?.audioPath != nil {
                type = .AUDIO
            } else if msg?.mediaPath != nil {
                type = .PHOTO
            }
            
            // incoming or outgoing
            incoming = isIncoming()
            doLayout()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func isIncoming() -> Bool {
        guard let user = Auth.auth().currentUser else {return false}
        guard let vc = self.viewControllerForTableView as? RoomVC else {return false}
        return vc.room?.owner != user.uid
    }
    
    private let avatar: UIImageView = {
        let ele = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
        return ele
    }()
    
    private let username: UILabel = {
        let bl = UILabel(frame: CGRect())
        bl.textColor = .black
        bl.font = UIFont.boldSystemFont(ofSize: 16)
        bl.textAlignment = .left
        return bl
    }()
    
    private func inComingBubbule() -> BubbleView {
        let bubble = BubbleView()
        bubble.isIncoming = true
        bubble.backgroundColor = .clear
        return bubble
    }
    
    
    private func outGoingBubble() -> BubbleView {
        let bubbleView = BubbleView()
        bubbleView.backgroundColor = .clear
        return bubbleView
    }
    
    func bubbleTxt(isIncoming: Bool, text: String) -> BubbleView {
        let bubble = isIncoming ? inComingBubbule() : outGoingBubble()
        let label =  UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.text = text
        
        let constraintRect = CGSize(width: 0.66 * frame.width,
                                    height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: label.font],
                                            context: nil)
        label.frame.size = CGSize(width: ceil(boundingBox.width),
                                  height: ceil(boundingBox.height))
        
        let bubbleSize = CGSize(width: label.frame.width + 28,
                                height: label.frame.height + 20)
        bubble.frame.size = bubbleSize
        return bubble
    }
    
    func doLayout(){}
}
