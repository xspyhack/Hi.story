//
//  FeedsFlowLayout.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 08/11/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class FeedsFlowLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        
        minimumLineSpacing = 18.0
        minimumInteritemSpacing = 0.0
        sectionInset.bottom = 12.0
        
        sectionHeadersPinToVisibleBounds = true
    }
}
