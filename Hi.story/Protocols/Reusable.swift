//
//  Reusable.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 1/27/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

protocol NibReusable: Reusable {
    static var nib: UINib { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(Self)
    }
}

extension NibReusable {
    static var nib: UINib {
        return UINib(nibName: String(Self), bundle: nil)
    }
}

// MARK: - UICollectionView

extension UICollectionView {
    
    func xh_registerReusableCell<T: UICollectionViewCell where T: Reusable>(cellType: T.Type) {
        self.registerClass(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func xh_registerReusableCell<T: UICollectionViewCell where T: NibReusable>(cellType: T.Type) {
        self.registerNib(T.nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func xh_dequeueReusableCell<T: UICollectionViewCell where T: Reusable>(for indexPath: NSIndexPath) -> T {
        guard let cell = dequeueReusableCellWithReuseIdentifier(T.reuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue reusable cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
    
    func xh_registerReusableSupplementaryView<T: UICollectionReusableView where T: NibReusable>(ofKind elementKind: String, viewType: T.Type) {
        registerNib(T.nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: T.reuseIdentifier)
    }
    
    func xh_registerReusableSupplementaryView<T: UICollectionReusableView where T: Reusable>(ofKind elementKind: String, viewType: T.Type) {
        registerClass(T.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: T.reuseIdentifier)
    }
    
    func xh_dequeueReusableSupplementaryView<T: UICollectionReusableView where T: Reusable>(ofKind elementKind: String, for indexPath: NSIndexPath) -> T {
        guard let view = dequeueReusableSupplementaryViewOfKind(elementKind, withReuseIdentifier: T.reuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue reusable supplementary view with identifier: \(T.reuseIdentifier)")
        }
        return view
    }
}

// MARK: - UITableView

extension UITableView {
    
    func xh_registerReusableCell<T: UITableViewCell where T: Reusable>(cellType: T.Type) {
        registerClass(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func xh_registerReusableCell<T: UITableViewCell where T: NibReusable>(cellType: T.Type) {
        registerNib(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func xh_dequeueReusableCell<T: UITableViewCell where T: Reusable>(for indexPath: NSIndexPath) -> T {
        guard let cell = dequeueReusableCellWithIdentifier(T.reuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue reusable cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
    
    func xh_registerHeaderFooter<T: UITableViewHeaderFooterView where T: Reusable>(viewType: T.Type) {
        
        registerClass(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    func xh_dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView where T: Reusable>() -> T {
        
        guard let view = dequeueReusableHeaderFooterViewWithIdentifier(T.reuseIdentifier) as? T else {
            fatalError("Could not dequeue headerfooter view with identifier: \(T.reuseIdentifier)")
        }
        
        return view
    }
}
