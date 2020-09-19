//
//  EditMyProfileViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/09/19.
//

import UIKit
import CloudKit

class EditMyProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var name: String?
    var bio: String?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    var check = false
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        bioTextView.delegate = self

        // 名前入力時の判定
        nameTextField.addTarget(self, action: #selector(nameTextEditingChanged), for: UIControl.Event.editingChanged)
        
        // カスタムバー
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spaceItem, doneItem], animated: true)
        
        // bioTextViewにはカスタムバーをつける
        bioTextView.inputAccessoryView = toolbar
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateMyProfile(_ sender: Any) {
        if let id = myID {
            // デフォルトコンテナ（iCloud.com.gmail.mokamokayuuyuu.varmeets）のパブリックデータベースにアクセス
            let publicDatabase = CKContainer.default().publicCloudDatabase
            
            // 検索条件を作成
            let predicate = NSPredicate(format: "accountID == %@", argumentArray: [id])
            let query = CKQuery(recordType: "Accounts", predicate: predicate)
            
            // 検索したレコードの値を更新
            publicDatabase.perform(query, inZoneWith: nil, completionHandler: {(records, error) in
                if let error = error {
                    print("レコードのプロフィール更新エラー1: \(error)")
                    return
                }
                for record in records! {
                    record["accountName"] = myName! as NSString
                    record["accountBio"] = self.bio! as NSString
                    publicDatabase.save(record, completionHandler: {(record, error) in
                        if let error = error {
                            print("レコードのプロフィール更新エラー2: \(error)")
                            return
                        }
                        print("レコードのプロフィール更新成功")
                    })
                }
            })
        }
    }
    
    // 名前入力時の判定
    @objc func nameTextEditingChanged(textField: UITextField) {
        if let text = textField.text {
            // 入力されていないとき
            if text.count == 0 {
                check = false
                saveButton.isEnabled = false
                saveButton.image = UIImage(named: "SaveButton_gray")
            }
                
            // 21文字以上のとき
            else if text.count > 20 {
                check = false
                saveButton.isEnabled = false
                saveButton.image = UIImage(named: "SaveButton_gray")
            }
                
            // 1~20文字のとき
            else {
                check = true
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
        
        // 名前の入力条件をクリアしていれば保存ボタンを有効にする
        if check == true {
            saveButton.isEnabled = true
            saveButton.image = UIImage(named: "SaveButton")
            
            myName = nameTextField.text!
            if bioTextView.text == "自己紹介（100文字以内）" {
                bio = ""
            } else {
                bio = bioTextView.text
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        // 名前の入力条件をクリアしていれば保存ボタンを有効にする
        if check == true {
            saveButton.isEnabled = true
            saveButton.image = UIImage(named: "SaveButton")
            
            myName = nameTextField.text!
            if bioTextView.text == "自己紹介（100文字以内）" {
                bio = ""
            } else {
                bio = bioTextView.text
            }
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 初期テキストが入っていたらタップで空にする
        if textView.text == "自己紹介（100文字以内）" {
            textView.text = ""
        }
        
        textView.textColor = .black
        
        // 入力中は保存ボタンを無効にする
        saveButton.isEnabled = false
        saveButton.image = UIImage(named: "SaveButton_gray")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.endEditing(true)
        
        // 名前の入力条件をクリアしていれば続行ボタンを有効にする
        if check == true {
            saveButton.isEnabled = true
            saveButton.image = UIImage(named: "SaveButton")
            
            myName = nameTextField.text!
            bio = bioTextView.text
        }
    }
    
    @objc func done() {
        bioTextView.endEditing(true)
        
        // 名前の入力条件をクリアしていれば続行ボタンを有効にする
        if check == true {
            saveButton.isEnabled = true
            saveButton.image = UIImage(named: "SaveButton")
            
            myName = nameTextField.text!
            bio = bioTextView.text
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        name = nameTextField.text!
        bio = bioTextView.text
    }

}

