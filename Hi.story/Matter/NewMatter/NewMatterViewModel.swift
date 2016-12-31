//
//  NewMatterViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/11/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit
import RxCocoa
import RxSwift
import RxDataSources
import RealmSwift

protocol NewMatterViewModelType {
    
    var postAction: PublishSubject<Void> { get }
    var cancelAction: PublishSubject<Void> { get }

    var postButtonEnabled: Driver<Bool> { get }
    var dismissViewController: Driver<Void> { get }
}

struct NewMatterViewModel: NewMatterViewModelType {
    
    // matter model
    
    var title: Variable<String>
    var tag: Variable<Tag>
    var happenedAt: Variable<Date>
    var body: Variable<String>
    
    var postAction = PublishSubject<Void>()
    var cancelAction = PublishSubject<Void>()
    
    // Output
    let postButtonEnabled: Driver<Bool>
    let dismissViewController: Driver<Void>
    
    fileprivate let disposeBag = DisposeBag()
    
    init() {
     
        // Default value
        self.title = Variable("")
        self.tag = Variable(.none)
        self.happenedAt = Variable(Date())
        self.body = Variable("")
        
        self.postButtonEnabled = self.title.asDriver()
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
            .startWith(false)

        let matter = Driver.combineLatest(title.asDriver(),
                                          tag.asDriver(),
                                          happenedAt.asDriver(),
                                          body.asDriver()
        ) { title, tag, happenedAt, body -> Matter in
            let matter = Matter()
            matter.creator = Service.god
            matter.title = title
            matter.tag = tag.rawValue
            matter.happenedAt = happenedAt.timeIntervalSince1970
            matter.body = body
            return matter
        }
        
        let didPost = self.postAction.asDriver()
            .withLatestFrom(postButtonEnabled).filter{ $0 }
            .withLatestFrom(matter)
            .map { matter in
                Matter.didCreate.onNext(matter)
            }
            .asDriver()
        
        let didCancel = self.cancelAction.asDriver()
        
        self.dismissViewController = Driver.of(didPost, didCancel).merge()
    }
}
