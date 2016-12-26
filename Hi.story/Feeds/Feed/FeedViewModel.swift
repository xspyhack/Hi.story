//
//  FeedViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 24/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit

protocol FeedViewModelType {
    
    var feed: Feed { get }
}

struct FeedViewModel: FeedViewModelType {
    
    let feed: Feed
}
