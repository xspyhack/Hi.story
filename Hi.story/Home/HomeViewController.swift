//
//  HomeViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxCocoa
import RxSwift

final class HomeViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var segmentedControl: UISegmentedControl!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!

    private enum Channel: Int {
        case today = 0
        case history
        
        var index: Int {
            return rawValue
        }
    }
    
    // MARK: Lift cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        segmentedControl.rx.value
            .subscribe(onNext: { [weak self] index in
                self?.selecting(at: index)
            })
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Public
    
    func tryToTellStory() {
        // ?? QuickAction
    }
    
    fileprivate func selecting(at index: Int) {
        guard let channel = Channel(rawValue: index) else { return }
        
        selectingChannel(channel)
    }
    
    fileprivate func selectingChannel(_ channel: Channel) {
        
        let width = view.bounds.width
        
        scrollView.setContentOffset(CGPoint(x: width * CGFloat(channel.index), y: 0.0), animated: true)
    }
    
    fileprivate func selecting(at offset: CGFloat) {
        
        let width = view.bounds.width
        
        let index = Int(offset / width)
        
        segmentedControl.selectedSegmentIndex = index
    }
}

extension HomeViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        selecting(at: scrollView.contentOffset.x)
    }
}

