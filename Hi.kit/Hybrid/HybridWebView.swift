//
//  HybridWebView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 07/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import WebKit

public class HybridWebView: WKWebView {
    
    /*
    public convenience init(frame: CGRect) {
        let configuration = WKWebViewConfiguration()
        for cookie in HTTPCookieStorage.shared.cookies ?? [] {
            if #available(iOS 11.0, *) {
                configuration.websiteDataStore.httpCookieStore.setCookie(cookie, completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        self.init(frame: frame, configuration: configuration)
    }
     */
    
    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setBodyColor(_ color: UIColor) {
        guard let hex = color.hi.hex else {
            return
        }
        evaluateJavaScript("document.body.style.backgroundColor = '\(hex)'", completionHandler: nil)
    }
}
