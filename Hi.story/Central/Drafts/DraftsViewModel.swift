//
//  DraftsViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 11/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift

typealias DraftsViewSection = SectionModel<Void, DraftCellModelType>

protocol DraftsViewModelType {
    
    // Input
    var itemDidSelect: PublishSubject<IndexPath> { get }
    var itemDeleted: PublishSubject<IndexPath> { get }
    
    // Output
    var sections: Driver<[DraftsViewSection]> { get }
}

struct DraftsViewModel: DraftsViewModelType {
    
    // MARK: Input
    
    let itemDidSelect = PublishSubject<IndexPath>()
    var itemDeleted = PublishSubject<IndexPath>()
    
    // MARK: Output
    
    let sections: Driver<[DraftsViewSection]>
    
    // MARK: Private
    
    private let disposeBag = DisposeBag()
    private var drafts: Variable<[Draft]>
    
    init() {
        let defaultDrafts = [
            Draft(title: "Untitled", content: "Empty empty empty", updatedAt: Date().timeIntervalSince1970),
            Draft(title: "四月是你的谎言", content: "飞机穿梭于茫茫星海中逐渐远去，你如猫般，无声靠近，从意想不到的角度玩弄他人，而我只能呆愣在原地，永远只能跟随你的步伐。", updatedAt: Date().timeIntervalSince1970),
            Draft(title: "Untitled", content: "也许女孩子第一次有男朋友的心境就像白水冲了红酒，说不上爱情，只是一种温淡的兴奋。", updatedAt: Date().timeIntervalSince1970),
        ]
        
        let drafts = Variable<[Draft]>(defaultDrafts)
        self.drafts = drafts
        
        self.sections = drafts.asObservable()
            .map { drafts in
                let cellModels = drafts.map { DraftCellModel(draft: $0) } as [DraftCellModelType]
                let section = DraftsViewSection(model: Void(), items: cellModels)
                return [section]
            }
            .asDriver(onErrorJustReturn: [])
        
        self.itemDeleted
            .subscribe(onNext: { indexPath in
                drafts.value.remove(at: indexPath.row)
            })
            .addDisposableTo(self.disposeBag)
      
    }
    
}
