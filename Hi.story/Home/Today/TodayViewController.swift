//
//  TodayViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/10/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RealmSwift

final class TodayViewController: UIViewController {
    
    var newAction: (() -> Void)?
    var analyzedAction: ((Bool) -> Void)?
    
    var isEmpty: Bool = true {
        didSet {
            memoriesCardView.isHidden = isEmpty
            emptyView.isHidden = !isEmpty
        }
    }
   
    private struct Constant {
        static let navigationBarHeight: CGFloat = 64.0
        static let bottomToolbarHeight: CGFloat = 44.0
        static let gap: CGFloat = 16.0
    }
    
    private lazy var memoriesCardView: MemoriesCardView = {
        let cardView = MemoriesCardView(style: .top)
        cardView.isHidden = true
        return cardView
    }()
    
    private lazy var emptyView: TodayEmptyView = {
        let emptyView = TodayEmptyView()
        return emptyView
    }()
    
    private lazy var birthdayView: BirthdayCardView = {
        let cardView = BirthdayCardView()
        cardView.isHidden = true
        return cardView
    }()
    
    private var isViewAppeared: Bool = false
    
    private let selectingCoverLinstener = "TodayViewController.selectingCover"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Today"
        
        setupEmptyView()
        
        emptyView.newAction = { [weak self] in
            self?.newAction?()
        }
        
        Defaults.selectingCover.bindListener(with: selectingCoverLinstener) { (index) in
            print(index)
        }
        
        setup(cardView: memoriesCardView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isViewAppeared {
            isViewAppeared = true
           
        }
        
        if let birthday = Defaults.birthday, Date(timeIntervalSince1970: birthday).hi.monthDay == "" {
            setup(cardView: birthdayView)
            birthdayView.start()
        }
    }
    
    func snapshot() -> UIImage? {
        return memoriesCardView.hi.capture()
    }
    
    func tryToAnalyzing() {
        analyzing()
    }
    
    private func analyzing() {
        
        defer {
            analyzedAction?(!isEmpty)
        }
       
        guard let realm = try? Realm(), let userID = HiUserDefaults.userID.value else { return }
        
        let today = Date()
        let predicate = NSPredicate(format: "creator.id = %@", userID)
        
        // Feeds
        guard let feed = (FeedService.shared.fetchAll(withPredicate: predicate, fromRealm: realm).filter { Date(timeIntervalSince1970: $0.createdAt).hi.yearMonthDay == today.hi.yearMonthDay }).first, let story = feed.story, let creator = feed.creator else {
            return
        }
        
        isEmpty = false
        
        memoriesCardView.configure(withPresenter: MemoriesCardViewModel(story: story, creator: creator))
    }
    
    private func setupEmptyView() {
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = ["emptyView": emptyView]
        
        let vConstaints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[emptyView]-bottom-|", options: [], metrics: ["top": Constant.navigationBarHeight + Constant.gap, "bottom": Constant.bottomToolbarHeight + Constant.gap], views: views)
        let ratio = NSLayoutConstraint(item: emptyView, attribute: .width, relatedBy: .equal, toItem: emptyView, attribute: .height, multiplier: 10.0 / 16.0, constant: 0.0)
        NSLayoutConstraint.activate(vConstaints)
        NSLayoutConstraint.activate([ratio])
        
        emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setup(cardView: UIView) {
        view.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = ["cardView": cardView]
        
        let vConstaints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[cardView]-bottom-|", options: [], metrics: ["top": Constant.navigationBarHeight + Constant.gap, "bottom": Constant.bottomToolbarHeight + Constant.gap], views: views)
        let ratio = NSLayoutConstraint(item: cardView, attribute: .width, relatedBy: .equal, toItem: cardView, attribute: .height, multiplier: 10.0 / 16.0, constant: 0.0)
        NSLayoutConstraint.activate(vConstaints)
        NSLayoutConstraint.activate([ratio])
        
        cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}
