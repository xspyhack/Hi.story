//
//  AppDelegate.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RealmSwift
import WatchConnectivity
import CoreSpotlight

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window?.backgroundColor = UIColor.white
       
        Realm.Configuration.defaultConfiguration = realmConfig()
        
        if let realm = try? Realm(), Service.god(of: realm) == nil {
            let userID = UUID.uuid
            let nickname = "What's your name?"
            let user = User()
            user.id = userID
            user.nickname = nickname
            user.bio = "No introduction yet."
            try? realm.write {
                realm.add(user, update: true)
            }
            
            HiUserDefaults.userID.value = userID
            HiUserDefaults.nickname.value = nickname
            HiUserDefaults.bio.value = "No introduction yet."
            
            // default storybook
            let book = Storybook()
            book.name = Defaults.storybookName
            book.creator = user
            
            try? realm.write {
                realm.add(book, update: true)
            }
        } else {
            // Waiting for register
        }
        
        if !Defaults.sayHi {
            
            DispatchQueue.global(qos: .default).async {
                Configuration.hi()
                Defaults.sayHi = true
            }
        }
        
        // Appearence
        UITabBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.hi.tint
        UIToolbar.appearance().tintColor = UIColor.hi.tint
        UIToolbar.appearance().barTintColor = UIColor.white
        
        // Static items, just for now.
        if window?.traitCollection.forceTouchCapability == .available {
            configureShortcuts()
        }
        
        // Transfer matters to watchApp
        //WatchSessionService.shared.start(withDelegate: self)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        if Defaults.spotlightEnabled {
            
            CSSearchableIndex.default().deleteAllSearchableItems { error in
                guard error == nil else {
                    return
                }
                
                indexFeedSearchableItems()
            }
        } else {
            CSSearchableIndex.default().deleteAllSearchableItems(completionHandler: nil)
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: Spotlight
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        switch userActivity.activityType {
        case NSUserActivityTypeBrowsingWeb:
            guard let webpageURL = userActivity.webpageURL else {
                return false
            }
            
            return handleUniversalLink(webpageURL)
        case CSSearchableItemActionType:
            
            guard let searchableItemID = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
                return false
            }
            
            guard let (itemType, itemID) = searchableItem(with: searchableItemID) else {
                return false
            }
            
            switch itemType {
                
            case .user:
                return handleUserSearchActivity(userID: itemID)
                
            case .feed:
                return handleFeedSearchActivity(feedID: itemID)
            }
        default:
            return false
        }
    }
    
    private func handleUniversalLink(_ url: URL) -> Bool {
        return false
    }
   
    // 暂不支持
    private func handleUserSearchActivity(userID: String) -> Bool {
       return false
    }
    
    private func handleFeedSearchActivity(feedID: String) -> Bool {
        
        guard let realm = try? Realm() else {
                return false
        }
        
        guard let feed = FeedService.shared.fetch(withPredicate: NSPredicate(format: "id = %@", feedID), fromRealm: realm),
            let tabBarVC = window?.rootViewController as? UITabBarController,
            let nvc = tabBarVC.selectedViewController as? UINavigationController else {
                return false
        }
        
        if let feedViewController = nvc.topViewController as? FeedViewController, let appearingFeed = feedViewController.viewModel?.feed, appearingFeed.id == feedID {
            
            return true
        } else {
            let vc: FeedViewController = Storyboard.feed.viewController(of: FeedViewController.self)
            vc.viewModel = FeedViewModel(feed: feed)
            vc.hidesBottomBarWhenPushed = true
            
            _ = delay(0.25) {
                nvc.pushViewController(vc, animated: true)
            }
            
            return true
        }
    }
        
    // MARK: Shortcuts
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        handleShortcutItem(shortcutItem)
        
        completionHandler(true)
    }
    
    private func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        
        if let window = window {
            tryToHandleQuickAction(shortcutItem: shortcutItem, inWindow: window)
        }
    }
}

extension AppDelegate: WCSessionDelegate {
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState)
        
        if activationState == .activated {
            
            if let realm = try? Realm() {
                let matters: [SharedMatter] = MatterService.shared.fetchAll(fromRealm: realm).flatMap { SharedMatter.matter(with: $0) }
                
                WatchSessionService.shared.update(withApplicationContext: [Configure.sharedMattersKey: matters.first!])
                
                print("did update application context: \(matters.count)")
            }
        }
    }
    
    /** ------------------------- iOS App State For Watch ------------------------ */
    
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    public func sessionDidDeactivate(_ session: WCSession) {
        
    }
}

