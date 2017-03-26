//
//  String+Hi.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 8/27/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import CommonCrypto

public struct StringProxy {
    public let base: String
    public init(_ base: String) {
        self.base = base
    }
}

extension String: BaseType {
    public typealias Base = StringProxy
    
    public var hi: StringProxy {
        return StringProxy(self)
    }
    
    public static var hi: StringProxy.Type {
        return StringProxy.self
    }
}

public extension StringProxy {

    public enum TrimmingType {
        case whitespace
        case whitespaceAndNewline
    }
    
    public func trimming(_ trimmingType: TrimmingType) -> String {
        switch trimmingType {
        case .whitespace:
            return base.trimmingCharacters(in: CharacterSet.whitespaces)
        case .whitespaceAndNewline:
            return base.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    public var md5: String? {
        
        guard let str = base.cString(using: String.Encoding.utf8) else {
            return nil
        }
        
        let strLen = CC_LONG(base.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str, strLen, result)
        
        let hash = NSMutableString()
        
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate(capacity: digestLen)
        
        return String(format: hash as String)
    }

    public var words: [String] {
        let range = Range<String.Index>(uncheckedBounds: (lower: base.startIndex, upper: base.endIndex))
        var words = [String]()
        
        base.enumerateSubstrings(in: range, options: .byWords, { (substring, _, _, _) -> () in
            if let substring = substring {
                words.append(substring)
            }
        })
        
        return words
    }
}
