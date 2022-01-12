//
//  RecordMapView.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/10/25.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RecordInfoMapView: UIView, MKMapViewDelegate {
    
    var mapView:MKMapView!

    var viewModel:RecordInfoViewModel!
    var startAnnotation = ImageAnnotation()
    var endAnnotation = ImageAnnotation()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        

        mapView = MKMapView(frame: .zero)
      
        mapView.delegate = self  //委派給ViewController
        mapView.showsUserLocation = true   //顯示user位置
        mapView.userTrackingMode = .followWithHeading  //隨著user移動
        mapView.isRotateEnabled = true
        
        self.addSubview(mapView)
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: "imageAnnotation")
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
     

        
    }
    
    
    func mapView(_ map: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
            
        }
        
//        if let _ = annotation as? MKPointAnnotation {
//
//            let identifier = "pinAnnotation"
//
//            if let view = map.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
//
//                view.pinTintColor =  .purple
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
//
//        return nil
        
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
        
        view?.isDraggable = false

          let annotation = annotation as! ImageAnnotation
          view?.image = annotation.image
        
        if(annotation.title == "起點"){
            view?.imageView.frame.origin.y -= 25
            
        }
        
          view?.isDraggable = true
          view?.annotation = annotation
        
        return view
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let overlay = overlay as? MKPolyline{
            
            
//            let gradientColors = [UIColor.green, UIColor.yellow, UIColor.red]
//
//            /// Initialise a GradientPathRenderer with the colors
//            let polylineRenderer = GradientPathRender(polyline: overlay, colors:gradientColors)
//            /// set a linewidth
//            polylineRenderer.lineWidth = 7
//            return polylineRenderer
            
            
            let polyline = overlay as! MulticolorPolylineSegment
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = polyline.color
            renderer.lineWidth = 3
            return renderer
            
        }
        

        return MKOverlayRenderer()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
