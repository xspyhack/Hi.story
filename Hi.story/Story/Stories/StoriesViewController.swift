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
    
    func viewController(_ viewController: StoriesViewController, didDeleteStory story: Story, at index: Int)
    func canEditViewController(_ viewController: StoriesViewController) -> Bool
}

final class StoriesViewController: UITableViewController {

    var stories: [Story] = []
    
    weak var delegate: StoriesViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false

        if (delegate?.canEditViewController(self)) ?? false {
            self.navigationItem.rightBarButtonItem = self.editButtonItem
        }
        
        tableView.hi.register(reusableCell: StoryCell.self)
        tableView.hi.register(reusableCell: StoryImageCell.self)
        tableView.separatorStyle = .none
        tableView.contentInset.bottom = 12.0
        tableView.scrollIndicatorInsets.bottom = 12.0
    }
    
}

// MARK: - UITableViewDataSource

extension StoriesViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return delegate?.canEditViewController(self) ?? false
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let story = stories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            delegate?.viewController(self, didDeleteStory: story, at: indexPath.row)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}

// MARK: - UITableViewDelegate

extension StoriesViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        guard let story = stories.safe[indexPath.row] else { return 0.0 }
        
        let width = tableView.bounds.width
        let height = StoryCell.height(with: story, width: width)
        return height
    }
}
