//
//  LocationService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/30/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import CoreLocation
import Hiprelude

public struct LocationError: Error {
    public let code: Int
    
    public let description: String
    
    public static var `default`: LocationError {
        return LocationError(code: -1, description: "Default location error.")
    }
}

final public class LocationService: NSObject {
    
    public static let shared = LocationService()
    
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
    
    public func turnOn() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        self.locationManager.startUpdatingLocation()
    }
    
    public func turnOff() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        locationManager.stopUpdatingLocation()
    }
    
    public var afterUpdatedAction: ((CLLocation) -> Void)?
    public var didLocateHandler: ((Result<(String, CLLocationCoordinate2D)>) -> Void)?
    
    private lazy var geocoder = CLGeocoder()
}

extension LocationService: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        
        afterUpdatedAction?(newLocation)
        
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
                
                let result: (String, CLLocationCoordinate2D) = (address, newLocation.coordinate)
                self?.didLocateHandler?(Result.success(result))
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didLocateHandler?(.failure(error))
    }
}
