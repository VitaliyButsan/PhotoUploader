//
//  PhotoModel.swift
//  PhotoUploader
//
//  Created by vit on 18/07/2019.
//  Copyright © 2019 vit. All rights reserved.
//

import Foundation
import Photos

class PhotosViewModel {
    
    // photo storage
    var imageResult: PHFetchResult<AnyObject>?
    
    // Requesting permission to user Photos
    func requestAccessToPhotos(authClosure: @escaping (PHAuthorizationStatus) -> ()) {
        PHPhotoLibrary.requestAuthorization { (authStatus: PHAuthorizationStatus) -> Void in
            authClosure(authStatus)
        }
    }
    
    // Load user photos
    func loadImageAssets(fetchClosure: @escaping (PHFetchResult<AnyObject>?) -> ()) {
        requestAccessToPhotos { (auth: PHAuthorizationStatus) in
            if auth == PHAuthorizationStatus.authorized {
                let fetchResult = PHAsset.fetchAssets(with: .image, options: nil) as? PHFetchResult<AnyObject>
                self.imageResult = fetchResult
                fetchClosure(fetchResult)
            } else {
                fetchClosure(nil)
            }
        }
    }
}
