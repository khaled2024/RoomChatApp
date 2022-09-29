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
    let currentUserid = Auth.auth().currentUser?.uid
    var users: [User] = []
    var usersId = [String]()
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
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell")!
        cell.textLabel?.text = users[indexPath.row].name
        cell.textLabel?.font = UIFont(name: "American Typewriter", size: 20)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
