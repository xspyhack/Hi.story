//
//  CollectionCellModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

protocol CollectionCellModelType {
    
    var title: String { get }
    var description: String { get }
    var coverImageURL: NSURL? { get }
}

struct CollectionCellModel: CollectionCellModelType {
    
    private(set) var title: String
    
    private(set) var description: String
    
    private(set) var coverImageURL: NSURL?
    
    init(collection: Collection) {
        self.title = collection.title
        self.description = collection.description
        self.coverImageURL = collection.coverImageURL
    }
    
    init(restrospective: Restrospective) {
        self.title = restrospective.title
        self.description = restrospective.description
        self.coverImageURL = restrospective.imageURL
    }
}