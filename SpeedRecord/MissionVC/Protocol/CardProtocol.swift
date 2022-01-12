//
//  CardProtocol.swift
//  SpeedRecord
//
//  Created by Alghero_Mac_02 on 2020/10/14.
//  Copyright © 2020 Alpha. All rights reserved.
//

import Foundation


protocol CardCellModelDelegate {
    func commonModel_currentLocation(imgTag:Int)
    func commonModel_textFiledChange(text:String,textFieldTag:Int)
}
