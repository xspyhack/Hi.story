//
//  Bundle+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

extension Bundle {
    
    static var releaseVersionNumber: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static var buildVersionNumber: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
}
