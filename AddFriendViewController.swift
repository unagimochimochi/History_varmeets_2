//
//  AddFriendViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/09/21.
//

import UIKit
import CloudKit

class AddFriendViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var fetchedFriendID: String?
    var fetchedFriendName: String?
    
    @IBOutlet weak var friendsSearchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsSearchBar.delegate = self
        resultsTableView.delegate = self
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        fetchedFriendID = nil
        fetchedFriendName = nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードをとじる
        self.view.endEditing(true)
        
        if let text = searchBar.text {
            fetchFriendInfo(friendID: text)
            
            // 1秒後に処理
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let id = self.fetchedFriendID, let name = self.fetchedFriendName {
                    print("ID: \(id), Name: \(name)")
                    
                    self.resultsTableView.reloadData()
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // テキストを空にする
        searchBar.text = ""
        // キーボードをとじる
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foundFriendCell", for: indexPath)
        return cell
    }

    func fetchFriendInfo(friendID: String) {
        // デフォルトコンテナ（iCloud.com.gmail.mokamokayuuyuu.varmeets）のパブリックデータベースにアクセス
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: "accountID-\(friendID)")
        
        publicDatabase.fetch(withRecordID: recordID, completionHandler: {(record, error) in
            if let error = error {
                print("友だちの情報取得エラー: \(error)")
                return
            }
            
            if let id = record?.value(forKey: "accountID") as? String, let name = record?.value(forKey: "accountName") as? String {
                self.fetchedFriendID = id
                self.fetchedFriendName = name
            }
        })
    }
}
