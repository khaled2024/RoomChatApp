//
//  Extension+UiView.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 16/09/2022.
//

import Foundation
import UIKit

extension UIView{
    func addLayer(cornerRadius: CGFloat = 10,shadowColor: UIColor = UIColor.lightGray,shadowOffsetWidth: CGFloat = 5 ,shadowOffsetHeight: CGFloat = 5, shadowOpacity: CGFloat = 0.7){
        
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        
        self.layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        let shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowOpacity = Float(shadowOpacity)
    }
}
