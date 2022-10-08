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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yourChatsTableView.delegate = self
        yourChatsTableView.dataSource = self
        yourChatsTableView.register(UINib(nibName: RoomsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: RoomsTableViewCell.identifier)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        getUsersChats()
        
    }
    //MARK: - private func
    private func getUsersChats(){
        let ref = Database.database().reference()
        DispatchQueue.global().async {
            ref.child("users").observe(.value) {snapShot in
                if let dataArray = snapShot.value as? [String: Any]{
                    self.usersId.append(contentsOf: dataArray.keys)
                }
                self.getPrivateChatsIDs()
                self.observeChats()
            }
        }
    }
    private func getPrivateChatsIDs(){
        guard let currentUserID = Auth.auth().currentUser?.uid else{return}
        for id in usersId {
            let privateUserId = "\(currentUserID)To\(id)"
            self.privateUserIds.append(privateUserId)
        }
    }
    private func observeChats(){
        guard let currentID = Auth.auth().currentUser?.uid else{return}
        let ref = Database.database().reference()
        for id in privateUserIds {
            ref.child("privateChats").child(currentID).child(id).child("Reciver").observe(.value) { snapShot in
                if let name = snapShot.value as? String{
                    self.privateChat.append(name)
                }
                DispatchQueue.main.async {
                    self.yourChatsTableView.reloadWithAnimation()
                }
            }
        }
    }
    
}
//MARK: - UITableViewDelegate,UITableViewDataSource
extension YourChatsViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return privateChat.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoomsTableViewCell.identifier, for: indexPath)as? RoomsTableViewCell else{
            return UITableViewCell()
        }
        let selectedPrivateChat = privateChat[indexPath.row]
        //        let model = self.privateChat[indexPath.row]
        //        cell.configForPrivateChat(model: model)
        cell.roomChatName.text = selectedPrivateChat
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPrivateChat = privateChat[indexPath.row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "UserChatViewController")as! UserChatViewController
        controller.title = selectedPrivateChat
        self.navigationController?.pushViewController(controller, animated: true)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
    }
}

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
