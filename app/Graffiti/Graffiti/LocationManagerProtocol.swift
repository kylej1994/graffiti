//
//  LocationManagerProtocol.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/10/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerProtocol {
    //var desiredAccuracy: CLLocationAccuracy { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    var distanceFilter: CLLocationDistance { get set }
    var delegate: CLLocationManagerDelegate? { get set }
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func startMonitoringSignificantLocationChanges()
    func requestAuthorizationWhenNotDetermined()
    
}

extension CLLocationManager: LocationManagerProtocol {

    func requestAuthorizationWhenNotDetermined() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.requestWhenInUseAuthorization()
        }
    }
}

