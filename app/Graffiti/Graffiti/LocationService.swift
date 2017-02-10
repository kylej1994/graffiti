//
//  LocationService.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/9/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import CoreLocation

/* Since multiple view controllers need to be CLLocationManagerDelegates, we made this class
 * to avoid duplicating code
 * This class receives the updates from the CLLocationManager and will update the currentLocation property
 * To use: make a variable like locationService = LocationService.sharedInstance
 * then, in viewDidLoad, call locationService.startUpdatingLocation() to start generating updates
 * Call locationService.stopUpdatingLocation() to stop generating updates (don't know why we'd do this)
 * When the ViewController wants to send location info to the backend, it calls
 * getLatitude() and getLongitude() to get the latest location
 */

class LocationService: NSObject, CLLocationManagerDelegate {
    
    // classes share LocationService and do not create separate instances (singleton)
    // reference: https://krakendev.io/blog/the-right-way-to-write-a-singleton
    static let sharedInstance = LocationService()
    var locationManager : LocationManagerProtocol
    var currentLocation: CLLocation?
    // min distance (meters) device must move horizontally for update event to be generated
    let distanceFilter: CLLocationDistance = 100
    
    // the parameter is necessary so the class can be testable with a mock CLLocationManager
    public init(with givenLocationManager: LocationManagerProtocol? = nil) {
        if let unwrappedLocationManager = givenLocationManager {
            self.locationManager = unwrappedLocationManager
        }   else {
            self.locationManager = CLLocationManager()
        }
        super.init()
        
        locationManager.requestAuthorizationWhenNotDetermined()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = distanceFilter
        locationManager.delegate = self
    }
    
    func getLatitude() -> CLLocationDegrees? {
        return currentLocation?.coordinate.latitude
    }
    
    func getLongitude() -> CLLocationDegrees? {
        return currentLocation?.coordinate.longitude
    }

    func startUpdatingLocation() {
        print("Starting location updates")
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stopping location updates")
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: LocationManagerDelegate functions
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // get location
        guard let location = locations.last else {
            return
        }
        self.currentLocation = location
    }

}

