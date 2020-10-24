//
//  DeleteMyAccountViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/10/24.
//

import UIKit
import CloudKit

class DeleteMyAccountViewController: UIViewController, UITextFieldDelegate {
    
    var inputPassword: String?
    var fetchedPassword: String?
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var continueButton: UIBarButtonItem!
    
    var timer1: Timer!
    var timer2: Timer!
    var deleteCheck = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.delegate = self
    }
    
    // 入力中は続行ボタンを無効にする
    func textFieldDidBeginEditing(_ textField: UITextField) {
        continueButton.isEnabled = false
        continueButton.image = UIImage(named: "ContinueButton_gray")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
        
        inputPassword = textField.text
        
        // UITextFieldが空でなければ続行ボタンを有効にする
        if let text = textField.text, !text.isEmpty {
            continueButton.isEnabled = true
            continueButton.image = UIImage(named: "ContinueButton")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        inputPassword = textField.text
        
        // UITextFieldが空でなければ続行ボタンを有効にする
        if let text = textField.text, !text.isEmpty {
            continueButton.isEnabled = true
            continueButton.image = UIImage(named: "ContinueButton")
        }
        
        return true
    }
    
    // 続行ボタンタップ時
    @IBAction func deleteMyAccount(_ sender: Any) {
        
        // タイマースタート
        timer1 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(fetchingPassword), userInfo: nil, repeats: true)
        
        fetchPassword()
    }
    
    @objc func fetchingPassword() {
        print("Fetching my password")
        
        if let correctPassword = fetchedPassword {
            print("Completed fetching my password!")
            
            // タイマーを止める
            if let workingTimer = timer1 {
                workingTimer.invalidate()
            }
            
            // 入力したパスワードと取得したパスワードが一致したとき
            if self.inputPassword == correctPassword {
                let dialog = UIAlertController(title: "最終確認", message: "アカウントを削除すると復元できません。\n本当に削除しますか？", preferredStyle: .alert)
                
                // キャンセルボタン
                let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
                // 削除ボタン
                let delete = UIAlertAction(title: "削除", style: .destructive, handler: { (action) in
                    // クロージャで削除処理を書く
                    print("削除完了")
                })
                
                // Actionを追加
                dialog.addAction(cancel)
                dialog.addAction(delete)
                // ダイアログを表示
                self.present(dialog, animated: true, completion: nil)
            }
            
            // パスワードが間違っていたとき
            else {
                let dialog = UIAlertController(title: "削除失敗", message: "パスワードが違います。", preferredStyle: .alert)
                // もう一度挑戦ボタン
                dialog.addAction(UIAlertAction(title: "もう一度挑戦", style: .default, handler: nil))
                // ダイアログを表示
                self.present(dialog, animated: true, completion: nil)
            }
        }
    }
    
    func fetchPassword() {
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let recordID = CKRecord.ID(recordName: "accountID-\(myID!)")
        
        publicDatabase.fetch(withRecordID: recordID, completionHandler: {(record, error) in
            
            if let error = error {
                print("パスワード取得エラー: \(error)")
                return
            }
            
            if let password = record?.value(forKey: "password") as? String {
                self.fetchedPassword = password
            }
        })
    }
    
    func deleteMyAccount() {
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let recordID = CKRecord.ID(recordName: "accountID-\(myID!)")
        
        publicDatabase.delete(withRecordID: recordID, completionHandler: {(record, error) in
            
            if let error = error {
                print("アカウント削除エラー: \(error)")
                self.deleteCheck = 1
                return
            }
            print("アカウント削除成功")
            self.deleteCheck = 2
        })
    }
    
}
