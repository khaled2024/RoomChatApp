//
//  ChatViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 25/09/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class ChatViewController: UIViewController {
    
    @IBOutlet weak var messageTF: UITextField!
    var room: Room?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = room?.roomName
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    //MARK: -  functions
    ///get user with id
    private func getUserWithId(_ id: String , completion: @escaping (_ userName: String?)-> Void){
        let ref = Database.database().reference()
        let user = ref.child("users").child(id)
        user.child("userName").observeSingleEvent(of: .value) { snapShot in
            if let userName = snapShot.value as? String{
                completion(userName)
            }else{
                completion(nil)
            }
        }
    }
    /// send message
    private func sendMessage(text: String , completion:@escaping (_ isSuccess: Bool) -> Void){
        guard let userId = Auth.auth().currentUser?.uid else{
            return
        }
        let ref = Database.database().reference()
        getUserWithId(userId) { userName in
            if let userName = userName{
                if let roomId = self.room?.roomId {
                    let dataArray:[String:Any] = ["senderName":userName , "text": text]
                    let room = ref.child("rooms").child(roomId)
                    room.child("messages").childByAutoId().setValue(dataArray) { error, ref in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    //MARK: - actions
    @IBAction func sendBtnTapped(_ sender: UIButton) {
        guard let message = messageTF.text , !message.isEmpty else{
            print("please field TF.!")
            return
        }
        sendMessage(text: message, completion: { isSuccess in
            if isSuccess{
                self.messageTF.text = ""
                print("message added to database successfuly:)")
            }else{
                print("error for sending message:(")
            }
        })
    }
}
