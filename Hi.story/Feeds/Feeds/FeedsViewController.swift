//
//  FeedsViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxCocoa
import RxSwift
import RealmSwift

final class FeedsViewController: BaseViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.hi.register(reusableCell: FeedCell.self)
            collectionView.hi.register(reusableCell: FeedImageCell.self)
            collectionView.hi.registerReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, viewType: FeedSectionHeaderView.self)
        }
    }
    
    fileprivate lazy var presentationTransitionManager: PresentationTransitionManager = {
        let manager = PresentationTransitionManager()
        manager.presentedViewHeight = self.view.bounds.height
        return manager
    }()
    
    fileprivate struct Constant {
        static let topInset: CGFloat = 12.0
        static let headerHeight: CGFloat = 48.0
    }
    
    fileprivate var feeds: [Feed] = []
    
    private lazy var newItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(named: "nav_new")
        return item
    }()
    
    private lazy var collectionsItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(named: "nav_new")
        return item
    }()
    
    private var viewModel: FeedsViewModel? // Reference it!!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = newItem
        
        navigationItem.leftBarButtonItem = collectionsItem
        
        collectionsItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.performSegue(withIdentifier: .showCollections, sender: nil)
            })
            .addDisposableTo(disposeBag)
        
        guard let realm = try? Realm() else { return }
        
        let viewModel = FeedsViewModel(realm: realm)
        
        feeds = FeedService.shared.fetchAll(fromRealm: realm)
        
        self.viewModel = viewModel
        
        newItem.rx.tap
            .bindTo(viewModel.addAction)
            .addDisposableTo(disposeBag)
        
        viewModel.showNewFeedViewModel
            .drive(onNext: { [weak self] viewModel in
                self?.performSegue(withIdentifier: .presentNewFeed, sender: viewModel)
            })
            .addDisposableTo(disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tryToAddNewFeed() {
        performSegue(withIdentifier: .presentNewFeed, sender: nil)
    }
    
    fileprivate func handleNewFeeds(_ feeds: [Feed]) {
        DispatchQueue.main.async { 
            print(feeds)
        }
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
        
        guard let feed = feeds[safe: indexPath.section] else { return UICollectionViewCell() }
        
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
        guard let story = feeds[safe: indexPath.section]?.story else { return }
        
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
        guard let view = view as? FeedSectionHeaderView, let user = feeds[safe: indexPath.section]?.creator else { return }
        
        let viewModel = FeedSectionHeaderViewModel(user: user)
        view.configure(withPresenter: viewModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let story = feeds[safe: indexPath.section]?.story else { return CGSize.zero }
        
        let width = collectionView.bounds.width
        let titleHeight = story.title.height(with: width - FeedCell.margin * 2, fontSize: 24.0)
        let contentHeight = story.body.height(with: width - FeedCell.margin * 2, fontSize: 14.0)
        
        let height = 12.0 + titleHeight + 16.0 + min(contentHeight, 68.0) + 32.0
        
        if story.attachment != nil {
            return CGSize(width: width, height: 16.0 + height + width * 9.0 / 16.0)
        } else {
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constant.headerHeight)
    }
}

// MARK: - SegueHandlerType

extension FeedsViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case presentNewFeed
        case showCollections
        case showProfile
    }

    // MARK: - Navigation
    
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
        case .showCollections:
            break
        }
    }
}

extension String {
    
    func height(with width: CGFloat, fontSize: CGFloat) -> CGFloat {
        return ceil(self.boundingRect(with: CGSize(width: width, height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)], context: nil).height)
    }
}

