//
//  MarkdownToolbar.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 07/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class MarkdownToolbar: UIView {
    
    private(set) var dataset: [TextActionOperation] = []
    
    var selectedAction: ((TextActionOperation) -> Void)?
    
    var isActived: Bool = false {
        didSet {
            if isActived {
                activate()
            } else {
                deactivate()
            }
        }
    }
    
    private var operationButtons: [UIButton] = []
    
    init(operations: [TextActionOperation]) {
        self.dataset = operations
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func activate() {
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
            self.transform = CGAffineTransform(translationX: 0, y: -20)
        }
    }
    
    private func deactivate() {
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0.0
            self.transform = .identity
        }
    }
    
    private func setup() {
        
        layer.cornerRadius  = frame.height / 2.0
        backgroundColor     = UIColor.white
        layer.shadowColor   = UIColor.lightGray.cgColor
        layer.shadowOffset  = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius  = 6.0
        alpha               = 0.0
        
        layout()
    }
    
    private func layout() {
        
        operationButtons = dataset.map { operation -> UIButton in
            let button = UIButton(type: .custom)
            button.setImage(operation.icon, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            return button
        }
        
        Array(0..<dataset.count).forEach { index in
            operationButtons.safe[index]?.tag = index
        }
        
        let stackView = UIStackView(arrangedSubviews: operationButtons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[stackView]-14-|", options: [], metrics: nil, views: ["stackView": stackView])
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: nil, views: ["stackView": stackView])
        
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
    }
    
    @objc
    private func tapped(_ sender: UIButton) {
        
        guard let operation = dataset.safe[sender.tag] else { return }
        
        selectedAction?(operation)
    }
 }
