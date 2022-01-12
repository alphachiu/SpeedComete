//
//  MulticolorPolylineSegment.swift
//  SpeedRecord
//
//  Created by Alghero_Mac_02 on 2020/11/13.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MulticolorPolylineSegment: MKPolyline {
  var color: UIColor?
    
    
    private class func allSpeeds(forLocations locations: [CLLocation]) -> (speeds: [Double], minSpeed: Double, maxSpeed: Double) {
        // Make Array of all speeds. Find slowest and fastest
        var speeds = [Double]()
        var minSpeed = DBL_MAX
        var maxSpeed = 0.0

        for i in 1..<locations.count {
            let l1 = locations[i-1]
            let l2 = locations[i]
            
            let cl1 = CLLocation(latitude: l1.coordinate.latitude, longitude: l1.coordinate.longitude)
            let cl2 = CLLocation(latitude: l2.coordinate.latitude, longitude: l2.coordinate.longitude)
            
            let distance = cl2.distance(from: cl1)
            let time = l2.timestamp.timeIntervalSince(l1.timestamp)
            print("i = \(i)")
            print("distance = \(distance)")
            print("time = \(time))")
            let speed = distance/time
            print("speed = \(speed)")
            let speedStr = "\(String(format: "%.1f",speed))"
            let speedDouble = Double(speedStr)!/100000
            print("speedDouble = \(speedDouble)")
            print("---------------------------")
            minSpeed = min(minSpeed, speedDouble)
            maxSpeed = max(maxSpeed, speedDouble)
            
            speeds.append(speed)
        }

        return (speeds, minSpeed, maxSpeed)
      }

    class func colorSegments(forLocations locations: [CLLocation]) -> [MulticolorPolylineSegment] {
        var colorSegments = [MulticolorPolylineSegment]()

        // RGB for Red (slowest)
        let red   = (r: 1.0, g: 20.0 / 255.0, b: 44.0 / 255.0)

        // RGB for Yellow (middle)
        let yellow = (r: 1.0, g: 215.0 / 255.0, b: 0.0)

        // RGB for Green (fastest)
        let green  = (r: 0.0, g: 146.0 / 255.0, b: 78.0 / 255.0)

        let (speeds, minSpeed, maxSpeed) = allSpeeds(forLocations: locations)

        // now knowing the slowest+fastest, we can get mean too
        let midSpeed = (minSpeed + maxSpeed)/2

        print("minSpeed  = \(minSpeed)")
        print("maxSpeed  = \(maxSpeed)")
        print("midSpeed  = \(midSpeed)")
        
        for i in 1..<locations.count {
              let l1 = locations[i-1]
              let l2 = locations[i]

              var coords = [CLLocationCoordinate2D]()

            coords.append(CLLocationCoordinate2D(latitude: l1.coordinate.latitude, longitude: l1.coordinate.longitude))
              coords.append(CLLocationCoordinate2D(latitude: l2.coordinate.latitude, longitude: l2.coordinate.longitude))

              var speed = speeds[i-1]
              let speedStr = "\(String(format: "%.1f",speed))"
             print("speed = \(speed), speedStr = \(speedStr)")
             speed = Double(speedStr)!/100000
              var color = UIColor.black

            print("Double speed = \(speed)")
            if speed < 14.0 { // Between Red & Yellow
//                let ratio = (speed - minSpeed) / (midSpeed - minSpeed)
//                let r = CGFloat(red.r + ratio * (yellow.r - red.r))
//                let g = CGFloat(red.g + ratio * (yellow.g - red.g))
//                let b = CGFloat(red.r + ratio * (yellow.r - red.r))
//                color = UIColor(red: r, green: g, blue: b, alpha: 1)
                color = .red
              }else if(speed > 14.0 && speed < 27.8) { // Between Yellow & Green
//                let ratio = (speed - midSpeed) / (maxSpeed - midSpeed)
//                let r = CGFloat(yellow.r + ratio * (green.r - yellow.r))
//                let g = CGFloat(yellow.g + ratio * (green.g - yellow.g))
//                let b = CGFloat(yellow.b + ratio * (green.b - yellow.b))
//                color = UIColor(red: r, green: g, blue: b, alpha: 1)
                color = .green
              }else if(speed > 27.8){
                color = .blue
                print("blue = \(speed)")
              }

              let segment = MulticolorPolylineSegment(coordinates: &coords, count: coords.count)
              segment.color = color
              colorSegments.append(segment)
            }
        
        
        return colorSegments
      }
    
    
    class func colorSegments(forLocations locations: [CLLocation],forSpeeds speeds:[Double]) -> [MulticolorPolylineSegment] {
        var colorSegments = [MulticolorPolylineSegment]()

        // RGB for Red (slowest)
        let red   = (r: 1.0, g: 20.0 / 255.0, b: 44.0 / 255.0)

        // RGB for Yellow (middle)
        let yellow = (r: 1.0, g: 215.0 / 255.0, b: 0.0)

        // RGB for Green (fastest)
        let green  = (r: 0.0, g: 146.0 / 255.0, b: 78.0 / 255.0)
        
        for i in 1..<locations.count {
              let l1 = locations[i-1]
              let l2 = locations[i]

              var coords = [CLLocationCoordinate2D]()

              coords.append(CLLocationCoordinate2D(latitude: l1.coordinate.latitude, longitude: l1.coordinate.longitude))
              coords.append(CLLocationCoordinate2D(latitude: l2.coordinate.latitude, longitude: l2.coordinate.longitude))

              var speed = speeds[i-1]
//              let speedStr = "\(String(format: "%.1f",speed))"
//             print("speed = \(speed), speedStr = \(speedStr)")
//             speed = Double(speedStr)!/100000
              var color = UIColor.black

            print("Double speed = \(speed)")
            if speed < 50.0 { // Between Red & Yellow
                let ratio = (speed - 20) / (50 - 20)
                let r = CGFloat(red.r + ratio * (yellow.r - red.r))
                let g = CGFloat(red.g + ratio * (yellow.g - red.g))
                let b = CGFloat(red.r + ratio * (yellow.r - red.r))
                color = UIColor(red: r, green: g, blue: b, alpha: 1)
               // color = .red
              }else if(speed > 50.0 && speed < 100.0) { // Between Yellow & Green
                let ratio = (speed - 50) / (100 - 50)
                let r = CGFloat(yellow.r + ratio * (green.r - yellow.r))
                let g = CGFloat(yellow.g + ratio * (green.g - yellow.g))
                let b = CGFloat(yellow.b + ratio * (green.b - yellow.b))
                color = UIColor(red: r, green: g, blue: b, alpha: 1)
              //  color = .green
              }else if(speed > 100.0){
                color = .blue
                print("blue = \(speed)")
              }

              let segment = MulticolorPolylineSegment(coordinates: &coords, count: coords.count)
              segment.color = color
              colorSegments.append(segment)
            }
        
        
        return colorSegments
      }
    
 }
