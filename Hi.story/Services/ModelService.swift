//
//  ModelService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/11/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import RxSwift

private var _instances = [String: Any]()

protocol ModelType {}

struct ModelService<Model: ModelType> {
    
    let didCreate = PublishSubject<Model>()
    let didUpdate = PublishSubject<Model>()
    let didDelete = PublishSubject<Model>()
    
    static func instance(modelClass: Model.Type) -> ModelService<Model> {
        let key = String(modelClass)
        if let stream = _instances[key] as? ModelService<Model> {
            return stream
        }
        let stream = ModelService<Model>()
        _instances[key] = stream
        return stream
    }
    
}

extension ModelType {
    
    static var didCreate: PublishSubject<Self> {
        return ModelService.instance(Self).didCreate
    }
    
    static var didUpdate: PublishSubject<Self> {
        return ModelService.instance(Self).didUpdate
    }
    
    static var didDelete: PublishSubject<Self> {
        return ModelService.instance(Self).didDelete
    }
}