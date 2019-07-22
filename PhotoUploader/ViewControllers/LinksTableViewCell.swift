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
        // get data from db
        let storedDataDict = UserDefaults.standard.dictionary(forKey: Imgur.Constants.dictStorage) as! [String:String]

        print(storedDataDict["\(cellIndex)"] ?? "...")
    }
}
