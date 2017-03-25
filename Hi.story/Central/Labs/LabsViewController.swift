//
//  LabsViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 28/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

final class LabsViewController: UITableViewController {
    
    enum Section: Int {
        case spotlight
        case handoff
        case watch
        //case siri
        
        var annotation: String {
            switch self {
            case .spotlight: return "Spotlight"
            case .handoff: return "Handoff"
            case .watch: return "Watch"
            //case .siri: return "Siri"
            }
        }
        
        var describe: String {
            switch self {
            case .spotlight: return "Open Spotlight to search your stories"
            case .handoff: return "Handoff, free your hands"
            case .watch: return " Watch support"
            //case .siri: return "Hey Siri"
            }
        }
        
        static var count: Int {
            return Section.watch.rawValue + 1
        }
    }
    
    struct Constant {
        static let rowHeight: CGFloat = 60.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Labs"
        
        tableView.hi.register(reusableCell: SwitchCell.self)
        tableView.hi.register(reusableCell: DisclosureCell.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .spotlight?:
            return 1
        case .handoff?:
            return 1
        case .watch?:
            return 1
        //case .siri?:
        //    return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else { fatalError() }
        
        switch section {
        case .spotlight:
            let cell: SwitchCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = section.annotation
            cell.toggleSwitch.isOn = Defaults.spotlightEnabled
            cell.toggleSwitchStateChangedAction = { isOn in
                Defaults.spotlightEnabled = isOn
            }
            return cell
        case .handoff:
            let cell: SwitchCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = section.annotation
            cell.toggleSwitch.isOn = Defaults.handoffEnabled
            cell.toggleSwitchStateChangedAction = { isOn in
                Defaults.handoffEnabled = isOn
            }
            
            return cell
            
        case .watch:
            let cell: DisclosureCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.textLabel?.text = section.annotation
            cell.textLabel?.textColor = UIColor.hi.title
            cell.detailTextLabel?.textColor = UIColor.hi.detail
            let state = WatchActivationState(rawValue: Defaults.watchActivationState.value)
            cell.detailTextLabel?.text = state?.name
            Defaults.watchActivationState.bindListener(with: "Labs.watch") { (state) in
                cell.detailTextLabel?.text = WatchActivationState(rawValue: state)?.name
            }
            
            cell.accessoryType = .none
            
            return cell
        /*
        case .siri:
            let cell: SwitchCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = section.annotation
            cell.toggleSwitch.isOn = Defaults.siriEnabled
            cell.toggleSwitchStateChangedAction = { isOn in
                Defaults.siriEnabled = isOn
            }
            return cell
        */
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { fatalError() }
        
        return section.describe
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}
