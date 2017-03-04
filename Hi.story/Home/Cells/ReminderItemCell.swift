//
//  ReminderItemCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

protocol ReminderItemCellModelType {
    var title: String { get }
    var createdAt: String { get }
    var isCompleted: Bool { get }
    var completedDate: String? { get }
}

struct ReminderItemCellModel: ReminderItemCellModelType {
    let title: String
    let createdAt: String
    let isCompleted: Bool
    let completedDate: String?
    
    init(reminder: Reminder) {
        self.title = reminder.title
        self.createdAt = Date(timeIntervalSince1970: reminder.createdAt).hi.time
        self.isCompleted = reminder.isCompleted
        self.completedDate = reminder.completionDate.map { $0.hi.yearMonthDay }
    }
}

class ReminderItemCell: HistoryItemCell, Reusable {
  
    private static let titleFont = UIFont.systemFont(ofSize: 24.0)
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reminder"
        label.font = ReminderItemCell.titleFont
        label.numberOfLines = 0
        label.textColor = UIColor.hi.title
        return label
    }()
    
    lazy var completedImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var completedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
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
        
        iconImageView.image = UIImage.hi.remindersIcon
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(completedImageView)
        completedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(completedLabel)
        completedLabel.translatesAutoresizingMaskIntoConstraints = false
       
        let views: [String: Any] = [
            "titleLabel": titleLabel,
            "completedImageView": completedImageView,
            "completedLabel": completedLabel,
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[titleLabel]-(padding)-|", options: [], metrics: ["padding": ReminderItemCell.iconPadding], views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(margin)-[titleLabel]-16-[completedImageView(16)]|", options: [.alignAllLeading], metrics: ["margin": ReminderItemCell.iconContainerHeight], views: views)
        
        let completedH = NSLayoutConstraint.constraints(withVisualFormat: "H:[completedImageView(16)]-8-[completedLabel]", options: [.alignAllCenterY], metrics: nil, views: views)
        NSLayoutConstraint.activate(completedH)
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
    }
    
    static func height(with reminder: Reminder, width: CGFloat) -> CGFloat {
        let titleHeight = reminder.title.hi.height(with: width - 2 * ReminderItemCell.iconPadding, fontSize: titleFont.pointSize)
        return ReminderItemCell.iconContainerHeight + titleHeight + 16.0 + 16.0
    }
}

extension ReminderItemCell: Configurable {
    
    func configure(withPresenter presenter: ReminderItemCellModelType) {
        createdAtLabel.text = presenter.createdAt
        titleLabel.text = presenter.title
        completedImageView.image = presenter.isCompleted ? UIImage.hi.completed : UIImage.hi.unCompleted
        completedLabel.text = presenter.completedDate
    }
}
