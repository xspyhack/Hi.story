//
//  InputableCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 02/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxCocoa
import RxSwift

final class TitleInputableCell: UITableViewCell, Reusable {
    
    var changedAction: ((String) -> Void)?
    
    var didBeginInputingAction: (() -> Void)?
    var didEndInputingAction: (() -> Void)?
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.textAlignment = .center
        textField.textColor = UIColor.hi.text
        return textField
    }()
    
    fileprivate let disposeBag = DisposeBag()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        
        textLabel?.textColor = UIColor.hi.title
        
        textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.changedAction?(text.hi.trimming(.whitespaceAndNewline))
            })
            .addDisposableTo(disposeBag)
        
        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "textField": textField,
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|[textField]|", options: [], metrics: nil, views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|[textField]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
    }
}

extension TitleInputableCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginInputingAction?()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        didEndInputingAction?()
    }
}

final class InputableCell: UITableViewCell, Reusable {
    
    var changedAction: ((String) -> Void)?
    
    var didBeginInputingAction: (() -> Void)?
    var didEndInputingAction: (() -> Void)?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.title
        return label
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.textAlignment = .right
        textField.textColor = UIColor.hi.text
        return textField
    }()
    
    fileprivate let disposeBag = DisposeBag()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        
        textLabel?.textColor = UIColor.hi.title
        
        textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.changedAction?(text.hi.trimming(.whitespaceAndNewline))
            })
            .addDisposableTo(disposeBag)
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        
        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "textField": textField,
            "titleLabel": titleLabel,
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[titleLabel]-10-[textField]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|[textField]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
    }
}

extension InputableCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginInputingAction?()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        didEndInputingAction?()
    }
}

final class InfoInputableCell: UITableViewCell, Reusable {
    
    var didEndEditing: ((String) -> Void)?
    
    var textdidChange: ((String) -> Void)?
    
    var didBeginInputingAction: (() -> Void)?
    
    var textViewDidChangeAction: ((CGFloat) -> Void)?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.title
        return label
    }()
    
    fileprivate let textViewMinixumHeight: CGFloat = 30.0
    static let minixumHeight: CGFloat = 16 + 30 + 10 + 30 + 20
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textColor = UIColor.hi.text
        textView.font = UIFont.systemFont(ofSize: 14.0)
        textView.textContainer.lineFragmentPadding = 0.0
        textView.textContainerInset = .zero
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        return textView
    }()
    
    fileprivate var textViewHeightConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        
        textLabel?.textColor = UIColor.hi.title
        
        contentView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "titleLabel": titleLabel,
            "textView": textView,
        ] as [String : Any]
        
        let H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[textView]-20-|", options: [], metrics: nil, views: views)
        let V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLabel(30)]-10-[textView(>=30)]-20-|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(H)
        NSLayoutConstraint.activate(V)
    }
}

extension InfoInputableCell: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text.hi.trimming(.whitespaceAndNewline)
        textView.text = text
        
        didEndEditing?(text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        didBeginInputingAction?()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        //var bounds = textView.bounds
        //bounds.size = size
        //textView.bounds = bounds
        //textViewHeightConstraint.constant = max(textViewMinixumHeight, size.height)
        textViewDidChangeAction?(size.height + 80.0)
        
        textdidChange?(textView.text)
    }
}
