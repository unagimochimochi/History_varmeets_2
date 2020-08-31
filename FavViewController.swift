//
//  FavViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/04/10.
//

import UIKit

var favPlaces = [String]()
var favAddresses = [String]()
var favLats = [Double]()
var favLons = [Double]()

class FavViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var favSearchBar: UISearchBar!
    @IBOutlet weak var favTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavCell", for:indexPath)
        
        if favPlaces.isEmpty == false {
            cell.textLabel?.text = favPlaces[indexPath.row]
            cell.detailTextLabel?.text = favAddresses[indexPath.row]
        } else {
            cell.textLabel?.text = "お気に入りはありません"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
