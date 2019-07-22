//
//  LinksTableViewCell.swift
//  PhotoUploader
//
//  Created by vit on 21/07/2019.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit

class LinksTableViewCell: UITableViewCell {

    func presentLink(forCellIndex cellIndex: Int) {
        // db
        let storedDataDict = UserDefaults.standard.dictionary(forKey: Imgur.Constants.dictStorage) as! [String:String]
        //guard let val = storedDataDict["\(cellIndex)"] as? String else { return }
        //print("--->", val)
        //let val = storedDataDict["\(7)"]
        
        
        for (_ , value) in storedDataDict {
            textLabel?.text = value
        }
        //guard let text = textLabel?.text else { return }
        //print("__________", text)
        //guard (storedDataDict as? [String:String]) != nil else { return }
        //print("---->", storedDataDict["\(1)"] ?? "...")
        //print(storedDataDict)
        //let names = UserDefaults.standard.array(forKey: NetConstants.namesStorage)
        //let links = UserDefaults.standard.array(forKey: NetConstants.linksStorage)
        
        //guard let myNames = names as? [String], let myLinks = links as? [String] else { return }
        //guard let link = links?[cellIndex] as? String else { return }
        //textLabel?.text = link
        //print(cellIndex, array)
        //guard let arr = array as? [[String:String]] else { return }
        //print(arr[cellIndex])
        //let ind = arr[cellIndex] as! [String:String]
        //for i in arr {
            //print(i.value)
        //}
        //let index = storedDataDict.index(forKey: "\(cellIndex)")
        //print("...t.t.t.t", index)
        //for key in storedDataDict.keys {
        //let cellKey = String(cellIndex)
        //guard let link = storedDataDict[cellKey] as? String else { return }
        //textLabel?.text = link
        //}
    }

}

extension Dictionary {
    subscript(optional optKey : Key?) -> Value? {
        return optKey.flatMap { self[$0] }
    }
}
