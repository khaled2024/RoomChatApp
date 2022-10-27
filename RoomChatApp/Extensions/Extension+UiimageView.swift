//
//  Extension+UiimageView.swift
//  RoomChatApp
//
//  Created by KhaleD HuSsien on 16/10/2022.
//

import UIKit

var imageCache = NSCache<AnyObject,AnyObject>()

extension UIImageView{
    func loadDataUsingCacheWithUrlString(urlString: String){
//        self.image = UIImage(named: "user")
        if let chachImage = imageCache.object(forKey: urlString as NSString)as? UIImage{
            self.image = chachImage
            return
        }
        guard let url = NSURL(string: urlString) as? URL else{return}
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if error != nil{
                print(error?.localizedDescription ?? "error in fetch url image")
                return
            }
            DispatchQueue.main.async {
                if let downloadImage = UIImage(data: data!){
                    imageCache.setObject(downloadImage, forKey: urlString as NSString)
                    self.image = downloadImage
                }
            }
        }.resume()
    }
}
