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
    
    @IBOutlet weak var usersTableView: UITableView!
    var users: [User] = []
    var usersId = [String]()
    let currentUserid = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Users"
        getUsers()
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    //MARK: - private func
    func getUsers(){
        let ref = Database.database().reference()
        ref.child("users").observe(.value) { snapshot in
            if let dataArray = snapshot.value as? [String: Any]{
                self.usersId.append(contentsOf: dataArray.keys)
                self.getUsersNames()
            }
        }
    }
    func getUsersNames(){
        for id in usersId {
            let ref = Database.database().reference()
            ref.child("users").child(id).child("userName").observeSingleEvent(of: .value) { [weak self] snapShot in
                if let userName = snapShot.value as? String {
                    self?.users.append(User(name: userName, id: id))
                    DispatchQueue.main.async {
                        self?.usersTableView.reloadWithAnimation()
                    }
                }
            }
        }
    }
}
extension UsersViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell")!
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
    
    
}
