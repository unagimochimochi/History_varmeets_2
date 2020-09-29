//
//  HomeViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/02/26.
//

import UIKit
import CloudKit

var myID: String?
var myName: String?

let userDefaults = UserDefaults.standard

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // let userDefaults = UserDefaults.standard
    
    var dateAndTimes = [String]()
    var planTitles = [String]()
    // var participantImgs = [UIImage]()
    var participantNames = [String]()
    var places = [String]()
    var lons = [String]()
    var lats = [String]()
    
    var estimatedTimes = [Date]()
    var estimatedTimesSort = [Date]()
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var fetchedRequest = [String]()
    var friendIDs = [String]()
    var friendIDsToMe = [String]()
    
    @IBOutlet weak var planTable: UITableView!

    @IBOutlet weak var myIcon: UIButton!
    
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var countdownViewHeight: NSLayoutConstraint!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var countdownDateAndTimeLabel: UILabel!
    @IBOutlet weak var countdownPlanTitleLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    
    @IBAction func createdAccount(sender: UIStoryboardSegue) {
        if let firstVC = sender.source as? FirstViewController,
            let id = firstVC.id,
            let name = firstVC.name {
            
            myID = id
            myName = name
            
            userDefaults.set(id, forKey: "myID")
            userDefaults.set(name, forKey: "myName")
            
            let recordID = CKRecord.ID(recordName: "accountID-\(id)")
            let record = CKRecord(recordType: "Accounts", recordID: recordID)
            
            record["accountID"] = id as NSString
            record["accountName"] = name as NSString
            record["requestedAccountID_01"] = "NO" as NSString
            record["requestedAccountID_02"] = "NO" as NSString
            record["requestedAccountID_03"] = "NO" as NSString
            
            // レコードを保存
            publicDatabase.save(record, completionHandler: {(record, error) in
                if let error = error {
                    print("新規レコード保存エラー: \(error)")
                    return
                }
                print("アカウント作成成功")
            })
            
            var existingIDs = firstVC.existingIDs
            
            // 検索条件を作成
            let predicate = NSPredicate(format: "toSearch IN %@", ["all-varmeetsIDs"])
            let query = CKQuery(recordType: "AccountsList", predicate: predicate)
            
            existingIDs.append("accountID-\(id)")
            
            // 検索したレコードの値を更新
            publicDatabase.perform(query, inZoneWith: nil, completionHandler: {(records, error) in
                if let error = error {
                    print("アカウントリスト追加エラー1: \(error)")
                    return
                }
                
                for record in records! {
                    record["accounts"] = existingIDs as [String]
                    self.publicDatabase.save(record, completionHandler: {(record, error) in
                        if let error = error {
                            print("アカウントリスト追加エラー2: \(error)")
                            return
                        }
                    })
                }
                print("アカウントリスト追加成功")
            })
        }
    }
    
    @IBAction func becameFriends(sender: UIStoryboardSegue) {
        if let requestedVC = sender.source as? RequestedViewController {
            
            let requestedIDs = requestedVC.requestedIDs
            
            friendIDsToMe = friendIDs
            
            var count1 = 0
            while count1 < requestedIDs.count {
                
                if (requestedVC.requestedTableView.cellForRow(at: IndexPath(row: count1, section: 0)) as? RequestedCell)!.approval == true {
                    // 友だち一覧に申請者を追加
                    friendIDsToMe.append(requestedIDs[count1])
                }
                
                count1 += 1
            }
                
            // 自分のレコードの検索条件を作成
            let predicate1 = NSPredicate(format: "accountID == %@", argumentArray: [myID!])
            let query1 = CKQuery(recordType: "Accounts", predicate: predicate1)
                
            // 検索したレコードの値を更新
            publicDatabase.perform(query1, inZoneWith: nil, completionHandler: {(records, error) in
                if let error = error {
                    print("友だち一覧更新エラー1: \(error)")
                    return
                }
                        
                for record in records! {
                    
                    record["friends"] = self.friendIDsToMe as [String]
                    record["requestedAccountID_01"] = "NO" as NSString
                    record["requestedAccountID_02"] = "NO" as NSString
                    record["requestedAccountID_03"] = "NO" as NSString
                    
                    self.publicDatabase.save(record, completionHandler: {(record, error) in
                        if let error = error {
                            print("友だち一覧更新エラー2: \(error)")
                            return
                        }
                        print("友だち一覧更新成功")
                    })
                }
            })
            
            // 友だちの検索条件を作成
            // let predicate2 = NSPredicate(format: "accountID == %@", argumentArray: [requestedIDs[count2]])
            // let query2 = CKQuery(recordType: "Accounts", predicate: predicate2)
            
        }
    }
    
    @IBAction func unwindtoHomeVC(sender: UIStoryboardSegue) {
        // 日時
        guard let sourceVC1 = sender.source as? AddPlanViewController, let dateAndTime = sourceVC1.dateAndTime else {
            return
        }
        
        if let selectedIndexPath = self.planTable.indexPathForSelectedRow {
            self.dateAndTimes[selectedIndexPath.row] = dateAndTime
            self.estimatedTimes[selectedIndexPath.row] = (sourceVC1.addPlanTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? DateAndTimeCell)!.estimatedTime
            
        } else {
            self.dateAndTimes.append(dateAndTime)
            self.estimatedTimes.append((sourceVC1.addPlanTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? DateAndTimeCell)!.estimatedTime)
        }
        
        userDefaults.set(self.dateAndTimes, forKey: "DateAndTimes")
        userDefaults.set(self.estimatedTimes, forKey: "EstimatedTimes")
        
        // 予定タイトル
        guard let sourceVC2 = sender.source as? AddPlanViewController, let planTitle = sourceVC2.planTitle else {
            return
        }
        
        if let selectedIndexPath = self.planTable.indexPathForSelectedRow {
            self.planTitles[selectedIndexPath.row] = planTitle
            
        } else {
            self.planTitles.append(planTitle)
        }
        
        userDefaults.set(self.planTitles, forKey: "PlanTitles")
        
        // 場所
        guard let sourceVC4 = sender.source as? AddPlanViewController, let place = sourceVC4.place else {
            return
        }
        
        let lon = sourceVC4.lon
        let lat = sourceVC4.lat
        
        if let selectedIndexPath = self.planTable.indexPathForSelectedRow {
            self.places[selectedIndexPath.row] = place
            self.lons[selectedIndexPath.row] = lon
            self.lats[selectedIndexPath.row] = lat
            
        } else {
            self.places.append(place)
            self.lons.append(lon)
            self.lats.append(lat)
        }
        
        userDefaults.set(self.places, forKey: "Places")
        userDefaults.set(self.lons, forKey: "lons")
        userDefaults.set(self.lats, forKey: "lats")
        
        self.planTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hiddenCountdown()
        estimatedTimesSort.removeAll()
        
        // 左上のアイコン
        myIcon.layer.borderColor = UIColor.gray.cgColor // 枠線の色
        myIcon.layer.borderWidth = 1 // 枠線の太さ
        myIcon.layer.cornerRadius = myIcon.bounds.width / 2 // 丸くする
        myIcon.layer.masksToBounds = true // 丸の外側を消す

        // 1秒ごとに処理
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
        // 1秒後に処理
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 友だち申請されている場合
            if self.fetchedRequest.isEmpty == false {
                self.performSegue(withIdentifier: "toRequestedVC", sender: nil)
            }
        }
        
        if userDefaults.object(forKey: "myID") != nil {
            myID = userDefaults.string(forKey: "myID")
            print(myID!)
            
            // 友だち申請をデータベースから取得
            fetchRequest(id: myID!)
            // 友だち一覧をデータベースから取得
            fetchFriendIDs(id: myID!)
        }
        
        if userDefaults.object(forKey: "myName") != nil {
            myName = userDefaults.string(forKey: "myName")
            print(myName!)
        }
        
        if userDefaults.object(forKey: "DateAndTimes") != nil {
            self.dateAndTimes = userDefaults.stringArray(forKey: "DateAndTimes")!
        } else {
            self.dateAndTimes = ["日時"]
        }
        
        if userDefaults.object(forKey: "EstimatedTimes") != nil {
            self.estimatedTimes = userDefaults.array(forKey: "EstimatedTimes") as! [Date]
        } else {
            // estimatedTimesの初期値に 00:00:00 UTC on 1 January 2001 を設定
            let referenceDate = Date(timeIntervalSinceReferenceDate: 0.0)
            self.estimatedTimes = [referenceDate]
        }
        
        if userDefaults.object(forKey: "PlanTitles") != nil {
            self.planTitles = userDefaults.stringArray(forKey: "PlanTitles")!
        } else {
            self.planTitles = ["予定サンプル"]
        }
        
        if userDefaults.object(forKey: "Places") != nil {
            self.places = userDefaults.stringArray(forKey: "Places")!
        } else {
            self.places = ["場所"]
        }
        
        if userDefaults.object(forKey: "lons") != nil {
            self.lons = userDefaults.stringArray(forKey: "lons")!
            self.lats = userDefaults.stringArray(forKey: "lats")!
        } else {
            self.lons = ["経度"]
            self.lats = ["緯度"]
        }
        
        // self.participantImgs = ["FriendsNoimg"]
        self.participantNames = ["参加者"]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // print(#function)

        if let indexPath = planTable.indexPathForSelectedRow {
            planTable.deselectRow(at: indexPath, animated: true)
        }
        
        // 初回起動時のみFirstVCに遷移
        let firstUserDefaults = UserDefaults.standard
        let firstLaunchKey = "firstLaunch"
        
        if firstUserDefaults.bool(forKey: firstLaunchKey) {
            firstUserDefaults.set(false, forKey: firstLaunchKey)
            firstUserDefaults.synchronize()
            
            self.performSegue(withIdentifier: "toFirstVC", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCell", for: indexPath)
        // let img = UIImage(named: participantImgs[indexPath.row] as! String)
        
        let dateAndTimeLabel = cell.viewWithTag(1) as! UILabel
        dateAndTimeLabel.text = self.dateAndTimes[indexPath.row]
        
        let planTitleLabel = cell.viewWithTag(2) as! UILabel
        planTitleLabel.text = self.planTitles[indexPath.row]
        /*
         // let participantImageView = cell.viewWithTag(3) as! UIImageView
         // participantImageView.image = img
         
         let participantLabel = cell.viewWithTag(4) as! UILabel
         participantLabel.text = self.participantNames[indexPath.row]
         */
        let placeLabel = cell.viewWithTag(5) as! UILabel
        placeLabel.text = self.places[indexPath.row]
        print("経度: \(self.lons[indexPath.row]), 緯度: \(self.lats[indexPath.row])")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateAndTimes.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.dateAndTimes.remove(at: indexPath.row)
            userDefaults.set(self.dateAndTimes, forKey: "DateAndTimes")
            
            self.estimatedTimes.remove(at: indexPath.row)
            userDefaults.set(self.estimatedTimes, forKey: "EstimatedTimes")
            
            self.planTitles.remove(at: indexPath.row)
            userDefaults.set(self.planTitles, forKey: "PlanTitles")
            
            self.places.remove(at: indexPath.row)
            userDefaults.set(self.places, forKey: "Places")
            
            self.lons.remove(at: indexPath.row)
            userDefaults.set(self.lons, forKey: "lons")
            
            self.lats.remove(at: indexPath.row)
            userDefaults.set(self.lats, forKey: "lats")
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @objc func update() {
        
        let now = Date()
        let calendar = Calendar(identifier: .japanese)
        
        // 予定サンプルが消されていないとき
        if planTitles.contains("予定サンプル") == true {
            // サンプル以外の予定が登録されているとき
            if estimatedTimes.count >= 2 {
                print("サンプルあり、サンプル以外の予定あり")
                // 並べ替え用の配列に予定時刻をセット
                estimatedTimesSort = estimatedTimes
                // 並べ替え用の配列で並べ替え
                estimatedTimesSort.sort { $0 < $1 }
                
                let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: now, to: estimatedTimesSort[1])
                
                // 一番近い予定のindexを取得
                if let index = estimatedTimes.index(of: estimatedTimesSort[1]) {
                    // 1時間未満のとき
                    if components.month! == 0 && components.day! == 0 && components.hour! == 0 &&
                        components.minute! >= 0 && components.minute! <= 59 &&
                        components.second! >= 0 && components.second! <= 59 {
                        print("サンプルあり、1時間未満の予定あり")
                        // カウントダウンを表示
                        displayCountdown()
                        
                        // 背景をオレンジにする
                        countdownView.backgroundColor = UIColor.init(hue: 0.07, saturation: 0.9, brightness: 0.9, alpha: 1.0)
                        
                        countdownLabel.text = String(format: "%02d:%02d", components.minute!, components.second!)
                        countdownDateAndTimeLabel.text = dateAndTimes[index]
                        countdownPlanTitleLabel.text = planTitles[index]
                    }
                    
                    // 予定時刻を過ぎたとき
                    else if components.month! <= 0 && components.day! <= 0 && components.hour! <= 0 && components.minute! <= 0 && components.second! <= 0 {
                        print("予定時刻を過ぎた")
                        
                        if countdownView.isHidden == false {
                            // 背景を赤にする
                            countdownView.backgroundColor = UIColor.init(hue: 0.03, saturation: 0.9, brightness: 0.9, alpha: 1.0)
                            
                            countdownLabel.text = "00:00"
                        }
                    }
                }
            }
                
            // 予定がサンプルのみのとき
            else {
                print("サンプルのみ")
                // カウントダウンを非表示
                hiddenCountdown()
            }
        }
        
        // 予定サンプルが消されているとき
        else {
            // 予定が登録されているとき
            if estimatedTimes.isEmpty == false {
                // 並べ替え用の配列に予定時刻をセット
                estimatedTimesSort = estimatedTimes
                // 並べ替え用の配列で並べ替え
                estimatedTimesSort.sort { $0 < $1 }
                
                let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: now, to: estimatedTimesSort[0])
                
                // 一番近い予定のindexを取得
                if let index = estimatedTimes.index(of: estimatedTimesSort[0]) {
                    // 1時間未満のとき
                    if components.month! == 0 && components.day! == 0 && components.hour! == 0 &&
                        components.minute! >= 0 && components.minute! <= 59 &&
                        components.second! >= 0 && components.second! <= 59 {
                        // カウントダウンを表示
                        displayCountdown()
                        
                        // 背景をオレンジにする
                        countdownView.backgroundColor = UIColor.init(hue: 0.07, saturation: 0.9, brightness: 0.95, alpha: 1.0)
                        
                        countdownLabel.text = String(format: "%02d:%02d", components.minute!, components.second!)
                        countdownDateAndTimeLabel.text = dateAndTimes[index]
                        countdownPlanTitleLabel.text = planTitles[index]
                    }
                    
                    // 予定時刻を過ぎたとき
                    else if components.month! <= 0 && components.day! <= 0 && components.hour! <= 0 && components.minute! <= 0 && components.second! <= 0 {
                        print("予定時刻を過ぎた")
                        
                        if countdownView.isHidden == false {
                            // 背景を赤にする
                            countdownView.backgroundColor = UIColor.init(hue: 0.03, saturation: 0.9, brightness: 0.9, alpha: 1.0)
                            
                            countdownLabel.text = "00:00"
                        }
                    }
                }
            }
            
            // 予定がひとつも登録されていないとき
            else {
                print("予定なし")
                // カウントダウンを非表示
                hiddenCountdown()
            }
        }
    }
    
    @IBAction func tappedCompleteButton(_ sender: Any) {
        // カウントダウンを非表示
        hiddenCountdown()
        
        // 予定サンプルが消されていないとき
        if planTitles.contains("予定サンプル") == true {
            // 並べ替え用の配列に予定時刻をセット
            estimatedTimesSort = estimatedTimes
            // 並べ替え用の配列で並べ替え
            estimatedTimesSort.sort { $0 < $1 }
            
            // 一番近い予定のindexを取得
            if let index = estimatedTimes.index(of: estimatedTimesSort[1]) {
                // index番目の配列とuserDefaultsを削除
                remove(index: index)
            }
        }
        
        // 予定サンプルが消されているとき
        else {
            // 並べ替え用の配列に予定時刻をセット
            estimatedTimesSort = estimatedTimes
            // 並べ替え用の配列で並べ替え
            estimatedTimesSort.sort { $0 < $1 }
            
            // 一番近い予定のindexを取得
            if let index = estimatedTimes.index(of: estimatedTimesSort[0]) {
                // index番目の配列とuserDefaultsを削除
                remove(index: index)
            }
        }
        
        planTable.reloadData()
    }
    
    func fetchRequest(id: String) {
        let recordID = CKRecord.ID(recordName: "accountID-\(id)")
        
        publicDatabase.fetch(withRecordID: recordID, completionHandler: {(record, error) in
            if let error = error {
                print("友だち申請取得エラー: \(error)")
                return
            }
            
            if let request01 = record?.value(forKey: "requestedAccountID_01") as? String {
                self.fetchedRequest.append(request01)
            }
            if let request02 = record?.value(forKey: "requestedAccountID_02") as? String {
                self.fetchedRequest.append(request02)
            }
            if let request03 = record?.value(forKey: "requestedAccountID_03") as? String {
                self.fetchedRequest.append(request03)
            }
            print(self.fetchedRequest)
            
            // 申請者のIDのみ配列に残す
            while self.fetchedRequest.contains("NO") {
                if let index = self.fetchedRequest.index(of: "NO") {
                    self.fetchedRequest.remove(at: index)
                }
            }
            print(self.fetchedRequest)
        })
    }
    
    func fetchFriendIDs(id: String) {
        let recordID = CKRecord.ID(recordName: "accountID-\(id)")
        
        publicDatabase.fetch(withRecordID: recordID, completionHandler: {(record, error) in
            if let error = error {
                print("友だち一覧取得エラー: \(error)")
                return
            }
            
            if let friendIDs = record?.value(forKey: "friends") as? [String] {
                for friendID in friendIDs {
                    self.friendIDs.append(friendID)
                }
                print(self.friendIDs)
            } else {
                print("友だち0人")
            }
        })
    }
    
    func displayCountdown() {
        
        countdownViewHeight.constant = 200
        countdownLabel.isHidden = false
        countdownDateAndTimeLabel.isHidden = false
        countdownPlanTitleLabel.isHidden = false
        completeButton.isHidden = false
        completeButton.isEnabled = true
    }
    
    func hiddenCountdown() {
        
        countdownViewHeight.constant = 0
        countdownLabel.isHidden = true
        countdownDateAndTimeLabel.isHidden = true
        countdownPlanTitleLabel.isHidden = true
        completeButton.isHidden = true
        completeButton.isEnabled = false
    }
    
    func remove(index: Int) {
        
        dateAndTimes.remove(at: index)
        userDefaults.set(self.dateAndTimes, forKey: "DateAndTimes")
        
        self.estimatedTimes.remove(at: index)
        userDefaults.set(self.estimatedTimes, forKey: "EstimatedTimes")
        
        self.planTitles.remove(at: index)
        userDefaults.set(self.planTitles, forKey: "PlanTitles")
        
        self.places.remove(at: index)
        userDefaults.set(self.places, forKey: "Places")
        
        self.lons.remove(at: index)
        userDefaults.set(self.lons, forKey: "lons")
        
        self.lats.remove(at: index)
        userDefaults.set(self.lats, forKey: "lats")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        if identifier == "toPlanDetails" {
            let planDetailsVC = segue.destination as! PlanDetailsViewController
            planDetailsVC.dateAndTime = self.dateAndTimes[(self.planTable.indexPathForSelectedRow?.row)!]
            planDetailsVC.planTitle = self.planTitles[(self.planTable.indexPathForSelectedRow?.row)!]
            planDetailsVC.place = self.places[(self.planTable.indexPathForSelectedRow?.row)!]
            planDetailsVC.lonStr = self.lons[(self.planTable.indexPathForSelectedRow?.row)!]
            planDetailsVC.latStr = self.lats[(self.planTable.indexPathForSelectedRow?.row)!]
        }
        
        if identifier == "toRequestedVC" {
            let requestedVC = segue.destination as! RequestedViewController
            requestedVC.requestedIDs = self.fetchedRequest
        }
    }
    
}

