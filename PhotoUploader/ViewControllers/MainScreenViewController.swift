//
//  ViewController.swift
//  PhotoUploader
//
//  Created by vit on 18/07/2019.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit
import Photos


class MainScreenViewController: UICollectionViewController {
    

    struct Constants {
        static let successResponsesStorageKey: String = "successResponsesNamesStorage"
        static let storyboardIdentifier: String = "LinksViewController"
        static let textForLinksVCTitle: String = "Images on server"
        static let cellIdentifier: String = "PhotoCell"
        static let alertTitle: String = "ERROR!"
        static let alertMessage: String = "don't loaded on server. Try later"
        static let alertButtonTitle: String = "Ok"
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
        static var lastLoadIsComplete: Bool = true
        static var successResponsesAmount: Int = 0
        static var loadedNames: [String] = []
        static var bufferOfIndices: [Int] = []
        static var numberOfCells: Int = OrientationMode.Portrait.rawValue
        static var numberOfCellsSpacings: Int = OrientationMode.Portrait.rawValue
        static var sectionLeadingIndent: CGFloat = Constants.defaultSectionLeadingIndent
        static var sectionTrailingIndent: CGFloat = Constants.defaultSectionTrailingIndent
        static var sectionLeadingTrailingIndent: CGFloat = Constants.defaultSectionLeadingIndent + Constants.defaultSectionTrailingIndent
    }
    
    var photoViewModelDelegate: PhotoViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoViewModelDelegate = PhotosViewModel()
        NotificationCenter.default.addObserver(self, selector: #selector(makeRequest), name: Notification.Name.init(rawValue: "complete"), object: nil)
        /// TO_DO: REMOVE OBSERVERS!!!
        // load images on start application
        photoViewModelDelegate?.loadImagesAssets() { _ in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    @IBAction func linksButtonTapped(_ sender: UIBarButtonItem) {
        let linksViewController = storyboard?.instantiateViewController(withIdentifier: Constants.storyboardIdentifier) as! LinksViewController
        // if db exist, change title of LinksVC
        if let dict = UserDefaults.standard.dictionary(forKey: Imgur.Constants.dictStorage), dict.count > 0 {
            linksViewController.mainTitleLabel = Constants.textForLinksVCTitle
        }
        
        UserDefaults.standard.set(Variables.loadedNames, forKey: Constants.successResponsesStorageKey)
        navigationController?.present(linksViewController, animated: true, completion: nil)
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


// MARK: - UICollectionViewDelegate

extension MainScreenViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.photoViewModelDelegate?.changeImageIsLoading(index: indexPath.row, isLoading: true)
        print("MyName on phone:", self.photoViewModelDelegate?.getId(index: indexPath.row) ?? "")
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        Variables.bufferOfIndices.append(indexPath.row)
        let image = self.photoViewModelDelegate?.getImage(index: indexPath.row)
        let name = self.photoViewModelDelegate?.getId(index: indexPath.row)
        
        if Variables.lastLoadIsComplete {
            Variables.lastLoadIsComplete = false
            
            Imgur.requestWith(image: image!, name: String(name!)) { (responseName, responsesAmount) in
                guard let name = responseName else { return }
                Variables.loadedNames.append(name)
                Variables.successResponsesAmount = responsesAmount
                
                if responsesAmount == Variables.bufferOfIndices.count {
                    Variables.lastLoadIsComplete = true
                }
            }
        }
    }
    
    @objc func makeRequest(_ notification: Notification) {
        
        if notification.name.rawValue == "complete", Variables.successResponsesAmount < Variables.bufferOfIndices.count - 1 {
            // STOP spinner, for this change "isLoading" state of loaded image, and reloadData()
            let indexForNextRequest = Variables.bufferOfIndices[Variables.successResponsesAmount + 1]
            let image = self.photoViewModelDelegate?.getImage(index: indexForNextRequest)
            let name = self.photoViewModelDelegate?.getId(index: indexForNextRequest)
            
            Imgur.requestWith(image: image!, name: String(name!)) { (responseName, responsesAmount) in
                guard let name = responseName else { return }
                Variables.loadedNames.append(name)
                Variables.successResponsesAmount = responsesAmount
                
                if responsesAmount == Variables.bufferOfIndices.count {
                    Variables.lastLoadIsComplete = true
                }
            }
        } else if notification.name.rawValue == "failure" {
            alertHandler(withTitle: Constants.alertTitle, withMessage: Constants.alertMessage, titleForActionButton: Constants.alertButtonTitle)
        }
    }
    
    func alertHandler(withTitle title: String, withMessage message: String, titleForActionButton titleOfButton: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: titleOfButton, style: .default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension MainScreenViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoViewModelDelegate?.getImagesQuantity() ?? Constants.defaultCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        cell.presentImageView.image = self.photoViewModelDelegate?.getImage(index: indexPath.row)
        // check image is dowloadable
        if let spinnerState = self.photoViewModelDelegate?.getSpinnerState(index: indexPath.row) {
            cell.spinnerState = spinnerState
        }
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
