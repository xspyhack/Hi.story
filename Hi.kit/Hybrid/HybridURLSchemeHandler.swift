//
//  HybridURLSchemeHandler.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 07/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import WebKit
import Hicache

@available(iOS 11.0, *)
final class HybridURLSchemeHandler: NSObject, WKURLSchemeHandler {
    
    let urlScheme: String
    
    private var dataTask: URLSessionTask?
    
    init(urlScheme: String) {
        self.urlScheme = urlScheme
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        
        let request = urlSchemeTask.request

        guard let url = request.url else {
            urlSchemeTask.didFailWithError(NSError(domain: NSURLErrorDomain, code: -100, userInfo: nil))
            return
        }
        
        let original = url.absoluteString.replacingOccurrences(of: urlScheme, with: "https")

        if ImageCache.shared.contains(forKey: original) {
            ImageCache.shared.retrieve(forKey: original) { image, key in
                guard let image = image, let data = UIImageJPEGRepresentation(image, 0.9) else {
                    urlSchemeTask.didFailWithError(NSError(domain: NSURLErrorDomain, code: -404, userInfo: nil))
                    return
                }
                
                let response = URLResponse(url: url, mimeType: "image/jpeg", expectedContentLength: data.count, textEncodingName: nil)
                urlSchemeTask.didReceive(response)
                urlSchemeTask.didReceive(data)
                urlSchemeTask.didFinish()
            }
        } else {
            let newRequest = URLRequest(url: URL(string: original)!)
            dataTask = URLSession.shared.dataTask(with: newRequest) { data, response, error in
                guard let data = data, let response = response else {
                    SafeDispatch.async {
                        urlSchemeTask.didFailWithError(error ?? NSError(domain: NSURLErrorDomain, code: -404, userInfo: nil))
                    }
                    return
                }
                
                SafeDispatch.async {
                    urlSchemeTask.didReceive(response)
                    urlSchemeTask.didReceive(data)
                    urlSchemeTask.didFinish()
                }
            }
            dataTask?.resume()
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        dataTask?.cancel()
    }
}
