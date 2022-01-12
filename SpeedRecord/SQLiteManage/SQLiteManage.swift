//
//  SQLiteManage.swift
//  SpeedRecord
//
//  Created by Alghero_Mac_02 on 2020/10/16.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
//import SQLite3
import SQLite

class SQLiteManage: NSObject {

    static let shared = SQLiteManage()
    var competeDB:Connection!
    let speedTable = Table("speed")
    let speedGroupTable = Table("speedGroupTable")
    let filePath: String="/Documents"
    var speedColumnModel:SpeedColumnModel?
    var speedGroupColumnModel:SpeedGroupColumnModel?
    var userDBVersion = UserDefaults.standard.string(forKey: "DBVersion")
    
    
    
    var dbVersion = "1.1.0"
    
    override init() {
        super.init()
        
        if(speedColumnModel == nil){

            
            speedColumnModel = SpeedColumnModel(id: Expression<Int>("id"),
                                          speed: Expression<Double>("speed"),
                                          time:  Expression<Int>("time"),
                                          avgSpeed: Expression<Double>("avgSpeed"),
                                          startTimestamp: Expression<Int>("startTimestamp"),
                                          location: Expression<String>("location")
            )
            
        }
        
        if(speedGroupColumnModel == nil){

            
            speedGroupColumnModel = SpeedGroupColumnModel(id: Expression<Int>("id"),
                                                          startTimestamp: Expression<Int>("startTimestamp"),
                                                          totalKm: Expression<Double>("totalKm"),
                                                          totalTime: Expression<Int>("totalTime"),
                                                          isFinishComete: Expression<Bool>("isFinishComete"),
                                                          startAnnotation: Expression<String>("startAnnotation"),
                                                          endAnnotation: Expression<String>("endAnnotation"),
                                                          startPlace: Expression<String>("startPlace"),
                                                          endPlace:  Expression<String>("endPlace"),
                                                          mode: Expression<Int>("mode"),
                                                          note: Expression<String?>("note")
                                                          
            )
            
            
        }
        
     
    
        if(userDBVersion == nil){
            UserDefaults.standard.set("1.0.0", forKey: "DBVersion")
        }
        
    }
    
    deinit {
        self.speedColumnModel = nil
        speedGroupColumnModel = nil
        competeDB = nil
    }
    
    
    func checkVersion(){
     

        if(userDBVersion == self.dbVersion){
            return
        }
        
     
        if(userDBVersion ?? "1.0.0" < self.dbVersion){
            print("更新 Table")
            if(dbVersion == "1.1.0"){
                print("新增 speedGroupTable note")
                
                let isAddColumnSuccess =  addDBField(sFieldName: "note", sTable: "speedGroupTable")
                print("isAddColumnSuccess = \(isAddColumnSuccess)")
                UserDefaults.standard.set(self.dbVersion, forKey: "DBVersion")
                userDBVersion = UserDefaults.standard.string(forKey: "DBVersion")
            }

        }

       
    }
    
    
    func start(){
        
        
        let sqlFilePath = NSHomeDirectory()+filePath+"/competeDB.sqlite3"
        print("sqlFilePath = \(sqlFilePath)")
        //  print("db = ", db)
        do{
            self.competeDB = try Connection(sqlFilePath)
            //print("dcategoryDB = ",( try? self.categoryDB.scalar(self.categoryTable.select(Expression<String>("name").distinct.count))) != nil)
        }catch{
            print("categoryDB error = \(error)")
        }
        
    
        
        if (( try? self.competeDB.scalar(self.speedGroupTable.select(Expression<String>("startTimestamp").distinct.count))) == nil ){
            
            do{
                print("Creat db")
                
                try competeDB.run(speedTable.create(ifNotExists: true){ speedTable in
                    speedTable.column(speedColumnModel!.id,primaryKey: true)
                    speedTable.column(speedColumnModel!.speed)//,unique: true)
                    speedTable.column(speedColumnModel!.time)//,unique: true)
                    speedTable.column(speedColumnModel!.avgSpeed)//,unique: true)
                    speedTable.column(speedColumnModel!.startTimestamp)//,unique: true)
                    speedTable.column(speedColumnModel!.location)//,unique: true)
                    
                })
                
                
                try competeDB.run(speedGroupTable.create(ifNotExists: false){ speedGroupTable in
                    speedGroupTable.column(speedGroupColumnModel!.id,primaryKey: true)
                    speedGroupTable.column(speedGroupColumnModel!.startTimestamp)//,unique: true)
                    speedGroupTable.column(speedGroupColumnModel!.totalKm)//,unique: true)
                    speedGroupTable.column(speedGroupColumnModel!.totalTime)//,unique: true)
                    speedGroupTable.column(speedGroupColumnModel!.isFinishComete)//,unique: true)
                    speedGroupTable.column(speedGroupColumnModel!.startAnnotation)//,unique: true)
                    speedGroupTable.column(speedGroupColumnModel!.endAnnotation)//,unique: true)
                    speedGroupTable.column(speedGroupColumnModel!.startPlace)//,unique: true)
                    speedGroupTable.column(speedGroupColumnModel!.endPlace)//,unique: true),
                    speedGroupTable.column(speedGroupColumnModel!.mode)//,unique: true),
                    speedGroupTable.column(speedGroupColumnModel!.note)//,unique: true),
                })
                
                UserDefaults.standard.set(dbVersion, forKey: "DBVersion")
                
            }catch{
                
                
            }
        }else{
            print("DB存在")
        }
        
        
        checkVersion()
        
        
    }
    
    func addDBField(sFieldName:String, sTable:String) -> Bool
    {
        
        var db :OpaquePointer? = nil
        let sqliteURL: URL = {
            do {
                    return try FileManager.default.url(
                        for: .documentDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: true).appendingPathComponent("competeDB.sqlite3")
            } catch {
                fatalError("Error getting file URL from document directory.")
            }
        }()
        if sqlite3_open(sqliteURL.path, &db) == SQLITE_OK {
            print("資料庫連線成功")
        } else {
            print("資料庫連線失敗")
        }
        
        var bReturn:Bool = false;
        var sSQL="ALTER TABLE " + sTable + " ADD COLUMN " + sFieldName + " TEXT DEFAULT 備註";
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, sSQL, -1, &statement, nil) != SQLITE_OK
        {
            print("Failed to prepare statement")
        }
        else
        {
            if sqlite3_step(statement) == SQLITE_DONE
            {
               print("field " + sFieldName + " added  to  " + sTable);
            }
            sqlite3_finalize(statement);
            bReturn=true;
        }
        return bReturn;
    }
    
    
    
    //插入speedGroup資料
    func insertSpeedGroupData(speedGroupData: SpeedGroupModel)  {
        
        start()
        
        do{
            
            // print("insertFaceGroupData = _id \(_id),_name \(_name)")
            var insert:Insert! = self.speedGroupTable.insert(
                speedGroupColumnModel!.startTimestamp <- speedGroupData.startTimestamp,
                speedGroupColumnModel!.totalTime <- speedGroupData.totalTime,
                speedGroupColumnModel!.totalKm <- speedGroupData.totalKm,
                speedGroupColumnModel!.isFinishComete <- speedGroupData.isFinishComete,
                speedGroupColumnModel!.startAnnotation <- speedGroupData.startAnnotation,
                speedGroupColumnModel!.endAnnotation <- speedGroupData.endAnnotation,
                speedGroupColumnModel!.startPlace <- speedGroupData.startPlace,
                speedGroupColumnModel!.endPlace <- speedGroupData.endPlace,
                speedGroupColumnModel!.mode <- speedGroupData.mode
                
            )
            
            if(self.competeDB == nil){
                return
            }
            
            try competeDB.run(insert)
            
            insert = nil
            
            
        }catch{
              print("insertSpeedGroupData error = \(error)")
        }
        
    }
    
    //插入speedGroup資料
    func insertSpeedDatas(speedDatas: [SpeedModel],startTimestamp:Int)  {
        
        start()
        
        do{
            
            // print("insertFaceGroupData = _id \(_id),_name \(_name)")
            
            if(self.competeDB == nil){
                return
            }
            
            var insert:Insert!
            for speedData in speedDatas{
                
               insert = self.speedTable.insert(
                    speedColumnModel!.speed <- speedData.speed,
                    speedColumnModel!.time <- speedData.time,
                    speedColumnModel!.avgSpeed <- speedData.avgSpeed,
                    speedColumnModel!.startTimestamp <- startTimestamp,
                    speedColumnModel!.location <- speedData.location
                )
                
                
                try competeDB.run(insert)
            }
            

            


            
            insert = nil
            
            
        }catch{
              print("insertSpeedData error = \(error)")
        }
        
    }
    
    func querySpeedGroupData() -> [SpeedGroupModel]{
        
        start()
        
        var speedGroups = [SpeedGroupModel]()
        
        for speedGroup in try! competeDB.prepare(speedGroupTable) {
            
            let categoryData = SpeedGroupModel(id: speedGroup[speedGroupColumnModel!.id],
                                               startTimestamp: speedGroup[speedGroupColumnModel!.startTimestamp],
                                               totalKm: speedGroup[speedGroupColumnModel!.totalKm],
                                               totalTime: speedGroup[speedGroupColumnModel!.totalTime],
                                               isFinishComete: speedGroup[speedGroupColumnModel!.isFinishComete],
                                               startAnnotation: speedGroup[speedGroupColumnModel!.startAnnotation],
                                               endAnnotation: speedGroup[speedGroupColumnModel!.endAnnotation],
                                               startPlace:speedGroup[speedGroupColumnModel!.startPlace],
                                               endPlace:speedGroup[speedGroupColumnModel!.endPlace],
                                               mode:speedGroup [speedGroupColumnModel!.mode],
                                               note: speedGroup [speedGroupColumnModel!.note] ?? ""
            )
            
            speedGroups.append(categoryData)
        }
        
        speedGroups.sort { (speedGroupA, speedGroupB) -> Bool in
            speedGroupA.startTimestamp > speedGroupB.startTimestamp
        }
        
        
        return speedGroups
    }
    
    
    func deleteData(deleteGroupData:RecordModel){
        
        start()

        do{
            
            let delete_GroupData = self.speedGroupTable.filter(speedGroupColumnModel!.startTimestamp == deleteGroupData.timeStamp )
            
            try self.competeDB.run(delete_GroupData.delete())
            
            
            let deleteSpeedDatas = self.speedTable.filter(speedColumnModel!.startTimestamp == deleteGroupData.timeStamp )
            
            try self.competeDB.run(deleteSpeedDatas.delete())
            
            
        }catch{
            print("deleteCustomeCategoryData error = \(error)")
        }
        
        
        
        
    }
    
    func querySpeedData(startTimeStamp:Int) -> [SpeedModel]{
        
        start()
        
        var speedDatas = [SpeedModel]()
        let filterTable = speedTable.filter(speedColumnModel!.startTimestamp == startTimeStamp)
        for speedData in try! competeDB.prepare(filterTable) {
        
            let data = SpeedModel(id: speedData[speedColumnModel!.id],
                                  speed: speedData[speedColumnModel!.speed],
                                  time: speedData[speedColumnModel!.time],
                                  avgSpeed: speedData[speedColumnModel!.avgSpeed],
                                  startTimestamp: speedData[speedColumnModel!.startTimestamp],
                                  location: speedData[speedColumnModel!.location])
        
            speedDatas.append(data)
        }
        
        speedDatas.sort { (speedModelA, speedModelB) -> Bool in
            return speedModelA.time < speedModelB.time
        }
        
        return speedDatas
    }
    
    
    
    func updateNote(timeStamp:Int,newNote:String){
        
        start()
        
        let categoryData = speedGroupTable.filter(speedGroupColumnModel!.startTimestamp == timeStamp)
        do{
          
            try self.competeDB.run(categoryData.update(speedGroupColumnModel!.note <- newNote ) )
        }catch{
            print("updateSort error = \(error)")
        }
        
    }
    
    
    
    func deleteDB(){
        competeDB = nil
        let fm = FileManager.default
        
        let sqlFilePath = NSHomeDirectory()+filePath+"/competeDB.sqlite3"
        do {
            let vFileURL = NSURL(fileURLWithPath: sqlFilePath)
            try fm.removeItem(at: vFileURL as URL)
            print("Database Deleted!")
        } catch {
            print("Error on Delete Database!!!")
        }
        
    }
    
    func cloaseDB(){
        self.competeDB = nil
    }
    
    
}
