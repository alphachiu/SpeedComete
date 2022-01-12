//
//  MissionVC.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/11/14.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import MapKit
import SCLAlertView
import AudioToolbox


class MissionVC: UIViewController {

    var missionMapView:MissionMapView!
    var cardCollectionView:CardCollectionView!
    var viewModel:MissionViewModel!
    var startBtn:UIButton!
    
    var modeTag = 0  // 0 立即開始 1 接觸annation＿start 才開始
    var totoalKM = ""
    

    let soundID = SystemSoundID(kSystemSoundID_Vibrate) //震動
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.overrideUserInterfaceStyle = .light
        
        SpeedSingleton.share.loadInterstitialADs(vc: self)
        
        viewModel = MissionViewModel()

        setMapView()
        setCardView()
        setBottomView()
      
        
        let alertView = SCLAlertView()
        alertView.showSuccess("提示通知", subTitle: "\n1.自訂模式：當紅色旗幟(起點)大於當前位置距離約一公里時，需前往紅色旗幟(起點)則開始計時，直到到達方格旗(終點)才結束計時。 \n\n 2.立即模式：紅色旗幟(起點)小於當前位置距離約一公里時，當前行駛的時速大於20/hr則開始計時，直到到達方格旗(終點)才結束計時。 \n\n3.當按下開始後，行駛停止時則會出現結束按鈕，按結束即可以強制結束。\n",closeButtonTitle: "確定" )

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
        if(self.missionMapView.mapView.mapType != .standard){
            mapViewFixMemory()
        }


//        SpeedSingleton.share.appDelegate?.showLoadView(message: "處理中，請稍候")
//        DispatchQueue.global().asyncAfter(deadline: .now() + 2 ) {
//            
//            DispatchQueue.main.async {
//                SpeedSingleton.share.appDelegate?.hiddenLoadView()
//            }
//        }
    }

    

    func authorization(){
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse:
            missionMapView.locationManager.startUpdatingLocation()
        case .authorizedAlways:
            missionMapView.locationManager.startUpdatingLocation()
        case .denied:
            
            missionMapView.locationManager.requestWhenInUseAuthorization()
        case .notDetermined:
            missionMapView.locationManager.requestWhenInUseAuthorization()
            missionMapView.locationManager.startUpdatingLocation()
            
        case .restricted:
            
            break
        case .authorized:
            break
        
        default:
            break
            
        }
        
     
    }
    

    
    func setCardView(){
        
        cardCollectionView = CardCollectionView(frame: .zero)
        cardCollectionView.delegate = self
        cardCollectionView.viewModel = viewModel
//      cardCollectionView.backgroundColor = .red
        self.view.addSubview(cardCollectionView)
        
        cardCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-25)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().dividedBy(4)
        }
        
    }
    
    func setMapView(){
        
        missionMapView = MissionMapView(frame: .zero)
        missionMapView.delegate = self
        self.view.addSubview(missionMapView)
        missionMapView?.snp.makeConstraints({ (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
           // make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(0)
            make.bottom.equalToSuperview().offset(100)
        })
        
    }
    
    
    func setBottomView(){
        
        startBtn = UIButton()
        //startBtn.setTitle("開始", for: .normal)
        startBtn.setBackgroundImage(UIImage(named: "startBg"), for: .normal)
        startBtn.addTarget(self, action: #selector(startEvent), for: .touchUpInside)
        startBtn.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        startBtn.setTitleColor(.white, for: .normal)
        startBtn.backgroundColor = .black
        startBtn.layer.cornerRadius = 50.0
        
        self.view.addSubview(startBtn)
        startBtn.snp.makeConstraints { (make) in
            make.height.width.equalTo(100)
//            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)

        }
    }
    
    func mapViewFixMemory(){
        
        switch (self.missionMapView.mapView.mapType) {
        case .hybrid:
            self.missionMapView.mapView.mapType = .standard

                break;
        case .standard:
            self.missionMapView.mapView.mapType = .hybrid;
                break;
            default:
                break;
        }
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authorization()
        
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapViewFixMemory()
    }

}

extension MissionVC:CardCellModelDelegate{
    
    func commonModel_currentLocation(imgTag: Int) {
      
        missionMapView.setStart_EndAnnotation(AnnotationTag: imgTag)
          
    }
    
    func commonModel_textFiledChange(text: String, textFieldTag: Int) {
        
        missionMapView.setStart_EndAnnotation(AnnotationTag: textFieldTag, text: text)
    }
    

}

extension MissionVC:MissionMapDelegate{
    func getCurrentStart_EndPlace(startPlace: String, endPlace: String) {
        
        
        let cell = cardCollectionView.cardCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? CommonModelCell
        if(cell != nil){
         
            cell?.startTextField.text = startPlace
            cell?.endTextField.text = endPlace
            
        }
        
    }

}
