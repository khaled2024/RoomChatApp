//
//  ProfileViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 25/09/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
struct Setting {
    let title: String
    let option: [Option]
}
struct Option{
    let title: String
    let handler: ()->Void
}
class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileTableView: UITableView!
    private var sections = [Setting]()
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.delegate = self
        profileTableView.dataSource = self
        configSetting()
        
        profileTableView.tableHeaderView = headerView()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func headerView()-> UIView{
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width / 1.5))
        let lable = UILabel(frame: .init(x: 10, y: 20, width: headerView.frame.size.width, height: 20))
        lable.center = headerView.center
        lable.textColor = #colorLiteral(red: 0.1165452674, green: 0.4018504918, blue: 0.4115763307, alpha: 1)
        lable.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        let ref = Database.database().reference()
        if let id = Auth.auth().currentUser?.uid { ref.child("users").child(id).child("userName").observeSingleEvent(of: .value) { snapShot in
                if let userName = snapShot.value as? String{
                    lable.text = "Name: \(userName)"
                }
            }
        }
        
        view.addSubview(lable)
        return headerView
    }
    private func configSetting(){
        sections.append(Setting(title: "Account", option: [Option(title: "Log out", handler: {[weak self] in
            self?.signOutTapped()
        })]))
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
        return sections.count
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
