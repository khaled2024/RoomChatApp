//
//  ProfileViewController+PickerImageController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 16/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
extension ProfileViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func updataProfileImage(){
       self.userProfile.isUserInteractionEnabled = true
       self.userProfile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TouchedProfileImage)))
   }
   @objc func TouchedProfileImage(){
       let picker = UIImagePickerController()
       picker.delegate = self
       picker.allowsEditing = true
       present(picker, animated: true)
   }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled")
        picker.dismiss(animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        spinner.show(in: view)
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage]as? UIImage{
            print(editedImage)
            self.userProfile.image = editedImage
            getandUpdateUserImage(image: editedImage)
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage]as? UIImage{
            self.userProfile.image = originalImage
            print(originalImage)
            getandUpdateUserImage(image: originalImage)
        }
        picker.dismiss(animated: true,completion: nil)
    }
    private func getandUpdateUserImage(image: UIImage){
        if let uid = Auth.auth().currentUser?.uid , let email = Auth.auth().currentUser?.email {
            if let imageProfile = self.userProfile.image , let imageData = imageProfile.jpegData(compressionQuality: 0.1){
                let fileName = "\(uid)_\(email)_udpated_profile_picture.jpg"
                print(fileName)
                Helper.shared.uploadProfilePicture(with: imageData, fileName: fileName) { [weak self] result in
                    switch result{
                    case.failure(let error):
                        print(error)
                    case.success(let downloadImage):
                        let refrence = Database.database().reference()
                        refrence.child("users").child(uid).child("profileImageURL").setValue(downloadImage) { error, ref in
                            if error == nil {
                                self?.spinner.dismiss()
                                self?.updateProfileAlert(title: "Congratulations", message: "Your profile Image updated Successfully 👌")
                                self?.userProfile.isUserInteractionEnabled = false
                                self?.userProfile.layer.borderColor = UIColor.clear.cgColor
                                self?.userProfile.layer.borderWidth = 0
                                return
                            }
                            self?.updateProfileAlert(title: "Sorry", message: "Error for update profile image")
                            print(error ?? "error for update profile image")
                        }
                    }
                }
            }
        }
    }
    func updateProfileAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
}

