//
//  BottomSheetView.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/10/7.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit

class BottomSheetView: UIView {

    var positon:CGFloat = 0.0
    
//    public var defaultMininumDisplayHeight: CGFloat = 50 {
//        didSet {
//            mininumDisplayHeight = defaultMininumDisplayHeight
//        }
//    }
//
//    public var defaultMaxinumDisplayHeight: CGFloat = 500 {
//        didSet {
//            maxinumDisplayHeight = defaultMaxinumDisplayHeight
//        }
//    }
  //  let bottomHeight = UIApplication.shared.windows.first?.safeAreaInsets.bottom

    var mininumDisplayHeight: CGFloat = 200
    
    var maxinumDisplayHeight: CGFloat = UIScreen.main.bounds.height <= 667 ? UIScreen.main.bounds.height * 0.4 : UIScreen.main.bounds.height * 0.5
    
    var gesture:UIPanGestureRecognizer?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BottomSheetView.panGesture))
        self.addGestureRecognizer(gesture!)
        
       // prepareBackgroundView()
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            let frame = self?.frame
          
          
            let yComponent = UIScreen.main.bounds.height -  self!.mininumDisplayHeight
            self?.positon = yComponent
            self?.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
            
        }

    }
    
    override func layoutSubviews() {
        
 
    }

    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init()
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)

        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.frame.height)

        self.insertSubview(bluredView, at: 0)
    }
    

    
    
    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        var y = self.frame.minY
        print("y + translation.y = \(y + translation.y)")
        print("UIScreen.main.bounds.height = \(UIScreen.main.bounds.height)")
        print("UIScreen.main.bounds.height - y = \(UIScreen.main.bounds.height - y)")
        
      
        
        y = y + translation.y
        
        if(y < self.maxinumDisplayHeight ){ //top
            y = self.maxinumDisplayHeight
        }else if(y > positon){//下

            y = UIScreen.main.bounds.height  - mininumDisplayHeight
       
        }else if(y < positon){//上
            y = self.maxinumDisplayHeight
         
        }

        UIView.animate(withDuration: 0.5) {
            self.frame = CGRect(x: 0, y: y, width: self.frame.width, height:  self.frame.height)
            recognizer.setTranslation(.zero, in: self)
            
            self.layoutIfNeeded()
            
        } completion: { (completed) in
            self.positon =  self.frame.origin.y
        }

        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
