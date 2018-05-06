//
//  FeedCoordinator.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/03/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Hikit
import Hiroute
import RealmSwift

struct FeedCoordinator {
    
    init() {
        
        Router.add(Route("/feed") { params in
            
        })
        
        Router.add(Route("/feed/new") { params in
            
            let vc = Storyboard.newFeed.viewController(of: NewFeedViewController.self)
            
            let transitionManager = PresentationTransitionManager()
            transitionManager.presentedViewHeight = AppCoordinator.shared.rootViewController.view.bounds.height
            
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = transitionManager
            
            let viewModel = NewFeedViewModel(token: UUID().uuidString)
            vc.viewModel = viewModel
        })
        
        Router.add(Route("/feed/:id") { params in
      
            guard let feedID = params |>> "id", let realm = try? Realm() else { return }
            
            let predicate = NSPredicate(format: "id = %@", feedID)
            
            guard let feed = FeedService.shared.fetch(withPredicate: predicate, fromRealm: realm) else {
                return
            }
            
            let vc = Storyboard.feed.viewController(of: FeedViewController.self)
            vc.viewModel = FeedViewModel(feed: feed)
        })
    }
}
