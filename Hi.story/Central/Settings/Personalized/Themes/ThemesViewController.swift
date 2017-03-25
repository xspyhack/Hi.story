//
//  ThemesViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 20/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class ThemesViewController: UICollectionViewController {
    
    private let reuseIdentifier = "ThemeCell"
    
    private var themes: [String] = ["[K]"]

    private struct Constant {
        static let padding: CGFloat = 32.0
        static let gap: CGFloat = 24.0
        static let itemSize = CGSize(width: 300.0, height: 200.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Choose a theme"
        
        collectionView?.backgroundColor = UIColor.hi.background
        collectionView?.alwaysBounceVertical = true
       
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = Constant.itemSize
            let inset = Constant.gap / 2.0
            flowLayout.sectionInset = UIEdgeInsets(top: Constant.gap, left: Constant.padding, bottom: inset + Defaults.tabBarHeight, right: Constant.padding)
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThemeCell
        cell.imageView.image = UIImage.hi.themeK
        return cell
    }
}
