//
//  Publish.swift
//  holi
//
//  Created by jasoncheng on 2018/10/21.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//

struct Publish: Codable {
    var key: String?
    var createdAt: Double
    var ignore: [String: Double]?
    var name: String
    var owner: String
    var priority: Double?
    var priority_expire: Double?
    var abuse: Bool?
}
