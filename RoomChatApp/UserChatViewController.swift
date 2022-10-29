//
//  UserChatViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 02/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MobileCoreServices
import AVFoundation
import JGProgressHUD
import FirebaseStorage

class UserChatViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pickPhotoImageView: UIImageView!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var userChatTableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var msgTextField: UITextField!
    
    let spinner = JGProgressHUD(style: .light)
    var startingFram: CGRect?
    var blackgroundView: UIView?
    var startingImageView: UIImageView?
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
        setKeyboeadObserver()
        
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
        // to make picker have videos type :)
        picker.mediaTypes = [kUTTypeImage as String , kUTTypeMovie as String]
        picker.delegate = self
        present(picker, animated: true)
    }
    /// For keyboard observer
    private func setKeyboeadObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name:UIResponder.keyboardDidShowNotification, object: nil)
    }
    @objc func handleKeyboardDidShow(){
        if self.messages.count > 0 {
            let index = IndexPath(item: self.messages.count - 1, section: 0)
            self.userChatTableView.scrollToRow(at: index, at: .bottom, animated: true)
        }
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
                }else if (dictinary["imageURL"] as? String != nil) && (dictinary["videoURL"] as? String == nil){
                    let message = Message(fromId: dictinary["fromId"]as? String,
                                          timeStamp: dictinary["timeStamp"]as? NSNumber,
                                          toId: dictinary["toId"]as? String,
                                          messageImageURL: dictinary["imageURL"]as? String,
                                          imageWidth: dictinary["imageWidth"]as? NSNumber ,
                                          imageHeight: dictinary["imageHeight"]as? NSNumber)
                    self.messages.append(message)
                }else if (dictinary["videoURL"] as? String) != nil{
                    let message = Message(fromId: dictinary["fromId"]as? String,
                                          timeStamp: dictinary["timeStamp"]as? NSNumber,
                                          toId: dictinary["toId"]as? String,
                                          messageImageURL: dictinary["imageURL"]as? String,
                                          videoURL: dictinary["videoURL"]as? String)
                    self.messages.append(message)
                }
                DispatchQueue.main.async {
                    self.userChatTableView.reloadData()
                    // sroll to last msg
                    let index = IndexPath(item: self.messages.count - 1, section: 0)
                    self.userChatTableView.scrollToRow(at: index, at: .bottom, animated: true)
                    print(self.messages)
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
        // like delegate for Zooming ImageView
        cell.userChatVC = self
        let message = messages[indexPath.row]
        cell.message = message
        // User image
        if let user = self.user,
           let userImage = user.profileImageURL{
            cell.userImage.loadDataUsingCacheWithUrlString(urlString: userImage)
        }
        // Check Between if message have a text or image or video :)
        if let text = message.text {
            cell.messageTextView.text = text
            cell.messageViewWidth.constant = estimateFrameForText(text: text).width + 20
            cell.messageImage.isHidden = true
            cell.messageTextView.isHidden = false
        }else if message.messageImageURL != nil{
            cell.messageViewWidth.constant = 200
            cell.messageImage.isHidden = false
            cell.messageTextView.isHidden = true
        }
        cell.playBtn.isHidden = message.videoURL == nil
        if message.videoURL != nil {
            cell.messageImage.contentMode = .scaleAspectFit
        }else{
            cell.messageImage.contentMode = .scaleToFill
            cell.messageView.layer.cornerRadius = 12
            cell.messageImage.layer.cornerRadius = 20
        }
        cell.setMessageDataForPrivateChat(message: message)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = 220
        let message = messages[indexPath.row]
        if let text = message.text{
            height = estimateFrameForText(text: text).height + 60
        }else if let imageWidth = message.imageWidth?.floatValue , let imageHeight = message.imageHeight?.floatValue {
            print(imageWidth , imageHeight)
            height = CGFloat(imageHeight/imageWidth * 200)
        }
        print(height)
        return height
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.userChatTableView.invalidateIntrinsicContentSize()
    }
    // func for EstimateFrameForText
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options:options,attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], context: nil)
    }
}
//MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension UserChatViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL]as? URL {
            print("videoURL: \(videoURL)")
            handleVideoUrl(url: videoURL)
        }else{
            self.handleImageSelectedFromInfoDic(info: info)
        }
        self.spinner.show(in: view)
        dismiss(animated: true)
    }
    //MARK: - Private func For image picker
    
    //MARK: - for video :)
    // #1
    private func handleVideoUrl(url: URL){
        Helper.shared.upload(file: url) { result in
            switch result{
            case.failure(let error):
                print(error)
            case .success(let urlString):
                print(urlString)
                if let thumbnailImage = self.thumbnailImageForVideoURL(fileUrl: url) {
                    print("upload thumbnail image: \(thumbnailImage)")
                    if let imageData = thumbnailImage.jpegData(compressionQuality: 0.2){
                        let fileName = NSUUID().uuidString
                        Helper.shared.uploadImageMessage(with: imageData, fileName: fileName) { result in
                            switch result{
                            case.failure(let error):
                                print(error)
                            case .success(let imageURL):
                                print(imageURL)
                                self.sendVideoWithURLAndThumbnail(urlString: urlString,thumbnailImage: thumbnailImage,imageURL: imageURL)
                            }
                        }
                    }
                }
                self.spinner.dismiss(animated: true)
            }
        }
    }
    // #2
    private func thumbnailImageForVideoURL(fileUrl:URL)->UIImage?{
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let cgThumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: cgThumbnailImage)
        }catch let error{
            print(error)
        }
        return nil
    }
    // #3
    private func sendVideoWithURLAndThumbnail(urlString: String,thumbnailImage: UIImage,imageURL:String){
        let ref = Database.database().reference().child("messages")
        let refChild = ref.childByAutoId()
        if let user = user, let toId = user.id, let fromId = Auth.auth().currentUser?.uid{
            let timeStamp: NSNumber = NSDate().timeIntervalSince1970 as NSNumber
            if let values = ["toId": toId,
                             "fromId":fromId,
                             "timeStamp":timeStamp,
                             "imageURL":imageURL,
                             "imageWidth":thumbnailImage.size.width,
                             "imageHeight":thumbnailImage.size.height,
                             "videoURL":urlString] as? [AnyHashable : Any]{
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
                    print(userMessagesRef)
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
    //MARK: -  For image :)
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
        let ref = Database.database().reference().child("messages")
        let refChild = ref.childByAutoId()
        if let user = user, let toId = user.id, let fromId = Auth.auth().currentUser?.uid{
            let timeStamp: NSNumber = NSDate().timeIntervalSince1970 as NSNumber
            if let values = ["toId": toId,
                             "fromId":fromId,
                             "timeStamp":timeStamp,
                             "imageURL":imageURL,
                             "imageWidth":image.size.width,
                             "imageHeight":image.size.height] as? [AnyHashable : Any]{
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
//MARK: - extensions custom zooming logic
extension UserChatViewController{
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
                self.msgView.alpha = 0
                
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
                self.msgView.alpha = 1
            } completion: { (completed: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
}
//MARK: - Comments
// private chats :)
