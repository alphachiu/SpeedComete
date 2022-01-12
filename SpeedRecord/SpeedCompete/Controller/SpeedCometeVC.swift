//
//  SpeedCometeVC.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/10/7.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import MapKit
import SwifterSwift
import GoogleMobileAds
import AudioToolbox
import AdColony
import AdColonyAdapter
import FacebookAdapter


protocol SpeedCometeDelegate {
    
    func getMapInfo() -> (modeStyle:Int,startAnnotation:ImageAnnotation,endAnnotation:ImageAnnotation,start_Location:CLLocation,end_Location:CLLocation)
    
    
}

class SpeedCometeVC: UIViewController, GADBannerViewDelegate {

    


    var viewModel:SpeedCompeteViewModel =  SpeedCompeteViewModel()
//    var isStart = false
    var bottomSheetView: BottomSheetView?
    var mapView:MapView?
    var speedView = UIView() //速度view
    var currentSpeedLabel = UILabel()
    var delegate:SpeedCometeDelegate?
    var topView  = UIView()
    var timer:Timer?

//    var second:Int = 0{
//        didSet{
//
//        }
//    } //計時 +1

    
    var minSpeed = 20.0 //最低時速
    
//    var timeStr = ""
    let aDegree = CGFloat.pi / 180
    let lineWidth: CGFloat = 5
    let radius: CGFloat = 50
    let startDegree: CGFloat = 270
    var percentFloat: CGFloat = 0
//    var label:UILabel!
    var percentagePath:UIBezierPath?
    var percentageLayer:CAShapeLayer!
    var circleLayer: CAShapeLayer!
    
    var isAdd = false
    var timeLabel:UILabel!
    var avgSpeedLabel:UILabel!
    var topSpeedLabel:UILabel!
    var distanceKM:UILabel!
//    var modelTag = 0
    var gradientLayer = CAGradientLayer()
    
    var bannerView: GADBannerView!
    
    
    let starPointLable = UILabel()
    let endPointLable = UILabel()
//    var starInsideLable = UILabel()
//    var starOutsidLable = UILabel()
//    var endInsideLable = UILabel()
//    var endOutsideLable = UILabel()
    

    
    let soundID = SystemSoundID(kSystemSoundID_Vibrate) //震動
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.overrideUserInterfaceStyle = .light
        

        setMapView()
        setMissionTipView()
        setBottomView()
        setBind()
        
        //廣告
        setBannerAdsView()

        
        self.mapView?.isCompeteFinish = false
        
        if(self.mapView?.modeStyle == 0){
            self.mapView?.isDrawPath = true
        }else{
            self.mapView?.isDrawPath = false
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    

    func setBind(){
        
        viewModel.starPlace.bind(listener: { [unowned self] data in
            
        })
        
        viewModel.endPlace.bind(listener: { [unowned self] data in
            
        })
        
        
        viewModel.totalKM.bind { [unowned self] data in
            
            self.distanceKM.text = data
        }
        
        viewModel.second.bind(listener: { [unowned self] data in
            
            let hours = Int(data) / 3600
            let minutes = Int(data) / 60 % 60
            let seconds = Int(data) % 60
            self.timeLabel.text = "\(String(format:"%02i:%02i:%02i", hours, minutes, seconds))"
//            print("timeStr = \(timeStr)")
            
        })
        
        viewModel.topSpeed.bind(listener: { [unowned self] data in
            
            self.topSpeedLabel.text = String(format: "%.1f",data)
            
        })
        
        viewModel.avgSpeed.bind(listener: { [unowned self] data in
            
            self.avgSpeedLabel.text = String(format: "%.1f",data)
            
        })
        
        
        viewModel.currentSpeed.bind(listener: { [unowned self] data in
            
            if(data > 80){
                gradientLayer.colors = [CGColor(red: 0, green: 1, blue: 0, alpha: 1), CGColor(red: 1, green: 1, blue: 1, alpha: 1)]
            }else {
                gradientLayer.colors = [CGColor(red: 1, green: 0, blue: 0, alpha: 1), CGColor(red: 1, green: 1, blue: 1, alpha: 1)]
            }
            
            if(data >= (self.currentSpeedLabel.text?.double() ?? 0.0)){ //加速
                speedUp()
                
            }else{ //減速
                speedDown()
            }
          
          //  self.currentSpeedLabel.text =  String(format: "%.1f",currentSpeed)

            print("timer isValid= \(timer?.isValid == nil)")
            
          //  if(!(timer?.isValid ?? false) && currentSpeed > minSpeed && self.second == 0 && !self.mapView.isCompeteFinish){
            
            //當計時未開始 且 時速大於預設最低速度 且未完賽 時觸發
            if((timer?.isValid == nil || timer?.isValid == false) && data > minSpeed && self.viewModel.second.value == 0 && !self.mapView!.isCompeteFinish && self.mapView?.modeStyle == 0 ){
                
                print( "currenSpeed = \(data)")
                print("timer.timeInterval = \(timer?.timeInterval)")
                print( "self.second = \(self.viewModel.second.value)")
                print( " (立即開始模式)，時速大於20 計時開始")
              //  SpeedSingleton.share.showAlert(viewConroller: self, "(立即開始模式)，時速大於20 計時開始")
                self.showToast(message: "計時開始")
                
                setTimer()
                
                self.mapView?.isDrawPath = true
                self.mapView?.isOverStartAnnotion = true
                
            }
            
        })
        
        
        
    }
    
    func setMissionTipView(){
        
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        self.view.addSubview(view)
        
        view.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(200)
            make.height.width.equalTo(120)
        }
        
  
        let bgImag = UIImageView(image: UIImage(named: "startEndBg_Icon"))
        view.addSubview(bgImag)
        
        bgImag.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        
        starPointLable.text = "起點"
        starPointLable.font = UIFont(name: "PingFangTC-Medium", size: 18)
        starPointLable.textAlignment = .center
        starPointLable.textColor = .white
        view.addSubview(starPointLable)
        
        starPointLable.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(35)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.height.equalTo(20)
        }
     
        endPointLable.text = "終點"
        endPointLable.font = UIFont(name: "PingFangTC-Medium", size: 18)
        endPointLable.textAlignment = .center
        endPointLable.textColor = .black
        view.addSubview(endPointLable)
        
        endPointLable.snp.makeConstraints { (make) in
            make.top.equalTo(starPointLable).offset(32)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.height.equalTo(20)
        }

        
        
    }
    
    func setMapView(){
        
        mapView = MapView(frame: .zero)
        mapView?.delegate = self
        self.view.addSubview(mapView!)
        mapView?.snp.makeConstraints({ (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
           // make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(0)
            make.bottom.equalToSuperview().offset(100)
        })
        
    }

    func setBannerAdsView(){
        
        #if DEBUG
        print("setBannerAdsView DEBUG")
 
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.delegate = self
      //  GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["1EF245DE-B0C1-499E-ABFA-FA7F9B2E6ED5"]
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["  A4A6ABAF-3DAE-429C-9E78-D01E2504EA18"]
        
        let request = GADRequest()
        let fbExtras = GADFBNetworkExtras()
        fbExtras.nativeAdFormat = GADFBAdFormat.native
        request.register(fbExtras)
//
        bannerView.load(request)
        bannerView.load(GADRequest())
        
        self.view.addSubview(bannerView)
        self.bannerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(view).multipliedBy(0.1)
        }
        
        #else
        print("setBannerAdsView Release")
        //ca-app-pub-6780602618431578/1397966712
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-6780602618431578/1397966712"
        bannerView.rootViewController = self
        bannerView.delegate = self
        
      //  GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["1EF245DE-B0C1-499E-ABFA-FA7F9B2E6ED5"]
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["  A4A6ABAF-3DAE-429C-9E78-D01E2504EA18"]
      
        
        let request = GADRequest()
//        let extras = GADMAdapterAdColonyExtras()
//        extras.showPrePopup = true
//        extras.showPostPopup = true
//        request.register(extras)
        
        let fbExtras = GADFBNetworkExtras()
        fbExtras.nativeAdFormat = GADFBAdFormat.native
        request.register(fbExtras)
//
        bannerView.load(request)
        
        
        self.view.addSubview(bannerView)
        self.bannerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(view).multipliedBy(0.1)
        }
        
        #endif

  
        
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerView adapter class name: \(bannerView.responseInfo?.adNetworkClassName)")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: 1 = \(error)")
        print("interstitial:didFailToReceiveAdWithError: 2 \(error.localizedDescription)")
    }
    
    
    func setBottomView(){
        
        let height = UIScreen.main.bounds.height <= 667 ? UIScreen.main.bounds.height * 0.7 : UIScreen.main.bounds.height * 0.5
        let width  = UIScreen.main.bounds.width
        bottomSheetView = BottomSheetView(frame: CGRect(x: 0, y: self.view.frame.maxY, width: width, height: CGFloat(height)))
//        bottomSheetView?.gesture?.isEnabled = true
  
        self.view.addSubview(bottomSheetView!)
        
//        bottomSheetView?.snp.makeConstraints({ (make) in
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            make.bottom.equalToSuperview()
//            make.height.equalTo(height)
//        })
        
        

        topView.backgroundColor = .clear
        bottomSheetView!.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            //    make.bottom.equalToSuperview()
            make.height.equalTo(150)
        }
        
        
        //Speed
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapEvent(sender:)))
        tap.numberOfTapsRequired = 1
//        speedView.addGestureRecognizer(tap)
        

//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
       
      
      
        
        speedView = UIView()
        speedView.backgroundColor = .black
        speedView.layer.cornerRadius = 55.0
        
        topView.addSubview(speedView)
      //  speedView.addGestureRecognizer(longPressRecognizer)
        speedView.addGestureRecognizer(tap)
        
        speedView.snp.makeConstraints { (make) in
            make.height.width.equalTo(110)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()

        }
        
        
        currentSpeedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 2*(radius+lineWidth), height: 2*(radius+lineWidth)))
        currentSpeedLabel.text = "\(0.0)"
        currentSpeedLabel.textAlignment = .center
        currentSpeedLabel.font = UIFont(name: "PingFangTC-Medium", size: 35)
        currentSpeedLabel.textColor = .white
        speedView.addSubview(currentSpeedLabel)
//        speedLabel.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//
//        }
        
        
        let footerView = UIView()
        footerView.backgroundColor = .clear
        bottomSheetView!.addSubview(footerView)
        footerView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let footerTopView = UIView()
        footerTopView.clipsToBounds = true
        footerTopView.layer.cornerRadius = 10.0
        footerTopView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        footerTopView.backgroundColor = .black
        footerView.addSubview(footerTopView)
        footerTopView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            
        }
        
        let centerLine = UIView()
        centerLine.backgroundColor = .white
        footerTopView.addSubview(centerLine)
        centerLine.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.equalTo(footerTopView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            
        }
        
        let footerBottomView = UIView()
        footerBottomView.backgroundColor = .black
        footerView.addSubview(footerBottomView)
        footerBottomView.snp.makeConstraints { (make) in
          
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(footerTopView.snp.bottom)
            make.bottom.equalToSuperview()
            
        }
        
        
        //公里
//        let kmDiscriptionLabel = UILabel()
//        kmDiscriptionLabel.text = "全程約:"
//        kmDiscriptionLabel.font = UIFont.systemFont(ofSize: 20)
//        kmDiscriptionLabel.textColor = .white
//        footerBottomView.addSubview(kmDiscriptionLabel)
//
//        kmDiscriptionLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(10)
//            make.top.equalToSuperview().offset(20)
//            make.height.equalTo(30)
//        }
        

        distanceKM = UILabel()
        distanceKM.textAlignment = .center
       
        distanceKM.font =  UIFont(name: "PingFangTC-Medium", size: 50)
        distanceKM.textColor = .white
        footerBottomView.addSubview(distanceKM)
        
        distanceKM.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(50)
        }
        
        let kmLabel = UILabel()
        kmLabel.textAlignment = .center
        kmLabel.text = "km"
        kmLabel.font = UIFont(name: "PingFangTC-Medium", size: 15)
        kmLabel.textColor = .white
        footerBottomView.addSubview(kmLabel)
        
        kmLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(distanceKM.snp.bottom).offset(5)
            make.height.width.equalTo(15)
        }
        
        topSpeedLabel = UILabel()
        topSpeedLabel.textAlignment = .center
        topSpeedLabel.text = "0.0"
        topSpeedLabel.font =  UIFont(name: "PingFangTC-Medium", size: 27)
        topSpeedLabel.textColor = .white
        footerBottomView.addSubview(topSpeedLabel)
        
        topSpeedLabel.snp.makeConstraints { (make) in
            make.top.equalTo(kmLabel.snp.bottom).offset(20)
            make.height.width.equalTo(25)
            make.right.equalToSuperview()
            make.left.equalToSuperview()
        }
        let topDiscriptionSpeedLabel = UILabel()
        topDiscriptionSpeedLabel.textAlignment = .center
        topDiscriptionSpeedLabel.text = "最高速度"
        topDiscriptionSpeedLabel.font = UIFont(name: "PingFangTC-Medium", size: 15)
        topDiscriptionSpeedLabel.textColor = .white
        footerBottomView.addSubview(topDiscriptionSpeedLabel)
        
        topDiscriptionSpeedLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topSpeedLabel.snp.bottom).offset(20)
            make.height.width.equalTo(15)
            make.right.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        
        
        avgSpeedLabel = UILabel()
        avgSpeedLabel.textAlignment = .right
        avgSpeedLabel.text = "0.0"
        avgSpeedLabel.font =  UIFont(name: "PingFangTC-Medium", size: 27)
        avgSpeedLabel.textColor = .white
        footerBottomView.addSubview(avgSpeedLabel)
        
        avgSpeedLabel.snp.makeConstraints { (make) in
            make.top.equalTo(kmLabel.snp.bottom).offset(20)
            make.height.width.equalTo(25)
            make.right.equalToSuperview().offset(-33)
            make.left.equalToSuperview()
            
        }
        
        let avgDiscriptionSpeedLabel = UILabel()
        avgDiscriptionSpeedLabel.textAlignment = .right
        avgDiscriptionSpeedLabel.text = "平均速度"
        avgDiscriptionSpeedLabel.font = UIFont.systemFont(ofSize: 15)
        avgDiscriptionSpeedLabel.textColor = .white
        footerBottomView.addSubview(avgDiscriptionSpeedLabel)
        
        avgDiscriptionSpeedLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avgSpeedLabel.snp.bottom).offset(20)
            make.height.width.equalTo(15)
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview()
            
        }
        
        timeLabel = UILabel()
        timeLabel.textAlignment = .left
        timeLabel.text = "00:00:00"
        timeLabel.font =  UIFont(name: "PingFangTC-Medium", size: 27)
        timeLabel.textColor = .white
        footerBottomView.addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(kmLabel.snp.bottom).offset(20)
            make.height.width.equalTo(25)
            make.right.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            
        }
        
        let timeDiscriptionLabel = UILabel()
        timeDiscriptionLabel.textAlignment = .left
        timeDiscriptionLabel.text = "時間"
        timeDiscriptionLabel.font = UIFont(name: "PingFangTC-Medium", size: 15)
        timeDiscriptionLabel.textColor = .white
        footerBottomView.addSubview(timeDiscriptionLabel)
        
        timeDiscriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(20)
            make.height.width.equalTo(15)
            make.right.equalToSuperview()
            make.left.equalToSuperview().offset(60)
            
        }
        
        
        let lineView = UIView()
        lineView.layer.cornerRadius = 2.0
        lineView.backgroundColor = .white
        footerTopView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(3)
            make.width.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        
    }
    

    func setTimer(){
    
        
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
//
//
//            self.second += 1
//
//          //  self.timeLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
//
//            let currentcell = self.cardCollectionView.cardCollectionView.visibleCells.first
//            if currentcell is CommonModelCell{ //普通模式
////                if(self.viewModel?.speedGroupData == nil){
////
////                    let cell = currentcell as? CommonModelCell
////
////
////
////                }
//
//                self.timeLabel.text = self.timeStr
//
//
//                let speedData = SpeedModel(id: 0, speed: self.currentSpeed, time:self.second , avgSpeed: self.avgSpeed, startTimestamp: self.viewModel?.speedGroupData?.startTimestamp ?? 0,location: "\(self.mapView.userLocation.coordinate.latitude),\(self.mapView.userLocation.coordinate.longitude)")
//
//
//                self.viewModel?.speedDatas.append(speedData)
//
//            }
//
//
//        })
        
        if(self.timer == nil){
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
//            RunLoop.main.run()
            RunLoop.main.add(self.timer!, forMode: .common)

        }
        

        
    }
    
    
    @objc func updateTime(){
        
        print("updateTime")
        
        self.viewModel.second.value += 1
 
        print("self.viewModel?.second.value = \(self.viewModel.second.value)")
       
        //新增user data
        self.viewModel.insertUserData(userLocation: self.mapView?.userLocation ?? CLLocation(latitude: 0.0, longitude: 0.0))

        
        if(self.mapView!.isDrawPath){
            
            starPointLable.textColor = .green
        }else{
            starPointLable.textColor = .red
        }

    }
    
    func releasMemory(){

        //insert sql
        SpeedSingleton.share.appDelegate?.showLoadView(message: "處理中，請稍候")

        self.viewModel.saveData()

        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            
            DispatchQueue.main.async {
                
                autoreleasepool {
                    self.view.backgroundColor = .black
                    self.timer?.invalidate()
                    self.timer = nil
                    self.currentSpeedLabel.text = "0.0"
                    self.viewModel.second.value = 0
                    self.topSpeedLabel.text = "0.0"
                    self.avgSpeedLabel.text = "0.0"
                    self.timeLabel.text = "00:00:00"
                    self.distanceKM.text = "0.0"
                    self.currentSpeedLabel.text = "0.0"
                    self.viewModel.speedDatas.removeAll()

                    self.bottomSheetView?.removeSubviews()
                    self.bottomSheetView?.removeFromSuperview()
                    self.bottomSheetView = nil

                    self.mapView?.reset()
                    self.mapView?.removeSubviews()
                    self.mapView?.removeFromSuperview()
                    self.mapView?.delegate = nil
                    self.mapView = nil
                    
                    
                    SpeedSingleton.share.appDelegate?.hiddenLoadView()

                }

            }
            
        }
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
       // UIApplication.shared.isIdleTimerDisabled = true
    
        releasMemory()

        
    }
    
    deinit{
        print ("********* deinit MapVC \(#function) ********** ")
    }
    
    override func didReceiveMemoryWarning() {
         print("********* MapVC \(#function) **********")
         super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
 
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewWillLayoutSubviews() {
        //circle
//        if(percentagePath != nil){
//            return
//        }
        
  

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        setBottomView()

        let mapInfo = delegate?.getMapInfo()
        
        mapView?.modeStyle = mapInfo!.modeStyle
        mapView!.startAnnotation = mapInfo!.startAnnotation
        mapView!.endAnnotation = mapInfo!.endAnnotation
//        mapView!.startMKCircle = mapInfo!.startMKCircle
//        mapView!.endMKCircle = mapInfo!.endMKCircle
        mapView!.start_Location = mapInfo!.start_Location
        mapView!.end_Location = mapInfo!.end_Location
        

        let circlePath = UIBezierPath(ovalIn: CGRect(x: lineWidth, y: lineWidth, width: radius*2, height: radius*2))
        
        circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = UIColor.gray.cgColor
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = UIColor.clear.cgColor
  
        percentagePath = UIBezierPath(arcCenter: CGPoint(x: lineWidth + radius, y: lineWidth + radius), radius: radius, startAngle: aDegree * startDegree, endAngle: aDegree * (startDegree + 360 * percentFloat / 100), clockwise: true)
        
        percentageLayer = CAShapeLayer()
        percentageLayer.path = percentagePath?.cgPath
        percentageLayer.strokeColor  =   UIColor.init(hexString: "0xFF6CDAD2")?.cgColor
  
        
        percentageLayer.lineWidth = lineWidth
        percentageLayer.fillColor = UIColor.clear.cgColor
        
        gradientLayer = CAGradientLayer()
           gradientLayer.colors = [CGColor(red: 0, green: 0, blue: 1, alpha: 1), CGColor(red: 1, green: 1, blue: 1, alpha: 1)]
        gradientLayer.frame = speedView.bounds
        speedView.layer.addSublayer(gradientLayer)
        speedView.layer.addSublayer(circleLayer)
        gradientLayer.mask = circleLayer
        self.speedView.layer.addSublayer(percentageLayer)
        
        
        //annotion
        self.mapView?.startAnnotation.title = "起點"
        self.mapView?.startAnnotation.image = UIImage(named: "red_flag20201219")
        
        var region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  self.mapView!.startAnnotation.coordinate.latitude, longitude:  self.mapView!.startAnnotation.coordinate.longitude), radius: self.mapView!.regionRadius, identifier: "START")
        self.mapView!.locationManager.startMonitoring(for: region)
    
        //新加大頭針
        self.mapView!.mapView.addAnnotation( self.mapView!.startAnnotation)

      //  self.mapView.mapView.addOverlay(self.mapView.startMKCircle)
        self.mapView!.start_Location = CLLocation(latitude: self.mapView!.startAnnotation.coordinate.latitude, longitude: self.mapView!.startAnnotation.coordinate.longitude)
        

        self.mapView!.endAnnotation.title = "終點"
        self.mapView!.endAnnotation.image = UIImage(named: "chequered_flag20201219")
        
         region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  self.mapView!.endAnnotation.coordinate.latitude, longitude:  self.mapView!.endAnnotation.coordinate.longitude), radius: self.mapView!.regionRadius, identifier: "END")
        self.mapView?.locationManager.startMonitoring(for: region)
        
        //新加大頭針
        self.mapView?.mapView.addAnnotation( self.mapView!.endAnnotation)
        
        
        // . 繪製一個圓圈圖形（用於表示 region 的範圍）
      //  self.mapView.mapView.removeOverlay(self.mapView.endMKCircle)
      
      //  self.mapView.mapView.addOverlay(self.mapView.endMKCircle)
        
        self.mapView?.end_Location = CLLocation(latitude: self.mapView!.endAnnotation.coordinate.latitude, longitude: self.mapView!.endAnnotation.coordinate.longitude)

        
        startEvent()
        
  
        
    }
    
    
    

}

extension SpeedCometeVC:MapViewDelegate{
    
//
//    func getUserLocation(isGetLocation: Bool) {
//
//
//
//    }
//
    
    func setTimerStart(isStart: Bool) {
        
        //開始計時
        if(isStart && self.viewModel.second.value == 0){
            
            setTimer()
            
        }else if(!isStart){     //到達終點
            
            print("isStart = \(isStart)")
            
            endPointLable.textColor = .green
            
//                self.rest()
            timer?.invalidate()
           // self.second = 0
            currentSpeedLabel.text = "結束"
          //  self.mapView.mapView.delegate = nil
            self.mapView?.locationManager.stopUpdatingLocation()
            //截圖
            SpeedSingleton.share.takeSnapShot(coordinates: self.mapView!.myPathPoint) { (image) in
                
                self.viewModel.saveSnapShot(shotImage: image, starLocation:self.mapView!.start_Location , endLocation: self.mapView!.end_Location)

            }
            
       
            //震動3秒
            
           DispatchQueue.global().asyncAfter(deadline:.now() + 1) {
               AudioServicesPlaySystemSound(self.soundID)
           }
           
           DispatchQueue.global().asyncAfter(deadline:.now() + 2) {
               AudioServicesPlaySystemSound(self.soundID)
           }
           
           DispatchQueue.global().asyncAfter(deadline:.now() + 3) {
               AudioServicesPlaySystemSound(self.soundID)
           }

            
            //test
//            if(self.mapView!.endInside){
//                endInsideLable.textColor = .green
//            }else{
//
//                endInsideLable.textColor = .red
//            }
//
//
//            if(self.mapView!.endOutside){
//                endOutsideLable.textColor = .green
//            }else{
//                endOutsideLable.textColor = .red
//            }
            
        }

    }
    
    
    func getLocationDats(currentSpeed: Double, topSpeed: CLLocationSpeed, avgSpeed: CLLocationSpeed) {
        
        
        if(self.viewModel.second.value % 3 != 0){
            return
        }

   
        self.viewModel.topSpeed.value = topSpeed.floor(toDecimal: 1)
        print("avgSpeed = \(avgSpeed)")
        print("currenSpeed = \(String(format: "%.1f",currentSpeed))")
        self.viewModel.avgSpeed.value = avgSpeed
        self.viewModel.currentSpeed.value = currentSpeed
        print("double = \(self.currentSpeedLabel.text?.double()))")
      
      
    
//        DispatchQueue.main.async {
//
//
//          //  self.timeLabel.text = self.timeStr
//        }
      
   

    }
    
    
    
    func speedUp(){
      
        
        if(!self.mapView!.isCompeteFinish){
            
            if(self.viewModel.currentSpeed.value == 0){
                self.currentSpeedLabel.text = "結束"
               // self.mapView.isUserStopLocation = true
            
                return
            }
            
            if(!self.mapView!.isCompeteFinish && self.viewModel.currentSpeed.value >= 1){
                
                
                
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.1 ) {
                    
                    DispatchQueue.main.async {
                        print("self.currentSpeed = \(self.viewModel.currentSpeed.value)")
                        print("self.currentSpeedLabel.text?.double() = \(self.currentSpeedLabel.text?.double() ?? 0.0)")
                        if(self.viewModel.currentSpeed.value >= (self.currentSpeedLabel.text?.double() ?? 0.0)){
                            var speedDouble = self.currentSpeedLabel.text?.double() ?? 0.0
                            speedDouble += 1.0
                            
                            print("self.currentSpeedLabel.text up = \(speedDouble)")
                            self.currentSpeedLabel.text = String(Int(speedDouble))
                            
                         //  self.currentSpeedLabel.text = String(format: "%.1f",speedDouble)
    //                        self.currentSpeed = speedDouble
                            self.speedUp()
                        }
                    }
                    
                }
            }
            
        }else{
            
            self.currentSpeedLabel.text = "結束"
 
        }

        
    }
    
    func speedDown(){
        
        if(!self.mapView!.isCompeteFinish){
            
            if(self.viewModel.currentSpeed.value == 0){
                self.currentSpeedLabel.text = "結束"
//                self.mapView.isUserStopLocation = true
                return
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1 ) {
                
                DispatchQueue.main.async {
                    print("self.currentSpeed = \(self.viewModel.currentSpeed.value)")
                    print("self.currentSpeedLabel.text?.double() = \(self.currentSpeedLabel.text?.double() ?? 0.0)")
                    if(self.viewModel.currentSpeed.value <= (self.currentSpeedLabel.text?.double() ?? 0.0)){
                        var speedDouble = self.currentSpeedLabel.text?.double() ?? 0.0
                        speedDouble -= 1.0
                        speedDouble = speedDouble <= 0 ? 0.0 : speedDouble
                        print("self.currentSpeedLabel.text down = \(speedDouble)")
                        if(speedDouble <= 0){
                           
                            self.currentSpeedLabel.text = "0.0"
                       
                        }else {
                            self.currentSpeedLabel.text = String(Int(speedDouble))
                            
                            
//                            self.currentSpeedLabel.text = String(format: "%.1f",speedDouble)
                        }
                      
                       // self.currentSpeed = speedDouble
                        self.speedDown()
                    }
                }
                
            }
        }else{
            self.currentSpeedLabel.text = "結束"
           // self.mapView.isUserStopLocation = true
        }
        
    }

}

