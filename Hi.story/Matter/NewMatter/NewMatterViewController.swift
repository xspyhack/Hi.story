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
import RealmSwift

final class InputableCell: UITableViewCell, Reusable {
    
    var changedAction: ((String) -> Void)?
    
    var didBeginInputingAction: (() -> Void)?
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.textAlignment = .Center
        textField.textColor = UIColor.hi.textColor
        return textField
    }()
    
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        textLabel?.textColor = UIColor.hi.titleColor
        
        textField.rx_text
            .subscribeNext { [weak self] text in
                self?.changedAction?(text)
            }
            .addDisposableTo(disposeBag)
        
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        didBeginInputingAction?()
    }
}

final class InfoInputableCell: UITableViewCell, Reusable {
    
    var didBeginInputingAction: (() -> Void)?
    
    var textViewDidChangeAction: ((CGFloat) -> Void)?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.titleColor
        return label
    }()
    
    private let textViewMinixumHeight: CGFloat = 30.0
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.scrollEnabled = false
        textView.textColor = UIColor.hi.textColor
        textView.font = UIFont.systemFontOfSize(14.0)
        return textView
    }()
    
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        textLabel?.textColor = UIColor.hi.titleColor
        
        contentView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "titleLabel": titleLabel,
            "textView": textView,
        ]
        
        let H = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[textView]-20-|", options: [], metrics: nil, views: views)
        let V = NSLayoutConstraint.constraintsWithVisualFormat("V:|-16-[titleLabel(30)]-10-[textView(>=30)]-20-|", options: [.AlignAllLeading, .AlignAllTrailing], metrics: nil, views: views)
        
        NSLayoutConstraint.activateConstraints(H)
        NSLayoutConstraint.activateConstraints(V)
    }
}

extension InfoInputableCell: UITextViewDelegate {
    
    func textViewDidEndEditing(textView: UITextView) {
        let text = textView.text.trimming(.WhitespaceAndNewline)
        textView.text = text
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        didBeginInputingAction?()
    }
    
    func textViewDidChange(textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: CGRectGetWidth(textView.frame), height: CGFloat.max))
        //var bounds = textView.bounds
        //bounds.size = size
        //textView.bounds = bounds
        //textViewHeightConstraint.constant = max(textViewMinixumHeight, size.height)
        textViewDidChangeAction?(size.height + 80.0)
    }
}

final class TagItemCell: UICollectionViewCell, Reusable {
    
    var itemColor: UIColor = UIColor.tintColor() {
        didSet {
            outerView.backgroundColor = itemColor
            innerView.backgroundColor = itemColor
        }
    }
    
    private lazy var outerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.layer.cornerRadius = Constant.outerSize.width / 2.0
        return view
    }()

    private lazy var gapView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.layer.cornerRadius = Constant.gapSize.width / 2.0
        view.hidden = true
        return view
    }()
    private lazy var innerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.layer.cornerRadius = Constant.innerSize.width / 2.0
        return view
    }()
    
    private struct Constant {
        static let outerSize = CGSize(width: 16.0, height: 16.0)
        static let gapSize = CGSize(width: 14.0, height: 14.0)
        static let innerSize = CGSize(width: 10.0, height: 10.0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        contentView.addSubview(outerView)
        contentView.addSubview(gapView)
        contentView.addSubview(innerView)
        
        outerView.translatesAutoresizingMaskIntoConstraints = false
        gapView.translatesAutoresizingMaskIntoConstraints = false
        innerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints(makeSize(item: outerView, constant: Constant.outerSize))
        NSLayoutConstraint.activateConstraints(makeSize(item: gapView, constant: Constant.gapSize))
        NSLayoutConstraint.activateConstraints(makeSize(item: innerView, constant: Constant.innerSize))
        
        NSLayoutConstraint.activateConstraints(makeCenter(item: outerView))
        NSLayoutConstraint.activateConstraints(makeCenter(item: gapView))
        NSLayoutConstraint.activateConstraints(makeCenter(item: innerView))
    }
    
    private func makeSize(item item: UIView, constant: CGSize) -> [NSLayoutConstraint] {
        let width = NSLayoutConstraint(item: item, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: constant.width)
        let height =  NSLayoutConstraint(item: item, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: constant.height)
        return [width, height]
    }
    
    private func makeCenter(item item: UIView) -> [NSLayoutConstraint] {
        let centerX = NSLayoutConstraint(item: item, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let centerY = NSLayoutConstraint(item: item, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        return [centerX, centerY]
    }
    
    func setSelected(flag: Bool, animated: Bool) {
        gapView.hidden = !flag
    }
}

final class TagCell: UITableViewCell, Reusable {
    
    var items: [Tag] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var pickedAction: ((Tag) -> Void)?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.titleColor
        return label
    }()
    
    private struct Constant {
        static let margin: CGFloat = 20.0
    }
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.showsHorizontalScrollIndicator = false
    
        return collectionView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        collectionView.hi.registerReusableCell(TagItemCell)
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "titleLabel": titleLabel,
            "collectionView": collectionView,
        ]
        
        let V = NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil, views: views)
        let H = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[titleLabel]-20-[collectionView]-20-|", options: [.AlignAllCenterY], metrics: nil, views: views)
        
        NSLayoutConstraint.activateConstraints(H)
        NSLayoutConstraint.activateConstraints(V)
    }
}

extension TagCell: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let tag = items[safe: indexPath.item] else { return TagItemCell() }
        
        let cell: TagItemCell = collectionView.hi.dequeueReusableCell(for: indexPath)
        cell.itemColor = UIColor(hex: tag.value)
        return cell
    }
}

extension TagCell: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? TagItemCell, item = items[safe: indexPath.item] else { return }
        
        let visibleCells = collectionView.visibleCells()
        
        for cell in visibleCells {
            (cell as? TagItemCell)?.setSelected(false, animated: true)
        }
        
        cell.setSelected(true, animated: false)
        
        pickedAction?(item)
    }
}

extension TagCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width / CGFloat(items.count)
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
}

final class DisclosureCell: UITableViewCell, Reusable {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .DisclosureIndicator
        
        textLabel?.textColor = UIColor.hi.titleColor
        detailTextLabel?.textColor = UIColor.hi.textColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - NewMatterViewController

final class NewMatterViewController: BaseViewController {

    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.hi.registerReusableCell(InputableCell)
            tableView.hi.registerReusableCell(InfoInputableCell)
            tableView.hi.registerReusableCell(TagCell)
            tableView.hi.registerReusableCell(DisclosureCell)
            tableView.hi.registerReusableCell(DatePickerCell)
        }
    }
    
    @IBOutlet private weak var cancelItem: UIBarButtonItem!
    @IBOutlet private weak var postItem: UIBarButtonItem!
    
    private struct Constant {
        static let pickerRowHeight: CGFloat = 200.0
        static var notesRowHeight: CGFloat = 120.0
    }
    
    private var pickedDate: NSDate = NSDate() {
        willSet {
            guard newValue != pickedDate else { return }
            
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: Section.When.rawValue))
            cell?.detailTextLabel?.text = newValue.hi.yearMonthDay
        }
    }
    
    private var subject: String? {
        didSet {
            guard let subject = subject else { return }
            isDirty = !subject.isEmpty
        }
    }
    private var tag: Tag = .None
    
    private var isDirty = false {
        willSet {
            postItem.enabled = newValue
        }
    }
    
    private var datePickerIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        
        postItem.enabled = false
        
        tableView.contentInset.top = Defaults.navigationBarWithoutStatusBarHeight
        
        // MARK: Setup
        
        cancelItem.rx_tap
            .subscribeNext { [weak self] in
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
        postItem.rx_tap
            .map { [weak self] in self?.isDirty }
            .subscribeNext { [weak self] in
                self?.tryToPostNewMatter()
            }
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func tryToPostNewMatter() {
        guard let subject = subject else { return }
        
        let matter = Matter()
        matter.title = subject
        matter.tag = tag.rawValue
        matter.happenedUnixTime = pickedDate.timeIntervalSince1970
        
        if let bodyCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: Section.Body.rawValue)) as? InfoInputableCell {
            matter.body = bodyCell.textView.text
        }
        
        guard let realm = try? Realm() else { return }
        
        MatterService.sharedService.synchronize(matter, toRealm: realm)
        
        delay(0.1) { [weak self] in
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: Picker
    
    private func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }
    
    private func indexPathHasPicker(indexPath: NSIndexPath) -> Bool {
        return (hasInlineDatePicker() && datePickerIndexPath?.row == indexPath.row)
    }
    
    private func hasPicker(for indexPath: NSIndexPath) -> Bool {
        let targetedRow = indexPath.row + 1
        
        let checkDatePickerCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection: indexPath.section))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(datePickerTag) as? UIDatePicker
        
        return (checkDatePicker != nil)
    }
        
    private func toggleDatePicker(for selectedIndexPath: NSIndexPath) {
        tableView.beginUpdates()
        
        // date picker index path
        let indexPaths = [NSIndexPath(forRow: selectedIndexPath.row + 1, inSection: selectedIndexPath.section)]
        
        // check if 'indexPath' has an attached date picker below it
        if hasPicker(for: selectedIndexPath) {
            // found a picker below it, so remove it
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            datePickerIndexPath = nil
        } else {
            // didn't find a picker below it, so we should insert it
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            datePickerIndexPath = indexPaths.first
        }
        
        tableView.endUpdates()
    }
    
    private func displayInlineDatePicker(for indexPath: NSIndexPath) {
        
        toggleDatePicker(for: indexPath)
    }
    
    private func hideInlineDatePicker() {
        
        if hasInlineDatePicker(), let indexPath = datePickerIndexPath {
            
            tableView.beginUpdates()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            datePickerIndexPath = nil
            
            tableView.endUpdates()
        }
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
            case .Body: return "Notes"
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Section.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == Section.When.rawValue && hasInlineDatePicker()) ? 2 : 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("*** Fatal error *** in tableView(_:cellForRowAtIndexPath:)")
        }
        
        switch section {
        case .Title:
            let cell: InputableCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.textField.placeholder = "What's the Matter"
            cell.changedAction = { [weak self] text in
                self?.subject = text
            }
            cell.didBeginInputingAction = { [weak self] in
                self?.hideInlineDatePicker()
            }
            return cell
        case .Tag:
            let cell: TagCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = section.annotation
            cell.items = Tag.tags
            cell.pickedAction = { [weak self] tag in
                self?.tag = tag
            }
            return cell
        case .Body:
            let cell: InfoInputableCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = section.annotation
            
            cell.didBeginInputingAction = { [weak self] in
                self?.hideInlineDatePicker()
            }
            cell.textViewDidChangeAction = { height in
                if height != Constant.notesRowHeight && height >= 120 {
                    tableView.beginUpdates()
                    Constant.notesRowHeight = height
                    tableView.endUpdates()
                }
            }
            return cell
        case .When:
            if indexPathHasPicker(indexPath) {
                let cell: DatePickerCell = tableView.hi.dequeueReusableCell(for: indexPath)
                cell.pickedAction = { [weak self] date in
                    self?.pickedDate = date
                }
                return cell
            } else {
                let cell: DisclosureCell = tableView.hi.dequeueReusableCell(for: indexPath)
                cell.textLabel?.text = section.annotation
                cell.detailTextLabel?.text = pickedDate.hi.yearMonthDay
                return cell
            }
        }
    }
}

extension NewMatterViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        // Selected date cell
        if indexPath.section == Section.When.rawValue && indexPath.row == 0 {
            
            view.endEditing(true)
            
            // show date picker
            displayInlineDatePicker(for: indexPath)
            
        } else {
            hideInlineDatePicker()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == datePickerIndexPath {
            return Constant.pickerRowHeight
        } else {
            
            return indexPath.section == Section.Body.rawValue ? Constant.notesRowHeight : Defaults.rowHeight
        }
    }
}
