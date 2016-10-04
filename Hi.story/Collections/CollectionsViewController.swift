//
//  CollectionsViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxCocoa
import RxSwift

final class CollectionsViewController: BaseViewController {
    
    fileprivate lazy var presentationTransitionManager: PresentationTransitionManager = {
        let manager = PresentationTransitionManager()
        manager.presentedViewHeight = self.view.bounds.height
        return manager
    }()

    @IBOutlet fileprivate weak var collectionView: UICollectionView! {
        didSet {
            collectionView.hi.register(reusableCell: CollectionCell.self)
        }
    }
    @IBOutlet private weak var addItem: UIBarButtonItem!
    
    @IBOutlet private weak var switchItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.tryToShowNewStory()
            })
            .addDisposableTo(disposeBag)
        
        switchItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.tryToShowMatters()
            })
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func tryToShowNewStory() {
        performSegue(withIdentifier: .presentNewStory, sender: nil)
    }
    
    fileprivate func tryToShowMatters() {
        performSegue(withIdentifier: .showMatters, sender: nil)
    }
}

// MARK: - Navigation

extension CollectionsViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case showRestrospective
        case showMatters
        case presentNewStory
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segueIdentifier(forSegue: segue) {
        case .showRestrospective:
            let viewController = segue.destination as! RestrospectiveViewController
            viewController.hidesBottomBarWhenPushed = true

        case .presentNewStory:
            let viewController = segue.destination as! NewStoryViewController
            
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = presentationTransitionManager
            
        case .showMatters:
            break
        }
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionsViewController: UICollectionViewDataSource {
 
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionCell = collectionView.hi.dequeueReusableCell(for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CollectionsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension CollectionsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: width / 2.0)
    }
}
