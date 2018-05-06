//
//  WKWebview+Rx.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 14/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import WebKit
import RxSwift

extension Reactive where Base: WKWebView {
    /**
     Reactive wrapper for `title` property
     */
    public var title: Observable<String?> {
        return self.observeWeakly(String.self, #keyPath(WKWebView.title))
    }
    
    /**
     Reactive wrapper for `loading` property.
     */
    public var loading: Observable<Bool> {
        return self.observeWeakly(Bool.self, #keyPath(WKWebView.loading))
            .map { $0 ?? false }
    }
    
    /**
     Reactive wrapper for `estimatedProgress` property.
     */
    public var estimatedProgress: Observable<Double> {
        return self.observeWeakly(Double.self, #keyPath(WKWebView.estimatedProgress))
            .map { $0 ?? 0.0 }
    }
    
    /**
     Reactive wrapper for `url` property.
     */
    public var url: Observable<URL?> {
        return self.observeWeakly(URL.self, #keyPath(WKWebView.URL))
    }
    
    
    /**
     Reactive wrapper for `canGoBack` property.
     */
    public var canGoBack: Observable<Bool> {
        return self.observeWeakly(Bool.self, #keyPath(WKWebView.canGoBack))
            .map { $0 ?? false }
    }
    
    /**
     Reactive wrapper for `canGoForward` property.
     */
    public var canGoForward: Observable<Bool> {
        return self.observeWeakly(Bool.self, #keyPath(WKWebView.canGoForward))
            .map { $0 ?? false }
    }
}

