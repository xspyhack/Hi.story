//
//  SearchableItem.swift
//  Yep
//
//  Created by NIX on 16/3/30.
//  Copyright © 2016年 Catch Inc. All rights reserved.
//

import CoreSpotlight
import MobileCoreServices.UTType
import RealmSwift

public enum SearchableItemType: String {
    case user // 暂时不支持
    case feed
}

public func searchableItemID(searchableItemType itemType: SearchableItemType, itemID: String) -> String {

    return "\(itemType)/\(itemID)"
}

public func searchableItem(with searchableItemID: String) -> (itemType: SearchableItemType, itemID: String)? {

    let parts = searchableItemID.components(separatedBy: "/")

    guard parts.count == 2 else {
        return nil
    }

    guard let itemType = SearchableItemType(rawValue: parts[0]) else {
        return nil
    }

    return (itemType: itemType, itemID: parts[1])
}

public func deleteSearchableItems(searchableItemType itemType: SearchableItemType, itemIDs: [String]) {

    guard !itemIDs.isEmpty else {
        return
    }

    let toDeleteSearchableItemIDs = itemIDs.map {
        searchableItemID(searchableItemType: itemType, itemID: $0)
    }

    CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: toDeleteSearchableItemIDs, completionHandler: { error in
        if error != nil {
            debugPrint(error!.localizedDescription)

        } else {
            if itemIDs.count == 1 {
                debugPrint("deleteSearchableItem \(itemType): \(itemIDs[0]) OK")
            } else {
                debugPrint("deleteSearchableItems \(itemType): count \(itemIDs.count) OK")
            }
        }
    })
}

@available(iOS 9.0, *)
public extension Feed {
    
    public var attributeSet: CSSearchableItemAttributeSet {
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
        attributeSet.title = story?.title
        attributeSet.contentDescription = story?.body
        
        if let attachment = story?.attachment, let thumbnailImageData = attachment.thumbnailImageData {
            attributeSet.thumbnailData = thumbnailImageData
            
        }
        
        return attributeSet
    }
}

public func indexFeedSearchableItems() {
    
    guard let realm = try? Realm() else {
        return
    }
    
    let feeds = Array(realm.objects(Feed.self))
    
    let searchableItems = feeds.map {
        CSSearchableItem(
            uniqueIdentifier: searchableItemID(searchableItemType: .feed, itemID: $0.id),
            domainIdentifier: Configure.Domain.feed,
            attributeSet: $0.attributeSet
        )
    }
    
    print("feedSearchableItems: \(searchableItems.count)")
    
    CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
        if error != nil {
            print(error!.localizedDescription)
            
        } else {
            print("indexFeedSearchableItems OK")
        }
    }
}

