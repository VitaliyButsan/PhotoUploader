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
        let loadedImages = Imgur.imageStorage.filter { $0.isLoad == true }
        let link = Imgur.userDefaults.string(forKey: loadedImages[cellIndex].name)
        textLabel?.text = link ?? ""
    }

}
