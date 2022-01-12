//
//  SPHelp.swift
//  SpeedRecord
//
//  Created by Alghero_Mac_02 on 2020/10/16.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import SnapKit
import MapKit


extension Double {     //無條件捨去小數第Ｘ位
    
    func ceiling(toInteger integer: Int = 1) -> Double {
        let integer = integer - 1
        let numberOfDigits = pow(10.0, Double(integer))
        return Double(Darwin.ceil(self / numberOfDigits)) * numberOfDigits
    }
    
    func ceiling(toDecimal decimal: Int) -> Double {
        let numberOfDigits = Swift.abs(pow(10.0, Double(decimal)))
          if self.sign == .minus {
              return Double(Int(self * numberOfDigits)) / numberOfDigits
          } else {
            return Double(Darwin.ceil(self * numberOfDigits)) / numberOfDigits
          }
      }

    func floor(toDecimal decimal: Int) -> Double {
           let numberOfDigits = pow(10.0, Double(decimal))
           return (self * numberOfDigits).rounded(.towardZero) / numberOfDigits
       }
}

extension UIViewController {
    
//    func showToast(message : String) {
//
//        let toastLabel = UILabel(frame: .zero)
//        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//        toastLabel.textColor = UIColor.white
//        toastLabel.font = UIFont(name: "PingFangTC-Medium", size: 15)
//        toastLabel.textAlignment = .center;
//        toastLabel.text = message
//        toastLabel.alpha = 1.0
//       // toastLabel.layer.cornerRadius = 10;
//        toastLabel.clipsToBounds  =  true
//        self.view.addSubview(toastLabel)
//
//        toastLabel.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview()
//            make.width.equalTo(250)
//            make.height.equalTo(50)
//
//        }
//
//        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
//            toastLabel.alpha = 0.0
//        }, completion: {(isCompleted) in
//            toastLabel.removeFromSuperview()
//        })
//    }
    
    func showToast(message : String, completed:(()->Void)? = nil) {
        
        let toastLabel = UILabel(frame: .zero)
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: "PingFangTC-Medium", size: 15)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        // toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        
        toastLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(50)
            make.width.equalTo(250)
            make.height.equalTo(50)
            
        }
        
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
            
            if(completed != nil){
                completed!()
            }
          
        })
        
       
    }
    

    
    
}

extension UITextField{
    
//    func rightViewRectForBounds(bounds:CGRect) -> CGRect{
//
//        var textRect = self.rightViewRect(forBounds: bounds)
//        textRect.origin.x -= 10
//        return textRect
//    }

  
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}


extension UIImage{
    
    func imageWith(newSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let image = renderer.image { _ in
            self.draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
        }

        return image.withRenderingMode(self.renderingMode)
    }
    
}

extension MKMapView {
    func annotationView<T: MKAnnotationView>(of type: T.Type, annotation: MKAnnotation?, reuseIdentifier: String) -> T {
        guard let annotationView = dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? T else {
            return type.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        annotationView.annotation = annotation
        return annotationView
    }
}

