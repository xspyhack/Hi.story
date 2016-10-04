//
//  NextTextView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 04/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

open class NextTextView: UITextView {
    
    override open var text: String! {
        didSet {
            needsDisplayPlaceholder = text.isEmpty
        }
    }
    
    // default is nil. string is drawn 70% gray
    open var placeholder: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // default is nil
    open var attributedPlaceholder: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var needsDisplayPlaceholder: Bool = true {
        didSet {
            if oldValue != needsDisplayPlaceholder {
                setNeedsDisplay()
            }
        }
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChange(_:)), name: .UITextViewTextDidChange, object: self)
    }
    
    // remove notification observer when deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        setNeedsDisplay()
    }
    
    // show placeholder
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard needsDisplayPlaceholder else { return }
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        let targetRect = CGRect(x: 4 + textContainerInset.left,
                                y: textContainerInset.top,
                                width: frame.size.width - (textContainerInset.left + textContainerInset.right),
                                height: frame.size.height - (textContainerInset.top + textContainerInset.bottom))
        
        var attributed: NSAttributedString?
        
        if let attributedPlaceholder = attributedPlaceholder {
            attributed = attributedPlaceholder
        } else if let placeholder = placeholder {
            attributed = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor.gray.withAlphaComponent(0.7), NSFontAttributeName: font])
        }
        
        attributed?.draw(in: targetRect)
    }
    
    @objc private func didChange(_ notification: Foundation.Notification) {
        
        needsDisplayPlaceholder = text.isEmpty
    }
}
