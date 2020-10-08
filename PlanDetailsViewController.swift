//
//  PlanDetailsViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/07/06.
//

import UIKit
import CloudKit

class PlanDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let planItem = ["予定作成者", "参加者","場所"]
    
    var planID: String?
    
    var planTitle: String?
    var dateAndTime: String?
    
    var authorID: String? {
        didSet {
            fetchAuthorInfo()
        }
    }
    
    var authorName: String?
    
    var participantIDs = [String]()
    var participantNames = [String]()
    var place: String?
    var lonStr: String?
    var latStr: String?
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var timer1: Timer!
    var timer2: Timer!
    var checkCount1 = 0
    var checkCount2 = 0
    
    @IBOutlet weak var planDetailsTableView: UITableView!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchParticipants()
        
        // タイマー1スタート
        timer1 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(update1), userInfo: nil, repeats: true)
        
        if let dateAndTime = self.dateAndTime {
            dateAndTimeLabel.text = dateAndTime
        }
        
        if let planTitle = self.planTitle {
            self.navigationItem.title = planTitle
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
            
        if let workingTimer1 = timer1 {
            workingTimer1.invalidate()
        }
            
        if let workingTimer2 = timer2 {
            workingTimer2.invalidate()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlanDetailAuthorCell", for: indexPath)
            cell.textLabel?.text = planItem[indexPath.row]
            
            let icon = cell.viewWithTag(1) as! UIButton
            icon.layer.borderColor = UIColor.gray.cgColor // 枠線の色
            icon.layer.borderWidth = 1 // 枠線の太さ
            icon.layer.cornerRadius = icon.bounds.width / 2 // 丸くする
            icon.layer.masksToBounds = true // 丸の外側を消す
            
            let authorNameLabel = cell.viewWithTag(2) as! UILabel
            authorNameLabel.text = authorName
            
            return cell
        }
        
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlanDetailParticipantCell", for: indexPath) as! PlanDetailParticipantCell
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
        
        else if indexPath.row == 2 {
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
    
    @objc func update1() {
        print("update1")
        
        // participantIDs配列がデータベースの参加者一覧と同じ要素数になったら
        if participantIDs.count == checkCount1 {
            // タイマー1を止める
            if let workingTimer = timer1 {
                workingTimer.invalidate()
            }
            
            // 各々の参加者の情報を取得
            var count = 0
            while count < participantIDs.count {
                if checkCount2 == count {
                    fetchParticipantInfo(count)
                    count += 1
                }
            }
            
            // タイマー2スタート
            timer2 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(update2), userInfo: nil, repeats: true)
        }
    }
    
    @objc func update2() {
        print("update2")
        
        // 繰り返し処理のカウントがparticipantIDsと同じ数になったら（すべての参加者の情報を取得し終えたら）
        if checkCount2 == participantIDs.count {
            // タイマー2を止める
            if let workingTimer = timer2 {
                workingTimer.invalidate()
            }
            
            // UI更新
            planDetailsTableView.reloadData()
        }
    }
        
    // データベースから作成者と参加者のIDを取得
    func fetchParticipants() {
        
        let recordID = CKRecord.ID(recordName: "planID-\(planID!)")
        
        publicDatabase.fetch(withRecordID: recordID, completionHandler: {(record, error) in
            
            if let error = error {
                print("参加者一覧取得エラー: \(error)")
                return
            }
            
            if let author = record?.value(forKey: "authorID") as? String {
                self.authorID = author
            }
            
            if let participantIDs = record?.value(forKey: "participantIDs") as? [String] {
                
                self.checkCount1 = participantIDs.count
                
                for participantID in participantIDs {
                    print("success!")
                    self.participantIDs.append(participantID)
                }
            }
        })
    }
    
    func fetchParticipantInfo(_ count: Int) {
        
        let recordID = CKRecord.ID(recordName: "accountID-\(participantIDs[count])")
        
        publicDatabase.fetch(withRecordID: recordID, completionHandler: {(record, error) in
            
            if let error = error {
                print("\(count + 1)番目の参加者の情報取得エラー: \(error)")
                return
            }
            
            if let name = record?.value(forKey: "accountName") as? String {
                self.participantNames.append(name)
                self.checkCount2 = count + 1
            }
        })
    }
    
    func fetchAuthorInfo() {
        
        let recordID = CKRecord.ID(recordName: "accountID-\(authorID!)")
        
        publicDatabase.fetch(withRecordID: recordID, completionHandler: {(record, error) in
            
            if let error = error {
                print("作成者の情報取得エラー: \(error)")
                return
            }
            
            if let name = record?.value(forKey: "accountName") as? String {
                self.authorName = name
            }
        })
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
