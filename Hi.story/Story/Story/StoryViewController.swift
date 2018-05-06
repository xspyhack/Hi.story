//
//  StoryViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/30/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import WebKit
import Hikit

final class StoryViewController: BaseViewController {
    
    var viewModel: StoryViewModel?
    
    private var messageHandlerName = "StoryHandler"
    
    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: self.messageHandlerName)
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsLinkPreview = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        return webView
    }()
    
    private lazy var detailsItem: UIBarButtonItem = UIBarButtonItem()
    
    private var popoverTransitioningDelegate: PopoverTransitioningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsItem.image = UIImage.hi.navDetails
        navigationItem.rightBarButtonItem = detailsItem
        
        detailsItem.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.showsDetails()
            })
            .disposed(by: disposeBag)
        
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
    
    private func showsDetails() {
        guard let viewModel = viewModel else { return }
        
        let story = viewModel.story
        
        let viewController = Storyboard.details.viewController(of: DetailsViewController.self)
        viewController.viewModel = DetailsViewModel(story: story)
        
        viewController.showsLocationAction = { [weak self] location in
            self?.hi.open(location)
        }
        
        viewController.modalPresentationStyle = .custom
        viewController.modalTransitionStyle = .crossDissolve
        
        let size: CGSize
        if story.location != nil {
            size = CGSize(width: view.bounds.width - 70.0, height: 300.0)
        } else {
            size = CGSize(width: view.bounds.width - 80.0, height: 250.0)
        }
        
        let shadowAlpha: CGFloat = (webView.scrollView.contentOffset.y > (view.bounds.height / 2.0) || story.attachment == nil) ? 0.3 : 0.4
        
        let shadow = PopoverPresentationShadow(radius: 32.0, color: UIColor.black.withAlphaComponent(shadowAlpha))
        let context = PopoverPresentationContext(presentedContentSize: size, cornerRadius: 16.0, chromeAlpha: 0.0, shadow: shadow)
        self.popoverTransitioningDelegate = PopoverTransitioningDelegate(presentationContext: context)
        
        viewController.transitioningDelegate = popoverTransitioningDelegate
        
        self.present(viewController, animated: true, completion: nil)
    }
    
    private func display() {
        
        guard let viewModel = viewModel else { return }
        
        title = viewModel.story.title
        
        webView.loadHTMLString(viewModel.displayContents, baseURL: Bundle.main.bundleURL)
    }
}

extension StoryViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
}

extension StoryViewController: WKNavigationDelegate {
    
}

extension StoryViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == messageHandlerName {
            
        }
        print(message.name)
        print(message.body)
    }
}
