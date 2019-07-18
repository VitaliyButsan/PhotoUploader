//
//  PhotoCollectionViewCell.swift
//  PhotoUploader
//
//  Created by vit on 18/07/2019.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var presentImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    func setupViews() {
        backgroundColor = .brown
    }
    
    var asset: PHAsset? {
        didSet {
            if let hashAsset = asset {
                PHImageManager.default().requestImage(for: hashAsset, targetSize: presentImageView.frame.size, contentMode: .aspectFill, options: nil) { (image: UIImage?, dict: [AnyHashable:Any]?) -> Void in
                        if let hashImage = image {
                            self.presentImageView.image = hashImage
                        }
                }
            }
        }
    }
}
