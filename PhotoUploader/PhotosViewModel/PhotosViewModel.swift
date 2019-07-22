//
//  PhotoModel.swift
//  PhotoUploader
//
//  Created by vit on 18/07/2019.
//  Copyright © 2019 vit. All rights reserved.
//

import Foundation
import Photos

protocol PhotoViewModelProtocol: class {
    func loadImagesAssets(completion: @escaping (Bool) -> Void)
    func changeImageIsLoading(index: Int, isLoading loadingState: Bool)
    func getImage(index: Int) -> UIImage?
    func getId(index: Int) -> Int
    func getSpinnerState(index: Int) -> Bool
    func getImagesQuantity() -> Int
}

class PhotosViewModel: PhotoViewModelProtocol {

    private struct ImageData {
        let image: UIImage?
        let id: Int
        var isLoading = false
        mutating func changeLoadingState(to state: Bool) {
            self.isLoading = state
        }
    }
    
    private var arrImageData: [ImageData] = []
    
    private func getAssetThembnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFit, options: option) { (result, info) -> Void in
            thumbnail = result!
        }
        return thumbnail
    }
    
    // MARK: - implementation PhotoViewModelProtocol functions
    
    // load user photos
    func loadImagesAssets(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { (authStatus: PHAuthorizationStatus) in
            if authStatus == PHAuthorizationStatus.authorized {
                let fetchResult = PHAsset.fetchAssets(with: .image, options: nil) as? PHFetchResult<AnyObject>
                var quantityImages = fetchResult?.count
                var wolker = 0
                while quantityImages ?? 0 > 0 {
                    if let asset = fetchResult?[wolker] as? PHAsset {
                        self.arrImageData.append(ImageData(image: self.getAssetThembnail(asset: asset), id: wolker, isLoading: false))
                        quantityImages! -= 1
                        wolker += 1
                    }
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func changeImageIsLoading(index: Int, isLoading loadingState: Bool) {
        self.arrImageData[index].changeLoadingState(to: loadingState)
    }
    
    func getImage(index: Int) -> UIImage? {
        return self.arrImageData[index].image
    }
    
    func getId(index: Int) -> Int {
        return self.arrImageData[index].id
    }
    
    func getSpinnerState(index: Int) -> Bool {
        return self.arrImageData[index].isLoading
    }
    
    func getImagesQuantity() -> Int {
        return self.arrImageData.count
    }
}
