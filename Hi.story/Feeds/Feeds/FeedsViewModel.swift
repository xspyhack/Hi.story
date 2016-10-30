//
//  FeedsViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Hikit
import RxSwift
import RxCocoa
import RxDataSources
import RealmSwift

protocol FeedsViewModelType {
    var addAction: PublishSubject<Void> { get }
}

typealias FeedsViewSection = FeedsSectionModel//SectionModel<Void, FeedsViewModelType>

enum FeedsSectionModel {
    case basic(model: Void, items: [SectionItem])
    case image(model: Void, items: [SectionItem])
}

extension FeedsSectionModel: SectionModelType {
    typealias Item = SectionItem
    
    var items: [SectionItem] {
        switch self {
        case .basic(model: (), items: let items):
            return items.map { $0 }
        case .image(model: (), items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: FeedsSectionModel, items: [Item]) {
        switch original {
        case .basic(model: (), items: _):
            self = .basic(model: (), items: items)
        case .image(model: (), items: _):
            self = .image(model: (), items: items)
        }
    }
}

enum SectionItem {
    case basic(Feed)
    case image(Feed, UIImage)
}

struct FeedsViewModel: FeedsViewModelType {
    
    private(set) var addAction = PublishSubject<Void>()
    
    let sections: Driver<[FeedsViewSection]>

    let showNewFeedViewModel: Driver<NewFeedViewModel>
    //let showFeedViewModel: Driver<FeedViewModel>
    
    private let disposeBag = DisposeBag()
    
    private(set) var feeds: Variable<[Feed]>
    
    init(realm: Realm) {
        
        let feeds = Variable<[Feed]>(FeedService.shared.fetchAll(fromRealm: realm))
        
        self.feeds = feeds
        
        self.sections = feeds.asObservable()
            .map { (fs) -> [FeedsViewSection] in
                return fs.flatMap { feed -> FeedsViewSection in
                    return .basic(model: (), items: [.basic(feed)])
                }
            }
            .asDriver(onErrorJustReturn: [])

        
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
