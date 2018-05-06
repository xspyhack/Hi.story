//
//  Routing.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 18/03/2018.
//  Copyright © 2018 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public protocol Routing {
    
    static func canRoute(_ url: URL) -> Bool
    
    static func route(_ url: URL, withParams params: Params?, context: Context?)
    
    static func add(_ route: Route)
    
    static func remove(_ route: Route)
}

extension Routing {
    
    static func route(_ url: URL) {
        return self.route(url, withParams: nil, context: nil)
    }
    
    static func route(_ url: URL, withParams params: Params?) {
        return self.route(url, withParams: params, context: nil)
    }
}
