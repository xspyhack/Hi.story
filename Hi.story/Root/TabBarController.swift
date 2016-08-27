//
//  TabBarController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    enum Tab: Int {
        case Home = 0
        case Feeds
        case Collections
        case Profile
    }
    
    var selectedTab: Tab = .Home {
        didSet {
            selectedIndex = selectedTab.rawValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        delegate = self
        
        tabBar.tintColor = UIColor(hex: Defaults.Color.tintColor)
        configureItem()
    }

    private func configureItem() {
        guard let items = tabBar.items else {
            return
        }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            item.title = nil
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var tabBarFrame = tabBar.frame
        tabBarFrame.size.height = Defaults.tabBarHeight
        tabBarFrame.origin.y = view.frame.height - Defaults.tabBarHeight
        tabBar.frame = tabBarFrame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        guard let tab = Tab(rawValue: selectedIndex) else {
            return false
        }
        
        if tab != selectedTab {
            return true
        }
        
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        guard let tab = Tab(rawValue: selectedIndex),
            nvc = viewController as? UINavigationController
            else {
                return
        }
        
        if tab != selectedTab {
            selectedTab = tab
            return
        }
        
        if let vc = nvc.topViewController as? Refreshable {
            vc.refresh()
        }
    }
}
