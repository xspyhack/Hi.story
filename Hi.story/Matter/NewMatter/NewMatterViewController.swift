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
        
        textField.rx.text
            .subscribe(onNext: { [weak self] text in
                self?.changedAction?(text)
            })
            .addDisposableTo(disposeBag)
        
        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "textField": textField,
        ]
        
        let H = NSLayoutConstraint.constraints(withVisualFormat: "H:|[textField]|", options: [], metrics: nil, views: views)
        let V = NSLayoutConstraint.constraints(withVisualFormat: "V:|[textField]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(H)
        NSLayoutConstraint.activate(V)
    }
}

extension InputableCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginInputingAction?()
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
    
    fileprivate lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textColor = UIColor.hi.text
        textView.font = UIFont.systemFont(ofSize: 14.0)
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
        let text = textView.text.trimming(.whitespaceAndNewline)
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

final class TagItemCell: UICollectionViewCell, Reusable {
    
    var itemColor: UIColor = UIColor.hi.tint {
        didSet {
            outerView.backgroundColor = itemColor
            innerView.backgroundColor = itemColor
        }
    }
    
    fileprivate lazy var outerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = Constant.outerSize.width / 2.0
        return view
    }()

    fileprivate lazy var gapView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = Constant.gapSize.width / 2.0
        view.isHidden = true
        return view
    }()
    fileprivate lazy var innerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = Constant.innerSize.width / 2.0
        return view
    }()
    
    fileprivate struct Constant {
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
    
    fileprivate func setup() {
        
        contentView.addSubview(outerView)
        contentView.addSubview(gapView)
        contentView.addSubview(innerView)
        
        outerView.translatesAutoresizingMaskIntoConstraints = false
        gapView.translatesAutoresizingMaskIntoConstraints = false
        innerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(makeSize(item: outerView, constant: Constant.outerSize))
        NSLayoutConstraint.activate(makeSize(item: gapView, constant: Constant.gapSize))
        NSLayoutConstraint.activate(makeSize(item: innerView, constant: Constant.innerSize))
        
        NSLayoutConstraint.activate(makeCenter(item: outerView))
        NSLayoutConstraint.activate(makeCenter(item: gapView))
        NSLayoutConstraint.activate(makeCenter(item: innerView))
    }
    
    fileprivate func makeSize(item: UIView, constant: CGSize) -> [NSLayoutConstraint] {
        let width = NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: constant.width)
        let height =  NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: constant.height)
        return [width, height]
    }
    
    fileprivate func makeCenter(item: UIView) -> [NSLayoutConstraint] {
        let centerX = NSLayoutConstraint(item: item, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let centerY = NSLayoutConstraint(item: item, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        return [centerX, centerY]
    }
    
    func setSelected(_ flag: Bool, animated: Bool) {
        gapView.isHidden = !flag
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
        label.textColor = UIColor.hi.title
        return label
    }()
    
    fileprivate struct Constant {
        static let margin: CGFloat = 20.0
    }
    
    fileprivate lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
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
    
    fileprivate func setup() {
        
        collectionView.hi.register(reusableCell: TagItemCell.self)
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "titleLabel": titleLabel,
            "collectionView": collectionView,
        ] as [String : Any]
        
        let V = NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views)
        let H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[titleLabel]-20-[collectionView]-20-|", options: [.alignAllCenterY], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(H)
        NSLayoutConstraint.activate(V)
    }
}

extension TagCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let tag = items[safe: (indexPath as NSIndexPath).item] else { return TagItemCell() }
        
        let cell: TagItemCell = collectionView.hi.dequeueReusableCell(for: indexPath)
        cell.itemColor = UIColor(hex: tag.value)
        return cell
    }
}

extension TagCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TagItemCell, let item = items[safe: (indexPath as NSIndexPath).item] else { return }
        
        let visibleCells = collectionView.visibleCells
        
        for cell in visibleCells {
            (cell as? TagItemCell)?.setSelected(false, animated: true)
        }
        
        cell.setSelected(true, animated: false)
        
        pickedAction?(item)
    }
}

extension TagCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / CGFloat(items.count)
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
}

final class DisclosureCell: UITableViewCell, Reusable {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
        
        textLabel?.textColor = UIColor.hi.title
        detailTextLabel?.textColor = UIColor.hi.text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - NewMatterViewController

final class NewMatterViewController: BaseViewController {
    
    var viewModel: NewMatterViewModel?

    @IBOutlet fileprivate weak var navigationBar: UINavigationBar!
    @IBOutlet fileprivate weak var tableView: UITableView! {
        didSet {
            tableView.hi.register(reusableCell: InputableCell.self)
            tableView.hi.register(reusableCell: InfoInputableCell.self)
            tableView.hi.register(reusableCell: TagCell.self)
            tableView.hi.register(reusableCell: DisclosureCell.self)
            tableView.hi.register(reusableCell: DatePickerCell.self)
        }
    }
    
    @IBOutlet fileprivate weak var cancelItem: UIBarButtonItem!
    @IBOutlet fileprivate weak var postItem: UIBarButtonItem!
    
    fileprivate struct Constant {
        static let pickerRowHeight: CGFloat = 200.0
        static var notesRowHeight: CGFloat = 120.0
    }
    
    fileprivate var pickedDate: NSDate = NSDate() {
        willSet {
            guard newValue != pickedDate else { return }
            
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: Section.when.rawValue))
            cell?.detailTextLabel?.text = newValue.hi.yearMonthDay
        }
        
        didSet {
            happenedDate.value = pickedDate as Date
        }
    }
    
    fileprivate var subject: Variable<String> = Variable("")
    
    fileprivate var tag: Variable<Tag> = Variable(.none)
    
    fileprivate var datePickerIndexPath: IndexPath?
    
    private var happenedDate: Variable<Date> = Variable(Date())
    
    fileprivate var body: Variable<String> = Variable("")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        
        tableView.contentInset.top = Defaults.navigationBarWithoutStatusBarHeight
        
        // MARK: Setup
        
        let viewModel = self.viewModel ?? NewMatterViewModel()
        
        cancelItem.rx.tap
            .bindTo(viewModel.cancelAction)
            .addDisposableTo(disposeBag)
        
        postItem.rx.tap
            .bindTo(viewModel.postAction)
            .addDisposableTo(disposeBag)
        
        viewModel.postButtonEnabled
            .drive(self.postItem.rx.enabled)
            .addDisposableTo(disposeBag)
        
        viewModel.dismissViewController
            .drive(onNext: { [weak self] in
                self?.view.endEditing(true)
                self?.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
        
        subject.asObservable()
            .bindTo(viewModel.title)
            .addDisposableTo(disposeBag)
        
        tag.asObservable()
            .bindTo(viewModel.tag)
            .addDisposableTo(disposeBag)
        
        happenedDate.asObservable()
            .bindTo(viewModel.happenedUnixTime)
            .addDisposableTo(disposeBag)
        
        body.asObservable()
            .bindTo(viewModel.body)
            .addDisposableTo(disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Picker
    
    fileprivate func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }
    
    fileprivate func indexPathHasPicker(_ indexPath: IndexPath) -> Bool {
        return (hasInlineDatePicker() && (datePickerIndexPath as NSIndexPath?)?.row == (indexPath as NSIndexPath).row)
    }
    
    fileprivate func hasPicker(for indexPath: IndexPath) -> Bool {
        let targetedRow = (indexPath as NSIndexPath).row + 1
        
        let checkDatePickerCell = tableView.cellForRow(at: IndexPath(row: targetedRow, section: (indexPath as NSIndexPath).section))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(datePickerTag) as? UIDatePicker
        
        return (checkDatePicker != nil)
    }
        
    fileprivate func toggleDatePicker(for selectedIndexPath: IndexPath) {
        tableView.beginUpdates()
        
        // date picker index path
        let indexPaths = [IndexPath(row: (selectedIndexPath as NSIndexPath).row + 1, section: (selectedIndexPath as NSIndexPath).section)]
        
        // check if 'indexPath' has an attached date picker below it
        if hasPicker(for: selectedIndexPath) {
            // found a picker below it, so remove it
            tableView.deleteRows(at: indexPaths, with: .fade)
            datePickerIndexPath = nil
        } else {
            // didn't find a picker below it, so we should insert it
            tableView.insertRows(at: indexPaths, with: .fade)
            datePickerIndexPath = indexPaths.first
        }
        
        tableView.endUpdates()
    }
    
    fileprivate func displayInlineDatePicker(for indexPath: IndexPath) {
        
        toggleDatePicker(for: indexPath)
    }
    
    fileprivate func hideInlineDatePicker() {
        
        if hasInlineDatePicker(), let indexPath = datePickerIndexPath {
            
            tableView.beginUpdates()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            datePickerIndexPath = nil
            
            tableView.endUpdates()
        }
    }
}

extension NewMatterViewController: UITableViewDataSource {
    
    fileprivate enum Section: Int {
        case title = 0
        case tag
        case when
        case notes
        
        static var count: Int {
            return Section.notes.rawValue + 1
        }
        
        var annotation: String {
            switch self {
            case .title: return "Title"
            case .tag: return "Tag"
            case .when: return "Happen"
            case .notes: return "Notes"
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == Section.when.rawValue && hasInlineDatePicker()) ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: (indexPath as NSIndexPath).section) else {
            fatalError("*** Fatal error *** in tableView(_:cellForRowAtIndexPath:)")
        }
        
        switch section {
        case .title:
            let cell: InputableCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.textField.placeholder = "What's the Matter"
            cell.changedAction = { [weak self] text in
                self?.subject.value = text
            }
            cell.didBeginInputingAction = { [weak self] in
                self?.hideInlineDatePicker()
            }
            return cell
        case .tag:
            let cell: TagCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = section.annotation
            cell.items = Tag.tags
            cell.pickedAction = { [weak self] tag in
                self?.tag.value = tag
            }
            return cell
        case .notes:
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
            cell.didEndEditing = { [weak self] body in
                self?.body.value = body.trimming(.whitespaceAndNewline)
            }
            cell.textdidChange = { [weak self] body in
                self?.body.value = body
            }
            return cell
        case .when:
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        // Selected date cell
        if (indexPath as NSIndexPath).section == Section.when.rawValue && (indexPath as NSIndexPath).row == 0 {
            
            view.endEditing(true)
            
            // show date picker
            displayInlineDatePicker(for: indexPath)
            
        } else {
            hideInlineDatePicker()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == datePickerIndexPath {
            return Constant.pickerRowHeight
        } else {
            
            return (indexPath as NSIndexPath).section == Section.notes.rawValue ? Constant.notesRowHeight : Defaults.rowHeight
        }
    }
}
