//
//  SpeedSingleton.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/10/11.
//  Copyright © 2020 Alpha. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import SnapKit
import GoogleMobileAds
import AdColony
import AdColonyAdapter
import FacebookAdapter


class SpeedSingleton: NSObject, GADInterstitialDelegate {
    

    static let share = SpeedSingleton()
    let bottomHeight = (UIApplication.shared.windows.first?.safeAreaInsets.bottom)! + 49
    
    var publicMapView:MKMapView? = MKMapView(frame: .zero)
    let filePath: String="/Documents"
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    
    var interstitial: GADInterstitial!
  static  var adTimeDefault = 2
    var adTimeLeft = adTimeDefault
    var adTimer: Timer?
    var vc:UIViewController?
    
    
    
    
    func showAlert(viewConroller:UIViewController,_ message:String){
        
         let controller = UIAlertController(title: "Racing 通知", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        controller.addAction(okAction)
        viewConroller.present(controller, animated: true, completion: nil)
        
    }
    
    func showAlert(viewConroller:UIViewController,_ message:String, completed:((_ isCancel:Bool)->Void)? = nil){
        
         let controller = UIAlertController(title: "Racing 通知", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { (alert) in
            completed?(true)
        }
       
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (alert) in
            completed?(false)
        }
        
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        viewConroller.present(controller, animated: true, completion: nil)
        
    }
    
    
    //計算距離
    func calculateDistance(startLocation:CLLocation ,endLocation:CLLocation) -> Double{
        
        if(startLocation != nil && endLocation != nil ){
            let distanceMeters = startLocation.distance(from:endLocation) / 1000
          //  print(String(format: "distanceMeters is %.01fkm", distanceMeters))
         
            return  distanceMeters
        }
   
        return 0.0
    }
    //

   private   func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let imagePath = paths[0].appendingPathComponent("images")
        print("imagePath = \(imagePath)")
        if !FileManager.default.fileExists(atPath: imagePath.path) {
            do {
                try FileManager.default.createDirectory(atPath: imagePath.path, withIntermediateDirectories: true, attributes: nil)
           
         
            } catch {
                print(error.localizedDescription);
            }
        }else{
        
        }
        return imagePath
    }
    
    func saveImage(image:UIImage,imageName:String){

      //  let imageDir = NSHomeDirectory()+filePath+"/recordImages"
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        print("save imagePath = \(imagePath)")
        if let data = image.pngData() {
            try? data.write(to: imagePath)
          }

    }
    
    func loadImage(imgName:String) -> UIImage?{
        return UIImage(contentsOfFile: getDocumentsDirectory().appendingPathComponent("\(imgName).png").path) ?? nil
        
    }
    
    
    func takeSnapShot(coordinates:[CLLocationCoordinate2D],complete:@escaping(_ mapView:UIImage)->Void) {
        let mapSnapshotOptions = MKMapSnapshotter.Options()

        // Set the region of the map that is rendered. (by polyline)
        let paths = MKPolyline(coordinates: coordinates, count: coordinates.count)
        var regionRect = paths.boundingMapRect
        let wPadding = regionRect.size.width * 2.0
        let hPadding = regionRect.size.height * 2.0
        //Add padding to the region
        regionRect.size.width += wPadding
        regionRect.size.height += hPadding
        //Center the region on the line
        regionRect.origin.x -= wPadding / 2
        regionRect.origin.y -= hPadding / 2
        let region = MKCoordinateRegion(regionRect)
        
        mapSnapshotOptions.region = region

        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale

        // Set the size of the image output.
        mapSnapshotOptions.size = CGSize(width: 200, height: 200)

        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true

        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        var imageView:UIImage?
        snapShotter.start() { snapshot, error in
            guard let snapshot = snapshot else {
                return
            }
            // Don't just pass snapshot.image, pass snapshot itself!
            imageView = self.drawLineOnImage(snapshot: snapshot, coordinates: coordinates)
            print("imageView = \(imageView)")
            complete(imageView!)
        }
  
        
    }
    

    func drawLineOnImage(snapshot: MKMapSnapshotter.Snapshot,coordinates:[CLLocationCoordinate2D]) -> UIImage {
        let image = snapshot.image

        // for Retina screen
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 200, height: 200), true, 0)

        // draw original image into the context
        image.draw(at: CGPoint.zero)

        // get the context for CoreGraphics
        let context = UIGraphicsGetCurrentContext()

        // set stroking width and color of the context
        context!.setLineWidth(2.0)
        context!.setStrokeColor(UIColor.orange.cgColor)

        // Here is the trick :
        // We use addLine() and move() to draw the line, this should be easy to understand.
        // The diificult part is that they both take CGPoint as parameters, and it would be way too complex for us to calculate by ourselves
        // Thus we use snapshot.point() to save the pain.
        context!.move(to: snapshot.point(for: coordinates[0]))
        for i in 0...coordinates.count-1 {
          context!.addLine(to: snapshot.point(for: coordinates[i]))
          context!.move(to: snapshot.point(for: coordinates[i]))
        }

        // apply the stroke to the context
        context!.strokePath()

        // get the image from the graphics context
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()

        // end the graphics context
        UIGraphicsEndImageContext()

        return resultImage!
    }
    


    

    func loadInterstitialADs(vc:UIViewController){
        self.vc = vc
        
        #if DEBUG
        print("loadInterstitialADs debug")
   
        interstitial = GADInterstitial(adUnitID:"ca-app-pub-3940256099942544/4411468910")
        
        let request = GADRequest()
//        request.testDevices = [kGADSimulatorID as! String, "1EF245DE-B0C1-499E-ABFA-FA7F9B2E6ED5"]
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["1EF245DE-B0C1-499E-ABFA-FA7F9B2E6ED5"]
        interstitial.delegate = self
        let extras = GADMAdapterAdColonyExtras()
        extras.showPrePopup = true
        extras.showPostPopup = true
        request.register(extras)
        
        let fbExtras = GADFBNetworkExtras()
        fbExtras.nativeAdFormat = GADFBAdFormat.nativeBanner
        request.register(fbExtras)
        interstitial.load(request)
        
        startAds()
        
        #else
        print("loadInterstitialADs release")
        //ca-app-pub-6780602618431578/9263180143
        interstitial = GADInterstitial(adUnitID:"ca-app-pub-6780602618431578/9263180143")
        
        let request = GADRequest()
//        request.testDevices = [kGADSimulatorID as! String, "1EF245DE-B0C1-499E-ABFA-FA7F9B2E6ED5"]
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["1EF245DE-B0C1-499E-ABFA-FA7F9B2E6ED5"]
        interstitial.delegate = self
        let extras = GADMAdapterAdColonyExtras()
        extras.showPrePopup = true
        extras.showPostPopup = true
        request.register(extras)
        
        let fbExtras = GADFBNetworkExtras()
        fbExtras.nativeAdFormat = GADFBAdFormat.nativeBanner
        request.register(fbExtras)
        
        interstitial.load(request)
        
        startAds()
        
        #endif
        

    }
    
    
    
    func startAds(){
    
        adTimeLeft = Self.adTimeDefault
        adTimer = Timer.scheduledTimer(
          timeInterval: 1.0,
          target: self,
          selector: #selector(self.decrementTimeLeft(_:)),
          userInfo: nil,
          repeats: true)
        
    }
    

    @objc func decrementTimeLeft(_ timer: Timer) {
      adTimeLeft -= 1
      if adTimeLeft == 0 {
        endGame()
      }
    }
    
    fileprivate func endGame() {
        adTimer?.invalidate()
        adTimer = nil
   
        if self.interstitial.isReady {
            
//            let viewController = UIApplication.shared.windows.first!.rootViewController
            
            self.interstitial.present(fromRootViewController: self.vc!)
        
            
      
        } else {
            print("Ad wasn't ready")
        }
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      print("interstitialDidReceiveAd")
        print("Interstitial adapter class name: \(ad.responseInfo?.adNetworkClassName)")
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
      print("interstitialWillDismissScreen")
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      print("interstitialDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      print("interstitialWillLeaveApplication")
    }
    
}

