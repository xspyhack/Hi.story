//
//  UUID+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 30/09/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

extension UUID {
    
    static var uuid: String {
        let keychain = Keychain(service: "KeychainService")
        var uuid = ""
        do {
            if let id = try keychain.get("") {
                uuid = id
                try keychain.label("com.xspyhack.Histroy")
                    .comment("Hi.story uuid")
                    .set(uuid, forKey: Defaults.uuidKey)
            } else {
                let uuidRef = CFUUIDCreate(kCFAllocatorDefault)
                uuid = String(CFUUIDCreateString(kCFAllocatorDefault, uuidRef))
                try keychain.label("com.xspyhack.Histroy")
                    .comment("Hi.story uuid")
                    .set(uuid, forKey: Defaults.uuidKey)
            }
        } catch {}
        
        return uuid
    }
}
