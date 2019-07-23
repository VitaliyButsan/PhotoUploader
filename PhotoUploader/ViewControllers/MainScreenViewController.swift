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
    
    private struct Constants {
        static let storyboardIdentifier: String = "LinksViewController"
        static let textForLinksVCTitle: String = "Images on server"
        static let cellIdentifier: String = "PhotoCell"
        static let alertTitle: String = "Something wrong!"
        static let alertMessage: String = "Image don't loaded on server. Try later"
        static let alertButtonTitle: String = "Ok"
        static let complete: Notification.Name = Notification.Name.init("complete")
        static let failure: Notification.Name = Notification.Name.init("failure")
        static let defaultValue: Int = 0
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
    
    private struct Variables {
        static var lastLoadsComplete: Bool = true
        static var responsesAmount: Int = 0
        static var bufferOfIndices: [Int] = []
        static var numberOfCells: Int = OrientationMode.Portrait.rawValue
        static var numberOfCellsSpacings: Int = OrientationMode.Portrait.rawValue
        static var sectionLeadingIndent: CGFloat = Constants.defaultSectionLeadingIndent
        static var sectionTrailingIndent: CGFloat = Constants.defaultSectionTrailingIndent
        static var sectionLeadingTrailingIndent: CGFloat = Constants.defaultSectionLeadingIndent + Constants.defaultSectionTrailingIndent
    }
    
    private var photoViewModelDelegate: PhotoViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoViewModelDelegate = PhotosViewModel()
        NotificationCenter.default.addObserver(self, selector: #selector(makeRequest), name: Constants.complete, object: nil)

        // get images on start application
        photoViewModelDelegate?.loadImagesAssets() { _ in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    // present LinksVC
    @IBAction func linksButtonTapped(_ sender: UIBarButtonItem) {
        let linksViewController = storyboard?.instantiateViewController(withIdentifier: Constants.storyboardIdentifier) as! LinksViewController
        // if db exist, change title of LinksVC
        if Storage.linksAndNamesStorageIsExist() {
            linksViewController.mainTitleText = Constants.textForLinksVCTitle
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
        
        // set number of cells in row dependent of iPad orientation
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
        // reload cell to show spinner on it
        DispatchQueue.main.async {
            self.collectionView.reloadItems(at: [indexPath])
        }
        
        // write tapped index of cell to buffer
        Variables.bufferOfIndices.append(indexPath.row)
        // image and name for request
        guard let image = self.photoViewModelDelegate?.getImage(index: indexPath.row) else { return }
        guard let name = self.photoViewModelDelegate?.getId(index: indexPath.row) else { return }
        
        // check, is completed loads from buffer
        if Variables.lastLoadsComplete {
            Variables.lastLoadsComplete = false
            // send image to server
            Imgur.requestWith(image: image, name: String(name)) { (responseName, responsesAmount) in
                guard let retrievedName = responseName else {
                    // stop spinner
                    self.photoViewModelDelegate?.changeImageIsLoading(index: name, isLoading: false)
                    DispatchQueue.main.async {
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                    // call alert
                    self.alertHandler(withTitle: Constants.alertTitle, withMessage: Constants.alertMessage)
                    Variables.responsesAmount = responsesAmount
                    return
                }
                
                // write result to db
                Storage.writeToSuccessResponsesNamesStorage(name: retrievedName)
                Variables.responsesAmount = responsesAmount
                
                // check completion of all requests
                if responsesAmount == Variables.bufferOfIndices.count {
                    Variables.lastLoadsComplete = true
                }
                
                // stop spinner
                self.photoViewModelDelegate?.changeImageIsLoading(index: name, isLoading: false)
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }
    
    // continue make requests by notifications
    @objc func makeRequest(_ notification: Notification) {
        
        if Variables.responsesAmount < Variables.bufferOfIndices.count - 1 {
            
            let indexForNextRequest = Variables.bufferOfIndices[Variables.responsesAmount + 1]
            // image and name for request
            guard let image = self.photoViewModelDelegate?.getImage(index: indexForNextRequest) else { return }
            guard let name = self.photoViewModelDelegate?.getId(index: indexForNextRequest) else { return }

            if notification.name == Constants.complete {
                Imgur.requestWith(image: image, name: String(name)) { (responseName, responsesAmount) in
                    guard let retrievedName = responseName else {
                        // remove spinner
                        self.photoViewModelDelegate?.changeImageIsLoading(index: Int(name), isLoading: false)
                        let tempIndexPath = IndexPath(row: Int(name), section: 0)
                        DispatchQueue.main.async {
                            self.collectionView.reloadItems(at: [tempIndexPath])
                        }
                        // check completion of all requests
                        Variables.responsesAmount = responsesAmount
                        return
                    }
                    
                    // write result to db
                    Storage.writeToSuccessResponsesNamesStorage(name: retrievedName)
                    Variables.responsesAmount = responsesAmount
                    
                    // check completion of all requests
                    if responsesAmount == Variables.bufferOfIndices.count {
                        Variables.lastLoadsComplete = true
                    }
                }
                
            } else if notification.name == Constants.failure {
                alertHandler(withTitle: Constants.alertTitle, withMessage: Constants.alertMessage)
            }
            
            // stop spinner
            self.photoViewModelDelegate?.changeImageIsLoading(index: Int(name), isLoading: false)
            let tempIndexPath = IndexPath(row: Int(name), section: 0)
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [tempIndexPath])
            }
        }
    }
    
    private func alertHandler(withTitle title: String, withMessage message: String, titleForActionButton titleOfButton: String = Constants.alertButtonTitle) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: titleOfButton, style: .default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension MainScreenViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoViewModelDelegate?.getImagesQuantity() ?? Constants.defaultValue
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        // show image
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
        
        // set number of cells in row dependent iPhone orientation
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
