//
//  LinksViewController.swift
//  PhotoUploader
//
//  Created by vit on 21/07/2019.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit

struct LinksVC_Constants {
    static let cellIdentifier: String = "LinkCellIdentifier"
    static let defaultTitleText: String = "No links yet"
}

class LinksViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    var mainTitleLabel = LinksVC_Constants.defaultTitleText
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel?.text = mainTitleLabel
        tableView.register(LinksTableViewCell.self, forCellReuseIdentifier: LinksVC_Constants.cellIdentifier)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension LinksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let imagesOnServer = Imgur.imageStorage.filter { $0.isLoad != false }
        return imagesOnServer.count
    }
}

// MARK: - UITableViewDataSource

extension LinksViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LinksVC_Constants.cellIdentifier) as! LinksTableViewCell
        cell.presentLink(forCellIndex: indexPath.row)
        return cell
    }
    
}
