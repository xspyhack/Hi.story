//
//  Cache.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 15/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

public struct MemoryCache<Object>: Caching {
    
    private var cache = NSCache<NSString, Wrapper<Object>>()
    
    public init<S: CacheSerializer>(countLimit: Int = 0, serializer: S) where S.Object == Object {
        self.cache.countLimit = countLimit
        self.serializer = AnyCacheSerializer(serializer)
        
        NotificationCenter.default.addObserver(cache, selector: #selector(type(of: cache).removeAllObjects), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(cache, selector: #selector(type(of: cache).removeAllObjects), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    // MARK: - Caching
    
    public var serializer: AnyCacheSerializer<Object>
    
    public func store(_ object: Object, forKey key: String) {
        cache.setObject(Wrapper(bullet: object), forKey: key as NSString)
    }
    
    public func retrieve(forKey key: String) -> Object? {
        return cache.object(forKey: key as NSString)?.candy
    }
    
    public func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    public func removeAll() {
        cache.removeAllObjects()
    }
    
    public func contains(forKey key: String) -> Bool {
        return cache.object(forKey: key as NSString) != nil
    }
}

public struct DiskCache<Object>: AsyncCaching, FileCaching {
    
    private let directory: String
    
    private var fileManager: FileManager!
    private let ioQueue = DispatchQueue(label: "com.xspyhack.cache.io", attributes: .concurrent)
    private let processQueue = DispatchQueue(label: "com.xspyhack.cache.process", attributes: .concurrent)
    
    public init<S: CacheSerializer>(directory: String, serializer: S) where S.Object == Object {
        try? DiskCache.makeDirectory(at: directory)
        self.directory = directory
        self.serializer = AnyCacheSerializer(serializer)
        
        self.ioQueue.sync { self.fileManager = FileManager() }
    }
    
    public static func makeDirectory(at path: String) throws {
        var isDirectory: ObjCBool = false
        // Ensure the directory exists
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue {
            return
        }
        
        // Try to create the directory
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
    
    // MARK: - Caching
    
    public var serializer: AnyCacheSerializer<Object>
    
    public func store(_ object: Object, forKey key: String) {
        coordinate(queue: ioQueue, barrier: true) {
            
            guard let data = self.serializer.data(with: object, original: nil) else {
                return
            }
            
            self.fileManager.createFile(atPath: self.path(forKey: key), contents: data, attributes: nil)
        }
    }
    
    public func store(_ object: Object, forKey key: String, completionHandler: @escaping ((String) -> Void)) {
        coordinate(queue: ioQueue, barrier: true) {
            defer {
                completionHandler(key)
            }
            
            guard let data = self.serializer.data(with: object, original: nil) else {
                return
            }
            
            self.fileManager.createFile(atPath: self.path(forKey: key), contents: data, attributes: nil)
        }
    }
    
    public func retrieve(forKey key: String) -> Object? {
        var object: Object?
        ioQueue.sync {
            if let data = data(forKey: key) {
                object = serializer.object(with: data)
            }
        }
        return object
    }
    
    public func retrieve(forKey key: String, completionHandler: @escaping (Object?, String) -> Void) {
        coordinate(queue: ioQueue) {
            var object: Object?
            defer {
                completionHandler(object, key)
            }
            
            if let data = self.data(forKey: key) {
                object = self.serializer.object(with: data)
            }
        }
    }
    
    public func remove(forKey key: String) {
        coordinate(queue: ioQueue) {
            do {
                try self.fileManager.removeItem(atPath: self.path(forKey: key))
            } catch _ {}
        }
    }
    
    public func remove(forKey key: String, completionHandler: @escaping (String) -> Void) {
        coordinate(queue: ioQueue) {
            defer {
                completionHandler(key)
            }
            
            do {
                try self.fileManager.removeItem(atPath: self.path(forKey: key))
            } catch _ {}
        }
    }
    
    public func removeAll() {
        coordinate(queue: ioQueue) {
            do {
                try self.fileManager.removeItem(atPath: self.directory)
                try DiskCache.makeDirectory(at: self.directory)
            } catch _ {}
        }
    }
    
    public func removeAll(completionHandler: @escaping () -> Void) {
        coordinate(queue: ioQueue) {
            defer {
                completionHandler()
            }
            
            do {
                try self.fileManager.removeItem(atPath: self.directory)
                try DiskCache.makeDirectory(at: self.directory)
            } catch _ {}
        }
    }
    
    public func contains(forKey key: String) -> Bool {
        var cached = false
        ioQueue.sync {
            cached = self.fileManager.fileExists(atPath: self.path(forKey: key))
        }
        
        return cached
    }
    
    public func contains(forKey key: String, completionHandler: @escaping (Bool, String) -> Void) {
        coordinate(queue: ioQueue) {
            let cached = self.fileManager.fileExists(atPath: self.path(forKey: key))
            completionHandler(cached, key)
        }
    }
    
    public func fileURL(forKey key: String) -> URL {
        return URL(fileURLWithPath: path(forKey: key))
    }
    
    // MARK: - Private
    
    private func data(forKey key: String) -> Data? {
        let filePath = path(forKey: key)
        return (try? Data(contentsOf: URL(fileURLWithPath: filePath)))
    }
    
    private func path(forKey key: String) -> String {
        let name = fileName(forKey: key)
        return (directory as NSString).appendingPathComponent(name)
    }
    
    private func fileName(forKey key: String) -> String {
        return key // fixme, md5
    }
    
    private func coordinate(queue: DispatchQueue, barrier: Bool = false, block: @escaping () -> Void) {
        if barrier {
            queue.async(flags: .barrier, execute: block)
            return
        }
        
        queue.async(execute: block)
    }
}

public enum CacheType {
    case memory(countLimit: Int)
    case disk(directory: String)
}

public struct Cache<Object>: AsyncCaching {
    
    public let serializer: AnyCacheSerializer<Object>
    
    public let memoryCache: MemoryCache<Object>
    public let diskCache: DiskCache<Object>
    
    public init<S: CacheSerializer>(directory: String, serializer: S) where S.Object == Object {
        let serializer = AnyCacheSerializer(serializer)
        self.serializer = serializer
        self.memoryCache = MemoryCache(countLimit: 0, serializer: serializer)
        self.diskCache = DiskCache(directory: directory, serializer: serializer)
    }
    
    
    // MAKR: - Caching
    
    public func store(_ object: Object, forKey key: String) {
        memoryCache.store(object, forKey: key)
        diskCache.store(object, forKey: key)
    }
    
    public func retrieve(forKey key: String) -> Object? {
        var object = memoryCache.retrieve(forKey: key)
        if object == nil {
            object = diskCache.retrieve(forKey: key)
            if let object = object {
                memoryCache.store(object, forKey: key)
            }
        }
        return object
    }
    
    public func remove(forKey key: String) {
        memoryCache.remove(forKey: key)
        diskCache.remove(forKey: key)
    }
    
    public func removeAll() {
        memoryCache.removeAll()
        diskCache.removeAll()
    }
    
    public func contains(forKey key: String) -> Bool {
        return memoryCache.contains(forKey: key) || diskCache.contains(forKey: key)
    }
    
    // MARK: - AsyncCaching
    
    public func store(_ object: Object, forKey key: String, completionHandler: @escaping ((String) -> Void)) {
        memoryCache.store(object, forKey: key)
        diskCache.store(object, forKey: key, completionHandler: completionHandler)
    }
    
    public func retrieve(forKey key: String, completionHandler: @escaping (Object?, String) -> Void) {
        if let object = memoryCache.retrieve(forKey: key) {
            completionHandler(object, key)
        } else {
            diskCache.retrieve(forKey: key) { object, key in
                if let object = object {
                    self.memoryCache.store(object, forKey: key)
                }
                completionHandler(object, key)
            }
        }
    }
    
    public func remove(forKey key: String, completionHandler: @escaping ((String) -> Void)) {
        memoryCache.remove(forKey: key)
        diskCache.remove(forKey: key, completionHandler: completionHandler)
    }
    
    public func removeAll(completionHandler: @escaping  (() -> Void)) {
        memoryCache.removeAll()
        diskCache.removeAll(completionHandler: completionHandler)
    }
    
    public func contains(forKey key: String, completionHandler: @escaping ((Bool, String) -> Void)) {
        if memoryCache.contains(forKey: key) {
            completionHandler(true, key)
        } else {
            diskCache.contains(forKey: key, completionHandler: completionHandler)
        }
    }
}

extension Cache: FileCaching {
    
    public func fileURL(forKey key: String) -> URL {
        return diskCache.fileURL(forKey: key)
    }
}
