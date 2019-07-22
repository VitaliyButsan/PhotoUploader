//
//  PhotoCollectionViewCell.swift
//  PhotoUploader
//
//  Created by vit on 18/07/2019.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit
import Photos
import Alamofire

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var presentImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    var spinnerState = false {
        didSet {
            if spinnerState == true {
                self.spinner.startAnimating()
            } else {
                self.spinner.stopAnimating()
            }
        }
    }
}
