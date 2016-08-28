//
//  NewMatterViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/27/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxCocoa
import RxSwift

final class InputableCell: UITableViewCell, Reusable {
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.textAlignment = .Center
        return textField
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "textField": textField,
        ]
        
        let H = NSLayoutConstraint.constraintsWithVisualFormat("H:|[textField]|", options: [], metrics: nil, views: views)
        let V = NSLayoutConstraint.constraintsWithVisualFormat("V:|[textField]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activateConstraints(H)
        NSLayoutConstraint.activateConstraints(V)
    }
}

extension InputableCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
}

final class InfoInputableCell: UITableViewCell, Reusable {
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        return textView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "textView": textView,
        ]
        let H = NSLayoutConstraint.constraintsWithVisualFormat("H:|[textView]|", options: [], metrics: nil, views: views)
        let V = NSLayoutConstraint.constraintsWithVisualFormat("V:|[textView]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activateConstraints(H)
        NSLayoutConstraint.activateConstraints(V)
    }
}

extension InfoInputableCell: UITextViewDelegate {
    
    func textViewDidEndEditing(textView: UITextView) {
        let text = textView.text.trimming(.WhitespaceAndNewline)
        textView.text = text
    }
}

final class TagCell: UITableViewCell, Reusable {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class DisclosureCell: UITableViewCell, Reusable {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .DisclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class NewMatterViewController: BaseViewController {

    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.hi.registerReusableCell(InputableCell)
            tableView.hi.registerReusableCell(InfoInputableCell)
            tableView.hi.registerReusableCell(TagCell)
            tableView.hi.registerReusableCell(DisclosureCell)
        }
    }
    
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var datePickerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cancelItem: UIBarButtonItem!
    @IBOutlet private weak var postItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        
        tableView.contentInset.top = Defaults.navigationBarWithoutStatusBarHeight
        
        cancelItem.rx_tap
            .subscribeNext { [weak self] in
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

/*
extension NewMatterViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
*/

extension NewMatterViewController: UITableViewDataSource {
    
    private enum Section: Int {
        case Title = 0
        case Tag
        case When
        case Body
        
        static var count: Int {
            return Section.Body.rawValue + 1
        }
        
        var annotation: String {
            switch self {
            case .Title: return "Title"
            case .Tag: return "Tag"
            case .When: return "Happen"
            case .Body: return "Description"
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Section.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Section Error")
        }
        
        switch section {
        case .Title:
            let cell: InputableCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.textField.placeholder = "What's the Matter"
            return cell
        case .Tag:
            let cell: TagCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.textLabel?.text = section.annotation
            return cell
        case .Body:
            let cell: InfoInputableCell = tableView.hi.dequeueReusableCell(for: indexPath)
            
            return cell
        case .When:
            let cell: DisclosureCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.text = section.annotation
            cell.detailTextLabel?.text = "2016/10/10"
            return cell            
        }
    }
}

extension NewMatterViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == Section.Body.rawValue ? 100 : Defaults.rowHeight
    }
}
