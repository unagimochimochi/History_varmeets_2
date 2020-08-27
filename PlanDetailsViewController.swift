//
//  PlanDetailsViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/07/06.
//

import UIKit

class PlanDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let planItem = ["参加者","場所","共有開始","通知"]
    
    var planTitle: String?
    var dateAndTime: String?
    var place: String?
    var lonStr: String?
    var latStr: String?
    
    // @IBOutlet weak var PlanDetailsTableView: UITableView!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dateAndTime = self.dateAndTime {
            dateAndTimeLabel.text = dateAndTime
        }
        
        if let planTitle = self.planTitle {
            self.navigationItem.title = planTitle
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlanDetailPlaceCell", for: indexPath)
            cell.textLabel?.text = planItem[indexPath.row]
            
            if let place = self.place {
                let placeLabel = cell.viewWithTag(1) as! UILabel
                placeLabel.text = place
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlanDetailsCell", for: indexPath)
            cell.textLabel?.text = planItem[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planItem.count
    }
    
    // Cell の高さを68にする
    func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        if identifier == "editPlan" {
            let addPlanVC = segue.destination as! AddPlanViewController
            addPlanVC.planTitle = self.planTitle
            addPlanVC.dateAndTime = self.dateAndTime
            addPlanVC.place = self.place
            addPlanVC.lon = self.lonStr ?? ""
            addPlanVC.lat = self.latStr ?? ""
        }

        else if identifier == "toPlaceVC" {
            let placeVC = segue.destination as! PlaceViewController
            placeVC.place = self.place
            placeVC.lonStr = self.lonStr
            placeVC.latStr = self.latStr
        }
    }
    
}
