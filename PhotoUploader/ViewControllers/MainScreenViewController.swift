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
    static let defaultCount: Int = 0
    static let minCellSpacing: CGFloat = 3.0
    static let defaultSectionLeadingIndent: CGFloat = 4.0
    static let defaultSectionTrailingIndent: CGFloat = 4.0
    static let sectionTopIndent: CGFloat = 4.0
    static let sectionBottomIndent: CGFloat = 4.0
}


enum OrientationMode: Int {
    case Portrait = 3
    case Landscape = 5
}

struct Variables {
    static var numberOfCells: Int = OrientationMode.Portrait.rawValue
    static var numberOfCellsSpacings: Int = OrientationMode.Portrait.rawValue
    static var sectionLeadingIndent: CGFloat = Constants.defaultSectionLeadingIndent
    static var sectionTrailingIndent: CGFloat = Constants.defaultSectionTrailingIndent
    static var sectionLeadingTrailingIndent: CGFloat = Constants.defaultSectionLeadingIndent + Constants.defaultSectionTrailingIndent
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
        return photoViewModel.imageResult?.count ?? Constants.defaultCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        cell.asset = photoViewModel.imageResult?[indexPath.row] as? PHAsset
        return cell
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.minCellSpacing
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        // Determine iPad orientation
        if screenHeight > screenWidth {
            Variables.numberOfCells = OrientationMode.Landscape.rawValue
            Variables.numberOfCellsSpacings = OrientationMode.Landscape.rawValue
            collectionView.reloadData()
        } else {
            Variables.numberOfCells = OrientationMode.Portrait.rawValue
            Variables.numberOfCellsSpacings = OrientationMode.Portrait.rawValue
            collectionView.reloadData()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = UIEdgeInsets(top: Constants.sectionTopIndent,
                                 left: Variables.sectionLeadingIndent,
                                 bottom: Constants.sectionBottomIndent,
                                 right: Variables.sectionTrailingIndent)
        return inset
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainScreenViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let orientation = UIApplication.shared.statusBarOrientation
        
        // Determine iPhone orientation
        if orientation == .landscapeRight {
            Variables.numberOfCells = OrientationMode.Landscape.rawValue
            Variables.numberOfCellsSpacings = OrientationMode.Landscape.rawValue
        } else if orientation == .landscapeLeft {
            Variables.numberOfCells = OrientationMode.Landscape.rawValue
            Variables.numberOfCellsSpacings = OrientationMode.Landscape.rawValue
        } else {
            Variables.numberOfCells = OrientationMode.Portrait.rawValue
            Variables.numberOfCellsSpacings = OrientationMode.Portrait.rawValue
        }

        let cellWidth: CGFloat = (view.frame.width - Variables.sectionLeadingTrailingIndent - Constants.minCellSpacing * CGFloat(Variables.numberOfCellsSpacings)) / CGFloat(Variables.numberOfCells)

        return CGSize(width: cellWidth, height: cellWidth)
    }
    
}
