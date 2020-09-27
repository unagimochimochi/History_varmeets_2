//
//  RequestedViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/09/27.
//

import UIKit

class RequestedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var requestedIDs = [String]()

    @IBOutlet weak var requestedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestedTableView.delegate = self
        requestedTableView.dataSource = self

        print("リクエストID: \(requestedIDs)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestedIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        
        let icon = cell.viewWithTag(1) as! UIImageView
        icon.layer.borderColor = UIColor.gray.cgColor // 枠線の色
        icon.layer.borderWidth = 0.5 // 枠線の太さ
        icon.layer.cornerRadius = icon.bounds.width / 2 // 丸くする
        icon.layer.masksToBounds = true // 丸の外側を消す
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
