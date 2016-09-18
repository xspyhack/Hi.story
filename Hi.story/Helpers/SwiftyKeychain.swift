//
//  SwiftyKeychain.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/21/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Security

private let kSwiftyKeychainDomain = "com.xspyhack.swiftykeychain"

struct Keychain: OptionsType {
    
    var itemClass: String { return options.itemClass }
    
    var service: String {
        get {
            return options.service
        }
        set {
            options.service = newValue
        }
    }
    
    var accessGroup: String? {
        get {
            return options.accessGroup
        }
        set {
            options.accessGroup = newValue
        }
    }
    
    var accessibility: Accessibility { return options.accessibility }
    
    var label: String? { return options.label }
    
    var comment: String? { return options.comment }
    
    fileprivate var options: Options
    
    init(service: String, accessGroup: String? = nil) {
        let options = Options(service: service, accessGroup: accessGroup)
        self.init(opts: options)
    }
    
    fileprivate init(opts: Options) {
        self.options = opts
    }
    
    init() {
        var service = ""
        if let identifier = Bundle.main.bundleIdentifier {
            service = identifier
        }

        let options = Options(service: service)
        self.init(opts: options)
    }
    
    func identifier(_ id: String) -> Keychain {
        var options = self.options
        options.identifier = id
        return Keychain(opts: options)
    }
    
    func label(_ label: String) -> Keychain {
        var options = self.options
        options.label = label
        return Keychain(opts: options)
    }
    
    func comment(_ comment: String) -> Keychain {
        var options = self.options
        options.comment = comment
        return Keychain(opts: options)
    }
    
    func attributes(_ attrs: [String: AnyObject]) -> Keychain {
        var options = self.options
        options.attributes = attrs
        return Keychain(opts: options)
    }
    
    // getter
    
    func get(_ key: String) throws -> String? {
        return try getString(key)
    }
    
    func getString(_ key: String) throws -> String? {
        guard let data = try getData(key) else {
            return nil
        }
        guard let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String else {
            throw NSError(domain: kSwiftyKeychainDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string."])
        }
        return string
    }
    
    func getData(_ key: String) throws -> Data? {
        var query = genericQuery()
        
        query[String(kSecMatchLimit)] = String(kSecMatchLimitOne) as AnyObject?
        query[String(kSecReturnData)] = true as AnyObject?
        query[String(kSecAttrAccount)] = key as AnyObject?
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw NSError(domain: kSwiftyKeychainDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Unexpected error."])
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw NSError(domain: kSwiftyKeychainDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "\(status)"])
        }
    }
    
    func get<T>(_ key: String, handler: (KeychainAttributes?) -> T) throws -> T {
        var query = genericQuery()
        
        query[String(kSecMatchLimit)] = String(kSecMatchLimitOne) as AnyObject?
        query[String(kSecReturnAttributes)] = true as AnyObject?
        query[String(kSecReturnRef)] = true as AnyObject?
        query[String(kSecReturnData)] = true as AnyObject?
        query[String(kSecAttrAccount)] = key as AnyObject?
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        switch status {
        case errSecSuccess:
            guard let attributes = result as? [String: AnyObject] else {
                throw NSError(domain: kSwiftyKeychainDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Unexpected error."])
            }
            return handler(KeychainAttributes(attrs: attributes))
        case errSecItemNotFound:
            return handler(nil)
        default:
            throw NSError(domain: kSwiftyKeychainDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "\(status)."])
        }
    }
    
    // setter
    
    func set(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            throw NSError(domain: kSwiftyKeychainDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to data."])
        }
        try set(data, forKey: key)
    }
    
    func set(_ value: NSCoding, forKey key: String) throws {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        try set(data, forKey: key)
    }
    
    func set(_ value: Data, forKey key: String) throws {
        var query = genericQuery()
        query[String(kSecAttrAccount)] = key as AnyObject?
        
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess, errSecInteractionNotAllowed:
            var query = genericQuery()
            query[String(kSecAttrAccount)] = key as AnyObject?
            var (attrs, error) = genericAttributes(key: nil, value: value)
            if let error = error {
                throw error
            }
            attributes.forEach { attrs.updateValue($1, forKey: $0) }
            #if os(iOS)
                if status == errSecInteractionNotAllowed && floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_8_0) {
                    try remove(key)
                    try set(value, forKey: key)
                } else {
                    status = SecItemUpdate(query as CFDictionary, attrs as CFDictionary)
                    if status != errSecSuccess {
                        throw NSError(domain: kSwiftyKeychainDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "OSStatus error: \(status)."])
                    }
                }
            #else
                status = SecItemUpdate(query, attrs)
                if status != errSecSuccess {
                    throw NSError(domain: kSwiftyKeychainDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "OSStatus error: \(status)."])
                }
            #endif
        case errSecItemNotFound:
            var (attrs, error) = genericAttributes(key: key, value: value)
            if let error = error {
                throw error
            }
            attributes.forEach { attrs.updateValue($1, forKey: $0) }
            status = SecItemAdd(attrs as CFDictionary, nil)
            if status != errSecSuccess {
                throw NSError(domain: kSwiftyKeychainDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "\(status)."])
            }
        default:
            throw NSError(domain: kSwiftyKeychainDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "OSStatus error: \(status)."])
        }
    }
    
    func remove(_ key: String) throws {
        var query = genericQuery()
        query[String(kSecAttrAccount)] = key as AnyObject?
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw NSError(domain: kSwiftyKeychainDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "OSStatus error: \(status)."])
        }
    }
    
    func removeAll() throws {
        var query = genericQuery()
        #if !os(iOS) && !os(watchOS) && !os(tvOS)
            query[String(kSecMatchLimit)] = String(kSecMatchLimitAll)
        #endif
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw NSError(domain: kSwiftyKeychainDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "OSStatus error: \(status)."])
        }
    }
    
    subscript(key: String) -> String? {
        get {
            return (try? get(key)).flatMap { $0 }
        }
        set {
            if let value = newValue {
                do { try set(value, forKey: key) } catch {}
            } else {
                do { try remove(key) } catch {}
            }
        }
    }
    
    subscript(string key: String) -> String? {
        get {
            return self[key]
        }
        set {
            self[key] = newValue
        }
    }
    
    subscript(data key: String) -> Data? {
        get {
            return (try? getData(key))?.flatMap { $0 }
        }
        set {
            if let value = newValue {
                do { try set(value, forKey: key) } catch {}
            } else {
                do { try remove(key) } catch {}
            }
        }
    }
    
    subscript(attributes key: String) -> KeychainAttributes? {
        get {
            return (try? get(key) { $0 }).flatMap { $0 }
        }
    }
}

struct KeychainAttributes {
    var data: Data? {
        return attributes[String(kSecValueData)] as? Data
    }
    
    var label: String? {
        return attributes[String(kSecAttrLabel)] as? String
    }
    
    var comment: String? {
        return attributes[String(kSecAttrComment)] as? String
    }
    
    var account: String? {
        return attributes[String(kSecAttrAccount)] as? String
    }
    
    var service: String? {
        return attributes[String(kSecAttrService)] as? String
    }
    
    var accessGroup: String? {
        return attributes[String(kSecAttrAccessGroup)] as? String
    }
    
    var ref: Data? {
        return attributes[String(kSecValueRef)] as? Data
    }
    
    var accessible: String? {
        return attributes[String(kSecAttrAccessible)] as? String
    }
    
    var generic: Data? {
        return attributes[String(kSecAttrGeneric)] as? Data
    }
    
    var description: String? {
        return attributes[String(kSecAttrDescription)] as? String
    }
    
    fileprivate let attributes: [String: AnyObject]
    
    init(attrs: [String: AnyObject]) {
        self.attributes = attrs
    }
    
    subscript(key: String) -> AnyObject? {
        return attributes[key]
    }
}

protocol OptionsType {
    var itemClass: String { get }
    var service: String { get set }
    var accessGroup: String? { get set }
    
    var accessibility: Accessibility { get }
    var label: String? { get }
    var comment: String? { get }
    
    var attributes: [String: AnyObject] { get }
    
    func genericQuery() -> [String: AnyObject]
    
    func genericAttributes(key: String?, value: Data) -> ([String: AnyObject], NSError?)
}

extension OptionsType {
    var itemClass: String { return String(kSecClassGenericPassword) }
    
    var accessibility: Accessibility { return .afterFirstUnlock }
    var label: String? { return nil }
    var comment: String? { return nil }
    
    var attributes: [String: AnyObject] { return [:] }
    
    func genericQuery() -> [String: AnyObject] {
        var query = [String: AnyObject]()
        
        query[String(kSecClass)] = itemClass as AnyObject?
        query[String(kSecAttrService)] = service as AnyObject?
        
        #if (!arch(i386) && !arch(x86_64)) || (!os(iOS) && !os(watchOS) && !os(tvOS)) // TARGET_IPHONE_SIMULATOR TARGET_OS_SIMULATOR
            if let accessGroup = accessGroup {
                query[String(kSecAttrAccessGroup)] = accessGroup as AnyObject?
            }
        #endif
        return query
    }
    
    func genericAttributes(key: String?, value: Data) -> ([String: AnyObject], NSError?) {
        var attributes: [String: AnyObject]
        
        if let key = key {
            attributes = genericQuery()
            attributes[String(kSecAttrAccount)] = key as AnyObject?
        } else {
            attributes = [String: AnyObject]()
        }
        
        attributes[String(kSecValueData)] = value as AnyObject?
        
        if let label = label {
            attributes[String(kSecAttrLabel)] = label as AnyObject?
        }
        
        if let comment = comment {
            attributes[String(kSecAttrComment)] = comment as AnyObject?
        }
        
        attributes[String(kSecAttrAccessible)] = accessibility.rawValue as AnyObject?
        return (attributes, nil)
    }
}

struct Options: OptionsType {
    var service: String
    var accessGroup: String?
    
    var identifier: String?
    
    var label: String?
    var comment: String?
    var attributes: [String : AnyObject] = [:]
    
    init(service: String, accessGroup: String? = nil, identifier: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
}

enum Accessibility {
    case whenUnlocked
    case afterFirstUnlock
    case always
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlockedThisDeviceOnly
    case alwaysThisDeviceOnly
}

extension Accessibility: RawRepresentable {
    typealias RawValue = String
    
    var rawValue: RawValue {
        switch self {
        case .whenUnlocked:
            return String(kSecAttrAccessibleWhenUnlocked)
        case .afterFirstUnlock:
            return String(kSecAttrAccessibleAfterFirstUnlock)
        case .always:
            return String(kSecAttrAccessibleAlways)
        case .whenUnlockedThisDeviceOnly:
            return String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        case .afterFirstUnlockedThisDeviceOnly:
            return String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
        case .alwaysThisDeviceOnly:
            return String(kSecAttrAccessibleAlwaysThisDeviceOnly)
        }
    }
    
    init?(rawValue: RawValue) {
        switch rawValue {
        case String(kSecAttrAccessibleWhenUnlocked):
            self = .whenUnlocked
        case String(kSecAttrAccessibleAfterFirstUnlock):
            self = .afterFirstUnlock
        case String(kSecAttrAccessibleAlways):
            self = .always
        case String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly):
            self = .alwaysThisDeviceOnly
        case String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly):
            self = .afterFirstUnlockedThisDeviceOnly
        case String(kSecAttrAccessibleAlwaysThisDeviceOnly):
            self = .alwaysThisDeviceOnly
        default:
            return nil
        }
    }
}
