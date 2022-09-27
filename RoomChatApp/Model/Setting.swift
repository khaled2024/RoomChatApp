//
//  Setting.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 27/09/2022.
//

import Foundation

struct Setting {
    let title: String
    let option: [Option]
}
struct Option{
    let title: String
    let handler: ()->Void
}
