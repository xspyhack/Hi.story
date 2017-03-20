//
//  UIViewController+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 09/11/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import SafariServices

extension UIViewController: Identifiable {
    public var identifier: String {
        return String(describing: self)
    }
    
    public static var identifier: String {
        return String(describing: self)
    }
    
    static func instantiate(from storyboard: Storyboard) -> Self {
        return storyboard.viewController(of: self)
    }
}

extension Hi where Base: UIViewController {
    
    func open(_ url: URL, preferSafari: Bool = true) {
        if (url.scheme?.hasPrefix("http"))!, preferSafari {
            let safariViewController = SFSafariViewController(url: url)
            base.present(safariViewController, animated: true, completion: nil)
        } else {
            UIApplication.shared.open(url, options: [UIApplicationOpenURLOptionUniversalLinksOnly: true], completionHandler: nil)
        }
    }
    
    func canOpenURL(_ url: URL) -> Bool {
        return UIApplication.shared.canOpenURL(url)
    }
}
