//
//  MsgAnnouncement.swift
//  holi
//
//  Created by jasoncheng on 2018/10/27.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//

import UIKit
class MsgAnnouncement: MsgCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private var contentText: UILabel = {
        let ele = UILabel(frame: CGRect())
        ele.textAlignment = .center
        ele.textColor = .white
        return ele
    }()
    
    private var contentTime: UILabel = {
        let ele = UILabel(frame: CGRect())
        ele.textAlignment = .center
        ele.textColor = .white
        return ele
    }()
    
    private let stackView: UIStackView = {
        let ele = UIStackView(arrangedSubviews: [])
        ele.axis = .vertical
        ele.spacing = 3.0
        ele.addBackground(color: UIColor(rgb: 0x999999))
        return ele
    }()
    
    override func doLayout() {
        let msgOut = Helper.getAnnouncementFormatString(content: msg?.announcement ?? "")
        if msgOut.isEmpty {
            return
        }
        
        if msg?.key == nil && msg?.content != nil {
            contentTxt.text = ""
            contentTime.text = NSLocalizedString((msg?.content)!, comment: (msg?.content)!)
            contentTime.font = UIFont.boldSystemFont(ofSize: 14)
            stackView.addBackground(color: UIColor(rgb: 0x333333))
        } else if let username = userRoomName {
            contentText.text = "\(username) \(msgOut)"
            contentTime.text = msg?.createdAt?.toDateTime()
        }
        
        stackView.addArrangedSubview(contentText)
        stackView.addArrangedSubview(contentTime)
        addSubview(stackView)
        
        // caculator UILabel max width & sum height
        let constraintRect = CGSize(width: 0.66 * frame.width,
                                    height: .greatestFiniteMagnitude)
        let boundingBox = contentText.text?.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: contentText.font],
                                            context: nil)
        let boundingBoxTime = contentTime.text?.boundingRect(with: constraintRect,
                                                         options: .usesLineFragmentOrigin,
                                                         attributes: [.font: contentTime.font],
                                                         context: nil)
        let txtSize = CGSize(width: ceil(boundingBox?.width ?? 0),
                             height: ceil(boundingBox?.height ?? 0))
        
        let timeSize = CGSize(width: ceil(boundingBoxTime?.width ?? 0),
                             height: ceil(boundingBoxTime?.height ?? 0))
        
        let totalWidth = txtSize.width > timeSize.width ? txtSize.width+20 : timeSize.width+20
        let totalHeight = txtSize.height + timeSize.height + 10
        stackView.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: totalWidth, height: totalHeight, enableInsets: false)
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        super.doLayout()
    }
}
