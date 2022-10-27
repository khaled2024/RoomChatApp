//
//  PrivateChatTableViewCell.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 26/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

enum messageType {
    case incoming
    case outgoing
    
}
class PrivateChatTableViewCell: UITableViewCell {
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var chatStack: UIStackView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var userNameLable: UILabel!
    
    @IBOutlet weak var messageTextWidth: NSLayoutConstraint!
    @IBOutlet weak var messageViewWidth: NSLayoutConstraint!
    
    static let identifier = String(describing: PrivateChatTableViewCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.layer.cornerRadius = 7
        messageImage.layer.cornerRadius = 20
        userImage.layer.cornerRadius = self.userImage.frame.size.height/2
        messageText.isEditable = false
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func setMessageDataForPrivateChat(message: Message){
        guard let currentId = Auth.auth().currentUser?.uid else{return}
        if message.fromId == currentId {
            setBubbleType(type: .outgoing)
            userNameLable.text = "You"
            messageTextView.text = message.text
        }else{
            setBubbleType(type: .incoming)
            guard let chatPartnerID = message.chatPartnerId() else{return}
            Database.database().reference().child("users").child(chatPartnerID).observeSingleEvent(of: .value) { snapShat in
                if let value = snapShat.value as?[String:Any],let name = value["name"]as? String{
                    DispatchQueue.main.async {
                        self.userNameLable.text = name
                        self.messageTextView.text = message.text
                    }
                }
            }
        }
        if let messageImageURL = message.messageImageURL {
            self.messageImage.loadDataUsingCacheWithUrlString(urlString: messageImageURL)
            messageImage.isHidden = false
            messageView.backgroundColor = UIColor.clear
        }else{
            messageImage.isHidden = true
        }

    }
    func setBubbleType(type: messageType){
        if type == .incoming{
            userImage.isHidden = false
            chatStack.alignment = .leading
            userNameLable.textColor = .darkGray
            messageView.backgroundColor = .lightGray
            messageTextView.textColor = .black
        }else if type == .outgoing{
            chatStack.alignment = .trailing
            userNameLable.text = "You"
            userImage.isHidden = true
            userNameLable.textColor = #colorLiteral(red: 0.1165452674, green: 0.4018504918, blue: 0.4115763307, alpha: 1)
            messageView.backgroundColor = #colorLiteral(red: 0.1165452674, green: 0.4018504918, blue: 0.4115763307, alpha: 1)
            messageTextView.textColor = .white
        }
    }
}
