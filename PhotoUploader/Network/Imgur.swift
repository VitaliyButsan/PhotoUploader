//
//  Imgur.swift
//  PhotoUploader
//
//  Created by vit on 19/07/2019.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit
import Alamofire

final class Imgur {
    
    private struct Constants {
        static let compressionQuality: CGFloat = 1.0
        static let headerDataName: String = "title"
        static let encodeDataName: String = "image"
        static let encodeMimeType: String = "image/jpg"
        static let endpoingURL: String = "https://api.imgur.com/3/image"
        static let headers: HTTPHeaders = ["Authorization": "Client-ID 7680907fb2e8211"]
        
        static let dataKey: String = "data"
        static let titleKey: String = "title"
        static let linkKey: String = "link"
        static let complete: Notification.Name = Notification.Name.init(rawValue: "complete")
        static let failure: Notification.Name = Notification.Name.init(rawValue: "failure")
    }
    
    private static var responsesAmount: Int = 0
    
    static func requestWith(image: UIImage, name imageName: String, completionHandler: @escaping (String?, Int) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: Constants.compressionQuality) else { return }

        Alamofire.upload(multipartFormData: { formData in
            formData.append(String(describing: imageName).data(using: String.Encoding.utf8)!, withName: Constants.headerDataName)
            formData.append(imageData, withName: Constants.encodeDataName, fileName: imageName, mimeType: Constants.encodeMimeType)
            
        }, to: Constants.endpoingURL, headers: Constants.headers) { encodingResult in
            switch encodingResult {
                
            case .success(let upload, _, _):
                upload.responseJSON { response  in
                    let json = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String : Any]
                    //----------------------------------------------------------------------
                    let dictData = json?[Constants.dataKey] as? [String: Any]
                    
                    guard let dict = dictData else {
                        print("No response JSON data!")
                        responsesAmount += 1
                        // send complete message
                        NotificationCenter.default.post(name: Constants.complete, object: nil)
                        completionHandler(nil, responsesAmount)
                        return
                    }

                    guard let link = dict[Constants.linkKey] as? String else {
                        print("No link on server!")
                        responsesAmount += 1
                        // send complete message
                        NotificationCenter.default.post(name: Constants.complete, object: nil)
                        completionHandler(nil, responsesAmount)
                        return
                    }
                    
                    print("MyName on server:", imageName , "--> Link on server:", link)
                    //----------------------------------------------------------------------
                
                    // save [name : link] to db
                    Storage.writeLinksAndNamesStorage(name: imageName, link: link)


                    // send complete message
                    NotificationCenter.default.post(name: Constants.complete, object: nil)
                    responsesAmount += 1
                    completionHandler(imageName, responsesAmount)
                }
                
            case .failure( _ ):
                // send failure message
                NotificationCenter.default.post(name: Constants.failure, object: nil)
                responsesAmount += 1
                completionHandler(nil, responsesAmount)
            }
          
        }
    }
}
