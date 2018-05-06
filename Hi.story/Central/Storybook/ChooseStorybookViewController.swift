//
//  ChooseStorybookViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 15/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RealmSwift
import RxCocoa
import RxSwift

final class ChooseStorybookViewController: UITableViewController {
    
    var ownerID: String?
    var selecting: String?
    
    var selectedAction: ((Storybook) -> Void)?
    
    private var storybooks: [Storybook] = []
    private let disposeBag = DisposeBag()
    
    private struct Constant {
        static let rowHeight: CGFloat = 64.0
        static let bottomInset: CGFloat = 28.0
    }
    
    private let generator = UISelectionFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()

        generator.prepare()
        self.clearsSelectionOnViewWillAppear = false

        let doneItem = UIBarButtonItem()
        doneItem.title = "Done"
        doneItem.style = .done
        doneItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.done()
            })
            .disposed(by: disposeBag)
        
        self.navigationItem.rightBarButtonItem = doneItem
        
        let cancelItem = UIBarButtonItem()
        cancelItem.title = "Cancel"
        cancelItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        self.navigationItem.leftBarButtonItem = cancelItem
        
        self.tableView.allowsMultipleSelection = false
        self.tableView.hi.register(reusableCell: SelectableCell.self)
        self.tableView.rowHeight = Constant.rowHeight
        self.tableView.estimatedRowHeight = Constant.rowHeight
        self.tableView.contentInset.bottom = Constant.bottomInset
        
        guard let realm = try? Realm() else { return }
        
        let predicate: NSPredicate
        
        if let id = ownerID {
            predicate = NSPredicate(format: "creator.id = %@", id)
        } else {
            predicate = NSPredicate(value: true)
        }
        
        storybooks = StorybookService.shared.fetchAll(withPredicate: predicate, fromRealm: realm)
       
        if let selecting = selecting, let index = storybooks.index(where: { $0.name == selecting }) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        }
    }
    
    private func done() {
        // Get selected row
        guard let indexPath = tableView.indexPathsForSelectedRows?.first, let storybook = storybooks.safe[indexPath.row] else {
            return
        }
        
        selectedAction?(storybook)
 
        dismiss(animated: true, completion: nil)
    }
}

extension ChooseStorybookViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storybooks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SelectableCell = tableView.hi.dequeueReusableCell(for: indexPath)
       
        guard let storybook = storybooks.safe[indexPath.row] else { return cell }
        
        let count = storybook.stories.count > 1 ? "\(storybook.stories.count) stories" : "\(storybook.stories.count) story"
        cell.configure(text: storybook.name, detail: count)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        generator.selectionChanged()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            tableView.setEditing(false, animated: true)
        }
        
        let updateAction = UITableViewRowAction(style: .normal, title: "Update") { (action, indexPath) in
            tableView.setEditing(false, animated: true)
        }
        
        return [deleteAction, updateAction]
    }
}
