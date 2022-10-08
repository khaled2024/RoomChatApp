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
    var privateChat = [PersonalChat]()
    var privateUserIds = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yourChatsTableView.delegate = self
        yourChatsTableView.dataSource = self
        yourChatsTableView.register(UINib(nibName: RoomsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: RoomsTableViewCell.identifier)
        getUsersChats()
    }
    //MARK: - private func
    private func getUsersChats(){
        let ref = Database.database().reference()
        ref.child("users").observe(.value) {snapShot in
            if let dataArray = snapShot.value as? [String: Any]{
                self.usersId.append(contentsOf: dataArray.keys)
                print(self.usersId)
            }
            self.getPrivateChatsIDs()
            self.getPrivateChats()
        }
    }
    private func getPrivateChatsIDs(){
        guard let currentUserID = Auth.auth().currentUser?.uid else{return}
        for id in usersId {
            let privateUserId = "\(currentUserID)To\(id)"
            self.privateUserIds.append(privateUserId)
            print(self.privateUserIds)
        }
    }
    private func getPrivateChats(){
        guard let currentUserID = Auth.auth().currentUser?.uid else{return}
        for privateUserId in privateUserIds {
            let ref = Database.database().reference().child("privateChats").child(currentUserID).child(privateUserId).child("Chat").child("Messages")
            ref.observeSingleEvent(of: .value) { [weak self] snapShot in
                for snap in snapShot.children {
                    let recipeSnap = snap as! DataSnapshot
                    let recipeID = recipeSnap.key
                    let dict = recipeSnap.value as! [String:AnyObject]
                    let msg = dict["Msg"] as! String
                    let ReciverID = dict["ReciverID"] as! String
                    let ReciverName = dict["ReciverName"] as! String
                    let SenderID = dict["SenderID"] as! String
                    let SenderName = dict["SenderName"] as! String
                    print("key = \(recipeID) - msg = \(msg) - ReciverID = \(ReciverID) - ReciverName = \(ReciverName) - SenderID =  \(SenderID) - SenderName = \(SenderName)")
                    self?.privateChat.append(PersonalChat(msg: msg, reciverId: ReciverID, reciverName: ReciverName, senderId: SenderID, senderrName: SenderName))
                    print(ReciverName)
                    DispatchQueue.main.async {
                        self?.yourChatsTableView.reloadWithAnimation()
                    }
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
        let model = self.privateChat[indexPath.row]
        cell.configForPrivateChat(model: model)
        return cell
    }
}
