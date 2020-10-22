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
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    
    var check = [false, false, false]
    @IBOutlet weak var continueButton: UIBarButtonItem!
    
    @IBOutlet weak var eulaButton: UIButton!
    @IBOutlet weak var ppButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        idTextField.delegate = self
        nameTextField.delegate = self
        passwordTextField.delegate = self
        
        fetchExistingIDs()
        
        // 使用許諾契約ボタン
        eulaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12.0)
        eulaButton.setTitleColor(UIColor(hue: 0.07, saturation: 0.9, brightness: 0.95, alpha: 1.0), for: .normal)
        eulaButton.backgroundColor = .white
        eulaButton.layer.borderColor = UIColor.orange.cgColor
        eulaButton.layer.borderWidth = 1
        eulaButton.layer.cornerRadius = 8
        eulaButton.layer.masksToBounds = true
        
        // プライバシーポリシーボタン
        ppButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12.0)
        ppButton.setTitleColor(UIColor(hue: 0.07, saturation: 0.9, brightness: 0.95, alpha: 1.0), for: .normal)
        ppButton.backgroundColor = .white
        ppButton.layer.borderColor = UIColor.orange.cgColor
        ppButton.layer.borderWidth = 1
        ppButton.layer.cornerRadius = 8
        ppButton.layer.masksToBounds = true
        
        // ID入力時の判定
        idTextField.addTarget(self, action: #selector(idTextEditingChanged), for: UIControl.Event.editingChanged)
        // 名前入力時の判定
        nameTextField.addTarget(self, action: #selector(nameTextEditingChanged), for: UIControl.Event.editingChanged)
        // パスワード入力時の判定
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldEditingChanged), for: UIControl.Event.editingChanged)
    }
    
    // アプリ起動でレコードを削除（ダッシュボードに表示されないので応急処置）
    func deleteRecord() {
        let recordID = CKRecord.ID(recordName: "accountID-sample02")
        
        // デフォルトコンテナ（iCloud.com.gmail.mokamokayuuyuu.varmeets）のパブリックデータベースにアクセス
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        publicDatabase.delete(withRecordID: recordID, completionHandler: {(recordID, error) in
            if let error = error {
                print(error)
                return
            }
            print("saple02レコード削除完了")
        })
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
                        
                        check[0] = true
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
                noGood(num: 1)
            }
            
            // 入力されているとき
            else {
                check[1] = true
            }
        }
    }
    
    // パスワード入力時の判定
    @objc func passwordTextFieldEditingChanged(textField: UITextField) {
        
        if let text = textField.text {
            // 8文字未満のとき
            if text.count < 8 {
                passwordLabel.text = "8文字以上で入力してください"
                noGood(num: 2)
            }
            
            // 33文字以上のとき
            else if text.count > 32 {
                passwordLabel.text = "32文字以下で入力してください"
                noGood(num: 2)
            }
            
            // 8~32文字のとき
            else {
                // 半角英数字で構成されているとき
                if passwordTextFieldCharactersSet(textField, text) == true {
                    // OK!
                    passwordLabel.text = "OK!"
                    passwordLabel.textColor = .blue
                    
                    check[2] = true
                }
                
                // 使用できない文字が含まれているとき
                else {
                    passwordLabel.text = "半角英数字のみで構成してください"
                    noGood(num: 2)
                }
            }
        }
    }
    
    // パスワード入力文字列の判定
    func passwordTextFieldCharactersSet(_ textField: UITextField, _ text: String) -> Bool {
        // 入力できる文字
        let characters = CharacterSet(charactersIn:"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").inverted
        
        let components = text.components(separatedBy: characters)
        let filtered = components.joined(separator: "")
        
        if text == filtered {
            return true
        } else {
            return false
        }
    }
    
    // 警告を表示 & 続行ボタンを無効にする
    func noGood(num: Int) {
        
        check[num] = false
        
        // ラベルが初期テキストではないとき（入力済みのとき）、ラベルを赤くする
        if check[0] == false && idLabel.text != "半角英数字・アンダーバー（_）を入力できます" {
            idLabel.textColor = .red
        }
        if check[2] == false && passwordLabel.text != "半角英数字を入力できます" {
            passwordLabel.textColor = .red
        }
        
        continueButton.isEnabled = false
        continueButton.image = UIImage(named: "ContinueButton_gray")
    }
    
    // 入力中は続行ボタンを無効にする
    func textFieldDidBeginEditing(_ textField: UITextField) {
        continueButton.isEnabled = false
        continueButton.image = UIImage(named: "ContinueButton_gray")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
        
        // ID、名前の入力条件をクリアしていれば続行ボタンを有効にする
        if check.contains(false) == false {
            continueButton.isEnabled = true
            continueButton.image = UIImage(named: "ContinueButton")
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
            continueButton.image = UIImage(named: "ContinueButton")
        }
        
        return true
    }
    
    // すでに登録されているIDを配列に格納
    func fetchExistingIDs() {
        // デフォルトコンテナ（iCloud.com.gmail.mokamokayuuyuu.varmeets）のパブリックデータベースにアクセス
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: "all-varmeetsIDsList")
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let button = sender as? UIBarButtonItem, button === continueButton else {
            return
        }
        
        id = idTextField.text!
        name = nameTextField.text!
    }

}
