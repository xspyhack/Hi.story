//
//  FeedViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import WebKit
import Hikit
import RxSwift
import RxCocoa

final class FeedViewController: BaseViewController {
    
    var viewModel: FeedViewModelType?
    
    private lazy var detailsItem: UIBarButtonItem = UIBarButtonItem()
    
    private var popoverTransitioningDelegate: PopoverTransitioningDelegate?
    
    private var hybridViewController: HybridViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsItem.image = UIImage.hi.navDetails
        navigationItem.rightBarButtonItem = detailsItem
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
        detailsItem.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.showsDetails()
            })
            .disposed(by: disposeBag)
        
        guard let viewModel = viewModel else {
            return
        }
        
        let vc = HybridViewController(urlScheme: "hybrid")
        /*
        vc.rx.observeWeakly(String.self, #keyPath(HybridViewController.webTitle))
            .skip(1)
            .subscribe(onNext: { [weak self] title in
                self?.title = title
            })
            .disposed(by: disposeBag)
        */
        vc.changedTitle = { [weak self] title in
            self?.title = title
        }
        
        addChildViewController(vc)
        view.addSubview(vc.view)
        NSLayoutConstraint.activate(vc.view.hi.edges())
        vc.didMove(toParentViewController: self)
        vc.load(viewModel.toHTML(), baseURL: Bundle.main.bundleURL)
        
        hybridViewController = vc
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showsDetails() {
        guard let viewModel = viewModel, let story = viewModel.feed.story, let hybridViewController = hybridViewController else { return }
        
        let viewController = Storyboard.details.viewController(of: DetailsViewController.self)
        viewController.viewModel = DetailsViewModel(story: story)
        
        viewController.showsLocationAction = { [weak self] location in
            self?.hi.open(location)
        }
        
        viewController.modalPresentationStyle = .custom
        viewController.modalTransitionStyle = .crossDissolve
        
        let size: CGSize
        if story.location != nil {
            size = CGSize(width: view.bounds.width - 70.0, height: 300.0)
        } else {
            size = CGSize(width: view.bounds.width - 80.0, height: 250.0)
        }
        
        let shadowAlpha: CGFloat = (hybridViewController.webView.scrollView.contentOffset.y > (view.bounds.height / 2.0) || story.attachment == nil) ? 0.3 : 0.4

        let shadow = PopoverPresentationShadow(radius: 32.0, color: UIColor.black.withAlphaComponent(shadowAlpha))
        let context = PopoverPresentationContext(presentedContentSize: size, cornerRadius: 16.0, chromeAlpha: 0.0, shadow: shadow)
        self.popoverTransitioningDelegate = PopoverTransitioningDelegate(presentationContext: context)

        viewController.transitioningDelegate = popoverTransitioningDelegate
        
        self.present(viewController, animated: true, completion: nil)
    }
}
