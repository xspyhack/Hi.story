//
//  String+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/27/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public extension String {
    
    public enum TrimmingType {
        case whitespace
        case whitespaceAndNewline
    }
    
    public func trimming(_ trimmingType: TrimmingType) -> String {
        switch trimmingType {
        case .whitespace:
            return trimmingCharacters(in: CharacterSet.whitespaces)
        case .whitespaceAndNewline:
            return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
}
