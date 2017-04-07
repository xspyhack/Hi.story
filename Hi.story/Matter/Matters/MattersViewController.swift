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
import WatchConnectivity

final class MattersViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView! {
        didSet {
            tableView.hi.register(reusableCell: MatterCell.self)
            tableView.rowHeight = Constant.rowHeight
            tableView.estimatedRowHeight = Constant.rowHeight
            tableView.backgroundColor = UIColor.hi.background
        }
    }
    
    @IBOutlet fileprivate weak var addItem: UIBarButtonItem!
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private let dataSource = RxTableViewSectionedReloadDataSource<MattersViewSection>()
    
    fileprivate var viewModel: MattersViewModel? // Reference it!!
    
    lazy var presentationTransition: PresentationTransitionManager = {
        let manager = PresentationTransitionManager()
        manager.presentedViewHeight = self.view.bounds.height
        return manager
    }()
    
    private struct Constant {
        static let rowHeight: CGFloat = 64.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WatchSessionService.shared.start(withDelegate: self)
        
        self.registerForPreviewing(with: self, sourceView: tableView)
        
        guard let realm = try? Realm(), let userID = HiUserDefaults.userID.value else { return }
        
        let viewModel = MattersViewModel(with: userID, realm: realm)
        
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
            let section = dataSource[index]
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
        
        if !Defaults.showedNewMatterTip {
            Defaults.showedNewMatterTip = true
            show()
        }
    }
    
    func tryToAddNewMatter() {
        
    }
    
    private func show() {
        
        let viewController = PopoverViewController()
        viewController.tips = "Counting the important matters"
        
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
        
        let viewController = Storyboard.matter.viewController(of: MatterViewController.self)
        
        guard let matter = viewModel?.matters.value.safe[indexPath.row] else { return nil }
        viewController.viewModel = MatterViewModel(matter: matter)
        let cellRect = tableView.rectForRow(at: indexPath)
        previewingContext.sourceRect = previewingContext.sourceView.convert(cellRect, from: tableView)

        return viewController
    }
}

extension MattersViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension MattersViewController: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(String(describing: error))
        Defaults.watchState.value = activationState.rawValue
    }
    
    /** ------------------------- iOS App State For Watch ------------------------ */
    
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}

enum WatchState: Int {
    case notActivated
    
    case inactive
    
    case activated
    
    case notInstalled
    
    case unpaired
    
    var name: String {
        switch self {
        case .notActivated: return "not activated"
        case .inactive: return "inactive"
        case .activated: return "activated"
        case .notInstalled: return "not installed"
        case .unpaired: return "unpaired"
        }
    }
}
