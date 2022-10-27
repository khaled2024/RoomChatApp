//
//  UserChatViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 02/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import JGProgressHUD
class UserChatViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pickPhotoImageView: UIImageView!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var userChatTableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var msgTextField: UITextField!
    
    let spinner = JGProgressHUD(style: .light)
    
    //MARK: - vars
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            observeMessage()
        }
    }
    var messages = [Message]()
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDesign()
        pickImage()
        userChatTableView.delegate = self
        userChatTableView.dataSource = self
        self.msgTextField.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = .white
    }
    //MARK: - private functions
    private func pickImage(){
        self.pickPhotoImageView.isUserInteractionEnabled = true
        self.pickPhotoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickImage)))
    }
    @objc func handlePickImage(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    private func setDesign(){
        msgView.addLayer(cornerRadius: 15, shadowColor: .gray, shadowOffsetWidth: 4, shadowOffsetHeight: 3, shadowOpacity: 0.5)
        sendBtn.addLayer(cornerRadius: 15, shadowColor: .gray, shadowOffsetWidth: 4, shadowOffsetHeight: 3, shadowOpacity: 0.5)
        
        msgTextField.changePlaceholderColor(text: "Type your message here.")
    }
    
    ///get user with id
    private func getUserWithId(_ id: String , completion: @escaping (_ userName: String?)-> Void){
        let ref = Database.database().reference()
        let user = ref.child("users").child(id)
        user.child("profileImageURL").observeSingleEvent(of: .value) { snapShot in
            if let userImage = snapShot.value as? String{
                completion(userImage)
            }else{
                completion(nil)
            }
        }
    }
    /// observe messages
    func observeMessage(){
        guard let currentid = Auth.auth().currentUser?.uid, let toID = user?.id else{return}
        let ref = Database.database().reference().child("user-messages").child(currentid).child(toID)
        ref.observe(.childAdded, with: { snapShot in
            print(snapShot)
            let messageID = snapShot.key
            let messageRef = Database.database().reference().child("messages").child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { snapShot in
                print(snapShot)
                guard let dictinary = snapShot.value as? [String:Any] else{return}
                if (dictinary["text"] as? String) != nil {
                    let message = Message(fromId: dictinary["fromId"]as? String,
                                          text: dictinary["text"]as? String,
                                          timeStamp: dictinary["timeStamp"]as? NSNumber,
                                          toId: dictinary["toId"]as? String)
                    self.messages.append(message)
                }else if (dictinary["imageURL"] as? String) != nil{
                    let message = Message(fromId: dictinary["fromId"]as? String,
                                          timeStamp: dictinary["timeStamp"]as? NSNumber,
                                          toId: dictinary["toId"]as? String,messageImageURL: dictinary["imageURL"]as? String)
                    self.messages.append(message)
                }
                DispatchQueue.main.async {
                    self.userChatTableView.reloadData()
                }
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }
    /// send message
    private func sendMsg(){
        let ref = Database.database().reference().child("messages")
        let refChild = ref.childByAutoId()
        if let text = self.msgTextField.text , text.isEmpty == false, let user = user, let toId = user.id, let fromId = Auth.auth().currentUser?.uid{
            let timeStamp: NSNumber = NSDate().timeIntervalSince1970 as NSNumber
            if let values = ["text": text,
                             "toId": toId,
                             "fromId":fromId,
                             "timeStamp":timeStamp] as? [AnyHashable : Any]{
                refChild.updateChildValues(values) { error, ref in
                    if  error != nil{
                        print(error ?? "error for update child ref of messages")
                        print("didnt send")
                        return
                    }
                    let messagesID = refChild.key
                    let values = [messagesID:1]as? [AnyHashable:Any]
                    // for user-messages
                    let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
                    userMessagesRef.updateChildValues(values!)
                    // for recipent-messages
                    let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
                    recipientUserMessagesRef.updateChildValues(values!)
                    self.msgTextField.text = ""
                    print("sended")
                }
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMsg()
        return true
    }
    //MARK: - Action
    @IBAction func sendMsgBtn(_ sender: UIButton) {
        sendMsg()
    }
}
//MARK: - UITableViewDelegate
extension UserChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PrivateChatTableViewCell.identifier, for: indexPath)as! PrivateChatTableViewCell
        let message = messages[indexPath.row]
        cell.setMessageDataForPrivateChat(message: message)
        if let text = message.text {
            cell.messageTextView.text = text
        }
        if let user = self.user,let userImage = user.profileImageURL{
            cell.userImage.loadDataUsingCacheWithUrlString(urlString: userImage)
        }
        return cell
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.userChatTableView.invalidateIntrinsicContentSize()
    }
}
//MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension UserChatViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage]as? UIImage{
            selectedImage = editedImage
            print(selectedImage!)
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage]as? UIImage{
            selectedImage = originalImage
            print(selectedImage!)
        }
        if let selectedImage = selectedImage {
            uploadImageToFirebase(image: selectedImage)
        }
        self.spinner.show(in: view)
        dismiss(animated: true)
    }
    private func uploadImageToFirebase(image: UIImage){
        print("upload image ")
        if let imageData = image.jpegData(compressionQuality: 0.2){
            let fileName = NSUUID().uuidString
            Helper.shared.uploadImageMessage(with: imageData, fileName: fileName) { result in
                switch result{
                case.failure(let error):
                    print(error)
                case .success(let imageURL):
                    print(imageURL)
                    self.sendImageWithImageURL(imageURL: imageURL)
                }
            }
        }
    }
    private func sendImageWithImageURL(imageURL: String){
        let ref = Database.database().reference().child("messages")
        let refChild = ref.childByAutoId()
        if let user = user, let toId = user.id, let fromId = Auth.auth().currentUser?.uid{
            let timeStamp: NSNumber = NSDate().timeIntervalSince1970 as NSNumber
            if let values = ["imageURL": imageURL,
                             "toId": toId,
                             "fromId":fromId,
                             "timeStamp":timeStamp] as? [AnyHashable : Any]{
                refChild.updateChildValues(values) { error, ref in
                    if  error != nil{
                        print(error ?? "error for update child ref of messages")
                        print("didnt send")
                        return
                    }
                    let messagesID = refChild.key
                    let values = [messagesID:1]as? [AnyHashable:Any]
                    // for user-messages
                    let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
                    userMessagesRef.updateChildValues(values!)
                    // for recipent-messages
                    let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
                    recipientUserMessagesRef.updateChildValues(values!)
                    self.msgTextField.text = ""
                    print("sended")
                    self.spinner.dismiss(animated: true)
                }
            }
        }
        
    }
}
//MARK: - Comments
// private chats :)
