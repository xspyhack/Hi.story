//
//  FeedsViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import Hiroute
import RxCocoa
import RxSwift
import RealmSwift

final class FeedsViewController: BaseViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.showsVerticalScrollIndicator = false
            collectionView.hi.register(reusableCell: FeedCell.self)
            collectionView.hi.register(reusableCell: FeedImageCell.self)
            collectionView.hi.registerReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, viewType: FeedSectionHeaderView.self)
        }
    }
    
    private lazy var presentationTransitionManager: PresentationTransitionManager = {
        let manager = PresentationTransitionManager()
        manager.presentedViewHeight = self.view.bounds.height
        return manager
    }()
    
    private struct Constant {
        static let topInset: CGFloat = 12.0
        static let headerHeight: CGFloat = 48.0
    }
    
    private var feeds: [Feed] = []
    
    private lazy var newItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(named: "nav_new")
        return item
    }()
    
    private var viewModel: FeedsViewModel? // Reference it!!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = newItem
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        guard let realm = try? Realm() else { return }
       
        Feed.didCreate
            .subscribe(onNext: { [weak self] feed in
                guard let sSelf = self else { return }
                
                sSelf.feeds.insert(feed, at: 0)
                
                if sSelf.feeds.count == 1 {
                    sSelf.collectionView.reloadData()
                } else {
                    sSelf.collectionView.insertSections([0])
                }
                FeedService.shared.synchronize(feed, toRealm: realm)
                
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                generator.impactOccurred()
            })
            .disposed(by: disposeBag)
        
        
        Feed.didDelete
            .subscribe(onNext: { [weak self] feed in
                print("Feed did delete")
                
                guard let sSelf = self else { return }
                if let index = sSelf.feeds.index(where: { feed.id == $0.id }) {
                    sSelf.feeds.remove(at: index)
                    
                    if sSelf.feeds.count == 0 {
                        sSelf.collectionView.reloadData()
                    } else {
                        sSelf.collectionView.deleteSections([index])
                    }
                    FeedService.shared.remove(feed, fromRealm: realm)
                }
            })
            .disposed(by: disposeBag)
        
        feeds = FeedService.shared.fetchAll(sortby: "createdAt", fromRealm: realm)
        
        newItem.rx.tap
            .subscribe(onNext: {
                Router.route(URL(string: "hi://feed/new/")!)
            })
            .disposed(by: disposeBag)
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: collectionView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        // TODO: - Dispose
    }
    
    private func fetchFeeds() {
        
        guard let realm = try? Realm() else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        
        feeds = FeedService.shared.fetchAll(sortby: "createdAt", fromRealm: realm)
       
        SafeDispatch.async { [weak self] in
            self?.collectionView.reloadData()
            
            generator.impactOccurred()
        }
    }
    
    func tryToCreateNewFeed() {
        performSegue(withIdentifier: .presentNewFeed, sender: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension FeedsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return feeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let feed = feeds.safe[indexPath.section] else { return UICollectionViewCell() }
        
        if feed.story?.attachment != nil {
            let cell: FeedImageCell = collectionView.hi.dequeueReusableCell(for: indexPath)
            return cell
        } else {
            let cell: FeedCell = collectionView.hi.dequeueReusableCell(for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view: FeedSectionHeaderView = collectionView.hi.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
        view.backgroundColor = UIColor.white
        view.didSelect = { [weak self] in
            guard let feed = self?.feeds.safe[indexPath.item] else { return }
            self?.performSegue(withIdentifier: .showProfile, sender: feed.creator)
        }
        return view
    }
}

// MARK: - UICollectionViewDelegate

extension FeedsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let story = feeds.safe[indexPath.section]?.story else { return }
        
        if story.attachment != nil {
            guard let cell = cell as? FeedImageCell else { return }
            let viewModel = FeedImageCellModel(story: story)
            cell.configure(withPresenter: viewModel)
        } else {
            guard let cell = cell as? FeedCell else { return }
            let viewModel = FeedCellModel(story: story)
            cell.configure(withPresenter: viewModel)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let view = view as? FeedSectionHeaderView, let user = feeds.safe[indexPath.section]?.creator else { return }
        
        let viewModel = FeedSectionHeaderViewModel(user: user)
        view.configure(withPresenter: viewModel)
        view.didSelect = { [weak self] () -> Void in
            self?.performSegue(withIdentifier: .showProfile, sender: user)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let feed = feeds.safe[indexPath.section] else { return }
        
        performSegue(withIdentifier: .showFeed, sender: feed)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let feed = feeds.safe[indexPath.section] else { return CGSize.zero }
        
        let width = collectionView.bounds.width
        let height = FeedCell.height(with: feed, width: width)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constant.headerHeight)
    }
}

extension FeedsViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    
        // cell
        if let indexPath = collectionView.indexPathForItem(at: location), let cell = collectionView.cellForItem(at: indexPath) {
            previewingContext.sourceRect = cell.frame
            let vc = Storyboard.feed.viewController(of: FeedViewController.self)
            vc.viewModel = feeds.safe[indexPath.section].map { FeedViewModel(feed: $0) }
            return vc
        }
        
        // header
        let cellLocation = CGPoint(x: location.x, y: location.y + Constant.headerHeight)
        if let indexPath = collectionView.indexPathForItem(at: cellLocation), let headerView = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) {
            previewingContext.sourceRect = headerView.frame
            let vc = Storyboard.profile.viewController(of: ProfileViewController.self)
            vc.viewModel = feeds.safe[indexPath.section]?.creator.map { ProfileViewModel(user: $0) }
            return vc
        }
        
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
    }
}

// MARK: - SegueHandlerType

extension FeedsViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case presentNewFeed
        case showProfile
        case showFeed
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segueIdentifier(forSegue: segue) {
        case .presentNewFeed:
            let viewController = segue.destination as! NewFeedViewController
            
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = presentationTransitionManager
            
            if let viewModel = sender as? NewFeedViewModel {
                viewController.viewModel = viewModel
            }
        case .showProfile:
            let vc = segue.destination as? ProfileViewController
            vc?.viewModel = (sender as? User).flatMap { ProfileViewModel(user: $0) }
        case .showFeed:
            let vc = segue.destination as! FeedViewController
            if let feed = sender as? Feed {
                vc.viewModel = FeedViewModel(feed: feed)
            }
        }
    }
}

extension FeedsViewController: Refreshable {
    
    var isAtTop: Bool {
        return self.collectionView.hi.isAtTop
    }
    
    func refresh() {
        fetchFeeds()
    }
    
    func scrollsToTopIfNeeded() {
        
        if !isAtTop {
            collectionView.hi.scrollsToTop(animated: true)
        }
    }
}

