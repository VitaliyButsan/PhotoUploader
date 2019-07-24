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
    
    private func getAssetThumbnail(asset: PHAsset) -> UIImage {
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
                guard let fetchResult = PHAsset.fetchAssets(with: .image, options: nil) as? PHFetchResult<AnyObject> else { return }
                var walker = 0
                while walker <= fetchResult.count - 1 {
                    if let asset = fetchResult[walker] as? PHAsset {
                        self.arrImageData.append(ImageData(image: self.getAssetThumbnail(asset: asset), id: walker, isLoading: false))
                        walker += 1
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
