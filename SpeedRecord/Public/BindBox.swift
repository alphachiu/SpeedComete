//
//  BindBox.swift
//  SpeedRecord
//
//

import Foundation
final class Box<T>{
    
    //自定義型別
    typealias Listener  = (T) -> Void
    var listener :Listener?
    var value:T{
        didSet{
            listener?(value)
        }
    }
    
    init(_ value:T){
        self.value = value
    }
    
    //綁定
    func bind(listener:Listener?){
        
        self.listener = listener
        listener?(value)
        
    }
    
}
