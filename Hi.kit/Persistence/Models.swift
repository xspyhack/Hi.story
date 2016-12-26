//
//  Models.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/3/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import MapKit
import RealmSwift

public class User: Object {
    public dynamic var id: String = ""
    public dynamic var username: String = ""
    public dynamic var nickname: String = ""
    public dynamic var bio: String = ""
    public dynamic var avatarURLString: String = ""
    
    public dynamic var createdAt: TimeInterval = Date().timeIntervalSince1970
    public dynamic var lastSignInAt: TimeInterval = Date().timeIntervalSince1970
    
    public let createdFeeds = LinkingObjects(fromType: Feed.self, property: "creator")
    
    public override class func indexedProperties() -> [String] {
        return ["id"]
    }
}

public extension User {
    
    public static var current: User {
        // TODO: - Fix me
        return User()
    }
}

public class Attachment: Object {
    public dynamic var metadata: String = ""
    public dynamic var urlString: String = ""
    public dynamic var meta: Meta?
}

public class Meta: Object {
    public dynamic var widht: Double = 0.0
    public dynamic var height: Double = 0.0
}

public class Location: Object {
    public dynamic var name: String = ""
    public dynamic var coordinate: Coordinate?
}

public class Coordinate: Object {
    public dynamic var latitude: Double = 0    // 合法范围 (-90, 90)
    public dynamic var longitude: Double = 0   // 合法范围 (-180, 180)
    
    // NOTICE: always use safe version property
    
    public var safeLatitude: Double {
        return abs(latitude) > 90 ? 0 : latitude
    }
    public var safeLongitude: Double {
        return abs(longitude) > 180 ? 0 : longitude
    }
    public var locationCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: safeLatitude, longitude: safeLongitude)
    }
    
    public func safeConfigure(withLatitude latitude: Double, longitude: Double) {
        self.latitude = abs(latitude) > 90 ? 0 : latitude
        self.longitude = abs(longitude) > 180 ? 0 : longitude
    }
}
