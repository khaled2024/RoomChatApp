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
    
    @IBOutlet weak var usersSearchbar: UISearchBar!
    @IBOutlet weak var usersTableView: UITableView!
    let currentUserid = Auth.auth().currentUser?.uid
    var users: [User] = []
    var filteredUsers: [User] = []
    var usersId = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Users"
        DispatchQueue.global().async {
            self.getUsers()
        }
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersSearchbar.delegate = self
        
        usersTableView.register(UINib(nibName: RoomsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: RoomsTableViewCell.identifier)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
        
        tabBarController?.tabBar.isHidden = true
    }
    //MARK: - private func
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
        let controller = storyboard?.instantiateViewController(withIdentifier: "UserChatViewController")as! UserChatViewController
        let user = filteredUsers[indexPath.row]
        controller.userTitle = user.name
        navigationController?.pushViewController(controller, animated: true)
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
        print("tapped")
        self.filteredUsers = searchText.isEmpty ? users : users.filter({ model in
            return model.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        usersTableView.reloadData()
    }
}
