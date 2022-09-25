//
//  HomeViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 20/09/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class HomeViewController: UIViewController {
    //MARK: - vars & outlets
    @IBOutlet weak var roomsTableView: UITableView!
    @IBOutlet weak var roomChatNameTF: UITextField!
    
    var rooms = [Room]()
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        roomsTableView.delegate = self
        roomsTableView.dataSource = self
        observeRooms()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        roomsTableView.reloadData()
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
    func observeRooms(){
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
            }
        }
    }
    //MARK: - actions
    @IBAction func logoutBarButtonTapped(_ sender: UIBarButtonItem) {
        try! Auth.auth().signOut()
        self.presentAuthScreen()
    }
    
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
                //
            }
        }
    }
}
//MARK: - UITableViewDelegate , UITableViewDataSource
extension HomeViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell")!
        cell.textLabel?.text = rooms[indexPath.row].roomName
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedRoom = rooms[indexPath.row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
        controller.room = selectedRoom
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}
