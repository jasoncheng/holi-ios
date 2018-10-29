//
//  RoomVC.swift
//  holi
//
//  Created by jasoncheng on 2018/10/25.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CodableFirebase
import ReverseExtension

class RoomVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let cellId: String = "Cell"
    let listenNumOfLastMsg: Int = 25
    var isBG: Bool = false
    var refRoom: DatabaseReference?
    var refMsg: DatabaseReference?
    var data = [Msg]()
    
    var room: Room? {
        didSet {
            if ifUserBeenBlock() {
                print("========> user been block!!!!!")
                showToast("blocked")
                dismiss(animated: true, completion: nil)
                return
            }
            
            if refRoom == nil && room?.key != nil {
                bindRoom()
                bindMsg()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    func layout() {
        // Navigation
        let label = UILabel()
        label.text = room?.name
        label.textAlignment = .left
        self.navigationItem.titleView = label
        let backButton = UIBarButtonItem(title: "\u{25C0}", style:.plain, target: self, action: #selector(goBack))
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
        
        // Background Image
        if let bg = room?.background {
            isBG = true
            let url = URL(string: bg)
            bgImg.sd_setImage(with: url, completed: nil)
            self.view.addSubview(bgImg)
        }
        
        // Input Text
        inputTxt.delegate = self
        self.view.addSubview(inputTxt)
        
        // Chat Area
        table.dataSource = self
        table.register(MsgCell.self, forCellReuseIdentifier: cellId)
        table.delegate = self
        table.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.view.addSubview(table)
    }
    
    override func viewWillLayoutSubviews() {
        if #available(iOS 11.0, *) {
            inputTxt.anchor(top: nil, left: nil, bottom: self.view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: self.view.frame.width, height: 70, enableInsets: false)
        } else {
            inputTxt.anchor(top: nil, left: nil, bottom: self.view.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: self.view.frame.width, height: 40, enableInsets: false)
        }
        
        if isBG {
            bgImg.anchor(top: self.view.topAnchor, left: nil, bottom: self.view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: self.view.frame.width, height: self.view.frame.height, enableInsets: false)
        }
        
        table.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, left: self.view.leftAnchor, bottom: inputTxt.topAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: self.view.frame.width, height: self.view.frame.height, enableInsets: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        confirmLoadRoom()
    }
    
    func confirmLoadRoom() {
        unbindRoom()
        unbindMsg()
    }
    
    func unbindRoom() {
        if refRoom != nil {
            refRoom?.removeAllObservers()
        }
    }
    
    func bindRoom(){
        refRoom = Database.database().reference().child("room").child((room?.key)!)
        refRoom?.observe(.value, with: { snapshot in
            guard let value = snapshot.value else {return}
            do {
                self.room = try FirebaseDecoder().decode(Room.self, from: value)
            } catch let error {
                print("firebase error \(error)")
            }
        })
    }
    
    func unbindMsg(){
        if refMsg != nil {
            refMsg?.removeAllObservers()
        }
    }
    
    func bindMsg() {
        refMsg = Database.database().reference().child("msg").child((room?.key)!)
        let query = refMsg?.queryLimited(toLast: UInt(listenNumOfLastMsg))
        
        // new message coming
        var counter = 0;
        query!.observe(.childAdded, with: { snapshot in
            guard let value = snapshot.value else {return}
            do {
                var msg = try FirebaseDecoder().decode(Msg.self, from: value)
                msg.key = snapshot.key
                if self.data.contains(msg) {return}
                
                // setup msg.hideUserInfo
                if self.data.count > 0 {
                    let preMsg = self.data[self.data.count - 1]
                    if !MsgCell.isAnnouncement(preMsg) {
                        msg.hideUserInfo = preMsg.user == msg.user
                    }
                }
                
                //                if counter == 24 {
                //                    msg.user = "PhAcB9ZDf7YMu8fE2XfGzyBmYHg2"
                //                }
                
                //                self.data.append(msg)
                self.data.insert(msg, at: 0)
                self.table.reloadData()
                self.scrollToBottom();
                counter+=1
                print("ADD \(msg.user ?? ""): \(msg.content ?? "")")
            } catch let error {
                print("firebase error \(error)")
            }
        })
        
        // someone delete this message
        query!.observe(.childRemoved, with: { snapshot in
            guard let value = snapshot.value else {return}
            do {
                var msg = try FirebaseDecoder().decode(Msg.self, from: value)
                msg.key = snapshot.key
                print("DEL \(msg.user ?? ""): \(msg.content ?? "")")
            } catch let error {
                print("firebase error \(error)")
            }
        })
        
        // someone read this message
        query!.observe(.childChanged, with: { snapshot in
            do {
                guard let value = snapshot.value else {return}
                let msg = try FirebaseDecoder().decode(Msg.self, from: value)
                guard let offset = self.data.index(where: { $0.key == snapshot.key}) else {return}
                guard let path = NSIndexPath(row: offset, section: 0) as? IndexPath else {return}
                guard let _ = self.table.cellForRow(at: path) as? MsgCell else {return}
                self.data[offset] = msg
                print(String(describing: "CHG \(String(describing: msg.user)): \(String(describing: msg.content))"))
            } catch let error {
                print("firebase error \(error)")
            }
        })
    }
    
    private let bgImg: UIImageView = {
        let ele = UIImageView(frame: UIScreen.main.bounds)
        ele.contentMode = UIView.ContentMode.scaleAspectFill
        return ele
    }()
    
    private let table:UITableView = {
        let t = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        t.allowsSelection = true
        t.allowsMultipleSelection = false
        t.separatorStyle = .none
        t.backgroundColor = UIColor.clear
        return t
    }()
    
    private let inputTxt: UITextField = {
        var ele = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        ele.placeholder = "message here"
        ele.clearButtonMode = .whileEditing
        ele.returnKeyType = .done
        ele.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 10)
        ele.backgroundColor = UIColor(rgb: 0xEFEFEF)
        ele.backgroundColor?.withAlphaComponent(0.2)
        return ele
    }()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func scrollToBottom() {
        //        let index = NSIndexPath(row: data.count-1, section: 0) as IndexPath
        let index = NSIndexPath(row: 0, section: 0) as IndexPath
        self.table.scrollToRow(at: index, at: UITableView.ScrollPosition.bottom, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = self.data[indexPath.row]
        let cell: MsgCell
        let defaultFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
        if MsgCell.isAnnouncement(msg) {
            cell = MsgAnnouncement(frame: defaultFrame)
        } else if MsgCell.isIncoming(msg) {
            cell = MsgInCell(frame: defaultFrame)
        } else {
            cell = MsgOutCell(frame: defaultFrame)
        }
        
        // priority first: set up user info from room
        if let user_name = room?.names?[msg.user!] ?? msg.username {
            cell.userRoomName = user_name
        }
        
        guard let user_avatar = room?.hideProfile?[msg.user!] else {
            cell.msg = msg
            return cell
        }
        
        if !user_avatar.isEmpty {
            cell.userRoomAvatar = user_avatar
        }
        
        cell.msg = msg
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // check if user been block
    func ifUserBeenBlock() -> Bool {
        guard let user = Auth.auth().currentUser else {return false}
        return room?.block?.keys.contains(user.uid) ?? false
    }
    
    // check if room is private, no one can join
    func isPrivateRoom() -> Bool {
        return room?.privateMode ?? true
    }
    
    // check if member is new
    func ifUserNew() -> Bool {
        guard let _ = Auth.auth().currentUser else {return false}
        guard let _ = room?.users else {return false}
        return true
    }
}
