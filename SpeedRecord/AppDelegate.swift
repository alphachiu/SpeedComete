//
//  AppDelegate.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/9/12.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMobileAds
import Firebase
import FBAudienceNetwork
import AdSupport


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var loadView:UIView?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
       
       print("UUID = \( ASIdentifierManager.shared().advertisingIdentifier)")
        
       // SQLiteManage.shared.deleteDB()
        SQLiteManage.shared.start()
        
        //FB ADs
        FBAdSettings.setAdvertiserTrackingEnabled(true)
        
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        //        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["1EF245DE-B0C1-499E-ABFA-FA7F9B2E6ED5"]
     
        #if DEBUG
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["1EF245DE-B0C1-499E-ABFA-FA7F9B2E6ED5"]
        #endif
        
      
        FirebaseApp.configure()
        
        
        
        
        
        return true
    }

    
    func showLoadView(message:String){
        
        if(self.loadView == nil){
            loadView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height))
            loadView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2994608275)
            let mainWindow = UIApplication.shared.keyWindow! as UIWindow
            mainWindow.addSubview(loadView!)
            
            let active = UIActivityIndicatorView(style: .whiteLarge)
            active.translatesAutoresizingMaskIntoConstraints = false
            active.startAnimating()
            loadView?.addSubview(active)
            
            active.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.height.width.equalTo(50)
            }
            
            let subTitle = UILabel()
            subTitle.textAlignment = .center
            subTitle.text = message
            subTitle.textColor = .white
            subTitle.font = UIFont(name: "PingFangTC-Regular", size: 20.0)
            loadView?.addSubview(subTitle)
            
            subTitle.snp.makeConstraints { (make) in
                make.top.equalTo(active.snp.bottom).offset(0)
                make.centerX.equalToSuperview()
                make.width.equalTo(150)
                make.height.equalTo(50)
              
            }
        }
        
        self.loadView!.isHidden = false
        
    }
    
    func hiddenLoadView(){
        
        self.loadView?.removeSubviews()
        self.loadView?.removeFromSuperview()
        self.loadView = nil
    }
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

