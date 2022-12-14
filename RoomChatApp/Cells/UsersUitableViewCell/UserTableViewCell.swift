//
//  UserTableViewCell.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 16/10/2022.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    static let identifier = "UserTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userProfileImage.contentMode = .scaleAspectFill
        userProfileImage.layer.masksToBounds = true
        self.userProfileImage.layer.cornerRadius = userProfileImage.frame.size.height / 2
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func config(user: User){
        self.userName.text = user.name
        self.userEmail.text = user.email
        if let profileImage = user.profileImageURL {
            self.userProfileImage.loadDataUsingCacheWithUrlString(urlString: profileImage)
        }
    }
}
