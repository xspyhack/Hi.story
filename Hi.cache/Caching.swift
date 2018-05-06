//
//  Caching.swift
//  Hikit
//
//  Created by bl4ckra1sond3tre on 11/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

internal func _abstract(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Abstract method must be overridden", file: file, line: line)
}

public protocol Caching {
    
    associatedtype Object
    
    var serializer: AnyCacheSerializer<Object> { get }
    
    func store(_ object: Object, forKey key: String)
    
    func retrieve(forKey key: String) -> Object?
    
    func remove(forKey key: String)
    
    func removeAll()
    
    func contains(forKey key: String) -> Bool
}

public protocol FileCaching {
    
    func fileURL(forKey key: String) -> URL
}

public protocol AsyncCaching: Caching {
    
    func store(_ object: Object, forKey key: String, completionHandler: @escaping  ((String) -> Void))
    
    func retrieve(forKey key: String, completionHandler: @escaping (Object?, String) -> Void)
    
    func remove(forKey key: String, completionHandler: @escaping ((String) -> Void))
    
    func removeAll(completionHandler: @escaping  (() -> Void))
    
    func contains(forKey key: String, completionHandler: @escaping  ((Bool, String) -> Void))
}

class AnyCacheBoxBase<Object>: Caching {
    
    var serializer: AnyCacheSerializer<Object>
    
    init<S: CacheSerializer>(_ serializer: S) where S.Object == Object {
        self.serializer = AnyCacheSerializer(serializer)
    }
    
    func store(_ object: Object, forKey key: String) {
        _abstract()
    }

    func retrieve(forKey key: String) -> Object? {
        _abstract()
    }

    func remove(forKey key: String) {
        _abstract()
    }

    func removeAll() {
        _abstract()
    }

    func contains(forKey key: String) -> Bool {
        _abstract()
    }
}

class AnyAsyncCacheBoxBase<Object>: AnyCacheBoxBase<Object> {
    
    override init<S: CacheSerializer>(_ serializer: S) where S.Object == Object {
        super.init(serializer)
    }
    
    func store(_ object: Object, forKey key: String, completionHandler: @escaping  ((String) -> Void)) {
        _abstract()
    }
    
    func retrieve(forKey key: String, completionHandler: @escaping (Object?, String) -> Void) {
        _abstract()
    }
    
    func remove(forKey key: String, completionHandler: @escaping ((String) -> Void)) {
        _abstract()
    }
    
    func removeAll(completionHandler: @escaping  (() -> Void)) {
        _abstract()
    }
    
    func contains(forKey key: String, completionHandler: @escaping  ((Bool, String) -> Void)) {
        _abstract()
    }
}

final class AnyCacheBox<Base: Caching>: AnyCacheBoxBase<Base.Object> {

    private var base: Base

    init(_ base: Base) {
        self.base = base
        super.init(base.serializer)
    }

    override func store(_ object: Base.Object, forKey key: String) {
        base.store(object, forKey: key)
    }

    override func retrieve(forKey key: String) -> Base.Object? {
        return base.retrieve(forKey: key)
    }

    override func remove(forKey key: String) {
        base.remove(forKey: key)
    }

    override func removeAll() {
        base.removeAll()
    }

    override func contains(forKey key: String) -> Bool {
        return base.contains(forKey: key)
    }
}

class AnyAsyncCacheBox<Base: AsyncCaching>: AnyAsyncCacheBoxBase<Base.Object> {
    
    private var base: Base
    
    init(_ base: Base) {
        self.base = base
        super.init(base.serializer)
    }
    
    override func store(_ object: Object, forKey key: String, completionHandler: @escaping ((String) -> Void)) {
        base.store(object, forKey: key, completionHandler: completionHandler)
    }
    
    override func retrieve(forKey key: String, completionHandler: @escaping (Object?, String) -> Void) {
        base.retrieve(forKey: key, completionHandler: completionHandler)
    }
    
    override func remove(forKey key: String, completionHandler: @escaping ((String) -> Void)) {
        base.remove(forKey: key, completionHandler: completionHandler)
    }
    
    override func removeAll(completionHandler: @escaping  (() -> Void)) {
        base.removeAll(completionHandler: completionHandler)
    }
    
    override func contains(forKey key: String, completionHandler: @escaping ((Bool, String) -> Void)) {
        base.contains(forKey: key, completionHandler: completionHandler)
    }
}

public struct AnyCache<Object>: Caching {
    
    private let cache: AnyCacheBoxBase<Object>

    public init<C: Caching>(_ cache: C) where C.Object == Object {
        self.cache = AnyCacheBox(cache)
    }
    
    public var serializer: AnyCacheSerializer<Object> {
        return cache.serializer
    }
    
    public func store(_ object: Object, forKey key: String) {
        cache.store(object, forKey: key)
    }
    
    public func retrieve(forKey key: String) -> Object? {
        return cache.retrieve(forKey: key)
    }

    public func remove(forKey key: String) {
        cache.remove(forKey: key)
    }

    public func removeAll() {
        cache.removeAll()
    }

    public func contains(forKey key: String) -> Bool {
        return cache.contains(forKey: key)
    }
}

public struct AnyAsyncCache<Object>: AsyncCaching {
    
    private let cache: AnyAsyncCacheBoxBase<Object>
    
    public init<C: AsyncCaching>(_ cache: C) where C.Object == Object {
        self.cache = AnyAsyncCacheBox(cache)
    }
    
    public var serializer: AnyCacheSerializer<Object> {
        return cache.serializer
    }
    
    public func store(_ object: Object, forKey key: String) {
        cache.store(object, forKey: key)
    }
    
    public func retrieve(forKey key: String) -> Object? {
        return cache.retrieve(forKey: key)
    }
    
    public func remove(forKey key: String) {
        cache.remove(forKey: key)
    }
    
    public func removeAll() {
        cache.removeAll()
    }
    
    public func contains(forKey key: String) -> Bool {
        return cache.contains(forKey: key)
    }
    
    public func store(_ object: Object, forKey key: String, completionHandler: @escaping ((String) -> Void)) {
        cache.store(object, forKey: key, completionHandler: completionHandler)
    }
    
    public func retrieve(forKey key: String, completionHandler: @escaping (Object?, String) -> Void) {
        cache.retrieve(forKey: key, completionHandler: completionHandler)
    }
    
    public func remove(forKey key: String, completionHandler: @escaping ((String) -> Void)) {
        cache.remove(forKey: key, completionHandler: completionHandler)
    }
    
    public func removeAll(completionHandler: @escaping  (() -> Void)) {
        cache.removeAll(completionHandler: completionHandler)
    }
    
    public func contains(forKey key: String, completionHandler: @escaping ((Bool, String) -> Void)) {
        cache.contains(forKey: key, completionHandler: completionHandler)
    }
}
