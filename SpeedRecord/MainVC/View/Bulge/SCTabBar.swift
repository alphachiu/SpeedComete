//
//  SCTabBar.swift
//  Tabbar
//
//  Created by Alghero_Mac_02 on 2020/10/13.
//

import Foundation

import UIKit

public enum SCTabBarCenterButtonPosition : Int {
    case center // 置中
    case bulge  // 中間凸出
}

//中間按鈕
class SCTabBar: UITabBar {
    // tabbar高度49固定
    let SCTABBARHEIGHT: CGFloat = 49.0
    
    /**
     中間按鈕
     */
    public var centerBtn: UIButton = UIButton(type: .custom)
    
    /**
      中間按鈕圖片
     */
    var centerImage: UIImage? {
        didSet {
            if (centerWidth <= 0 && centerHeight <= 0){
                centerWidth = centerImage?.size.width ?? 0
                centerHeight = centerImage?.size.height ?? 0
            }
            centerBtn.setImage(centerImage, for: .normal)
        }
    }
    /**
     中間選中圖片
     */
//    var centerSelectedImage: UIImage? {
//        didSet {
//            centerBtn.setImage(centerSelectedImage, for: .selected)
//        }
//    }
    
    /**
       中間按鈕偏移量,兩種可選，也可以使用centerOffsetY 自定義
     */
    var positon: SCTabBarCenterButtonPosition = .center
    
    /**
     中間按鈕的寬和高，預設使用圖片寬高
     */
    var centerWidth:CGFloat = 0
    var centerHeight:CGFloat = 0
    /**
     中間按鈕偏移量，預設是居中
     */
    var centerOffsetY:CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        if(centerBtn != nil){
//            return
//        }
        switch positon {
        case .center:
            centerBtn.frame = CGRect(x: (UIScreen.main.bounds.size.width - centerWidth)/2.0, y: (SCTABBARHEIGHT - centerHeight)/2.0, width: centerWidth, height: centerHeight)
        case .bulge:
            centerBtn.frame = CGRect(x: (UIScreen.main.bounds.size.width - centerWidth)/2.0, y: -centerHeight/2.0 + centerOffsetY, width: centerWidth, height: centerHeight)
        }
    }
    
    func initView() {
        //去除點選時亮光
        centerBtn.adjustsImageWhenHighlighted = false
        self.addSubview(centerBtn)
    }
    
    //處理超出區域點擊無效的問題
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !self.isHidden{
            //轉換座標
            let tempPoint = centerBtn.convert(point, from: self)
            //判斷點擊的點是否在按鈕區域內
            if centerBtn.bounds.contains(tempPoint) {
           
                return centerBtn
            }
        }
        return super.hitTest(point, with: event)
    }
}

