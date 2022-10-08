//
//  HomeViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 20/09/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import JGProgressHUD
class HomeViewController: UIViewController {
    //MARK: - vars & outlets
    @IBOutlet weak var createRoomBtn: UIButton!
    @IBOutlet weak var createRoomStack: UIStackView!
    @IBOutlet weak var roomsTableView: UITableView!
    @IBOutlet weak var roomChatNameTF: UITextField!
    @IBOutlet weak var createRoomView: UIView!
    var rooms = [Room]()
    private let spinner =  JGProgressHUD(style: .dark)
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        roomsTableView.delegate = self
        roomsTableView.dataSource = self
        registerTableView()
        observeRooms()
        configDesign()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    //الفانكشن دي بتشتغل كل مره الفيو بيظهر عكس ال view will appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let currentUser = Auth.auth().currentUser
        if currentUser == nil {
            self.presentAuthScreen()
        }else{
            // present Home Screen :)
        }
    }
    //MARK: - private functions
    private func registerTableView(){
        roomsTableView.register(UINib(nibName: RoomsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: RoomsTableViewCell.identifier)
    }
    private func configDesign(){
        self.createRoomView.addLayer(cornerRadius: 15, shadowColor: .darkGray, shadowOffsetWidth: 0, shadowOffsetHeight: 0, shadowOpacity: 0)
        self.createRoomBtn.addLayer(cornerRadius: 15, shadowColor: .darkGray, shadowOffsetWidth: 0, shadowOffsetHeight: 0, shadowOpacity: 0)
    }
    func presentAuthScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AuthViewController")as! AuthViewController
        controller.modalTransitionStyle = .flipHorizontal
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
        print("exit")
        
    }
    func observeRooms(){
        self.spinner.show(in: view)
        let ref = Database.database().reference()
        ref.child("rooms").observe(.childAdded) { snapShot in
            if let dataArray = snapShot.value as? [String:Any] {
                if let roomName = dataArray["roomName"]as? String{
                    let room = Room(roomId: snapShot.key, roomName: roomName)
                    self.rooms.append(room)
                    DispatchQueue.main.async {
                        self.roomsTableView.reloadWithAnimation()
                    }
                }
            }else{
                
                let alert = UIAlertController(title: "Error", message: "Some server issues :(", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancle", style: .cancel))
                self.present(alert, animated: true)
                
            }
        }
        self.spinner.dismiss(animated: true)
    }
    //MARK: - actions
    
    @IBAction func createRoomBtnTapped(_ sender: UIButton) {
        guard let roomName = roomChatNameTF.text  , !roomName.isEmpty else{
            print("Please filed the Room Name.!")
            return
        }
        let databaseRef = Database.database().reference()
        // create child called "rooms" to put the rooms name we will create and give a random key
        let room = databaseRef.child("rooms").childByAutoId()
        let dataArray: [String:Any] = ["roomName" : roomName]
        // here  set the value of new room name :)
        room.setValue(dataArray) { error, ref in
            if error == nil {
                DispatchQueue.main.async {
                    self.roomChatNameTF.text = ""
                }
            }else{
                print("error of creating room")
            }
        }
    }
    
    @IBAction func newFriendBtnTapped(_ sender: UIBarButtonItem) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "UsersViewController")as! UsersViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
//MARK: - UITableViewDelegate , UITableViewDataSource
extension HomeViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell")!
        let room = rooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: RoomsTableViewCell.identifier, for: indexPath)as! RoomsTableViewCell
        cell.config(model: room)
        return cell
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedRoom = rooms[indexPath.row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
        controller.room = selectedRoom
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
