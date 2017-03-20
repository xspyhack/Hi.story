//
//  CoversViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 16/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

final class CoversViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "CoverPhotoCell"
    
    private struct Constant {
        static let padding: CGFloat = 32.0
        static let numberOfRow = 2
        static let gap: CGFloat = 24.0
        static let ratio: CGFloat = 6.0 / 10.0
    }
    
    private let generator = UISelectionFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Choose a cover photo"
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = Constant.gap
            flowLayout.minimumInteritemSpacing = Constant.gap
            let inset = Constant.gap / 2.0
            flowLayout.sectionInset = UIEdgeInsets(top: Constant.gap, left: Constant.padding, bottom: inset + Defaults.tabBarHeight, right: Constant.padding)
        }
        
        generator.prepare()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let index = Defaults.selectingCover.value
        
        collectionView?.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredVertically)
    }
   
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return King.all.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CoverPhotoCell
    
        let king = King.all.safe[indexPath.item]
        cell.titleLabel.text = king?.name
        cell.backgroundImageView.image = king?.card
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        Defaults.selectingCover.value = indexPath.item
        
        generator.selectionChanged()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.bounds.width
        
        let itemWidth = (collectionViewWidth - Constant.padding * 2 - CGFloat((Constant.numberOfRow - 1)) * Constant.gap) / CGFloat(Constant.numberOfRow)
        
        return CGSize(width: itemWidth, height: itemWidth / Constant.ratio)
    }

}
