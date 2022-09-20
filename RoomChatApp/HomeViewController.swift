//
//  HomeViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 20/09/2022.
//

import UIKit
import FirebaseAuth
class HomeViewController: UIViewController {
    //MARK: - vars & outlets
    @IBOutlet weak var roomsTableView: UITableView!
    @IBOutlet weak var roomChatNameTF: UITextField!
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        roomsTableView.delegate = self
        roomsTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        roomsTableView.reloadWithAnimation()
    }
    //الفانكشن دي بتشتغل كل مره الفيو بيظهر عكس ال view will appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let currentUser = Auth.auth().currentUser
        if currentUser == nil {
            self.presentAuthScreen()
        }else{
            
        }
        
    }
    
    //MARK: - private functions
    func presentAuthScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AuthViewController")as! AuthViewController
        controller.modalTransitionStyle = .flipHorizontal
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
        print("exit")
        
    }
    //MARK: - actions
    @IBAction func logoutBarButtonTapped(_ sender: UIBarButtonItem) {
        try! Auth.auth().signOut()
        self.presentAuthScreen()
    }
    
    @IBAction func createRoomBtnTapped(_ sender: UIButton) {
        
    }
}
//MARK: - UITableViewDelegate , UITableViewDataSource
extension HomeViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell")!
        cell.textLabel?.text = "hello"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    
    
}
