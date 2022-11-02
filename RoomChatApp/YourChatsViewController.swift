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
    //MARK: - Vars
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    var timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        yourChatsTableView.allowsMultipleSelectionDuringEditing = true
        
        yourChatsTableView.delegate = self
        yourChatsTableView.dataSource = self
        yourChatsTableView.register(UINib(nibName: PrivateChatUserTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: PrivateChatUserTableViewCell.identifier)
        observeUserMessages()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    //MARK: - private func
    private func observeUserMessages(){
        guard let currentUserId = Auth.auth().currentUser?.uid else{return}
        let ref = Database.database().reference().child("user-messages").child(currentUserId)
        ref.observe(.childAdded, with: { snapShot in
            let userID = snapShot.key
            Database.database().reference().child("user-messages").child(currentUserId).child(userID).observe(.childAdded, with: { snapShot in
                let messageID = snapShot.key
                self.fetchMessagesFrom(messageID: messageID)
            }, withCancel: nil)
        }, withCancel: nil)
        // for remove
        ref.observe(.childRemoved, with: { snapShot in
            self.messagesDictionary.removeValue(forKey: snapShot.key)
            self.attempReloadData()
        }, withCancel: nil)
    }
    private func fetchMessagesFrom(messageID: String){
        let messageRef = Database.database().reference().child("messages").child(messageID)
        messageRef.observeSingleEvent(of: .value) {[weak self] snapShot in
            print(snapShot)
            if let dictionary = snapShot.value as? [String:Any]{
                if let fromId = dictionary["fromId"]as? String , let text = dictionary["text"]as? String , let timeStamp = dictionary["timeStamp"]as? NSNumber,let toId = dictionary["toId"]as? String{
                    let message = Message(fromId: fromId, text: text, timeStamp: timeStamp, toId: toId)
                    
                    // here create a dic of id of the user we create a chat with ans the message that sended to him
                    if let chatPartnerID = message.chatPartnerId(){
                        self?.messagesDictionary[chatPartnerID] = message
                    }
                    // to reload data
                    self?.attempReloadData()
                }else if let fromId = dictionary["fromId"]as? String , let imageURL = dictionary["imageURL"]as? String , let timeStamp = dictionary["timeStamp"]as? NSNumber,let toId = dictionary["toId"]as? String,let imageWidth = dictionary["imageWidth"]as? NSNumber,let imageHeight = dictionary["imageHeight"]as? NSNumber{
                    let message = Message(fromId: fromId, timeStamp: timeStamp, toId: toId,messageImageURL: imageURL,imageWidth: imageWidth,imageHeight: imageHeight)
                    // here create a dic of id of the user we create a chat with ans the message that sended to him
                    if let chatPartnerID = message.chatPartnerId(){
                        self?.messagesDictionary[chatPartnerID] = message
                    }
                    // to reload data
                    self?.attempReloadData()
                }
            }
        }
    }
    @objc func handlereloadTable(){
        self.messages = Array(self.messagesDictionary.values)
        // sort by time stamp
        self.messages.sort(by: { msg1, msg2 in
            return  msg1.timeStamp!.intValue > msg2.timeStamp!.intValue
        })
        DispatchQueue.main.async {
            self.yourChatsTableView.reloadData()
        }
    }
    private func attempReloadData(){
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handlereloadTable), userInfo: nil, repeats: false)
    }
    private func observeMessage(){
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { [weak self] snapShot in
            if let dictionary = snapShot.value as? [String:Any]{
                if let fromId = dictionary["fromId"]as? String , let text = dictionary["text"]as? String , let timeStamp = dictionary["timeStamp"]as? NSNumber,let toId = dictionary["toId"]as? String{
                    let message = Message(fromId: fromId, text: text, timeStamp: timeStamp, toId: toId)
                    // here create a dic of id of the user we create a chat with ans the message that sended to him
                    if let toID = message.toId {
                        self?.messagesDictionary[toID] = message
                        if let messagesValues = self?.messagesDictionary.values{
                            self?.messages = Array(messagesValues)
                            // sort by time stamp
                            self?.messages.sort(by: { msg1, msg2 in
                                return  msg1.timeStamp!.intValue > msg2.timeStamp!.intValue
                            })
                        }
                    }
                    DispatchQueue.main.async {
                        self?.yourChatsTableView.reloadData()
                    }
                }
            }
        }, withCancel: nil)
    }
    //MARK: - Actions
    @IBAction func newFriendBtnTapped(_ sender: UIBarButtonItem) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "UsersViewController")as! UsersViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
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
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("tapped")
        let controller = storyboard?.instantiateViewController(withIdentifier: "UserChatViewController")as! UserChatViewController
        self.navigationController?.pushViewController(controller, animated: true)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else{return}
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { snapShot in
            print(snapShot)
            guard let dictinary = snapShot.value as? [String:AnyHashable]else{return}
            let user = User(id: chatPartnerId, email: dictinary["email"]as? String, name: dictinary["name"]as? String, profileImageURL: dictinary["profileImageURL"]as? String)
            controller.user = user
        }, withCancel: nil)
    }
    // editing cell
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            guard let uid = Auth.auth().currentUser?.uid else{return}
            let message = self.messages[indexPath.row]
            if let chatPartner = message.chatPartnerId(){
                Database.database().reference().child("user-messages").child(uid).child(chatPartner).removeValue { error, ref in
                    if error != nil{
                        print(error ?? "error for deleting row")
                        return
                    }
                    // this s the correct way
                    self.messagesDictionary.removeValue(forKey: chatPartner)
                    self.attempReloadData()
                    
                    // this is one way to delete but not safe ...
                    //     self.messages.remove(at: indexPath.row)
                    //     self.yourChatsTableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeConfiguration
    }
    
}
