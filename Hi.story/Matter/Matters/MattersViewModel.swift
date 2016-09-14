//
//  MattersViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/10/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Hikit
import RxCocoa
import RxSwift
import RxDataSources
import RealmSwift

protocol MattersViewModelType {
    
    var addAction: PublishSubject<Void> { get }
    var itemDeleted: PublishSubject<IndexPath> { get }
    var itemDidSelect: PublishSubject<IndexPath> { get }
    
    var sections: Driver<[MattersViewSection]> { get }
}

typealias MattersViewSection = SectionModel<String, MatterCellModelType>

struct MattersViewModel: MattersViewModelType {
    
    fileprivate(set) var addAction = PublishSubject<Void>()
    fileprivate(set) var itemDeleted = PublishSubject<IndexPath>()
    fileprivate(set) var itemDidSelect = PublishSubject<IndexPath>()
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate var matters: Variable<[Matter]>
    
    let sections: Driver<[MattersViewSection]>
    
    let showNewMatterViewModel: Driver<NewMatterViewModel>
    
    init(realm: Realm) {
        
        let matters = Variable<[Matter]>(MatterService.sharedService.fetchAll(fromRealm: realm))
        self.matters = matters
        
        self.sections = matters.asObservable()
            .map { matters in
                let commingCellModels = matters.filter { $0.happenedUnixTime > Date().timeIntervalSince1970 }.map(MatterCellModel.init) as [MatterCellModelType]
                let commingSection = MattersViewSection(model: "Comming", items: commingCellModels)
                
                let pastCellModels = matters.filter { $0.happenedUnixTime <= Date().timeIntervalSince1970 }.map(MatterCellModel.init) as [MatterCellModelType]
                let pastSection = MattersViewSection(model: "Past", items: pastCellModels)
                return [commingSection, pastSection]
            }
            .asDriver(onErrorJustReturn: [])
        
        self.itemDeleted
            .subscribeNext { indexPath in
                if let matter = matters.value[safe: (indexPath as NSIndexPath).row] {
                    Matter.didDelete.onNext(matter)
                }
            }
            .addDisposableTo(disposeBag)
        
        self.showNewMatterViewModel = self.addAction.asDriver()
            .map {
                NewMatterViewModel()
            }
        
        // Services
        
        Matter.didCreate
            .subscribeNext { matter in
                self.matters.value.insert(matter, at: 0)
            }
            .addDisposableTo(disposeBag)
        
        Matter.didDelete
            .subscribeNext { matter in
                if let index = self.matters.value.indexOf(matter) {
                    self.matters.value.removeAtIndex(index)
                }
            }
            .addDisposableTo(disposeBag)
    }
}

extension Matter: ModelType {}
