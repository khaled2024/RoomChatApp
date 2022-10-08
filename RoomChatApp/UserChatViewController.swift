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
    var user: User? = nil
    //MARK: - vars
    var msgs: [Message] = [Message(messageKey: "khaled", messageSender: "khaled", messageText: "hello", userId: "ksksksk"),Message(messageKey: "You", messageSender: "You", messageText: "hi.!", userId: "ksksksk"),Message(messageKey: "khaled", messageSender: "khaled", messageText: "how are you?", userId: "ksksksk"),Message(messageKey: "khaled", messageSender: "You", messageText: "I am fine ty", userId: "ksksksk"),Message(messageKey: "khaled", messageSender: "khaled", messageText: "nice to meet you", userId: "ksksksk")]
    var userTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = userTitle
        setDesign()
        userChatTableView.delegate = self
        userChatTableView.dataSource = self
        print(user?.name ?? "" , user?.id ?? "")
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        
    }
    //MARK: - private functions
    func setDesign(){
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
    
    private func sendMsg(completion: @escaping (Bool)->Void){
        guard let currentUserId = Auth.auth().currentUser?.uid , let user = self.user else{return}
        let privateChatName = "\(currentUserId)To\(user.id)"
        let ref = Database.database().reference()
        let message = ref.child("privateChats").child(currentUserId).child(privateChatName).child("Chat")
        getUserWithId(currentUserId) { userName in
            if let userName = userName , let msg = self.msgTextField.text , !msg.isEmpty {
                let dataArray: [String:Any] = ["SenderID":currentUserId , "SenderName":userName,"ReciverID":user.id, "ReciverName":user.name, "Msg":msg]
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
        return msgs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath)as! ChatTableViewCell
        let message = msgs[indexPath.row]
        cell.setMessageData(message: message)
        if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 4){
            cell.setBubbleType(type: .outgoing)
        }else{
            cell.setBubbleType(type: .incoming)
        }
        return cell
    }
}
