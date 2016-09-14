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
    
}

struct NewMatterViewModel: NewMatterViewModelType {
    
    // matter model
    
    var title: Variable<String>
    var tag: Variable<Tag>
    var happenedUnixTime: Variable<Date>
    var body: Variable<String>
    
    var postAction = PublishSubject<Void>()
    var cancelAction = PublishSubject<Void>()
    
    // Output
    let postButtonEnabled: Driver<Bool>
    fileprivate let disposeBag = DisposeBag()
    
    init() {
     
        // Default value
        self.title = Variable("")
        self.tag = Variable(.none)
        self.happenedUnixTime = Variable(Date())
        self.body = Variable("")
        
        self.postButtonEnabled = self.title.asDriver()
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
            .startWith(false)
        
        
        
        let didDone = self.postAction.asDriver()
            .withLatestFrom(self.postButtonEnabled).filter { $0 }
            .withLatestFrom(self.title.asDriver())
            .map { title in
                
            }
    }
}
