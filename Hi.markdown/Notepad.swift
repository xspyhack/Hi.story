//
//  Notepad.swift
//  Notepad
//
//  Created by Rudd Fawcett on 10/14/16.
//  Copyright © 2016 Rudd Fawcett. All rights reserved.
//


import UIKit

public class Notepad: UITextView {
    var storage: Storage = Storage()

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
    
    /// Creates a new Notepad.
    ///
    /// - parameter frame:     The frame of the text editor.
    /// - parameter themeFile: The name of the theme file to use.
    ///
    /// - returns: A new Notepad.
    convenience public init(_ frame: CGRect, themeFile: String) {
        self.init(frame: frame, textContainer: nil)
        
        setup(themeFile: themeFile)
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        let layoutManager = NSLayoutManager()
        let containerSize = CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true

        layoutManager.addTextContainer(container)
        storage.addLayoutManager(layoutManager)
        super.init(frame: frame, textContainer: container)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let layoutManager = NSLayoutManager()
        let containerSize = CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true

        layoutManager.addTextContainer(container)
        storage.addLayoutManager(layoutManager)
        
        setup(themeFile: "one-dark")
    }
    
    private func setup(themeFile: String) {
        self.storage.theme = Theme(themeFile)
        self.backgroundColor = self.storage.theme.backgroundColor
        self.tintColor = self.storage.theme.tintColor
        
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
            attributed = NSAttributedString(string: placeholder, attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray.withAlphaComponent(0.7), NSAttributedStringKey.font: font ?? UIFont.systemFont(ofSize: 14.0)])
        }
        
        attributed?.draw(in: targetRect)
    }
    
    @objc private func didChange(_ notification: Foundation.Notification) {
        
        needsDisplayPlaceholder = text.isEmpty
    }
}
