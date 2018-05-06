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
        
        case personalized
        
        var annotation: String {
            switch self {
            case .connector: return "Connector"
            case .notification: return "Notifications"
            case .birthday: return "Birthday"
            case .personalized: return "Personalized"
            }
        }
        
        var describe: String {
            switch self {
            case .connector: return "Gather stories from your photos/reminders/calendar"
            case .notification: return "Background collecting your memories and notify you"
            case .birthday: return "Surprise for you"
            case .personalized: return ""
            }
        }
        
        static var count: Int {
            return Section.personalized.rawValue + 1
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
        static let pickerRowHeight: CGFloat = 200.0
    }

    private var datePickerIndexPath: IndexPath?
    private var pickedDate: Date? {
        willSet {
            guard newValue != pickedDate else { return }
            
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: Section.birthday.rawValue))
            cell?.detailTextLabel?.text = newValue?.hi.yearMonthDay
        }
        
        didSet {
            Defaults.birthday = pickedDate?.timeIntervalSince1970
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        
        if !Defaults.hadInitializeBackgroundMode {
            Defaults.hadInitializeBackgroundMode = true
            Defaults.backgroundModeEnabled = hi.isAuthorizedForBackgroundMode()
        }
        
        self.tableView.hi.register(reusableCell: SwitchCell.self)
        self.tableView.hi.register(reusableCell: DisclosureCell.self)
        self.tableView.hi.register(reusableCell: DatePickerCell.self)
        self.tableView.backgroundColor = UIColor.hi.background
        self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Picker
    
    private func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }
    
    private func indexPathHasPicker(_ indexPath: IndexPath) -> Bool {
        return (hasInlineDatePicker() && datePickerIndexPath?.row == indexPath.row)
    }
    
    private func hasPicker(for indexPath: IndexPath) -> Bool {
        let targetedRow = indexPath.row + 1
        
        let checkDatePickerCell = tableView.cellForRow(at: IndexPath(row: targetedRow, section: indexPath.section))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(datePickerTag) as? UIDatePicker
        
        return (checkDatePicker != nil)
    }
    
    private func toggleDatePicker(for selectedIndexPath: IndexPath) {
        tableView.beginUpdates()
        
        // date picker index path
        let indexPaths = [IndexPath(row: selectedIndexPath.row + 1, section: selectedIndexPath.section)]
        
        // check if 'indexPath' has an attached date picker below it
        if hasPicker(for: selectedIndexPath) {
            // found a picker below it, so remove it
            tableView.deleteRows(at: indexPaths, with: .fade)
            datePickerIndexPath = nil
            tableView.endUpdates()
        } else {
            // didn't find a picker below it, so we should insert it
            tableView.insertRows(at: indexPaths, with: .fade)
            datePickerIndexPath = indexPaths.first
            tableView.endUpdates()
            tableView.scrollToRow(at: datePickerIndexPath!, at: .bottom, animated: true)
        }
    }
    
    private func displayInlineDatePicker(for indexPath: IndexPath) {
        
        toggleDatePicker(for: indexPath)
    }
    
    private func hideInlineDatePicker() {
        
        if hasInlineDatePicker(), let indexPath = datePickerIndexPath {
            
            tableView.beginUpdates()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            datePickerIndexPath = nil
            
            tableView.endUpdates()
        }
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
            return hasInlineDatePicker() ? 2 : 1
        case .personalized?:
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
                        self?.hi.propose(for: .photos, agreed: {
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
                hi.isAuthorizedForNotifications { granted in
                    SafeDispatch.async(forWork: {
                        cell.toggleSwitch.isOn = granted
                        Defaults.notificationsEnabled = granted
                    })
                }
                
                cell.toggleSwitchStateChangedAction = { isOn in
                    
                    if Defaults.notificationsEnabled && !isOn {
                        Defaults.notificationsEnabled = isOn
                    } else if !Defaults.notificationsEnabled && isOn {
                        // ask for authorize
                        self.hi.alertNoPermission(self.hi.notificationsNoPermissionMessage())
                    }
                }

                return cell
            case .background:
                let cell: SwitchCell = tableView.hi.dequeueReusableCell(for: indexPath)
                cell.titleLabel.text = "Background"
                cell.toggleSwitch.isOn = hi.isAuthorizedForBackgroundMode() && Defaults.backgroundModeEnabled
                cell.toggleSwitchStateChangedAction = { isOn in
                    
                    if Defaults.backgroundModeEnabled && !isOn {
                        Defaults.backgroundModeEnabled = isOn
                    } else if !Defaults.backgroundModeEnabled && isOn {
                        self.hi.alertNoPermission(self.hi.backgroundModeNoPermissionMessage())
                    }
                }
                return cell
            }
        case .birthday:
            if indexPathHasPicker(indexPath) {
                let cell: DatePickerCell = tableView.hi.dequeueReusableCell(for: indexPath)
                cell.pickedAction = { [weak self] date in
                    self?.pickedDate = date
                }
                return cell
            } else {
                let cell: DisclosureCell = tableView.hi.dequeueReusableCell(for: indexPath)
                cell.textLabel?.text = "Your birthday"
                cell.textLabel?.textColor = UIColor.hi.title
                cell.detailTextLabel?.textColor = UIColor.hi.detail
                cell.detailTextLabel?.text = pickedDate?.hi.yearMonthDay ?? Defaults.birthday.map { Date(timeIntervalSince1970: $0).hi.yearMonthDay } ?? "unspecified"
                cell.accessoryType = .disclosureIndicator
                return cell
            }
            
        case .personalized:
            let cell: DisclosureCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.textLabel?.text = "Personalized"
            cell.textLabel?.textColor = UIColor.hi.title
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
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        // Selected date cell
        if indexPath.section == Section.birthday.rawValue && indexPath.row == 0 {
            // show date picker
            displayInlineDatePicker(for: indexPath)
        } else {
            hideInlineDatePicker()
        }
        
        if indexPath.section == Section.personalized.rawValue {
            performSegue(withIdentifier: .showPersonalized, sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == datePickerIndexPath {
            return Constant.pickerRowHeight
        } else {
            return Constant.rowHeight
        }
    }
}

extension SettingsViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case showPersonalized
    }
}
