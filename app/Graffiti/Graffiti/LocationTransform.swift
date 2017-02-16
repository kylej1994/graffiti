//
//  LocationTransform.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/15/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation

class LocationTransform : TransformType {
    public typealias Object = CLLocation
    public typealias JSON = [String : Double]
    
    public init() {}
    
    func transformFromJSON(_ value: Any?) -> CLLocation? {
        let params = value as! [String : Double]
        
        guard let latitude = params["latitude"] else {
            return nil
        }
        
        guard let longitude = params["longitude"] else {
            return nil
        }
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func transformToJSON(_ value: CLLocation?) -> [String : Double]? {
        guard let location = value else {
            return nil
        }
        
        let json = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]
        
        return json
    }
}
