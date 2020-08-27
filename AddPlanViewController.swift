//
//  AddPlanViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/05/15.
//
// TableView 基礎 https://qiita.com/pe-ta/items/cafa8e20029047993025
// セルごとアクションを変える https://tech.pjin.jp/blog/2016/09/24/tableview-14/

import UIKit

class AddPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var planTitle: String?
    var dateAndTime: String!
    var address: String?
    var place: String?
    var lon: String = ""
    var lat: String = ""
    
    @IBOutlet weak var addPlanTable: UITableView!
    
    @IBOutlet weak var planTitleTextField: UITextField!
    
    // キャンセルボタン
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 保存ボタン
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var planItem = ["日時","参加者","場所","共有開始","通知"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        planTitleTextField.delegate = self
        
        addPlanTable.dataSource = self
        
        if let planTitle = self.planTitle {
            self.planTitleTextField.text = planTitle
        }
    }
    
    // 場所を選択画面からの巻き戻し
    @IBAction func unwindToAddPlanVCFromSearchPlaceVC(sender: UIStoryboardSegue) {
        if let sourceVC = sender.source as? SearchPlaceViewController {
            // 日時をすでに出力していたとき
            if let dateAndTime = sourceVC.dateAndTime {
                self.dateAndTime = dateAndTime
            }
            
            if let place = sourceVC.place, let lat = sourceVC.lat, let lon = sourceVC.lon {
                self.address = place
                self.lat = lat
                self.lon = lon
            }
        }
        
        addPlanTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateAndTimeCell", for:indexPath) as! DateAndTimeCell
            cell.textLabel?.text = planItem[indexPath.row]
            cell.displayDateAndTimeTextField.text = dateAndTime
            
            return cell
            
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for:indexPath) // as UITableViewCell
            cell.textLabel?.text = planItem[indexPath.row]
            
            return cell
            
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for:indexPath) as! PlaceCell
            cell.textLabel?.text = planItem[indexPath.row]
            
            // MapVCから住所が渡ってきたとき
            if let address = self.address {
                cell.displayPlaceTextField.text = address
            }
            // PlanDetailsVCから場所の名前が渡ってきたとき
            if let place = self.place {
                cell.displayPlaceTextField.text = place
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for:indexPath) // as UITableViewCell
            cell.textLabel?.text = planItem[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return planItem.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print("\(indexPath.row)番セルをタップ")
        tableView.deselectRow(at: indexPath, animated: true) // セルの選択を解除
        
        if indexPath.row == 0 {
            if let cell = tableView.cellForRow(at: indexPath) as? DateAndTimeCell {
                cell.displayDateAndTimeTextField.becomeFirstResponder()
            }
        } else {
            // 0番セル以外をクリックしたらキーボードを閉じる
            view.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        self.view.endEditing(true)
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if let identifier = segue.identifier {
            if identifier == "toSearchPlaceVC" {
                let searchPlaceVC = segue.destination as! SearchPlaceViewController
                self.dateAndTime = (addPlanTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? DateAndTimeCell)?.displayDateAndTimeTextField.text ?? ""
                searchPlaceVC.dateAndTime = self.dateAndTime
            }
        }
        
        guard let button = sender as? UIBarButtonItem, button === self.saveButton else {
            return
        }
        self.planTitle = self.planTitleTextField.text ?? ""
        self.dateAndTime = (addPlanTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? DateAndTimeCell)?.displayDateAndTimeTextField.text ?? ""
        self.place = (addPlanTable.cellForRow(at: IndexPath(row: 2, section: 0)) as? PlaceCell)?.displayPlaceTextField.text ?? ""
    }
    
}
