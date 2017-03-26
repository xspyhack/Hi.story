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
    
    let location: LocationInfo?
    let address: String?
    
    init(body: String, created: TimeInterval, updated: TimeInterval, location: LocationInfo? = nil) {
        self.words = body.hi.words.count
        self.chars = body.characters.count
        self.created = "CREATED " + Date(timeIntervalSince1970: created).hi.dmyAtHourMinute
        self.updated = "UPDATED " + Date(timeIntervalSince1970: updated).hi.dmyAtHourMinute
        self.location = location
        self.address = location?.address
    }
    
    init(story: Story) {
        self.words = story.body.hi.words.count
        self.chars = story.body.characters.count
        self.created = "CREATED " + Date(timeIntervalSince1970: story.createdAt).hi.dmyAtHourMinute
        self.updated = "UPDATED " + Date(timeIntervalSince1970: story.updatedAt).hi.dmyAtHourMinute
        self.location = story.location.flatMap {
            if let coordinate = $0.coordinate {
                return LocationInfo(address: $0.name, coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
            } else {
                return nil
            }
        }
        self.address = story.location?.name
    }
}
