//
//  MsgCell.swift
//  holi
//
//  Created by jasoncheng on 2018/10/27.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//

import UIKit
import FirebaseAuth
import PromiseKit
import SDWebImage

class MsgCell: UITableViewCell {
    
    var type: MsgType? = .TEXT
    var incoming: Bool?
    var bubbleLabelFrame: CGRect?
    
    var userRoomName: String?
    var userRoomAvatar: String?
    
    enum MsgType {
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
            incoming = MsgCell.isIncoming(self.msg ?? Msg())
            
            doLayout()
        }
    }
    
    func getIndexPathFor(view: UIView, tableView: UITableView) -> IndexPath? {
        let point = tableView.convert(view.bounds.origin, from: view)
        let indexPath = tableView.indexPathForRow(at: point)
        return indexPath
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func isIncoming(_ msg: Msg) -> Bool {
        guard let user = Auth.auth().currentUser else {return false}
        return msg.user != user.uid
    }
    
    static func isAnnouncement(_ msg: Msg) -> Bool {
        return msg.announcement != nil && !(msg.announcement?.isEmpty)!
    }
    
    let avatar: UIImageView = {
        let ele = UIImageView(frame: CGRect(x:0, y:0, width: 30, height:30))
        return ele
    }()
    
    let username: UILabel = {
        let bl = UILabel(frame: CGRect())
        bl.textColor = .black
        bl.textAlignment = .left
        return bl
    }()
    
    private let message_time: UILabel = {
        let bl = UILabel(frame: CGRect())
        bl.textColor = .black
        bl.font = UIFont.systemFont(ofSize: 13)
        return bl
    }()
    
    private let read_text: UILabel = {
        let bl = UILabel(frame: CGRect())
        bl.textColor = .black
        bl.font = UIFont.systemFont(ofSize: 13)
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
    
    var contentTxt: UILabel = {
        let label =  UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    var viewContent: UIView?
    
    func bubbleTxt(isIncoming: Bool, text: String) -> UIView {
        viewContent = isIncoming ? inComingBubbule() : outGoingBubble()
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
        bubbleLabelFrame = label.frame
        let bubbleSize = CGSize(width: label.frame.width + 28,
                                height: label.frame.height + 20)
        viewContent?.frame.size = bubbleSize
        
        if isIncoming {
            viewContent?.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
        
        return viewContent!
    }
    
    func viewContentLayout() {
        let isIncoming = self.isKind(of: MsgInCell.self)
        let view = viewContent!
        let width = view.frame.width
        let height = view.frame.height
        
        if isIncoming {
            if msg?.hideUserInfo ?? false {
                view.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: width, height: height, enableInsets: false)
            } else {
                view.anchor(top: avatar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: width, height: height, enableInsets: false)
            }
        } else {
            view.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: width, height: height, enableInsets: false)
        }
    }
    
    func doLayoutPhoto(){
        guard let tmpStr = msg?.mediaUrl else {return}
        let ar = tmpStr.components(separatedBy: "#")
        let _url = ar[0].urlEncoded()
        
        print("IMAGE ======> \(String(describing: _url))")
        let url = URL(string: _url)
        let f = CGRect(x: 0, y: 0, width: frame.size.width * 0.68, height: frame.size.width * 0.68)
        
        let img = FLAnimatedImageView(frame: f)
        img.sd_setImage(with: url, placeholderImage: nil, options: [.allowInvalidSSLCertificates], completed: nil)
//        img.sd_setImage(with: url, completed: nil)
        addSubview(img)
        viewContent = img
        viewContentLayout()
    }
    
    func doLayoutSticker(){
        guard let tmpStr = msg?.sticker else {return}
        let ar = tmpStr.components(separatedBy: "#")
        let _url = ar[0].urlEncoded()
        
        print("IMAGE ======> \(String(describing: _url))")
        let f = CGRect(x: 0, y: 0, width: frame.size.width * 0.68, height: frame.size.width * 0.68)
        let url = URL(string: _url)
        
        let img = FLAnimatedImageView(frame: f)
        img.sd_setImage(with: url, placeholderImage: nil, options: [.allowInvalidSSLCertificates], completed: nil)
//        img.sd_setImage(with: url, completed: nil)
        addSubview(img)
        viewContent = img
        viewContentLayout()
    }
    
    func doLayoutBubbleText(){
        let isIncoming = self.isKind(of: MsgInCell.self)
        let bubble = bubbleTxt(isIncoming: isIncoming, text: msg?.content ?? "")
        
        contentTxt.text = msg?.content
        addSubview(bubble)
        addSubview(contentTxt)
        viewContentLayout()
        
        contentTxt.anchor(center: bubble, width: bubbleLabelFrame?.size.width ?? 0, height: bubbleLabelFrame?.size.height ?? 0)
    }
    
    func doLayoutMessageTime() {
        let isIncoming = self.isKind(of: MsgInCell.self)
        message_time.text = msg?.createdAt?.toTime()
        addSubview(message_time)
        
        if isIncoming {
            message_time.anchor(top: nil, left: viewContent?.rightAnchor, bottom: viewContent?.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 50, height: 0, enableInsets: false)
        } else {
            message_time.textAlignment = .right
            message_time.anchor(top: nil, left: nil, bottom: viewContent?.bottomAnchor, right: viewContent?.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 50, height: 0, enableInsets: false)
        }
    }
    
    func doLayoutRead() {
        guard let read = msg?.read else {return}
        let isIncoming = self.isKind(of: MsgInCell.self)
        let str = NSLocalizedString("READ_COUNT", comment: "")
        if read.count == 1 {
            read_text.text = String(format: str, "")
        } else {
            read_text.text = String(format: str, "\(read.count)")
        }
        
        addSubview(read_text)
        if isIncoming {
            read_text.anchor(top: nil, left: viewContent?.rightAnchor, bottom: message_time.topAnchor, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 50, height: 0, enableInsets: false)
        } else {
            read_text.textAlignment = .right
            read_text.anchor(top: nil, left: nil, bottom: message_time.topAnchor, right: viewContent?.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 50, height: 0, enableInsets: false)
        }
    }
    
    // after all layout, start layout message time
    func doLayout(){
        print("doLayout parent: ")
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
}
