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
        let type = ShortcutType.NewStory.rawValue
        
        let item = UIApplicationShortcutItem(
            type: type,
            localizedTitle: NSLocalizedString("New Story", comment: ""),
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(type: .Compose),
            userInfo: nil
        )
        
        shortcutItems.append(item)
    }
    
    do {
        let type = ShortcutType.Feeds.rawValue
        
        let item = UIApplicationShortcutItem(
            type: type,
            localizedTitle: NSLocalizedString("Feeds", comment: ""),
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(templateImageName: "tab_feeds_selected"),
            userInfo: nil
        )
        
        shortcutItems.append(item)
    }
    
    do {
        let type = ShortcutType.Collections.rawValue
        
        let item = UIApplicationShortcutItem(
            type: type,
            localizedTitle: NSLocalizedString("Collections", comment: ""),
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(templateImageName: "tab_collections_selected"),
            userInfo: nil
        )
        
        shortcutItems.append(item)
    }
    
    UIApplication.sharedApplication().shortcutItems = shortcutItems
}

func tryHandleQuickAction(shortcutItem shortcutItem: UIApplicationShortcutItem, inWindow window: UIWindow) {
    
    guard let shortcutType = ShortcutType(rawValue: shortcutItem.type) else {
        return
    }
    
    guard let tabBarController = window.rootViewController as? TabBarController else {
        return
    }
    
    if let nvc = tabBarController.selectedViewController as? UINavigationController {
        if nvc.viewControllers.count > 1 {
            nvc.popToRootViewControllerAnimated(false)
        }
    }
    
    switch shortcutType {
    case .NewStory:
        tabBarController.selectedTab = .Home
        if let nvc = tabBarController.selectedViewController as? UINavigationController {
            if let vc = nvc.topViewController as? HomeViewController {
                vc.tryToTellStory()
            }
        }
    case .Feeds:
        tabBarController.selectedTab = .Feeds
    case .Collections:
        tabBarController.selectedTab = .Collections
    }
}

func clearDynamicShortcuts() {
    UIApplication.sharedApplication().shortcutItems = nil
}