//
//  YourChatsViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 02/10/2022.

import UIKit
import FirebaseAuth
import FirebaseDatabase

class YourChatsViewController: UIViewController {
    
    @IBOutlet weak var yourChatsTableView: UITableView!
    var usersId = [String]()
    var privateChat = [String]()
    var privateUserIds = [String]()
    var myChats = [PrivateChat]()
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yourChatsTableView.delegate = self
        yourChatsTableView.dataSource = self
        yourChatsTableView.register(UINib(nibName: PrivateChatUserTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: PrivateChatUserTableViewCell.identifier)
//        getUsersChats()
//        getPrivateChats()
        observeMessage()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewDidDisappear(_ animated: Bool) {
//        self.myChats = []
    }
    //MARK: - private func
    private func observeMessage(){
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { [weak self] snapShot in
            if let dictionary = snapShot.value as? [String:Any]{
                if let fromId = dictionary["fromId"]as? String , let text = dictionary["text"]as? String , let timeStamp = dictionary["timeStamp"]as? NSNumber,let toId = dictionary["toId"]as? String{
                    let message = Message(fromId: fromId, text: text, timeStamp: timeStamp, toId: toId)
//                    self?.messages.append(message)
                    // here create a dic of id of the user we create a chat with ans the message that sended to him
                    self?.messagesDictionary[toId] = message
                    if let messagesValues = self?.messagesDictionary.values{
                        self?.messages = Array(messagesValues)
                        print(messagesValues)
                        // sort by time stamp
                        self?.messages.sort(by: { msg1, msg2 in
                            return  msg1.timeStamp!.intValue > msg2.timeStamp!.intValue
                        })
                    }
                    DispatchQueue.main.async {
                        self?.yourChatsTableView.reloadData()
                    }
                }
            }
        }, withCancel: nil)
    }
    
//    private func getUsersChats(){
//        let ref = Database.database().reference()
//        DispatchQueue.global().async {
//            ref.child("users").observe(.value) {snapShot in
//                if let dataArray = snapShot.value as? [String: Any]{
//                    self.usersId.append(contentsOf: dataArray.keys)
//                }
//                self.getPrivateChatsIDs()
//                self.observeChats()
////                self.getMessage()
//            }
//        }
//    }
//    private func getPrivateChatsIDs(){
//        guard let currentUserID = Auth.auth().currentUser?.uid else{return}
//        for id in usersId {
//            let privateUserId = "\(currentUserID)To\(id)"
//            self.privateUserIds.append(privateUserId)
//        }
//    }
//    private func observeChats(){
//        guard let currentID = Auth.auth().currentUser?.uid else{return}
//        for id in privateUserIds {
//            let ref = Database.database().reference().child("privateChats").child(currentID).child(id).child("chatName")
//            ref.observe(.value) { snapShot in
//                if let snap = snapShot.value as? String{
//                    print(snap)
//                }
//            }
//        }
//    }
//    private func getMessage(){
//        guard let currentID = Auth.auth().currentUser?.uid else{return}
//        let ref = Database.database().reference()
//        for id in privateUserIds {
//            ref.child("privateChats").child(currentID).child(id).child("Chat").child("Messages").observe(.value) { snapShot in
//                if let msg = snapShot.value as? [String:Any]{
//                   print(msg)
//                }
//            }
//        }
//    }
    
//    private func getUserIDChat(){
//        guard let currentID = Auth.auth().currentUser?.uid else{return}
//        let ref = Database.database().reference().child("privateChats").child(currentID).observe(.value) { snapShot in
//            if let cha
//        }
//    }
    
//    private func getPrivateChats(){
//        guard let currentID = Auth.auth().currentUser?.uid else{return}
//        DispatchQueue.global().async {
//            let ref = Database.database().reference().child("privateChats").child(currentID)
//            ref.observe(.childAdded) { snapShot in
//                if let dataArray = snapShot.value as? [String:Any]{
//                    if let chatName = dataArray["chatName"]as? String , let reciver = dataArray["Reciver"]as? String{
//                        let chat = PrivateChat(chatId: snapShot.key, chatName: chatName, reciver: reciver)
//                        self.myChats.append(chat)
//                    }
//                }
//                DispatchQueue.main.async {
//                    self.yourChatsTableView.reloadWithAnimation()
//                }
//            }
//        }
//    }
//    func getMoreChats(){
//        guard let currentID = Auth.auth().currentUser?.uid else{return}
//        let ref = Database.database().reference().child("privateChats").child(currentID)
//    }
}
//MARK: - UITableViewDelegate,UITableViewDataSource
extension YourChatsViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PrivateChatUserTableViewCell.identifier, for: indexPath)as? PrivateChatUserTableViewCell else{
            return UITableViewCell()
        }
        let message = messages[indexPath.row]
        cell.message = message
        
//        let selectedPrivateChat = privateChat[indexPath.row]
//        print(selectedPrivateChat)
        
        //        let model = self.privateChat[indexPath.row]
        //        cell.configForPrivateChat(model: model)
//        let selectedPrivateChat = myChats[indexPath.row].reciver
//        cell.roomChatName.text = selectedPrivateChat
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let selectedPrivateChat = myChats[indexPath.row]
        print("tapped")
        let controller = storyboard?.instantiateViewController(withIdentifier: "UserChatViewController")as! UserChatViewController
//        controller.title = selectedPrivateChat.reciver
//        controller.chat = selectedPrivateChat
        self.navigationController?.pushViewController(controller, animated: true)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
    }
}
//MARK: - Comments
//let ref = Database.database().reference().child("privateChats").child(currentUserID).child(privateUserId).child("Chat").child("Messages")
//ref.observe(.value) { [weak self] snapShot in
//    for snap in snapShot.children {
//        let recipeSnap = snap as! DataSnapshot
//        let recipeID = recipeSnap.key
//        let dict = recipeSnap.value as! [String:AnyObject]
//        let msg = dict["Msg"] as! String
//        let ReciverID = dict["ReciverID"] as! String
//        let ReciverName = dict["ReciverName"] as! String
//        let SenderID = dict["SenderID"] as! String
//        let SenderName = dict["SenderName"] as! String
//        print("key = \(recipeID) - msg = \(msg) - ReciverID = \(ReciverID) - ReciverName = \(ReciverName) - SenderID =  \(SenderID) - SenderName = \(SenderName)")
//        self?.privateChat.append(PersonalChat(chatID: privateUserId, msg: msg, reciverId: ReciverID, reciverName: ReciverName, senderId: SenderID, senderrName: SenderName))
//        print(self!.privateChat)
//        DispatchQueue.main.async {
//            self?.yourChatsTableView.reloadWithAnimation()
//        }
//    }
//}
