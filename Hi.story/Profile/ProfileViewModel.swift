//
//  ProfileViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 12/11/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit

protocol ProfileViewModelType {
    var user: User { get }
    var isGod: Bool { get }
}

struct ProfileViewModel: ProfileViewModelType {
    
    let user: User
    let isGod: Bool
    
    init(user: User, isGod: Bool = false) {
        self.user = user
        self.isGod = isGod
    }
}
