//
//  FeedsViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxCocoa
import RxSwift
import RealmSwift

final class FeedsViewController: BaseViewController {
    
    fileprivate lazy var presentationTransitionManager: PresentationTransitionManager = {
        let manager = PresentationTransitionManager()
        manager.presentedViewHeight = self.view.bounds.height
        return manager
    }()
    
    fileprivate var feeds: [Feed]?
    
    private lazy var newItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(named: "nav_new")
        return item
    }()
    
    private lazy var collectionsItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(named: "nav_new")
        return item
    }()
    
    private var viewModel: FeedsViewModel? // Reference it!!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = newItem
        
        navigationItem.leftBarButtonItem = collectionsItem
        
        collectionsItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.performSegue(withIdentifier: .showCollections, sender: nil)
            })
            .addDisposableTo(disposeBag)
        
        guard let realm = try? Realm() else { return }
        
        let viewModel = FeedsViewModel(realm: realm)
        
        self.viewModel = viewModel
        
        newItem.rx.tap
            .bindTo(viewModel.addAction)
            .addDisposableTo(disposeBag)
        
        viewModel.showNewFeedViewModel
            .drive(onNext: { [weak self] viewModel in
                self?.performSegue(withIdentifier: .presentNewFeed, sender: viewModel)
            })
            .addDisposableTo(disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tryToAddNewFeed() {
        performSegue(withIdentifier: .presentNewFeed, sender: nil)
    }
    
    fileprivate func handleNewFeeds(_ feeds: [Feed]) {
        DispatchQueue.main.async { 
            print(feeds)
        }
    }

}

extension FeedsViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case presentNewFeed
        case showCollections
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segueIdentifier(forSegue: segue) {
        case .presentNewFeed:
            let viewController = segue.destination as! NewFeedViewController
            
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = presentationTransitionManager
            
            if let viewModel = sender as? NewFeedViewModel {
                viewController.viewModel = viewModel
            }
        case .showCollections:
            break
        }
    }
}
