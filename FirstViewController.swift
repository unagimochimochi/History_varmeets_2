//
//  FirstViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/09/11.
//

import UIKit
import CloudKit

class FirstViewController: UIViewController, UITextFieldDelegate {
    
    var existingIDs = [String]()
    
    var id: String?
    var name: String?
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    var check = [false, false]
    @IBOutlet weak var continueButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        idTextField.delegate = self
        nameTextField.delegate = self
        
        fetchExistingIDs()
        
        // ID入力時の判定
        idTextField.addTarget(self, action: #selector(idTextEditingChanged), for: UIControl.Event.editingChanged)
        // 名前入力時の判定
        nameTextField.addTarget(self, action: #selector(nameTextEditingChanged), for: UIControl.Event.editingChanged)
    }
    
    // ID入力時の判定
    @objc func idTextEditingChanged(textField: UITextField) {
        if let text = textField.text {
            // 4文字未満のとき
            if text.count < 4 {
                idLabel.text = "4文字以上で入力してください"
                noGood(num: 0)
            }
            
            // 21文字以上のとき
            else if text.count > 20 {
                idLabel.text = "20文字以下で入力してください"
                noGood(num: 0)
            }
            
            // 4~20文字のとき
            else {
                // 半角英数字と"_"で構成されているとき
                if idTextFieldCharactersSet(textField, text) == true {
                    // 入力したIDがすでに存在するとき
                    if existingIDs.contains("accountID-\(text)") == true {
                        idLabel.text = "そのIDはすでに登録されています"
                        noGood(num: 0)
                    }
                    
                    // OK!
                    else {
                        idLabel.text = "OK!"
                        idLabel.textColor = .blue
                        
                        check.remove(at: 0)
                        check.insert(true, at: 0)
                    }
                }
                
                // 使用できない文字が含まれているとき
                else {
                    idLabel.text = "半角英数字とアンダーバー（_）のみで構成してください"
                    noGood(num: 0)
                }
            }
        }
    }
    
    // ID入力文字列の判定
    func idTextFieldCharactersSet(_ textField: UITextField, _ text: String) -> Bool {
        // 入力できる文字
        let characters = CharacterSet(charactersIn:"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_").inverted
        
        let components = text.components(separatedBy: characters)
        let filtered = components.joined(separator: "")
        
        if text == filtered {
            return true
        } else {
            return false
        }
    }
    
    // 名前入力時の判定
    @objc func nameTextEditingChanged(textField: UITextField) {
        if let text = textField.text {
            // 入力されていないとき
            if text.count == 0 {
                check.remove(at: 1)
                check.insert(false, at: 1)
                continueButton.isEnabled = false
            }
            
            // 入力されているとき
            else {
                check.remove(at: 1)
                check.insert(true, at: 1)
            }
        }
    }
    
    // 警告を表示 & 続行ボタンを無効にする
    func noGood(num: Int) {
        idLabel.textColor = .red
        check.remove(at: num)
        check.insert(false, at: num)
        continueButton.isEnabled = false
    }
    
    // 入力中は続行ボタンを無効にする
    func textFieldDidBeginEditing(_ textField: UITextField) {
        continueButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
        
        // ID、名前の入力条件をクリアしていれば続行ボタンを有効にする
        if check.contains(false) == false {
            continueButton.isEnabled = true
        }
        
        if textField == idTextField {
            id = textField.text
            print(id!)
        }
        
        if textField == nameTextField {
            name = textField.text
            print(name!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        // ID、パスワードの入力条件をクリアしていればDoneボタンを有効にする
        if check.contains(false) == false {
            continueButton.isEnabled = true
        }
        
        return true
    }
    
    // すでに登録されているIDを配列に格納
    func fetchExistingIDs() {
        // ID一覧のRecordName
        let accountsList = "accounts-accountID"
        // デフォルトコンテナ（iCloud.com.gmail.mokamokayuuyuu.AccountsTest）のパブリックデータベースにアクセス
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: accountsList)
        
        publicDatabase.fetch(withRecordID: recordID, completionHandler: {(existingIDs, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let existingIDs = existingIDs?.value(forKey: "accounts") as? [String] {
                for existingID in existingIDs {
                    print("success!")
                    self.existingIDs.append(existingID)
                }
                print(self.existingIDs)
            }
        })
    }

}
