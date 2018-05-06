//
//  StorybookCellModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit

protocol StorybookCellModelType {
    
    var name: String { get }
    var count: Int { get }
    var coverImageURL: URL? { get }
    var fadeIn: Bool { get }
}

struct StorybookCellModel: StorybookCellModelType {
    
    private(set) var name: String
    
    private(set) var coverImageURL: URL?
    
    var count: Int
    
    var fadeIn: Bool
    
    init(storybook: Storybook, fadeIn: Bool = true) {
        self.name = storybook.name
        let stories = storybook.stories.filter { $0.isPublished }
        self.count = stories.count
        self.fadeIn = fadeIn
        
        if let urlString = storybook.latestPublishedPicturedStory?.attachment?.urlString {
            self.coverImageURL =  URL(string: urlString)
        } else {
            self.coverImageURL = nil
        }
    }
}
