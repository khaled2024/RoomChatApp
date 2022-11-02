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
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = false
    }
    //MARK: - private function
    private func configData(){
        title = "Users"
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
                if let email = dictionary["email"]as? String , let name = dictionary["name"]as?String , let imageURL = dictionary["profileImageURL"]as? String{
                    let toId = snapShot.key
                    let user = User(id: toId,email: email, name: name,profileImageURL: imageURL)
                    self.users.append(user)
                    self.filteredUsers.append(user)
                    DispatchQueue.main.async {
                        self.usersTableView.reloadData()
                    }
                }
            }
        }, withCancel: nil)
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
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserChatViewController")as! UserChatViewController
        let user = self.users[indexPath.row]
        controller.user = user
        controller.modalTransitionStyle = .flipHorizontal
        self.navigationController?.pushViewController(controller, animated: true)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
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
