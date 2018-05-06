//
//  UITextView+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 25/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import UIKit
import Hikit

extension UITextView {
    static let cursorToken = ">|<"
}

extension Hi where Base: UITextView {
    
    private func oneCharRange(pos: UITextPosition?) -> UITextRange? {
        guard let pos = pos, let position = base.position(from: pos, offset: 1) else {
            return nil
        }
        return base.textRange(from: pos, to: position)
    }
    
    private func text(atPosition position: UITextPosition?) -> String? {
        guard let position = position, let range = oneCharRange(pos: position) else {
            return nil
        }
        return base.text(in: range)
    }
    
    func startOfLine(forRange range: UITextRange) -> UITextPosition {
        
        func previousPosition(pos: UITextPosition?) -> UITextPosition? {
            guard let pos = pos else { return nil }
            return base.position(from: pos, offset: -1)
        }
        
        var position: UITextPosition? =  previousPosition(pos: range.start)
        while let text = text(atPosition: position), text != "\n" { // check if it's the EoL
            position = previousPosition(pos: position) // move back 1 char
        }
        
        if let position = position, // we have a position
            let pos = base.position(from: position, offset: 1) { // need to advance by one...
            return pos
        }
        
        return base.beginningOfDocument // not found? Go to the beginning
    }
    
    func replace(left: String, right: String?, atLineStart: Bool) {
        guard let range = base.selectedTextRange, let text = base.text(in: range) else {
            return
        }
        
        let replacementText: String
        if atLineStart {
            replacementText = left
        } else {
            replacementText = "\(left)\(text)\(right ?? "")"
        }
        
        var insertionRange = range
        if atLineStart {
            let startLinePosition = startOfLine(forRange: range)
            insertionRange = base.textRange(from: startLinePosition, to: startLinePosition) ?? range
        }
        
        let cursorPosition = (replacementText as NSString).range(of: UITextView.cursorToken)
        base.replace(insertionRange, withText: replacementText.replacingOccurrences(of: UITextView.cursorToken, with: ""))
        
        if range.start == range.end, // single cursor (no selection)
            let position = base.position(from: range.start, // advance by the inserted before
                offset: left.lengthOfBytes(using: .utf8)) {
            base.selectedTextRange = base.textRange(from: position, to: position) // single cursor
        } else if cursorPosition.location != NSNotFound,
            let position = base.position(from: range.start, // advance by the inserted before
                offset: cursorPosition.location) {
            base.selectedTextRange = base.textRange(from: position, to: position) // single cursor {
        }
    }
}
