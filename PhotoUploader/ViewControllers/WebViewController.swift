//
//  WebViewController.swift
//  PhotoUploader
//
//  Created by vit on 21/07/2019.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    var photoLink: URL?
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        request()
    }

    private func request() {
        guard let url = photoLink else { return }
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
