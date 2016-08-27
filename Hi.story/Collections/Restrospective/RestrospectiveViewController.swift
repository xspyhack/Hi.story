//
//  RestrospectiveViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import SFFocusViewLayout
import Hikit
import RealmSwift

final class RestrospectiveViewController: UIViewController {

    @IBOutlet private weak var storyCollectionView: UICollectionView! {
        didSet {
            storyCollectionView.xh_registerReusableCell(CollectionCell)
            storyCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        }
    }
    
    var viewModel: StorysViewModel?
    
    var stories: [Story]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "Restrospective"
        
        edgesForExtendedLayout = UIRectEdge.None
        
        viewModel = StorysViewModel() { [weak self] in
            self?.storyCollectionView.reloadData()
        }
        
        viewModel?.fetchStorys()
        
        guard let realm = try? Realm() else { return }
        stories = StoryService.sharedService.fetchAll(fromRealm: realm)
        
    }
    
    private func handleNewStories(stories: [Story]) {
        self.stories = stories
        self.storyCollectionView.reloadData()
    }
}

// MARK: - SegueHandlerType

extension RestrospectiveViewController: SegueHandlerType {

    enum SegueIdentifier: String {
        case ShowStory
    }
    
    // MARK: Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segueIdentifier(forSegue: segue) {
        case .ShowStory:
            let viewController = segue.destinationViewController as? StoryViewController
            if let wrapper: Wrapper<Story> = sender as? Wrapper {
                viewController?.story = wrapper.candy
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension RestrospectiveViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories?.count ?? 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell: CollectionCell = collectionView.xh_dequeueReusableCell(for: indexPath)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension RestrospectiveViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let story = stories?[safe: indexPath.item], cell = cell as? CollectionCell else {
            return
        }
        
        let restrospective = Restrospective(title: story.title, description: story.body, imageURL: NSURL(string: story.attachment?.URLString ?? ""))
        
        let collectionCellModel = CollectionCellModel(restrospective: restrospective)
        
        cell.configure(withPresenter: collectionCellModel)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let focusViewLayout = collectionView.collectionViewLayout as? SFFocusViewLayout else {
            fatalError("error casting focus layout from collection view")
        }
        
        let offset = focusViewLayout.dragOffset * CGFloat(indexPath.item)
        if collectionView.contentOffset.y != offset {
            collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        } else {
            guard let story = stories?[safe: indexPath.item] else {
                return
            }
            performSegue(withIdentifier: .ShowStory, sender: Wrapper(bullet: story))
        }
    }
}