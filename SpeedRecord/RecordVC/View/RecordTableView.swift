//
//  RecordTableView.swift
//  SpeedRecord
//
//  Created by Alghero_Mac_02 on 2020/10/20.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import SnapKit
import EmptyDataSet_Swift

protocol RecordTableViewDelegate {
    
    func didToGroupInfo(timeStamp:Int,totalTime:String,totoalDistance:String)
    func reloadData()
}

class RecordTableView: UIView {

   
    
    var viewModel:RecordViewModel!
    var delegate:RecordTableViewDelegate?
    var refreshControl:UIRefreshControl!
    let tableView:UITableView = {
       
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.backgroundColor = .white
        view.separatorStyle = .none
        return view
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        tableView.register(UINib(nibName: "RecordCell", bundle: nil), forCellReuseIdentifier: "RecordCellID")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        //開始下拉更新的功能
        refreshControl = UIRefreshControl()
        //修改顯示文字的顏色
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        //顯示文字內容
        refreshControl.attributedTitle = NSAttributedString(string: "正在更新", attributes: attributes)
        //設定元件顏色
        refreshControl.tintColor = UIColor.black
        //設定背景顏色
        refreshControl.backgroundColor = UIColor.white
        //將元件加入TableView的視圖中
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        
        self.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
   @objc func reloadData() {
       delegate?.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecordTableView:UITableViewDelegate,UITableViewDataSource,EmptyDataSetSource, EmptyDataSetDelegate{
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let year = self.viewModel.recordGroupDatas.value[section].year
        let month = self.viewModel.recordGroupDatas.value[section].month
        let totalNum = self.viewModel.recordGroupDatas.value[section].totalNum
        let totalKM =  self.viewModel.recordGroupDatas.value[section].totalKm
        
        
        let sectionView = UIView()
        sectionView.backgroundColor = .white

        
        let dateLable = UILabel()
        dateLable.backgroundColor = .white
        dateLable.font =  UIFont(name: "PingFangTC-Medium", size: 20.0)
        dateLable.text = "\(year)年\(month)月"
        dateLable.textColor = .black
        sectionView.addSubview(dateLable)
        
        dateLable.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(25)
        }
        
        let numLable = UILabel()
        numLable.font =  UIFont(name: "PingFangSC-Light", size: 15.0)
        numLable.text = "完賽 \(totalNum) 次"
        numLable.textColor = UIColor(hexString: "9E9E9E", transparency: 1)
        sectionView.addSubview(numLable)
        numLable.snp.makeConstraints { (make) in
            make.top.equalTo(dateLable.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }
        
        let totalKMLable = UILabel()
        totalKMLable.font =  UIFont(name: "PingFangSC-Light", size: 15.0)
        totalKMLable.text =  "\(String(format: "%.1f",totalKM)) KM"
        //"\(totalKM) KM"
        totalKMLable.textColor = UIColor(hexString: "9E9E9E", transparency: 1)
        sectionView.addSubview(totalKMLable)
        totalKMLable.snp.makeConstraints { (make) in
            make.top.equalTo(dateLable.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        }

        
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return  self.viewModel.recordGroupDatas.value.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.viewModel.recordGroupDatas.value[section].recordData.count
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "刪除紀錄", message: "是否要刪除此筆紀錄", preferredStyle: .alert)
            
            
            alert.addAction(UIAlertAction(title: "刪除", style: .default, handler: { (_) in

                SQLiteManage.shared.deleteData(deleteGroupData: self.viewModel.recordGroupDatas.value[indexPath.section].recordData[indexPath.row])
                self.viewModel.recordGroupDatas.value[indexPath.section].recordData.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                tableView.reloadData()
                
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (alert) in
             
            }))
            
            
            
            self.findViewController()?.present(alert, animated: true, completion: nil)

        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCellID", for: indexPath) as? RecordCell
        cell?.delegate = self
        cell?.indexPath = indexPath
        cell?.backgroundColor = .white
 
        cell?.selectionStyle = .none

        let timeStamp = self.viewModel.recordGroupDatas.value[indexPath.section].recordData[indexPath.row].timeStamp
        let image = SpeedSingleton.share.loadImage(imgName: "\(timeStamp)")
     
        if(image != nil){
            cell?.mapImage.image = image
        }
        
        let year = self.viewModel.recordGroupDatas.value[indexPath.section].recordData[indexPath.row].year
        let month = self.viewModel.recordGroupDatas.value[indexPath.section].recordData[indexPath.row].month
        let day = self.viewModel.recordGroupDatas.value[indexPath.section].recordData[indexPath.row].day
        
        cell?.dateLabel.text = "\(year)/\(month)/\(day)"
        
        
        
        let startPlace = self.viewModel.recordGroupDatas.value[indexPath.section].recordData[indexPath.row].startPlace
        
        let endPlace = self.viewModel.recordGroupDatas.value[indexPath.section].recordData[indexPath.row].endPlace
        
        
        cell?.placeLabel.text = "\(startPlace) - \(endPlace)"
        
        
        let totalKM = self.viewModel.recordGroupDatas.value[indexPath.section].recordData[indexPath.row].totalKM
        let totalTime = self.viewModel.recordGroupDatas.value[indexPath.section].recordData[indexPath.row].totalTime
        
        let hours = Int(totalTime) / 3600
        let minutes = Int(totalTime) / 60 % 60
        let seconds = Int(totalTime) % 60
        var timeStr = ""
        if(hours == 0){
            timeStr = "\(String(format:"%02i:%02i", minutes, seconds))"
        }else{
            timeStr = "\(String(format:"%02i:%02i:%02i", hours, minutes, seconds))"
        }
    
        
        
        cell?.totalKMLabel.text =  "\(String(format: "%.1f",totalKM)) KM"
            //"\(totalKM) 公里"
        cell?.totalTimeLabel.text = "\(timeStr)"
        
        let note = self.viewModel.recordGroupDatas.value[indexPath.section].recordData[indexPath.row].note
        if(note != "備註" && note != ""){
            cell?.noteTextView.text = note
            cell?.noteTextView.textColor = .black
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let timeStampInt = self.viewModel.recordGroupDatas.value[indexPath.section].recordData[indexPath.row].timeStamp
        print("timeStampInt = \(timeStampInt)")
        let totalKM = self.viewModel.recordGroupDatas.value[indexPath.section].recordData[indexPath.row].totalKM
        let totalTime = self.viewModel.recordGroupDatas.value[indexPath.section].recordData[indexPath.row].totalTime
        let hours = Int(totalTime) / 3600
        let minutes = Int(totalTime) / 60 % 60
        let seconds = Int(totalTime) % 60
        var timeStr = ""
        if(hours == 0){
            timeStr = "\(String(format:"%02i:%02i", minutes, seconds))"
        }else{
            timeStr = "\(String(format:"%02i:%02i:%02i", hours, minutes, seconds))"
        }
    
        
        delegate?.didToGroupInfo(timeStamp: timeStampInt,totalTime: "\(timeStr)",totoalDistance:  "\(String(format: "%.1f",totalKM)) KM")
        
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
         //return UIScreen.main.bounds.size.height / 2
//        if(scrollView.contentOffset.y < 0){
//               return -(UIScreen.main.bounds.size.height * 0.4)
//        }else{
//               return -(UIScreen.main.bounds.size.height * 0.3)
//        }
        return -((UIScreen.main.bounds.size.height * 0.1) - 50)
        
       
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        
        if(self.viewModel.recordGroupDatas.value.isEmpty ){
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
            
            let label = UILabel(frame: .zero)
            label.text = "目前無紀錄"
            label.font = UIFont(name: "PingFangTC-Semibold", size: 16)
            label.textAlignment = .center
            label.textColor = .black
            
            view.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            
            return view
        }else{
            return UIView()
        }
    }
    
}
extension RecordTableView:RecordCellDelegate{

    func note(index: IndexPath, noteStr: String) {
        
//        let section = Int(index.split(separator: "-")[0])
//        let row = Int(index.split(separator: "-")[1])
        

        let timeStamp =  self.viewModel.recordGroupDatas.value[index.section].recordData[index.row].timeStamp
        SQLiteManage.shared.updateNote(timeStamp: timeStamp, newNote: noteStr)
        self.viewModel.recordGroupDatas.value[index.section].recordData[index.row].note = noteStr
        self.tableView.reloadData()
        
    }
    

    
}
