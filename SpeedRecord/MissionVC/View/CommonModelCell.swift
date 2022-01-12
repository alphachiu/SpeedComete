//
//  CommonModelCell.swift
//  SpeedRecord
//
//  Created by Alpha on 2020/10/11.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit


class CommonModelCell: UICollectionViewCell, UITextFieldDelegate {

    
    var startTextField:UITextField = {
        
        let view = UITextField()
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.cornerRadius = 10.0
        view.attributedPlaceholder = NSAttributedString(string:"起始位置", attributes:[NSAttributedString.Key.foregroundColor:UIColor.gray])
        view.rightViewMode = .always
        view.textColor = .black
        view.backgroundColor = UIColor.white
        view.returnKeyType = .search
        return view
        
    }()
    var endTextField:UITextField  = {
        
        let view = UITextField()
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.cornerRadius = 10.0
        view.rightViewMode = .always
        view.attributedPlaceholder = NSAttributedString(string:"終點位置", attributes:[NSAttributedString.Key.foregroundColor:UIColor.gray])
        view.textColor = .black
        view.backgroundColor = UIColor.white
        view.returnKeyType = .search
        return view
        
    }()

    let bgView = UIView()
    
    var delegate:CardCellModelDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       
        bgView.backgroundColor = .red
        self.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        
        startTextField.borderStyle = .roundedRect
        startTextField.delegate = self
        startTextField.tag  = 1
//        startTextField.addTarget(self, action: #selector(textChangeTextField(textField:)), for: .editingChanged)

        bgView.addSubview(startTextField)
        
        startTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(35)
        }
        
        endTextField.borderStyle = .roundedRect
        endTextField.delegate = self
        endTextField.tag  = 2
//        endTextField.addTarget(self, action: #selector(textChangeTextField(textField:)), for: .editingChanged)
        bgView.addSubview(endTextField)
        endTextField.snp.makeConstraints { (make) in
            //make.top.equalTo(startTextField.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(35)
            make.bottom.equalToSuperview().offset(-10)
            
        }
        
        
        let startTap = UITapGestureRecognizer()
        startTap.addTarget(self, action: #selector(myLocationImage(imageView:)))
        var imagView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imagView.tintColor = .red
        imagView.image = UIImage(named: "my_location")?.withRenderingMode(.alwaysTemplate)
//        image = image?.imageWith(newSize: CGSize(width: 10, height: 10))
//        imagView.image = image
        var startRightView = UIView(frame: CGRect(
            x: 0, y: 0, // keep this as 0, 0
            width: imagView.frame.width + 10, // add the padding
            height: imagView.frame.height))
       
        imagView.tag = 1
        imagView.isUserInteractionEnabled = true
        imagView.addGestureRecognizer(startTap)
        
       // startTextField.rightViewMode = .whileEditing
        startRightView.addSubview(imagView)
        startTextField.rightView = startRightView
        
        let endTap = UITapGestureRecognizer()
        endTap.addTarget(self, action: #selector(myLocationImage(imageView:)))
        imagView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imagView.image = UIImage(named: "my_location")?.withRenderingMode(.alwaysTemplate)
        imagView.tintColor = .red
        imagView.tag = 2
        imagView.isUserInteractionEnabled = true
        imagView.addGestureRecognizer(endTap)
        
        
        var endRightView = UIView(frame: CGRect(
            x: 0, y: 0, // keep this as 0, 0
            width: imagView.frame.width + 10, // add the padding
            height: imagView.frame.height))
        endRightView.addSubview(imagView)
        endTextField.rightView = endRightView
       
    }

    
    
//    @objc func textChangeTextField(textField:UITextField){
//
//        print("text tag = \(textField.tag)")
//
//
//
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        delegate?.commonModel_textFiledChange(text: textField.text ?? "", textFieldTag: textField.tag)
        
        return true
    }
    
    
    @objc func myLocationImage(imageView:UITapGestureRecognizer){
    
        if let view = imageView.view as? UIImageView{
            print("imageView = \(view.tag)")
            
            if(view.tag == 1){
                
                startTextField.text = "目前位置"
                
            }else{
                endTextField.text = "目前位置"
                
            }
            
            delegate?.commonModel_currentLocation(imgTag: view.tag)

        }
    
        
    }
    
    
}

