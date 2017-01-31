//
//  SettingsViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/11/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class SettingsViewController: UITableViewController {
    
    enum Section: Int {
        case connector
        case notification
        
        case birthday
        
        var annotation: String {
            switch self {
            case .connector: return "Connector"
            case .notification: return "Notifications"
            case .birthday: return "Birthday"
            }
        }
        
        var describe: String {
            switch self {
            case .connector: return "Story from your photos/reminders/calendar"
            case .notification: return "Background collecting your memories and notify you"
            case .birthday: return ""
            }
        }
        
        static var count: Int {
            return Section.birthday.rawValue + 1
        }
    }
    
    enum ConnectorRow: Int {
        case photos
        case reminders
        case calendar
        
        static var count: Int {
            return ConnectorRow.calendar.rawValue + 1
        }
    }
    
    enum NotificationRow: Int {
        case notifications
        case background
        
        static var count: Int {
            return NotificationRow.background.rawValue + 1
        }
    }
    
    struct Constant {
        static let rowHeight: CGFloat = 60.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        
        self.tableView.hi.register(reusableCell: SwitchCell.self)
        self.tableView.hi.register(reusableCell: ReusableTableViewCell.self)
        self.tableView.backgroundColor = UIColor.hi.background
        self.clearsSelectionOnViewWillAppear = false
        
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
        case .connector?:
            return ConnectorRow.count
        case .notification?:
            return NotificationRow.count
        case .birthday?:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else { fatalError() }
        
        switch section {
        case .connector:
            
            guard let row = ConnectorRow(rawValue: indexPath.row) else { fatalError() }
            let cell: SwitchCell = tableView.hi.dequeueReusableCell(for: indexPath)
            
            switch row {
            case .photos:
                cell.titleLabel.text = "Photos"
                cell.toggleSwitch.isOn = Defaults.connectPhotos && hi.isAuthorized(for: .photos)
                cell.toggleSwitchStateChangedAction = { [weak self] isOn in
                    if isOn {
                        self?.hi.propose(for: .reminders, agreed: {
                            Defaults.connectPhotos = isOn
                        }, rejected: {
                            Defaults.connectPhotos = false
                            cell.toggleSwitch.isOn = false
                        })
                    } else {
                        Defaults.connectPhotos = isOn
                    }
                }
            case .calendar:
                cell.titleLabel.text = "Calendar"
                cell.toggleSwitch.isOn = Defaults.connectCalendar && hi.isAuthorized(for: .calendar)
                cell.toggleSwitchStateChangedAction = { [weak self] isOn in
                    if isOn {
                        self?.hi.propose(for: .calendar, agreed: {
                            Defaults.connectCalendar = isOn
                        }, rejected: {
                            Defaults.connectCalendar = false
                            cell.toggleSwitch.isOn = false
                        })
                    } else {
                        Defaults.connectCalendar = isOn
                    }
                }
            case .reminders:
                cell.titleLabel.text = "Reminders"
                cell.toggleSwitch.isOn = Defaults.connectReminders && hi.isAuthorized(for: .reminders)
                cell.toggleSwitchStateChangedAction = { [weak self] isOn in
                    if isOn {
                        self?.hi.propose(for: .reminders, agreed: {
                            Defaults.connectReminders = isOn
                        }, rejected: {
                            Defaults.connectReminders = false
                            cell.toggleSwitch.isOn = false
                        })
                    } else {
                        Defaults.connectReminders = isOn
                    }
                }
            }
            return cell
        case .notification:
            guard let row = NotificationRow(rawValue: indexPath.row) else { fatalError() }
            switch row {
            case .notifications:
                let cell: SwitchCell = tableView.hi.dequeueReusableCell(for: indexPath)
                cell.titleLabel.text = "Notifications"
                cell.toggleSwitch.isOn = Defaults.notificationsEnabled
                cell.toggleSwitchStateChangedAction = { isOn in
                    Defaults.notificationsEnabled = isOn
                }

                return cell
            case .background:
                let cell: SwitchCell = tableView.hi.dequeueReusableCell(for: indexPath)
                cell.titleLabel.text = "Background"
                cell.toggleSwitch.isOn = Defaults.backgroundModeEnabled
                cell.toggleSwitchStateChangedAction = { isOn in
                    Defaults.backgroundModeEnabled = isOn
                }
                return cell
            }
        case .birthday:
            let cell: ReusableTableViewCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.textLabel?.text = "Your birthday"
            cell.textLabel?.textColor = UIColor.hi.title
            cell.detailTextLabel?.text = "none"
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { fatalError() }
        
        return section.annotation
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
