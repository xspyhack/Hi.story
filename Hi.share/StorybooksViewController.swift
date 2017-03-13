//
//  StorybooksViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 12/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RealmSwift

class StorybooksViewController: UITableViewController {
    
    var choosedAction: ((_ storybook: String) -> Void)?
    
    private(set) var storybooks: [Storybook] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        title = "Choose Storybook"
        view.backgroundColor = UIColor.clear
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = CGFloat(Configuration.rowHeight)
        
        guard let realm = try? Realm() else { return }
        
        let predicate: NSPredicate
        
        if let id = HiUserDefaults.userID.value {
            predicate = NSPredicate(format: "creator.id = %@", id)
        } else {
            predicate = NSPredicate(value: true)
        }
        
        storybooks = StorybookService.shared.fetchAll(withPredicate: predicate, fromRealm: realm)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        let height = min(view.bounds.height, max(200.0, CGFloat(Configuration.rowHeight) * CGFloat(storybooks.count)))
        preferredContentSize = CGSize(width: view.bounds.width, height: height)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
}

extension StorybooksViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storybooks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StorybookCell", for: indexPath)
        cell.textLabel?.text = storybooks.safe[indexPath.row]?.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let storybook = storybooks.safe[indexPath.row]
        choosedAction?(storybook?.name ?? Configuration.Defaults.storybookName)
    }
}
