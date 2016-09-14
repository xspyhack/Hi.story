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

open class User: Object {
    open dynamic var userID: String = ""
    open dynamic var username: String = ""
    open dynamic var nickname: String = ""
    open dynamic var bio: String = ""
    open dynamic var avatarURLString: String = ""
    
    open dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    open dynamic var lastSignInUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    open override class func indexedProperties() -> [String] {
        return ["userID"]
    }
}

open class Attachment: Object {    
    open dynamic var metadata: String = ""
    open dynamic var URLString: String = ""
}

open class Location: Object {
    open dynamic var name: String = ""
    open dynamic var coordinate: Coordinate?
}

open class Coordinate: Object {
    open dynamic var latitude: Double = 0    // 合法范围 (-90, 90)
    open dynamic var longitude: Double = 0   // 合法范围 (-180, 180)
    
    // NOTICE: always use safe version property
    
    open var safeLatitude: Double {
        return abs(latitude) > 90 ? 0 : latitude
    }
    open var safeLongitude: Double {
        return abs(longitude) > 180 ? 0 : longitude
    }
    open var locationCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: safeLatitude, longitude: safeLongitude)
    }
    
    open func safeConfigure(withLatitude latitude: Double, longitude: Double) {
        self.latitude = abs(latitude) > 90 ? 0 : latitude
        self.longitude = abs(longitude) > 180 ? 0 : longitude
    }
}
