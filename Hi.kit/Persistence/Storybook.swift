//
//  Storybook.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 15/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RealmSwift

public class Storybook: Object, Timetable {

    @objc public dynamic var id: String = UUID().uuidString
    @objc public dynamic var name: String = ""
    @objc public dynamic var creator: User?
    public let stories = LinkingObjects(fromType: Story.self, property: "withStorybook")
    public var latestPicturedStory: Story? {
        return stories.filter({
            $0.attachment != nil
        }).sorted(by: {
            $0.createdAt > $1.createdAt
        }).first
    }
    
    public var latestPublishedPicturedStory: Story? {
        return stories.filter({
            $0.attachment != nil && $0.isPublished == true
        }).sorted(by: {
            $0.createdAt > $1.createdAt
        }).first
    }
    @objc public dynamic var visible: Int = Visible.public.rawValue
    @objc public dynamic var createdAt: TimeInterval = Date().timeIntervalSince1970
    @objc public dynamic var updatedAt: TimeInterval = Date().timeIntervalSince1970
    
    public override class func primaryKey() -> String? {
        return "id"
    }
}

open class StorybookService: Synchronizable {
    
    public typealias T = Storybook
    
    open static let shared = StorybookService()
}
