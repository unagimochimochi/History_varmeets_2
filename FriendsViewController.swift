//
//  ReFriendsViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/06/06.
//
// Label受け渡し参考 https://qiita.com/azuma317/items/6b800bfca423e8fe2cf6

import UIKit

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var friendsTableView: UITableView!
    
    var selectedImage: UIImage?
    var giveName: String = ""
    var giveID: String = ""
    var giveBio: String = ""
    
    // section毎の画像配列
    let imgArray: NSArray = ["Toshihiro","Yuka"]
    
    let label1Array: [String] = ["利洋","優香"]
    let label2Array: [String] = ["@toshihiro_sanada","@yuyuyuyuyukakka"]
    let label3Array: [String] = ["SUACデザイン2年。ラーメン！！！","パンケーキ食べる人、誘ってください"]
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        let img = UIImage(named: imgArray[indexPath.row] as! String)
        
        // Tag番号 1 で UIImageView インスタンスの生成
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = img
        imageView.layer.borderColor = UIColor.gray.cgColor // 枠線の色
        imageView.layer.borderWidth = 0.5 // 枠線の太さ
        imageView.layer.cornerRadius = imageView.bounds.width / 2 // 丸くする
        imageView.layer.masksToBounds = true // 丸の外側を消す
        
        // Tag番号 ２ で UILabel インスタンスの生成
        let label1 = cell.viewWithTag(2) as! UILabel
        label1.text = String(describing: label1Array[indexPath.row])
        
        // Tag番号 ３ で UILabel インスタンスの生成
        let label2 = cell.viewWithTag(3) as! UILabel
        label2.text = String(describing: label2Array[indexPath.row])
        
        return cell
    }
    
    // Cell の高さを60にする
    func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ table: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        // [indexPath.row] から画像名を探し、UImage を設定
        selectedImage = UIImage(named: imgArray[indexPath.row] as! String)
        self.giveName = self.label1Array[indexPath.item]
        self.giveID = self.label2Array[indexPath.item]
        self.giveBio = self.label3Array[indexPath.item]
        if selectedImage != nil {
            performSegue(withIdentifier: "toFriendProfileVC", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toFriendProfileVC" {
            let fpVC = segue.destination as! FriendProfileViewController
            // SubViewController のselectedImgに選択された画像を設定する
            fpVC.selectedImg = selectedImage
            fpVC.receiveName = giveName
            fpVC.receiveID = giveID
            fpVC.receiveBio = giveBio
        }
    }

}
