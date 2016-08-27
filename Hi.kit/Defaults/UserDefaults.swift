//
//  UserDefaults.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 6/19/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public struct UserDefaults {
    
    private static let userDefaults = NSUserDefaults.standardUserDefaults()
    
    public static var TellerRecordName: String {
        get {
            return userDefaults.objectForKey("com.xspyhack.Histroy.TellerRecordName") as? String ?? "_2a8756cfa0c606aa6f49c5532ad6a935"
        }
        set {
            userDefaults.setObject(newValue, forKey: "com.xspyhack.Histroy.TellerRecordName")
        }
    }
}