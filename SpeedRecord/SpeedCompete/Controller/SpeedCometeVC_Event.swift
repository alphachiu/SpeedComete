//
//  SpeedCometeVC_Event.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/10/11.
//  Copyright © 2020 Alpha. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import AudioToolbox

extension SpeedCometeVC{
    
    @objc func startEvent(){
        print("startEvent")
     
        self.mapView?.locationManager.startUpdatingLocation()
        self.mapView?.locationManager.startUpdatingHeading()
//        
//        UIView.animate(withDuration: 1) { [weak self] in
//            let yComponent = UIScreen.main.bounds.height -  (self?.bottomSheetView?.mininumDisplayHeight)!
//
//            self?.bottomSheetView?.frame.origin.y = yComponent
//
////            NotificationCenter.default.post(name:  Notification.Name(rawValue: "ChangeTabBarY"), object: true, userInfo: nil)
//           
//            self?.view.layoutIfNeeded()
//        }
//        
//        self.bottomSheetView?.gesture?.isEnabled = true
        
        
        
    }
    
    @objc func tapEvent(sender:UITapGestureRecognizer){
           print("tapEvent")
        if(!self.mapView!.isCompeteFinish){
            print("未完賽")
            SpeedSingleton.share.showAlert(viewConroller: self, "尚未到達終點，是否要結束") { (isCancel) in
                
                if(isCancel){
                    
                    self.racingEnd()
                    
                }else{
                    self.percentFloat = 0
                    self.reduce()
                }
                
            }
            
        }else{
            self.racingEnd()
        }
           
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
       
//        if(self.currentSpeedLabel.text == "結束"){
//
//
//
//        }else{
//            self.dismiss(animated: true, completion: nil)
//        }
        if sender.state == .ended {
           print("end")
            isAdd = false
            reduce()
        } else if sender.state == .began {
            print("Began")
            isAdd = true
            add()

        }

    }
    
    func add(){

        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            
            DispatchQueue.main.async {
                self.percentagePath = UIBezierPath(arcCenter: CGPoint(x: self.lineWidth +  self.radius, y:  self.lineWidth +  self.radius), radius:  self.radius, startAngle: self.aDegree *  self.startDegree, endAngle: self.aDegree * (self.startDegree + 360 * self.percentFloat / 100), clockwise: true)
                self.percentageLayer.path =  self.percentagePath?.cgPath
                print("percentage = \( self.percentFloat)")
                
                if(self.isAdd && self.percentFloat < 100 ){
                
//                   if !self.mapView!.isCompeteFinish{
//
//
//
//                    }
 
                    self.percentFloat += 1
                    self.add()
                }
                
                
                if(self.percentFloat >= 100){
                    
                    if(!self.mapView!.isCompeteFinish){
                        print("未完賽")
                        SpeedSingleton.share.showAlert(viewConroller: self, "尚未到達終點，是否要結束") { (isCancel) in
                            
                            if(isCancel){
                                
                                self.racingEnd()
                                
                            }else{
                                self.percentFloat = 0
                                self.reduce()
                            }
                            
                        }
                        
                    }else{
                        self.racingEnd()
                    }
                    
                    

                }
            }
            

         
        }
    }
    
    func racingEnd(){
        
        self.mapView?.delegate = nil
        self.percentFloat = 0
        self.mapView!.isCompeteFinish = true
        
        //結束震動
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            
            AudioServicesRemoveSystemSoundCompletion(self.soundID)
            AudioServicesDisposeSystemSoundID(self.soundID)
            
        }
        
        
        //關閉資訊
        UIView.transition(with: self.speedView , duration: 0.6 , options: .transitionFlipFromLeft , animations: {
            
            
        },completion: { (completed) in
            
            self.speedView.isHidden = true
            
            UIView.animate(withDuration: 0.5) {
                
                let yComponent = (UIScreen.main.bounds.height  - SpeedSingleton.share.bottomHeight) - (self.bottomSheetView!.mininumDisplayHeight) + 50
                
                
                self.bottomSheetView?.frame.origin.y = yComponent
                
                
                //                            NotificationCenter.default.post(name:  Notification.Name(rawValue: "ChangeTabBarY"), object: false, userInfo: nil)
                
                self.view.layoutIfNeeded()
                
            } completion: { (completed) in
                //                            self.rest()
                self.dismiss(animated: true, completion: nil)
            }
            
            
        })
        
        
    }
    
    
    func reduce(){
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            
            DispatchQueue.main.async {
                self.percentagePath = UIBezierPath(arcCenter: CGPoint(x: self.lineWidth +  self.radius, y:  self.lineWidth +  self.radius), radius:  self.radius, startAngle: self.aDegree *  self.startDegree, endAngle: self.aDegree * (self.startDegree + 360 * self.percentFloat / 100), clockwise: true)
                self.percentageLayer.path =  self.percentagePath?.cgPath
                print("percentage = \( self.percentFloat)")
                
                if(!self.isAdd && self.percentFloat > 0 ){
                
                    self.percentFloat -= 1
                    self.reduce()
                }else{
//                    if !self.mapView!.isCompeteFinish{
//                        self.mapView?.delegate = self.mapView as? MapViewDelegate
//                    }
                    
                }
            }
            

         
        }
    
    }
    
}
