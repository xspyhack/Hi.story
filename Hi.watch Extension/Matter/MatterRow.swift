//
//  MatterRow.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 14/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import WatchKit
import Hiwatchkit

protocol MatterRowModelType {
    var title: String { get }
    var days: Int { get }
    var tag: Tag { get }
}

struct MatterRowModel: MatterRowModelType {
    
    var title: String
    var days: Int
    var tag: Tag
    
    init(matter: SharedMatter) {
        self.title = matter.title
        self.days = Date().hi.absoluteDays(with: Date(timeIntervalSince1970: matter.happenedAt))
        self.tag = Tag(rawValue: matter.tag) ?? Tag.random()
    }
}

class MatterRow: NSObject {

    @IBOutlet var daysLabel: WKInterfaceLabel!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    
    func configure(withPresenter presenter: MatterRowModelType) {
        titleLabel.setText(presenter.title)
        daysLabel.setText((presenter.days > 0) ? "+\(presenter.days)" : "\(presenter.days)")
        daysLabel.setTextColor(UIColor(hex: presenter.tag.value))
    }
}
