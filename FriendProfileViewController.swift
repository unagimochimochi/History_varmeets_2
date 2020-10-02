//
//  FriendProfileViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/06/05.
//

import Foundation
import UIKit

class FriendProfileViewController: UIViewController{
    
    @IBOutlet var icon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var receiveName: String = ""
    var receiveID: String = ""
    var receiveBio: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        icon.layer.borderColor = UIColor.gray.cgColor // 枠線の色
        icon.layer.borderWidth = 1 // 枠線の太さ
        icon.layer.cornerRadius = icon.bounds.width / 2 // 丸くする
        icon.layer.masksToBounds = true // 丸の外側を消す
        
        nameLabel.text = receiveName
        idLabel.text = receiveID
        
        bioLabel.text = receiveBio
        if receiveBio != "自己紹介が未入力です" {
            bioLabel.textColor = .black
        }
        
        self.navigationItem.title = receiveName
    }
}
