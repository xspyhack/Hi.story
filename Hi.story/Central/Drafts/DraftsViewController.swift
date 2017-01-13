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

final class DraftsViewController: BaseViewController {
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.hi.register(reusableCell: DraftCell.self)
            tableView.rowHeight = Constant.rowHeight
            tableView.estimatedRowHeight = Constant.rowHeight
        }
    }

    private let dataSource = RxTableViewSectionedReloadDataSource<DraftsViewSection>()
    
    fileprivate var viewModel: DraftsViewModel? // Reference it!!
    
    private struct Constant {
        static let rowHeight: CGFloat = 120.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Drafts"
        
        let viewModel = DraftsViewModel()
        self.viewModel = viewModel
       
        dataSource.configureCell = { _, tableView, indexPath, viewModel in
            let cell: DraftCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withPresenter: viewModel)
            return cell
        }
        
        viewModel.sections
            .drive(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
       
        tableView.rx.itemDeleted
            .bindTo(viewModel.itemDeleted)
            .addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected
            .bindTo(viewModel.itemDidSelect)
            .addDisposableTo(disposeBag)
        
        dataSource.canEditRowAtIndexPath = { _ in
            return true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
