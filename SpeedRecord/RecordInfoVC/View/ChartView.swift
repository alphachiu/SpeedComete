//
//  ChartView.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/10/25.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import SwiftChart
import SnapKit
import CoreLocation

protocol ChartViewDelegate {
    
    func updateLocation(location:CLLocationCoordinate2D)
}

class ChartView: UIView ,ChartDelegate {

    var viewModel:RecordInfoViewModel?
    var chart:Chart!
    var label: UILabel!
    var delegate:ChartViewDelegate?
    
    
    fileprivate var labelLeadingMarginInitialConstant:  Constraint!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      
        chart = Chart(frame: .zero)
        chart.backgroundColor = .black
        chart.delegate = self
        
        self.addSubview(chart)
        chart.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        
        label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont.init(name: "PingFangSC-Light", size: 15)
        self.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            labelLeadingMarginInitialConstant = make.left.equalToSuperview().constraint
            make.bottom.equalTo(chart.snp.top)
            make.height.equalTo(21)
        }
        print("labelLeadingMarginInitialConstant = \(labelLeadingMarginInitialConstant.layoutConstraints)")
    }
    
    
    func setChartData(){
        
        
        var serieData = self.viewModel?.chartYValuesArray ?? []
        let series = ChartSeries.init(serieData)
        series.area = true
        series.colors = (
            above: ChartColors.greenColor(),
            below: ChartColors.redColor(),
            zeroLevel: 50
          )
        
        
        // Configure chart layout
        chart.lineWidth = 0.5
        chart.labelFont = UIFont.systemFont(ofSize: 12)
       // chart.xLabels = viewModel?.chartXValueArray
        chart.labelColor = .white
        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in

            return ""
           // return (self.viewModel?.chartXStrValueArray[labelIndex] ?? "")
        }
        chart.xLabelsTextAlignment = .left
        chart.yLabelsOnRightSide = true
        
        chart.yLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
            print("serieData.min() = \(serieData.min())")
            
            let value = labelValue < 0 ? 0 : labelValue
            
            
            if(labelIndex == 0){
                print("最低 = \(String(Int(value)))")
                return  "最低 " +  String(Int(value)) + " km"
            }else if(labelIndex == 1){
                print("平均 = \(String(Int(value)))")
                return  "平均 " +  String(Int(value)) + " km"
            }else{
                print("最高 = \(String(Int(value)))")
                return  "最高 " +  String(Int(value)) + " km"
            }
            
//            if(serieData.max() == value){
//
//            }else if(serieData.min() == value){
//
//            }else{
//
//            }
            
          
        }
     //   chart.yLabelsFormatter = { String(Int($1)) + " km"}
        
        // Add some padding above the x-axis
      //  chart.minY = serieData.min()! - 5
        
        chart.add(series)
        
        
    }
    
    
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {

//            let numberFormatter = NumberFormatter()
//            numberFormatter.minimumFractionDigits = 2
//            numberFormatter.maximumFractionDigits = 2
//            label.text = numberFormatter.string(from: NSNumber(value: Int(value)))
            
  
            label.text = String(Int(value))
            
            

            // Align the label to the touch left position, centered

          labelLeadingMarginInitialConstant.update(offset: left - (label.frame.width / 2))

            let currentIndex = indexes[0]!
         //   let locationStr = self.viewModel?.speedDatas[currentIndex].location
            
            let latStr = String((self.viewModel?.speedDatas[currentIndex].location.split(separator: ",")[0]) ?? "")
            let lonStr = String((self.viewModel?.speedDatas[currentIndex].location.split(separator: ",")[1]) ?? "")
            
            if(latStr != "" && lonStr != ""){
                let loaction = CLLocationCoordinate2D(latitude: latStr.double()!, longitude: lonStr.double()!)
                delegate?.updateLocation(location: loaction)
            }
            
     

         //   var constant = labelLeadingMarginInitialConstant + left - (label.frame.width / 2)

            // Avoid placing the label on the left of the chart
//            if constant < labelLeadingMarginInitialConstant {
//                constant = labelLeadingMarginInitialConstant
//            }
//
//            // Avoid placing the label on the right of the chart
//            let rightMargin = chart.frame.width - label.frame.width
//            if constant > rightMargin {
//                constant = rightMargin
//            }
//
//            labelLeadingMarginConstraint.constant = constant

        }
        
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
