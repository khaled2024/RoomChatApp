//
//  ChatTableViewCell.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 25/09/2022.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    enum messageType {
        case incoming
        case outgoing
    
    }
    @IBOutlet weak var chatStack: UIStackView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var userNameLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.layer.cornerRadius = 7
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

    func setMessageData(message: Message){
        userNameLable.text = " \(message.messageSender!)"
        messageTextView.text = message.messageText
    }
    func setBubbleType(type: messageType){
        if type == .incoming{
            chatStack.alignment = .leading
            userNameLable.textColor = .darkGray
            messageView.backgroundColor = .lightGray
            messageTextView.textColor = .black
        }else if type == .outgoing{
            chatStack.alignment = .trailing
            messageView.backgroundColor = #colorLiteral(red: 0.1165452674, green: 0.4018504918, blue: 0.4115763307, alpha: 1)
            messageTextView.textColor = .white
        }
    }
}