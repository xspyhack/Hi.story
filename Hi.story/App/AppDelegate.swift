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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window?.backgroundColor = UIColor.white
        
        Realm.Configuration.defaultConfiguration = realmConfig()
        
        // Appearence
        UITabBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.hi.tint
        
        // Static items, just for now.
        if window?.traitCollection.forceTouchCapability == .available {
            configureShortcuts()
        }
        
        // Transfer matters to watchApp
        WatchSessionService.shared.start(withDelegate: self)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
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
        
    // MARK: Shortcuts
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        handleShortcutItem(shortcutItem)
        
        completionHandler(true)
    }
    
    fileprivate func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        
        if let window = window {
            tryToHandleQuickAction(shortcutItem: shortcutItem, inWindow: window)
        }
    }
}

extension AppDelegate: WCSessionDelegate {
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState)
        
        print(error)
    
        if activationState == .activated {
            
            if let realm = try? Realm() {
                let matters: [SharedMatter] = MatterService.shared.fetchAll(fromRealm: realm).flatMap { $0.shared }
                
                print(matters.first)
                
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

