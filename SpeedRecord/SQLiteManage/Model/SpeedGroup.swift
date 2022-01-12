//
//  SpeedGroup.swift
//  SpeedRecord
//
//  Created by Alghero_Mac_02 on 2020/10/16.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import SQLite

class SpeedGroupColumnModel: NSObject {
    
    let id:Expression<Int>
    let startTimestamp:Expression<Int> //開始時間
    let totalKm:Expression<Double> //全程公里
    let totalTime:Expression<Int> //所花時間
    let isFinishComete:Expression<Bool> //是否完賽
    let startAnnotation:Expression<String> //開始位置
    let endAnnotation:Expression<String> //結束位置
    let startPlace:Expression<String> //開始地點
    let endPlace:Expression<String> //結束地點
    let mode:Expression<Int> //模式
    let note:Expression<String?> //note
    
    init(
        id:Expression<Int>,
        startTimestamp:Expression<Int>,
        totalKm:Expression<Double>,
        totalTime:Expression<Int>,
        isFinishComete:Expression<Bool>,
        startAnnotation:Expression<String>,
        endAnnotation:Expression<String>,
        startPlace:Expression<String>,
        endPlace:Expression<String>,
        mode:Expression<Int>,
        note:Expression<String?>
    ) {
        
        self.id = id
        self.startTimestamp = startTimestamp
        self.totalKm = totalKm
        self.totalTime = totalTime
        self.isFinishComete = isFinishComete
        self.startAnnotation = startAnnotation
        self.endAnnotation = endAnnotation
        self.startPlace = startPlace
        self.endPlace = endPlace
        self.mode  = mode
        self.note = note
        
    }
    
}

class SpeedGroupModel:NSObject{
    
    let id:Int
    let startTimestamp:Int
    let totalKm:Double
    let totalTime:Int
    let isFinishComete:Bool
    let startAnnotation:String
    let endAnnotation:String
    let startPlace:String
    let endPlace:String
    let mode:Int
    let note:String
 
    
    init(
        id:Int,
        startTimestamp:Int,
        totalKm:Double,
        totalTime:Int,
        isFinishComete:Bool,
        startAnnotation:String,
        endAnnotation:String,
        startPlace:String,
        endPlace:String,
        mode:Int,
        note:String
  
    ) {
        
        self.id = id
        self.startTimestamp = startTimestamp
        self.totalKm = totalKm
        self.totalTime = totalTime
        self.isFinishComete = isFinishComete
        self.startAnnotation = startAnnotation
        self.endAnnotation = endAnnotation
        self.startPlace = startPlace
        self.endPlace = endPlace
        self.mode = mode
        self.note = note
   
    }
    
    
}
