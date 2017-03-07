//
//  TodayEmptyView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 05/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class TodayEmptyView: UIView {
    
    var newAction: (() -> Void)?

    private(set) lazy var newButton: BorderedButton = {
        let button = BorderedButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle("+ New", for: .normal)
        button.setTitleColor(UIColor.hi.tint, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
        button.addTarget(self, action: #selector(TodayEmptyView.new(_:)), for: .touchUpInside)
        return button
    }()
    
    private(set) lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.description
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .center
        label.text = "No memories today, write a story now?"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    private func setup() {
        
        backgroundColor = UIColor.clear
        layer.shadowRadius = 12.0
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.masksToBounds = false
        layer.shadowOpacity = 1.0
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        backgroundView.layer.cornerRadius = 12.0
        
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(newButton)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "backgroundView": backgroundView,
            "textLabel": textLabel,
            "newButton": newButton,
        ]
        
        let backgroundViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView]|", options: [], metrics: nil, views: views)
        let backgroundViewV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(backgroundViewH)
        NSLayoutConstraint.activate(backgroundViewV)
        
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|-44-[textLabel]-48-[newButton]-28-|", options: [.alignAllCenterX], metrics: nil, views: views)
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-24-[textLabel]-24-|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
    }
    
    @objc private func new(_ sender: UIButton) {
        newAction?()
    }
    
}
