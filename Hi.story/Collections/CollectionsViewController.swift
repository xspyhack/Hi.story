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

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.xh_registerReusableCell(CollectionCell)
        }
    }
    @IBOutlet private weak var addItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addItem.rx_tap
            .subscribeNext { [weak self] in
                self?.performSegue(withIdentifier: .ShowRestrospective, sender: nil)
            }
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Navigation

extension CollectionsViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case ShowRestrospective
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segueIdentifier(forSegue: segue) {
        case .ShowRestrospective:
            let viewController = segue.destinationViewController as! RestrospectiveViewController
            viewController.hidesBottomBarWhenPushed = true
        }
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionsViewController: UICollectionViewDataSource {
 
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: CollectionCell = collectionView.xh_dequeueReusableCell(for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CollectionsViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}

extension CollectionsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: width / 2.0)
    }
}
