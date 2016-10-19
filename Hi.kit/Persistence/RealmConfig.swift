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
    config.schemaVersion = 1
    config.migrationBlock = { migration, oldSchemaVersion in }

    return config
}

