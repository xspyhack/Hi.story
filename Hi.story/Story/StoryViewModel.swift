//
//  StoryViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/21/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit

struct StoryViewModel {
    var story: Story
}

protocol StoryCellModelType {
    
    var title: String { get }
    var subtitle: String { get }
    
}