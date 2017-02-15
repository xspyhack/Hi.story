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
            tableView.rowHeight = Constant.rowHeight
            tableView.estimatedRowHeight = Constant.rowHeight
            tableView.tableFooterView = UIView()
        }
    }
    
    fileprivate lazy var presentationTransitionManager: PresentationTransitionManager = {
        let manager = PresentationTransitionManager()
        manager.presentedViewHeight = self.view.bounds.height
        return manager
    }()

    private let dataSource = RxTableViewSectionedReloadDataSource<DraftsViewSection>()
    
    fileprivate var viewModel: DraftsViewModel? // Reference it!!
    
    private struct Constant {
        static let rowHeight: CGFloat = 120.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Drafts"
        
        guard let realm = try? Realm() else { return }
        
        let viewModel = DraftsViewModel(realm: realm)
        self.viewModel = viewModel
       
        dataSource.configureCell = { _, tableView, indexPath, viewModel in
            let cell: DraftCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withPresenter: viewModel)
            return cell
        }
        
        viewModel.sections
            .drive(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        viewModel.editDraft
            .drive(onNext: { [weak self] viewModel in
                self?.performSegue(withIdentifier: .presentNewFeed, sender: viewModel)
            })
            .addDisposableTo(disposeBag)
       
        tableView.rx.itemDeleted
            .bindTo(viewModel.itemDeleted)
            .addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected
            .bindTo(viewModel.itemDidSelect)
            .addDisposableTo(disposeBag)
        
        tableView.rx.enablesAutoDeselect()
            .addDisposableTo(disposeBag)
        
        dataSource.canEditRowAtIndexPath = { _ in
            return true
        }
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
