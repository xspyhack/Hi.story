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
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.hi.registerReusableCell(MatterCell)
        }
    }
    
    @IBOutlet private weak var addItem: UIBarButtonItem!
    
    private let dataSource = RxTableViewSectionedReloadDataSource<MattersViewSection>()
    
    private var viewModel: MattersViewModel?
    
    lazy var presentationTransition: PresentationTransitionManager = {
        let manager = PresentationTransitionManager()
        manager.presentedViewHeight = self.view.bounds.height
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Matters"
        
        guard let realm = try? Realm() else { return }
        
        let viewModel = MattersViewModel(realm: realm)
        
        dataSource.configureCell = { _, tableView, indexPath, viewModel in
            let cell: MatterCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withPresenter: viewModel)
            return cell
        }
        
        addItem.rx_tap
            .bindTo(viewModel.addAction)
            .addDisposableTo(disposeBag)
        
        viewModel.sections
            .drive(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        viewModel.showNewMatterViewModel
            .driveNext { [weak self] viewModel in
                self?.performSegue(withIdentifier: .PresentNewMatter, sender: Wrapper<NewMatterViewModel>(bullet: viewModel))
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx_itemDeleted
            .bindTo(viewModel.itemDeleted)
            .addDisposableTo(disposeBag)
        
        tableView.rx_itemSelected
            .bindTo(viewModel.itemDidSelect)
            .addDisposableTo(disposeBag)
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource.sectionAtIndex(index)
            return section.model
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        show()
    }
    
    private func show() {
        
        let viewController = PopoverViewController()
        viewController.tips = "Look at me!"
        
        viewController.modalPresentationStyle = .Popover
        viewController.popoverPresentationController?.barButtonItem = addItem
        viewController.popoverPresentationController?.delegate = self

        presentViewController(viewController, animated: true, completion: nil)
    }
}

extension MattersViewController: PresentationRepresentation {
}

extension MattersViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case PresentNewMatter
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segueIdentifier(forSegue: segue) {
        case .PresentNewMatter:
            let viewController = segue.destinationViewController as? NewMatterViewController
            
            viewController?.modalPresentationStyle = .Custom
            viewController?.transitioningDelegate = presentationTransition
            
            if let wrapper = sender as? Wrapper<NewMatterViewModel> {
                viewController?.viewModel = wrapper.candy
            }
        }
    }
}

extension MattersViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
    }
}
