//
//  UIView+Hi.swift
//  Hikit
//
//  Created by bl4ckra1sond3tre on 05/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

public extension Hi where Base: UIView {
    
    public func edges(with inset: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        self.base.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["view": self.base]
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-l-[view]-t-|", options: [], metrics: ["l": inset.left, "t": inset.right], views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|-t-[view]-b-|", options: [], metrics: ["t": inset.top, "b": inset.bottom], views: views)
        
        return h + v
    }
    
    public func left(with constant: CGFloat = 0) -> NSLayoutConstraint {
        self.base.translatesAutoresizingMaskIntoConstraints = false
        return self.base.leadingAnchor.constraint(equalTo: self.base.superview!.leadingAnchor, constant: constant)
    }
    
    public func right(with constant: CGFloat = 0) -> NSLayoutConstraint {
        self.base.translatesAutoresizingMaskIntoConstraints = false
        return self.base.trailingAnchor.constraint(equalTo: self.base.superview!.trailingAnchor, constant: constant)
    }
    
    public func top(with constant: CGFloat = 0, safeAreaLayout: Bool = false) -> NSLayoutConstraint {
        self.base.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOSApplicationExtension 11.0, *) {
            return self.base.topAnchor.constraint(equalTo: safeAreaLayout ? self.base.superview!.safeAreaLayoutGuide.topAnchor : self.base.superview!.topAnchor, constant: constant)
        } else {
            return self.base.topAnchor.constraint(equalTo: self.base.superview!.topAnchor, constant: constant)
        }
    }
    
    public func bottom(with constant: CGFloat = 0, safeAreaLayout: Bool = false) -> NSLayoutConstraint {
        self.base.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOSApplicationExtension 11.0, *) {
            return self.base.bottomAnchor.constraint(equalTo: safeAreaLayout ? self.base.superview!.safeAreaLayoutGuide.bottomAnchor : self.base.superview!.bottomAnchor, constant: constant)
        } else {
            return self.base.bottomAnchor.constraint(equalTo: self.base.superview!.bottomAnchor, constant: constant)
        }
    }
    
    public func width(with constant: CGFloat) -> NSLayoutConstraint {
        self.base.translatesAutoresizingMaskIntoConstraints = false
        return self.base.widthAnchor.constraint(equalToConstant: constant)
    }
    
    public func height(with constant: CGFloat) -> NSLayoutConstraint {
        self.base.translatesAutoresizingMaskIntoConstraints = false
        return self.base.heightAnchor.constraint(equalToConstant: constant)
    }
}
