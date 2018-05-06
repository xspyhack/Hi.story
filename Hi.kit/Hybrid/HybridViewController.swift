//
//  HybridViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 07/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Hicache
import WebKit
import RxSwift
import RxCocoa

public class HybridViewController: UIViewController {
    
    @objc
    public var webTitle: String? {
        didSet {
            title = webTitle
            changedTitle?(webTitle)
        }
    }
    
    public var changedTitle: ((String?) -> Void)? = nil
    
    public var fadeIn: Bool = true
    
    public private(set) lazy var webView: HybridWebView = {
        let configuration = WKWebViewConfiguration()
        if #available(iOS 11.0, *) {
            let urlSchemeHandler = HybridURLSchemeHandler(urlScheme: self.urlScheme)
            configuration.setURLSchemeHandler(urlSchemeHandler, forURLScheme: self.urlScheme)
        } else {

        }
        let webView = HybridWebView(frame: .zero, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsLinkPreview = true
        
        return webView
    }()
    
    private let disposeBag = DisposeBag()
    
    private var urlScheme: String
    
    public init(urlScheme: String = "hybrid") {
        self.urlScheme = urlScheme
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        NSLayoutConstraint.activate(webView.hi.edges())
        
        webView.backgroundColor = UIColor.white
        webView.alpha = 0.0
        view.backgroundColor = UIColor.white
        
        startObserving()
    }
    
    public func load(_ string: String, baseURL: URL?) {
        webView.loadHTMLString(string, baseURL: nil)
    }
    
    public func load(_ request: URLRequest) {
        webView.load(request)
    }
    
    public func load(_ url: URL) {
        if url.isFileURL {
            load(fileURL: url)
        } else {
            load(URLRequest(url: url))
        }
    }
    
    public func load(fileURL: URL) {
        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
    }
}

extension HybridViewController {
    
    private func startObserving() {
        webView.rx.title
            .share(replay: 1)
            .subscribe(onNext: { [weak self] title in
                self?.webTitle = title
            })
            .disposed(by: disposeBag)
        
        webView.rx.estimatedProgress
            .filter { $0 >= 1.0 }
            .do(onNext: { [weak webView] _ in
                UIView.animate(withDuration: 0.25) {
                    webView?.alpha = 1.0
                }
            })
            .subscribe(onNext: { progress in
            })
            .disposed(by: disposeBag)
    }
    
    private func showError() {
        
    }
}

extension HybridViewController: WKUIDelegate {
 
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        // timeout
        let alertController = UIAlertController(title: webView.title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { action in
        })
        
        present(alertController, animated: true) {
            completionHandler()
        }
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        // timeout
        let alertController = UIAlertController(title: webView.title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { action in
            completionHandler(true)
        })
        
        alertController.addAction(UIAlertAction(title: "NO", style: .cancel) { action in
            completionHandler(false)
        })
        
        present(alertController, animated: true) {
        }
    }
}

extension HybridViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        //
    }
}
