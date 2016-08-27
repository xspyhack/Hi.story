//
//  UIStoryBoard+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    enum StoryBoard: String {
        case Main
    }
    
    func storyBoard(board: StoryBoard) -> UIStoryboard {
        
        return UIStoryboard(name: board.rawValue, bundle: nil)
    }
}

