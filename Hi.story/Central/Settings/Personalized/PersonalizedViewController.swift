//
//  PersonalizedViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 18/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class PersonalizedViewController: UITableViewController {
    
    private enum Row: Int {
        
        case themes
        case covers
        
        var annotation: String {
            
            switch self {
            case .themes: return "Themes"
            case .covers: return "Cover Photos"
            }
        }
        
        static var count: Int {
            return Row.covers.rawValue + 1
        }
    }
    
    struct Constant {
        static let rowHeight: CGFloat = 60.0
        static let topInset: CGFloat = 24.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Personalized"
        clearsSelectionOnViewWillAppear = false
        
        tableView.hi.register(reusableCell: DisclosureCell.self)
        tableView.rowHeight = Constant.rowHeight
        tableView.backgroundColor = UIColor.hi.background
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DisclosureCell = tableView.hi.dequeueReusableCell(for: indexPath)
        let row = Row(rawValue: indexPath.row)
        cell.textLabel?.text = row?.annotation
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        switch Row(rawValue: indexPath.row) {
        case .themes?:
            performSegue(withIdentifier: .showThemes, sender: nil)
        case .covers?:
            performSegue(withIdentifier: .showCovers, sender: nil)
        default:
            break
        }
    }
}

extension PersonalizedViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case showCovers
        case showThemes
    }
}
