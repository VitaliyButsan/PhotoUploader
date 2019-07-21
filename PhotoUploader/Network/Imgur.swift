//
//  Imgur.swift
//  PhotoUploader
//
//  Created by vit on 19/07/2019.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit
import Alamofire

struct NetConstants {
    static let compressionQuality: CGFloat = 1.0
    static let headerDataName: String = "title"
    static let encodeDataName: String = "image"
    static let encodeMimeType: String = "image/jpg"
    static let endpoingURL: String = "https://api.imgur.com/3/image"
    static let headers: HTTPHeaders = ["Authorization": "Client-ID 7680907fb2e8211"]
    
    static let dataKey: String = "data"
    static let titleKey: String = "title"
    static let linkKey: String = "link"
    
}

struct Image {
    var name: String
    var data: UIImage
    var isLoad: Bool = false
}

class Imgur {
    
    static var userDefaults = UserDefaults.standard
    static var imageStorage: [Image] = []

    static func requestWith(image: UIImage, name imageName: String, completionHandler: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: NetConstants.compressionQuality) else { return }
        
        Alamofire.upload(multipartFormData: { formData in
            formData.append(String(describing: imageName).data(using: String.Encoding.utf8)!, withName: NetConstants.headerDataName)
            formData.append(imageData, withName: NetConstants.encodeDataName, fileName: imageName, mimeType: NetConstants.encodeMimeType)
            
        }, to: NetConstants.endpoingURL, headers: NetConstants.headers) { encodingResult in
            switch encodingResult {
                
            case .success(let upload, _, _):
                upload.responseJSON { response  in
                    let json = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String : Any]
                    //----------------------------------------------------------------------
                    let dictData = json?[NetConstants.dataKey] as? [String: Any]
                    guard let dict = dictData else { print("No JSON data!"); return }
                    guard let name = dict[NetConstants.titleKey] as? String else { print("No title!"); return }
                    guard let link = dict[NetConstants.linkKey] as? String else { print("No lenk!"); return }
                    print("MyName on server:", name , "--> Link on server:", link)
                    //----------------------------------------------------------------------
                    
                    self.userDefaults.set(link, forKey: name)
                    completionHandler(name)
                }
                
            case .failure(let encodingError):
                completionHandler(nil)
                print("ERROR!: \(encodingError)")
                // setup Alert
            }
        }
    }
}

