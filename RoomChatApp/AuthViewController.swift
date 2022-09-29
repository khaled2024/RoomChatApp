//
//  ViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 16/09/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class AuthViewController: UIViewController {
    //MARK: - outlets & vars
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleeLable: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    //MARK: - private functions
    @objc func slideToNextSlide(_ sender: UIButton){
        let indexPath = IndexPath(row: 1, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    @objc func slideToPrviousSlide(_ sender: UIButton){
        let indexPath = IndexPath(row: 0, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    @objc func signUpTapped(_ sender: UIButton){
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = self.collectionView.cellForItem(at: indexPath)as! FormCollectionViewCell
        guard let email = cell.emailTF.text , !email.isEmpty ,
              let pass = cell.passwordTF.text, !pass.isEmpty ,
              let userName = cell.userNameTF.text, !userName.isEmpty  else{
            self.displayError(errorText: "Please fill empty fields")
            return
        }
        Auth.auth().createUser(withEmail: email, password: pass) { result, error in
            guard error == nil , let result = result else{
                self.displayError(errorText: error!.localizedDescription)
                return
            }
            print("result: \(result)")
            self.dismiss(animated: true,completion: nil)
            let refrence = Database.database().reference()
            let user = refrence.child("users").child(result.user.uid)
            let dataArray: [String:Any] = ["userName" : userName]
            user.setValue(dataArray)
        }
    }
    @objc func signInTapped(){
        let indecPath = IndexPath(row: 0, section: 0)
        let cell = self.collectionView.cellForItem(at: indecPath)as! FormCollectionViewCell
        
        guard let email = cell.emailTF.text , !email.isEmpty ,
              let pass = cell.passwordTF.text, !pass.isEmpty else{
            self.displayError(errorText: "Please fill empty fields")
            return
        }
        Auth.auth().signIn(withEmail: email, password: pass) { result, error in
            guard let result = result , error == nil else{
                self.displayError(errorText: error!.localizedDescription)
                return
            }
            // هنا بعمل dismiss للاسكرين عشان ال home vc هيا ال intial controller عندي فلما اضغط علي logout بروح ل home دي ولما احب ادخل تاني بعمل dismiss بقي عشان هما فوق بعض كده.
            self.dismiss(animated: true,completion: nil)
            print(result)
        }
    }
    
    private func displayError(errorText: String){
        let alert = UIAlertController(title: "Error ❌", message: errorText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss 👌", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
//MARK: - Collection View Delegation
extension AuthViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FormCollectionViewCell", for: indexPath) as! FormCollectionViewCell
        cell.emailTF.changePlaceholderColor(text: "Email")
        cell.passwordTF.changePlaceholderColor(text: "Password")
        cell.userNameTF.changePlaceholderColor(text: "User Name")
        cell.configDesign()
        if indexPath.row == 0 { // signIn cell
            cell.usernameView.isHidden = true
            cell.actionButton.setTitle("Login", for: .normal)
            cell.slideButton.setTitle("Sign up 👉🏻", for: .normal)
            cell.slideButton.addTarget(self, action: #selector(slideToNextSlide), for: .touchUpInside)
            cell.actionButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        }else{
            // signUp cell
            cell.usernameView.isHidden = false
            cell.actionButton.setTitle("Sign up", for: .normal)
            cell.slideButton.setTitle("👈🏻 Sign in", for: .normal)
            cell.slideButton.addTarget(self, action: #selector(slideToPrviousSlide), for: .touchUpInside)
            cell.actionButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        }
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
}

