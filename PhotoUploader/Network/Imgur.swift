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
    
    struct Constants {
        static let compressionQuality: CGFloat = 1.0
        static let headerDataName: String = "title"
        static let encodeDataName: String = "image"
        static let encodeMimeType: String = "image/jpg"
        static let endpoingURL: String = "https://api.imgur.com/3/image"
        static let headers: HTTPHeaders = ["Authorization": "Client-ID 7680907fb2e8211"]
        
        static let dataKey: String = "data"
        static let titleKey: String = "title"
        static let linkKey: String = "link"
        static let linksStorage: String = "retrievedLinksArray"
        static let namesStorage: String = "retrievedNamesArray"
        static let dictStorage: String = "dictStorage1"
    }

    static func requestWith(image: UIImage, name imageName: String, completionHandler: @escaping (Bool) -> Void) {
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
                    guard let dict = dictData else { print("No JSON data!"); return }
                    guard let name = dict[Constants.titleKey] as? String else { print("No title!"); return }
                    guard let link = dict[Constants.linkKey] as? String else { print("No lenk!"); return }
                    print("MyName on server:", name , "--> Link on server:", link)
                    //----------------------------------------------------------------------
                
                    // save [name : link] to db
                    if UserDefaults.standard.array(forKey: Constants.namesStorage) == nil {
                        let nameData: [String] = [name]
                        let linkData: [String] = [link]
                        UserDefaults.standard.set(nameData, forKey: Constants.namesStorage)
                        UserDefaults.standard.set(linkData, forKey: Constants.linksStorage)
                        
                        let dataDictionary: [String:String] = [name : link]
                        UserDefaults.standard.set(dataDictionary, forKey: Constants.dictStorage)
                    } else {
                        var names = UserDefaults.standard.array(forKey: Constants.namesStorage)
                        var links = UserDefaults.standard.array(forKey: Constants.linksStorage)
                        names?.append(name)
                        links?.append(link)
                        UserDefaults.standard.set(names, forKey: Constants.namesStorage)
                        UserDefaults.standard.set(links, forKey: Constants.linksStorage)
                        
                        var storageDictionary = UserDefaults.standard.dictionary(forKey: Constants.dictStorage)
                        storageDictionary?.updateValue(link, forKey: name)
                        UserDefaults.standard.set(storageDictionary, forKey: Constants.dictStorage)
                    }
                    
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

