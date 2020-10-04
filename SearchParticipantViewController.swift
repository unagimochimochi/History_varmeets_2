//
//  SearchParticipantViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/10/02.
//

import UIKit
import CloudKit

class SearchParticipantViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var friendsSearchBar: UISearchBar!
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var friendIDs = [String]()
    var friendNames = [String]()
    var friendBios = [String]()
    
    var timer1: Timer!
    var timer2: Timer!
    var checkCount1: Int?
    var checkCount2: Int?
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        friendsSearchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchFriends()
        
        // タイマー1スタート
        timer1 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(update1), userInfo: nil, repeats: true)
    }
    
    @objc func update1() {
        
        print("update1")
        // friendIDs配列がデータベースのフレンド一覧と同じ要素数になったら
        if let friendsNum = checkCount1 {
            
            if friendIDs.count == friendsNum {
                print("friendIDs: \(friendIDs.count)")
                print("friendIDs: \(friendIDs)")
                // タイマー1を止める
                if let workingTimer = timer1 {
                    workingTimer.invalidate()
                }
                
                // 各々の友だちの情報を取得
                fetchFriendInfo()
                
                // タイマー2スタート
                timer2 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(update2), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func update2() {
        print("update2")
        // 繰り返し処理のカウントがfriendIDs配列と同じ数になったら（すべての友だちの情報を取得し終えたら）
        if let finishNum = checkCount2 {
            if finishNum >= friendIDs.count {
                // タイマー2を止める
                if let workingTimer = timer2 {
                    workingTimer.invalidate()
                }
                
                // UI更新
                friendsTableView.reloadData()
            }
        }
    }
    
    func fetchFriends() {
        
        // 自分のレコードから友だち一覧を取得
        let recordID1 = CKRecord.ID(recordName: "accountID-\(myID!)")
        
        publicDatabase.fetch(withRecordID: recordID1, completionHandler: {(record, error) in
            
            if let error = error {
                print("友だち一覧取得エラー: \(error)")
                return
            }
            
            if let friendIDs = record?.value(forKey: "friends") as? [String] {
                
                self.checkCount1 = friendIDs.count
                
                for friendID in friendIDs {
                    print("success!")
                    self.friendIDs.append(friendID)
                }
            }
        })
    }
    
    func fetchFriendInfo() {
        
        print("fetchFriendInfo()が呼ばれた")
        
        var count = 0
        while count < friendIDs.count {
            
            let recordID2 = CKRecord.ID(recordName: "accountID-\(friendIDs[count])")
            
            count += 1
            print("今から\(count)番目の友だちの情報を取得します")
            
            publicDatabase.fetch(withRecordID: recordID2, completionHandler: {(record, error) in
                
                if let error = error {
                    print("友だちの情報取得エラー: \(error)")
                    return
                }
                
                if let name = record?.value(forKey: "accountName") as? String {
                    self.friendNames.append(name)
                    print(name)
                    if self.friendNames.count == count {
                        self.checkCount2 = count
                        print(count)
                    }
                }
                
                if let bio = record?.value(forKey: "accountBio") as? String {
                    self.friendBios.append(bio)
                } else {
                    self.friendBios.append("自己紹介が未入力です")
                }
            })
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for:indexPath)
        
        let icon = cell.viewWithTag(1) as! UIImageView
        icon.layer.borderColor = UIColor.gray.cgColor // 枠線の色
        icon.layer.borderWidth = 0.5 // 枠線の太さ
        icon.layer.cornerRadius = icon.bounds.width / 2 // 丸くする
        icon.layer.masksToBounds = true // 丸の外側を消す
        
        let nameLabel = cell.viewWithTag(2) as! UILabel
        nameLabel.text = friendNames[indexPath.row]
        
        let idLabel = cell.viewWithTag(3) as! UILabel
        idLabel.text = friendIDs[indexPath.row]
        
        return cell
    }
    
    func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

}
