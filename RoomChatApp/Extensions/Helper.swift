//
//  Helper.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 16/10/2022.
//

import Foundation
import FirebaseStorage

public enum StorageError : Error{
    case failedToUpload
    case failedToGetReference
}

class Helper{
    static let shared = Helper()
    private let storage = Storage.storage().reference()
    // upload picture to firebase storage and return completion with url string to download
    public typealias UploadPictureCompletion = (Result<String , Error>)->Void
    public func uploadProfilePicture(with data: Data , fileName: String , completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data, metadata: nil) { metaData, error in
            guard error == nil else{
                // failed
                print("failed to upload picture to firebase storage")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("failed to get reference from url")
                    completion(.failure(StorageError.failedToGetReference))
                    return
                }
                let urlString = url.absoluteString
                print("downloaded url \(urlString)")
                completion(.success(urlString))
                
            }
        }
        
    }
}
