//
//  TabPublishVC.swift
//  holi
//
//  Created by jasoncheng on 2018/10/20.
//  Copyright © 2018 HOLI CHAT. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase
import PromiseKit

class TabPublishVC : TabBaseVC, UITableViewDelegate, UITableViewDataSource {
    var docs = [Room]()
    var table: UITableView?
    let cellId: String = "cellId"
    let publishRoomLimit = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial Table
        table = UITableView(frame: CGRect(x: 0, y: 0, width: self.fullScreenSize!.width, height: self.fullScreenSize!.height))
        table!.register(RoomCell.self, forCellReuseIdentifier: cellId)
        table!.dataSource = self
        table!.delegate = self
        table!.separatorStyle = .singleLine
        table!.allowsSelection = true
        table!.allowsMultipleSelection = false
        self.view.addSubview(table!)
        
        // Load Data
        firstly {
            Helper.getServerTime()
        }.then { now in
            self.loadData(now, Helper.getLocale())
        }.done { docs in
            for (idx, doc) in docs.enumerated() {
                let room:Room = Room(doc.key!, doc.name)
                let indexPath = IndexPath.init(row: idx, section: 0)
                self.docs.append(room)
                firstly {
                    Helper.getRoom(roomId: doc.key!)
                } .done { room in
                    self.docs[indexPath.row] = room
                    if let cell = self.table?.cellForRow(at: indexPath) as? RoomCell {
                        cell.room = room
                    }
                }
            }
            self.table!.reloadData()
        }
    }
    
    func loadData(_ now: Double, _ locale: String) -> Promise<[Publish]> {
        return Promise { seal in
            Database.database().reference().child("/publish")
                .child(locale)
                .queryOrdered(byChild: "createdAt")
                .queryStarting(atValue: now)
                .queryLimited(toLast: UInt(publishRoomLimit))
                .observeSingleEvent(of: .value, with: { snapshots in
                    var docs = [Publish]()
                    for snapshot in snapshots.children.allObjects as! [DataSnapshot] {
                        guard let value = snapshot.value else { return }
                        do {
                            var publish = try FirebaseDecoder().decode(Publish.self, from: value)
                            publish.key = snapshot.key
                            docs.append(publish)
                        } catch let error {
                            print(error)
                        }
                    }
                    seal.resolve(docs, nil)
                })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.docs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RoomCell
        let room = docs[indexPath.row]
        cell.room = room
        
        // info button click event
        let bt = cell.getInfoButton()
        let tap = UITapGestureRecognizer(target: self, action: #selector(rommInfoTap(tapGestureRecognizer:)))
        tap.numberOfTapsRequired = 1
        bt.tag = indexPath.row
        bt.isUserInteractionEnabled = true
        bt.addGestureRecognizer(tap)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let roomVC = RoomVC()
        roomVC.room = self.docs[indexPath.row]
//        self.navigationController?.pushViewController(roomVC, animated: true)
        
        let nav = UINavigationController(rootViewController: roomVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func rommInfoTap(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let img = tapGestureRecognizer.view else {
            return
        }
        
        guard let tag = Optional.some(img.tag) else {
            return;
        }
        
        let room:Room = docs[tag]
        let alert = UIAlertController(title: room.name, message: room.introduce, preferredStyle: .alert)
        self.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc func alertControllerBackgroundTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
