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
        
        if userDefaults.object(forKey: "favPlaces") != nil {
            favPlaces = userDefaults.stringArray(forKey: "favPlaces")!
        } else {
            favPlaces = ["お気に入り"]
        }
        
        if userDefaults.object(forKey: "favAddresses") != nil {
            favAddresses = userDefaults.stringArray(forKey: "favAddresses")!
        } else {
            favAddresses = ["住所"]
        }
        
        if userDefaults.object(forKey: "favLats") != nil {
            favLats = userDefaults.array(forKey: "favLats") as! [Double]
        } else {
            favLats = [35.658584]
        }
        
        if userDefaults.object(forKey: "favLons") != nil {
            favLons = userDefaults.array(forKey: "favLons") as! [Double]
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
            userDefaults.set(favPlaces, forKey: "favPlaces")
            
            favAddresses.remove(at: indexPath.row)
            userDefaults.set(favAddresses, forKey: "favAddresses")
            
            favLats.remove(at: indexPath.row)
            userDefaults.set(favLats, forKey: "favLats")
            
            favLons.remove(at: indexPath.row)
            userDefaults.set(favLons, forKey: "favLons")
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        if identifier == "toFavPlaceVC" {
            let favPlaceVC = segue.destination as! FavPlaceViewController
            favPlaceVC.place = favPlaces[(favTableView.indexPathForSelectedRow?.row)!]
            favPlaceVC.lat = favLats[(favTableView.indexPathForSelectedRow?.row)!]
            favPlaceVC.lon = favLons[(favTableView.indexPathForSelectedRow?.row)!]
        }
    }

}
