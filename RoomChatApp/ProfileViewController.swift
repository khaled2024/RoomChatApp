//
//  ProfileViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 25/09/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileTableView: UITableView!
    private var userName: String = ""
    private var email: String = ""
    private var sections = [Setting]()
    override func viewDidLoad() {
        super.viewDidLoad()
        configSetting()
        profileTableView.delegate = self
        profileTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
        configUserName()
    }
    
    //MARK: - Private functions
    private func configSetting(){
        //profile
        sections.append(Setting(title: "Profile", option: [Option(title: "View your profile", handler: { [weak self] in
            self?.showProfileName()
        })]))
        //account (sign out)
        sections.append(Setting(title: "Account", option: [Option(title: "Sign out", handler: { [weak self] in
            self?.signOutTapped()
        })]))
    }
    private func configUserName(){
        let ref = Database.database().reference()
        if let id = Auth.auth().currentUser?.uid { ref.child("users").child(id).observeSingleEvent(of: .value) { snapShot in
            if let dataArray = snapShot.value as? [String:Any] , let name = dataArray["name"]as? String , let email = dataArray["email"]as? String{
                self.userName = name
                self.email = email
            }
        }
        }
    }
    private func showProfileName(){
        let alert = UIAlertController(title: "Profile", message: "Name: \(self.userName)🧟‍♂️ \n Email: \(self.email)✉️", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    private func signOutTapped(){
        // sign out
        print("signOut")
        let alert = UIAlertController(title: "SignOut", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: { _ in
            try! Auth.auth().signOut()
            self.presentAuthScreen()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func presentAuthScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AuthViewController")as! AuthViewController
        controller.modalTransitionStyle = .flipHorizontal
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
        print("exit")
    }
    
}

//MARK: - tableView delegate
extension ProfileViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].option.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell") as! ProfileTableViewCell
        let model = sections[indexPath.section].option[indexPath.row]
        cell.textLabel?.text = model.title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].option[indexPath.row]
        model.handler()
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = sections[section]
        return model.title
    }
    
}
