//
//  Helper.swift
//  holi
//
//  Created by jasoncheng on 2018/10/21.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//
import UIKit
import Firebase
import CodableFirebase
import PromiseKit

class Helper {
    
    public enum ANNOUCEMENT_TYPE: String {
        case JOIN_ROOM = "_|_rj_|_"
        case CREATE_ROOM = "_|_rc_|_"
        case LEAVE_ROOM = "_|_rl_|_"
        case UNKNOW = "??"
    }
    
    static func getLocale() -> String {
        return String(String(Locale.preferredLanguages[0]).suffix(2));
    }
    
    static func getUUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    static func getAnnouncementFormatString(content: String) -> String {
        let cmd = ANNOUCEMENT_TYPE(rawValue: content)
        switch cmd {
        case .JOIN_ROOM?: return NSLocalizedString("JOIN_ROOM", comment: "")
        case .CREATE_ROOM?: return NSLocalizedString("CREATE_ROOM", comment: "")
        case .LEAVE_ROOM?: return NSLocalizedString("LEAVE_ROOM", comment: "")
        default: return "unknow"
        }
    }
    
    static func getServerTime() -> Promise<Double> {
        return Promise { seal in
            Database.database().reference(withPath: ".info/serverTimeOffset").observeSingleEvent(of: .value, with:{ (snapshot) in
                if let time = snapshot.value as? Double {
                    seal.resolve(Date().timeIntervalSince1970 + time, nil)
                } else {
                    seal.resolve(0, nil)
                }
            })
        }
    }
    
    static func getRoom(roomId: String, complete: @escaping (DataSnapshot) -> Void) {
        let ref = Database.database().reference(withPath: "/room").child(roomId)
        ref.observeSingleEvent(of: .value, with:complete);
    }
    
    static func getRoom(roomId: String) -> Promise<Room> {
        return Promise { seal in
            getRoom(roomId: roomId, complete: { snapshot in
                guard let value = snapshot.value else { return }
                do {
                    var room = try FirebaseDecoder().decode(Room.self, from:value)
                    room.key = snapshot.key
                    guard let userId = room.owner else {
                        seal.resolve(room, nil)
                        return
                    }
                    
                    firstly {
                        getUser(userId)
                        } .done { user in
                            room.avatar = user.avatar
                            seal.resolve(room, nil)
                    }
                } catch let err {
                    print("getRoom error \(roomId): \(err)")
                }
            })
        }
    }
    
    static func getUser(_ userId: String, path:String = "user") -> Promise<User> {
        return Promise { seal in
            print("getUser /\(path)/\(userId)")
            let ref = Database.database().reference().child(path).child(userId)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value else { return }
                do {
                    let user = try FirebaseDecoder().decode(User.self, from: value)
                    seal.resolve(user, nil)
                } catch let err {
                    print(err)
                }
            })
        }
    }
    
    static func getRoomAvatar(room: Room) -> String {
        let owner = room.owner
        
        // 如果有設定聊天室頭像
        if let hideAvatar = room.hideProfile?[owner ?? ""] {
            if !hideAvatar.isEmpty {
                return hideAvatar
            }
        }
        
        // 如果有設定個人頭像
        if let avatar = room.avatar {
            return avatar.url ?? ""
        }
        
        return ""
    }
    
    static func getRoomState(room: Room) -> [Int] {
        let online = room.online?.count ?? 0
        let users = room.users?.count ?? 0
        var ar = [Int]()
        ar.append( users )
        ar.append( online )
        return ar
    }
    
    static func getAvatarPlaceholder(name: String, cgFrame: CGRect) -> UIImageView {
        let image = UIImageView(frame: cgFrame)
        let label = "\(name.getCharAtIndex(0))"
        image.setImageForName(label, backgroundColor: nil, circular: true, textAttributes: nil)
        image.circle(borderColor: UIColor.white, strokeWidth: 2)
        return image
    }
}
