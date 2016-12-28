//
//  CentralViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 27/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class CentralViewController: BaseViewController {

    fileprivate struct Constant {
        static let profileHeight: CGFloat = 80.0
        static let rowHeight: CGFloat = 60.0
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.hi.register(reusableCell: ProfileCell.self)
            tableView.hi.register(reusableCell: GeneralCell.self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "History"
        
    }

}

extension CentralViewController: UITableViewDataSource {
    
    fileprivate enum Section: Int {
        case profile = 0
        case others
        
        static func with(_ section: Int) -> Section {
            return Section(rawValue: section) ?? .others
        }
    }
    
    fileprivate enum Row: Int {
        case drafts = 0
        case settings
        case labs
        case about
        
        var title: String {
            switch self {
            case .drafts: return "Drafts"
            case .settings: return "Settings"
            case .labs: return "Labs"
            case .about: return "About"
            }
        }
        
        static var count: Int {
            return Row.about.rawValue + 1
        }
        
        static func with(_ row: Int) -> Row {
            return Row(rawValue: row) ?? .about
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section.with(section) {
        case .profile: return 1
        case .others: return Row.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section.with(indexPath.section) {
        case .profile:
            let cell: ProfileCell = tableView.hi.dequeueReusableCell(for: indexPath)
            return cell
        case .others:
            let row = Row.with(indexPath.row)
            let cell: GeneralCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.textLabel?.text = row.title
            return cell
        }
    }
}

extension CentralViewController: UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch Section.with(indexPath.section) {
        case .profile:
            performSegue(withIdentifier: .showProfile, sender: nil)
        case .others:
            switch Row.with(indexPath.row) {
            case .drafts:
                performSegue(withIdentifier: .showDrafts, sender: nil)
            case .settings:
                performSegue(withIdentifier: .showSettings, sender: nil)
            case .labs:
                performSegue(withIdentifier: .showLabs, sender: nil)
            case .about:
                performSegue(withIdentifier: .showAbout, sender: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch Section.with(indexPath.section) {
        case .profile:
            return Constant.profileHeight
        case .others:
            return Constant.rowHeight
        }
    }
}

extension CentralViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case showProfile
        case showDrafts
        case showSettings
        case showLabs
        case showAbout
    }
}
