//
//  MattersViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/10/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxSwift
import RxCocoa
import RxDataSources
import RealmSwift

final class MattersViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView! {
        didSet {
            tableView.hi.register(reusableCell: MatterCell.self)
        }
    }
    
    @IBOutlet fileprivate weak var addItem: UIBarButtonItem!
    
    fileprivate let dataSource = RxTableViewSectionedReloadDataSource<MattersViewSection>()
    
    fileprivate var viewModel: MattersViewModel? // Reference it!!
    
    lazy var presentationTransition: PresentationTransitionManager = {
        let manager = PresentationTransitionManager()
        manager.presentedViewHeight = self.view.bounds.height
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Matters"
        
        self.registerForPreviewing(with: self, sourceView: tableView)
        
        guard let realm = try? Realm() else { return }
        
        let viewModel = MattersViewModel(realm: realm)
        
        self.viewModel = viewModel
        
        dataSource.configureCell = { _, tableView, indexPath, viewModel in
            let cell: MatterCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withPresenter: viewModel)
            return cell
        }
        
        addItem.rx.tap
            .bindTo(viewModel.addAction)
            .addDisposableTo(disposeBag)
        
        viewModel.sections
            .drive(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        viewModel.showMatterViewModel
            .drive(onNext: { [weak self] viewModel in
                self?.performSegue(withIdentifier: .showMatter, sender: Wrapper<MatterViewModel>(bullet: viewModel))
            })
            .addDisposableTo(disposeBag)
        
        viewModel.showNewMatterViewModel
            .drive(onNext: { [weak self] viewModel in
                self?.performSegue(withIdentifier: .presentNewMatter, sender: Wrapper<NewMatterViewModel>(bullet: viewModel))
            })
            .addDisposableTo(disposeBag)
        
        viewModel.itemDidDeselect
            .drive(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .addDisposableTo(disposeBag)
        
        tableView.rx.itemDeleted
            .bindTo(viewModel.itemDeleted)
            .addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected
            .bindTo(viewModel.itemDidSelect)
            .addDisposableTo(disposeBag)
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource.sectionAtIndex(index)
            return section.model
        }

        dataSource.canEditRowAtIndexPath = { _ in
            return true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Defaults.isShowedNewMatterTip {
            Defaults.isShowedNewMatterTip = true
            show()
        }
    }
    
    fileprivate func show() {
        
        let viewController = PopoverViewController()
        viewController.tips = "Look at me!"
        
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.barButtonItem = addItem
        viewController.popoverPresentationController?.delegate = self

        present(viewController, animated: true, completion: nil)
    }
}

extension MattersViewController: PresentationRepresentation {
}

extension MattersViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case showMatter
        case presentNewMatter
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segueIdentifier(forSegue: segue) {
        case .showMatter:
            let viewController = segue.destination as? MatterViewController
            
            if let wrapper = sender as? Wrapper<MatterViewModel> {
                viewController?.viewModel = wrapper.candy
            }
        case .presentNewMatter:
            let viewController = segue.destination as? NewMatterViewController
            
            viewController?.modalPresentationStyle = .custom
            viewController?.transitioningDelegate = presentationTransition
            
            if let wrapper = sender as? Wrapper<NewMatterViewModel> {
                viewController?.viewModel = wrapper.candy
            }
        }
    }
}

extension MattersViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        
        let viewController = UIStoryboard.hi.storyboard(.matter).instantiateViewController(withIdentifier: MatterViewController.identifier)
        guard let matterViewController = viewController as? MatterViewController else { return nil }
        
        guard let matter = viewModel?.matters.value[safe: indexPath.row] else { return nil }
        matterViewController.viewModel = MatterViewModel(matter: matter)
        let cellRect = tableView.rectForRow(at: indexPath)
        previewingContext.sourceRect = previewingContext.sourceView.convert(cellRect, from: tableView)

        return matterViewController
    }
}

extension MattersViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
