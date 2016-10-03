//
//  NewFeedViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit
import RxCocoa
import RxSwift
import RxDataSources
import RealmSwift
import CoreLocation

protocol NewFeedViewModelType {
    
    var postAction: PublishSubject<Void> { get }
    var cancelAction: PublishSubject<Void> { get }
    
    var postButtonEnabled: Driver<Bool> { get }
    var dismissViewController: Driver<Void> { get }
}

struct NewFeedViewModel: NewFeedViewModelType {
    
    // feed model
    
    // story
    var title: Variable<String>
    var body: Variable<String>
    var tag: Variable<Tag>
    var location: Variable<(String, CLLocationCoordinate2D)?>
    var attementURL: Variable<URL?>
    
    // visible
    var visible: Variable<Int>
    
    var postAction = PublishSubject<Void>()
    var cancelAction = PublishSubject<Void>()
    
    // Output
    let postButtonEnabled: Driver<Bool>
    let dismissViewController: Driver<Void>
    
    fileprivate let disposeBag = DisposeBag()
    
    init() {
        
        // Default value
        self.title = Variable("")
        self.body = Variable("")
        self.tag = Variable(.none)
        self.location = Variable(nil)
        self.attementURL = Variable(nil)
        
        self.visible = Variable(0)
        
        self.postButtonEnabled = self.title.asDriver()
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
            .startWith(false)
        
        let story = Driver.combineLatest(title.asDriver(),
                                         body.asDriver(),
                                         location.asDriver(),
                                         attementURL.asDriver()
        ) { title, body, locationInfo, attementURL -> Story in
            
            let story = Story()
            story.title = title
            story.body = body
            
            if let url = attementURL {
                let attachment = Attachment()
                attachment.urlString = url.absoluteString
                story.attachment = attachment
            }
            
            if let locationInfo = locationInfo {
                
                let location = Location()
                location.name = locationInfo.0
                
                let coordinate = Coordinate()
                coordinate.safeConfigure(withLatitude: locationInfo.1.latitude, longitude: locationInfo.1.longitude)
                location.coordinate = coordinate
                
                story.location = location
            }
            
            return story
        }
        
        let feed = Driver.combineLatest(story,
                                        visible.asDriver()
        ) { story, visible -> Feed in
            
            let feed = Feed()
            feed.story = story
         
            let creator = Hikit.User.current
            feed.creator = creator
            
            feed.visible = visible
            
            return feed
        }
        
        let didPost = self.postAction.asDriver()
            .withLatestFrom(postButtonEnabled).filter{ $0 }
            .withLatestFrom(feed)
            .map { feed in
                Feed.didCreate.onNext(feed)
            }
            .asDriver()
        
        let didCancel = self.cancelAction.asDriver()
        
        self.dismissViewController = Driver.of(didPost, didCancel).merge()
    }
}
