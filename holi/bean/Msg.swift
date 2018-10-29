//
//  Msg.swift
//  holi
//
//  Created by jasoncheng on 2018/10/26.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//
struct Msg: Codable, Equatable {
    var key: String?
    var createdAt: Double?
    var read: [String: Double]?
    var announcement: String?
    var user: String?
    var username: String?
    var content: String?
    var sticker: String?
    var note: Bool?
    
    var mediaUrl: String?
    var mediaPath: String?
    var audioUrl: String?
    var audioPath: String?
    var audioLength: Double?
    
    // if previous message is come for same people, then, avatar&username is no necessary
    var hideUserInfo: Bool? = false
    
    static func == (l: Msg, r: Msg) -> Bool {
        return l.key == r.key
    }
}
