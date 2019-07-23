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
        static let storyboardIdentifier: String = "LinksViewController"
        static let textForLinksVCTitle: String = "Images on server"
        static let cellIdentifier: String = "PhotoCell"
        static let alertTitle: String = "ERROR!"
        static let alertMessage: String = "don't loaded on server. Try later"
        static let alertButtonTitle: String = "Ok"
        static let complete: Notification.Name = Notification.Name.init("complete")
        static let failure: Notification.Name = Notification.Name.init("failure")
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
        static var lastLoadsComplete: Bool = true
        static var responsesAmount: Int = 0
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
        NotificationCenter.default.addObserver(self, selector: #selector(makeRequest), name: Constants.complete, object: nil)

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
        if Storage.linksAndNamesStorageIsExist() {
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        guard let image = self.photoViewModelDelegate?.getImage(index: indexPath.row) else { return }
        guard let name = self.photoViewModelDelegate?.getId(index: indexPath.row) else { return }
        
        if Variables.lastLoadsComplete {
            Variables.lastLoadsComplete = false
            
            Imgur.requestWith(image: image, name: String(name)) { (responseName, responsesAmount) in
                guard let retrievedName = responseName else {
                    // remove spinner
                    self.photoViewModelDelegate?.changeImageIsLoading(index: name, isLoading: false)
                    let tempIndexPath = IndexPath(row: name, section: indexPath.section)
                    DispatchQueue.main.async {
                        self.collectionView.reloadItems(at: [tempIndexPath])
                    }
                    Variables.responsesAmount = responsesAmount
                    return
                }
                
                // write result to db
                Storage.writeToSuccessResponsesNamesStorage(name: retrievedName)
                Variables.responsesAmount = responsesAmount
                
                if responsesAmount == Variables.bufferOfIndices.count {
                    Variables.lastLoadsComplete = true
                }
                
                // remove spinner
                self.photoViewModelDelegate?.changeImageIsLoading(index: name, isLoading: false)
                let tempIndexPath = IndexPath(row: name, section: indexPath.section)
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [tempIndexPath])
                }
            }
        }
    }
    
    // to continue make requests by notifications
    @objc func makeRequest(_ notification: Notification) {
        
        if notification.name == Constants.complete, Variables.responsesAmount < Variables.bufferOfIndices.count - 1 {
            
            let indexForNextRequest = Variables.bufferOfIndices[Variables.responsesAmount + 1]
            guard let image = self.photoViewModelDelegate?.getImage(index: indexForNextRequest) else { return }
            guard let name = self.photoViewModelDelegate?.getId(index: indexForNextRequest) else { return }

            Imgur.requestWith(image: image, name: String(name)) { (responseName, responsesAmount) in
                guard let retrievedName = responseName else {
                    // remove spinner
                    self.photoViewModelDelegate?.changeImageIsLoading(index: Int(name), isLoading: false)
                    let tempIndexPath = IndexPath(row: Int(name), section: 0)
                    DispatchQueue.main.async {
                        self.collectionView.reloadItems(at: [tempIndexPath])
                    }
                    Variables.responsesAmount = responsesAmount
                    return
                }
                
                // write result to db
                Storage.writeToSuccessResponsesNamesStorage(name: retrievedName)
                Variables.responsesAmount = responsesAmount
                
                if responsesAmount == Variables.bufferOfIndices.count {
                    Variables.lastLoadsComplete = true
                }
                
                // remove spinner
                self.photoViewModelDelegate?.changeImageIsLoading(index: Int(name), isLoading: false)
                let tempIndexPath = IndexPath(row: Int(name), section: 0)
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [tempIndexPath])
                }
            }
            
        } else if notification.name == Constants.failure {
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
