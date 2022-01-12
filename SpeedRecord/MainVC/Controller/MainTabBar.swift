//
//  MainTabBar.swift
//  Tabbar
//
//  Created by Alghero_Mac_02 on 2020/10/13.
//

import UIKit

class MainTabBar: SCTabBarController,SCTarBarControllerDelegate {
    
    
  //  var tabBarY:CGFloat?
    var isFirst = true
    var isStarChageY:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //點選時的顏色
        scTabBar.tintColor = UIColor(red: 251.0/255.0, green: 199.0/255.0, blue: 115.0/255.0, alpha: 1)
        scTabBar.backgroundColor = .white
        //中間按鈕是否透明
       // scTabBar.isTranslucent = true
       // scTabBar.positon = .center
       // scTabBar.centerImage = UIImage(named: "tabbar_add_yellow")!
        self.scDelegate = self

        addChildViewControllers()
 

        
//        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "ChangeTabBarY"), object: nil, queue: nil) { (notify) in
//            print("11")
//            
//            self.isStarChageY = notify.object as? Bool
//            
//            if(self.isStarChageY != nil && self.isStarChageY!){
//                
//
//                self.tabBar.frame.origin.y = self.tabBarY! + 200
//            }else{
//                self.tabBar.frame.origin.y = self.tabBarY!
//            }
//        
//            self.view.layoutIfNeeded()
//            
//        }
        
    }
    
    override func viewWillLayoutSubviews(){
        
        super.viewWillLayoutSubviews()
        
//        if(tabBarY != nil){
//            if(self.isStarChageY != nil && self.isStarChageY!){
//
//
//                self.tabBar.frame.origin.y = self.tabBarY! + 200
//            }else{
//                self.tabBar.frame.origin.y = self.tabBarY!
//            }
//        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(isFirst){
            self.selectedIndex = 1
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(isFirst){
           //self.selectedIndex = 0
          //  self.tabBarY = self.tabBar.frame.origin.y
            
            rotationAnimation()
            isFirst = !isFirst
        }
     
    }
    
    
    //增加VC
    
    func addChildViewControllers() {
        //圖片大小32*32
        addChildViewController(RecordVC(), title: "紀錄", imageName: "record")
        addChildViewController(MissionVC(), title: "競賽", imageName: "racingFlag")
      //  addChildViewController(ViewController(), title: "關於我", imageName: "tab4")
    }
    
    func addChildViewController(_ childController: UIViewController, title: String, imageName: String) {
        childController.title = title
        if imageName.count > 0{
             var image =  UIImage(named: imageName)
            image =  image?.imageWith(newSize: CGSize(width: 32, height: 32))
            
            childController.tabBarItem.image = image
            childController.tabBarItem.selectedImage = image
        }
      //  let nav = BaseNavigationController(rootViewController: childController)
        addChild(childController)
    }
    
    
    //當中間有TabBar時
    func scTabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 {
            rotationAnimation()
        }else {
            removeAnimation()
        }
    }
    
    //選轉動畫
    func rotationAnimation() {
        if "key" == self.scTabBar.centerBtn.layer.animationKeys()?.first {
            return
        }
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = NSNumber(value: Double.pi*2.0)
        animation.duration = 3.0
        animation.repeatCount = HUGE
        self.scTabBar.centerBtn.layer.add(animation, forKey: "key")
    }
    
    func removeAnimation() {
        self.scTabBar.centerBtn.layer.removeAllAnimations()
    }
}

