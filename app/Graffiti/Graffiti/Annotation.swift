//
//  Annotation.swift
//  Graffiti
//
//  Created by Henry Lewis on 3/3/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import MapKit

class Annotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(latitude: Double, longitude: Double) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.coordinate = location
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
