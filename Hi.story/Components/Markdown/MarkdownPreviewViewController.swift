//
//  MarkdownPreviewViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 26/11/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import WebKit

class MarkdownPreviewViewController: UIViewController {
    
    //
    var markdownText: String = ""
    
    //
    fileprivate lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.allowsLinkPreview = true
        webView.navigationDelegate = self
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "webView" = webView,
        ]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: [], metrics: nil, views: views)
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(hConstraints)
        NSLayoutConstraint.activate(vConstraints)
    }
    
    private func displayMarkdown() {
        let html = 
    }
    
}

extension MarkdownPreviewViewController: WKWebViewNavigationDelegate {
    
}

