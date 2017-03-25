//
//  StoriesViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 12/02/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

protocol StoriesViewControllerDelegate: class {
    
    func viewController(_ viewController: StoriesViewController, didDelete story: Story, at index: Int)
    func canEditViewController(_ viewController: StoriesViewController) -> Bool
}

final class StoriesViewController: BaseViewController {

    var stories: [Story] = []
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.hi.register(reusableCell: StoryCell.self)
            tableView.hi.register(reusableCell: StoryImageCell.self)
            tableView.separatorStyle = .none
            tableView.contentInset.bottom = 12.0
            tableView.scrollIndicatorInsets.bottom = 12.0
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    weak var delegate: StoriesViewControllerDelegate?
    
    fileprivate lazy var emptyView: EmptyView = {
        let view = EmptyView(frame: .zero)
        view.backgroundColor = UIColor.white
        view.isHidden = true
        view.imageView.image = UIImage.hi.emptyStory
        view.textLabel.text = "There are no stories in this storybook."
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if ((delegate?.canEditViewController(self)) ?? false) && !stories.isEmpty {
            self.navigationItem.rightBarButtonItem = self.editButtonItem
            
            self.editButtonItem.rx.tap
                .map { [unowned self] in
                    self.tableView.isEditing
                }
                .subscribe(onNext: { [weak self] editing in
                    self?.isEditing = !editing
                    self?.tableView.setEditing(!editing, animated: true)
                })
                .addDisposableTo(disposeBag)
        }
        
        setupEmptyView()
        
        if stories.isEmpty {
            emptyView.isHidden = false
        }
    }
    
    private func setupEmptyView() {
        emptyView.addTo(view)
    }
}

// MARK: - UITableViewDataSource

extension StoriesViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let story = stories.safe[indexPath.row] else { fatalError() }
        
        if story.attachment != nil {
            let cell: StoryImageCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withPresenter: StoryImageCellModel(story: story))
            return cell
        } else {
            let cell: StoryCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withPresenter: StoryCellCellModel(story: story))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return delegate?.canEditViewController(self) ?? false
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let story = stories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            delegate?.viewController(self, didDelete: story, at: indexPath.row)
            
            if stories.isEmpty {
                emptyView.isHidden = false
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}

// MARK: - UITableViewDelegate

extension StoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        guard let story = stories.safe[indexPath.row] else { return 0.0 }
        
        let width = tableView.bounds.width
        let height = StoryCell.height(with: story, width: width)
        return height
    }
}
