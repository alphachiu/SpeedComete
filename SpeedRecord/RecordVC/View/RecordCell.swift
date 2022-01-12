//
//  RecordCell.swift
//  SpeedRecord
//
//  Created by Alghero_Mac_02 on 2020/10/21.
//  Copyright © 2020 Alpha. All rights reserved.
//

import UIKit
import SnapKit


protocol RecordCellDelegate {
    
    func note(index:IndexPath,noteStr:String)
}


class RecordCell: UITableViewCell {
    
    var delegate:RecordCellDelegate?
    let dateLabel:UILabel = UILabel()
    let placeLabel:UILabel = UILabel()
    let totalKMLabel:UILabel = UILabel()
    let totalTimeLabel:UILabel = UILabel()
    
    let mapImage:UIImageView = UIImageView()
    
    let noteTextView = UITextView()
    var indexPath:IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
       
        
        mapImage.backgroundColor = .gray
        mapImage.contentMode = .scaleAspectFit
        self.addSubview(mapImage)
        
        mapImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
           // make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.height.width.equalTo(80)
        }
        
        dateLabel.font =  UIFont(name: "PingFangSC-Light", size: 15.0)
        dateLabel.text = ""
        dateLabel.textColor = UIColor(hexString: "9E9E9E", transparency: 1)
        self.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            //make.left.equalToSuperview().offset(30)
            make.left.equalTo(mapImage.snp.right).offset(30)
            make.height.equalTo(20)
        }
        
        placeLabel.font =  UIFont(name: "PingFangTC-Regular", size: 15.0)
        placeLabel.text = ""
        placeLabel.textColor = .black
        self.addSubview(placeLabel)
        placeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dateLabel.snp.bottom).offset(5)
           // make.left.equalToSuperview().offset(30)
            make.left.equalTo(mapImage.snp.right).offset(30)
            make.height.equalTo(20)                   
        }
        
        totalKMLabel.font =  UIFont(name: "PingFangSC-Light", size: 15.0)
        totalKMLabel.text = ""
        totalKMLabel.textColor = UIColor(hexString: "9E9E9E", transparency: 1)
        self.addSubview(totalKMLabel)
        totalKMLabel.snp.makeConstraints { (make) in
            make.top.equalTo(placeLabel.snp.bottom).offset(5)
            //make.left.equalToSuperview().offset(30)
            make.left.equalTo(mapImage.snp.right).offset(30)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        }
        
        totalTimeLabel.font =  UIFont(name: "PingFangSC-Light", size: 15.0)
        totalTimeLabel.text = ""
        totalTimeLabel.textColor = UIColor(hexString: "9E9E9E", transparency: 1)
        self.addSubview(totalTimeLabel)
        totalTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(placeLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        }
        
        noteTextView.font =  UIFont(name: "PingFangTC-Regular", size: 15.0)
        noteTextView.borderWidth = 1.0
        noteTextView.returnKeyType = .done
        noteTextView.insertText("test")
        noteTextView.borderColor = .lightGray
        noteTextView.layer.cornerRadius = 5.0
        noteTextView.clipsToBounds = true
        noteTextView.text = "備註"
        noteTextView.delegate = self
        noteTextView.textColor = UIColor.lightGray
        self.addSubview(noteTextView)
        noteTextView.snp.makeConstraints { (make) in
            make.top.equalTo(totalKMLabel.snp.bottom).offset(5)
            make.left.equalTo(mapImage.snp.right).offset(30)
            make.right.equalToSuperview().offset(-10)
          //  make.bottom.equalToSuperview().offset(5)
            make.height.equalTo(50)
        }
        
        
        let separateLineView = UIView()
        separateLineView.backgroundColor = UIColor(hexString: "9E9E9E", transparency: 1)
        self.addSubview(separateLineView)
        separateLineView.snp.makeConstraints { (make) in
            make.top.equalTo(noteTextView.snp.bottom).offset(5)
            make.right.equalToSuperview()
            make.left.equalToSuperview().offset(30)
            make.height.equalTo(1)
        }
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension RecordCell:UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            
            print("tag = \(self.tag) , textView.text = \(textView.text!)")
            delegate?.note(index: indexPath, noteStr:  textView.text!)
            
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = "Placeholder"
//            textView.textColor = UIColor.lightGray
//        }else{
//
//            print("tag = \(self.tag) , textView.text = \(textView.text!)")
//
//        }
//    }

}
