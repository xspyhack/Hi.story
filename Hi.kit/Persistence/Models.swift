//
//  Models.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 8/3/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import MapKit
import RealmSwift

public let realmQueue = DispatchQueue(label: "com.xspyhack.Hikit.realmQueue", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)

public class User: Object {
    @objc public dynamic var id: String = ""
    @objc public dynamic var username: String = ""
    @objc public dynamic var nickname: String = ""
    @objc public dynamic var bio: String = ""
    @objc public dynamic var avatarURLString: String = ""
    
    @objc public dynamic var createdAt: TimeInterval = Date().timeIntervalSince1970
    @objc public dynamic var lastSignInAt: TimeInterval = Date().timeIntervalSince1970
    
    public let createdFeeds = LinkingObjects(fromType: Feed.self, property: "creator")
   
    public override class func primaryKey() -> String? {
        return "id"
    }
    
    public override class func indexedProperties() -> [String] {
        return ["id"]
    }
}

public extension User {
    
    public static var current: User? {
        guard let userID = HiUserDefaults.userID.value, let realm = try? Realm() else { return nil }
        let predicate = NSPredicate(format: "id = %@", userID)
        return realm.objects(User.self).filter(predicate).first
    }
    
    
    public static func shared(with user: User) -> SharedUser {
        return SharedUser(id: user.id, username: user.username, nickname: user.nickname, bio: user.bio, avatarURLString: user.avatarURLString, createdAt: user.createdAt, lastSignInAt: user.lastSignInAt)
    }
}

public class Attachment: Object {
    @objc public dynamic var metadata: String = ""
    @objc public dynamic var urlString: String = ""
    @objc public dynamic var meta: Meta?
    
    public var thumbnailImageData: Data? {
        
        guard (metadata as NSString).length > 0 else {
            return nil
        }
        
        if !metadata.isEmpty {
            let thumbnailString = metadata
            let imageData = Data(base64Encoded: thumbnailString, options: NSData.Base64DecodingOptions(rawValue: 0))
            return imageData
        }
        
        return nil
    }
    
    public var thumbnailImage: UIImage? {
        return thumbnailImageData.flatMap { UIImage(data: $0) }
    }
}

public class Meta: Object {
    @objc public dynamic var widht: Double = 0.0
    @objc public dynamic var height: Double = 0.0
}

public class Location: Object {
    @objc public dynamic var name: String = ""
    @objc public dynamic var coordinate: Coordinate?
}

public class Coordinate: Object {
    @objc public dynamic var latitude: Double = 0    // 合法范围 (-90, 90)
    @objc public dynamic var longitude: Double = 0   // 合法范围 (-180, 180)
    
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

public func metadataString(of image: UIImage, quality: CGFloat = 0.7) -> String {
    
    let imageWidth = image.size.width
    let imageHeight = image.size.height
    
    let thumbnailWidth: CGFloat
    let thumbnailHeight: CGFloat
    
    if imageWidth > imageHeight {
        thumbnailWidth = min(imageWidth, Configuration.Metadata.thumbnailMaxSize)
        thumbnailHeight = imageHeight * (thumbnailWidth / imageWidth)
    } else {
        thumbnailHeight = min(imageHeight, Configuration.Metadata.thumbnailMaxSize)
        thumbnailWidth = imageWidth * (thumbnailHeight / imageHeight)
    }
    
    let thumbnailSize = CGSize(width: thumbnailWidth, height: thumbnailHeight)
    
    if let thumbnail = image.hi.resized(to: thumbnailSize, withInterpolationQuality: .high) {

        let data = UIImageJPEGRepresentation(thumbnail, quality)!
        let string = data.base64EncodedString(options: [])
        
        return string
    } else {
        return ""
    }
}
