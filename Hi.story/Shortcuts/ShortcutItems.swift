//
//  ShortcutItems.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 6/19/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

func configureShortcuts() {
    
    var shortcutItems = [UIApplicationShortcutItem]()

    do {
        let type = ShortcutType.history.rawValue
        
        let item = UIApplicationShortcutItem(
            type: type,
            localizedTitle: NSLocalizedString("History", comment: ""),
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(type: .home),
            userInfo: nil
        )
        
        shortcutItems.append(item)
    }
    
    do {
        let type = ShortcutType.newFeed.rawValue
        
        let item = UIApplicationShortcutItem(
            type: type,
            localizedTitle: NSLocalizedString("New Feed", comment: ""),
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(templateImageName: "tab_feeds_selected"),
            userInfo: nil
        )
        
        shortcutItems.append(item)
    }
    
    do {
        let type = ShortcutType.newMatter.rawValue
        
        let item = UIApplicationShortcutItem(
            type: type,
            localizedTitle: NSLocalizedString("New Matter", comment: ""),
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(type: .compose),
            userInfo: nil
        )
        
        shortcutItems.append(item)
    }
    
    UIApplication.shared.shortcutItems = shortcutItems
}

func tryToHandleQuickAction(shortcutItem: UIApplicationShortcutItem, inWindow window: UIWindow) {
    
    guard let shortcutType = ShortcutType(rawValue: shortcutItem.type) else {
        return
    }
    
    guard let tabBarController = window.rootViewController as? TabBarController else {
        return
    }
    
    if let nvc = tabBarController.selectedViewController as? UINavigationController {
        if nvc.viewControllers.count > 1 {
            nvc.popToRootViewController(animated: false)
        }
    }
    
    switch shortcutType {
    case .history:
        tabBarController.selectedTab.value = .home
        if let nvc = tabBarController.selectedViewController as? UINavigationController {
            if let vc = nvc.topViewController as? HomeViewController {
                //vc.tryToTellStory()
            }
        }
    case .newFeed:
        tabBarController.selectedTab.value = .feeds
        if let nvc = tabBarController.selectedViewController as? UINavigationController {
            if let vc = nvc.topViewController as? FeedsViewController {
                vc.tryToAddNewFeed()
            }
        }
    case .newMatter:
        tabBarController.selectedTab.value = .matters
        if let nvc = tabBarController.selectedViewController as? UINavigationController {
            if let vc = nvc.topViewController as? MattersViewController {
                vc.tryToAddNewMatter()
            }
        }
    }
}

func clearDynamicShortcuts() {
    UIApplication.shared.shortcutItems = nil
}
