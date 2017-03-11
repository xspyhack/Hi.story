//
//  NoMattersRowController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 11/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import WatchKit

class NoMattersRowController: NSObject {

    @IBOutlet var textLabel: WKInterfaceLabel!
    
    func setText(text: String) {
        textLabel.setText(text)
    }
    
    func setColor(color: UIColor) {
        textLabel.setTextColor(color)
    }
}
