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
    var coverImageURL: URL? { get }
}

struct CollectionCellModel: CollectionCellModelType {
    
    fileprivate(set) var title: String
    
    fileprivate(set) var description: String
    
    fileprivate(set) var coverImageURL: URL?
    
    init(collection: Collection) {
        self.title = collection.title
        self.description = collection.description
        self.coverImageURL = collection.coverImageURL as URL
    }
    
    init(restrospective: Restrospective) {
        self.title = restrospective.title
        self.description = restrospective.description
        self.coverImageURL = restrospective.imageURL as URL?
    }
}
