//
//  Message.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 17/10/2022.
//

import UIKit
import FirebaseAuth
struct Message{
    var fromId: String?
    var text: String?
    var timeStamp: NSNumber?
    var toId: String?
    
    func chatPartnerId()-> String?{
                return fromId == Auth.auth().currentUser?.uid ? toId : fromId
//        if fromId == Auth.auth().currentUser?.uid {
//            return toId
//        }else{
//            return fromId
//        }
    }
    
}
