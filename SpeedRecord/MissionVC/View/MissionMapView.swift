//
//  MissionMapView.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/11/14.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SnapKit


protocol MissionMapDelegate {
    func getCurrentStart_EndPlace(startPlace:String,endPlace:String)
}

class MissionMapView: UIView {

    

    var feedbackGenerator : UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .heavy)
    var locationPoint:CGPoint?
    var mapView:MKMapView!
    let regionRadius = 50.0
    
    
    var start_Location:CLLocation!
    var end_Location:CLLocation!
    
    var startAnnotation:ImageAnnotation!  = ImageAnnotation()
    var endAnnotation:ImageAnnotation!  = ImageAnnotation()
    
    var startMKCircle:MKCircle!
    var endMKCircle:MKCircle!
    
    var startPlace = ""
    var endPlace = ""
    
    var searchPlaceDispatchGroup = DispatchGroup()
    var locationManager = CLLocationManager()
    
    var userLocation:CLLocation = CLLocation() {
        didSet{
            
            //設置顯示區域
            let currentRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
           self.mapView.setRegion(currentRegion, animated: false)

            let  camera = MKMapCamera(lookingAtCenter:  userLocation.coordinate, fromDistance: 1000, pitch: 70, heading: userLocation.course == -1 ? 0 :userLocation.course)
            mapView.setCamera(camera, animated: false)
            locationManager.stopUpdatingLocation()
            
        }
    }
    
    var delegate:MissionMapDelegate?
    let gradientLayer: CAGradientLayer = {
         let layer = CAGradientLayer()
         layer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor,#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2035651408).cgColor,#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor]
         
         return layer
     }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        mapView = SpeedSingleton.share.publicMapView
            //MKMapView(frame: .zero)
        mapView.delegate = self  //委派給ViewController
        mapView.showsUserLocation = true   //顯示user位置
        mapView.userTrackingMode = .followWithHeading  //隨著user移動
        mapView.isRotateEnabled = true
//        mapView.layer.addSublayer(gradientLayer)
//        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.addSubview(mapView)
        
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
  
        
        locationManager.delegate = self  //委派給ViewController
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  //設定為最佳精度
        locationManager.activityType = .automotiveNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        feedbackGenerator?.prepare()
    }
    
    
    
    func setStart_EndAnnotation(AnnotationTag:Int,text:String = ""){
        
        if (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            
            self.locationManager.startUpdatingLocation()
            
            if(self.userLocation == nil){
                
                return
            }
            
            var annotationLocation:CLLocation!
            
            if(text != ""){
             
                self.searchPlaceDispatchGroup.enter()
                
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = text
                request.region = mapView.region
                
                let search = MKLocalSearch(request: request)
   
                search.start { (response, error) in
                    guard let response = response else {
                         print("Error: \(error?.localizedDescription ?? "Unknown error").")
                        SpeedSingleton.share.showAlert(viewConroller: self.findViewController()!, "找不到該地點")
                        self.searchPlaceDispatchGroup.leave()
                        return
                     }

                     for item in response.mapItems {
                        print("name = \(item.name),location = \(item.placemark.location)")
                        annotationLocation = item.placemark.location
                      
                        break
                     }
                    self.searchPlaceDispatchGroup.leave()
                    
                }
                
                
            }else{
                
                if(self.mapView.userLocation.location != nil){
                    self.userLocation = self.mapView.userLocation.location!
                    annotationLocation = self.userLocation
                    
                 
                }
               
             
            }
            
            self.searchPlaceDispatchGroup.notify(queue: .main) {
                
                if(annotationLocation == nil){
                    return
                }
                
                if(AnnotationTag == 1){
                    
                    self.startAnnotation.coordinate = annotationLocation.coordinate
                    self.startAnnotation.title = "起點"
//                    let flagImgView = UIImageView(image: UIImage(named: "red_flag"))
//                    flagImgView.backgroundColor = .white
                    self.startAnnotation.image = UIImage(named: "red_flag20201219")
                    
                    
                    let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  self.startAnnotation.coordinate.latitude, longitude:  self.startAnnotation.coordinate.longitude), radius: self.regionRadius, identifier: "START")
                    self.locationManager.startMonitoring(for: region)
                    
                    //新加大頭針
                    self.mapView.addAnnotation( self.startAnnotation)
                    
                    
                    // . 繪製一個圓圈圖形（用於表示 region 的範圍）
//                    if(self.startMKCircle != nil){
//                        self.mapView.removeOverlay(self.startMKCircle)
//                    }
//                    self.startMKCircle = MKCircle(center: annotationLocation.coordinate, radius: self.regionRadius)
//                    self.mapView.addOverlay(self.startMKCircle)
                    
                    
                    self.start_Location = CLLocation(latitude: self.startAnnotation.coordinate.latitude, longitude: self.startAnnotation.coordinate.longitude)
               
                    if(text == ""){
                        self.startPlace = "目前位置"
                    }else{
                        self.startPlace = text
                        
                        //設置顯示區域
                        let currentRegion = MKCoordinateRegion(center: self.start_Location.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
                       self.mapView.setRegion(currentRegion, animated: false)

                        let  camera = MKMapCamera(lookingAtCenter:  self.start_Location.coordinate, fromDistance: 1000, pitch: 70, heading: self.start_Location.course == -1 ? 0 :self.start_Location.course)
                        self.mapView.setCamera(camera, animated: false)
                    }
                    
                }else{
                    
                    self.endAnnotation.coordinate = annotationLocation.coordinate
                    self.endAnnotation.title = "終點"
                    self.endAnnotation.image = UIImage(named: "chequered_flag20201219")
                    
                    let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  self.endAnnotation.coordinate.latitude, longitude:  self.endAnnotation.coordinate.longitude), radius: self.regionRadius, identifier: "END")
                    self.locationManager.startMonitoring(for: region)
                    
                    //新加大頭針
                    self.mapView.addAnnotation( self.endAnnotation)
                    
                    
                    // . 繪製一個圓圈圖形（用於表示 region 的範圍）
//                    if(self.endMKCircle != nil){
//                        self.mapView.removeOverlay(self.endMKCircle)
//                    }
//                    self.endMKCircle = MKCircle(center: annotationLocation.coordinate, radius: self.regionRadius)
//                    self.mapView.addOverlay(self.endMKCircle)
                    
                    
                    self.end_Location = CLLocation(latitude: self.endAnnotation.coordinate.latitude, longitude: self.endAnnotation.coordinate.longitude)

                    if(text == ""){
                        self.endPlace = "目前位置"
                    }else{
                        self.endPlace = text
                        //設置顯示區域
                        let currentRegion = MKCoordinateRegion(center: self.end_Location.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
                       self.mapView.setRegion(currentRegion, animated: false)

                        let  camera = MKMapCamera(lookingAtCenter:  self.end_Location.coordinate, fromDistance: 1000, pitch: 70, heading: self.end_Location.course == -1 ? 0 :self.end_Location.course)
                        self.mapView.setCamera(camera, animated: false)
                    }
                }
                
                self.locationManager.stopUpdatingLocation()
                
            }

            
        }else{
    
            SpeedSingleton.share.showAlert(viewConroller: self.findViewController()!, "請打開權限")
                 
        }
        
    }
    
  @objc  func handleDrag(gesture: UILongPressGestureRecognizer) {
        
        
        let location = gesture.location(in: mapView)

        if gesture.state == .began {
            locationPoint = location
            feedbackGenerator?.impactOccurred()
            
        } else if gesture.state == .changed {
            gesture.view?.transform = CGAffineTransform(translationX: location.x - locationPoint!.x, y: location.y - locationPoint!.y)
    
        } else if gesture.state == .ended || gesture.state == .cancelled {
            let annotationView = gesture.view as! MKAnnotationView
            let annotation = annotationView.annotation as! ImageAnnotation

            let translate = CGPoint(x: location.x - locationPoint!.x, y: location.y - locationPoint!.y)
           // let originalLocation = mapView.convertCoordinate(annotation, toPointToView: mapView)
            let originalLocation = mapView.convert(annotation.coordinate, toPointTo: mapView)
            let updatedLocation = CGPoint(x: originalLocation.x + translate.x, y: originalLocation.y + translate.y)

            annotationView.transform = .identity
                //CGAffineTransformIdentity
            annotation.coordinate = mapView.convert(updatedLocation, toCoordinateFrom: mapView)
            
            let annotionView = gesture.view as! ImageAnnotationView
            if(annotionView.annotation?.title == "起點"){
                
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  self.startAnnotation.coordinate.latitude,longitude:  self.startAnnotation.coordinate.longitude), radius: regionRadius, identifier: "START")
                locationManager.startMonitoring(for: region)
                
//                self.mapView.removeOverlay(self.startMKCircle)
//                self.startMKCircle = MKCircle(center: self.startAnnotation.coordinate, radius: regionRadius)
//                self.mapView.addOverlay(self.startMKCircle)
                
                self.start_Location = CLLocation(latitude: self.startAnnotation.coordinate.latitude, longitude: self.startAnnotation.coordinate.longitude)
                
                if(self.start_Location != self.userLocation){
                    startPlace = "自訂位置"
                }
                
                print("起點 view.annotation = \(annotionView.annotation?.coordinate)")
                
            }else{
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  self.endAnnotation.coordinate.latitude, longitude:  self.endAnnotation.coordinate.longitude), radius: regionRadius, identifier: "END")
                locationManager.startMonitoring(for: region)
                
//                self.mapView.removeOverlay(self.endMKCircle)
//                self.endMKCircle = MKCircle(center: self.endAnnotation.coordinate, radius: regionRadius)
//                self.mapView.addOverlay( self.endMKCircle)
                
                self.end_Location = CLLocation(latitude: self.endAnnotation.coordinate.latitude, longitude: self.endAnnotation.coordinate.longitude)
                
                if(self.end_Location != self.userLocation){
                    endPlace = "自訂位置"
                }
            }
            
            delegate?.getCurrentStart_EndPlace(startPlace: startPlace, endPlace: endPlace)
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension MissionMapView:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0] //最新的位置在[0]
       self.userLocation = userLocation
        
        
        
    }
    
}

extension MissionMapView :MKMapViewDelegate{

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
    }


    
    func mapView(_ map: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
            
        }

        
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
          let imagHeight = annotation.image?.size.width
           view?.centerOffset = CGPoint(x: 0,y:  -imagHeight! / 3)
           print("view?.centerOffset = \(view?.centerOffset)")
       
         // view?.isDraggable = true
          view?.annotation = annotation
          let drag = UILongPressGestureRecognizer(target: self, action: #selector(handleDrag(gesture:)))
             drag.minimumPressDuration = 0 // set this to whatever you want
            drag.allowableMovement = .greatestFiniteMagnitude
             view?.addGestureRecognizer(drag)
        
        return view
        
//        return nil
    }
    
    
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//
//
//        print("map rigon = \(mapView.region)")
//        let annotions = mapView.annotations
//        print("annotions = \(annotions)")
//
//        for (index,annotion) in annotions.enumerated(){
//            print("annotion = \(annotion)")
//            if let annotation = annotion as? ImageAnnotation {
//                let annotationView  = self.mapView.annotationView(of: ImageAnnotationView.self, annotation: annotation, reuseIdentifier: "imageAnnotation")
//                let imagHeight = annotation.image?.size.height
//                annotationView.centerOffset = CGPoint(x: 0,y:  -imagHeight! / 2)
//                print("annotationView.centerOffset = \(annotationView.centerOffset)")
//            }
//        }
//
//    }
    
//    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//       print("view = \(view)")
//    }
//
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
//                 didChange newState: MKAnnotationView.DragState,
//                 fromOldState oldState: MKAnnotationView.DragState) {
//
//        if(view.annotation?.title == "起點"){
//
//            // setup region
//            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  self.startAnnotation.coordinate.latitude,longitude:  self.startAnnotation.coordinate.longitude), radius: regionRadius, identifier: "START")
//            locationManager.startMonitoring(for: region)
//
//            self.mapView.removeOverlay(self.startMKCircle)
//            self.startMKCircle = MKCircle(center: self.startAnnotation.coordinate, radius: regionRadius)
//            self.mapView.addOverlay(self.startMKCircle)
//
//            self.start_Location = CLLocation(latitude: self.startAnnotation.coordinate.latitude, longitude: self.startAnnotation.coordinate.longitude)
//
//            if(self.start_Location != self.userLocation){
//                startPlace = "自訂位置"
//            }
//
//            print("起點 view.annotation = \(view.annotation?.coordinate)")
//        }else{
//
//            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  self.endAnnotation.coordinate.latitude, longitude:  self.endAnnotation.coordinate.longitude), radius: regionRadius, identifier: "END")
//            locationManager.startMonitoring(for: region)
//
//            self.mapView.removeOverlay(self.endMKCircle)
//            self.endMKCircle = MKCircle(center: self.endAnnotation.coordinate, radius: regionRadius)
//            self.mapView.addOverlay( self.endMKCircle)
//
//            self.end_Location = CLLocation(latitude: self.endAnnotation.coordinate.latitude, longitude: self.endAnnotation.coordinate.longitude)
//
//            if(self.end_Location != self.userLocation){
//                endPlace = "自訂位置"
//
//            }
//            print("終點 view.annotation = \(view.annotation?.coordinate)")
//        }
//
//        delegate?.getCurrentStart_EndPlace(startPlace: startPlace, endPlace: endPlace)
//
//    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let overlay = overlay as? MKPolyline{
            
  
            let gradientColors = [UIColor.green, UIColor.yellow, UIColor.red]
            
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

}
