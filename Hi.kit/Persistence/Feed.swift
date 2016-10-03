//
//  Feed.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/31/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RealmSwift

public class Feed: Object {
    public dynamic var story: Story?
    public dynamic var creator: Hikit.User?
    public dynamic var likesCount: Int = 0
    public dynamic var visible: Int = Visible.public.rawValue
}
