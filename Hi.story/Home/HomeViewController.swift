//
//  HomeViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIPageViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    fileprivate enum Channel: Int {
        case today = 0
        case history
        
        var index: Int {
            return rawValue
        }
    }
    
    fileprivate lazy var historyViewController: HistoryViewController = {
        
        let vc = HistoryViewController()
        
        return vc
    }()
    
    fileprivate lazy var todayViewController: TodayViewController = {
        
        let vc = TodayViewController()
        
        return vc
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.rx.value
            .subscribe(onNext: { [weak self] index in
                self?.selecting(at: index)
            })
            .addDisposableTo(disposeBag)
    }
    
    private func selecting(at index: Int) {
        guard let channel = Channel(rawValue: index) else { return }
        
        selectingChannel(channel)
    }
    
    fileprivate func selectingChannel(_ channel: Channel) {
        
        switch channel {
            
        case .history:
            setViewControllers([historyViewController], direction: .reverse, animated: true, completion: nil)
            
        case .today:
            setViewControllers([todayViewController], direction: .forward, animated: true, completion: nil)
        }
        
        segmentedControl.selectedSegmentIndex = channel.index
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension HomeViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController == todayViewController {
            return historyViewController
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewController == historyViewController {
            return todayViewController
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
            selectingChannel(.history)
        } else if previousViewControllers.first == todayViewController {
            selectingChannel(.today)
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate
/*
extension HomeContainerViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        switch currentOption {
            
        case .meetGenius:
            
            let tableView = meetGeniusViewController.interviewsTableView
            
            let fixedLocation = view.convert(location, to: tableView)
            
            guard let indexPath = tableView.indexPathForRow(at: fixedLocation), let cell = tableView.cellForRow(at: indexPath) else {
                return nil
            }
            
            previewingContext.sourceRect = cell.frame
            
            let vc = UIStoryboard.Scene.geniusInterview
            let geniusInterview = meetGeniusViewController.geniusInterviewAtIndexPath(indexPath)
            vc.interview = geniusInterview
            
            return vc
            
        case .findAll:
            
            let collectionView = discoverViewController.collectionView
            
            let fixedLocation = view.convert(location, to: collectionView)
            
            guard let indexPath = collectionView.indexPathForItem(at: fixedLocation), let cell = collectionView.cellForItem(at: indexPath) else {
                return nil
            }
            
            previewingContext.sourceRect = cell.frame
            
            let vc = UIStoryboard.Scene.profile
            
            let discoveredUser = discoverViewController.discoveredUserAtIndexPath(indexPath)
            vc.prepare(with: discoveredUser)
            
            return vc
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
    }
}
*/

