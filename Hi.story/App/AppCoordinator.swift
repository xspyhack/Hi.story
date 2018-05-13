//
//  AppCoordinator.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 25/03/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//


import Hikit
import Hiroute
import Argo
import Runes
import RealmSwift

protocol Coordinator {
    func start()
}

struct AppCoordinator: Coordinator {
    
    static let shared = AppCoordinator()
    
    let rootWindow: UIWindow
    
    let rootViewController: TabBarController
    
    let rootCoordinator: TabBarCoordinator
    
    init() {
        self.init(rootWindow: UIApplication.shared.keyWindow!)
    }
    
    init(rootWindow: UIWindow) {
        self.rootWindow = rootWindow
        self.rootViewController = rootWindow.rootViewController as! TabBarController
        
        self.rootCoordinator = TabBarCoordinator(root: self.rootViewController)
    }
    
    func start() {
        rootCoordinator.start()
    }

    func loadRoutes() {
        
        Router.shared.hosts = ["www.blessingsoft.com", "www.blessingsoftware.com"]
        Router.shared.schemes = ["hi", "history", "story"]
 
        loadFeed()
        loadMatter()
    }
    
    private func popToRoot(animated: Bool = true) {
        if let nvc = self.rootViewController.selectedViewController as? UINavigationController {
            if nvc.viewControllers.count > 1 {
                nvc.popToRootViewController(animated: animated)
            }
        }
    }
}

extension AppCoordinator {
    
    private func loadFeed() {
        Router.add(Route("/feed") { params in
            self.popToRoot(animated: false)
            self.rootViewController.selectedTab.value = .feeds
        })
        
        Router.add(Route("/feed/new/") { params in
            self.popToRoot(animated: false)
            self.rootViewController.selectedTab.value = .feeds
            
            let vc = Storyboard.newFeed.viewController(of: NewFeedViewController.self)
            let nvc: UINavigationController
            if let context = Router.context, let navigationController = context.navigationController {
                nvc = navigationController
            } else {
                nvc = self.rootViewController.selectedNavigationController
            }

            let size = nvc.view.bounds.size
            let context = PresentationContext(presentedContentSize: size, offset: CGPoint(x: 0, y: Defaults.statusBarHeight))
            let transitionManager = PresentationTransitionManager(context: context)
            
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = transitionManager
            
            let viewModel = NewFeedViewModel(token: UUID().uuidString)
            vc.viewModel = viewModel
        
            nvc.present(vc, animated: true, completion: nil)
        })
        
        Router.add(Route("/feed/:id") { params in
            guard let feedID = params |>> "id", let realm = try? Realm() else { return }
            
            let predicate = NSPredicate(format: "id = %@", feedID)
            
            guard let feed = FeedService.shared.fetch(withPredicate: predicate, fromRealm: realm) else {
                return
            }
            
            self.popToRoot(animated: false)
            self.rootViewController.selectedTab.value = .feeds
            
            let vc = Storyboard.feed.viewController(of: FeedViewController.self)
            vc.viewModel = FeedViewModel(feed: feed)
            
            let nvc = self.rootViewController.selectedNavigationController
            nvc.pushViewController(vc, animated: true)
        })
    }
}

extension AppCoordinator {
    
    private func loadMatter() {
        Router.add(Route("/matter") { params in
            self.popToRoot(animated: false)
            self.rootViewController.selectedTab.value = .matters
        })
        
        Router.add(Route("/matter/new") { params in
            self.popToRoot(animated: false)
            self.rootViewController.selectedTab.value = .matters
            
            let nvc = self.rootViewController.selectedNavigationController
            let viewController = Storyboard.matter.viewController(of: NewMatterViewController.self)
            nvc.pushViewController(viewController, animated: true)
        })
        
        Router.add(Route("/matter/:id") { params in
            
            guard let metterID = params |>> "id" else {
                return
            }
            
            self.popToRoot(animated: false)
            self.rootViewController.selectedTab.value = .matters
            
            guard let realm = try? Realm(), let userID = HiUserDefaults.userID.value else { return }
            
            let predicate = NSPredicate(format: "creator.id = %@ AND id = %@", userID, metterID)
            
            guard let matter = MatterService.shared.fetch(withPredicate: predicate, fromRealm: realm) else {
                return
            }
            
            let viewModel = MatterViewModel(matter: matter)
            let viewController = Storyboard.matter.viewController(of: MatterViewController.self)
            viewController.viewModel = viewModel
            
            let nvc = self.rootViewController.selectedNavigationController
            nvc.pushViewController(viewController, animated: true)
        })
    }
}
