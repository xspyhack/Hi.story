//
//  ProfileCellModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 28/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

protocol ProfileCellModelType {
    
    var avatar: URL? { get }
    var nickname: String { get }
    var bio: String? { get }
}

struct ProfileCellModel: ProfileCellModelType {
   
    let avatar: URL?
    let nickname: String
    let bio: String?
}
