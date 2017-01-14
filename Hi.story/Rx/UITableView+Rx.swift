//
//  UITableView+Rx.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 01/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UITableView {
    public func enablesAutoDeselect() -> Disposable {
        return itemSelected
            .map { (at: $0, animated: true) }
            .subscribe(onNext: base.deselectRow)
    }
}

extension Reactive where Base: UITableViewCell {
    var prepareForReuse: Observable<Void> {
        return Observable.of((base as UITableViewCell).rx.sentMessage(#selector(UITableViewCell.prepareForReuse)).map { _ in }, (base as UITableViewCell).rx.deallocated).merge()
    }
    
    var prepareForReuseBag: DisposeBag {
        return base.rx_prepareForReuseBag
    }
}

private var _prepareForReuseBag: Void = ()

extension UITableViewCell {
    fileprivate var rx_prepareForReuse: Observable<Void> {
        return Observable.of(self.rx.sentMessage(#selector(UITableViewCell.prepareForReuse)).map { _ in () }, self.rx.deallocated).merge()
    }
    
    fileprivate var rx_prepareForReuseBag: DisposeBag {
        MainScheduler.ensureExecutingOnScheduler()
        
        if let bag = objc_getAssociatedObject(self, &_prepareForReuseBag) as? DisposeBag {
            return bag
        }
        
        let bag = DisposeBag()
        objc_setAssociatedObject(self, &_prepareForReuseBag, bag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        
        _ = self.rx.sentMessage(#selector(UITableViewCell.prepareForReuse))
            .subscribe(onNext: { [weak self] _ in
                let newBag = DisposeBag()
                objc_setAssociatedObject(self, &_prepareForReuseBag, newBag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            })
        
        return bag
    }
}
