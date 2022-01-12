//
//  File.swift
//  Tabbar
//
//  Created by Alghero_Mac_02 on 2020/10/13.
//
import UIKit

protocol SCTarBarControllerDelegate : NSObjectProtocol {
     func scTabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
}

class SCTabBarController: UITabBarController,UITabBarControllerDelegate {

    var scTabBar = SCTabBar(frame: CGRect.zero)
    weak var scDelegate : SCTarBarControllerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        scTabBar.centerBtn.addTarget(self, action: #selector(centerBtnAction), for: .touchUpInside)
        self.setValue(scTabBar, forKeyPath: "tabBar")
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        scTabBar.centerBtn.isSelected = (tabBarController.selectedIndex == (viewControllers?.count)!/2)
        self.scDelegate?.scTabBarController(tabBarController, didSelect: viewController)
    }
    // 中間按鈕點擊
    @objc func centerBtnAction() {
        let count = viewControllers?.count ?? 0
        self.selectedIndex = count/2
        self.tabBarController(self, didSelect: viewControllers![selectedIndex])
    }
}
