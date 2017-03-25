//
//  LocationService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/30/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Hikit
import CoreLocation

struct LocationError: Error {
    let code: Int
    
    let description: String
    
    static var `default`: LocationError {
        return LocationError(code: -1, description: "Default location error.")
    }
}

final class LocationService: NSObject {
    static let shared = LocationService()
    
    fileprivate lazy var locationManager: CLLocationManager = {
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
        guard CLLocationManager.locationServicesEnabled() else { return }
        self.locationManager.startUpdatingLocation()
    }
    
    func turnOff() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        locationManager.stopUpdatingLocation()
    }
    
    var afterUpdatedLocationAction: ((CLLocation) -> Void)?
    var didLocateHandler: ((Result<(String, CLLocationCoordinate2D)>) -> Void)?
    
    fileprivate lazy var geocoder = CLGeocoder()
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        
        afterUpdatedLocationAction?(newLocation)
        
        locationManager.stopUpdatingLocation()
        
        geocoder.reverseGeocodeLocation(newLocation) { [weak self] (placemarks, error) in
            if let error = error {
                self?.didLocateHandler?(.failure(error))
            } else {
                guard let placemarks = placemarks, let placemark = placemarks.first else {
                    self?.didLocateHandler?(.failure(LocationError(code: 2, description: "No location information")))
                    return
                }
                
                let address = "\(placemark.country ?? "") \(placemark.administrativeArea ?? "") \(placemark.locality ?? "") \(placemark.subLocality ?? "") \(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? "")"
                self?.didLocateHandler?(.success(address, newLocation.coordinate))
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didLocateHandler?(.failure(error))
    }
}
