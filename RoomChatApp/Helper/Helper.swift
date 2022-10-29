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
    public typealias UploadPictureAndVideoCompletion = (Result<String , Error>)->Void
    //MARK: - Upload image profile
    public func uploadProfilePicture(with data: Data , fileName: String , completion: @escaping UploadPictureAndVideoCompletion){
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
    //MARK: - Upload image for message
    public func uploadImageMessage(with data: Data , fileName: String , completion: @escaping UploadPictureAndVideoCompletion){
        storage.child("message_images").child(fileName).putData(data, metadata: nil) { metaData, error in
            guard error == nil else{
                // failed
                print("failed to upload message picture to firebase storage")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            self.storage.child("message_images/\(fileName)").downloadURL { url, error in
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
    //MARK: - Upload video
    public func upload(file: URL, completion: @escaping UploadPictureAndVideoCompletion) {
        let name = "\(Int(Date().timeIntervalSince1970)).mp4"
        do {
            let data = try Data(contentsOf: file)
            let storageRef = Storage.storage().reference().child("Videos").child(name)
            if let uploadData = data as Data? {
                let metaData = StorageMetadata()
                metaData.contentType = "video/mp4"
                storageRef.putData(uploadData, metadata: metaData, completion: { (metadata, error) in
                    if let error = error {
                        completion(.failure(error))
                    }else{
                        storageRef.downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                completion(.failure(error!))
                                return
                            }
                            completion(.success(downloadURL.absoluteString))
                        }
                    }
                })
            }
        }catch let error {
            print(error.localizedDescription)
        }
    }
}
