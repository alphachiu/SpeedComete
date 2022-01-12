//
//  MissionVC_Event.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/11/14.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import SCLAlertView
import MapKit

extension MissionVC{
    
    @objc func startEvent(){
        print("startEvent")
        
        
      //  fatalError()
        if(CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined){
            
            SpeedSingleton.share.showAlert(viewConroller: self, "請開啟權限")
            
            return
          
        }
        
        
        self.missionMapView.mapView.isPitchEnabled = false
        let currentcell = self.cardCollectionView.cardCollectionView.visibleCells.first
        if currentcell is CommonModelCell{ //普通模式
            
            let cell = currentcell as? CommonModelCell
            

            if(cell?.startTextField.text == "" || self.missionMapView.start_Location == nil){
                
                SpeedSingleton.share.showAlert(viewConroller: self, "請輸入起始位置")
                return
                
            }else if(cell?.endTextField.text == "" || self.missionMapView.end_Location == nil){
                SpeedSingleton.share.showAlert(viewConroller: self, "請輸入終點位置")
                return
            } else{

                let totalkm = SpeedSingleton.share.calculateDistance(startLocation: self.missionMapView.start_Location, endLocation: self.missionMapView.end_Location)
                totoalKM = String(format: "%.01f", totalkm)
                
//                self.speedLabel.text = "0.0"
//                self.topSpeedLabel.text = "0.0"
//                self.avgSpeedLabel.text = "0.0"
//                self.timeLabel.text = "00:00:00"
           
                missionMapView.locationManager.startUpdatingLocation()
                
                let distanceMeters = missionMapView.start_Location.distance(from: missionMapView.userLocation) / 1000
                print("distanceMeters model = \(distanceMeters)")
             
                
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                
                if(distanceMeters < 0.12 ){
                    modeTag = 0
                    print("立即開始模式")
                 //   SpeedSingleton.share.showAlert(viewConroller: self, "(立即開始模式)")
                    alertView.addButton("我知道了") {
                        self.startCompeteVC()
                    }
                    alertView.showSuccess("立即模式-提示通知", subTitle: "\n當前行駛時速大於20/hr則開始計時，直到到達方格旗(終點)才結束計時。")
                    
                }else{
                    modeTag = 1
                    alertView.addButton("我知道了") {
                        self.startCompeteVC()
                    }
                    alertView.showSuccess("自訂模式-提示通知", subTitle: "\n1.請前往紅色旗幟(起點)則開始計時，直到到達方格旗(終點)才結束計時。")
                }
                
              
                
           }
        
        
        
        }
        
        
    }
    
    func startCompeteVC(){
        

        mapViewFixMemory()
        
        let vc =  SpeedCometeVC()
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        
//        vc.mapView?.modeStyle = modeTag
//        vc.mapView!.startAnnotation = self.missionMapView.startAnnotation
//        vc.mapView!.endAnnotation = self.missionMapView.endAnnotation
//        vc.mapView!.startMKCircle = self.missionMapView.startMKCircle
//        vc.mapView!.endMKCircle = self.missionMapView.endMKCircle
//        vc.mapView!.start_Location = self.missionMapView.start_Location
//        vc.mapView!.end_Location = self.missionMapView.end_Location
        vc.viewModel.starPlace.value = self.missionMapView.startPlace
        vc.viewModel.endPlace.value = self.missionMapView.endPlace
        vc.viewModel.totalKM.value = totoalKM
        
    //    let navVC = UINavigationController(rootViewController: vc)
        
        self.present(vc, animated: true) {

            
            let cell = self.cardCollectionView.cardCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? CommonModelCell
            if(cell != nil){
             
                cell?.startTextField.text = ""
                cell?.endTextField.text = ""
                self.missionMapView.mapView.removeAnnotations(self.missionMapView.mapView.annotations)
                
            }
            

        }
        
        
        
    }
    
}


extension MissionVC:SpeedCometeDelegate{

    
    func getMapInfo() -> (modeStyle: Int, startAnnotation: ImageAnnotation, endAnnotation: ImageAnnotation, start_Location: CLLocation, end_Location: CLLocation) {
        
        
        //        vc.mapView?.modeStyle = modeTag
        //        vc.mapView!.startAnnotation = self.missionMapView.startAnnotation
        //        vc.mapView!.endAnnotation = self.missionMapView.endAnnotation
        //        vc.mapView!.startMKCircle = self.missionMapView.startMKCircle
        //        vc.mapView!.endMKCircle = self.missionMapView.endMKCircle
        //        vc.mapView!.start_Location = self.missionMapView.start_Location
        //        vc.mapView!.end_Location = self.missionMapView.end_Location
        
        
       return (modeTag,self.missionMapView.startAnnotation,self.missionMapView.endAnnotation,self.missionMapView.start_Location,self.missionMapView.end_Location)
        
    }
    
    
}
