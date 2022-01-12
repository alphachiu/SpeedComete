//
//  RecordVC.swift
//  SpeedRecord
//
//  Created by Alghero_Mac_02 on 2020/10/20.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import SnapKit

class RecordVC: UIViewController {

    var recordView:RecordTableView?
    
    lazy var coordintor:RecordCoordinatorProtocol = {

         let a = SingleMissionCoordinator()
         a.vc = self
         return a

     }()
    
    lazy   var viewModel =  RecordViewModel(coordinator: coordintor)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBinding()
        recordView = RecordTableView(frame: .zero)
        recordView?.delegate = self
        recordView?.viewModel = viewModel
        
        self.view.addSubview(recordView!)
        recordView?.snp.makeConstraints({ (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        })
        
        
    }
    
    func setBinding(){
        
        self.viewModel.recordGroupDatas.bind { [unowned self] data in
            
            print("tableView reloadData")
            self.recordView?.tableView.reloadData()
            self.recordView?.refreshControl.endRefreshing()
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        
       // print("")
        reloadData()
    }




}

extension RecordVC:RecordTableViewDelegate{
    
    func reloadData() {
        self.viewModel.reloadData()

    }
    
    
    func didToGroupInfo(timeStamp: Int,totalTime:String,totoalDistance:String) {
        
        self.viewModel.presentInfoVC(data: (timeStamp, totalTime, totoalDistance))
        
    }
    
    
    
}
