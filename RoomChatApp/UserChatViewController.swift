//
//  UserChatViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 02/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class UserChatViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var userChatTableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var msgTextField: UITextField!
    //MARK: - vars
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            observeMessage()
        }
    }
    var messages = [Message]()
    
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDesign()
        userChatTableView.delegate = self
        userChatTableView.dataSource = self
        self.msgTextField.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = .white
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
        guard let currentid = Auth.auth().currentUser?.uid, let toID = user?.id else{return}
        let ref = Database.database().reference().child("user-messages").child(currentid).child(toID)
        ref.observe(.childAdded, with: { snapShot in
            print(snapShot)
            let messageID = snapShot.key
            let messageRef = Database.database().reference().child("messages").child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { snapShot in
                print(snapShot)
                guard let dictinary = snapShot.value as? [String:Any] else{return}
                let message = Message(fromId: dictinary["fromId"]as? String,
                                      text: dictinary["text"]as? String,
                                      timeStamp: dictinary["timeStamp"]as? NSNumber,
                                      toId: dictinary["toId"]as? String)
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.userChatTableView.reloadData()
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    /// send message
    private func sendMsg(){
        let ref = Database.database().reference().child("messages")
        let refChild = ref.childByAutoId()
        if let text = self.msgTextField.text , text.isEmpty == false, let user = user, let toId = user.id, let fromId = Auth.auth().currentUser?.uid{
            let timeStamp: NSNumber = NSDate().timeIntervalSince1970 as NSNumber
            if let values = ["text": text,
                             "toId": toId,
                             "fromId":fromId,
                             "timeStamp":timeStamp] as? [AnyHashable : Any]{
                refChild.updateChildValues(values) { error, ref in
                    if  error != nil{
                        print(error ?? "error for update child ref of messages")
                        print("didnt send")
                        return
                    }
                    let messagesID = refChild.key
                    let values = [messagesID:1]as? [AnyHashable:Any]
                    // for user-messages
                    let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
                    userMessagesRef.updateChildValues(values!)
                    // for recipent-messages
                    let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
                    recipientUserMessagesRef.updateChildValues(values!)
                    self.msgTextField.text = ""
                    print("sended")
                }
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMsg()
        return true
    }
    //MARK: - Action
    @IBAction func sendMsgBtn(_ sender: UIButton) {
        sendMsg()
    }
}
//MARK: - UITableViewDelegate
extension UserChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PrivateChatTableViewCell.identifier, for: indexPath)as! PrivateChatTableViewCell
        let message = messages[indexPath.row]
        cell.setMessageDataForPrivateChat(message: message)
        cell.messageTextView.text = message.text
        return cell
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.userChatTableView.invalidateIntrinsicContentSize()
    }
}
//MARK: - Comments
// private chats :)
