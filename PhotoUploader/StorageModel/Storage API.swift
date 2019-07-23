//
//  db.swift
//  PhotoUploader
//
//  Created by vit on 23/07/2019.
//  Copyright © 2019 vit. All rights reserved.
//

import Foundation

final class Storage {
    
    private struct Constants {
        static let dictStorage: String = "linksAndNamesStorage"
        static let successResponsesNamesStorage: String = "successResponsesNamesStorage"
        static let serialPrivateQueue = DispatchQueue(label: "com.serialQueue", qos: .utility)
    }
    
    // check "seccessResponsesNames" db existence
    static func successResponsesNamesStorageIsExist() -> Bool {
        if UserDefaults.standard.array(forKey: Constants.successResponsesNamesStorage) != nil {
            return true
        } else {
            return false
        }
    }
    
    // read "successResponsesNames" db
    static func readSuccessResponsesNamesStorage() -> [String]? {
        if successResponsesNamesStorageIsExist() {
            return UserDefaults.standard.array(forKey: Constants.successResponsesNamesStorage) as? [String]
        } else {
            return nil
        }
    }
    
    // write "succesResponsesNames" db
    static func writeToSuccessResponsesNamesStorage(name: String) {
        Constants.serialPrivateQueue.async {
            if !successResponsesNamesStorageIsExist() {
                var newNamesArr: [String] = []
                newNamesArr.append(name)
                UserDefaults.standard.set(newNamesArr, forKey: Constants.successResponsesNamesStorage)
            } else {
                var names = readSuccessResponsesNamesStorage()!
                names.append(name)
                UserDefaults.standard.set(names, forKey: Constants.successResponsesNamesStorage)
            }
        }
    }
    
    // check "linksAndNames" db existence
    static func linksAndNamesStorageIsExist() -> Bool {
        
        if UserDefaults.standard.dictionary(forKey: Constants.dictStorage) != nil {
            return true
        } else {
            return false
        }
    }
    
    // reaad "linksAndNames" db
    static func readLinksAndNamesStorage() -> [String:String]? {
        
        if linksAndNamesStorageIsExist() {
            return UserDefaults.standard.dictionary(forKey: Constants.dictStorage) as? [String : String]
        } else {
            return nil
        }
    }
    
    // write to "linksAndNames" db
    static func writeLinksAndNamesStorage(name: String, link: String) {
        Constants.serialPrivateQueue.async {
            if !linksAndNamesStorageIsExist() {
                let newDataDictionary: [String:String] = [name : link]
                UserDefaults.standard.set(newDataDictionary, forKey: Constants.dictStorage)
            } else {
                var existingStorageDictionary = UserDefaults.standard.dictionary(forKey: Constants.dictStorage)
                existingStorageDictionary?.updateValue(link, forKey: name)
                UserDefaults.standard.set(existingStorageDictionary, forKey: Constants.dictStorage)
            }
        }
    }
    
    static func amountStorageLinksAndNames() -> Int? {
        
        if linksAndNamesStorageIsExist() {
            let dict = UserDefaults.standard.dictionary(forKey: Constants.dictStorage) as! [String : String]
            return dict.count
        } else {
            return nil
        }
    }
    
    // delete db -----------------------------------------------------------------------------
    // Deletion db is possible only if the app is completely will be removed from the device!
    // ---------------------------------------------------------------------------------------
}
