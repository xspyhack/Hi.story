//
//  MarkdownCoordinator.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 25/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation
import Hikit

final class MarkdownCoordinator {
    
    private weak var textView: UITextView?
    
    private weak var markdownToolbar: MarkdownToolbar?
    
    func configure(textView: UITextView, markdownToolbar: MarkdownToolbar) {
        
        markdownToolbar.selectedAction = { [unowned self] operation in
            
            func handle(_ operation: TextActionOperation.Operation) {
                switch operation {
                case .wrap(let left, let right):
                    self.textView?.hi.replace(left: left, right: right, atLineStart: false)
                case .line(let left):
                    self.textView?.hi.replace(left: left, right: nil, atLineStart: true)
                case .execute(let block):
                    block()
                case .multi(let operations):
                    operations.forEach { handle($0) }
                }
            }
            
            handle(operation.operation)
            
            SafeDispatch.async {
                self.markdownToolbar?.isActived = false
            }
        }
        
        self.markdownToolbar = markdownToolbar
        self.textView = textView
    }
    
    static var defaultOperations: [TextActionOperation] {
        let operations = [
            TextActionOperation(icon: UIImage(named: "md_hashtag"), operation: .line("#"), name: "Hashtag"),
            TextActionOperation(icon: UIImage(named: "md_at"), operation: .line("@"), name: "At"),
            TextActionOperation(icon: UIImage(named: "md_code"), operation: .wrap("`", "`"), name: "Code"),
            TextActionOperation(icon: UIImage(named: "md_codeblock"), operation: .wrap("```\n", "\n```"), name: "Code Block"),
            TextActionOperation(icon: UIImage(named: "md_bold"), operation: .wrap("**", "**"), name: "Bold"),
            TextActionOperation(icon: UIImage(named: "md_italic"), operation: .wrap("*", "*"), name: "Italic"),
            TextActionOperation(icon: UIImage(named: "md_strike"), operation: .wrap("~~", "~~"), name: "Strike"),
            TextActionOperation(icon: UIImage(named: "md_blockquote"), operation: .line("> "), name: "Blockquote"),
            TextActionOperation(icon: UIImage(named: "md_link"), operation: .wrap("[", "](\(UITextView.cursorToken))"), name: "Link"),
            ]
        return operations
    }
}
