//
//  Feed.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/31/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit
import RealmSwift

class Feed: Object {
    dynamic var story: Story?
    dynamic var creator: Hikit.User?
    dynamic var likesCount: Int = 0
    dynamic var visible: Int = Visible.public.rawValue
}
