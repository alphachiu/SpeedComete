//
//  RecordViewModel.swift
//  SpeedRecord
//
//  Created by Alghero_Mac_02 on 2020/10/20.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit

class RecordViewModel: NSObject {

    var recordGroupDatas = Box([RecordGroupModel]())
    
    private var coordinator: RecordCoordinatorProtocol?
    init(coordinator:RecordCoordinatorProtocol) {
        super.init()
        self.coordinator = coordinator
    }
    
    func reloadData(){
        
        print("reloadData start")
        recordGroupDatas.value.removeAll()
        let groups =  SQLiteManage.shared.querySpeedGroupData()
        
        var groupKMDic = [String:Double]()
        var groupRecordDataDic = [String:[RecordModel]]()
        var timeStampDic = [String:Int]()
     
        
        for group in groups{
            
            var date = Date(timeIntervalSince1970: TimeInterval(group.startTimestamp))
             
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            let dateStr = formatter.string(from: date)
            date = formatter.date(from: "\(dateStr)")!
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            
            let yearInt = components.year
            var monthInt = components.month
            let dateInt = components.day
            
            let monthStr:String = String(format: "%02d", monthInt!)
            print("monthStr = \(monthStr)")
     
            let recordModel = RecordModel(year: yearInt!,
                                          month: monthInt!,
                                          day: dateInt!,
                                          totalKM: group.totalKm,
                                          totalTime: group.totalTime,
                                          startPlace: group.startPlace,
                                          endPlace: group.endPlace,
                                          timeStamp: group.startTimestamp,
                                          note: group.note)
            
         
            
            //group KM
            if(groupKMDic["\(yearInt!)\(monthStr)"] == nil){
                //新增
                groupKMDic["\(yearInt!)\(monthStr)"] =  group.totalKm
                timeStampDic["\(yearInt!)\(monthStr)"] = group.startTimestamp
               
            }else{
                //已存在
                let totalKM =  groupKMDic["\(yearInt!)\(monthStr)"]! + group.totalKm
                groupKMDic["\(yearInt!)\(monthStr)"] = totalKM

                
            }

            
            // group RecordData
            if(groupRecordDataDic["\(yearInt!)\(monthStr)"] == nil){
                //新增
                groupRecordDataDic["\(yearInt!)\(monthStr)"]  = [recordModel]
                
            }else{
                //已存在
                var records =  groupRecordDataDic["\(yearInt!)\(monthStr)"]!
                records.append(recordModel)
                groupRecordDataDic["\(yearInt!)\(monthStr)"] = records
            }
            
        }
        
        
        var newGroupRecordDataDic =   groupRecordDataDic.sorted { (groupA, groupB) -> Bool in
            
            let yearMonthA = Int(groupA.key)
            let yearMonthB = Int(groupB.key)
            
            return yearMonthA! > yearMonthB!
        }

          newGroupRecordDataDic.forEach { (recordDic) in
            
            let recordData = recordDic.value
            let totalKM = groupKMDic[recordDic.key]!
            let timeStamp = timeStampDic[recordDic.key]!
       
            let groupData = RecordGroupModel(year: recordData.first!.year,
                                             month: recordData.first!.month,
                                             totalNum: recordData.count,
                                             totalKm: totalKM,
                                             recordData: recordData,timeStamp:timeStamp)
            
              self.recordGroupDatas.value.append(groupData)
            
            
        }
        groupRecordDataDic.removeAll()
        newGroupRecordDataDic.removeAll()
//        self.recordGroupDatas.sorted { (groupA, groupB) -> Bool in
//
//            return groupA.timeStamp < groupB.timeStamp
//        }
        

        print("reloadData end")
    }
    
    
    func presentInfoVC(data:(timeStamp: Int,totalTime:String,totoalDistance:String)){
        
        coordinator?.present(data: data)
    }
    
}
