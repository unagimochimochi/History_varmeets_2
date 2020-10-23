//
//  MenuViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/10/23.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // メニューの位置を取得
        let menuPosition = menuView.layer.position
        // 初期位置を画面の外側にするため、メニューの幅をマイナス
        menuView.layer.position.x = -menuView.frame.width
        
        // 表示時のアニメーション
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { self.menuView.layer.position.x = menuPosition.x },
                       completion: { bool in })
    }
    
    // メニューエリア以外タップ時
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(withDuration: 0.2,
                               delay: 0,
                               options: .curveEaseIn,
                               animations: { self.menuView.layer.position.x = -self.menuView.frame.width },
                               completion: { bool in
                                self.dismiss(animated: true, completion: nil)
                               })
            }
        }
    }

}
