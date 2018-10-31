//
//  User.swift
//  holi
//
//  Created by jasoncheng on 2018/10/22.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//
struct User: Codable {
    var key: String?
    var name: String?
    var about: String?
    var abuse: Bool?
    var avatar: UserAvatar?
    var background: String?
}
