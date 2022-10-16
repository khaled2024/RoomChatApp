//
//  AuthViewController+handler.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 16/10/2022.
//

import UIKit
extension AuthViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func configProfileImage(){
        self.userProfileImage.isUserInteractionEnabled = true
        userProfileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageTapped)))
        userProfileImage.layer.cornerRadius = userProfileImage.frame.size.height/2
    }
    @objc func profileImageTapped(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //UIImagePickerControllerEditedImage
        //UIImagePickerControllerOriginalImage
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage]as? UIImage{
            print(editedImage)
            self.userProfileImage.image = editedImage
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage]as? UIImage{
            self.userProfileImage.image = originalImage
            print(originalImage)
        }
        picker.dismiss(animated: true,completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancle picker")
        picker.dismiss(animated: true,completion: nil)
    }
}
