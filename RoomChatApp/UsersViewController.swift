//
//  UsersViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 29/09/2022.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class UsersViewController: UIViewController {
    
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var nodataImageView: UIImageView!
    @IBOutlet weak var usersSearchbar: UISearchBar!
    @IBOutlet weak var usersTableView: UITableView!
    
    let currentUserid = Auth.auth().currentUser?.uid
    var users = [User]()
    var filteredUsers: [User] = []
    
    
    var usersId = [String]()
    var privateChatID: String? = nil
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configData()
    }
    override func viewDidAppear(_ animated: Bool){
//        self.FilterChats()
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true
    }
    //MARK: - private function
    private func configData(){
        title = "Users"
//            self.getUsers()
          fetchUsers()
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersSearchbar.delegate = self
        
        nodataImageView.isHidden = true
        self.noDataLbl.isHidden = true
        usersTableView.isHidden = false
        
        usersTableView.register(UINib(nibName: UserTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: UserTableViewCell.identifier)
    }
    private func fetchUsers(){
        Database.database().reference().child("users").observe(.childAdded, with: { snapShot in
            print(snapShot)
            if let dictionary = snapShot.value as? [String:AnyObject] {
                if let email = dictionary["email"]as? String , let name = dictionary["name"]as?String{
                    let user = User(email: email, name: name)
                    self.users.append(user)
                    self.filteredUsers.append(user)
                    DispatchQueue.main.async {
                        self.usersTableView.reloadWithAnimation()
                    }
                }
            }
        }, withCancel: nil)
    }
//    private func getUsers(){
//        let ref = Database.database().reference()
//        ref.child("users").observe(.value) {snapshot in
//            if let dataArray = snapshot.value as? [String: Any]{
//                self.usersId.append(contentsOf: dataArray.keys)
//                if let index = self.usersId.firstIndex(of: self.currentUserid!){
//                    self.usersId.remove(at: index)
//                }
//                print(self.usersId)
//                self.getUsersNames()
//            }
//        }
//    }
//    private func getUsersNames(){
//        for id in usersId {
//            let ref = Database.database().reference()
//            ref.child("users").child(id).child("userName").observeSingleEvent(of: .value) { [weak self] snapShot in
//                if let userName = snapShot.value as? String {
//                    self?.users.append(User(name: userName, id: id))
//                    self?.filteredUsers.append(User(name: userName, id: id))
//                    DispatchQueue.main.async {
//                        self?.usersTableView.reloadWithAnimation()
//                    }
//                }
//            }
//        }
//    }
//    private func FilterChats(){
//        guard let currentUserId = Auth.auth().currentUser?.uid else{return}
//        let ref = Database.database().reference()
//        for id in usersId {
//            let chatName = "\(currentUserId)To\(id)"
//            ref.child("privateChats").child(currentUserId).child(chatName).observe(.value) { snapShot in
//                if let reciverUser = snapShot.value as? [String:Any]{
//                    print("exist")
//                    print(reciverUser.values)
//                    if let index:Int = self.filteredUsers.firstIndex(where: {$0.id == id}) {
//                        self.filteredUsers.remove(at: index)
//                        self.users.remove(at: index)
//                        DispatchQueue.main.async {
//                            self.usersTableView.reloadWithAnimation()
//                        }
//                    }
//                }
//            }
//        }
//        if users.count == 0 {
//            usersTableView.isHidden = true
//            nodataImageView.isHidden = false
//            self.noDataLbl.isHidden = false
//            UserDefaults.standard.set(true, forKey: "noUsers")
//        }else{
//            nodataImageView.isHidden = true
//            self.noDataLbl.isHidden = true
//            usersTableView.isHidden = false
//            UserDefaults.standard.set(false, forKey: "noUsers")
//        }
//    }
    private func createPrivateChat(reciverName: String,userId: String,completion: @escaping (Bool)->Void){
        guard let currentUserId = Auth.auth().currentUser?.uid else{return}
        let privateChatName = "\(currentUserId)To\(userId)"
        self.privateChatID = privateChatName
        let ref = Database.database().reference()
        // create child called "privateChats" to put the chats name we will create and give a random key
        let privateChats = ref.child("privateChats").child(currentUserId).child(privateChatName)
        let dataArray: [String:Any] = ["chatName" : privateChatName, "Reciver":reciverName]
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath)as? UserTableViewCell else{return UITableViewCell() }
        let user = filteredUsers[indexPath.row]
        cell.config(user: user)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let user = filteredUsers[indexPath.row]
        
//        createPrivateChat(reciverName: user.name,userId: user.id) { success in
//            if success {
//                print("successfuly created private chat :)")
//                let alert = UIAlertController(title: "Congratulations", message: "Your chat with name '\(user.name)' created Successfuly👌", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { _ in
//                    if let index:Int = self.filteredUsers.firstIndex(where: {$0.id == user.id}) {
//                        self.filteredUsers.remove(at: index)
//                        DispatchQueue.main.async {
//                            self.usersTableView.reloadData()
//                        }
//                    }
//                }))
//                self.present(alert, animated: true)
////                let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserChatViewController")as! UserChatViewController
////                controller.title = user.name
////                controller.user = user
////                controller.privateChatID = self.privateChatID
////                self.navigationController?.pushViewController(controller, animated: true)
////                self.navigationController?.navigationBar.prefersLargeTitles = false
//            }else{
//                print("error of creating chat :(")
//            }
//        }
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
            return model.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        usersTableView.reloadWithAnimation()
    }
}
