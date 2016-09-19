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

fileprivate enum Section: Int {
    case comming
    case past
    
    var title: String {
        switch self {
        case .comming: return "Comming"
        case .past: return "Past"
        }
    }
}

struct MattersViewModel: MattersViewModelType {
    
    private(set) var addAction = PublishSubject<Void>()
    private(set) var itemDeleted = PublishSubject<IndexPath>()
    private(set) var itemDidSelect = PublishSubject<IndexPath>()
    
    private let disposeBag = DisposeBag()
    var matters: Variable<[Matter]>
    
    let sections: Driver<[MattersViewSection]>
    
    let showNewMatterViewModel: Driver<NewMatterViewModel>
    let showMatterViewModel: Driver<MatterViewModel>
    let itemDidDeselect: Driver<IndexPath>
    
    init(realm: Realm) {
        
        let matters = Variable<[Matter]>(MatterService.sharedService.fetchAll(fromRealm: realm).sorted(by: { (matter0, matter1) in
            matter0.happenedUnixTime > matter1.happenedUnixTime
        }))
        
        self.matters = matters
        
        // 这样写，无法根据 section 来 delete 对应 matter，如果不怕牺牲性能，可以在删除的时候重新分组
        self.sections = matters.asObservable()
            .map { matters in
                let commingCellModels = matters.filter { $0.happenedUnixTime > Date().timeIntervalSince1970 }.map(MatterCellModel.init) as [MatterCellModelType]
                let commingSection = MattersViewSection(model: Section.comming.title, items: commingCellModels)
                
                let pastCellModels = matters.filter { $0.happenedUnixTime <= Date().timeIntervalSince1970 }.map(MatterCellModel.init) as [MatterCellModelType]
                let pastSection = MattersViewSection(model: Section.past.title, items: pastCellModels)
                return [commingSection, pastSection]
            }
            .asDriver(onErrorJustReturn: [])

        self.itemDeleted
            .subscribe(onNext: { indexPath in
                // 先分组
                guard let section = Section(rawValue: indexPath.section) else { return }
                
                if section == .comming {
                    let commings = matters.value.filter { $0.happenedUnixTime > Date().timeIntervalSince1970 }
                    
                    if let matter = commings[safe: indexPath.row] {
                        Matter.didDelete.onNext(matter)
                    }
                } else {
                    let pasts = matters.value.filter{ $0.happenedUnixTime <= Date().timeIntervalSince1970 }
                    
                    if let matter = pasts[safe: indexPath.row] {
                        Matter.didDelete.onNext(matter)
                    }
                }
            })
            .addDisposableTo(disposeBag)
        
        self.showMatterViewModel = self.itemDidSelect
            .map { indexPath in
                // 先分组
                if indexPath.section == Section.comming.rawValue {
                    let commings = matters.value.filter { $0.happenedUnixTime > Date().timeIntervalSince1970 }
                    
                    if let matter = commings[safe: indexPath.row] {
                        return MatterViewModel(matter: matter)
                    }
                } else {
                    let pasts = matters.value.filter{ $0.happenedUnixTime <= Date().timeIntervalSince1970 }
                    
                    if let matter = pasts[safe: indexPath.row] {
                        return MatterViewModel(matter: matter)
                    }
                }
                return MatterViewModel(matter: Matter())
            }
            .asDriver(onErrorDriveWith: .never())
        
        self.itemDidDeselect = self.itemDidSelect.asDriver(onErrorJustReturn: IndexPath())
        
        self.showNewMatterViewModel = self.addAction.asDriver()
            .map {
                NewMatterViewModel()
            }
        
        // Services
  
        Matter.didCreate
            .subscribe(onNext: { matter in
                matters.value.insert(matter, at: 0)
                MatterService.sharedService.synchronize(matter, toRealm: realm)
            })
            .addDisposableTo(disposeBag)
        
        Matter.didDelete
            .subscribe(onNext: { matter in
                if let index = matters.value.index(of: matter) {
                    matters.value.remove(at: index)
                    MatterService.sharedService.remove(matter, fromRealm: realm)
                }
            })
            .addDisposableTo(disposeBag)
    }
}

extension Matter: ModelType {}
