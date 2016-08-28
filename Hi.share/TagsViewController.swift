//
//  TagsViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 6/18/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import Hiconfig

class TagsViewController: UITableViewController {
    
    var pickAction: ((tag: String) -> Void)?
    
    private var tags: [String] = [
        "tag1", "tag2", "tag3", "tag4", "tag5", "tag6", "tag7"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "Choose Tag"
        view.backgroundColor = UIColor.clearColor()
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = CGFloat(HiConfig.rowHeight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        preferredContentSize = CGSize(width: view.bounds.width, height: CGFloat(HiConfig.rowHeight) * CGFloat(tags.count))
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
}

extension TagsViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TagCell", forIndexPath: indexPath)
        cell.textLabel?.text = tags[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        let tag = tags[indexPath.row]
        pickAction?(tag: tag)
    }
}