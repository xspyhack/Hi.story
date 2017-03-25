//
//  UIStoryBoard+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

extension UIStoryboard {
    
    enum Storyboard: String {
        case main
        case matter
        case home
        case central
        case feeds
        
        var value: String {
            return self.rawValue.capitalized
        }
    }
}

extension Hi where Base: UIStoryboard {
    
    static func storyboard(_ board: UIStoryboard.Storyboard) -> UIStoryboard {
        return UIStoryboard(name: board.value, bundle: nil)
    }
}

enum Storyboard: String {
    
    case main
    case home
    
    case feeds
    case newFeed
    case feed
    
    case matters
    case newMatter
    case matter

    case central
    
    case profile
    
    case editProfile
    
    case details
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue.capitalized, bundle: nil)
    }
    
    func viewController<T: UIViewController>(of viewControllerType: T.Type) -> T {
        
        return instance.instantiateViewController(withIdentifier: "\(T.self)") as! T
    }
    
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
    
    func navigationController(with identifier: String) -> UIViewController {
        return instance.instantiateViewController(withIdentifier: identifier)
    }
}
