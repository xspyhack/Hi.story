//
//  RealmConfig.swift
//  Yep
//
//  Created by NIX on 16/5/24.
//  Copyright © 2016年 Catch Inc. All rights reserved.
//

import Foundation
import RealmSwift

public func realmConfig() -> Realm.Configuration {

    // 默认将 Realm 放在 App Group 里

    let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Configure.appGroupIdentifier)!
    let realmFileURL = directory.appendingPathComponent("db.realm")

    var config = Realm.Configuration()
    config.fileURL = realmFileURL
    config.schemaVersion = 5
    config.migrationBlock = { migration, oldSchemaVersion in
        
        if oldSchemaVersion < 2 {
            migration.enumerateObjects(ofType: Attachment.className(), { (oldObject, newObject) in
                newObject?["meta"] = nil
            })
        }
        
        if oldSchemaVersion < 3 {
            migration.enumerateObjects(ofType: Feed.className(), { (oldObject, newObject) in
                newObject?["createdAt"] = Date().timeIntervalSince1970
            })
        }
        
        if oldSchemaVersion < 4 {
            migration.enumerateObjects(ofType: Story.className(), { (oldObject, newObject) in
                newObject?["isPublished"] = true
            })
        }
        
        if oldSchemaVersion < 5 {
            migration.enumerateObjects(ofType: Story.className(), { (oldObject, newObject) in
                newObject?["withStorybook"] = nil
            })
        }
        
    }

    return config
}

