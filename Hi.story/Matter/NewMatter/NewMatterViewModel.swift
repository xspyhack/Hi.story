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
    
    var postAction = PublishSubject<Void>()
    var cancelAction = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    init() {
     
        let a: Driver<Void> = self.postAction.asDriver()
    }
}
