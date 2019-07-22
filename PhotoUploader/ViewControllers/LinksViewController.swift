//
//  LinksViewController.swift
//  PhotoUploader
//
//  Created by vit on 21/07/2019.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit

class LinksViewController: UIViewController {
    
    struct Constants {
        static let cellIdentifier: String = "LinkCellIdentifier"
        static let defaultTitleText: String = "No links yet"
        static let webVCIdentifier: String = "WebViewSegue"
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    var mainTitleLabel = Constants.defaultTitleText
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel?.text = mainTitleLabel
        tableView.register(LinksTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension LinksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LinksTableViewCell
        let photoLink = cell.textLabel?.text ?? ""
        performSegue(withIdentifier: Constants.webVCIdentifier, sender: URL(string: photoLink))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let webViewController = segue.destination as? WebViewController
        webViewController?.photoLink = sender as? URL
    }
}

// MARK: - UITableViewDataSource

extension LinksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let storedDataDict = UserDefaults.standard.dictionary(forKey: Imgur.Constants.dictStorage) {
            return storedDataDict.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as! LinksTableViewCell
        cell.presentLink(forCellIndex: indexPath.row)
        
        return cell
    }
    
}
