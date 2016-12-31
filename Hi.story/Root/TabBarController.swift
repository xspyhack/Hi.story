//
//  TabBarController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class TabBarController: UITabBarController {
    
    enum Tab: Int {
        case home = 0
        case feeds
        case matters
        case central
    }
    
    lazy var selectedTab: Listenable<Tab> = {
        
        return Listenable<Tab>(.home) { tab in
            self.selectedIndex = tab.rawValue
        }
    }()
    
    fileprivate var previousTab: Tab = .home

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        delegate = self
        
        tabBar.tintColor = UIColor.hi.tint
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
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        guard let tab = Tab(rawValue: selectedIndex),
            let nvc = viewController as? UINavigationController
            else {
                return
        }
        
        if tab != previousTab {
            // fire
            selectedTab.value = tab
            
            previousTab = tab
            return
        }
        
        if let vc = nvc.topViewController as? Refreshable {
            vc.refresh()
        }
    }
}
