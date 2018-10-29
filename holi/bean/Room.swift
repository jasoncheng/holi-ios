//
//  Room.swift
//  holi
//
//  Created by jasoncheng on 2018/10/21.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//
struct Room: Codable {
    var key: String?
    var name: String?
    var owner: String?
    var avatar: UserAvatar?
    var users: [String: Double]?
    var names: [String: String]?
    
    var introduce: String?
    var background: String?
    
    var shareLink: String?
    var shareCode: String?
    
    var noLogin: Bool?
    var requirePS: Bool?
    var autoDeleteMode: Bool?
    var privateMode: Bool?
    var privateBlock: Bool?
    var newMemberSeeOld: Bool?
    var abuse: Bool?
    var mute: Bool?
    var adminCanNote: Bool?
    var noScreenShot: Bool?
    var noViolationDetect: Bool?
    var rejectAll: Bool?
    var publishTTL: Double?
    
    var online: [String: Double]?
    var onlineHistory: [String: Double]?
    var hideProfile: [String: String]?
    var block: [String: Double]?
    var blockDeviceId: [String: Double]?
    
    init(_ key: String, _ name: String) {
        self.key = key
        self.name = name
    }
}
