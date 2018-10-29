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
import PullToRefreshKit

class RoomVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let cellId: String = "Cell"
    var isBG: Bool = false
    var refRoom: DatabaseReference?
    var refMsg: DatabaseReference?
    var data = [Msg]()
    var msgBinded = false
    var loadingMore = false
    var noMore = false
    
    var room: Room? {
        didSet {
            print("----------_> WATCH Room didSet \(String(describing: room))")
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
        let footer = DefaultRefreshFooter.footer()
        let refreshing = NSLocalizedString("LOAD_MORE", comment: "")
        footer.setText(refreshing, mode: .pullToRefresh)
        footer.setText(refreshing, mode: .refreshing)
        footer.setText("", mode: .noMoreData)
        footer.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        table.dataSource = self
        table.register(MsgCell.self, forCellReuseIdentifier: cellId)
        table.delegate = self
        table.transform = CGAffineTransform(scaleX: 1, y: -1)
        table.configRefreshFooter(with: footer, container: self){ [weak self] in
            guard let vc = self else {return}
            vc.loadMore()
            print("=======> refresh.......")
        }
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
                self.room?.key = snapshot.key
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
    
    func getOldestMsgKey() -> String {
        var key: String?
        for doc in self.data {
            if doc.key != nil {
                key = doc.key
            }
        }
        return key!
    }
    
    func loadMore() {
        if noMore {
            self.table.switchRefreshFooter(to: .noMoreData)
            return
        }
        
        if loadingMore {
            self.table.switchRefreshFooter(to: .normal)
            return
        }
        
        if !msgBinded {
            self.table.switchRefreshFooter(to: .normal)
            return
        }
        
        self.loadingMore = true
        guard let roomKey = room?.key else {return}
        let query = Database.database().reference().child("msg").child(roomKey).queryOrderedByKey()
            .queryEnding(atValue: getOldestMsgKey())
            .queryLimited(toLast: UInt(Consts.MESSAGE_MORE_SIZE))
        query.observeSingleEvent(of: .value, with: { snapshots in
            let count = snapshots.childrenCount
            if count == 0 || count < Consts.MESSAGE_MORE_SIZE {
                self.noMore = true
                self.table.switchRefreshFooter(to: .noMoreData)
                return
            }
            
            for snapshot in snapshots.children.allObjects as! [DataSnapshot] {
                guard let value = snapshot.value else {return}
                do {
                    var msg = try FirebaseDecoder().decode(Msg.self, from: value)
                    msg.key = snapshot.key
                    self.newMsg(msg, toEnd: true, reload: false)
                }catch let error{
                    print("Error \(error)")
                }
            }
            
            
            self.table.reloadData()
            self.table.switchRefreshFooter(to: .normal)
            self.loadingMore = false
        }, withCancel: { error in
            self.loadingMore = false
            print("Error \(error)")
        })
    }
    
    func bindMsg() {
        refMsg = Database.database().reference().child("msg").child((room?.key)!)
        let query = refMsg?.queryLimited(toLast: UInt(Consts.MESSAGE_DYNAMIC_SIZE))
        
        // new message coming
        var counter = 0;
        query!.observe(.childAdded, with: { snapshot in
            guard let value = snapshot.value else {return}
            do {
                var msg = try FirebaseDecoder().decode(Msg.self, from: value)
                msg.key = snapshot.key
                self.newMsg(msg, toEnd: false, reload: true)
                self.scrollToBottom();
                counter+=1
                print("ADD \(msg.user ?? ""): \(msg.content ?? "")")
            } catch let error {
                print("firebase error \(error)")
            }
            
            if !self.msgBinded {
                self.msgBinded = true
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
    
    // some util for:
    // 1. this will control which message is necessary to show user info(avatar+username)
    // 2. show Date Announcement (2018-10-24 / Yesterday / Today)
    func newMsg(_ msg: Msg, toEnd: Bool, reload: Bool) {
        if self.data.contains(msg) {return}
        
        let todayE = (NSDate().timeIntervalSince1970 * 1000)
        let yesterday = (todayE - 86400000).toDate()
        let today = todayE.toDate()
        !toEnd ? self.data.insert(msg, at: 0) : self.data.append(msg)
        
        var preMsg:Msg?
        var arr = [Msg]()
        var dayDict = [String: String]()
        let sorted = self.data.sorted(by: { Double($0.createdAt ?? 0) > Double($1.createdAt ?? 0) })
        for var doc in sorted.reversed() {
            guard let _ = doc.key else {continue}
            
            doc.hideUserInfo = preMsg != nil && preMsg?.user == doc.user && !MsgCell.isAnnouncement(preMsg!)
            preMsg = doc
            arr.append(doc)
            
            // process day
            guard let thisDay = doc.createdAt?.toDate() else {continue}
            if !dayDict.keys.contains(thisDay) {
                dayDict[thisDay] = "-"
                var fakeMsg = Msg()
                fakeMsg.announcement = "date"
                fakeMsg.createdAt = doc.createdAt
                if today == thisDay {
                    fakeMsg.content = "today"
                } else if yesterday == thisDay {
                    fakeMsg.content = "yesterday"
                } else {
                     fakeMsg.content = thisDay
                }
                arr.insert(fakeMsg, at: arr.count-1 > 0 ? arr.count - 1 : 0)
            }
        }
        
        self.data = arr.reversed()
        if reload {
            table.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func scrollToBottom() {
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
        
        // if fake message (announcement date)
        if msg.key == nil && msg.announcement != nil && msg.announcement == "date" {
            cell.msg = msg
            return cell
        }
        
        // priority first: set up user info from room
        if let user_name = room?.names?[msg.user!] ?? msg.username {
            cell.userRoomName = user_name
            print("LoadMsgData with \(indexPath.row) \(cell.userRoomName)")
        }
        
        guard let user_avatar = room?.hideProfile?[msg.user!] else {
            cell.msg = msg
            return cell
        }
        
        if !user_avatar.isEmpty {
            cell.userRoomAvatar = user_avatar
        }
        cell.tag = indexPath.row
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
