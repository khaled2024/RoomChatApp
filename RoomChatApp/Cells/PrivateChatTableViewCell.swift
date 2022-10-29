//
//  PrivateChatTableViewCell.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 26/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import AVFoundation

enum messageType {
    case incoming
    case outgoing
}
class PrivateChatTableViewCell: UITableViewCell {
    //MARK: - vars& outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var chatStack: UIStackView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var userNameLable: UILabel!
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var messageTextWidth: NSLayoutConstraint!
    @IBOutlet weak var messageViewWidth: NSLayoutConstraint!
    
    var userChatVC: UserChatViewController?
    var message: Message?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    static let identifier = String(describing: PrivateChatTableViewCell.self)
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = self.userImage.frame.size.height/2
        messageTextView.isEditable = false
        messageImage.isUserInteractionEnabled = true
        // add target for
        messageImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomImage)))
        playBtn.addTarget(self, action: #selector(handlePlayBtn), for: .touchUpInside)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    //MARK: - private func & objc func
    @objc func handlePlayBtn(){
        print("play")
        if let message = message,
           let messageURl = message.videoURL,
           let videoURL = URL(string: messageURl) {
            player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = messageView.bounds
            self.messageView.layer.addSublayer(playerLayer!)
            player?.play()
        }
    }
    @objc func handleZoomImage(tapGesture: UITapGestureRecognizer){
        print("zoom image")
        // dont perform a lot of login inside view class
        if message?.videoURL != nil{
            return
        }
        if let imageView = tapGesture.view as? UIImageView{
            userChatVC?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    func setMessageDataForPrivateChat(message: Message){
        guard let currentId = Auth.auth().currentUser?.uid else{return}
        
        if message.fromId == currentId {
            setBubbleType(type: .outgoing)
            userNameLable.text = "You"
        }else{
            setBubbleType(type: .incoming)
            guard let chatPartnerID = message.chatPartnerId() else{return}
            Database.database().reference().child("users").child(chatPartnerID).observeSingleEvent(of: .value) { snapShat in
                if let value = snapShat.value as?[String:Any],let name = value["name"]as? String{
                    DispatchQueue.main.async {
                        self.userNameLable.text = name
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
