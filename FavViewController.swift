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

let favUserDefaults = UserDefaults.standard

class FavViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var favSearchBar: UISearchBar!
    @IBOutlet weak var favTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if favUserDefaults.object(forKey: "favPlaces") != nil {
            favPlaces = favUserDefaults.stringArray(forKey: "favPlaces")!
        } else {
            favPlaces = ["お気に入り"]
        }
        
        if favUserDefaults.object(forKey: "favAddresses") != nil {
            favAddresses = favUserDefaults.stringArray(forKey: "favAddresses")!
        } else {
            favAddresses = ["住所"]
        }
        
        if favUserDefaults.object(forKey: "favLats") != nil {
            favLats = favUserDefaults.array(forKey: "favLats") as! [Double]
        } else {
            favLats = [35.658584]
        }
        
        if favUserDefaults.object(forKey: "favLons") != nil {
            favLons = favUserDefaults.array(forKey: "favLons") as! [Double]
        } else {
            favLons = [139.7454316]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        favTableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            favPlaces.remove(at: indexPath.row)
            favUserDefaults.set(favPlaces, forKey: "favPlaces")
            
            favAddresses.remove(at: indexPath.row)
            favUserDefaults.set(favAddresses, forKey: "favAddresses")
            
            favLats.remove(at: indexPath.row)
            favUserDefaults.set(favLats, forKey: "favLats")
            
            favLons.remove(at: indexPath.row)
            favUserDefaults.set(favLons, forKey: "favLons")
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}
