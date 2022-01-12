//
//  SpeedCompeteViewModel.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/10/11.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import CoreLocation

enum CompeteModel {
    case Common
}



class SpeedCompeteViewModel: NSObject {

    var starPlace = Box("")
    var endPlace = Box("")
    var totalKM = Box("0.0")
    var second = Box(0)
    var topSpeed =  Box(CLLocationSpeed()) //平均速度
    var avgSpeed = Box(CLLocationSpeed()) //目前速度
    var currentSpeed = Box(0.0) //最高速度
    
    
    
    var competeModels: [CompeteModel] = [.Common]
    var speedGroupData:SpeedGroupModel?
    var speedDatas = [SpeedModel]()
    
    
    
    override init() {
      
    }
    
    
    func insertUserData(userLocation:CLLocation){
        
        let speedData = SpeedModel(id: 0, speed: self.currentSpeed.value, time:self.second.value , avgSpeed: self.avgSpeed.value, startTimestamp: self.speedGroupData?.startTimestamp ?? 0,location: "\(userLocation.coordinate.latitude ),\(userLocation.coordinate.longitude )")
        
        
        self.speedDatas.append(speedData)
        
    }
    
    
    func saveSnapShot(shotImage:UIImage,starLocation:CLLocation,endLocation:CLLocation){
        
        let timeInterval:TimeInterval = Date().timeIntervalSince1970
        let timeStamp = Int(timeInterval)
  
        let totalkm = SpeedSingleton.share.calculateDistance(startLocation: starLocation, endLocation: endLocation)
        
    //    self.distanceKM.text = "\(totalkm)"
        

        speedGroupData = SpeedGroupModel(id: 0,
                                                         startTimestamp: timeStamp,
                                                         totalKm: totalkm,
                                         totalTime: second.value,
                                                         isFinishComete: false,
                                                         startAnnotation: "\(starLocation.coordinate.latitude),\(starLocation.coordinate.longitude)",
                                                         endAnnotation: "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)",
                                         startPlace: starPlace.value,
                                         endPlace: endPlace.value,
                                                         mode: 0, note: ""
                                                         
        )
        
        SpeedSingleton.share.saveImage(image: shotImage, imageName:"\(speedGroupData!.startTimestamp).png")
        
    }
    
    func saveData(){
        
        DispatchQueue.global().async {
            
            if(self.speedGroupData != nil &&
                !self.speedDatas.isEmpty){
                
                
                SQLiteManage.shared.insertSpeedGroupData(speedGroupData: self.speedGroupData! )

                SQLiteManage.shared.insertSpeedDatas(speedDatas: self.speedDatas, startTimestamp: self.speedGroupData!.startTimestamp)
                
                self.speedGroupData = nil
                
                self.self.restData()
                
                SQLiteManage.shared.cloaseDB()

            }

            
        }

        
    }
    
    func restData(){
        
        self.speedDatas.removeAll()
        self.speedGroupData = nil
        
    }
}
