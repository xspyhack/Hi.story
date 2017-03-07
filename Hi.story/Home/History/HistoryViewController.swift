//
//  HistoryViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/10/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RealmSwift

final class HistoryViewController: UIViewController {

    var showFeedAction: ((Feed) -> Void)?
    var showMatterAction: ((Matter) -> Void)?
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.hi.register(reusableCell: FeedItemCell.self)
            collectionView.hi.register(reusableCell: FeedImageItemCell.self)
            collectionView.hi.register(reusableCell: MatterItemCell.self)
            collectionView.hi.register(reusableCell: PhotoItemCell.self)
            collectionView.hi.register(reusableCell: ReminderItemCell.self)
            collectionView.hi.register(reusableCell: EventItemCell.self)
            collectionView.hi.registerReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, viewType: HistoryHeaderView.self)
            collectionView.alwaysBounceVertical = true
            collectionView.contentInset.top = Constant.navigationBarHeight
            collectionView.scrollIndicatorInsets.top = Constant.navigationBarHeight
            collectionView.contentInset.bottom = 64.0
            collectionView.scrollIndicatorInsets.bottom = 64.0
        }
    }
    
    @IBOutlet private weak var promptedViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var promptedView: PromptedView! {
        didSet {
            promptedView.promptLabel.text = "Enable Hi.story to access your Photos/Reminders/Calendar in Settings to show you your memories of this day in history."
        }
    }
    @IBOutlet private weak var analyzingView: UIView!
    @IBOutlet private weak var activityIndicatorView: NVActivityIndicatorView!
    
    fileprivate var histories: [[Timetable]] = []
    
    private struct Constant {
        static let promptedViewHeight: CGFloat = 128.0
        static let navigationBarHeight: CGFloat = 64.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "History"
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 0.0
            flowLayout.sectionInset.bottom = 48.0
            flowLayout.sectionHeadersPinToVisibleBounds = true
        }
        
        promptedView.dismissAction = { [weak self] in
            self?.hidesPromptedView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hidesPromptedView()
        
        // begin loading
        func show(finish: @escaping () -> Void) {
            
            UIView.animate(withDuration: 0.01, animations: {
                self.analyzingView.alpha = 1.0
            }, completion: { finished in
                if finished {
                    finish()
                }
            })
        }
        
        // hide loading activity
        func hide(finish: @escaping () -> Void) {
            UIView.animate(withDuration: 0.25, animations: {
                self.analyzingView.alpha = 0.0
            }, completion: { (finished) in
                if finished {
                    finish()
                }
            })
        }
        
        /// loading, analyzing
        show() { [weak self] in
            SafeDispatch.async { [weak self] in
                self?.activityIndicatorView.startAnimating()
                self?.analyzing() { [weak self] datas in
                    // Group by year
                    self?.group(datas.sorted(by: { $0.createdAt > $1.createdAt }))
                    
                    SafeDispatch.async { [weak self] in
                        self?.collectionView.reloadData()
                        
                        hide { [weak self] in
                            self?.activityIndicatorView.stopAnimating()
                        }
                    }
                }
            }
        }
    }

    private func analyzing(finish: (([Timetable]) -> Void)? = nil) {
        
        guard let realm = try? Realm(), let userID = HiUserDefaults.userID.value else { return }
        
        var needsAskForAuthorized = false
        
        let today = Date()
        let predicate = NSPredicate(format: "creator.id = %@", userID)
        
        var datas: [Timetable] = []
        
        // Feeds
        let feeds: [Feed] = FeedService.shared.fetchAll(withPredicate: predicate, fromRealm: realm).filter { $0.monthDay == today.hi.monthDay }
        datas.append(contentsOf: (feeds.map { $0 as Timetable }))
        
        // matter
        let matters: [Matter] = MatterService.shared.fetchAll(withPredicate: predicate, fromRealm: realm).filter { $0.monthDay == today.hi.monthDay }
        datas.append(contentsOf: (matters.map { $0 as Timetable }))
        
        /// connecting
        
        // photos
        if hi.isAuthorized(for: .photos) && Defaults.connectPhotos {
            needsAskForAuthorized = false
            let photos = fetchMoments(at: today)
            datas.append(contentsOf: (photos.map { $0 as Timetable }))
        } else {
            needsAskForAuthorized = true
        }
        
        // calendar
        if hi.isAuthorized(for: .calendar) && Defaults.connectCalendar {
            needsAskForAuthorized = false
            let events = fetchEvents(at: today)
            datas.append(contentsOf: (events.map { $0 as Timetable }))
        } else {
            needsAskForAuthorized = true
        }
        
        // Async at latest
        // reminders
        if hi.isAuthorized(for: .reminders) && Defaults.connectReminders {
            needsAskForAuthorized = false
            
            fetchReminders(at: today) { reminders in
                
                SafeDispatch.async {
                    datas.append(contentsOf: (reminders.map { $0 as Timetable }))
                    
                    delay(2.5, task: {
                        finish?(datas)
                    })
                }
            }
        } else {
            needsAskForAuthorized = true
        }
        
        if needsAskForAuthorized {
            delay(2.5, task: { [weak self] in
                finish?(datas)
                
                // show prompted
                if datas.isEmpty {
                    self?.showsPromptedView()
                }
            })
        }
    }
    
    private func group(_ datas: [Timetable]) {
        var results = [[Timetable]]()
        
        datas.forEach {
            if var lastGroup = results.last, let element = lastGroup.last, element.year == $0.year {
                lastGroup.append($0)
                results.removeLast()
                results.append(lastGroup)
            } else {
                results.append([$0])
            }
        }
        
        histories = results
    }
    
    private func showsPromptedView() {
        promptedViewTopConstraint.constant = Constant.navigationBarHeight
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hidesPromptedView() {
        guard promptedViewTopConstraint.constant != -Constant.promptedViewHeight else { return }
        
        promptedViewTopConstraint.constant = -Constant.promptedViewHeight
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }
    }
}

extension HistoryViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return histories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let theYears = histories.safe[section] else { return 0 }
        return theYears.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let theYears = histories.safe[indexPath.section], let history = theYears.safe[indexPath.item] else { fatalError() }
        
        if let feed = history as? Feed, let story = feed.story {
            if story.attachment != nil {
                let cell: FeedImageItemCell = collectionView.hi.dequeueReusableCell(for: indexPath)
                cell.configure(withPresenter: FeedImageItemCellModel(story: story))
                return cell
            } else {
                let cell: FeedItemCell = collectionView.hi.dequeueReusableCell(for: indexPath)
                cell.configure(withPresenter: FeedItemCellModel(story: story))
                return cell
            }
        } else if let matter = history as? Matter {
            let cell: MatterItemCell = collectionView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withPresenter: MatterCellModel(matter: matter))
            return cell
        } else if let photo = history as? Photo {
            let cell: PhotoItemCell = collectionView.hi.dequeueReusableCell(for: indexPath)
            let width = collectionView.bounds.width
            cell.configure(withPresenter: PhotoItemCellModel(photo: photo, size: CGSize(width: width, height: width / photo.ratio)))
            return cell
        } else if let reminder = history as? Reminder {
            let cell: ReminderItemCell = collectionView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withPresenter: ReminderItemCellModel(reminder: reminder))
            return cell
        } else if let event = history as? Event {
            let cell: EventItemCell = collectionView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withPresenter: EventItemCellModel(event: event))
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let theYears = histories.safe[indexPath.section], let history = theYears.first else { fatalError() }
       
        if kind == UICollectionElementKindSectionHeader {
            let header: HistoryHeaderView = collectionView.hi.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
            var color = UIColor.hi.tint
            if let tag = (theYears.flatMap { $0 as? Matter }).first?.tag, let value = Tag(rawValue: tag)?.value {
                color = UIColor(hex: value)
            } else if let year = Int(Date(timeIntervalSince1970: history.createdAt).hi.year) {
                color = UIColor(hex: Tag.with(year).value)
            }
            header.configure(withPresenter: HistoryHeaderViewModel(createdAt: history.createdAt, color: color))
            return header
        } else {
            return UICollectionReusableView()
        }
    }
}

extension HistoryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let theYears = histories.safe[indexPath.section], let history = theYears.safe[indexPath.item] else { return }
       
        if let feed = history as? Feed {
            showFeedAction?(feed)
        }
        
        if let matter = history as? Matter {
            showMatterAction?(matter)
        }
    }
}

extension HistoryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        guard let theYears = histories.safe[indexPath.section], let history = theYears.safe[indexPath.item] else { fatalError() }
        let width = collectionView.bounds.width
        
        let height: CGFloat
        if let feed = history as? Feed {
            height = FeedItemCell.height(with: feed, width: width)
        } else if let matter = history as? Matter {
            height = MatterItemCell.height(with: MatterCellModel(matter: matter), width: width)
        } else if let photo = history as? Photo {
            height = PhotoItemCell.height(with: photo, width: width)
        } else if let reminder = history as? Reminder {
            height = ReminderItemCell.height(with: reminder, width: width)
        } else if let event = history as? Event {
            height = EventItemCell.height(with: event, width: width)
        } else {
            height = 60.0
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44.0)
    }
}

