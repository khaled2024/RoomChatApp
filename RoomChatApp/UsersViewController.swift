//
//  UsersViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 29/09/2022.
//

import UIKit

class UsersViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Users"
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    

   

}
