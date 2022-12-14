//
//  ProfileViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 25/09/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import JGProgressHUD

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var profileTableView: UITableView!
    private var userName: String = ""
    private var email: String = ""
    private var sections = [Setting]()
    var isInteractionEnabled: Bool = false
    let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configSetting()
        profileTableView.delegate = self
        profileTableView.dataSource = self
        self.userProfile.layer.cornerRadius = userProfile.frame.size.height/2
        updataProfileImage()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
        configUserData()
        self.userProfile.isUserInteractionEnabled = false
        self.userProfile.layer.borderColor = UIColor.clear.cgColor
        self.userProfile.layer.borderWidth = 0
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
    private func configUserData(){
        let ref = Database.database().reference()
        if let id = Auth.auth().currentUser?.uid { ref.child("users").child(id).observeSingleEvent(of: .value) { snapShot in
            if let dataArray = snapShot.value as? [String:Any] , let name = dataArray["name"]as? String , let email = dataArray["email"]as? String,let profileImageURL = dataArray["profileImageURL"]as? String{
                self.userName = name
                self.email = email
                self.configProfileImage(with: profileImageURL)
            }
        }
        }
    }
    private func configProfileImage(with urlString: String){
        self.userProfile.loadDataUsingCacheWithUrlString(urlString: urlString)
    }
    private func showProfileName(){
        let alert = UIAlertController(title: "Profile", message: "Name: \(self.userName)????????????? \n Email: \(self.email)??????", preferredStyle: .alert)
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
    @IBAction func editButtonTapped(_ sender: UIButton) {
        isInteractionEnabled = !isInteractionEnabled
        if isInteractionEnabled{
            self.userProfile.isUserInteractionEnabled = true
            self.userProfile.layer.borderColor = #colorLiteral(red: 0.007948002778, green: 0.708705008, blue: 0.9307365417, alpha: 1)
            self.userProfile.layer.borderWidth = 4
            self.userProfile.layer.masksToBounds = true
        }else{
            self.userProfile.isUserInteractionEnabled = false
            self.userProfile.layer.borderColor = UIColor.clear.cgColor
            self.userProfile.layer.borderWidth = 0
        }
        
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
