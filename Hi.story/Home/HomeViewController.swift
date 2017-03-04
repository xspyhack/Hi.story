//
//  HomeViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxSwift
import RxCocoa

final class HomeViewController: UIPageViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.removeAllSegments()
            (0..<Channel.count).forEach({
                let channel = Channel(rawValue: $0)
                segmentedControl.insertSegment(withTitle: channel?.title, at: $0, animated: false)
            })
        }
    }
    
    fileprivate enum Channel: Int {
        case today = 0
        case history
        
        var index: Int {
            return rawValue
        }
        
        var title: String? {
            switch self {
            case .today: return "Today"
            case .history: return "History"
            }
        }
        
        static var count: Int {
            return Channel.history.rawValue + 1
        }
    }
    
    fileprivate lazy var historyViewController: HistoryViewController = {
       
        let vc = Storyboard.home.viewController(of: HistoryViewController.self)

        return vc
    }()
    
    fileprivate lazy var todayViewController: TodayViewController = {
       
        let vc = Storyboard.home.viewController(of: TodayViewController.self)
        
        return vc
    }()
    
    private var isPageViewTransitioning: Bool = false
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectingChannel(.today)

        segmentedControl.rx.value
            .subscribe(onNext: { [weak self] index in
                self?.selecting(at: index)
            })
            .addDisposableTo(disposeBag)
        
        self.dataSource = self
        self.delegate = self
        
        historyViewController.showFeedAction = { feed in
        }
        
        historyViewController.showMatterAction = { [weak self] matter in
            self?.performSegue(withIdentifier: .showMatter, sender: matter)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hi.proposeForNotifications([.alert, .sound], agreed: { 
            // just request
            Defaults.notificationsEnabled = true
        }, rejected: {
            Defaults.notificationsEnabled = false
        })
    }
    
    private func selecting(at index: Int) {
        guard let channel = Channel(rawValue: index) else { return }
        
        selectingChannel(channel)
    }
    
    fileprivate func selectingChannel(_ channel: Channel) {
        
        isPageViewTransitioning = true
        
        switch channel {
            
        case .history:
            setViewControllers([historyViewController], direction: .forward, animated: true) { [weak self] finished in
                self?.isPageViewTransitioning = !finished
            }
            
        case .today:
            setViewControllers([todayViewController], direction: .reverse, animated: true) { [weak self] finished in
                self?.isPageViewTransitioning = !finished
            }
        }
        
        segmentedControl.selectedSegmentIndex = channel.index
    }
    
    func collectingMemories() {
    
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension HomeViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController == historyViewController {
            return todayViewController
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewController == todayViewController {
            return historyViewController
        }
        
        return nil
    }
}

// MARK: - UIPageViewControllerDelegate

extension HomeViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else {
            return
        }
        
        if previousViewControllers.first == historyViewController {
            selectingChannel(.today)
        } else if previousViewControllers.first == todayViewController {
            selectingChannel(.history)
        }
    }
}

extension HomeViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case showMatter
        case showFeed
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(forSegue: segue) {
        case .showFeed:
            let vc = segue.destination as? FeedViewController
            if let feed = sender as? Feed {
                vc?.viewModel = FeedViewModel(feed: feed)
            }
        case .showMatter:
            let vc = segue.destination as? MatterViewController
            if let matter = sender as? Matter {
                vc?.viewModel = MatterViewModel(matter: matter)
            }
        }
    }
}

