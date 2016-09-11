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
    
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var scrollView: UIScrollView!

    private enum Channel: Int {
        case Today = 0
        case History
        
        var index: Int {
            return rawValue
        }
    }
    
    // MARK: Lift cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        segmentedControl.rx_value
            .subscribeNext { [weak self] index in
                self?.selecting(at: index)
            }
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Public
    
    private func selecting(at index: Int) {
        guard let channel = Channel(rawValue: index) else { return }
        
        selectingChannel(channel)
    }
    
    private func selectingChannel(channel: Channel) {
        
        let width = view.bounds.width
        
        scrollView.setContentOffset(CGPoint(x: width * CGFloat(channel.index), y: 0.0), animated: true)
    }
    
    private func selecting(at offset: CGFloat) {
        
        let width = view.bounds.width
        
        let index = Int(offset / width)
        
        segmentedControl.selectedSegmentIndex = index
    }
}

extension HomeViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        selecting(at: scrollView.contentOffset.x)
    }
}

