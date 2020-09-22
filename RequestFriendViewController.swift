//
//  RequestFriendViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/09/22.
//

import UIKit
import CloudKit

class RequestFriendViewController: UIViewController {
    
    var friendID: String?
    var friendName: String?
    var friendBio: String?
    
    var requestedAccounts = [String]()

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var requestButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let id = friendID, let name = friendName {
            idLabel.text = id
            nameLabel.text = name
        }
        
        if let bio = friendBio {
            bioLabel.text = bio
        }
        
        // 友だち申請ボタン
        requestButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        requestButton.layer.masksToBounds = true
        requestButton.layer.cornerRadius = 8
        
        if requestedAccounts.contains(myID!) {
            requestButton.setTitle("申請をキャンセル", for: .normal)
            requestButton.setTitleColor(.white, for: .normal)
            requestButton.backgroundColor = UIColor(hue: 0.07, saturation: 0.9, brightness: 0.95, alpha: 1.0)
        } else {
            requestButton.setTitle("友だち申請", for: .normal)
            requestButton.setTitleColor(UIColor(hue: 0.07, saturation: 0.9, brightness: 0.95, alpha: 1.0), for: .normal)
            requestButton.layer.borderColor = UIColor.orange.cgColor
            requestButton.layer.borderWidth = 1
        }
    }

    @IBAction func request(_ sender: Any) {
        // デフォルトコンテナ（iCloud.com.gmail.mokamokayuuyuu.varmeets）のパブリックデータベースにアクセス
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        if let friendID = friendID {
            // 検索条件を作成
            let predicate = NSPredicate(format: "accountID == %@", argumentArray: [friendID])
            let query = CKQuery(recordType: "Accounts", predicate: predicate)
            
            // 検索したレコードの値を更新
            publicDatabase.perform(query, inZoneWith: nil, completionHandler: {(records, error) in
                if let error = error {
                    print("申請エラー1: \(error)")
                    return
                }
                
                for record in records! {
                    // すでに申請済みのとき
                    if self.requestedAccounts.contains(myID!) {
                        // 01~03のうち何番目に申請されているか
                        if let index = self.requestedAccounts.index(of: myID!) {
                            // 自分のIDがあるところにNOを挿入
                            record["requestedAccountID_0\((index + 1).description)"] = "NO"
                        }
                    }
                    
                    // これから申請するとき
                    else {
                        // 01~03のうち、NOのところに申請する
                        if self.requestedAccounts[0] == "NO" {
                            record["requestedAccountID_01"] = myID!
                        } else if self.requestedAccounts[1] == "NO" {
                            record["requestedAccountID_02"] = myID!
                        } else if self.requestedAccounts[2] == "NO" {
                            record["requestedAccountID_03"] = myID!
                        }
                        
                        // NOがないとき
                        else {
                            print("相手の申請数の上限を超えています")
                        }
                    }
                    
                    publicDatabase.save(record, completionHandler: {(record, error) in
                        if let error = error {
                            print("申請エラー2: \(error)")
                            return
                        }
                        print("友だち申請／キャンセル成功")
                    })
                }
            })
        }
    }
    
}
