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
    var itemDeleted: PublishSubject<NSIndexPath> { get }
    var itemDidSelect: PublishSubject<NSIndexPath> { get }
    
    var sections: Driver<[MattersViewSection]> { get }
}

typealias MattersViewSection = SectionModel<String, MatterCellModelType>

struct MattersViewModel: MattersViewModelType {
    
    private(set) var addAction = PublishSubject<Void>()
    private(set) var itemDeleted = PublishSubject<NSIndexPath>()
    private(set) var itemDidSelect = PublishSubject<NSIndexPath>()
    
    private let disposeBag = DisposeBag()
    private var matters: Variable<[Matter]>
    
    let sections: Driver<[MattersViewSection]>
    
    init(realm: Realm) {
        
        let matters = Variable<[Matter]>(MatterService.sharedService.fetchAll(fromRealm: realm))
        self.matters = matters
        
        self.sections = matters.asObservable()
            .map { matters in
                let commingCellModels = matters.filter { $0.happenedUnixTime > NSDate().timeIntervalSince1970 }.map(MatterCellModel.init) as [MatterCellModelType]
                let commingSection = MattersViewSection(model: "Comming", items: commingCellModels)
                
                let pastCellModels = matters.filter { $0.happenedUnixTime <= NSDate().timeIntervalSince1970 }.map(MatterCellModel.init) as [MatterCellModelType]
                let pastSection = MattersViewSection(model: "Past", items: pastCellModels)
                return [commingSection, pastSection]
            }
            .asDriver(onErrorJustReturn: [])
        
        self.itemDeleted
            .subscribeNext { indexPath in
                let matter = matters.value[indexPath.row]
            }
            .addDisposableTo(disposeBag)
        
        Matter.didDelete.subscribeNext { matter in
            self.matters.value.indexOf(ma)
        }
    }
}

extension Matter: ModelType {}
