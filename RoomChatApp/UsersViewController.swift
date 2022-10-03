//
//  UsersViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 29/09/2022.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import JGProgressHUD
class UsersViewController: UIViewController {
    
    @IBOutlet weak var nodataImageView: UIImageView!
    @IBOutlet weak var usersSearchbar: UISearchBar!
    @IBOutlet weak var usersTableView: UITableView!
    
    let currentUserid = Auth.auth().currentUser?.uid
    var users: [User] = []
    var filteredUsers: [User] = []
    var ristUsers: [User] = []
    var usersId = [String]()
    let spinner = JGProgressHUD(style: .dark)
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configData()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true
//        self.checkForUserExist()
    }
    override func viewDidAppear(_ animated: Bool){
        spinner.show(in: view)
        self.checkForUserExist()
//        print(self.usersId)
//        print(filteredUsers)
        self.FilterChats()
        self.spinner.dismiss(animated: true)
    }
    //MARK: - private function
    private func configData(){
        title = "Users"
        DispatchQueue.global().async {
            self.getUsers()
        }
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersSearchbar.delegate = self
        
        nodataImageView.isHidden = true
        usersTableView.isHidden = false
        
        usersTableView.register(UINib(nibName: RoomsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: RoomsTableViewCell.identifier)
    }
    private func FilterChats(){
        guard let currentUserId = Auth.auth().currentUser?.uid else{return}
        let ref = Database.database().reference()
        for id in usersId {
            let chatName = "\(currentUserId)To\(id)"
            ref.child("privateChats").child(currentUserId).child(chatName).observe(.value) { snapShot in
                if let reciverUser = snapShot.value as? [String:Any]{
                    print("exist")
                    print(reciverUser.values)
                    if let index:Int = self.filteredUsers.firstIndex(where: {$0.id == id}) {
                        self.filteredUsers.remove(at: index)
                        self.users.remove(at: index)
                        DispatchQueue.main.async {
                            self.usersTableView.reloadWithAnimation()
                        }
                    }
                }
            }
        }
    }
    private func checkForUserExist(){
        if self.filteredUsers.count == 0{
            usersTableView.isHidden = true
            nodataImageView.isHidden = false
            let alert = UIAlertController(title: "Error", message: "There is no Users to check your personal Chats", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            self.present(alert, animated: true)
        }
    }
    private func getUsers(){
        let ref = Database.database().reference()
        ref.child("users").observe(.value) {snapshot in
            if let dataArray = snapshot.value as? [String: Any]{
                self.usersId.append(contentsOf: dataArray.keys)
                if let index = self.usersId.firstIndex(of: self.currentUserid!){
                    self.usersId.remove(at: index)
                }
                self.getUsersNames()
            }
        }
    }
    private func getUsersNames(){
        for id in usersId {
            let ref = Database.database().reference()
            ref.child("users").child(id).child("userName").observeSingleEvent(of: .value) { [weak self] snapShot in
                if let userName = snapShot.value as? String {
                    self?.users.append(User(name: userName, id: id))
                    self?.filteredUsers.append(User(name: userName, id: id))
                    DispatchQueue.main.async {
                        self?.usersTableView.reloadWithAnimation()
                    }
                }
            }
        }
    }
    private func createPrivateChat(userId: String,completion: @escaping (Bool)->Void){
        guard let currentUserId = Auth.auth().currentUser?.uid else{return}
        let privateChatName = "\(currentUserId)To\(userId)"
        let ref = Database.database().reference()
        // create child called "privateChats" to put the chats name we will create and give a random key
        let privateChats = ref.child("privateChats").child(currentUserId).child(privateChatName)
        let dataArray: [String:Any] = ["chatName" : privateChatName]
        // here  set the value of new room name :)
        privateChats.setValue(dataArray) { error, ref in
            if error == nil {
                completion(true)
            }else{
                completion(false)
            }
        }
    }
}
//MARK: - UITableViewDelegate
extension UsersViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoomsTableViewCell.identifier, for: indexPath)as? RoomsTableViewCell else{return UITableViewCell() }
        let user = filteredUsers[indexPath.row]
        cell.configForUser(model: user)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = filteredUsers[indexPath.row]
        createPrivateChat(userId: user.id) { success in
            if success {
                print("successfuly created private chat :)")
                if let index:Int = self.filteredUsers.firstIndex(where: {$0.id == user.id}) {
                    self.filteredUsers.remove(at: index)
                    DispatchQueue.main.async {
                        self.usersTableView.reloadData()
                    }
                }
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserChatViewController")as! UserChatViewController
                controller.userTitle = user.name
                controller.user = user
                self.navigationController?.pushViewController(controller, animated: true)
                self.navigationController?.navigationBar.prefersLargeTitles = false
            }else{
                print("error of creating chat :(")
            }
        }
    }
}
//MARK: - searchbar
extension UsersViewController: UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        self.filteredUsers = self.users
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredUsers = searchText.isEmpty ? users : users.filter({ model in
            return model.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        usersTableView.reloadData()
    }
}
//MARK: - comments
//private func isChatExist(userId: String , completion: @escaping (Bool)->Void){
//    guard let currentUserId = Auth.auth().currentUser?.uid else{return}
//    let chatName = "\(currentUserId)To\(userId)"
//    let ref = Database.database().reference()
//    ref.child("privateChats").child(currentUserId).child(chatName).child("chatName").observeSingleEvent(of: .value) { snapShot in
//        if let privateChatName = snapShot.value as? String {
//            print("privateChatName\(privateChatName)")
//            //                if privateChatName == chatName{
//            //                    completion(true)
//            //                }else{
//            //                    completion(false)
//            //                }
//            completion(true)
//        }
//        else{
//            if let index:Int = self.users.firstIndex(where: {$0.id == userId}) {
//                self.users.remove(at: index)
//                DispatchQueue.main.async {
//                    self.usersTableView.reloadData()
//                }
//            }
//            completion(false)
//        }
//    }
//}
//private func checkForMessageExist(userId: String,completion:@escaping (Bool)->Void){
//    guard let currentUserId = Auth.auth().currentUser?.uid else{return}
//    let chatName = "\(currentUserId)To\(userId)"
//    let ref = Database.database().reference()
//    ref.child("privateChats").child(currentUserId).child(chatName).child("chatName").child("Messages").observeSingleEvent(of: .value) { snapShot in
//        if let messages = snapShot.value as? [String:Any] {
//            print(messages)
//            completion(true)
//        }else{
//            completion(false)
//        }
//    }
//}
