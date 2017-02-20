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
            storybookCollectionView.alwaysBounceVertical = true
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
    @IBOutlet private weak var editItem: UIBarButtonItem! // left item
    @IBOutlet private weak var newItem: UIBarButtonItem! // right item
    @IBOutlet private weak var toolbar: UIToolbar!
    
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    fileprivate struct Constant {
        static let gap: CGFloat = 24.0
        static let padding: CGFloat = 32.0
        static let numberOfRow = 2
        static let ratio: CGFloat = 6 / 9
        static let matterRowHeight: CGFloat = 64.0
        static let avatarSize = CGSize(width: 120.0, height: 120.0)
        static let bottomToolbarHeight: CGFloat = 44.0
    }
    
    private enum Channel: Int {
        case storybook = 0
        case matter
        
        var name: String {
            switch self {
            case .matter: return "Matter"
            case .storybook: return "Storybook"
            }
        }
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
                
                editItem.title = isEditingStorybook ? "Done" : "Edit"
                newItem.title = "New"
               
            case .matter:
                
                matterTableView.isHidden = false
                storybookCollectionView.isHidden = true
                
                //storybookCollectionView.hi.forceStop()
                //matterTableView.hi.scrollToTop(animated: false)
                
                // 同上
                let contentOffsetY = storybookCollectionView.contentOffset.y
                matterTableView.contentOffset.y = min(contentOffsetY, -minimumHeaderHeight)
                
                editItem.title = nil
                newItem.title = nil
            }
            
            showsBottomBarIfIsGod(newValue == .storybook)
            
            //headerHeight = maximumHeaderHeight
            //updateHeaderViewConstraints(animated: true)
        }
    }
    
    private lazy var settingsItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(named: "nav_settings")
        return item
    }()
    
    private var viewDidAppear: Bool = false
    fileprivate var isEditingStorybook: Bool = false
    
    fileprivate var storybooks: [Storybook] = []
    
    // Matters
    
    private let dataSource = RxTableViewSectionedReloadDataSource<MattersViewSection>()
    private var mattersViewModel: MattersViewModel?
    
    private struct Listener {
        static let avatar = "Profile.avatar"
        static let nickname = "Profile.nickname"
        static let bio = "Profile.bio"
    }
    
    fileprivate var realm: Realm!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let viewModel = viewModel else { return }
    
        // Configure profile
       
        if viewModel.isGod {
            navigationItem.rightBarButtonItem = settingsItem
           
            HiUserDefaults.nickname.bindAndFireListener(with: Listener.nickname) { [weak self] (nickname) in
                self?.navigationItem.title = nickname
            }
            
            HiUserDefaults.bio.bindAndFireListener(with: Listener.bio) { [weak self] (bio) in
                self?.bioLabel.text = bio
            }
            
            HiUserDefaults.avatar.bindAndFireListener(with: Listener.avatar) { [weak self] avatarURLString in
                self?.avatarImageView.setImage(with: avatarURLString.flatMap { URL(string: $0) }, placeholder: UIImage.hi.roundedAvatar(radius: Constant.avatarSize.width / 2), transformer: .rounded(Constant.avatarSize))
            }
        
            settingsItem.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.tryToShowEditProfile()
                })
                .addDisposableTo(disposeBag)
            
            newItem.rx.tap
                .filter { [unowned self] in self.channel == .storybook }
                .flatMap(tryToAddNewStorybook)
                .subscribe(onNext: { [weak self] name in
                    
                    guard let realm = self?.realm else { return }
                    
                    let book = Storybook()
                    book.name = name
                    book.creator = User.current
                    
                    try? realm.write {
                        realm.add(book, update: true)
                    }
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.updateStorybooks()
                        self?.storybookCollectionView.reloadData()
                    }
                })
                .addDisposableTo(disposeBag)
            
            editItem.rx.tap
                .subscribe(onNext: { [weak self] in
                    guard let sSelf = self else { return }
                    if sSelf.isEditingStorybook {
                        // Done
                        sSelf.isEditingStorybook = false
                        sSelf.editItem.title = "Edit"
                        sSelf.editItem.style = .plain
                    } else {
                        sSelf.isEditingStorybook = true
                        sSelf.editItem.title = "Done"
                        sSelf.editItem.style = .done
                    }
                    
                    sSelf.storybookCollectionView.reloadData()
                })
                .addDisposableTo(disposeBag)
            
        } else {
            navigationItem.title = viewModel.user.nickname
            bioLabel.text = viewModel.user.bio
            avatarImageView.setImage(with: URL(string: viewModel.user.avatarURLString), placeholder: UIImage.hi.roundedAvatar(radius: Constant.avatarSize.width / 2), transformer: .rounded(Constant.avatarSize))
        }
        
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
            flowLayout.sectionInset = UIEdgeInsets(top: Constant.gap, left: Constant.padding, bottom: inset + Defaults.tabBarHeight, right: Constant.padding)
        }
        
        headerViewHeightConstraint.constant = maximumHeaderHeight
        bioContainerHeightConstraint.constant = bioHeight
        
        guard let realm = try? Realm() else { return }
        self.realm = realm
        
        // datasource
        
        updateStorybooks()
        
        let mattersViewModel = MattersViewModel(with: viewModel.user.id, realm: realm)
        
        dataSource.configureCell = { _, tableView, indexPath, viewModel in
            let cell: MatterCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withPresenter: viewModel)
            return cell
        }
        
        mattersViewModel.sections
            .drive(matterTableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        matterTableView.rx.itemSelected
            .bindTo(mattersViewModel.itemDidSelect)
            .addDisposableTo(disposeBag)
        
        mattersViewModel.itemDidDeselect
            .drive(onNext: { [weak self] indexPath in
                self?.matterTableView.deselectRow(at: indexPath, animated: true)
            })
            .addDisposableTo(disposeBag)
        
        mattersViewModel.showMatterViewModel
            .drive(onNext: { [weak self] viewModel in
                self?.performSegue(withIdentifier: .showMatter, sender: Wrapper<MatterViewModel>(bullet: viewModel))
            })
            .addDisposableTo(disposeBag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        viewDidAppear = true
        showsBottomBarIfIsGod(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        showsBottomBarIfIsGod(false)
    }
    
    private func showsBottomBarIfIsGod(_ show: Bool, animated: Bool = true) {
        guard let viewModel = viewModel, viewModel.isGod, viewDidAppear else {
            return
        }

        toolbarBottomConstraint.constant = show ? 0 : -Constant.bottomToolbarHeight
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }
    
    fileprivate func updateStorybooks() {
        guard let viewModel = viewModel else { return }
        
        let predicate = NSPredicate(format: "creator.id = %@", viewModel.user.id)
        storybooks = StorybookService.shared.fetchAll(withPredicate: predicate, fromRealm: realm)
    }
    
    fileprivate func reloadStorybooks() {
        SafeDispatch.async { [weak self] in
            self?.storybookCollectionView.reloadData()
        }
    }
    
    private func tryToAddNew(isStorybook: Bool) -> Observable<String> {
        if isStorybook {
            return tryToAddNewStorybook()
        } else {
            return Observable.empty()
        }
    }
    
    private func tryToAddNewStorybook() -> Observable<String> {
        
        return Observable.create { [weak self] observer -> Disposable in
            
            let alertController = UIAlertController(title: "New Storybook", message: "Enter a name for this storybook.", preferredStyle: .alert)
            
            var disposable: Disposable?
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
                
                if let name = alertController.textFields?.first?.text {
                    observer.onNext(name)
                    observer.onCompleted()
                }
                
                disposable?.dispose()
            }
            
            alertController.addTextField { (textField) in
                textField.placeholder = "Name"
                textField.clearsOnBeginEditing = true
                
                disposable = textField.rx.text.orEmpty
                    .map { !$0.isEmpty }
                    .debug()
                    .bindTo(saveAction.rx.isEnabled)
            }
            
            let cancelAction = UIAlertAction(title: "Canecl", style: .cancel) { (action) in
                disposable?.dispose()
                observer.onCompleted()
            }
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self?.present(alertController, animated: true, completion: nil)
            
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func tryToShowEditProfile() {
        performSegue(withIdentifier: .showEditProfile, sender: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension ProfileViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storybooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: StorybookCell = collectionView.hi.dequeueReusableCell(for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? StorybookCell, let storybook = storybooks.safe[indexPath.item] else { return }
        
        let storybookCellModel = StorybookCellModel(storybook: storybook)
        cell.configure(withPresenter: storybookCellModel)
        cell.isEditing = isEditingStorybook && storybook.name != Defaults.storybookName
        
        cell.deleteAction = { [weak self] in
            // alert
            let alertController = UIAlertController(title: "Delete “\(storybook.name)”", message: "Are you sure you want to delete the storybook ”\(storybook.name)“? The storys will be deleted.", preferredStyle: .actionSheet)
           
            let deleteAction = UIAlertAction(title: "Delete Storybook", style: .destructive, handler: { (action) in
                print("delete")
                
                guard let realm = self?.realm else { return }
                
                SafeDispatch.async { [weak self] in
                    
                    if let index = self?.storybooks.index(where: { $0.id == storybook.id }) {
                        StorybookService.shared.remove(storybook, fromRealm: realm)
                        assert(index == indexPath.item, "Index of storybook not equal to indexPath.item")
                        self?.storybooks.remove(at: index)
                        self?.reloadStorybooks()
                    }
                }
            })
            alertController.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let storybook = storybooks.safe[indexPath.item] else { return }
        
        performSegue(withIdentifier: .showStories, sender: storybook)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.bounds.width
        
        let itemWidth = (collectionViewWidth - Constant.padding * 2 - CGFloat((Constant.numberOfRow - 1)) * Constant.gap) / CGFloat(Constant.numberOfRow)
        
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

extension ProfileViewController: StoriesViewControllerDelegate {
    
    func viewController(_ viewController: StoriesViewController, didDelete story: Story, at index: Int) {
        
        let predicate = NSPredicate(format: "story.id = %@", story.id)
        if let feed = FeedService.shared.fetch(withPredicate: predicate, fromRealm: realm) {
            Feed.didDelete.onNext(feed)
            
            // 如果没有 Obverser，需要删除 feed，否则应该在 obserser 那里删除
            if !Feed.didCreate.hasObservers {
                FeedService.shared.remove(feed, fromRealm: realm)
            }
        }
        
        StoryService.shared.remove(story, fromRealm: realm)
       
        // 需要刷新一下封面
        updateStorybooks()
        reloadStorybooks()
        
        /*
        if story.attachment != nil, storybooks[index].latestPicturedStory?.id == story.id {
            updateStorybooks()
            reloadStorybooks()
        } else {
            reloadStorybooks()
        }*/
    }
    
    func canEditViewController(_ viewController: StoriesViewController) -> Bool {
        return viewModel?.isGod ?? false
    }
}

extension ProfileViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case edit
        case showEditProfile
        case showMatter
        case showStories
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segueIdentifier(forSegue: segue) {
        case .edit:
            print("edit")
        case .showMatter:
            let viewController = segue.destination as? MatterViewController
            
            if let wrapper = sender as? Wrapper<MatterViewModel> {
                viewController?.viewModel = wrapper.candy
            }
        case .showEditProfile:
            break
        case .showStories:
            
            let vc = segue.destination as? StoriesViewController
            if let storybook = sender as? Storybook, !storybook.stories.isEmpty {
                vc?.stories = Array(storybook.stories)
            }
            
            vc?.delegate = self
        }
    }
}
