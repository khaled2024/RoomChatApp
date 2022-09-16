//
//  ViewController.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 16/09/2022.
//

import UIKit

class ViewController: UIViewController {
    //MARK: - outlets & vars
    @IBOutlet weak var titleCollection: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleeLable: UILabel!
    var indexPath: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        titleeLable.addCharacterSpacing()
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
    
}
//MARK: - Collection View Delegation
extension ViewController: UICollectionViewDelegate , UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "formCell", for: indexPath) as! FormCollectionViewCell
        cell.emailTF.changePlaceholderColor(text: "Email")
        cell.passwordTF.changePlaceholderColor(text: "Password")
        cell.userNameTF.changePlaceholderColor(text: "User Name")
        if indexPath.row == 0 { // signin cell
            cell.usernameView.isHidden = true
            cell.actionButton.setTitle("Login", for: .normal)
            cell.slideButton.setTitle("Sign up 👉🏻", for: .normal)
            cell.slideButton.addTarget(self, action: #selector(slideToNextSlide), for: .touchUpInside)
        }else{
            // sign up cell
            cell.usernameView.isHidden = false
            cell.actionButton.setTitle("Sign up", for: .normal)
            cell.slideButton.setTitle("👈🏻 Sign in", for: .normal)
            cell.slideButton.addTarget(self, action: #selector(slideToPrviousSlide), for: .touchUpInside)
        }
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
}

