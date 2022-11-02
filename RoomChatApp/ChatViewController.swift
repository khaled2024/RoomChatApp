//
//  ChatViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 25/09/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import JGProgressHUD
class ChatViewController: UIViewController {
    //MARK: - Vars & Outlets
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatMessageView: UIView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTF: UITextField!
    @IBOutlet weak var addImageView: UIImageView!
    
    var room: Room?
    var chatMessages = [RoomMessage]()
    let spinner = JGProgressHUD(style: .light)
    var startingFram: CGRect?
    var blackgroundView: UIView?
    var startingImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = room?.roomName
        observeMessage()
        //        observeImageMessages()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.allowsSelection = false
        setDesign()
        self.addImageView.isUserInteractionEnabled = true
        
        self.addImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dragImage)))
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: -  functions
    @objc func dragImage(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        // to make picker have videos type :)
        picker.delegate = self
        present(picker, animated: true)
    }
    func setDesign(){
        messageTF.changePlaceholderColor(text: "Type your message here.")
        chatMessageView.addLayer(cornerRadius: 15, shadowColor: .gray, shadowOffsetWidth: 4, shadowOffsetHeight: 3, shadowOpacity: 0.5)
        sendButton.addLayer(cornerRadius: 15, shadowColor: .gray, shadowOffsetWidth: 4, shadowOffsetHeight: 3, shadowOpacity: 0.5)
    }
    ///get user with id
    private func getUserWithId(_ id: String , completion: @escaping (_ userName: String?)-> Void){
        let ref = Database.database().reference()
        let user = ref.child("users").child(id)
        user.child("name").observeSingleEvent(of: .value) { snapShot in
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
                if let roomId = self.room?.roomId , let senderId = Auth.auth().currentUser?.uid{
                    let dataArray:[String:Any] = ["senderName":userName , "text": text , "senderId": senderId]
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
    /// observe messages
    func observeMessage(){
        guard let roomId = room?.roomId else{return}
        let ref = Database.database().reference()
        ref.child("rooms").child(roomId).child("messages").observe(.childAdded) { snapShot in
            if let dataArray = snapShot.value as? [String: Any]{
                guard let userId = dataArray["senderId"]as? String else{return}
                let messageKey = snapShot.key
                Database.database().reference().child("users").child(userId).observeSingleEvent(of: .value) { snapShot in
                    print(snapShot)
                    if let userData = snapShot.value as? [String:Any],let userImage = userData["profileImageURL"]as? String{
                        if (dataArray["text"] as? String) != nil{
                            let message = RoomMessage(messageKey: messageKey, messageSender: dataArray["senderName"]as? String, messageText: dataArray["text"]as? String,userId: userId,userImage: userImage)
                            self.chatMessages.append(message)
                        }
                        else if (dataArray["imageURL"]as? String) != nil {
                            let imageURL = dataArray["imageURL"]as? String
                            let imageWidth = dataArray["imageWidth"]as? NSNumber
                            let imageHeight = dataArray["imageHeight"]as? NSNumber
                            let message = RoomMessage(messageKey: messageKey, messageSender: dataArray["senderName"]as? String,userId: userId,userImage: userImage, messageImageURL: imageURL, imageWidth: imageWidth, imageHeight: imageHeight)
                            self.chatMessages.append(message)
                        }
                        DispatchQueue.main.async {
                            self.chatTableView.reloadData()
                            // sroll to last msg
                            let index = IndexPath(item: self.chatMessages.count - 1, section: 0)
                            self.chatTableView.scrollToRow(at: index, at: .bottom, animated: true)
                        }
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
//MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = chatMessages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell")as! ChatTableViewCell
        cell.roomChatVC = self
        if let text = message.messageText {
            cell.messageImageView.isHidden = true
            cell.messageTextView.isHidden = false
            cell.messageTextView.text = text
            cell.messageViewWidth.constant = estimateFrameForText(text: text).width + 30
            cell.messageView.layer.cornerRadius = 12
        }else if message.messageImageURL != nil{
            cell.messageViewWidth.constant = 200
            cell.messageView.layer.cornerRadius = 20
            cell.messageImageView.layer.cornerRadius = 20
            cell.messageImageView.isHidden = false
            cell.messageTextView.isHidden = true
        }
        cell.setMessageData(message: message)

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = 230
        let message = chatMessages[indexPath.row]
        if let text = message.messageText{
            height = estimateFrameForText(text: text).height + 60
        }else if let imageWidth = message.imageWidth?.floatValue , let imageHeight = message.imageHeight?.floatValue {
            print(imageWidth , imageHeight)
            height = CGFloat(imageHeight/imageWidth * 220)
        }
        print(height)
        return height
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.chatTableView.invalidateIntrinsicContentSize()
    }
    
    // func for EstimateFrameForText
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options:options,attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], context: nil)
    }
}
//MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.handleImageSelectedFromInfoDic(info: info)
        spinner.show(in: view)
        dismiss(animated: true)
    }
    // #1
    private func handleImageSelectedFromInfoDic(info:[UIImagePickerController.InfoKey:Any]){
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
    }
    // #2
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
                    self.sendImageWithImageURL(imageURL: imageURL,image: image)
                }
            }
        }
    }
    // #3
    private func sendImageWithImageURL(imageURL: String,image:UIImage){
        guard let userId = Auth.auth().currentUser?.uid else{return}
        let ref = Database.database().reference()
        getUserWithId(userId) { userName in
            if let userName = userName{
                if let roomId = self.room?.roomId{
                    let dataArray:[String:Any] = ["senderName":userName ,
                                                  "imageURL":imageURL,
                                                  "imageWidth":image.size.width,
                                                  "imageHeight":image.size.height,
                                                  "senderId": userId]
                    let room = ref.child("rooms").child(roomId)
                    room.child("messages").childByAutoId().setValue(dataArray) { error, ref in
                        guard error == nil else{
                            return
                        }
                        print(ref)
                        self.spinner.dismiss(animated: true)
                    }
                }
            }
        }
    }
}
//MARK: - extensions custom zooming logic
extension ChatViewController{
    func performZoomInForStartingImageView(startingImageView:UIImageView){
        print("performing zoom in logic")
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        //perform the fram of image
        startingFram = startingImageView.superview?.window?.convert(startingImageView.frame, from: startingImageView.superview)
        //        print(startingFram!)
        // craeting a black color behind the image
        let zoomingImageView = UIImageView(frame: startingFram!)
        zoomingImageView.backgroundColor = .systemBlue
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        //zoom out
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow =  UIApplication.shared.keyWindow{
            blackgroundView = UIView(frame: keyWindow.frame)
            blackgroundView?.backgroundColor = UIColor.black
            blackgroundView?.alpha = 0
            keyWindow.addSubview(blackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            // animate the image
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackgroundView?.alpha = 1
                self.chatMessageView.alpha = 0
                
                let height = self.startingFram!.height / self.startingFram!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: nil)
        }
    }
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        // zoom out
        print("zooming out :(")
        if let zoomOutImageView = tapGesture.view{
            // need to animate back the fram
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                zoomOutImageView.layer.cornerRadius = 20
                zoomOutImageView.clipsToBounds = true
                zoomOutImageView.frame = self.startingFram!
                self.blackgroundView?.alpha = 0
                self.chatMessageView.alpha = 1
            } completion: { (completed: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
}
