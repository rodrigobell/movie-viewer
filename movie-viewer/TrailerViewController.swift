//
//  TrailerViewController.swift
//  movie-viewer
//
//  Created by Rodrigo Bell on 2/6/17.
//  Copyright © 2017 Rodrigo Bell. All rights reserved.
//

import UIKit
import WebKit

class TrailerViewController: UIViewController {
    
    var webView: WKWebView!
    
    var movieTitle: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: CGRect(x: 0, y: 20, width: 750, height: 1334))
        view.addSubview(webView)
        self.view.sendSubview(toBack: webView)
        
        let titleString = movieTitle.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let url: URL = URL(string: "https://www.youtube.com/results?search_query=\(titleString)")!
        let req: URLRequest = URLRequest(url: url)
        webView.load(req)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        self.dismiss(animated: true, completion: {});
    }
    
}
