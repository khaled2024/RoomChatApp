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
    
    @IBOutlet weak var messageTextWidth: NSLayoutConstraint!
    @IBOutlet weak var messageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var chatStack: UIStackView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var userNameLable: UILabel!
    var roomChatVC: ChatViewController?
    
    static let identifier = String(describing: ChatTableViewCell.self)
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = self.userImage.frame.size.height/2
        messageImageView.isUserInteractionEnabled = true
        // add target for
        messageImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomImage)))
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @objc func handleZoomImage(tapGesture: UITapGestureRecognizer){
        print("zoom image")
        // dont perform a lot of login inside view class
        if let imageView = tapGesture.view as? UIImageView{
            roomChatVC?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    func setMessageData(message: RoomMessage){
        if let userImage = message.userImage {
            self.userImage.loadDataUsingCacheWithUrlString(urlString: userImage)
        }
        if message.userId == Auth.auth().currentUser?.uid {
            setBubbleTypeForRoomChat(type: .outgoing)
        }else{
            setBubbleTypeForRoomChat(type: .incoming)
            userNameLable.text = " \(message.messageSender!)"
        }
        if let messageImageURL = message.messageImageURL {
            self.messageImageView.loadDataUsingCacheWithUrlString(urlString: messageImageURL)
            messageImageView.isHidden = false
            messageView.backgroundColor = UIColor.white
        }else{
            messageImageView.isHidden = true
            messageTextView.text = message.messageText
        }
        
    }
    func setBubbleTypeForRoomChat(type: messageType){
        if type == .incoming{
            chatStack.alignment = .leading
            userImage.isHidden = false
//    userNameLable.textColor = colors.randomElement()
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
