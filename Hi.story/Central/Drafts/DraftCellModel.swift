//
//  DraftCellModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 11/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import RxCocoa
import RxSwift
import Hikit

protocol DraftCellModelType {
    var title: String { get }
    var content: String { get }
    var updatedAt: TimeInterval { get }
}

struct DraftCellModel: DraftCellModelType {
    
    let title: String
    let content: String
    let updatedAt: TimeInterval
    
    init(story: Story) {
        self.title = story.title
        self.content = story.body
        self.updatedAt = story.updatedAt
    }
}
