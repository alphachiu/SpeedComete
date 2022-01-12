//
//  CustomAnnotationView.swift
//  SpeedRecord
//
//  Created by Alghero_Mac_02 on 2020/10/29.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ImageAnnotation: NSObject, MKAnnotation {
    @objc dynamic   var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage?
    var colour: UIColor?
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.subtitle = nil
        self.image = nil
        self.colour = UIColor.white
    }
}
class ImageAnnotationView: MKAnnotationView {
    var imageView: UIImageView!

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
       // self.backgroundColor = .black
 
        self.imageView = UIImageView(frame: CGRect(x: 0, y:  0 , width:50, height: 50))
        
        self.addSubview(self.imageView)

        self.imageView.layer.cornerRadius = 5.0
        self.imageView.layer.masksToBounds = true
    }

    override var image: UIImage? {
        get {
            return self.imageView.image
        }

        set {
            self.imageView.image = newValue
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
