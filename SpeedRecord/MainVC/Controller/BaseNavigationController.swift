//
//  BaseNavigationController.swift
//  MCTabbarDemoSwift
//
//  Created by Alghero_Mac_02 on 2020/10/13.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let navBar = UINavigationBar.appearance()
        self.navigationBar.isTranslucent = true
        navBar.barTintColor = UIColor.white
//       navBar.tintColor = UIColor.red

//        let attriDic = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 18),NSAttributedStringKey.foregroundColor:UIColor.red]
//        navBar.titleTextAttributes = attriDic
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {

        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
            // 可以在這裡設置返回按鈕等,重寫後側滑返回失效需要自己處理
            //backBarButtonItem 是帶有字和返回箭頭的樣式
            /*
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_back_13x21"), style: .plain, target: self, action: #selector(navBackAction))
            */
        }

        super.pushViewController(viewController, animated: true)
    }

    // 返回event
    @objc func navBackAction(){
        popViewController(animated: true)
    }

}
