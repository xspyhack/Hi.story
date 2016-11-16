//
//  Identifiable.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 09/11/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

protocol Identifiable {
    associatedtype Identifier: Equatable
    var identifier: Identifier { get }
    
    static var identifier: Identifier { get }
}
