//
//  Reusable.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 1/27/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

public protocol NibReusable: Reusable {
    static var nib: UINib { get }
}

public extension Reusable {
    static var reuseIdentifier: String {
        return String(Self)
    }
}

public extension NibReusable {
    static var nib: UINib {
        return UINib(nibName: String(Self), bundle: nil)
    }
}

// MARK: - UICollectionView

public extension Hi where Base: UICollectionView {
    
    public func registerReusableCell<T: UICollectionViewCell where T: Reusable>(cellType: T.Type) {
        base.registerClass(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    public func registerReusableCell<T: UICollectionViewCell where T: NibReusable>(cellType: T.Type) {
        base.registerNib(T.nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    public func dequeueReusableCell<T: UICollectionViewCell where T: Reusable>(for indexPath: NSIndexPath) -> T {
        guard let cell = base.dequeueReusableCellWithReuseIdentifier(T.reuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue reusable cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
    
    public func registerReusableSupplementaryView<T: UICollectionReusableView where T: NibReusable>(ofKind elementKind: String, viewType: T.Type) {
        base.registerNib(T.nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: T.reuseIdentifier)
    }
    
    public func registerReusableSupplementaryView<T: UICollectionReusableView where T: Reusable>(ofKind elementKind: String, viewType: T.Type) {
        base.registerClass(T.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: T.reuseIdentifier)
    }
    
    public func dequeueReusableSupplementaryView<T: UICollectionReusableView where T: Reusable>(ofKind elementKind: String, for indexPath: NSIndexPath) -> T {
        guard let view = base.dequeueReusableSupplementaryViewOfKind(elementKind, withReuseIdentifier: T.reuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue reusable supplementary view with identifier: \(T.reuseIdentifier)")
        }
        return view
    }
}

// MARK: - UITableView

public extension Hi where Base: UITableView {
    
    public func registerReusableCell<T: UITableViewCell where T: Reusable>(cellType: T.Type) {
        base.registerClass(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    public func registerReusableCell<T: UITableViewCell where T: NibReusable>(cellType: T.Type) {
        base.registerNib(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    public func dequeueReusableCell<T: UITableViewCell where T: Reusable>(for indexPath: NSIndexPath) -> T {
        guard let cell = base.dequeueReusableCellWithIdentifier(T.reuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue reusable cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
    
    public func registerHeaderFooter<T: UITableViewHeaderFooterView where T: Reusable>(viewType: T.Type) {
        
        base.registerClass(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    public func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView where T: Reusable>() -> T {
        
        guard let view = base.dequeueReusableHeaderFooterViewWithIdentifier(T.reuseIdentifier) as? T else {
            fatalError("Could not dequeue headerfooter view with identifier: \(T.reuseIdentifier)")
        }
        
        return view
    }
}
