//
//  EventItemCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

protocol EventItemCellModelType {
    var title: String { get }
    var createdAt: String { get }
}

struct EventItemCellModel: EventItemCellModelType {
    let title: String
    let createdAt: String
    
    init(event: Event) {
        self.title = event.title
        self.createdAt = Date(timeIntervalSince1970: event.createdAt).hi.time
    }
}

class EventItemCell: HistoryItemCell, Reusable {

    private static let titleFont = UIFont.systemFont(ofSize: 24.0)
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Event"
        label.font = EventItemCell.titleFont
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        iconImageView.image = UIImage.hi.calendarIcon
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "titleLabel": titleLabel,
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[titleLabel]-(padding)-|", options: [], metrics: ["padding": EventItemCell.iconPadding], views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(margin)-[titleLabel]|", options: [], metrics: ["margin": EventItemCell.iconContainerHeight], views: views)
        
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
    }
    
    static func height(with event: Event, width: CGFloat) -> CGFloat {
        let titleHeight = event.title.hi.height(with: width - 2 * EventItemCell.iconPadding, fontSize: titleFont.pointSize)
        return HistoryItemCell.iconContainerHeight + titleHeight
    }
}

extension EventItemCell: Configurable {
    
    func configure(withPresenter presenter: EventItemCellModelType) {
        createdAtLabel.text = presenter.createdAt
        titleLabel.text = presenter.title
    }
}
