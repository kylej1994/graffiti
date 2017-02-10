//
//  UserTests.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import XCTest


class UserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func initTest() {        
        let testUser:User = User(username: "willem", name: "Will", email: "w@uchicago.edu", userImage: nil, textTag: nil, imageTag: nil)
        XCTAssertNotNil(testUser)
    }
    
    
}
