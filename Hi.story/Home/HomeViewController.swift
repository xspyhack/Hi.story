//
//  HomeViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import TextAttributes
import Kingfisher
import Hikit
import Alamofire
import Himarkdown
import RealmSwift

final class HomeViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    private lazy var blurEffect = UIBlurEffect(style: .Light)
    private lazy var blurEffectView: UIVisualEffectView = {
        return UIVisualEffectView()
    }()
    
    private var isFace: Bool = false
    
    private lazy var presentationTransitionManager: PresentationTransitionManager = {
        let manager = PresentationTransitionManager()
        manager.presentedViewHeight = self.view.bounds.height
        return manager
    }()

    // MARK: Lift cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let realm = try? Realm(), latestStory = StoryService.sharedService.fetchLatest(fromRealm: realm) {
            handleNewStory(latestStory)
        }
        
        Kingfisher.ImageCache.defaultCache.calculateDiskCacheSizeWithCompletionHandler { (size) in
            print("cache size: \(size)")
        }
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
    
    func tryToTellStory() {
        performSegue(withIdentifier: .PresentNewStory, sender: nil)
    }
    
    // MARK: - Private setup
    
    @objc private func showNewStory(sender: UITapGestureRecognizer) {
        tryToTellStory()
    }
    
    private func handleNewStory(story: Story) {
        DispatchQueue.async(on: .Main) {
            self.imageView.kf_setImage(withURL: NSURL(string: story.attachment?.URLString ?? ""))
        }
    }
}

extension HomeViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case PresentNewStory
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let viewController = segue.destinationViewController as! NewStoryViewController
        
        viewController.modalPresentationStyle = .Custom
        viewController.transitioningDelegate = presentationTransitionManager
        
        viewController.tellStoryDidSuccessAction = { [weak self] (story) in
            self?.handleNewStory(story)
            print(story)
        }
    }
}

extension HomeViewController: Refreshable {
    
    func refresh() {
        imageView.image = nil
    }
}
