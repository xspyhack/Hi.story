//
//  IndexPath+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 06/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

extension IndexPath: HistoryCompatible {
}

public extension Hi where Base == IndexPath {
    
    public var next: IndexPath {
        return IndexPath(row: self.base.row + 1, section: self.base.section)
    }
    
    public var previous: IndexPath {
        return IndexPath(row: self.base.row - 1, section: self.base.section)
    }
}
