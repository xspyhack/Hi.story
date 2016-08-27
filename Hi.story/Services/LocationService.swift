//
//  LocationService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/30/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import CoreLocation
import Hikit

class LocationService: NSObject {
    static let shareService = LocationService()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.distanceFilter = kCLDistanceFilterNone
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.pausesLocationUpdatesAutomatically = true
        manager.headingFilter = kCLHeadingFilterNone
        return manager
    }()
    
    func turnOn() {
        self.locationManager.startUpdatingLocation()
    }
    
    var afterUpdatedLocationAction: (CLLocation -> Void)?
    var didLocateHandler: (Result<(String, CLLocationCoordinate2D)> -> Void)?
    
    private lazy var geocoder = CLGeocoder()
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        
        afterUpdatedLocationAction?(newLocation)
        
        locationManager.stopUpdatingLocation()
        
        geocoder.reverseGeocodeLocation(newLocation) { [weak self](placemarks, error) in
            if let error = error {
                self?.didLocateHandler?(.Failure(error.localizedDescription))
            } else {
                guard let placemarks = placemarks, placemark = placemarks.first else {
                    self?.didLocateHandler?(.Failure("No location information"))
                    return
                }
                
                let address = "\(placemark.country ?? "") \(placemark.administrativeArea ?? "") \(placemark.locality ?? "") \(placemark.subLocality ?? "") \(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? "")"
                self?.didLocateHandler?(.Success(address, newLocation.coordinate))
            }
        }
    }
}