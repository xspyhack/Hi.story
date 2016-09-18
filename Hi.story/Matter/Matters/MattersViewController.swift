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
        
        viewModel.showNewMatterViewModel
            .drive(onNext: { [weak self] viewModel in
                print("show new")
                self?.performSegue(withIdentifier: .presentNewMatter, sender: Wrapper<NewMatterViewModel>(bullet: viewModel))
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        show()
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
        case presentNewMatter
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segueIdentifier(forSegue: segue) {
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

extension MattersViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
