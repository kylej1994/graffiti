//
//  MockLocationManager.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/10/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import CoreLocation

class MockLocationManager: LocationManagerProtocol {
    var desiredAccuracy = kCLLocationAccuracyBest
    var distanceFilter: CLLocationDistance = 100
    var delegate: CLLocationManagerDelegate?
    var authorized = false
    
    func requestAuthorizationWhenNotDetermined() {
        authorized = true
    }
    
    func startUpdatingLocation() {
        
    }
    
    func stopUpdatingLocation() {
    
    }
    
    func startMonitoringSignificantLocationChanges() {
    
    }
    
    func setLocation(location: CLLocation) {
        delegate?.locationManager!(CLLocationManager(), didUpdateLocations: [location])
    }
}
