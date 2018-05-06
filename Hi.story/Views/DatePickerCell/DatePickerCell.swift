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

final class DatePickerCell: UITableViewCell, Reusable {
    
    var pickedAction: ((Date) -> Void)?
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.tag = datePickerTag
        datePicker.datePickerMode = .date
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
    
        datePicker.rx.date
            .subscribe(onNext: { [weak self] (date) in
                self?.pickedAction?(date)
            })
            .disposed(by: disposeBag)
        
        contentView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["datePicker": datePicker]
        
        let H = NSLayoutConstraint.constraints(withVisualFormat: "H:|[datePicker]|", options: [], metrics: nil, views: views)
        let V = NSLayoutConstraint.constraints(withVisualFormat: "V:|[datePicker]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(H)
        NSLayoutConstraint.activate(V)
    }
}
