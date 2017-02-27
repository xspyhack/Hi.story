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

enum NewFeedMode {
    case new
    case edit(Story)
}

struct LocationInfo: Equatable {
    let address: String
    let coordinate: CLLocationCoordinate2D
    
    public static func ==(lhs: LocationInfo, rhs: LocationInfo) -> Bool {
        return (lhs.coordinate.latitude == rhs.coordinate.latitude) && (lhs.coordinate.longitude == rhs.coordinate.longitude)
    }
}

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
    var location: Variable<LocationInfo?>
    var attachmentImage: Variable<UIImage?>
    var storybook: Variable<Storybook?>
    
    // visible
    var visible: Variable<Bool>
    
    // Input
    var postAction = PublishSubject<Void>()
    var cancelAction = PublishSubject<Void>()
    
    // Output
    let postButtonEnabled: Driver<Bool>
    let dismissViewController: Driver<Void>
    
    fileprivate let disposeBag = DisposeBag()
    
    init(mode: NewFeedMode = .new, token: String) {
       
        let storyID: String
        
        switch mode {
        case .new:
            // Default value
            storyID = UUID().uuidString
            
            self.title = Variable("")
            self.body = Variable("")
            self.tag = Variable(.none)
            self.location = Variable(nil)
            
            self.visible = Variable(true)
           
            if let userID = HiUserDefaults.userID.value {
                self.storybook = Variable(Configuration.defaultStorybook(of: userID))
            } else {
                self.storybook = Variable(nil)
            }
            self.attachmentImage = Variable(nil)
        case .edit(let story):
            storyID = story.id
            
            self.title = Variable(story.title)
            self.body = Variable(story.body)
            self.tag = Variable(.none)
            if let location = story.location, let coordinate = location.coordinate {
                let coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let info = LocationInfo(address: location.name, coordinate: coordinate)
                self.location = Variable(info)
            } else {
                self.location = Variable(nil)
            }
            self.visible = Variable(true)
            
            self.storybook = Variable(story.withStorybook)
            self.attachmentImage = Variable(nil)
        }
        
        let attachmentInfo = self.attachmentImage.asObservable()
            .flatMapLatest { (image) -> Observable<(String, URL, CGSize)?> in
                let url = URL.hi.imageURL(withPath: storyID)
                if let image = image {
                    let size = image.size
                    let metadata = metadataString(of: image)
                    CacheService.shared.store(image, forKey: url.absoluteString)
                    return Observable.just((metadata, url, size))
                } else {
                    print("Remove image")
                    CacheService.shared.removeIfExisting(forKey: url.absoluteString)
                    return Observable.just(nil)
                }
            }
            .asDriver(onErrorJustReturn: nil)
        
        self.postButtonEnabled = self.body.asDriver()
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
            .startWith(false)
        
        let story = Driver.combineLatest(
            title.asDriver(),
            body.asDriver(),
            location.asDriver(),
            storybook.asDriver(),
            attachmentInfo
        ) { title, body, locationInfo, storybook, attachmentInfo -> Story in
          
            let newStory = Story()
            newStory.id = storyID
            newStory.title = title.isEmpty ? "Untitle" : title
            newStory.body = body.hi.trimming(.whitespaceAndNewline)
            
            newStory.withStorybook = storybook
            
            if let (metadata, url, size) = attachmentInfo {
                let meta = Meta()
                meta.widht = Double(size.width)
                meta.height = Double(size.height)
                let attachment = Attachment()
                attachment.urlString = url.absoluteString
                attachment.meta = meta
                attachment.metadata = metadata
                newStory.attachment = attachment
            }
            
            if let locationInfo = locationInfo {
                
                let location = Location()
                location.name = locationInfo.address
                
                let coordinate = Coordinate()
                coordinate.safeConfigure(withLatitude: locationInfo.coordinate.latitude, longitude: locationInfo.coordinate.longitude)
                location.coordinate = coordinate
                
                newStory.location = location
            }
            
            return newStory
        }
        
        let feed = Driver.combineLatest(
            story,
            visible.asDriver()
        ) { story, isVisible -> Feed in
            
            let feed = Feed()
            feed.story = story
         
            let creator = User.current
            feed.creator = creator
            
            feed.visible = isVisible ? 0 : 1
            
            return feed
        }
        
        let didPost = self.postAction.asDriver()
            .withLatestFrom(postButtonEnabled).filter{ $0 }
            .withLatestFrom(feed)
            .map { feed in
                feed.story?.isPublished = true
                Feed.didCreate.onNext(feed)
            }
            .asDriver()
        
        let didCancel = self.cancelAction.asDriver()
            .withLatestFrom(story)
            .map { story in
                // Save draft
                guard let realm = try? Realm(), !(story.title.isEmpty && story.body.isEmpty ) else { return }
                StoryService.shared.synchronize(story, toRealm: realm)
            }
            .asDriver()
        
        self.dismissViewController = Driver.of(didPost, didCancel).merge()
    }
}
