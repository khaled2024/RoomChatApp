//
//  ChatTableViewCell.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 25/09/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class ChatTableViewCell: UITableViewCell {
    enum messageType {
        case incoming
        case outgoing
        
    }
    var colors: [UIColor] = [
        .systemRed,
        .systemPink,
        .systemBlue,
        .systemGreen,
        .systemOrange,
        .systemBrown,
        .systemPurple,
        .systemIndigo,
        .systemYellow
    ]
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var chatStack: UIStackView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var userNameLable: UILabel!
    
    
    static let identifier = String(describing: ChatTableViewCell.self)
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.layer.cornerRadius = 12
        userImage.layer.cornerRadius = self.userImage.frame.size.height/2
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setMessageData(message: RoomMessage){
        if let userImage = message.userImage {
            self.userImage.loadDataUsingCacheWithUrlString(urlString: userImage)
        }
        userNameLable.text = " \(message.messageSender!)"
        messageTextView.text = message.messageText
    }
    func setBubbleTypeForRoomChat(type: messageType){
        if type == .incoming{
            chatStack.alignment = .leading
            userImage.isHidden = false
//            userNameLable.textColor = colors.randomElement()
            userNameLable.textColor = .darkText
            messageView.backgroundColor = .lightGray
            messageTextView.textColor = .black
        }else if type == .outgoing{
            userImage.isHidden = true
            userImage.image = UIImage()
            chatStack.alignment = .trailing
            userNameLable.text = "You"
            userNameLable.textColor = #colorLiteral(red: 0.1165452674, green: 0.4018504918, blue: 0.4115763307, alpha: 1)
            messageView.backgroundColor = #colorLiteral(red: 0.1165452674, green: 0.4018504918, blue: 0.4115763307, alpha: 1)
            messageTextView.textColor = .white
        }
    }
}
