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
    static let headerDataName: String = "title"
    static let encodeDataName: String = "image"
    static let encodeMimeType: String = "image/jpg"
    static let endpoingURL: String = "https://api.imgur.com/3/image"
    static let headers: HTTPHeaders = ["Authorization": "Client-ID 7680907fb2e8211"]
}

struct Image {
    var name: String
    var data: UIImage
    var isLoad: Bool = false
}

class Imgur {
    
    static var imageStorage: [Image] = []
    
    static func requestWith(image: UIImage, name imageName: String, completionHandler: @escaping (Bool) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        
        Alamofire.upload(multipartFormData: { formData in
            formData.append(String(describing: imageName).data(using: String.Encoding.utf8)!, withName: NetConstants.headerDataName)
            formData.append(imageData, withName: NetConstants.encodeDataName, fileName: imageName, mimeType: NetConstants.encodeMimeType)
            
        }, to: NetConstants.endpoingURL, headers: NetConstants.headers) { encodingResult in
            switch encodingResult {
                
            case .success(let upload, _, _):
                upload.responseJSON { response  in
                    let json = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String : Any]
                    //----------------------------------------------------------------------
                    let dictData = json?["data"] as? [String: Any]
                    if let dict = dictData {
                        print("MyName on server:", dict["title"] ?? "...no title", "--> Link on server:", dict["link"] ?? "...no link")
                    }
                    //----------------------------------------------------------------------
                    completionHandler(true)
                }
                
            case .failure(let encodingError):
                completionHandler(false)
                print("ERROR!: \(encodingError)")
                // setup Alert
            }
        }
    }
}

