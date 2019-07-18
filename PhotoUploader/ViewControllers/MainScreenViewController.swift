//
//  ViewController.swift
//  PhotoUploader
//
//  Created by vit on 18/07/2019.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit
import Photos

struct Constants {
    static let cellIdentifier: String = "Cell"
    static let cellHeight: Double = 100.0
    static let cellWidth: Double = 100.0
}

class MainScreenViewController: UICollectionViewController {
    
    let photoViewModel = PhotosViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load images on start application
        photoViewModel.loadImageAssets { (result: PHFetchResult<AnyObject>?) in
            if result != nil {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } else {
                // TODO: setup Alert!
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoViewModel.imageResult?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        cell.asset = photoViewModel.imageResult?[indexPath.row] as? PHAsset
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainScreenViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.cellHeight, height: Constants.cellWidth)
    }
    
}
