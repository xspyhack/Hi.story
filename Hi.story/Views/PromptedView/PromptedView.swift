//
//  PromptedView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 27/02/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

final class PromptedView: UIView {
    
    var dismissAction: (() -> Void)?

    private(set) lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.text
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private(set) lazy var dismissButton: BorderedButton = {
        let button = BorderedButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle("Dismiss", for: .normal)
        button.setTitleColor(UIColor.hi.tint, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
        button.addTarget(self, action: #selector(PromptedView.dismiss(_:)), for: .touchUpInside)
        return button
    }()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard superview != nil  else {
            return
        }
        
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.white
        
        let lineView = UIView()
        addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        lineView.backgroundColor = UIColor.hi.separator
        
        let views: [String: Any] = [
            "lineView": lineView,
            "promptLabel": promptLabel,
            "dismissButton": dismissButton,
        ]
        
        addSubview(promptLabel)
        addSubview(dismissButton)
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options: [], metrics: nil, views: views)
        
        let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[promptLabel]-10-[dismissButton(30)]-16-[lineView(0.5)]|", options: [.alignAllCenterX], metrics: nil, views: views)
        
        promptLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
        
        NSLayoutConstraint.activate(constraintsH)
        NSLayoutConstraint.activate(constraintsV)
    }
    
    @objc
    private func dismiss(_ sender: UIButton) {
        dismissAction?()
    }
}

final class BorderedButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 6
    @IBInspectable var borderColor: UIColor = UIColor.hi.tint
    @IBInspectable var borderWidth: CGFloat = 1
    
    override var isEnabled: Bool {
        willSet {
            let newBorderColor = newValue ? borderColor : UIColor(white: 0.8, alpha: 1.0)
            layer.borderColor = newBorderColor.cgColor
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
