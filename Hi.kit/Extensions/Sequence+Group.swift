//
//  Sequence+Group.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 30/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public extension Sequence where Self.Iterator.Element: Equatable {
    
    /// if elements hadn't be sorted, the result maybe not unique
    public func grouped() -> [[Iterator.Element]] {
        return _grouped(by: ==)
    }
}

public extension Sequence {
    
    // must be sorted first
    fileprivate func _grouped(by predicate: (Self.Iterator.Element, Self.Iterator.Element) -> Bool) -> [[Self.Iterator.Element]] {
        var results = [Array<Iterator.Element>]()
        
        forEach {
            if var lastGroup = results.last, let element = lastGroup.last, predicate(element, $0) {
                lastGroup.append($0)
                results.removeLast()
                results.append(lastGroup)
            } else {
                results.append([$0])
            }
        }
        return results
    }
}

public extension Sequence where Self.Iterator.Element: Comparable {
    
    public func grouped(by predicate: (Self.Iterator.Element, Self.Iterator.Element) -> Bool) -> [[Self.Iterator.Element]] {
        return sorted(by: predicate)._grouped(by: predicate)
    }
}

public extension Sequence {
    
    public func grouped<G: Hashable>(by closure: (Iterator.Element) -> G) -> [G: [Iterator.Element]] {
        var results = [G: Array<Iterator.Element>]()
        
        forEach {
            let key = closure($0)
            
            if var array = results[key] {
                array.append($0)
                results[key] = array
            }
            else {
                results[key] = [$0]
            }
        }
        
        return results
    }
}
