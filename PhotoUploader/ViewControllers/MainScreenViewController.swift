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
    static let storyboardIdentifier: String = "LinksViewController"
    static let textForLinksVCTitle: String = "Images on server"
    static let cellIdentifier: String = "PhotoCell"
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

    @IBAction func linksButtonTapped(_ sender: UIBarButtonItem) {
        let linksViewController = storyboard?.instantiateViewController(withIdentifier: Constants.storyboardIdentifier) as! LinksViewController
        
        if Imgur.imageStorage.contains(where: { $0.isLoad == true }) {
            linksViewController.mainTitleLabel = Constants.textForLinksVCTitle
        }
        navigationController?.present(linksViewController, animated: true, completion: nil)
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.minCellSpacing
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        cell.post(index: indexPath.row)
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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoViewModel.imageResult?.count ?? Constants.defaultCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        cell.rowIndex = indexPath.row
        cell.asset = photoViewModel.imageResult?[indexPath.row] as? PHAsset
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainScreenViewController: UICollectionViewDelegateFlowLayout {
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Determine iPhone orientation
        if UIDevice.current.orientation.isLandscape {
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
