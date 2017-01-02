//
//  UIViewController+Proposer.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 01/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit
import Proposer
import CoreLocation

extension Hi where Base: UIViewController {
    
    func propose(for resource: PrivateResource, agreed successAction: @escaping ProposerAction, rejected failureAction: ProposerAction? = nil) {
        if !resource.isAuthorized {
            if resource.isNotDeterminedAuthorization {
                Proposer.proposeToAccess(resource, agreed: successAction, rejected: {  failureAction?() })
            } else {
                alertNoPermission(to: resource, cancelAction: failureAction)
            }
        } else {
            successAction()
        }
    }
    
    func alertNoPermission(to resource: PrivateResource, cancelAction: ProposerAction? = nil) {
        
        let title = "Oops!"
        
        showDialog(title: title, message: resource.noPermissionMessage, cancelTitle: "Ok", confirmTitle: NSLocalizedString("Change it now", comment: ""), withCancelAction: cancelAction, confirmAction: {
            
            if case .location = resource {
                self.openLocatioinSettings()
                
            } else {
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:])
            }
        })
    }
    
    func openLocatioinSettings() {
        
        if CLLocationManager.locationServicesEnabled() {
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:])
        } else if UIApplication.shared.canOpenURL(URL(string: "prefs:root=LOCATION_SERVICES")!) {
            UIApplication.shared.open(URL(string: "prefs:root=LOCATION_SERVICES")!, options: [:])
        }
    }
    
    func showDialog(title: String?, message: String, cancelTitle: String, confirmTitle: String, withCancelAction cancelAction : (() -> Void)?, confirmAction: (() -> Void)?) {
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
                cancelAction?()
            }
            alertController.addAction(cancelAction)
            
            let confirmAction: UIAlertAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
                confirmAction?()
            }
            alertController.addAction(confirmAction)
            
            self.base.present(alertController, animated: true, completion: nil)
        }
    }
}

extension PrivateResource {
    
    var proposeMessage: String {
        switch self {
        case .photos:
            return NSLocalizedString("Hi.story need to access your Photos to choose photo.", comment: "")
        case .camera:
            return NSLocalizedString("Hi.story need to access your Camera to take photo.", comment: "")
        case .microphone:
            return NSLocalizedString("Hi.story need to access your Microphone to record audio.", comment: "")
        case .contacts:
            return NSLocalizedString("Hi.story need to access your Contacts to match friends.", comment: "")
        case .reminders:
            return NSLocalizedString("Hi.story need to access your Reminders to create reminder.", comment: "")
        case .calendar:
            return NSLocalizedString("Hi.story need to access your Calendar to create event.", comment: "")
        case .location:
            return NSLocalizedString("Hi.story need to get your Location to share to your friends.", comment: "")
        case .notifications:
            return NSLocalizedString("Hi.story need to get your Notifications to share to your friends.", comment: "")
        }
    }
    
    var noPermissionMessage: String {
        switch self {
        case .photos:
            return NSLocalizedString("Hi.story can not access your Camera Roll!\nBut you can change it in iOS Settings.", comment: "")
        case .camera:
            return NSLocalizedString("Hi.story can not open your Camera!\nBut you can change it in iOS Settings.", comment: "")
        case .microphone:
            return NSLocalizedString("Hi.story can not access your Microphone!\nBut you can change it in iOS Settings.", comment: "")
        case .contacts:
            return NSLocalizedString("Hi.story can not read your Contacts!\nBut you can change it in iOS Settings.", comment: "")
        case .reminders:
            return NSLocalizedString("Hi.story can not access your Reminders, but you can change it in iOS Settings.", comment: "")
        case .calendar:
            return NSLocalizedString("Hi.story can not access your Calendar, but you can change it in iOS Settings.", comment: "")
        case .location:
            return NSLocalizedString("Hi.story can not get your Location!\nBut you can change it in iOS Settings.", comment: "")
        case .notifications:
            return NSLocalizedString("Hi.story can not get your Notifications!\nBut you can change it in iOS Settings.", comment: "")
        }
    }
}
