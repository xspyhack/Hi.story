//
//  Configuration.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 09/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public struct Configuration {
   
    public struct App {
        public static let urlString = "itms-apps://itunes.apple.com/app/id1051799810"
        public static let groupIdentifier = "group.com.xspyhack.History"
        public static let reviewURLString = "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1051799810&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
    }
    
    public static let rowHeight: Float = 44.0
    
    public static let sharedMattersKey = "com.xspyhack.History.Matters"
    
    public static let author = "blessingsoft"
    
    // Keys used to store relevant list data in the userInfo dictionary of an NSUserActivity for continuation.
    public struct UserActivity {
        // The editing user activity
        public static let editing = "com.xspyhack.History.editing"
        
        // The watch user activity is used to continue activities started on the watch on other devices.
        public static let watch = "com.xspyhack.History.watch"
        
        // The user info key used for storing the matter raw value.
        public static var matterUserInfoKey = "matterUserInfoKey"
    }
    
    public struct Defaults {
        public static let storyTitle = "Untitled"
        public static let storybookName = "Stories"
    }
    
    public struct Domain {
        static let feed = "com.xspyhack.History.Feed"
        static let user = "com.xspyhack.History.User"
    }
    
    public struct Metadata {
        public static let thumbnailMaxSize: CGFloat = 180
    }
}
