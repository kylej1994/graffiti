//
//  LocationServiceTests.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/10/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import XCTest
import CoreLocation
class LocationServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLocation() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let mock = MockLocationManager()
        let locationService = LocationService(givenLocationManager: mock)
        
        let aLocation = CLLocation(latitude: 10.0, longitude: 10.0)
        
        mock.setLocation(location: aLocation)
        let testLat = locationService.getLatitude()
        let testLong = locationService.getLongitude()
        XCTAssertEqual(testLat, aLocation.coordinate.latitude)
        XCTAssertEqual(testLong, aLocation.coordinate.longitude)
    }
    
    func testDidCallAuthorization() {
        let mock = MockLocationManager()
        _ = LocationService(givenLocationManager: mock)
        XCTAssertTrue(mock.authorized)
        
    }
    
}
