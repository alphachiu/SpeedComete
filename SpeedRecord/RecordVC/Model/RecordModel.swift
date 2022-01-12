//
//  RecordModel.swift
//  SpeedRecord
//
//  Created by Alghero_Mac_02 on 2020/10/20.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit

class RecordGroupModel: NSObject {
    
    let year:Int
    let month:Int
    let totalNum:Int
    let totalKm:Double
    var recordData:[RecordModel]
    let timeStamp:Int
 
    
    init(
        year:Int,
        month:Int,
        totalNum:Int,
        totalKm:Double,
        recordData:[RecordModel],
        timeStamp:Int
   
        
    ) {
        
        self.year = year
        self.month = month
        self.totalNum = totalNum
        self.totalKm = totalKm
        self.recordData = recordData
        self.timeStamp = timeStamp
    
    }
    
}


class RecordModel:NSObject{
    
    let year:Int
    let month:Int
    let day:Int
    let totalKM:Double
    let totalTime:Int
    let startPlace:String
    let endPlace:String
    let timeStamp:Int
    var note:String
 
    
    init(
        year:Int,
        month:Int,
        day:Int,
        totalKM:Double,
        totalTime:Int,
        startPlace:String,
        endPlace:String,
        timeStamp:Int,
        note:String
     
        
    ) {
        
        self.year = year
        self.month = month
        self.day = day
        self.totalTime = totalTime
        self.totalKM = totalKM
        self.startPlace = startPlace
        self.endPlace = endPlace
        self.timeStamp = timeStamp
        self.note = note
   
    }
    
    
}
