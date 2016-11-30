//
//  ProfileViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxSwift
import RxCocoa
import RealmSwift
import RxDataSources
//import Permission
import MobileCoreServices.UTType

private let maximumHeaderHeight: CGFloat = 332.0
private let minimumHeaderHeight: CGFloat = 220.0
private let maximumAvatarWidth: CGFloat = 120.0

final class ProfileViewController: BaseViewController {

    var viewModel: ProfileViewModelType?
    
    @IBOutlet private weak var storybookCollectionView: UICollectionView! {
        didSet {
            storybookCollectionView.contentInset.top = maximumHeaderHeight
            storybookCollectionView.scrollIndicatorInsets.top = maximumHeaderHeight
            storybookCollectionView.contentInset.bottom = Defaults.tabBarHeight
            storybookCollectionView.scrollIndicatorInsets.bottom = Defaults.tabBarHeight
            storybookCollectionView.hi.register(reusableCell: StorybookCell.self)
        }
    }
    
    @IBOutlet private weak var matterTableView: UITableView! {
        didSet {
            matterTableView.contentInset.top = maximumHeaderHeight
            matterTableView.scrollIndicatorInsets.top = maximumHeaderHeight
            matterTableView.contentInset.bottom = Defaults.tabBarHeight
            matterTableView.scrollIndicatorInsets.bottom = Defaults.tabBarHeight
            matterTableView.rowHeight = Constant.matterRowHeight
            matterTableView.hi.register(reusableCell: MatterCell.self)
        }
    }
    
    @IBOutlet fileprivate weak var headerView: UIView!
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet fileprivate weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var avatarImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    @IBOutlet private weak var bioLabel: UILabel!
    
    @IBOutlet fileprivate weak var bioContainerHeightConstraint: NSLayoutConstraint!
    
    fileprivate var headerHeight: CGFloat = 0.0
    fileprivate var bioHeight: CGFloat = UIFont.systemFont(ofSize: 22.0).lineHeight
    
    fileprivate lazy var blurEffect = UIBlurEffect(style: .light)
    
    @IBOutlet fileprivate weak var blurEffectView: UIVisualEffectView! {
        didSet {
            blurEffectView.effect = blurEffect
        }
    }
    
    fileprivate struct Constant {
        static let gap: CGFloat = 4.0
        static let numberOfRow = 4
        static let ratio: CGFloat = 3 / 4
        static let matterRowHeight: CGFloat = 64.0
    }
    
    private enum Channel: Int {
        case storybook = 0
        case matter
    }
    
    private var channel: Channel = .matter {
        willSet {
    
            guard newValue != channel else { return }
            
            // 这里或许需要手动调整 headerView 的高度，因为虽然使得 scrollView.scrollToTop() 了，但是不一定会调用 scrollViewDidScroll(_:) 方法。
            // 即 headerView 不一定会跟随 contentOffset.y 来调整高度，所以可能会出现空白。
            switch newValue {
            case .storybook:
                
                storybookCollectionView.isHidden = false
                matterTableView.isHidden = true
                
                //matterTableView.hi.forceStop()
                //storybookCollectionView.hi.scrollToTop(animated: false)
                
                // 为了提供更好的用户体验，切换 channel 后，不进行 headerView 高度的改变。
                // 而是保持之前的状态，所以只需要调整 contentOffset 即可。
                let contentOffsetY = matterTableView.contentOffset.y
                storybookCollectionView.contentOffset.y = min(contentOffsetY, -minimumHeaderHeight)
            case .matter:
                
                matterTableView.isHidden = false
                storybookCollectionView.isHidden = true
                
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
    
    // Matters
    
    private let dataSource = RxTableViewSectionedReloadDataSource<MattersViewSection>()
    private var mattersViewModel: MattersViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "__b233"
        
        navigationItem.rightBarButtonItem = settingsItem
        
        segmentedControl.rx.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                self?.channel = Channel(rawValue: index)!
            })
            .addDisposableTo(disposeBag)
        
        if let flowLayout = storybookCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = Constant.gap
            flowLayout.minimumInteritemSpacing = Constant.gap
            let inset = Constant.gap / 2.0
            flowLayout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset + Defaults.tabBarHeight, right:  inset)
        }
        
        headerViewHeightConstraint.constant = maximumHeaderHeight
        bioContainerHeightConstraint.constant = bioHeight
        
        settingsItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.tryToShowSettings()
            })
            .addDisposableTo(disposeBag)
        
        guard let realm = try? Realm() else { return }
        
        let viewModel = MattersViewModel(realm: realm)
        
        dataSource.configureCell = { _, tableView, indexPath, viewModel in
            let cell: MatterCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withPresenter: viewModel)
            return cell
        }
        
        viewModel.sections
            .drive(matterTableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        matterTableView.rx.itemSelected
            .bindTo(viewModel.itemDidSelect)
            .addDisposableTo(disposeBag)
        
    }
    
    fileprivate func tryToShowSettings() {
        performSegue(withIdentifier: .showEditProfile, sender: nil)
    }
}



// MARK: - UICollectionViewDataSource

extension ProfileViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: StorybookCell = collectionView.hi.dequeueReusableCell(for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? StorybookCell, storybook = storybooks?[safe: indexPath.item] else { return }
        
        //let storybookCellModel = StorybookCellModel(storybook: storybook)
        //cell.configure(withPresenter: storybookCellModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.bounds.width
        
        let itemWidth = (collectionViewWidth - Constant.gap - CGFloat((Constant.numberOfRow - 1)) * Constant.gap) / CGFloat(Constant.numberOfRow)
        
        return CGSize(width: itemWidth, height: itemWidth / Constant.ratio)
    }
}

// MARK: - UIScrollViewDelegate

extension ProfileViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        
        headerHeight = max(min(-(offsetY), maximumHeaderHeight), minimumHeaderHeight) // 220 ~ 332
        
        updateHeaderViewConstraints()
    }
    
    func updateHeaderViewConstraints(animated animate: Bool = false) {
        
        headerViewHeightConstraint.constant = headerHeight
        
        avatarImageViewWidthConstraint.constant = (headerHeight / maximumHeaderHeight) * maximumAvatarWidth
        
        bioContainerHeightConstraint.constant = bioHeight * ((headerHeight - minimumHeaderHeight) / (maximumHeaderHeight - minimumHeaderHeight))
        
        if animate {
            UIView.animate(withDuration: 0.35, delay: 0.0, options: [.curveLinear], animations: {
                self.headerView.layoutIfNeeded()
                self.avatarImageView.layoutIfNeeded()
            }, completion: nil)
        } else {
            headerView.layoutIfNeeded()
            avatarImageView.layoutIfNeeded()
        }
    }
}

extension ProfileViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case edit
        case showQRCode
        case showEditProfile
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segueIdentifier(forSegue: segue) {
        case .edit:
            print("edit")
        case .showQRCode:
            break
        case .showEditProfile:
            break
        }
    }
}
