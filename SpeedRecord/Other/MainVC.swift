//
//  MainVC.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/9/12.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import SnapKit
import CoreLocation
import MapKit


class MainVC: UIViewController {

    
    @IBOutlet weak var curentSpeedLabel: UILabel!
    
    @IBOutlet weak var avargeSpeedLabel: UILabel!
    
    @IBOutlet weak var topSpeedLabel: UILabel!
    
    @IBOutlet weak var startLocation: UITextField!
    
    @IBOutlet weak var endLocation: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var userLocationBtn: UIButton!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var startBtn: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var switchModelBtn: UIButton!
    
    let regionRadius = 50.0
    var isSpeedEnd = false
    
    var start_Location:CLLocation!
    var end_Location:CLLocation!
    
    var startAnnotation:MKPointAnnotation!  = MKPointAnnotation()
    var endAnnotation:MKPointAnnotation!  = MKPointAnnotation()
    
    var startMKCircle:MKCircle!
    var endMKCircle:MKCircle!
    
    var userLocation:CLLocation!
    var locationManager = CLLocationManager()
    var speeds = [CLLocationSpeed]()
    
    var second:Int = 0
    var isStart_Start_Region = false
    var isEnd_Start_Region = false

    @IBOutlet weak var coverView: UIView!
    
    var timer = Timer()
    
    var myPathPoint = [CLLocationCoordinate2D]()
    
    var model = 0 //0 立即開始 1 預先起點然後開始
    
    var avgSpeed: CLLocationSpeed {
        return speeds.reduce(0,+)/Double(speeds.count) //the reduce returns the sum of the array, then dividing it by the count gives its average
    }
    var topSpeed: CLLocationSpeed {
        return speeds.max() ?? 0 > currentTopSpeed ? speeds.max() ?? 0.0 : currentTopSpeed //return 0 if the array is empty
    }
    
    var currentTopSpeed:CLLocationSpeed = 0.0
    
    override func viewDidAppear(_ animated: Bool) {
                 super.viewDidAppear(animated)
        
              // status is not determined
              if CLLocationManager.authorizationStatus() == .notDetermined {
                  locationManager.requestAlwaysAuthorization()
                  locationManager.startUpdatingLocation()
              }
              // authorization were denied
              else if CLLocationManager.authorizationStatus() == .denied {
                  showAlert("Location services were previously denied. Please enable location services for this app in Settings.")
              }else if(CLLocationManager.authorizationStatus() == .authorizedAlways){
                
       
                  locationManager.startUpdatingLocation()
              }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.delegate = self  //委派給ViewController
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  //設定為最佳精度
        locationManager.activityType = .automotiveNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false

        mapView.delegate = self  //委派給ViewController
        mapView.showsUserLocation = true   //顯示user位置
        mapView.userTrackingMode = .followWithHeading  //隨著user移動
        mapView.isRotateEnabled = true
        
        mapView.isHidden = true
        curentSpeedLabel.isHidden = false
        
        //textfiled
        startLocation.delegate = self
        endLocation.delegate = self


        coverView.isHidden = true

  
    }
    
    
    func setTimer(){
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            
            
            self.second += 1
            let hours = Int(self.second) / 3600
            let minutes = Int(self.second) / 60 % 60
            let seconds = Int(self.second) % 60
            print("\(String(format:"%02i:%02i:%02i", hours, minutes, seconds))")
            
            self.timeLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
            
            
            
        })
        
        
    }
    
    
    //計算距離
    func calculateDistance() -> Double{
        
        if(self.start_Location != nil && self.end_Location != nil ){
            let distanceMeters = self.start_Location.distance(from: self.end_Location) / 1000
          //  print(String(format: "distanceMeters is %.01fkm", distanceMeters))
         
            return  distanceMeters
        }
   
        return 0.0
    }
    
    func reset(){
        
        timer.invalidate()
        self.start_Location = nil
        self.end_Location = nil
        self.mapView.removeOverlay(self.startMKCircle)
        self.mapView.removeOverlay(self.endMKCircle)
        
        self.mapView.removeAnnotation(self.startAnnotation)
        self.mapView.removeAnnotation(self.endAnnotation)
        
        self.isStart_Start_Region  = false
        self.isEnd_Start_Region = false
        coverView.isHidden = true
        isSpeedEnd = true
//        curentSpeedLabel.text = "0.0"
//        distanceLabel.text = "0.0"
//        avargeSpeedLabel.text = "0.0"
//        topSpeedLabel.text = "0.0"
//        timeLabel.text = "00:00:00"
        
        self.startLocation.text = "起始位置"
        self.endLocation.text = "終點位置"
        
        
    }
    
    
    @IBAction func currentStartLocationEvent(_ sender: Any) {
        
        // we do have authorization
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            
            if(userLocation == nil){
                
                return
            }
            
            self.startAnnotation.coordinate = userLocation.coordinate
            self.startAnnotation.title = "start"
            
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  self.startAnnotation.coordinate.latitude, longitude:  self.startAnnotation.coordinate.longitude), radius: self.regionRadius, identifier: "START")
            self.locationManager.startMonitoring(for: region)
            
            //添加大头针
            self.mapView.addAnnotation( self.startAnnotation)
            // . 繪製一個圓圈圖形（用於表示 region 的範圍）
            self.startMKCircle = MKCircle(center: userLocation.coordinate, radius: self.regionRadius)
            self.mapView.addOverlay(self.startMKCircle)
            
            
            self.start_Location = CLLocation(latitude: self.startAnnotation.coordinate.latitude, longitude: self.startAnnotation.coordinate.longitude)
            self.startLocation.text = "目前位置"
            
            
            
        }else{
                 showAlert("請打開權限")
                 
        }
        
        
    }
    
    @IBAction func switchModelEvent(_ sender: Any) {
        
        if(model == 0){
            model = 1
            switchModelBtn.setTitle("模式一", for: .normal)
            startBtn.setTitle("自訂起點(開始)", for: .normal)
            
        }else{
            model = 0
            switchModelBtn.setTitle("模式二", for: .normal)
            startBtn.setTitle("從目前位置(開始)", for: .normal)
            
        }
      
    }
    
    
    @IBAction func startEvent(_ sender: Any) {
        
        
        
        if(self.start_Location == nil ){
            
            showAlert("請輸入起點位置")
            
        }else if(self.end_Location == nil){
            showAlert("請輸入終點位置")
            
        } else{
            

            if(model == 1 ){
                
                let distanceMeters = self.start_Location.distance(from: self.userLocation) / 1000
                print("distanceMeters model = \(distanceMeters)")
                if(distanceMeters < 0.12 ){
               
                    
                    model = 0
                    switchModelBtn.setTitle("模式二", for: .normal)
                    startBtn.setTitle("從目前位置(開始)", for: .normal)
                    
                    showAlert("起點需要離目前位置100公尺以上")
                }else{
                    startBtn.setTitle("自訂起點(執行中)", for: .normal)
                    coverView.isHidden = false
                    mapView.userTrackingMode = .followWithHeading  //隨著user移動
                
                    
                }
                
                
            }else{
                startBtn.setTitle("從目前位置(執行中)", for: .normal)
                isStart_Start_Region = true
                setTimer()
                coverView.isHidden = false
                mapView.userTrackingMode = .followWithHeading  //隨著user移動
            }

            
        }

        
    }
    
    
    
    
    @IBAction func switchEvent(_ sender: Any) {
        
        if(mapView.isHidden){
      
               mapView.isHidden = false
        }else{
  
               mapView.isHidden = true
        }
        
    }
    

    @IBAction func userLocationEvent(_ sender: Any) {
        
        mapView.userTrackingMode = .followWithHeading  //隨著user移動

    }
    
    
    func showAlert(_ message:String){
        
         let controller = UIAlertController(title: "Racing 通知", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
        
    }
    
    
}


extension MainVC:CLLocationManagerDelegate{
    
       
       // MARK: - CLLocationManagerDelegate
       
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        
        
        let userLocation: CLLocation = locations[0] //最新的位置在[0]
        
        if(isSpeedEnd){
            return
        }
        
        
        self.userLocation = userLocation
        // self.curentSpeedLabel.text = "\(userLocation.speed)"
        
        
        
        //10個為單位 畫出路線
        if(myPathPoint.count > 10){
            myPathPoint.removeAll()
        }
        
        //繪製路線
        if(isStart_Start_Region){
            
            myPathPoint.append(userLocation.coordinate)
            let path = MKPolyline(coordinates:myPathPoint, count: myPathPoint.count)
            //         path.title = "my_path"
            self.mapView.addOverlay(path, level: MKOverlayLevel.aboveRoads)
        }
   
        
        
        let speed = userLocation.speed < 0 ? 0 :userLocation.speed * (18/5)
        
        //10個為單位 計算平均速度
        if(speeds.count > 10){
            speeds.removeAll()
        }
        
        speeds.append(contentsOf: locations.map{$0.speed < 0 ? 0 : $0.speed * (18/5)}) //append all new speed updates to the array
        
        
        //  self.distanceLabel.text = "\(speed)"
        // m/s to km/h
        
        let kmt = speed
        let kmtLabel = kmt
        
        curentSpeedLabel.text = String(format: "%.1f",kmtLabel)
        //  showAlert("目前速度 ： \(kmtLabel)")
        
        // Top Speed
        topSpeedLabel.text = String(format: "%.1f",topSpeed)
        
        // Average speed
        self.avargeSpeedLabel.text = String(format: "%.1f",avgSpeed)
        
        currentTopSpeed = topSpeed > currentTopSpeed ? topSpeed : currentTopSpeed
        
        
        print("course = \(userLocation.course)")
        print("timestamp = \(userLocation.timestamp)")
        print("speedAccuracy = \(userLocation.speedAccuracy)")
        print("courseAccuracy = \(userLocation.courseAccuracy)")

        //        if let location = self.userLocation{
        //                  let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        //                  let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        //                  self.mapView.setRegion(region, animated: true)
        //              }
    }
           
           // 1. 當用戶進入一個 region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
//
//        showAlert("enter \(region.identifier)")
//
        
        if(region.identifier == "START"){
            
            self.isStart_Start_Region  = true
            
        }else{
            self.isEnd_Start_Region = true
        }
        
        if(model == 1){

            
            if(isStart_Start_Region && !self.isEnd_Start_Region){
                
                setTimer()
                showAlert("計時開始")
                startBtn.isEnabled = false
                
            }else if(isEnd_Start_Region){
              
                showAlert("已到達終點")
                startBtn.setTitle("自訂起點(開始)", for: .normal)
                startBtn.isEnabled = true
                
                //重置
                reset()
                
                
            }
            
        }else{
            
            if(isEnd_Start_Region){

                showAlert("已到達終點")
                startBtn.setTitle("從目前位置(開始)", for: .normal)
                startBtn.isEnabled = true
                
                //重置
                reset()
                
            }
            
            
        }
        

        
    }

           // 2. 當用戶退出一個 region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
       //
  //      showAlert("exit \(region.identifier)")
        
//        if(region.identifier == "START"){
//
//            self.isStart_End_Region  = true
//            self.isStart_Start_Region = true
//
//        }else{
//            self.isEnd_End_Region = true
//        }
//
//

        
    }
           
       func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
               print("The monitored regions are: \(manager.monitoredRegions)")
           }
    
}


extension MainVC:MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
    }
    
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        print("正在跟踪用户的位置")
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        print("跟踪用户的位置失败")
    }
    
    func mapView(_ map: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let _ = annotation as? MKPointAnnotation {
            
            let identifier = "pinAnnotation"
            
            if let view = map.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                
                view.pinTintColor =  .purple
                
                
                return view
                
            } else {
                let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                
                view.canShowCallout = true
                
                if(view.annotation?.title == "start"){
                    view.pinTintColor = .purple
                    view.animatesDrop = true
                    view.isDraggable = true
                }else{
                    view.pinTintColor = .red
                    view.animatesDrop = true
                    view.isDraggable = true
                }
                
                
                return view
            }
        }
        
        return nil
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let overlay = overlay as? MKPolyline{
            
            //            let polyLineRender = MKPolylineRenderer(overlay: overlay)
            //            polyLineRender.strokeColor = UIColor.red
            //            polyLineRender.lineWidth = 10
            //
            //            return polyLineRender
            let gradientColors = [UIColor.green, UIColor.blue, UIColor.yellow, UIColor.red]
            
            /// Initialise a GradientPathRenderer with the colors
            let polylineRenderer = GradientPathRender(polyline: overlay, colors:gradientColors)
    
            
            /// set a linewidth
            polylineRenderer.lineWidth = 7
            return polylineRenderer
            
        }else{
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.strokeColor = .blue
            circleRenderer.lineWidth = 5.0
            return circleRenderer
        }
        

    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationView.DragState,
                 fromOldState oldState: MKAnnotationView.DragState) {
        
        if(view.annotation?.title == "start"){
            
            // setup region
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  self.startAnnotation.coordinate.latitude,longitude:  self.startAnnotation.coordinate.longitude), radius: regionRadius, identifier: "START")
            locationManager.startMonitoring(for: region)
            
            self.mapView.removeOverlay(self.startMKCircle)
            self.startMKCircle = MKCircle(center: self.startAnnotation.coordinate, radius: regionRadius)
            self.mapView.addOverlay(self.startMKCircle)
            
            self.start_Location = CLLocation(latitude: self.startAnnotation.coordinate.latitude, longitude: self.startAnnotation.coordinate.longitude)
            
            print("view.annotation = \(view.annotation?.coordinate)")
        }else{
            
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  self.endAnnotation.coordinate.latitude, longitude:  self.endAnnotation.coordinate.longitude), radius: regionRadius, identifier: "END")
            locationManager.startMonitoring(for: region)
            
            self.mapView.removeOverlay(self.endMKCircle)
            self.endMKCircle = MKCircle(center: self.endAnnotation.coordinate, radius: regionRadius)
            self.mapView.addOverlay( self.endMKCircle)
            
            self.end_Location = CLLocation(latitude: self.endAnnotation.coordinate.latitude, longitude: self.endAnnotation.coordinate.longitude)
            
            
            print("view.annotation = \(view.annotation?.coordinate)")
        }
        
        
        
        //        switch newState {
        //        case .starting:
        //            view.dragState = .dragging
        //        case .ending, .canceling:
        //            view.dragState = .none
        //        default: break
        //        }
    }
    
}

extension MainVC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textField.text ?? "") { (placemarks, error) in
            guard  let placemarks = placemarks,  let location = placemarks.first?.location   else {
                
              //  textField.text = "找不到，請重新輸入"
                
                if(textField.tag == 1){
                    self.showAlert("起始點輸入錯誤，請重新輸入")
                }else{
                    self.showAlert("終點輸入錯誤，請重新輸入")
                }
                
                return
            }
            // handle no location found
            
            print("location = \(location)")
            
            if(textField.tag == 1){
                
                self.start_Location = location
                
                self.startAnnotation.coordinate = location.coordinate
                self.startAnnotation.title = "start"
                
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  self.startAnnotation.coordinate.latitude, longitude:  self.startAnnotation.coordinate.longitude), radius: self.regionRadius, identifier: "START")
                self.locationManager.startMonitoring(for: region)
                
                
                if(self.startMKCircle != nil){
                      self.mapView.removeOverlay(self.startMKCircle)
                }
                
                //添加大头针
                self.mapView.addAnnotation( self.startAnnotation)
                // . 繪製一個圓圈圖形（用於表示 region 的範圍）
                self.startMKCircle = MKCircle(center: location.coordinate, radius: self.regionRadius)
                self.mapView.addOverlay(self.startMKCircle)
                
               
                
            }else{
                self.end_Location = location
                self.endAnnotation.coordinate = location.coordinate
                self.endAnnotation.title = "end"
                
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  self.endAnnotation.coordinate.latitude, longitude:  self.endAnnotation.coordinate.longitude), radius: self.regionRadius, identifier: "輸入錯誤ＥＮＤ")
                    self.locationManager.startMonitoring(for: region)
                
                if(self.endMKCircle != nil){
                    self.mapView.removeOverlay(self.endMKCircle)
                }
                //添加大头针
                self.mapView.addAnnotation( self.endAnnotation)
                  // . 繪製一個圓圈圖形（用於表示 region 的範圍）
                self.endMKCircle = MKCircle(center: location.coordinate, radius: self.regionRadius)
                self.mapView.addOverlay(self.endMKCircle)
    
                
            }

            
            self.distanceLabel.text =  String(format: "%.01fkm", self.calculateDistance())
            // Use your location
        }
        
        
        
    }
    
 
    
}
