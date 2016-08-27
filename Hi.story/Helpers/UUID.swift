//
//  UUID.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/22/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

struct UUID {
    static var uuid: String {
        let keychain = Keychain(service: "HSKeychainService")
        var uuid = ""
        do {
            if let id = try keychain.get("") {
                uuid = id
                try keychain.label("com.xspyhack.Histroy")
                    .comment("Hi.story uuid")
                    .set(uuid, forKey: Defaults.UUID)
            } else {
                let UUIDRef = CFUUIDCreate(kCFAllocatorDefault)
                uuid = String(CFUUIDCreateString(kCFAllocatorDefault, UUIDRef))
                try keychain.label("com.xspyhack.Histroy")
                    .comment("Hi.story uuid")
                    .set(uuid, forKey: Defaults.UUID)
            }
        } catch {}
        
        return uuid
    }
}