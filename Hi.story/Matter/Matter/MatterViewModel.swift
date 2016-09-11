//
//  MatterViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit
import RxCocoa
import RxSwift
import RxDataSources
import RealmSwift

protocol MatterViewModelType {
    
    var itemDeleted: PublishSubject<NSIndexPath> { get }
    var itemDidSelect: PublishSubject<NSIndexPath> { get }
}

typealias MatterViewSection = SectionModel<String, MatterCellModelType>

struct MatterViewModel: MatterViewModelType {
    
    var itemDeleted = PublishSubject<NSIndexPath>()
    var itemDidSelect = PublishSubject<NSIndexPath>()
    
    private let disposeBag = DisposeBag()
    private var matters: Variable<[Matter]>
    
    let sections: Driver<[MatterViewSection]>
    
    init(realm: Realm) {
        
        let matters = Variable<[Matter]>(MatterService.sharedService.fetchAll(fromRealm: realm))
        self.matters = matters
        
        self.sections = matters.asObservable()
            .map { matters in
                let commingCellModels = matters.filter { $0.happenedUnixTime > NSDate().timeIntervalSince1970 }.map(MatterCellModel.init) as [MatterCellModelType]
                let commingSection = MatterViewSection(model: "Comming", items: commingCellModels)
                
                let pastCellModels = matters.filter { $0.happenedUnixTime <= NSDate().timeIntervalSince1970 }.map(MatterCellModel.init) as [MatterCellModelType]
                let pastSection = MatterViewSection(model: "Past", items: pastCellModels)
                return [commingSection, pastSection]
            }
            .asDriver(onErrorJustReturn: [])
    }
}

