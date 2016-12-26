//
//  FeedViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import WebKit

class FeedViewController: UIViewController {
    
    var viewModel: FeedViewModel?
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.allowsLinkPreview = true
        webView.navigationDelegate = self
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func setupWebView() {
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "webView": webView,
        ]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: [], metrics: nil, views: views)
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(hConstraints)
        NSLayoutConstraint.activate(vConstraints)
    }
    
    private func display() {
        
        let html = ""
        
        webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
    }
}

extension FeedViewController: WKNavigationDelegate {
    
    
}
