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
import RealmSwift

protocol FeedsViewModelType {
    var addAction: PublishSubject<Void> { get }
}

struct FeedsViewModel: FeedsViewModelType {
    
    private(set) var addAction = PublishSubject<Void>()

    let showNewFeedViewModel: Driver<NewFeedViewModel>
    //let showFeedViewModel: Driver<FeedViewModel>
    
    private let disposeBag = DisposeBag()
    
    private(set) var feeds: Variable<[Feed]>
    
    init(realm: Realm) {
        
        let feeds = Variable<[Feed]>(FeedService.shared.fetchAll(fromRealm: realm))
        
        self.feeds =  feeds
        self.showNewFeedViewModel = self.addAction.asDriver()
            .map {
                NewFeedViewModel()
            }
        
        // Services
        
        Feed.didCreate
            .subscribe(onNext: { feed in
                feeds.value.insert(feed, at: 0)
                FeedService.shared.synchronize(feed, toRealm: realm)
            })
            .addDisposableTo(disposeBag)

    }
}

extension Feed: ModelType {}
