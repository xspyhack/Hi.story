//
//  UIImage+Assets.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 19/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

extension Hi where Base: UIImage {
    
    static var navBack: UIImage? {
        return UIImage(named: "nav_back")
    }
    
    static var avatar: UIImage? {
        return UIImage(named: "avatar")
    }
    
    static func roundedAvatar(radius: CGFloat) -> UIImage? {
        return avatar?.hi.image(withRoundRadius: radius, fit: CGSize(width: radius * 2, height: radius * 2))
    }
    
    static var authorAvatar: UIImage? {
        return UIImage(named: "megumi")
    }
    
    static var hiTeamAvatar: UIImage? {
        return UIImage(named: "hi_team")
    }
    
    static var storybook: UIImage? {
        return UIImage(named: "album")
    }
    
    static var connectorIcon: UIImage? {
        return UIImage(named: "connector")
    }
    
    static var matterIcon: UIImage? {
        return UIImage(named: "icon_calendar")
    }
    
    static var feedIcon: UIImage? {
        return UIImage(named: "icon_feed")
    }
    
    static var remindersIcon: UIImage? {
        return UIImage(named: "icon_reminders")
    }
    
    static var photosIcon: UIImage? {
        return UIImage(named: "icon_photos")
    }
    
    static var calendarIcon: UIImage? {
        return UIImage(named: "calendar")
    }
    
    static var completed: UIImage? {
        return UIImage(named: "checkmark_selected")
    }
    
    static var unCompleted: UIImage? {
        return UIImage(named: "checkmark_normal")
    }
    
    static var storybookDelete: UIImage? {
        return UIImage(named: "icon_delete_oval")
    }
}
