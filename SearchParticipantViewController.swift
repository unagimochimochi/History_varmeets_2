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
    }
    
    func fetchFriends() {
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue")
        
        // 1つ目の処理
        dispatchGroup.enter()
        dispatchQueue.async(group: dispatchGroup, qos: .unspecified, flags: [], execute: {
            
            print("1つ目の処理入った")
            
            // 自分のレコードから友だち一覧を取得
            let recordID1 = CKRecord.ID(recordName: "accountID-\(myID!)")
            
            self.publicDatabase.fetch(withRecordID: recordID1, completionHandler: {(record, error) in
                
                if let error = error {
                    print("友だち一覧取得エラー: \(error)")
                    return
                }
                
                if let friendIDs = record?.value(forKey: "friends") as? [String] {
                    for friendID in friendIDs {
                        print("友だち一覧取得成功")
                        self.friendIDs.append(friendID)
                    }
                    
                    dispatchGroup.leave()
                    print("1つ目の処理抜けた")
                }
            })
        })
        
        
        // 2つ目の処理
        dispatchGroup.enter()
        dispatchQueue.async(group: dispatchGroup, qos: .unspecified, flags: [], execute: {
            
            print("2つ目の処理入った")
            
            var count = 0
            while count < self.friendIDs.count {
                
                // 友だちのレコードから情報を取得
                let recordID2 = CKRecord.ID(recordName: "accountID-\(self.friendIDs[count])")
                
                self.publicDatabase.fetch(withRecordID: recordID2, completionHandler: {(record, error) in
                    
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
                
                if count == self.friendIDs.count {
                    dispatchGroup.leave()
                    print("2つ目の処理抜けた")
                }
            }
        })
        
        // 両方の dispatchGroup.leave() が呼ばれたとき
        dispatchGroup.notify(queue: .main) {
            self.friendsTableView.reloadData()
            print("UITableView更新")
        }
    }
    
    func fetchFriendInfo() {
        
        var count = 0
        while count < friendIDs.count {
            
            print(count)
            
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
