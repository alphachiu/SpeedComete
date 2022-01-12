//
//  RecordInfoViewModel.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/10/25.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import CoreLocation

class RecordInfoViewModel: NSObject {
    
    
    private var coordinator: RecordCoordinatorProtocol?
    var speedDatas = [SpeedModel]()
    var paths = [CLLocationCoordinate2D]()
    var pathLocations = [CLLocation]()
    var chartYValuesArray = [Double]()
    var chartXValueArray = [Double]()
    var chartXStrValueArray: [String] = []
    
    var timeStamp:Int!
    
    init(timeStamp:Int,coordinator:RecordCoordinatorProtocol){
        
        self.timeStamp = timeStamp
        self.coordinator = coordinator
        
    }
    
    func getSpeedData(completed:@escaping()->Void){
        
        
        
        let speedDatas = SQLiteManage.shared.querySpeedData(startTimeStamp: timeStamp)
        
        self.speedDatas = speedDatas

        for (_,speedData) in self.speedDatas.enumerated(){
            if(speedData.location != ""){
               
                let lat = speedData.location.split(separator: ",")[0]
                let lon = speedData.location.split(separator: ",")[1]
                if(lat != "0" && lon != "0"){
                    let pathLocation = CLLocationCoordinate2D(latitude: Double(String(lat))!, longitude: Double(String(lon))!)
                    let location = CLLocation(latitude: Double(String(lat))!, longitude: Double(String(lon))!)
                    self.pathLocations.append(location)
                    self.paths.append(pathLocation)
                }

                let yValue = speedData.speed
                self.chartYValuesArray.append(yValue)
                
                let time = speedData.time
                let hours = Int(time) / 3600
                let minutes = Int(time) / 60 % 60
                let seconds = Int(time) % 60
                var timeStr = ""
                if(hours == 0){
                    timeStr = "\(String(format:"%02i:%02i", minutes, seconds))"
                }else{
                    timeStr = "\(String(format:"%02i:%02i:%02i", hours, minutes, seconds))"
                }
                
                if(time % 10 == 0){
                    self.chartXValueArray.append(Double(time))
                    self.chartXStrValueArray.append(timeStr)
                }
                
              
                
            }
            
        }
        self.chartXValueArray.insert(0.0, at: 0)
        self.chartXStrValueArray.insert("00:00", at: 0)
        
        completed()
        
    }

    
    func dismiss(){
        
        coordinator?.dismiss()
        
    }

}
