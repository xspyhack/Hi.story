//
//  DetailsViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 25/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit
import CoreLocation

struct DetailsViewModel {
    let words: Int
    let chars: Int
    let created: String
    let updated: String
    
    let coordinate: CLLocationCoordinate2D?
    let address: String?
    
    init(body: String, created: TimeInterval, updated: TimeInterval, location: Location? = nil) {
        self.words = 233
        self.chars = 1024
        self.created = Date(timeIntervalSince1970: created).hi.yearMonthDay
        self.updated = Date(timeIntervalSince1970: updated).hi.yearMonthDay
        self.coordinate = location?.coordinate.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        self.address = location?.name
    }
    
    init(story: Story) {
        self.words = 0
        self.chars = 0
        self.created = Date(timeIntervalSince1970: story.createdAt).hi.yearMonthDay
        self.updated = Date(timeIntervalSince1970: story.updatedAt).hi.yearMonthDay
        self.coordinate = story.location?.coordinate.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        self.address = story.location?.name
    }
}
