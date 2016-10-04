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
    var visibleAction: PublishSubject<Void> { get }

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
    var attachmentImage: Variable<UIImage?>
    
    // visible
    var visible: Variable<Bool>
    
    // Input
    var postAction = PublishSubject<Void>()
    var cancelAction = PublishSubject<Void>()
    var visibleAction = PublishSubject<Void>()
    
    // Output
    let postButtonEnabled: Driver<Bool>
    let dismissViewController: Driver<Void>
    
    fileprivate let disposeBag = DisposeBag()
    
    init() {
        
        // Default value
        self.title = Variable(NSDate().hi.yearMonthDay)
        self.body = Variable("")
        self.tag = Variable(.none)
        self.location = Variable(nil)
        
        self.visible = Variable(false)
        
        self.attachmentImage = Variable(nil)
        
        let attachmentURL = self.attachmentImage.asObservable()
            .flatMapLatest { (image) -> Observable<URL?> in
                let url = NSURL.hi.imageURL(withPath: NSDate().hi.timestamp)
                if let image = image {
                    CacheService.shared.store(image, forKey: url.absoluteString)
                    return Observable.just(url)
                } else {
                    CacheService.shared.removeIfExisting(forKey: url.absoluteString)
                    return Observable.just(nil)
                }
            }
            .asDriver(onErrorJustReturn: nil)
        
        self.postButtonEnabled = self.body.asDriver()
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
            .startWith(false)
        
        let story = Driver.combineLatest(title.asDriver(),
                                         body.asDriver(),
                                         location.asDriver(),
                                         attachmentURL
        ) { title, body, locationInfo, attachmentURL -> Story in
            
            let story = Story()
            story.title = title
            story.body = body.trimming(.whitespaceAndNewline)
            
            if let url = attachmentURL {
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
        ) { story, isVisible -> Feed in
            
            let feed = Feed()
            feed.story = story
         
            let creator = Hikit.User.current
            feed.creator = creator
            
            feed.visible = isVisible ? 0 : 1
            
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
