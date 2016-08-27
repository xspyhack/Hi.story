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

class FeedsViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    private lazy var presentationTransitionManager: PresentationTransitionManager = {
        let manager = PresentationTransitionManager()
        manager.presentedViewHeight = self.view.bounds.height
        return manager
    }()
    
    private var feeds: [Feed]?
    
    private lazy var newItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(named: "nav_new")
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = newItem
        
        newItem.rx_tap
            .subscribeNext { [weak self] in
                self?.tryToShowNewStory()
            }
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func tryToShowNewStory() {
        performSegue(withIdentifier: .PresentNewStory, sender: nil)
    }
    
    private func handleNewFeeds(feeds: [Feed]) {
        dispatch_async(dispatch_get_main_queue()) { 
            print(feeds)
        }
    }
    
    private func handleNewStory(story: Story) {
        
    }

}

extension FeedsViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case PresentNewStory
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segueIdentifier(forSegue: segue) {
        case .PresentNewStory:
            let viewController = segue.destinationViewController as! NewStoryViewController
            
            viewController.modalPresentationStyle = .Custom
            viewController.transitioningDelegate = presentationTransitionManager
            
            viewController.tellStoryDidSuccessAction = { [weak self](story) in
                self?.handleNewStory(story)
            }
        }
    }
}
