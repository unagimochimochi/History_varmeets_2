//
//  HomeViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/02/26.
//

import UIKit
import MapKit
import CloudKit

var myID: String?
var myName: String?

let userDefaults = UserDefaults.standard

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var planIDs = [String]()
    var planIDsOnDatabase = [String]()
    
    var dateAndTimes = [String]()
    var planTitles = [String]()
    var participantNames = [String]()
    var numberOfParticipants = [Int]()
    var places = [String]()
    var lons = [String]()
    var lats = [String]()
    
    var estimatedTimes = [Date]()
    var estimatedTimesSort = [Date]()
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var fetchedRequest = [String]()
    var friendIDs = [String]() // 起動時の友だち一覧
    var friendIDsToMe = [String]() // friendIDs配列に申請許可者を追加した一覧
    
    var timer: Timer!
    
    var addPlanIDCheckCount = 0
    
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
            
            var count2 = 0
            while count2 < requestedIDs.count {
                
                // 友だちの友だち一覧を格納する配列
                var fetchedFriendFriendIDs = [String]()
                
                let friendRecordID = CKRecord.ID(recordName: "accountID-\(requestedIDs[count2])")
                
                publicDatabase.fetch(withRecordID: friendRecordID, completionHandler: {(record, error) in
                    if let error = error {
                        print("友だちの友だち一覧取得エラー: \(error)")
                        return
                    }
                    
                    if let friendFriendIDs = record?.value(forKey: "friends") as? [String] {
                        for friendFriendID in friendFriendIDs {
                            fetchedFriendFriendIDs.append(friendFriendID)
                        }
                        print(fetchedFriendFriendIDs)
                    }
                })
                
                // 友だちの検索条件を作成
                let predicate2 = NSPredicate(format: "accountID == %@", argumentArray: [requestedIDs[count2]])
                let query2 = CKQuery(recordType: "Accounts", predicate: predicate2)
                
                if (requestedVC.requestedTableView.cellForRow(at: IndexPath(row: count2, section: 0)) as? RequestedCell)!.approval == true {
                    // 友だちの友だち一覧に自分を追加
                    fetchedFriendFriendIDs.append(myID!)
                }
                
                publicDatabase.perform(query2, inZoneWith: nil, completionHandler: {(records, error) in
                    if let error = error {
                        print("\(count2.description)番目の友だちの友だち一覧更新エラー1: \(error)")
                        return
                    }
                    
                    for record in records! {
                        record["friends"] = fetchedFriendFriendIDs as [String]
                        
                        self.publicDatabase.save(record, completionHandler: {(record, error) in
                            if let error = error {
                                print("\(count2.description)番目の友だちの友だち一覧更新エラー2: \(error)")
                                return
                            }
                            print("\(count2.description)番目の友だちの友だち一覧更新成功")
                        })
                    }
                })
                
                count2 += 1
            }
            
        }
    }
    
    @IBAction func unwindtoHomeVC(sender: UIStoryboardSegue) {
        
        guard let addPlanVC = sender.source as? AddPlanViewController else {
            return
        }
        
        // 日時
        var toSaveEstimatedTime: Date?
        
        if let dateAndTime = addPlanVC.dateAndTime {
            
            toSaveEstimatedTime = (addPlanVC.addPlanTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? DateAndTimeCell)!.estimatedTime
            
            if let selectedIndexPath = planTable.indexPathForSelectedRow {
                dateAndTimes[selectedIndexPath.row] = dateAndTime
                estimatedTimes[selectedIndexPath.row] = (addPlanVC.addPlanTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? DateAndTimeCell)!.estimatedTime
                
            } else {
                dateAndTimes.append(dateAndTime)
                estimatedTimes.append((addPlanVC.addPlanTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? DateAndTimeCell)!.estimatedTime)
            }
            
            userDefaults.set(dateAndTimes, forKey: "DateAndTimes")
            userDefaults.set(estimatedTimes, forKey: "EstimatedTimes")
        }
        
        // 予定タイトル
        var toSavePlanTitle: String?
        
        if let planTitle = addPlanVC.planTitle {
            
            toSavePlanTitle = planTitle
            
            if let selectedIndexPath = planTable.indexPathForSelectedRow {
                planTitles[selectedIndexPath.row] = planTitle
                
            } else {
                planTitles.append(planTitle)
            }
            
            userDefaults.set(planTitles, forKey: "PlanTitles")
        }
        
        // 参加者
        var toSaveParticipantIDs = [String]()
        
        if addPlanVC.participantNames.isEmpty == false {
            
            toSaveParticipantIDs = addPlanVC.participantIDs
            
            let rep = addPlanVC.participantNames[0]
            let number = addPlanVC.participantNames.count
            
            if let selectedIndexPath = planTable.indexPathForSelectedRow {
                participantNames[selectedIndexPath.row] = rep
                numberOfParticipants[selectedIndexPath.row] = number
                
            } else {
                participantNames.append(rep)
                numberOfParticipants.append(number)
            }
            
            userDefaults.set(participantNames, forKey: "ParticipantNames")
            userDefaults.set(numberOfParticipants, forKey: "NumberOfParticipants")
        }
        
        // 場所
        var toSavePlaceName: String?
        var toSaveLocation: CLLocation?
        
        if let place = addPlanVC.place {
            
            let lat = addPlanVC.lat
            let lon = addPlanVC.lon
            
            toSavePlaceName = place
            toSaveLocation = CLLocation(latitude: Double(lat)!, longitude: Double(lon)!)
            
            if let selectedIndexPath = planTable.indexPathForSelectedRow {
                places[selectedIndexPath.row] = place
                lons[selectedIndexPath.row] = lon
                lats[selectedIndexPath.row] = lat
                
            } else {
                places.append(place)
                lons.append(lon)
                lats.append(lat)
            }
            
            userDefaults.set(places, forKey: "Places")
            userDefaults.set(lons, forKey: "lons")
            userDefaults.set(lats, forKey: "lats")
        }
        
        self.planTable.reloadData()
        
        if let selectedIndexPath = planTable.indexPathForSelectedRow {
            
            let planID = planIDs[selectedIndexPath.row]
            
            // 検索条件を作成
            let predicate = NSPredicate(format: "planID == %@", argumentArray: [planID])
            let query = CKQuery(recordType: "Plans", predicate: predicate)
            
            // 検索した予定の中身を更新
            publicDatabase.perform(query, inZoneWith: nil, completionHandler: {(records, error) in
                
                if let error = error {
                    print("予定更新エラー1: \(error)")
                    return
                }
                
                for record in records! {
                    
                    if let savePlanTitle = toSavePlanTitle {
                        record["planTitle"] = savePlanTitle as NSString
                    }
                        
                    if let saveEstimatedTime = toSaveEstimatedTime {
                        record["estimatedTime"] = saveEstimatedTime as Date
                    }
                        
                    if toSaveParticipantIDs.isEmpty == false {
                        record["participantIDs"] = toSaveParticipantIDs as [String]
                    }
                        
                    if let savePlaceName = toSavePlaceName {
                        record["placeName"] = savePlaceName as NSString
                    }
                        
                    if let saveLocation = toSaveLocation {
                        record["placeLatAndLon"] = saveLocation
                    }
                    
                    self.publicDatabase.save(record, completionHandler: {(record, error) in
                        
                        if let error = error {
                            print("予定更新エラー2: \(error)")
                            return
                        }
                        
                        print("予定更新成功")
                    })
                }
            })
        }
        
        // 新たに予定を作成したとき
        else {
            // 10桁の予定ID生成
            let planID = generatePlanID(length: 10)
            planIDs.append(planID)
            
            userDefaults.set(planIDs, forKey: "PlanIDs")
            
            let recordID = CKRecord.ID(recordName: "planID-\(planID)")
            let record = CKRecord(recordType: "Plans", recordID: recordID)
                
            record["planID"] = planID as NSString
            record["authorID"] = myID! as NSString
                
            if let savePlanTitle = toSavePlanTitle {
                record["planTitle"] = savePlanTitle as NSString
            }
                
            if let saveEstimatedTime = toSaveEstimatedTime {
                record["estimatedTime"] = saveEstimatedTime as Date
            }
                
            if toSaveParticipantIDs.isEmpty == false {
                record["participantIDs"] = toSaveParticipantIDs as [String]
            }
                
            if let savePlaceName = toSavePlaceName {
                record["placeName"] = savePlaceName as NSString
            }
                
            if let saveLocation = toSaveLocation {
                record["placeLatAndLon"] = saveLocation
            }
                
            // レコードを保存
            publicDatabase.save(record, completionHandler: {(record, error) in
                if let error = error {
                    print("Plansタイプ予定保存エラー: \(error)")
                    return
                }
                print("Plansタイプ予定保存成功")
            })
            
            // 作成者・参加者のIDを格納した配列
            var everyone = [myID!]
            for participantID in toSaveParticipantIDs {
                everyone.append(participantID)
            }
            
            print(everyone)
            print(everyone.count)
            
            var count = 0
            var checkCount = 0
            
            while count < (everyone.count - 1) {
                
                if count == checkCount {
                    checkCount += 1
                    planIDsOnDatabase.removeAll()
                    
                    print(count)
                    fetchPlanIDs(accountID: everyone[count], completion: {
                        // データベースの予定ID取得後に新たなIDを追加
                        self.planIDsOnDatabase.append(planID)
                        
                        // 次の処理（データベースに保存）
                        self.addPlanIDToDatabase(accountID: everyone[count], newPlanID: planID, completion: {
                            // データベースに予定ID保存後、次の人へ
                            count += 1
                        })
                    })
                }
            }
        }
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
        
        if userDefaults.object(forKey: "PlanIDs") != nil {
            self.planIDs = userDefaults.stringArray(forKey: "PlanIDs")!
        } else {
            self.planIDs = ["samplePlan"]
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
        
        if userDefaults.object(forKey: "ParticipantNames") != nil {
            self.participantNames = userDefaults.stringArray(forKey: "ParticipantNames")!
        } else {
            self.participantNames = ["参加者"]
        }
        
        if userDefaults.object(forKey: "NumberOfParticipants") != nil {
            self.numberOfParticipants = userDefaults.array(forKey: "NumberOfParticipants") as! [Int]
        } else {
            self.numberOfParticipants = [0]
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // print(#function)

        if let indexPath = planTable.indexPathForSelectedRow {
            planTable.deselectRow(at: indexPath, animated: true)
        }
        
        // 1秒ごとに処理
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
        // 初回起動時のみFirstVCに遷移
        let firstUserDefaults = UserDefaults.standard
        let firstLaunchKey = "firstLaunch"
        
        if firstUserDefaults.bool(forKey: firstLaunchKey) {
            firstUserDefaults.set(false, forKey: firstLaunchKey)
            firstUserDefaults.synchronize()
            
            self.performSegue(withIdentifier: "toFirstVC", sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let workingTimer = timer {
            workingTimer.invalidate()
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
        
        let participantIcon = cell.viewWithTag(3) as! UIImageView
        participantIcon.layer.borderColor = UIColor.gray.cgColor // 枠線の色
        participantIcon.layer.borderWidth = 1 // 枠線の太さ
        participantIcon.layer.cornerRadius = participantIcon.bounds.width / 2 // 丸くする
        participantIcon.layer.masksToBounds = true // 丸の外側を消す
        
        let participantLabel = cell.viewWithTag(4) as! UILabel
        
        if numberOfParticipants[indexPath.row] <= 1 {
            participantLabel.text = self.participantNames[indexPath.row]
        } else {
            participantLabel.text = "\(self.participantNames[indexPath.row]) 他"
        }
        
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
            remove(index: indexPath.row)
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
    
    func fetchPlanIDs(accountID: String, completion: @escaping () -> ()) {
        print("\(accountID)の予定一覧取得開始")
        
        let recordID = CKRecord.ID(recordName: "accountID-\(accountID)")
        
        publicDatabase.fetch(withRecordID: recordID, completionHandler: {(record, error) in
            
            if let error = error {
                print("予定取得エラー: \(error)")
                return
            }
            
            if let planIDs = record?.value(forKey: "planIDs") as? [String] {
                
                for planID in planIDs {
                    self.planIDsOnDatabase.append(planID)
                }
            } else {
                print("\(accountID)のデータベースの予定なし")
            }
            
            print("\(accountID)の予定一覧取得完了")
            completion()
        })
    }
    
    func addPlanIDToDatabase(accountID: String, newPlanID: String, completion: @escaping () -> ()) {
        print("\(accountID)の予定一覧保存開始")
        
        // 検索条件を作成
        let predicate = NSPredicate(format: "accountID == %@", argumentArray: [accountID])
        let query = CKQuery(recordType: "Accounts", predicate: predicate)
        
        // データベースの予定一覧にIDを追加
        self.publicDatabase.perform(query, inZoneWith: nil, completionHandler: {(records, error) in
            
            if let error = error {
                print("\(accountID)のデータベースの予定ID追加エラー1: \(error)")
                return
            }
            
            for record in records! {
                
                record["planIDs"] = self.planIDsOnDatabase as [String]
                
                self.publicDatabase.save(record, completionHandler: {(record, error) in
                    
                    if let error = error {
                        print("\(accountID)のデータベースの予定ID追加エラー2: \(error)")
                        return
                    }
                    
                    print("\(accountID)のデータベースの予定ID追加成功")
                    completion()
                })
            }
        })
    }
    
    func generatePlanID(length: Int) -> String {
        let characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        return String((0 ..< length).map { _ in characters.randomElement()! })
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
        
        planIDs.remove(at: index)
        userDefaults.set(self.planIDs, forKey: "PlanIDs")
        
        dateAndTimes.remove(at: index)
        userDefaults.set(self.dateAndTimes, forKey: "DateAndTimes")
        
        self.estimatedTimes.remove(at: index)
        userDefaults.set(self.estimatedTimes, forKey: "EstimatedTimes")
        
        self.planTitles.remove(at: index)
        userDefaults.set(self.planTitles, forKey: "PlanTitles")
        
        self.participantNames.remove(at: index)
        userDefaults.set(self.participantNames, forKey: "ParticipantNames")
        
        self.numberOfParticipants.remove(at: index)
        userDefaults.set(self.numberOfParticipants, forKey: "NumberOfParticipants")
        
        self.places.remove(at: index)
        userDefaults.set(self.places, forKey: "Places")
        
        self.lons.remove(at: index)
        userDefaults.set(self.lons, forKey: "lons")
        
        self.lats.remove(at: index)
        userDefaults.set(self.lats, forKey: "lats")
        
        // 検索条件を作成
        let predicate = NSPredicate(format: "accountID == %@", argumentArray: [myID!])
        let query = CKQuery(recordType: "Accounts", predicate: predicate)
        
        // データベースの予定一覧からIDを削除
        publicDatabase.perform(query, inZoneWith: nil, completionHandler: {(records, error) in
            
            if let error = error {
                print("データベースの予定ID削除エラー1: \(error)")
                return
            }
            
            for record in records! {
                
                record["planIDs"] = self.planIDs as [String]
                
                self.publicDatabase.save(record, completionHandler: {(record, error) in
                    
                    if let error = error {
                        print("データベースの予定ID削除エラー2: \(error)")
                        return
                    }
                    
                    print("データベースの予定ID削除成功")
                })
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        if identifier == "toPlanDetails" {
            let planDetailsVC = segue.destination as! PlanDetailsViewController
            planDetailsVC.planID = planIDs[(planTable.indexPathForSelectedRow?.row)!]
            planDetailsVC.dateAndTime = dateAndTimes[(planTable.indexPathForSelectedRow?.row)!]
            planDetailsVC.planTitle = planTitles[(planTable.indexPathForSelectedRow?.row)!]
            planDetailsVC.place = places[(planTable.indexPathForSelectedRow?.row)!]
            planDetailsVC.lonStr = lons[(planTable.indexPathForSelectedRow?.row)!]
            planDetailsVC.latStr = lats[(planTable.indexPathForSelectedRow?.row)!]
        }
        
        if identifier == "toRequestedVC" {
            let requestedVC = segue.destination as! RequestedViewController
            requestedVC.requestedIDs = self.fetchedRequest
        }
    }
    
}

