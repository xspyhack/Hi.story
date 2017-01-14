//
//  DraftsViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 11/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Hikit
import RxCocoa
import RxDataSources
import RxSwift
import RealmSwift

typealias DraftsViewSection = SectionModel<Void, DraftCellModelType>

protocol DraftsViewModelType {
    
    // Input
    var itemDidSelect: PublishSubject<IndexPath> { get }
    var itemDeleted: PublishSubject<IndexPath> { get }
    
    // Output
    var sections: Driver<[DraftsViewSection]> { get }
    var editDraft: Driver<NewFeedViewModel> { get }
}

struct DraftsViewModel: DraftsViewModelType {
    
    // MARK: Input
    
    let itemDidSelect = PublishSubject<IndexPath>()
    var itemDeleted = PublishSubject<IndexPath>()
    
    // MARK: Output
    
    let sections: Driver<[DraftsViewSection]>
    let editDraft: Driver<NewFeedViewModel>
    
    // MARK: Private
    
    private let disposeBag = DisposeBag()
    private var drafts: Variable<[Story]>
    
    init(realm: Realm) {

        let drafts = Variable<[Story]>(StoryService.shared.unpublished(fromRealm: realm))
        self.drafts = drafts
        
        self.sections = drafts.asObservable()
            .map { drafts in
                let cellModels = drafts.map { DraftCellModel(story: $0) } as [DraftCellModelType]
                let section = DraftsViewSection(model: Void(), items: cellModels)
                return [section]
            }
            .asDriver(onErrorJustReturn: [])
        
        self.itemDeleted
            .subscribe(onNext: { indexPath in
                print(indexPath.row)
                
                if let story = drafts.value.safe[indexPath.row] {
                    
                    print(story)
                    
                    drafts.value.remove(at: indexPath.row)
                    // delete
                    StoryService.shared.remove(story, fromRealm: realm)
                }
            })
            .addDisposableTo(self.disposeBag)
      
        self.editDraft = self.itemDidSelect
            .map { indexPath -> NewFeedViewModel in
                if let story = drafts.value.safe[indexPath.row] {
                    return NewFeedViewModel(mode: .edit(story), token: UUID().uuidString)
                } else {
                    return NewFeedViewModel(token: UUID().uuidString)
                }
            }
            .asDriver(onErrorDriveWith: .never())
    }
    
}
