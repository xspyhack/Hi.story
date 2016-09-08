//
//  ProfileViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Permission
import MobileCoreServices.UTType
import Hikit
import RxSwift
import RxCocoa

private let maximumHeaderHeight: CGFloat = 360.0
private let minimumHeaderHeight: CGFloat = 220.0
private let maximumAvatarWidth: CGFloat = 120.0

class ProfileViewController: BaseViewController {

    @IBOutlet private weak var storybookCollectionView: UICollectionView! {
        didSet {
            storybookCollectionView.contentInset.top = maximumHeaderHeight
            storybookCollectionView.scrollIndicatorInsets.top = maximumHeaderHeight
            storybookCollectionView.contentInset.bottom = Defaults.tabBarHeight
            storybookCollectionView.scrollIndicatorInsets.bottom = Defaults.tabBarHeight
            storybookCollectionView.hi.registerReusableCell(StorybookCell)
        }
    }
    
    @IBOutlet private weak var matterTableView: UITableView! {
        didSet {
            matterTableView.contentInset.top = maximumHeaderHeight
            matterTableView.scrollIndicatorInsets.top = maximumHeaderHeight
            matterTableView.contentInset.bottom = Defaults.tabBarHeight
            matterTableView.scrollIndicatorInsets.bottom = Defaults.tabBarHeight
            matterTableView.rowHeight = Constant.matterRowHeight
            matterTableView.hi.registerReusableCell(MatterCell)
        }
    }
    
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var avatarImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var bioLabel: UILabel!
    
    @IBOutlet private weak var bioContainerHeightConstraint: NSLayoutConstraint!
    
    private var headerHeight: CGFloat = 0.0
    private var bioHeight: CGFloat = 30.0
    
    private lazy var blurEffect = UIBlurEffect(style: .Light)

    @IBOutlet private weak var blurEffectView: UIVisualEffectView! {
        didSet {
            blurEffectView.effect = blurEffect
        }
    }
    
    private struct Constant {
        static let gap: CGFloat = 4.0
        static let numberOfRow = 4
        static let ratio: CGFloat = 3 / 4
        static let matterRowHeight: CGFloat = 64.0
    }
    
    private enum Channel: Int {
        case Storybook = 0
        case Matter
    }
    
    private var channel: Channel = .Matter {
        willSet {
    
            guard newValue != channel else { return }
            
            // 这里或许需要手动调整 headerView 的高度，因为虽然使得 scrollView.scrollToTop() 了，但是不一定会调用 scrollViewDidScroll(_:) 方法。
            // 即 headerView 不一定会跟随 contentOffset.y 来调整高度，所以可能会出现空白。
            switch newValue {
            case .Storybook:
                
                storybookCollectionView.hidden = false
                matterTableView.hidden = true
                
                //matterTableView.hi.forceStop()
                //storybookCollectionView.hi.scrollToTop(animated: false)
                
                // 为了提供更好的用户体验，切换 channel 后，不进行 headerView 高度的改变。
                // 而是保持之前的状态，所以只需要调整 contentOffset 即可。
                let contentOffsetY = matterTableView.contentOffset.y
                storybookCollectionView.contentOffset.y = min(contentOffsetY, -minimumHeaderHeight)
            case .Matter:
                
                matterTableView.hidden = false
                storybookCollectionView.hidden = true
                
                //storybookCollectionView.hi.forceStop()
                //matterTableView.hi.scrollToTop(animated: false)
                
                // 同上
                let contentOffsetY = storybookCollectionView.contentOffset.y
                matterTableView.contentOffset.y = min(contentOffsetY, -minimumHeaderHeight)
            }
            
            //headerHeight = maximumHeaderHeight
            //updateHeaderViewConstraints(animated: true)
        }
    }
    
    private lazy var settingsItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(named: "nav_settings")
        return item
    }()
    
    private var matters: [Matter]?
    private var storybooks: [Storybook]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "__b233"
        
        navigationItem.rightBarButtonItem = settingsItem
        
        segmentedControl.rx_value
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] index in
                self?.channel = Channel(rawValue: index)!
            }
            .addDisposableTo(disposeBag)
        
        if let flowLayout = storybookCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = Constant.gap
            flowLayout.minimumInteritemSpacing = Constant.gap
            let inset = Constant.gap / 2.0
            flowLayout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset + Defaults.tabBarHeight, right:  inset)
        }
        
        headerViewHeightConstraint.constant = maximumHeaderHeight
        bioContainerHeightConstraint.constant = bioHeight
        
        settingsItem.rx_tap
            .subscribeNext { [weak self] in
                self?.tryToShowSettings()
            }
            .addDisposableTo(disposeBag)
        
    }
    
    private func tryToShowSettings() {
        performSegue(withIdentifier: .ShowMatters, sender: nil)
    }
}

extension ProfileViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case Edit
        case ShowQRCode
        case ShowMatters
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segueIdentifier(forSegue: segue) {
        case .Edit:
            print("edit")
        case .ShowQRCode:
            break
        case .ShowMatters:
            break
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension ProfileViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: StorybookCell = collectionView.hi.dequeueReusableCell(for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        //guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? StorybookCell, storybook = storybooks?[safe: indexPath.item] else { return }
        
        //let storybookCellModel = StorybookCellModel(storybook: storybook)
        //cell.configure(withPresenter: storybookCellModel)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.bounds.width
        
        let itemWidth = (collectionViewWidth - Constant.gap - CGFloat((Constant.numberOfRow - 1)) * Constant.gap) / CGFloat(Constant.numberOfRow)
        
        return CGSize(width: itemWidth, height: itemWidth / Constant.ratio)
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: MatterCell = tableView.hi.dequeueReusableCell(for: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? MatterCell, matter = matters?[safe: indexPath.row] else { return }
        
        //let matterCellModel = MatterCellModel(matter: matter)
        //cell.configure(withPresenter: matterCellModel)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

// MARK: - UIScrollViewDelegate

extension ProfileViewController {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        
        headerHeight = max(min(-(offsetY), maximumHeaderHeight), minimumHeaderHeight) // 220 ~ 360
        
        updateHeaderViewConstraints()
    }
    
    func updateHeaderViewConstraints(animated animate: Bool = false) {
        
        headerViewHeightConstraint.constant = headerHeight
        
        avatarImageViewWidthConstraint.constant = (headerHeight / maximumHeaderHeight) * maximumAvatarWidth
        
        bioContainerHeightConstraint.constant = bioHeight * ((headerHeight - minimumHeaderHeight) / (maximumHeaderHeight - minimumHeaderHeight))
        
        if animate {
            UIView.animateWithDuration(0.35, delay: 0.0, options: [.CurveLinear], animations: {
                self.headerView.layoutIfNeeded()
                self.avatarImageView.layoutIfNeeded()
            }, completion: nil)
        } else {
            headerView.layoutIfNeeded()
            avatarImageView.layoutIfNeeded()
        }
    }
}
