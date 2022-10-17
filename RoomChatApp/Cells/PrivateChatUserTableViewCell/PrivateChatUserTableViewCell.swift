//
//  PrivateChatUserTableViewCell.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 17/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class PrivateChatUserTableViewCell: UITableViewCell {
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var lastMsg: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    //MARK: - vars
    static let identifier = "PrivateChatUserTableViewCell"
    var message:Message?{
        didSet{
            if let message = message,let toId = message.toId {
                Database.database().reference().child("users").child(toId).observeSingleEvent(of: .value, with: { snapShot in
                    if let dictionary = snapShot.value as? [String:AnyObject]{
                        self.userName.text = dictionary["name"]as? String
                           if let profileImageUrl = dictionary["profileImageURL"]as? String{
                               self.userImage.loadDataUsingCacheWithUrlString(urlString: profileImageUrl)
                               self.lastMsg.text = message.text
                        }
                        if let seconds = message.timeStamp?.doubleValue{
                            let timeStampDate = Date(timeIntervalSince1970: seconds) 
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "hh:mm:ss a"
                            self.timeLable.text = dateFormatter.string(from: timeStampDate)
                            
                        }
                    }
                }, withCancel: nil)
            }
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userName.text = "----------"
        self.lastMsg.text = "----- ----- -- ------- ---"
        self.timeLable.text = "--/--/--"
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImage.layer.cornerRadius = userImage.frame.size.height/2
        userImage.layer.masksToBounds = true
        self.userImage.contentMode = .scaleAspectFill

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
