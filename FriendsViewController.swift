//
//  ReFriendsViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/06/06.
//
// Label受け渡し参考 https://qiita.com/azuma317/items/6b800bfca423e8fe2cf6

import UIKit
import CloudKit

protocol CountObserver {
    func didChange(newCount :Int)
}

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var friendsTableView: UITableView!
    
    var giveName: String = ""
    var giveID: String = ""
    var giveBio: String = ""
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var friendIDs: [String] = [] {
        // 配列が更新されたら処理
        didSet {
            fetchFriendInfo()
            // 1秒後に処理
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.friendsTableView.reloadData()
            }
        }
    }

    var friendNames = [String]()
    var friendBios = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        friendIDs.removeAll()
        friendNames.removeAll()
        friendBios.removeAll()
        
        fetchFriends()
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
                for friendID in friendIDs {
                    print("友だち一覧取得成功")
                    self.friendIDs.append(friendID)
                }
            }
        })
    }
    
    func fetchFriendInfo() {
        
        var count = 0
        while count < friendIDs.count {
            
            let recordID2 = CKRecord.ID(recordName: "accountID-\(friendIDs[count])")
            
            publicDatabase.fetch(withRecordID: recordID2, completionHandler: {(record, error) in
                
                if let error = error {
                    print("友だちの情報取得エラー: \(error)")
                    return
                }
                
                if let name = record?.value(forKey: "accountName") as? String {
                    self.friendNames.append(name)
                }
                
                if let bio = record?.value(forKey: "accountBio") as? String {
                    self.friendBios.append(bio)
                } else {
                    self.friendBios.append("自己紹介が未入力です")
                }
            })
            
            count += 1
        }
    }
    
    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendIDs.count
    }
    
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = table.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        
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
    
    // Cell の高さを60にする
    func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ table: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toFriendProfileVC" {
            
            let fpVC = segue.destination as! FriendProfileViewController

            if let selectedIndexPath = friendsTableView.indexPathForSelectedRow {
                
                fpVC.receiveName = friendNames[selectedIndexPath.row]
                fpVC.receiveID = friendIDs[selectedIndexPath.row]
                fpVC.receiveBio = friendBios[selectedIndexPath.row]
            }
        }
    }

}
