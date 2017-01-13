//
//  FeedViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import WebKit
import Hikit

final class FeedViewController: UIViewController {
    
    var viewModel: FeedViewModel?
    
    fileprivate var messageHandlerName = "FeedHandler"
    
    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: self.messageHandlerName)
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsLinkPreview = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        //webView.scrollView.contentInset.top = 64.0
        
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        
        display()
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
        
        guard let feed = viewModel?.feed, let story = feed.story else { return }
        
    
        display(story: story)
    }
    
    private func display(story: Story) {
        
        let html: String
        
        if let attachment = story.attachment {
           
            let base64 = UIImageJPEGRepresentation(CacheService.shared.retrieveImageInDiskCache(forKey: attachment.urlString)!, 1.0)?.base64EncodedString(options: .lineLength64Characters)
            
            let metadata = "data:image/png;base64,\(base64!)"
            html = "<html><head><title></title><meta charset='utf-8'><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\"><style>img{width:device-width !important;}</style></head><body><p><img src=\"\(metadata)\" /></p><h1>\(story.title)</h1><p>\(story.body)</p></body></html>"
        } else {
            html = "<html><head><title></title><meta charset='utf-8'><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\"></head><body><h1>\(story.title)</h1><p>\(story.body)</p></body></html>"
        }
        
        webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)

    }
}

extension FeedViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
}

extension FeedViewController: WKNavigationDelegate {
    
    
}

extension FeedViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == messageHandlerName {
            
        }
        print(message.name)
        print(message.body)
    }
}
