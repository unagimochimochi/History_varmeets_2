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
    
    var planID: String?
    
    var planTitle: String?
    var dateAndTime: String!
    var participantIDs = [String]()
    var participantNames = [String]()
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
    
    var planItem = ["日時","参加者","場所"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        planTitleTextField.delegate = self
        
        addPlanTable.dataSource = self
        
        if let planTitle = self.planTitle {
            self.planTitleTextField.text = planTitle
        }
    }
    
    // 参加者を選択画面からの巻き戻し
    @IBAction func unwindToAddPlanVCFromSearchParticipantVC(sender: UIStoryboardSegue) {
        if let sourceVC = sender.source as? SearchParticipantViewController {
            // 日時をすでに出力していたとき
            if let dateAndTime = sourceVC.dateAndTime {
                self.dateAndTime = dateAndTime
            }
            
            var count = 0
            
            while count < sourceVC.friendIDs.count {
                if sourceVC.checkmark[count] == true {
                    self.participantIDs.append(sourceVC.friendIDs[count])
                    self.participantNames.append(sourceVC.friendNames[count])
                }
                count += 1
            }
            
            if count == sourceVC.friendIDs.count {
                addPlanTable.reloadData()
            }
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
                self.place = place
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
            
        }
        
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for:indexPath) as! ParticipantCell
            cell.textLabel?.text = planItem[indexPath.row]
            
            if participantIDs.count == 0 {
                cell.hidden1()
                cell.hidden2()
                cell.hidden3()
                cell.hiddenOthers()
            }
            
            else if participantIDs.count == 1 {
                cell.display1()
                cell.hidden2()
                cell.hidden3()
                cell.hiddenOthers()
                
                cell.participant1Name.text = participantNames[0]
            }
            
            else if participantIDs.count == 2 {
                cell.display1()
                cell.display2()
                cell.hidden3()
                cell.hiddenOthers()
                
                cell.participant1Name.text = participantNames[0]
                cell.participant2Name.text = participantNames[1]
            }
            
            else if participantIDs.count == 3 {
                cell.display1()
                cell.display2()
                cell.display3()
                cell.hiddenOthers()
                
                cell.participant1Name.text = participantNames[0]
                cell.participant2Name.text = participantNames[1]
                cell.participant3Name.text = participantNames[2]
            }
            
            else {
                cell.display1()
                cell.display2()
                cell.display3()
                cell.displayOthers()
                
                cell.participant1Name.text = participantNames[0]
                cell.participant2Name.text = participantNames[1]
                cell.participant3Name.text = participantNames[2]
                cell.othersLabel.text = "他\(participantNames.count - 3)人"
            }
            
            return cell
            
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for:indexPath) as! PlaceCell
            cell.textLabel?.text = planItem[indexPath.row]

            if let place = self.place {
                cell.displayPlaceTextField.text = place
            }
            
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
            
            if identifier == "toSearchParticipantVC" {
                let searchParticipantVC = segue.destination as! SearchParticipantViewController
                self.dateAndTime = (addPlanTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? DateAndTimeCell)?.displayDateAndTimeTextField.text ?? ""
                searchParticipantVC.dateAndTime = self.dateAndTime
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
