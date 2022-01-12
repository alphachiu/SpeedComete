//
//  SpeedModel.swift
//  SpeedRecord
//
//  Created by Alghero_Mac_02 on 2020/10/16.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import SQLite


class SpeedColumnModel: NSObject {
    
    let id:Expression<Int>
    let speed:Expression<Double>
    let time:Expression<Int>
    let avgSpeed:Expression<Double>
    let startTimestamp:Expression<Int>
    let location:Expression<String>
    
    
    
    init(
        id:Expression<Int>,
        speed:Expression<Double>,
        time:Expression<Int>,
        avgSpeed:Expression<Double>,
        startTimestamp:Expression<Int>,
        location:Expression<String>
    ) {
        
        self.id = id
        self.speed = speed
        self.time = time
        self.avgSpeed = avgSpeed
        self.startTimestamp = startTimestamp
        self.location = location
        
    }
    
}

class SpeedModel:NSObject{
    
    let id:Int
    let speed:Double
    let time:Int
    let avgSpeed:Double
    let startTimestamp:Int
    let location:String
 
    
    init(
        id:Int,
        speed:Double,
        time:Int,
        avgSpeed:Double,
        startTimestamp:Int,
        location:String
  
    ) {
        
        self.id = id
        self.speed = speed
        self.time = time
        self.avgSpeed = avgSpeed
        self.startTimestamp = startTimestamp
        self.location = location
   
    }
    
    
}
