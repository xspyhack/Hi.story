//
//  Serializer.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 14/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

public protocol CacheSerializer {
    
    associatedtype Object
    
    func data(with object: Object, original: Data?) -> Data?
    
    func object(with data: Data) -> Object?
}

class AnyCacheSerializerBoxBase<Object>: CacheSerializer {
    
    func data(with object: Object, original: Data?) -> Data? {
        _abstract()
    }
    
    func object(with data: Data) -> Object? {
        _abstract()
    }
}

final class AnyCacheSerializerBox<Base: CacheSerializer>: AnyCacheSerializerBoxBase<Base.Object> {
    
    private var base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func data(with object: Base.Object, original: Data?) -> Data? {
        return base.data(with: object, original: original)
    }
    
    override func object(with data: Data) -> Base.Object? {
        return base.object(with: data)
    }
}

public struct AnyCacheSerializer<Object>: CacheSerializer {
    
    private let serializer: AnyCacheSerializerBoxBase<Object>
    
    public init<S: CacheSerializer>(_ serializer: S) where S.Object == Object {
        self.serializer = AnyCacheSerializerBox(serializer)
    }
    
    public func data(with object: Object, original: Data?) -> Data? {
        return serializer.data(with: object, original: original)
    }
    
    public func object(with data: Data) -> Object? {
        return serializer.object(with: data)
    }
}
