//
//  UserChatViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 02/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserChatViewController: UIViewController {
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var userChatTableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var msgTextField: UITextField!
    //MARK: - vars
    var user: User? = nil
    var privateChat: PersonalChat?
    var messages = [PrivateChatMessage]()
    var privateChatID: String? = nil
    var chat: PrivateChat?
    
    //MARK: - life cycle
    //    var userTitle: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setDesign()
        userChatTableView.delegate = self
        userChatTableView.dataSource = self
        //        print(user?.name ?? "" , user?.id ?? "")
        //        print(self.privateChat)
        //        print(self.privateChatID!)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = .white
        observeMessage()
    }
    //MARK: - private functions
    private func setDesign(){
        msgView.addLayer(cornerRadius: 15, shadowColor: .gray, shadowOffsetWidth: 4, shadowOffsetHeight: 3, shadowOpacity: 0.5)
        sendBtn.addLayer(cornerRadius: 15, shadowColor: .gray, shadowOffsetWidth: 4, shadowOffsetHeight: 3, shadowOpacity: 0.5)
        
        msgTextField.changePlaceholderColor(text: "Type your message here.")
    }
    
    ///get user with id
    private func getUserWithId(_ id: String , completion: @escaping (_ userName: String?)-> Void){
        let ref = Database.database().reference()
        let user = ref.child("users").child(id)
        user.child("userName").observeSingleEvent(of: .value) { snapShot in
            if let userName = snapShot.value as? String{
                completion(userName)
            }else{
                completion(nil)
            }
        }
    }
    /// observe messages
    func observeMessage(){
        guard let privateChatName = chat?.chatId else{return}
        guard let currentUserId = Auth.auth().currentUser?.uid else{return}
        let ref = Database.database().reference()
        ref.child("privateChats").child(currentUserId).child(privateChatName).child("Chat").child("Messages").observe(.childAdded) { snapShot in
            if let dataArray = snapShot.value as? [String: Any]{
                guard let messageText = dataArray["Msg"]as? String,
                      let ReciverID = dataArray["ReciverID"]as? String,
                      let ReciverName = dataArray["ReciverName"]as? String ,
                      let SenderID = dataArray["SenderID"]as? String,
                      let SenderName = dataArray["SenderName"]as? String  else{return}
                
                let message = PrivateChatMessage( msg: messageText, reciverId: ReciverID, reciverName: ReciverName, senderId: SenderID, senderrName: SenderName)
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.userChatTableView.reloadData()
                }
            }
        }
    }
    private func sendMsg(completion: @escaping (Bool)->Void){
        guard let currentUserId = Auth.auth().currentUser?.uid , let reciverName = self.chat?.reciver,let reciverID = chat?.chatId.substring(from: String.Index(encodedOffset: 30)) else{return}
        print("reciver id is \(reciverID)")
        //        guard let privateChatName = self.privateChat?.chatID else{return}
        //         let privateChatName = "\(currentUserId)To\(user.id)"
        guard let privateChatName = self.chat?.chatId else{return}
        let ref = Database.database().reference()
        let message = ref.child("privateChats").child(currentUserId).child(privateChatName).child("Chat")
        getUserWithId(currentUserId) { userName in
            if let userName = userName , let msg = self.msgTextField.text , !msg.isEmpty {
                let dataArray: [String:Any] = ["SenderID":currentUserId,
                                               "SenderName":userName,
                                               "ReciverID":reciverID,
                                               "ReciverName":reciverName,
                                               "Msg":msg]
                message.child("Messages").childByAutoId().setValue(dataArray) { error, ref in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    //MARK: - Action
    @IBAction func sendMsgBtn(_ sender: UIButton) {
        sendMsg { success in
            if success{
                self.msgTextField.text = ""
                print("sended")
            }else{
                print("not send :(")
            }
        }
    }
}
//MARK: - UITableViewDelegate
extension UserChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath)as! ChatTableViewCell
        let message = messages[indexPath.row]
        cell.setMessageDataForPrivateChat(message: message)
        if message.senderId == Auth.auth().currentUser?.uid {
            cell.setBubbleType(type: .outgoing)
        }else{
            cell.setBubbleType(type: .incoming)
        }
        return cell
    }
}
