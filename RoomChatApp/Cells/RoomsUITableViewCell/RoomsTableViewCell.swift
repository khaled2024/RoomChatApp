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
    
}
