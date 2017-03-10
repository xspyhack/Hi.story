//
//  Configuration.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 09/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public struct Configuration {
    
    public static let appGroupIdentifier = "group.com.xspyhack.History"
    
    public static let rowHeight: Float = 44.0
    
    public static let sharedMattersKey = "com.xspyhack.History.Matters"
    
    public struct Domain {
        static let feed = "com.xspyhack.History.Feed"
        static let user = "com.xspyhack.History.User"
    }
    
    public struct Metadata {
        public static let thumbnailMaxSize: CGFloat = 60
    }
}
