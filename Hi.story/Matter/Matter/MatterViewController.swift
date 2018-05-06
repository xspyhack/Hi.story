//
//  MatterViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxSwift
import RxCocoa
import RxDataSources
import RealmSwift

final class MatterViewController: BaseViewController {
    
    @IBOutlet private weak var notesTextView: UITextView! {
        didSet {
            notesTextView.textContainerInset = UIEdgeInsets(top: 12.0, left: 8.0, bottom: 12.0, right: 8.0)
            notesTextView.textColor = UIColor.hi.body
        }
    }
    
    @IBOutlet private weak var whenLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = UIColor.hi.title
        }
    }
    
    var viewModel: MatterViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Matter"
        
        guard let viewModel = viewModel else { return }
        
        configure(with: viewModel)

        if Defaults.handoffEnabled {
            startUserActivity()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let userInfo = userActivity?.userInfo {
            if let json = userInfo[Configuration.UserActivity.matterUserInfoKey] as? [String: Any], let sharedMatter = SharedMatter.with(json: json) {
                
                let matter = Matter.from(sharedMatter)
                self.viewModel = MatterViewModel(matter: matter)
                
                if let viewModel = self.viewModel {
                    configure(with: viewModel)
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopUserActivity()
    }
    
    private func configure(with viewModel: MatterViewModel) {
        
        viewModel.title
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.when
            .drive(whenLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.notes
            .drive(notesTextView.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.tag
            .drive(onNext: { [weak self] textColor in
                self?.titleLabel.textColor = textColor
                self?.whenLabel.textColor = textColor
            })
            .disposed(by: disposeBag)
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        userActivity = activity
        
        super.restoreUserActivityState(activity)
    }
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        if let matter = viewModel?.matter {
            activity.addUserInfoEntries(from: [Configuration.UserActivity.matterUserInfoKey: Matter.shared(with: matter).json])
        }
        super.updateUserActivityState(activity)
    }
    
    private func startUserActivity() {
        guard let matter = viewModel?.matter else { return }
        
        let activity = NSUserActivity(activityType: Configuration.UserActivity.watch)
        activity.title = "Watch Matter"
        activity.userInfo = [Configuration.UserActivity.matterUserInfoKey: Matter.shared(with: matter).json]
            
        userActivity = activity
        userActivity?.becomeCurrent()
    }
    
    private func stopUserActivity() {
        userActivity?.invalidate()
    }
}
