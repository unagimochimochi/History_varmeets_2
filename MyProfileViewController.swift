//
//  MyProfileViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/09/19.
//

import UIKit
import CloudKit

class MyProfileViewController: UIViewController {
    
    var fetchedBio: String?
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var header: UIImageView!
    @IBOutlet weak var bioLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let id = myID {
            fetchMyBio(myID: id)
            
            // 1秒後に処理
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let bio = self.fetchedBio {
                    self.bioLabel.text = bio
                    self.bioLabel.textColor = .black
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let id = myID, let name = myName {
            idLabel.text = id
            nameLabel.text = name
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editedMyProfile(sender: UIStoryboardSegue) {
        if let editMyProfileVC = sender.source as? EditMyProfileViewController,
            let name = editMyProfileVC.name,
            let bio = editMyProfileVC.bio {
            
            myName = name
            userDefaults.set(name, forKey: "myName")
            
            nameLabel.text = name
            bioLabel.text = bio
            bioLabel.textColor = .black
        }
    }

    func fetchMyBio(myID: String) {
        // デフォルトコンテナ（iCloud.com.gmail.mokamokayuuyuu.varmeets）のパブリックデータベースにアクセス
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: "accountID-\(myID)")
        
        publicDatabase.fetch(withRecordID: recordID, completionHandler: {(record, error) in
            if let error = error {
                print("Bio取得エラー: \(error)")
                return
            }
            
            else if let bio = record?.value(forKey: "accountBio") as? String {
                print("Bio取得成功")
                self.fetchedBio = bio
            } else {
                print("クラウドのBioが空")
            }
        })
    }
    
}
