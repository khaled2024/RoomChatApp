//
//  ChatViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 25/09/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class ChatViewController: UIViewController {
    //MARK: - Vars & Outlets
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTF: UITextField!
    var room: Room?
    var chatMessages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = room?.roomName
        observeMessage()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.allowsSelection = false
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    //MARK: -  functions
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
    /// send message
    private func sendMessage(text: String , completion:@escaping (_ isSuccess: Bool) -> Void){
        guard let userId = Auth.auth().currentUser?.uid else{
            return
        }
        let ref = Database.database().reference()
        getUserWithId(userId) { userName in
            if let userName = userName{
                if let roomId = self.room?.roomId , let senderId = Auth.auth().currentUser?.uid{
                    let dataArray:[String:Any] = ["senderName":userName , "text": text , "senderId": senderId]
                    let room = ref.child("rooms").child(roomId)
                    room.child("messages").childByAutoId().setValue(dataArray) { error, ref in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    /// observe messages
    func observeMessage(){
        guard let roomId = room?.roomId else{return}
        let ref = Database.database().reference()
        ref.child("rooms").child(roomId).child("messages").observe(.childAdded) { snapShot in
            if let dataArray = snapShot.value as? [String: Any]{
                guard let senderName = dataArray["senderName"]as? String , let messageText = dataArray["text"]as? String, let userId = dataArray["senderId"]as? String else{return}
                let message = Message(messageKey: snapShot.key, messageSender: senderName, messageText: messageText,userId: userId)
                self.chatMessages.append(message)
                DispatchQueue.main.async {
                    self.chatTableView.reloadData()
                }
            }
        }
        
        
        
    }
    //MARK: - actions
    @IBAction func sendBtnTapped(_ sender: UIButton) {
        guard let message = messageTF.text , !message.isEmpty else{
            print("please field TF.!")
            return
        }
        sendMessage(text: message, completion: { isSuccess in
            if isSuccess{
                self.messageTF.text = ""
                print("message added to database successfuly:)")
            }else{
                print("error for sending message:(")
            }
        })
    }
}
//MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = chatMessages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell")as! ChatTableViewCell
        cell.setMessageData(message: message)
        if message.userId == Auth.auth().currentUser?.uid {
            cell.setBubbleType(type: .outgoing)
        }else{
            cell.setBubbleType(type: .incoming)
        }
        
        return cell
    }
    
    
}
