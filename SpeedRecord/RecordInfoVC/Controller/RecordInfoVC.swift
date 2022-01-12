//
//  RecordInfoVC.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/10/25.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import SnapKit
import MapKit

class RecordInfoVC: UIViewController {
    
    
    lazy var coordintor:RecordCoordinatorProtocol = {

         let a = SingleMissionCoordinator()
         a.vc = self
         return a

     }()
    
    lazy var viewModel = RecordInfoViewModel(timeStamp: self.timeStampKey, coordinator: coordintor)

    
    var timeStampKey = 0
    var recordInfoMapView:RecordInfoMapView!
    var chartView:ChartView!
    
    var totalTime = ""
    var totalDistane = ""
    var totalTimeSpeedLabel:UILabel!
    var distanceLabel:UILabel!
    var hightSpeedLabel:UILabel!
    var lowSpeedLabel:UILabel!
    var avgSpeedLabel:UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setUI()
       
        loadData()

        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
  
    }

    func setUI(){
        
        recordInfoMapView = RecordInfoMapView()
        recordInfoMapView.viewModel = viewModel
        self.view.addSubview(recordInfoMapView)
        recordInfoMapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        chartView = ChartView(frame: .zero)
        chartView.delegate  = self
        chartView.viewModel = viewModel

        chartView.backgroundColor = .white
        self.recordInfoMapView.addSubview(chartView)
        chartView.snp.makeConstraints { (make) in
            make.height.equalTo(self.view.frame.height / 2)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        
        let cancelBtn = UIButton(frame: .zero)
        cancelBtn.layer.cornerRadius = 15.0
        cancelBtn.setTitle("X", for: .normal)
        cancelBtn.backgroundColor = .black
        cancelBtn.tintColor = .white
        cancelBtn.addTarget(self, action:#selector(cancelEvent), for: .touchUpInside)
        
        recordInfoMapView.addSubview(cancelBtn)
        
        cancelBtn.snp.makeConstraints { (make) in
            make.height.width.equalTo(30)
            make.right.equalToSuperview().offset(-30)
            make.top.equalToSuperview().offset(50)
        }

        
        let infoView = UIView()
        infoView.backgroundColor = .clear
        recordInfoMapView.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(80)
            make.width.equalTo(200)
            make.height.equalTo(130)
        }
        
         totalTimeSpeedLabel = UILabel()
        totalTimeSpeedLabel.text = "時間："
        totalTimeSpeedLabel.font = UIFont(name: "PingFangTC-Medium", size: 18)
        infoView.addSubview(totalTimeSpeedLabel)
        totalTimeSpeedLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(18)
        }
         distanceLabel = UILabel()
        distanceLabel.text = "距離"
        distanceLabel.font = UIFont(name: "PingFangTC-Medium", size: 18)
        infoView.addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(totalTimeSpeedLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(18)
        }
        hightSpeedLabel = UILabel()
        hightSpeedLabel.text = "最高速度"
        hightSpeedLabel.font = UIFont(name: "PingFangTC-Medium", size: 18)
        infoView.addSubview(hightSpeedLabel)
        hightSpeedLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(distanceLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(18)
        }
         lowSpeedLabel = UILabel()
        lowSpeedLabel.text = "最低速度"
        lowSpeedLabel.font = UIFont(name: "PingFangTC-Medium", size: 18)
        infoView.addSubview(lowSpeedLabel)
        lowSpeedLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(hightSpeedLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(18)
        }
         avgSpeedLabel = UILabel()
        avgSpeedLabel.text = "平均速度"
        avgSpeedLabel.font = UIFont(name: "PingFangTC-Medium", size: 18)
        infoView.addSubview(avgSpeedLabel)
        avgSpeedLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(lowSpeedLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(18)
        }
        
    }
    
    
    func loadData(){
        
        self.viewModel.getSpeedData {
            
            
            let paths = MKPolyline(coordinates:self.viewModel.paths, count: self.viewModel.paths.count)
//            paths.title = "my_path"
//            self.mapView.mapView.addOverlay(paths, level: MKOverlayLevel.aboveRoads)
            
      //      let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: self.viewModel!.pathLocations)
            let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: self.viewModel.pathLocations,forSpeeds: self.viewModel.chartYValuesArray)
            self.recordInfoMapView.mapView.addOverlays(colorSegments)

            
            print("paths.boundingMapRect = \(paths.boundingMapRect)")
            // let rect = MKCoordinateRegion.init(paths.boundingMapRect)
            var regionRect = paths.boundingMapRect
            let wPadding = regionRect.size.width * 2.0
            let hPadding = regionRect.size.height * 2.0
            
            //Add padding to the region
            regionRect.size.width += wPadding
            regionRect.size.height += hPadding
            
            //Center the region on the line
            regionRect.origin.x -= wPadding / 2
            regionRect.origin.y -= hPadding / 2
            
            self.recordInfoMapView.mapView.setRegion(MKCoordinateRegion(regionRect), animated: true)


            if(!self.viewModel.paths.isEmpty){
                
                self.recordInfoMapView.startAnnotation.coordinate = self.viewModel.paths.first!
                self.recordInfoMapView.startAnnotation.title = "起點"
                self.recordInfoMapView.startAnnotation.image = UIImage(named: "red_flag20201219")
             
                //新加大頭針
                self.recordInfoMapView.mapView.addAnnotation(self.recordInfoMapView.startAnnotation)

                self.recordInfoMapView.endAnnotation.coordinate = self.viewModel.paths.last!
                self.recordInfoMapView.endAnnotation.title = "終點"
                self.recordInfoMapView.endAnnotation.image = UIImage(named: "chequered_flag20201219")
                //新加大頭針
                self.recordInfoMapView.mapView.addAnnotation(self.recordInfoMapView.endAnnotation)
                self.chartView.setChartData()
                
                let titleAttr = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.black]
                var titleValue = NSMutableAttributedString(string:"時間：", attributes:titleAttr)
                
                let infoValue = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.red]
                var attributedValue = NSMutableAttributedString(string:"\(self.totalTime)", attributes:infoValue)
                titleValue.append(attributedValue)
                self.totalTimeSpeedLabel.attributedText = titleValue
                
                 titleValue = NSMutableAttributedString(string:"距離：", attributes:titleAttr)
                 attributedValue = NSMutableAttributedString(string:"\(self.totalDistane)", attributes:infoValue)
                titleValue.append(attributedValue)
                self.distanceLabel.attributedText = titleValue
                
                
                let newSpeedDatas = self.viewModel.speedDatas.sorted(by: { (speedModelA, speedModelB) -> Bool in
                    return speedModelA.speed > speedModelB.speed
                })
                let hightSpeed = newSpeedDatas.first?.speed ?? 0
                let lawSpeed = newSpeedDatas.last?.speed ?? 0
                titleValue = NSMutableAttributedString(string:"最高時速：", attributes:titleAttr)
                attributedValue = NSMutableAttributedString(string:"\(Int(hightSpeed))", attributes:infoValue)
               titleValue.append(attributedValue)
               self.hightSpeedLabel.attributedText = titleValue
            
                
                titleValue = NSMutableAttributedString(string:"最低時速：", attributes:titleAttr)
                attributedValue = NSMutableAttributedString(string:"\(Int(lawSpeed))", attributes:infoValue)
               titleValue.append(attributedValue)
                self.lowSpeedLabel.attributedText = titleValue
                
                
                var speeds = 0
                self.viewModel.speedDatas.forEach({ (speedModel) in
                   speeds  +=  Int(speedModel.speed)
                })
                
                let totalSpeed =  speeds/Int(self.viewModel.speedDatas.count ?? 0)
                titleValue = NSMutableAttributedString(string:"平均時速：", attributes:titleAttr)
                attributedValue = NSMutableAttributedString(string:"\(totalSpeed)", attributes:infoValue)
               titleValue.append(attributedValue)
                self.avgSpeedLabel.attributedText = titleValue
                
            }
            
            
          
            
        }
        
    }


    @objc func cancelEvent(){
        
        self.viewModel.dismiss()
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.viewModel.paths.removeAll()
        self.viewModel.chartXStrValueArray.removeAll()
        self.viewModel.chartXValueArray.removeAll()
        self.viewModel.chartYValuesArray.removeAll()
        self.viewModel.speedDatas.removeAll()
        self.recordInfoMapView?.mapView.removeOverlays((self.recordInfoMapView?.mapView.overlays)!)
        self.recordInfoMapView?.mapView.removeAnnotation(self.recordInfoMapView.startAnnotation)
        self.recordInfoMapView?.mapView.removeAnnotation(self.recordInfoMapView.endAnnotation)
       // self.mapView.mapView = nil
        self.recordInfoMapView?.mapView.delegate = nil
        self.chartView.delegate = nil
        self.chartView.viewModel = nil
        
        self.chartView.chart = nil

        recordInfoMapView?.removeSubviews()
        recordInfoMapView?.removeFromSuperview()
        self.recordInfoMapView.mapView = nil
        self.chartView.removeSubviews()
        self.chartView.removeFromSuperview()
        self.chartView = nil
        self.recordInfoMapView = nil
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
  
        
    }
    
    
}

extension RecordInfoVC:ChartViewDelegate{
    
    func updateLocation(location: CLLocationCoordinate2D) {
        
        self.recordInfoMapView.startAnnotation.coordinate = location
//        let view = self.recordInfoMapView.mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation", for:  self.recordInfoMapView.startAnnotation)
//
//        view.annotation = self.recordInfoMapView.startAnnotation
        
//        let view = self.mapView.mapView.view(for: self.mapView.startAnnotation) as? ImageAnnotationView
//
//        view?.annotation = self.mapView.startAnnotation
        
//        self.mapView.mapView.annotations
//            .compactMap { $0 as? ImageAnnotation }
//            .forEach { existingMarker in
//                existingMarker.coordinate = location
//        }
        
//        view?.image = annotation.image

//        view?.annotation?.coordinate = location
//        view?

        
    }
    
    
    
}
