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
    var rowIndex: Int?

    // get photo from asset
    var asset: PHAsset? {
        didSet {
            if let hashAsset = asset {
                PHImageManager.default().requestImage(for: hashAsset, targetSize: presentImageView.frame.size, contentMode: .aspectFill, options: nil) { (image: UIImage?, dict: [AnyHashable:Any]?) -> Void in
                        if let hashImage = image {
                            self.presentImageView.image = nil
                            self.presentImageView.image = hashImage
                            self.addImageToStorage(image: hashImage)
                        }
                }
            }
        }
    }

    private func addImageToStorage(image: UIImage) {
        // check, is exist element with cpecific name in storage. If no exist, add more one.
        if !Imgur.imageStorage.contains(where: { $0.name == String(describing: rowIndex) }) {
            let image = Image(name: String(describing: rowIndex), data: image, isLoad: false)
            Imgur.imageStorage.append(image)
        }
    }

    func post(index: Int) {
        
        spinner.startAnimating()
        let image = Imgur.imageStorage[index]
        print("MyName on phone:", image.name)
        
        let dispatchGroup = DispatchGroup()
            Imgur.requestWith(image: image.data, name: image.name) { isLoaded in
                dispatchGroup.enter()
                if isLoaded {
                    self.spinner.stopAnimating()
                    dispatchGroup.leave()
                } else {
                    // setup Alert!
                }
            }
    }
}
