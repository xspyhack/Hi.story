//
//  DraftsViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 28/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxSwift
import RxCocoa
import RxDataSources
import RealmSwift

final class DraftsViewController: BaseViewController {
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.hi.register(reusableCell: DraftCell.self)
            tableView.hi.register(reusableCell: DraftImageCell.self)
            tableView.rowHeight = Constant.rowHeight
            tableView.estimatedRowHeight = Constant.rowHeight
            tableView.tableFooterView = UIView()
        }
    }
    
    private lazy var emptyView: EmptyView = {
        let view = EmptyView(frame: .zero)
        view.backgroundColor = UIColor.white
        view.imageView.image = UIImage.hi.emptyDraft
        view.textLabel.text = "Looks like you don't have any drafts."
        return view
    }()
    
    private lazy var presentationTransitionManager: PresentationTransitionManager = {
        let context = PresentationContext(presentedContentSize: self.view.bounds.size, offset: CGPoint(x: 0, y: Defaults.statusBarHeight))
        let manager = PresentationTransitionManager(context: context)
        return manager
    }()
    
    private var viewModel: DraftsViewModel? // Reference it!!
    
    private struct Constant {
        static let rowHeight: CGFloat = 148.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Drafts"
        
        setupEmptyView()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.editButtonItem.rx.tap
            .map { [unowned self] in
                self.tableView.isEditing
            }
            .subscribe(onNext: { [weak self] editing in
                self?.isEditing = !editing
                self?.tableView.setEditing(!editing, animated: true)
            })
            .disposed(by: disposeBag)
        
        guard let realm = try? Realm() else { return }
        
        let viewModel = DraftsViewModel(realm: realm)
        self.viewModel = viewModel
       
        let dataSource = RxTableViewSectionedReloadDataSource<DraftsViewSection>(configureCell: { _, tableView, indexPath, viewModel in
            if viewModel.hasAttachment {
                let cell: DraftImageCell = tableView.hi.dequeueReusableCell(for: indexPath)
                cell.configure(withPresenter: viewModel)
                return cell
            } else {
                let cell: DraftCell = tableView.hi.dequeueReusableCell(for: indexPath)
                cell.configure(withPresenter: viewModel)
                return cell
            }
        })
        
        viewModel.sections
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.editDraft
            .drive(onNext: { [weak self] viewModel in
                self?.performSegue(withIdentifier: .presentNewFeed, sender: viewModel)
            })
            .disposed(by: disposeBag)
        
        viewModel.empty
            .map { !$0 }
            .drive(emptyView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.empty
            .map { !$0 }
            .drive(editButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)
       
        tableView.rx.itemDeleted
            .bind(to: viewModel.itemDeleted)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.itemDidSelect)
            .disposed(by: disposeBag)
        
        tableView.rx.enablesAutoDeselect()
            .disposed(by: disposeBag)
        
        dataSource.canEditRowAtIndexPath = { _, _ -> Bool in
            return true
        }
    }
    
    private func setupEmptyView() {
        emptyView.addTo(view)
    }
}

extension DraftsViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case presentNewFeed
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(forSegue: segue) {
        case .presentNewFeed:
            let viewController = segue.destination as? NewFeedViewController
            
            viewController?.modalPresentationStyle = .custom
            viewController?.transitioningDelegate = presentationTransitionManager
            
            if let viewModel = sender as? NewFeedViewModel {
                viewController?.viewModel = viewModel
            }
            
            viewController?.afterAppeared = { [weak self] in
                
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
    
                    UIView.performWithoutAnimation {
                        (self?.tabBarController as? TabBarController)?.selectedTab.value = .feeds
                        let _ = self?.navigationController?.popToRootViewController(animated: false)
                    }
                })
            }
        }
    }
}
