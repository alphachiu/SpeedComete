//
//  CardCollectionView.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/10/11.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit

class CardCollectionView: UIView,UICollectionViewDelegate,UICollectionViewDataSource {

 
    let cardCollectionView:UICollectionView = {
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: CardLayout())
        view.backgroundColor = .clear
        
        
        return view
    }()
    
    var delegate:CardCellModelDelegate?
    
    var viewModel:MissionViewModel!
    

    override init(frame: CGRect) {

        super.init(frame: frame)
        
        self.addSubview(cardCollectionView)
        cardCollectionView.dataSource = self
        cardCollectionView.bounces = false
        cardCollectionView.showsHorizontalScrollIndicator = false
        
        cardCollectionView.register(UINib(nibName: "CommonModelCell", bundle: nil), forCellWithReuseIdentifier: "CommonModelCellD")
        
        
        cardCollectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.competeModels.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = viewModel.competeModels[indexPath.row]
        
        switch model {
        case .Common:
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommonModelCellD", for: indexPath) as? CommonModelCell
            cell?.delegate = self
            cell?.bgView.layer.cornerRadius = 15.0
            cell?.bgView.backgroundColor = .white
            cell?.bgView.layer.shadowOffset = CGSize(width: 5,height: 5)
            cell?.bgView.layer.shadowOpacity = 0.7
            cell?.bgView.layer.shadowColor = UIColor.black.cgColor
            
            
            
            return cell!
            
            
            
            
        default:
            break
        }
        
   
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension CardCollectionView:CardCellModelDelegate{
    
    func commonModel_currentLocation(imgTag: Int) {
     
        delegate?.commonModel_currentLocation(imgTag: imgTag)
    }
    
    func commonModel_textFiledChange(text: String, textFieldTag: Int) {
        delegate?.commonModel_textFiledChange(text: text, textFieldTag: textFieldTag)
    }
    
    
    
}
