//
//  MapView.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/10/11.
//  Copyright © 2020 Alpha. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import MapKit


protocol MapViewDelegate {
    
    func getLocationDats(currentSpeed:Double,topSpeed: CLLocationSpeed,avgSpeed: CLLocationSpeed)
    func setTimerStart(isStart:Bool) //當接近範圍則啟動計時
   // func getUserLocation(isGetLocation:Bool)
    
}

class MapView: UIView {
    

    var mapView:MKMapView!
    let regionRadius = 30.0
    
    var start_Location:CLLocation!
    var end_Location:CLLocation!
    
    var startAnnotation:ImageAnnotation!  = ImageAnnotation()
    var endAnnotation:ImageAnnotation!  = ImageAnnotation()
    
    var startMKCircle:MKCircle!
    var endMKCircle:MKCircle!

 //   var isUserStopLocation = false
    var modeStyle = -1 // 0 立即開始 1 接觸start開始
    
    var userLocation:CLLocation?
    var userAnnotionView: MKAnnotationView?
    
    var locationManager = CLLocationManager()
    var speeds = [CLLocationSpeed]()
    var myPathPoint = [CLLocationCoordinate2D]()
    
    var avgSpeed: CLLocationSpeed {
        return speeds.count == 0 ? 0.0 : speeds.reduce(0,+)/Double(speeds.count) //the reduce returns the sum of the array, then dividing it by the count gives its average
    }
    var topSpeed: CLLocationSpeed {
        return speeds.max() ?? 0 > currentTopSpeed ? speeds.max() ?? 0.0 : currentTopSpeed //return 0 if the array is empty
    }
    
    var currentTopSpeed:CLLocationSpeed = 0.0
    
    var isCompeteFinish = true // 未開始 / 完賽
    var isDrawPath = false //開始畫路線
    var isOverStartAnnotion = false
    var delegate:MapViewDelegate?

    var userLocationIcon = UIImage(named: "userIcon")?.scaled(toHeight: 80)

    var notFindGetUserLocationView = UIView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        mapView = MKMapView(frame: .zero)
        
        mapView.mapType = .standard
        mapView.delegate = self  //委派給ViewController
        mapView.showsUserLocation = true   //顯示user位置
        mapView.userTrackingMode = .followWithHeading  //隨著user移動
        
        mapView.isRotateEnabled = true
        mapView.isZoomEnabled = false
        
        self.addSubview(mapView)
        
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        locationManager.delegate = self  //委派給ViewController
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  //設定為最佳精度
        locationManager.activityType = .automotiveNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        
        notFindGetUserLocationView.backgroundColor = .black
        notFindGetUserLocationView.layer.cornerRadius = 10.0
        notFindGetUserLocationView.isHidden = true
        mapView.addSubview(notFindGetUserLocationView)
        
        notFindGetUserLocationView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(100)
            make.right.equalToSuperview().offset(-100)
            make.height.equalTo(50)
            make.centerY.equalToSuperview().offset(-50)
            
        }
        
        let discription = UILabel(frame: .zero)
        discription.textColor = .red
        discription.text = "當前位置偵測微弱"
        discription.textAlignment = .center
        discription.font = UIFont(name: "PingFangTC-Regular", size: 20)
        notFindGetUserLocationView.addSubview(discription)
        
        discription.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

    }
    

    func reset(){
        
        switch (self.mapView.mapType) {
        case .hybrid:
            self.mapView.mapType = .standard
                
                break;
        case .standard:
            self.mapView.mapType = .hybrid;
                break;
            default:
                break;
        }
        
        self.modeStyle = -1
        self.myPathPoint.removeAll()
        self.start_Location = nil
        self.end_Location = nil
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.layer.removeAllAnimations()
//        self.mapView.removeOverlay(self.startMKCircle)
//        self.mapView.removeOverlay(self.endMKCircle)
        self.startAnnotation.image = nil
        self.endAnnotation.image = nil
        self.mapView.removeAnnotation(self.startAnnotation)
        self.mapView.removeAnnotation(self.endAnnotation)
        startAnnotation = nil
        endAnnotation = nil
        isDrawPath = false
 
        speeds.removeAll()
    
    
        self.mapView.isPitchEnabled = true
        self.locationManager.stopUpdatingLocation()
 
        self.mapView.showsUserLocation = false
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.delegate = nil
        self.locationManager.delegate = nil
        self.mapView.removeFromSuperview()
        self.mapView = nil
      
    }
    
    deinit {
        print("map deinit")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
extension MapView:CLLocationManagerDelegate{
    
    
    // MARK: - CLLocationManagerDelegate
//    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//
//        var degrees = newHeading.trueHeading
//        print("degrees = \(degrees)")
//         //Rotate the arrow image
//         if self.userAnnotionView != nil {
//
//          //  self.userAnnotionView?.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * (180.0 / M_PI)))
//            var direction = newHeading.trueHeading as Double
//
//            self.userAnnotionView?.image = self.imageRotatedByDegrees(degrees: CGFloat(direction), image: UIImage(named: "userIcon")!).scaled(toHeight: 80)
////            print("self.userAnnotionView?.image size = \(self.userAnnotionView?.image?.size)")
//         }
//
//    }
//
//
//    func imageRotatedByDegrees(degrees: CGFloat, image: UIImage) -> UIImage{
//         var size = image.size
//
//         UIGraphicsBeginImageContext(size)
//         var context = UIGraphicsGetCurrentContext()
//
//        context!.translateBy(x: 0.5*size.width, y: 0.5*size.height)
//        context!.rotate(by: CGFloat(DegreesToRadians(degrees: Double(degrees))))
//
//        image.draw(in: CGRect(origin: CGPoint(x: -size.width*0.5, y: -size.height*0.5), size: size))
//         var newImage = UIGraphicsGetImageFromCurrentImageContext()
//         UIGraphicsEndImageContext()
//
//        return newImage!
//     }
//
//    func DegreesToRadians(degrees: Double) -> Double {
//          return degrees * M_PI / 180.0
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let userLocation: CLLocation = locations[0] //最新的位置在[0]
        

        if(isCompeteFinish ){
            return
        }
        
        self.notFindGetUserLocationView.isHidden = true
        
        //設置顯示區域
        let currentRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        self.mapView.setRegion(currentRegion, animated: self.userLocation != nil ? true : false)
       
        let  camera = MKMapCamera(lookingAtCenter:  userLocation.coordinate, fromDistance: 1000, pitch: 70, heading: userLocation.course == -1 ? 0 :userLocation.course)
        mapView.setCamera(camera, animated:  self.userLocation != nil ? true : false)
        
         // 1 m/s to km/h = 3.6km/h
        let speed = userLocation.speed < 0 ? 0 :userLocation.speed * (18/5)
        
        if(self.userLocation == nil){
            self.userLocation = CLLocation()
        }
        
        self.userLocation = userLocation

        //繪製路線
        if(isDrawPath){
            
            myPathPoint.append(userLocation.coordinate)
//            let path = MKPolyline(coordinates:myPathPoint, count: myPathPoint.count)
//            //path.title = "my_path"
//            self.mapView.addOverlay(path, level: MKOverlayLevel.aboveRoads)
        }
        
        //10個為單位 畫出路線
//        if(myPathPoint.count > 10){
//            myPathPoint.removeAll()
//            self.mapView.removeOverlays(self.mapView.overlays)
//        }
        
        if(speed == 0){
            locationManager.stopUpdatingLocation()
            return
        }else{
            //locationManager.start()
        }

        
        //10個為單位 計算平均速度
        if(speeds.count > 10){
            speeds.removeAll()
        }
        
        speeds.append(contentsOf: locations.map{$0.speed < 0 ? 0 : $0.speed * (18/5)}) //append all new speed updates to the array
        
        let kmt = speed
        
        
        self.delegate?.getLocationDats(currentSpeed: kmt, topSpeed: topSpeed, avgSpeed: avgSpeed)
        
        currentTopSpeed = topSpeed > currentTopSpeed ? topSpeed : currentTopSpeed
        
        
    }
        
        // 1. 當用戶進入一個 region
 func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
     
//
      //  showAlert("enter \(region.identifier)")
      print("enter region = \(region.identifier)")

    
     if(region.identifier == "START" && !isOverStartAnnotion){
         
         self.isDrawPath  = true
        self.isOverStartAnnotion = true
     }else{
         self.isDrawPath = false
     }

    
    
    if(isDrawPath && !isCompeteFinish && modeStyle == 1){
 
      //  SpeedSingleton.share.showAlert(viewConroller: self.findViewController()!, "(自訂起點模式)，計時開始")
        let vc = findViewController()
        vc?.showToast(message: "計時開始")
        
        delegate?.setTimerStart(isStart: true)
        
    }else if(isOverStartAnnotion){
        
        
        SpeedSingleton.share.showAlert(viewConroller: self.findViewController()!, "恭喜，已到達終點！")
        isCompeteFinish = true
        delegate?.setTimerStart(isStart: false)

        let paths = MKPolyline(coordinates:myPathPoint, count: myPathPoint.count)
        self.mapView.addOverlay(paths, level: MKOverlayLevel.aboveRoads)
        var regionRect = paths.boundingMapRect
        let wPadding = regionRect.size.width * 2.0
        let hPadding = regionRect.size.height * 2.0
        //Add padding to the region
        regionRect.size.width += wPadding
        regionRect.size.height += hPadding
        //Center the region on the line
        regionRect.origin.x -= wPadding / 2
        regionRect.origin.y -= hPadding / 2
        self.mapView.setRegion(MKCoordinateRegion(regionRect), animated: true)
        
      
    }else{
        print("尚未通過起點")
       // vc?.showToast(message: "計時開始")
    }

     
 }

        // 2. 當用戶退出一個 region
 func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {

     
 }
        
//    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
//        print("The monitored regions are: \(manager.monitoredRegions)")
//        manager.requestState(for: region)
//
//    }
//    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
//        guard region is CLBeaconRegion else { return }
//
//        if state == .inside { // 在範圍內
//            if CLLocationManager.isRangingAvailable() {
//                manager.startRangingBeacons(in: region as! CLBeaconRegion)
//            }
//        } else if state == .outside { // 在範圍外
//            if CLLocationManager.isRangingAvailable() {
//                manager.stopRangingBeacons(in: region as! CLBeaconRegion)
//            }
//        }
//    }

}

extension MapView:MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //print("userLocation = \(userLocation.location?.speed)")

        let  userLocation = userLocation.location
        let speed = userLocation?.speed ?? 0

       let userSpeed = speed * (18/5)

       self.notFindGetUserLocationView.isHidden = true
//        if(userSpeed > 1.0 && !isUserStopLocation){
//            return
//        }
//        if(userLocation != nil){
//
//
//            let currentRegion = MKCoordinateRegion(center: userLocation!.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
//           self.mapView.setRegion(currentRegion, animated: false)
//
//            let  camera = MKMapCamera(lookingAtCenter:  userLocation!.coordinate, fromDistance: 1000, pitch: 70, heading: userLocation!.course == -1 ? 0 :userLocation!.course)
//            mapView.setCamera(camera, animated: false)
//        }
        print("userLocation speed = \(userSpeed)")
        
        if(modeStyle == -1 || isCompeteFinish){
            return
        }
              
        
        if(userSpeed <= 0){
           // locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.stopUpdatingLocation()
           // mapView.delegate = nil
            print("停止中")
         //   if(!isUserStopLocation){
             
                self.delegate?.getLocationDats(currentSpeed: 0, topSpeed: topSpeed, avgSpeed: avgSpeed)
         //   }
//            isUserStopLocation = true
        }else if(userSpeed >= 0){
//            self.delegate?.getLocationDats(currentSpeed: 0, topSpeed: topSpeed, avgSpeed: avgSpeed)
            locationManager.startUpdatingLocation()
           // mapView.delegate = self
           // locationManager.pausesLocationUpdatesAutomatically = false
           // isUserStopLocation = false
            print("開始中")
        }
        
    }
    
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        print("正在跟踪用户的位置")
        self.notFindGetUserLocationView.isHidden = true
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        print("跟踪用户的位置失败")
     
        if(!isCompeteFinish){
            
            self.notFindGetUserLocationView.isHidden = false
            
           UIView.animate(withDuration: 1, delay: 0, options:  [.repeat, .autoreverse]) {
                
                self.notFindGetUserLocationView.alpha = 0
                
            } completion: { (isFinish) in
                self.notFindGetUserLocationView.alpha = 1
                self.locationManager.startUpdatingLocation()
            }
        }
        
    }
    
    func mapView(_ map: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            let reuseId = "MyPin"
            userAnnotionView =
                mapView.dequeueReusableAnnotationView(
                    withIdentifier: reuseId)
              if userAnnotionView == nil {
                  // 建立一個地圖圖示視圖
                userAnnotionView = MKAnnotationView(
                    annotation: annotation,
                    reuseIdentifier: reuseId)
                  // 設置點擊地圖圖示後額外的視圖
                userAnnotionView?.canShowCallout = false
                
                  // 設置自訂圖示

                    self.userAnnotionView?.image = userLocationIcon
              } else {
                userAnnotionView?.annotation = annotation
              }

              return userAnnotionView
            
        }else{
            
            
    //        if let _ = annotation as? MKPointAnnotation {
    //
    //            let identifier = "pinAnnotation"
    //
    //            if let view = map.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
    //
    //                view.pinTintColor =  .blue
    //
    //
    //                return view
    //
    //            } else {
    //                let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
    //
    //                view.canShowCallout = true
    //
    //                if(view.annotation?.title == "起點"){
    //                    view.pinTintColor = .purple
    //                    view.animatesDrop = true
    //                    view.isDraggable = true
    //                }else{
    //                    view.pinTintColor = .red
    //                    view.animatesDrop = true
    //                    view.isDraggable = true
    //                }
    //
    //
    //                return view
    //            }
    //        }
            
            if !annotation.isKind(of: ImageAnnotation.self) {  //Handle non-ImageAnnotations..
                  var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "DefaultPinView")
                  if pinAnnotationView == nil {
                      pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DefaultPinView")
                  }
                  return pinAnnotationView
              }

              //Handle ImageAnnotations..
              var view: ImageAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? ImageAnnotationView
              if view == nil {
                  view = ImageAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")
              }

              let annotation = annotation as! ImageAnnotation
              view?.image = annotation.image
              view?.isDraggable = false
            
            //  view?.isDraggable = true
              view?.annotation = annotation
            
            return view
            
    //        return nil
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let overlay = overlay as? MKPolyline{
            
            //            let polyLineRender = MKPolylineRenderer(overlay: overlay)
            //            polyLineRender.strokeColor = UIColor.red
            //            polyLineRender.lineWidth = 10
            //
            //            return polyLineRender
            let gradientColors = [UIColor.green, UIColor.yellow, UIColor.red]
            
            /// Initialise a GradientPathRenderer with the colors
            let polylineRenderer = GradientPathRender(polyline: overlay, colors:gradientColors)
    
            
            /// set a linewidth
            polylineRenderer.lineWidth = 5
            return polylineRenderer
            
        }else{
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.strokeColor = .blue
            circleRenderer.lineWidth = 5.0
            return circleRenderer
        }
        

    }
    
  
    
}
