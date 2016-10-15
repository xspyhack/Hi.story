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
import RealmSwift

class InterfaceController: WKInterfaceController {
    
    private var matters: [Matter] = []

    @IBOutlet private var tableView: WKInterfaceTable!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        guard let realm = try? Realm() else {
            return
        }
        
        print(realm.objects(Matter.self).count)
        
        matters = MatterService.shared.fetchAll(fromRealm: realm)
        
        configureTableView()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    private func configureTableView() {
        
        tableView.setNumberOfRows(matters.count, withRowType: "MatterRow")
        
        for (index, matter) in matters.enumerated() {
            if let row = tableView.rowController(at: index) as? MatterRow {
                let viewModel = MatterRowModel(matter: matter)
                row.configure(withPresenter: viewModel)
            }
        }
    }
}

extension InterfaceController {
    
}
