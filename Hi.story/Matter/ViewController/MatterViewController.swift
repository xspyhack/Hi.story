//
//  MatterViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxSwift
import RxCocoa
import RxDataSources
import RealmSwift

final class MatterViewController: BaseViewController {
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.hi.registerReusableCell(MatterCell)
        }
    }
    
    private let dataSource = RxTableViewSectionedReloadDataSource<MatterViewSection>()
    
    var viewModel: MatterViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let realm = try? Realm() else { return }
        
        let viewModel = MatterViewModel(realm: realm)
        
        dataSource.configureCell = { _, tableView, indexPath, viewModel in
            let cell: MatterCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.configure(withPresenter: viewModel)
            return cell
        }
    
        viewModel.sections
            .drive(tableView.rx_itemsWithDataSource(dataSource))
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

}
