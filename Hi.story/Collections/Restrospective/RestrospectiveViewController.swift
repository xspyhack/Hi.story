//
//  RestrospectiveViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RealmSwift

final class RestrospectiveViewController: BaseViewController {

    @IBOutlet fileprivate weak var storyCollectionView: UICollectionView! {
        didSet {
            storyCollectionView.hi.register(reusableCell: CollectionCell.self)
            storyCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        }
    }
    
    var stories: [Story]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "Restrospective"
        
        edgesForExtendedLayout = UIRectEdge()
        
        guard let realm = try? Realm() else { return }
        stories = StoryService.shared.fetchAll(fromRealm: realm)
        
    }
    
    fileprivate func handleNewStories(_ stories: [Story]) {
        self.stories = stories
        self.storyCollectionView.reloadData()
    }
}

// MARK: - SegueHandlerType

extension RestrospectiveViewController: SegueHandlerType {

    enum SegueIdentifier: String {
        case showStory
    }
    
    // MARK: Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segueIdentifier(forSegue: segue) {
        case .showStory:
            let viewController = segue.destination as? StoryViewController
            if let wrapper: Wrapper<Story> = sender as? Wrapper {
                viewController?.story = wrapper.candy
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension RestrospectiveViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories?.count ?? 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: CollectionCell = collectionView.hi.dequeueReusableCell(for: indexPath)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension RestrospectiveViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let story = stories?[safe: indexPath.item], let cell = cell as? CollectionCell else {
            return
        }
        
        let restrospective = Restrospective(title: story.title, description: story.body, imageURL: URL(string: story.attachment?.urlString ?? ""))
        
        let collectionCellModel = CollectionCellModel(restrospective: restrospective)
        
        cell.configure(withPresenter: collectionCellModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let focusViewLayout = collectionView.collectionViewLayout as? SFFocusViewLayout else {
            fatalError("error casting focus layout from collection view")
        }
        
        let offset = focusViewLayout.dragOffset * CGFloat((indexPath as NSIndexPath).item)
        if collectionView.contentOffset.y != offset {
            collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        } else {
            guard let story = stories?[safe: (indexPath as NSIndexPath).item] else {
                return
            }
            performSegue(withIdentifier: .showStory, sender: Wrapper(bullet: story))
        }
    }
}
