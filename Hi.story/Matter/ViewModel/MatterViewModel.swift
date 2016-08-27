//
//  MatterViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Hikit

protocol MatterViewModelType {
    
    var itemDeleted: PublishSubject<NSIndexPath> { get }
}

struct MatterViewModel: MatterViewModelType {
    
    var itemDeleted = PublishSubject<NSIndexPath>()
    
    private let disposeBag = DisposeBag()
    private var matters: Variable<[Matter]>
    
}

