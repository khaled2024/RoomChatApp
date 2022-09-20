//
//  Extension+UitextField.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 16/09/2022.
//

import Foundation
import UIKit
extension UITextField {
    func changePlaceholderColor(text: String){
        self.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
    }
}
