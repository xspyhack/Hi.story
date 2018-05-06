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

class MattersInterfaceController: WKInterfaceController {
    
    // MARK: Types
    
    struct Storyboard {
        struct RowTypes {
            static let matter = "MatterRowType"
            static let noMatters = "NoMattersRowType"
        }
        
        struct Segues {
            static let matterSelection = "showMatter"
        }
    }
    
    private var matters: [SharedMatter] = []

    // MARK: Properties
    
    @IBOutlet private var tableView: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        print("awake")

        configure(with: matters)
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

    private func configure(with matters: [SharedMatter]) {
        
        self.matters = matters
        
        guard !matters.isEmpty else {
            
            tableView.setNumberOfRows(0, withRowType: Storyboard.RowTypes.matter)
            tableView.setNumberOfRows(1, withRowType: Storyboard.RowTypes.noMatters)
            
            let row = tableView.rowController(at: 0) as? NoMattersRowController
            row?.setText(text: "No Matters")
            row?.setColor(color: UIColor.red)
            
            return
        }
        
        tableView.setNumberOfRows(0, withRowType: Storyboard.RowTypes.noMatters)
        tableView.setNumberOfRows(matters.count, withRowType: Storyboard.RowTypes.matter)

        for (index, matter) in matters.enumerated() {
            if let row = tableView.rowController(at: index) as? MatterRowController {
                let viewModel = MatterRowModel(matter: matter)
                row.configure(withPresenter: viewModel)
            }
        }
    }
}

extension MattersInterfaceController {
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        if segueIdentifier == Storyboard.Segues.matterSelection {
            let matter = matters[rowIndex]
            
            return matter
        }
        
        return nil
    }
}

extension MattersInterfaceController: WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        guard let jsons = applicationContext[Configuration.sharedMattersKey] as? [[String: Any]] else { return }
        
        let matters = jsons.compactMap { SharedMatter.with(json: $0) }
        configure(with: matters)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
}
