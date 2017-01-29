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
    @IBOutlet private weak var newItem: UIBarButtonItem!
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
                
            case .matter:
                
                matterTableView.isHidden = false
                storybookCollectionView.isHidden = true
                
                //storybookCollectionView.hi.forceStop()
                //matterTableView.hi.scrollToTop(animated: false)
                
                // 同上
                let contentOffsetY = storybookCollectionView.contentOffset.y
                matterTableView.contentOffset.y = min(contentOffsetY, -minimumHeaderHeight)
            }
            
            newItem.title = "New \(newValue.name)"
            //headerHeight = maximumHeaderHeight
            //updateHeaderViewConstraints(animated: true)
        }
    }
    
    private lazy var settingsItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(named: "nav_settings")
        return item
    }()
    
    fileprivate var storybooks: [Storybook] = []
    
    // Matters
    
    private let dataSource = RxTableViewSectionedReloadDataSource<MattersViewSection>()
    private var mattersViewModel: MattersViewModel?
    
    private struct Listener {
        static let avatar = "Profile.avatar"
        static let nickname = "Profile.nickname"
        static let bio = "Profile.bio"
    }
    
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
                .flatMap(tryToAddNewStorybook)
                .subscribe(onNext: { name in
                    
                    realmQueue.async {
                        
                        guard let realm = try? Realm() else { return }
                        
                        let book = Storybook()
                        book.name = name
                        book.creator = User.current
                        
                        try? realm.write {
                            realm.add(book, update: true)
                        }
                    }
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
            flowLayout.sectionInset = UIEdgeInsets(top: inset, left: Constant.padding, bottom: inset + Defaults.tabBarHeight, right: Constant.padding)
        }
        
        headerViewHeightConstraint.constant = maximumHeaderHeight
        bioContainerHeightConstraint.constant = bioHeight
        
        guard let realm = try? Realm() else { return }
        
        // datasource
       
        let predicate = NSPredicate(format: "creator.id = %@", viewModel.user.id)
        
        storybooks = StorybookService.shared.fetchAll(withPredicate: predicate, fromRealm: realm)
        
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
       
        if let viewModel = viewModel, viewModel.isGod {
            
            self.toolbarBottomConstraint.constant = 0.0
            
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        if let viewModel = viewModel, viewModel.isGod {
            
            self.toolbarBottomConstraint.constant = -Constant.bottomToolbarHeight
            
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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

extension ProfileViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case edit
        case showEditProfile
        case showMatter
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
        }
    }
}
