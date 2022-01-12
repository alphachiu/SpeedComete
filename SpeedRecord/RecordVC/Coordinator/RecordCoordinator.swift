//
//  RecordCoordinator.swift
//  SpeedRecord
//
//  Created by Alpha on 2021/10/21.
//  Copyright © 2021 Alpha. All rights reserved.
//

import Foundation
import UIKit

protocol RecordCoordinatorProtocol: AnyObject {
    func present(data:(timeStamp: Int,totalTime:String,totoalDistance:String))
    func dismiss()
}

class SingleMissionCoordinator: RecordCoordinatorProtocol {
    
    weak var vc: UIViewController?
    
    func present(data:(timeStamp: Int,totalTime:String,totoalDistance:String)) {
       
        let infoVC = RecordInfoVC()
        infoVC.modalPresentationStyle = .fullScreen
        infoVC.timeStampKey = data.timeStamp
        infoVC.totalTime = data.totalTime
        infoVC.totalDistane = data.totoalDistance
        self.vc?.present(infoVC, animated: true, completion: nil)
    }

    
    func dismiss() {
        vc?.dismiss(animated: true, completion: nil)
    }
    
    
}
