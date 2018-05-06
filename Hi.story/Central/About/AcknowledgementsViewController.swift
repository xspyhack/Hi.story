//
//  AcknowledgementsViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 18/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

struct Project {
    let name: String
    let license: String
    let urlString: String
}

final class AcknowledgementsViewController: UITableViewController {
    
    enum Section: Int {
        case licenses
        case covers
        
        var annotation: String {
            switch self {
            case .licenses: return "Licenses"
            case .covers: return "Cover Credits"
            }
        }
        
        static var count: Int {
            return Section.covers.rawValue + 1
        }
    }
    
    private(set) lazy var projects: [Project] = {
        return [
            Project(name: "RxSwift", license: "ReactiveX - Licensed under MIT", urlString: "https://github.com/ReactiveX/RxSwift"),
            Project(name: "RxDataSources", license: "RxSwiftCommunity - Licensed under MIT", urlString: "https://github.com/RxSwiftCommunity/RxDataSources"),
            Project(name: "Kingfisher", license: "onvcat - Licensed under MIT", urlString: "https://github.com/onevcat/Kingfisher"),
            Project(name: "Realm", license: "realm - Apache License", urlString: "https://github.com/realm/realm-cocoa"),
            Project(name: "KeyboardMan", license: "nixzhu - Licensed under MIT", urlString: "https://github.com/nixzhu/KeyboardMan"),
            Project(name: "Proposer", license: "nixzhu - Licensed under MIT", urlString: "https://github.com/nixzhu/Proposer/"),
            Project(name: "Coder", license: "@xspyhack - Coded Hi.story", urlString: "https://github.com/xspyhack"),
            Project(name: "Designer", license: "@xspyhack - Designed Hi.story", urlString: "https://github.com/xspyhack"),
        ]
    }()
    
    private var covers: Project = Project(name: "Illustration", license: "@Andrey Prokopenko", urlString: "https://dribbble.com/Pro_Art/projects/385064-Illustration")
    
    struct Constant {
        static let rowHeight: CGFloat = 60.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = Constant.rowHeight
        tableView.backgroundColor = UIColor.hi.background
        tableView.tableFooterView = UIView()
    }
    
    private func safari(project: Project) {
        hi.open(URL(string: project.urlString)!)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .licenses?: return projects.count
        case .covers?: return 1
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch Section(rawValue: indexPath.section) {
        case .licenses?:
            let project = projects.safe[indexPath.row]
            cell.textLabel?.text = project?.name
            cell.detailTextLabel?.text = project?.license
        case .covers?:
            cell.textLabel?.text = covers.name
            cell.detailTextLabel?.text = covers.license
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { fatalError() }
        
        return section.annotation
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        switch Section(rawValue: indexPath.section) {
        case .licenses?:
            guard let project = projects.safe[indexPath.row] else { return }
            safari(project: project)
        case .covers?:
            safari(project: covers)
        default:
            break
        }
    }
}
