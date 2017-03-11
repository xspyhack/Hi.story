//
//  InterfaceController.swift
//  Hi.watch Extension
//
//  Created by bl4ckra1sond3tre on 8/6/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import WatchKit
import Foundation
import Hiwatchkit
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    
    //private var matters: [Matter] = []

    @IBOutlet private var tableView: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        print("awake")

        WatchSessionService.shared.start(withDelegate: self)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        print("activate")
        
        WatchSessionService.shared.start(withDelegate: self)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        print("Deactivate")
    }

    fileprivate func configure(with matters: [SharedMatter]) {
        
        tableView.setNumberOfRows(matters.count, withRowType: "MatterRow")

        for (index, matter) in matters.enumerated() {
            if let row = tableView.rowController(at: index) as? MatterRow {
                let viewModel = MatterRowModel(matter: matter)
                row.configure(withPresenter: viewModel)
            }
        }
    }
}

extension InterfaceController: WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        guard let jsons = applicationContext[Configuration.sharedMattersKey] as? [[String: Any]] else { return }
        
        let matters = jsons.flatMap { SharedMatter.with(json: $0) }
        configure(with: matters)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
}
