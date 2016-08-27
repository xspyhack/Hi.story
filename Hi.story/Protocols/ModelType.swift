//
//  ModelType.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

protocol Configurable {
    
    associatedtype ModelType
    
    func configure(withPresenter presenter: ModelType)
}