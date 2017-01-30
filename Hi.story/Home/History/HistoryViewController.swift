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
            collectionView.hi.register(reusableCell: FeedCell.self)
            collectionView.hi.register(reusableCell: FeedImageCell.self)
            collectionView.hi.register(reusableCell: MatterItemCell.self)
            collectionView.hi.registerReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, viewType: HistoryHeaderView.self)
            collectionView.alwaysBounceVertical = true
            collectionView.contentInset.top = 64.0
            collectionView.scrollIndicatorInsets.top = 64.0
            collectionView.contentInset.bottom = Defaults.tabBarHeight
            collectionView.scrollIndicatorInsets.bottom = Defaults.tabBarHeight
        }
    }
    
    fileprivate var histories: [[Timetable]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "History"
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 16.0
            flowLayout.sectionHeadersPinToVisibleBounds = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// loading, analyzing
        
        analyzing()
    }

    private func analyzing() {
        
        guard let realm = try? Realm(), let userID = HiUserDefaults.userID.value else { return }
        
        let today = Date().hi.monthDay
        let predicate = NSPredicate(format: "creator.id = %@", userID)
        
        var datas: [Timetable] = []
        
        // Feeds
        let feeds: [Feed] = FeedService.shared.fetchAll(withPredicate: predicate, fromRealm: realm).filter { $0.monthDay == today }
        datas.append(contentsOf: (feeds.map { $0 as Timetable }))
        
        // matter
        let matters: [Matter] = MatterService.shared.fetchAll(withPredicate: predicate, fromRealm: realm).filter { $0.monthDay == today }
        datas.append(contentsOf: (matters.map { $0 as Timetable }))
        
        // connecting
        // photos
        // reminders
        // calendar
        
        // Group by year
        
        group(datas.sorted(by: { $0.createdAt > $1.createdAt }))
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
        
        collectionView.reloadData()
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
                let cell: FeedImageCell = collectionView.hi.dequeueReusableCell(for: indexPath)
                cell.configure(withPresenter: FeedImageCellModel(story: story))
                return cell
            } else {
                let cell: FeedCell = collectionView.hi.dequeueReusableCell(for: indexPath)
                cell.configure(withPresenter: FeedCellModel(story: story))
                return cell
            }
        } else if let matter = history as? Matter {
            let cell: MatterItemCell = collectionView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withPresenter: MatterCellModel(matter: matter))
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let theYears = histories.safe[indexPath.section], let history = theYears.first else { fatalError() }
       
        if kind == UICollectionElementKindSectionHeader {
            let header: HistoryHeaderView = collectionView.hi.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
            let tag = Tag(rawValue: theYears.flatMap { $0 as? Matter }.first?.tag ?? Tag.randomExceptNone().rawValue ) ?? Tag.randomExceptNone()
            let color = UIColor(hex: tag.value)
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
            height = FeedCell.height(with: feed, width: width)
        } else if let matter = history as? Matter {
            height = MatterItemCell.height(with: matter, width: width)
        } else {
            height = 60.0
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44.0)
    }
}

