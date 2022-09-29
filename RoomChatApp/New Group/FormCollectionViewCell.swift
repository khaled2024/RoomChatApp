//
//  FormCollectionViewCell.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 16/09/2022.
//

import UIKit

class FormCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var slideButton: UIButton!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    func configDesign(){
        self.usernameView.addLayer(cornerRadius: 10, shadowColor: .lightGray,shadowOffsetWidth: 3,shadowOffsetHeight: 2,shadowOpacity: 0.2)
        self.emailView.addLayer(cornerRadius: 10, shadowColor: .lightGray,shadowOffsetWidth: 3,shadowOffsetHeight: 2,shadowOpacity: 0.2)
        self.passwordView.addLayer(cornerRadius: 10, shadowColor: .lightGray,shadowOffsetWidth: 3,shadowOffsetHeight: 2,shadowOpacity: 0.2)
        slideButton.addLayer(cornerRadius: 10, shadowColor: .lightGray,shadowOffsetWidth: 3,shadowOffsetHeight: 2,shadowOpacity: 0.2)
        actionButton.addLayer(cornerRadius: 10, shadowColor: .lightGray,shadowOffsetWidth: 3,shadowOffsetHeight: 2,shadowOpacity: 0.2)
    }
    
}

