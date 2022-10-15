//
//  RoomsUITableViewCell.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 29/09/2022.
//

import UIKit

class RoomsTableViewCell: UITableViewCell {

    @IBOutlet weak var roomChatName: UILabel!
    @IBOutlet weak var roomImageView: UIImageView!
    
    static let identifier = "RoomsTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func config(model: Room){
        self.roomChatName.text = model.roomName
        self.roomImageView.image = UIImage(named: "chatLogo")
    }
    func configForUser(model: User){
        self.roomChatName.text = model.name
        self.roomImageView.image = UIImage(named: "user")
        self.roomImageView.tintColor = .darkGray
        self.roomChatName.font = UIFont(name: "American Typewriter", size: 20)
    }
    func configForPrivateChat(model: PersonalChat){
        self.roomChatName.text = model.reciverName
        self.roomImageView.image = UIImage(named: "chatLogo")
    }
    
}
