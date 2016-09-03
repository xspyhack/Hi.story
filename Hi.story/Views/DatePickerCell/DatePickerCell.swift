//
//  DatePickerCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/28/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxCocoa
import RxSwift

let datePickerTag = 99

class DatePickerCell: UITableViewCell, Reusable {
    
    var pickedAction: ((NSDate) -> Void)?
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.tag = datePickerTag
        datePicker.datePickerMode = .Date
        return datePicker
    }()
    
    private let disposeBag = DisposeBag()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
    
        datePicker.rx_date
            .subscribeNext { [weak self] (date) in
                self?.pickedAction?(date)
            }
            .addDisposableTo(disposeBag)
        
        contentView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["datePicker": datePicker]
        
        let H = NSLayoutConstraint.constraintsWithVisualFormat("H:|[datePicker]|", options: [], metrics: nil, views: views)
        let V = NSLayoutConstraint.constraintsWithVisualFormat("V:|[datePicker]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activateConstraints(H)
        NSLayoutConstraint.activateConstraints(V)
    }
}
