//
//  TagsViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 6/18/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

class TagsViewController: UITableViewController {
    
    var pickAction: ((_ tag: String) -> Void)?
    
    fileprivate var tags: [String] = [
        "tag1", "tag2", "tag3", "tag4", "tag5", "tag6", "tag7"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "Choose Tag"
        view.backgroundColor = UIColor.clear
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = CGFloat(Configure.rowHeight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        preferredContentSize = CGSize(width: view.bounds.width, height: CGFloat(Configure.rowHeight) * CGFloat(tags.count))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
}

extension TagsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath)
        cell.textLabel?.text = tags[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let tag = tags[(indexPath as NSIndexPath).row]
        pickAction?(tag)
    }
}
