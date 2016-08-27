//
//  StorybookCellModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

protocol StorybookCellModelType {
    
    var name: String { get }
    var coverImageURL: NSURL? { get }
}

struct StorybookCellModel: StorybookCellModelType {
    
    private(set) var name: String
    private(set) var coverImageURL: NSURL?
    
    init(storybook: Storybook) {
        self.name = storybook.name
        self.coverImageURL = storybook.coverImageURL
    }
}