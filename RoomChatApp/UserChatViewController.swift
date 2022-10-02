//
//  UserChatViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 02/10/2022.
//

import UIKit

class UserChatViewController: UIViewController {
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var userChatTableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var msgTextField: UITextField!
    //MARK: - vars
    var msgs: [Message] = [Message(messageKey: "khaled", messageSender: "khaled", messageText: "hello", userId: "ksksksk"),Message(messageKey: "You", messageSender: "You", messageText: "hi.!", userId: "ksksksk"),Message(messageKey: "khaled", messageSender: "khaled", messageText: "how are you?", userId: "ksksksk"),Message(messageKey: "khaled", messageSender: "You", messageText: "I am fine ty", userId: "ksksksk"),Message(messageKey: "khaled", messageSender: "khaled", messageText: "nice to meet you", userId: "ksksksk")]
    var userTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = userTitle
        setDesign()
        userChatTableView.delegate = self
        userChatTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    //MARK: - private functions
    func setDesign(){
        msgView.addLayer(cornerRadius: 15, shadowColor: .gray, shadowOffsetWidth: 4, shadowOffsetHeight: 3, shadowOpacity: 0.5)
        sendBtn.addLayer(cornerRadius: 15, shadowColor: .gray, shadowOffsetWidth: 4, shadowOffsetHeight: 3, shadowOpacity: 0.5)
    }
    //MARK: - Action
    @IBAction func sendMsgBtn(_ sender: UIButton) {
        
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
