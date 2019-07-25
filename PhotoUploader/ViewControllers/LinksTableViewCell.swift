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
        guard let onServerHistory = Storage.readLinksAndNamesStorage() else { return }
        guard let inputHistory = Storage.readSuccessResponsesNamesStorage() else { return }
        
        // present link
        let nameFromInputHistory = inputHistory[cellIndex]
        let link = onServerHistory[nameFromInputHistory]
        textLabel?.textColor = .blue
        textLabel?.text = link
    }
}
