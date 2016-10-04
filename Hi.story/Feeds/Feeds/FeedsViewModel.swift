//
//  FeedsViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit
import RxSwift
import RxCocoa

protocol FeedsViewModelType {
    var addAction: PublishSubject<Void> { get }
}

struct FeedsViewModel: FeedsViewModelType {
    
    private(set) var addAction = PublishSubject<Void>()

    let showNewFeedViewModel: Driver<NewFeedViewModel>
    //let showFeedViewModel: Driver<FeedViewModel>
    
    init() {
        
        self.showNewFeedViewModel = self.addAction.asDriver()
            .map {
                NewFeedViewModel()
            }
    }
}

extension Feed: ModelType {}
