//
//  TabBarCoordinator.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/03/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

struct TabBarCoordinator: Coordinator {
    
    let tabBarController: TabBarController
    
    let feedCoordinator: FeedCoordinator
    
    init(root vc: TabBarController) {
        self.tabBarController = vc
        
        self.feedCoordinator = FeedCoordinator()
    }
    
    func start() {
        // select feed tab
    }
    
    public func popToRoot(animated: Bool = true) {
        if let nvc = self.tabBarController.selectedViewController as? UINavigationController {
            if nvc.viewControllers.count > 1 {
                nvc.popToRootViewController(animated: animated)
            }
        }
    }
    
    public func select(with coordinator: FeedCoordinator) {
        
    }
}
