//
//  MatterInterfaceController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 11/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import WatchKit
import Foundation
import Hiwatchkit
import WatchConnectivity

class MatterInterfaceController: WKInterfaceController {

    @IBOutlet var happenLabel: WKInterfaceLabel!
    @IBOutlet var notesLabel: WKInterfaceLabel!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        guard let matter = context as? SharedMatter else { return }
       
        let tag = Tag(rawValue: matter.tag) ?? Tag.random()
        let color = UIColor(hex: tag.value)
        titleLabel.setText(matter.title)
        titleLabel.setTextColor(color)
       
        let happenedAt = Date(timeIntervalSince1970: matter.happenedAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        happenLabel.setText(formatter.string(from: happenedAt))
        happenLabel.setTextColor(color)
        
        notesLabel.setText(matter.body.isEmpty ? " " : matter.body)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
